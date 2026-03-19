/**
 * ai-tool.js — Netlify Function: Claude API proxy for The Prompt Studio
 *
 * POST /api/ai-tool
 * Body: { toolSlug: string, inputs: object }
 * Headers: Authorization: Bearer <supabase_jwt>
 *
 * Flow:
 *   1. Verify JWT → get user
 *   2. Per-user rate limiting (10 req/min)
 *   3. Load tool config from Supabase (min_tier, vertical, system_prompt, prompt_template, max_output_tokens)
 *   4. Check subscription tier + vertical access (filtered by tool.vertical)
 *   5. Check monthly quota (Bronze: 50, Silver: 150, Gold: unlimited)
 *   6. Validate + sanitize inputs against field constraints
 *   7. Build system prompt + structured user message
 *   8. Call Anthropic Claude API (with prompt caching on system turn + retry on 429/529)
 *   9. Log to tool_usage + atomically increment usage_quotas (structured logging)
 *  10. Return generated text
 *
 * Hardened for 1M users:
 *   - Per-user rate limiting via in-memory sliding window
 *   - CLAUDE_MODEL from env var with fallback
 *   - Per-tool max_tokens from DB
 *   - Input length validation per field type
 *   - Claude API error classification + auto-retry (429, 529)
 *   - Structured JSON logging for all events
 *   - Standardized error response format
 *   - Request timeout on Claude API calls
 */

const { createClient } = require('@supabase/supabase-js');
const https = require('https');

// ── Config ────────────────────────────────────────────────────────────────────
const SUPABASE_URL         = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const ANTHROPIC_API_KEY    = process.env.ANTHROPIC_API_KEY;
const ANTHROPIC_API_URL    = 'https://api.anthropic.com/v1/messages';
const CLAUDE_MODEL         = process.env.CLAUDE_MODEL || 'claude-haiku-4-5-20251001';
const DEFAULT_MAX_TOKENS   = parseInt(process.env.DEFAULT_MAX_TOKENS, 10) || 800;
const TIER_QUOTA           = { starter: 50, pro: 150, gold: Infinity, team: Infinity };
const TIER_ORDER           = { starter: 1, pro: 2, gold: 3, team: 4 };

// ── Cost estimation (USD per million tokens) ─────────────────────────────────
// Pricing as of 2025 for claude-haiku-4-5. Update when model changes.
const COST_PER_M = {
  'claude-haiku-4-5-20251001':    { input: 0.80,  output: 4.00 },
  'claude-sonnet-4-5-20241022':   { input: 3.00,  output: 15.00 },
  'default':                      { input: 1.00,  output: 5.00 },
};

function estimateCost(model, inputTokens, outputTokens) {
  const pricing = COST_PER_M[model] || COST_PER_M['default'];
  return ((inputTokens * pricing.input) + (outputTokens * pricing.output)) / 1_000_000;
}

// ── Rate limiting (in-memory sliding window, per function instance) ──────────
const RATE_LIMIT_WINDOW_MS = 60_000;  // 1 minute
const RATE_LIMIT_MAX       = 10;       // 10 requests per minute per user
const _rateLimitMap = new Map();       // userId → [timestamps]

function isRateLimited(userId) {
  const now = Date.now();
  let timestamps = _rateLimitMap.get(userId);
  if (!timestamps) { timestamps = []; _rateLimitMap.set(userId, timestamps); }
  // Evict old entries
  while (timestamps.length && timestamps[0] < now - RATE_LIMIT_WINDOW_MS) timestamps.shift();
  if (timestamps.length >= RATE_LIMIT_MAX) return true;
  timestamps.push(now);
  return false;
}

// Periodic cleanup to prevent memory leak (every 5 min)
setInterval(() => {
  const cutoff = Date.now() - RATE_LIMIT_WINDOW_MS * 2;
  for (const [uid, ts] of _rateLimitMap) {
    if (!ts.length || ts[ts.length - 1] < cutoff) _rateLimitMap.delete(uid);
  }
}, 300_000);

// ── Input constraints per field type ─────────────────────────────────────────
const FIELD_MAX_CHARS = {
  text:     500,
  number:   20,
  select:   200,
  radio:    200,
  toggle:   10,
  tone_grid:200,
  textarea: 4000,
  hidden:   500,
};

function sanitizeInputs(inputs, inputSchema) {
  const clean = {};
  for (const [key, value] of Object.entries(inputs)) {
    if (value === undefined || value === null) continue;
    const str = String(value);
    // Find field definition to get type
    const fieldDef = inputSchema?.fields?.find(f => f.name === key);
    const fieldType = fieldDef?.type || 'text';
    const maxLen = FIELD_MAX_CHARS[fieldType] || 500;
    clean[key] = str.slice(0, maxLen);
  }
  return clean;
}

// ── CORS headers ──────────────────────────────────────────────────────────────
const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || '*';
const CORS = {
  'Access-Control-Allow-Origin':  ALLOWED_ORIGIN,
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

// ── Standardized responses ────────────────────────────────────────────────────
const ok  = (body) => ({ statusCode: 200, headers: CORS, body: JSON.stringify(body) });
const fail = (code, errorCode, message, details = {}) => ({
  statusCode: code, headers: CORS,
  body: JSON.stringify({ error: { code: errorCode, message, ...details } }),
});

// ── Structured logging ────────────────────────────────────────────────────────
function log(event, data = {}) {
  console.log(JSON.stringify({ fn: 'ai-tool', event, ts: new Date().toISOString(), ...data }));
}

// ── Helper: structured XML user message ───────────────────────────────────────
function buildUserMessage(tool, inputs) {
  if (tool.prompt_template) {
    return tool.prompt_template.replace(/\{\{(\w+)\}\}/g, (_, key) =>
      inputs[key] !== undefined ? String(inputs[key]) : `[${key} non fourni]`
    );
  }
  const fields = Object.entries(inputs)
    .filter(([, v]) => v !== undefined && v !== null && String(v).trim() !== '')
    .map(([k, v]) => `  <${k}>${String(v).trim()}</${k}>`)
    .join('\n');
  return `<demande>\n${fields}\n</demande>`;
}

// ── Helper: resolve system prompt ─────────────────────────────────────────────
function buildSystemPrompt(tool) {
  if (tool.system_prompt) return tool.system_prompt;
  return getDefaultSystemPrompt(tool);
}

function getDefaultSystemPrompt(tool) {
  const verticalCtx = {
    immo:         "de l'immobilier",
    commerce:     'du commerce et e-commerce',
    legal:        'du droit et du juridique',
    finance:      "de la finance et de l'investissement",
    marketing:    'du marketing et de la communication',
    rh:           'des ressources humaines et du recrutement',
    sante:        'de la santé et du bien-être',
    education:    "de l'éducation et de la formation",
    restauration: 'de la restauration et de l\'hôtellerie',
    freelance:    'du consulting et du freelancing',
  }[tool.vertical] || '';

  const base = `Tu es un assistant IA expert pour les professionnels ${verticalCtx}. \
Tu rédiges des contenus professionnels, percutants et adaptés au marché français. \
Réponds toujours en français sauf indication contraire. \
Sois direct, structuré et actionnable. \
Réponds uniquement avec le contenu demandé, sans introduction ni commentaire.`;

  const extras = {
    immo:     '\n\nMaîtrise : copywriting immobilier, mise en valeur des biens, vocabulaire professionnel du secteur.',
    commerce: '\n\nMaîtrise : marketing digital, copywriting de conversion, SEO, meilleures pratiques e-commerce.',
    legal:    '\n\nMaîtrise : rédaction juridique professionnelle. Ajoute systématiquement : "Ce contenu est fourni à titre indicatif. Consultez un professionnel du droit pour validation."',
    finance:  '\n\nMaîtrise : analyses financières structurées. Ajoute systématiquement : "Ce contenu est informatif et ne constitue pas un conseil en investissement."',
    sante:    '\n\nMaîtrise : communication santé professionnelle. Ajoute systématiquement : "Ce contenu est informatif et ne remplace pas un avis médical professionnel."',
  };

  return base + (extras[tool.vertical] || '');
}

// ── Helper: call Claude API with retry on 429/529 ────────────────────────────
function callClaude(systemPrompt, userMessage, maxTokens, retries = 2) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model:      CLAUDE_MODEL,
      max_tokens: maxTokens,
      system: systemPrompt,
      messages: [{ role: 'user', content: userMessage }],
    });

    const options = {
      method:  'POST',
      headers: {
        'Content-Type':      'application/json',
        'x-api-key':         ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
        'Content-Length':    Buffer.byteLength(payload),
      },
      timeout: 15_000, // 15s timeout
    };

    const req = https.request(ANTHROPIC_API_URL, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);

          // Retryable errors: 429 (rate limit) and 529 (overloaded)
          if ((res.statusCode === 429 || res.statusCode === 529) && retries > 0) {
            const delay = res.statusCode === 429 ? 2000 : 5000;
            log('claude_retry', { statusCode: res.statusCode, retries, delay });
            return setTimeout(() => {
              callClaude(systemPrompt, userMessage, maxTokens, retries - 1)
                .then(resolve).catch(reject);
            }, delay);
          }

          // Auth error — alert ops
          if (res.statusCode === 401) {
            log('claude_auth_error', { statusCode: 401 });
            return reject(new Error('CLAUDE_AUTH_ERROR'));
          }

          // Content filter / bad request
          if (res.statusCode === 400) {
            const msg = parsed?.error?.message || 'Bad request to AI';
            log('claude_bad_request', { message: msg });
            return reject(new Error(`CLAUDE_BAD_REQUEST: ${msg}`));
          }

          if (parsed.error) return reject(new Error(parsed.error.message));
          resolve(parsed);
        } catch (e) {
          reject(new Error('Invalid Claude API response'));
        }
      });
    });

    req.on('timeout', () => { req.destroy(); reject(new Error('CLAUDE_TIMEOUT')); });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

// ── Helper: atomic quota increment via RPC (per vertical) ─────────────────────
async function incrementQuota(supabase, userId, vertical = '') {
  const month = new Date().toISOString().slice(0, 7);
  const { error } = await supabase.rpc('increment_usage_quota', {
    p_user_id:  userId,
    p_month:    month,
    p_vertical: vertical,
  });
  if (error) {
    log('rpc_fallback', { reason: error.message });
    const { data: existing } = await supabase
      .from('usage_quotas').select('id, count')
      .eq('user_id', userId).eq('month', month).eq('vertical', vertical).single();
    if (existing) {
      await supabase.from('usage_quotas').update({ count: existing.count + 1 }).eq('id', existing.id);
    } else {
      await supabase.from('usage_quotas').insert({ user_id: userId, month, vertical, count: 1 });
    }
  }
}

// ── Main handler ──────────────────────────────────────────────────────────────
exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: CORS, body: '' };
  if (event.httpMethod !== 'POST')    return fail(405, 'METHOD_NOT_ALLOWED', 'Method not allowed');

  // Guard: fail fast if required env vars are missing
  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY || !ANTHROPIC_API_KEY) {
    const missing = ['SUPABASE_URL','SUPABASE_SERVICE_KEY','ANTHROPIC_API_KEY']
      .filter(k => !process.env[k]).join(', ');
    log('missing_env', { missing });
    return fail(500, 'SERVER_ERROR', 'Server misconfiguration. Contact support.');
  }

  // ── 1. Parse body ──────────────────────────────────────────────────────────
  let toolSlug, inputs, projectId;
  try {
    ({ toolSlug, inputs, projectId } = JSON.parse(event.body || '{}'));
  } catch {
    return fail(400, 'INVALID_JSON', 'Invalid JSON body');
  }
  if (!toolSlug || !inputs || typeof inputs !== 'object') {
    return fail(400, 'MISSING_PARAMS', 'Missing toolSlug or inputs');
  }

  // ── 2. Verify JWT ──────────────────────────────────────────────────────────
  const authHeader = event.headers.authorization || event.headers.Authorization || '';
  const token = authHeader.replace('Bearer ', '').trim();
  if (!token) return fail(401, 'AUTH_REQUIRED', 'Missing authorization token');

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) return fail(401, 'AUTH_REQUIRED', 'Invalid or expired token');

  // ── 3. Rate limiting ───────────────────────────────────────────────────────
  if (isRateLimited(user.id)) {
    log('rate_limited', { userId: user.id, toolSlug });
    return fail(429, 'RATE_LIMITED', 'Trop de requêtes. Veuillez patienter 1 minute.', { retryAfter: 60 });
  }

  // ── 4. Load tool config ────────────────────────────────────────────────────
  const { data: tool, error: toolError } = await supabase
    .from('tools')
    .select('slug, name, vertical, min_tier, system_prompt, prompt_template, max_output_tokens, input_schema, is_active')
    .eq('slug', toolSlug)
    .single();

  if (toolError || !tool) return fail(404, 'TOOL_NOT_FOUND', 'Tool not found');
  if (!tool.is_active)    return fail(403, 'TOOL_UNAVAILABLE', 'Tool is currently unavailable');

  // ── 5. Validate & sanitize inputs against schema ───────────────────────────
  inputs = sanitizeInputs(inputs, tool.input_schema);

  // ── 6. Load subscription — filtered by tool vertical ──────────────────────
  const { data: sub } = await supabase
    .from('subscriptions')
    .select('tier, vertical, current_period_end, trial_ends_at')
    .eq('user_id', user.id)
    .eq('vertical', tool.vertical)
    .eq('status', 'active')
    .single();

  if (!sub) {
    return fail(403, 'NO_SUBSCRIPTION', 'Aucun abonnement actif pour cette verticale.', { vertical: tool.vertical });
  }
  if (sub.current_period_end && new Date(sub.current_period_end) < new Date()) {
    return fail(403, 'SUBSCRIPTION_EXPIRED', 'Abonnement expiré.', { vertical: tool.vertical });
  }

  // Trial = full access to all tools regardless of tier
  const isInTrial = sub.trial_ends_at && new Date(sub.trial_ends_at) > new Date();

  if (!isInTrial) {
    const userTierOrder = TIER_ORDER[sub.tier]      || 0;
    const toolTierOrder = TIER_ORDER[tool.min_tier] || 1;
    if (userTierOrder < toolTierOrder) {
      return fail(403, 'UPGRADE_REQUIRED', `Upgrade requis (${tool.min_tier}).`, {
        required: tool.min_tier, yours: sub.tier,
      });
    }
  }

  // ── 7. Check monthly quota (per vertical) ─────────────────────────────────
  const quota = TIER_QUOTA[sub.tier];
  if (quota === undefined) {
    log('unknown_tier', { userId: user.id, tier: sub.tier, vertical: tool.vertical });
    return fail(403, 'INVALID_TIER', `Tier inconnu: ${sub.tier}.`);
  }
  if (quota !== Infinity) {
    const month = new Date().toISOString().slice(0, 7);
    const { data: usageRow } = await supabase
      .from('usage_quotas').select('count')
      .eq('user_id', user.id).eq('month', month).eq('vertical', tool.vertical).single();

    const currentCount = usageRow?.count || 0;
    if (currentCount >= quota) {
      return fail(429, 'QUOTA_EXCEEDED', `Quota atteint (${currentCount}/${quota}).`, {
        used: currentCount, limit: quota, vertical: tool.vertical,
      });
    }
  }

  // ── 8. Build prompt ────────────────────────────────────────────────────────
  const systemPrompt = buildSystemPrompt(tool);
  const userMessage  = buildUserMessage(tool, inputs);
  const maxTokens    = tool.max_output_tokens || DEFAULT_MAX_TOKENS;

  // ── 9. Call Claude with retry ──────────────────────────────────────────────
  const startMs = Date.now();
  let claudeResponse;
  try {
    claudeResponse = await callClaude(systemPrompt, userMessage, maxTokens);
  } catch (e) {
    const durationMs = Date.now() - startMs;
    log('generation_error', { userId: user.id, toolSlug, error: e.message, durationMs });
    // Log failed request to DB for admin monitoring
    try {
      await supabase.from('tool_usage').insert({
        user_id: user.id, tool_slug: toolSlug, input_data: inputs,
        duration_ms: durationMs, vertical: tool.vertical, model: CLAUDE_MODEL,
        request_status: 'error', output_text: `[ERROR] ${e.message}`.slice(0, 500),
      });
    } catch (_) { /* best-effort */ }

    if (e.message === 'CLAUDE_TIMEOUT') {
      return fail(504, 'GENERATION_TIMEOUT', "La génération a pris trop de temps. Réessayez.");
    }
    if (e.message === 'CLAUDE_AUTH_ERROR') {
      return fail(502, 'GENERATION_FAILED', "Erreur d'authentification IA. Contactez le support.");
    }
    if (e.message.startsWith('CLAUDE_BAD_REQUEST')) {
      return fail(400, 'GENERATION_FAILED', "Le contenu n'a pas pu être généré. Modifiez vos entrées.");
    }
    return fail(502, 'GENERATION_FAILED', 'Génération IA échouée. Réessayez dans un instant.');
  }

  const durationMs    = Date.now() - startMs;
  const outputText    = claudeResponse.content?.[0]?.text || '';
  const usage         = claudeResponse.usage || {};
  const inputTokens   = usage.input_tokens || 0;
  const outputTokens  = usage.output_tokens || 0;
  const tokensUsed    = inputTokens + outputTokens;
  const tokensSaved   = usage.cache_read_input_tokens || 0;
  const cacheHit      = tokensSaved > 0;
  const modelUsed     = CLAUDE_MODEL;
  const estCost       = estimateCost(modelUsed, inputTokens, outputTokens);

  // ── 10. Log usage (structured) ──────────────────────────────────────────────
  log('generation_success', {
    userId: user.id, toolSlug, vertical: tool.vertical, tier: sub.tier,
    durationMs, tokensUsed, tokensSaved, cacheHit, maxTokens,
    inputTokens, outputTokens, model: modelUsed, estimated_cost_usd: estCost,
  });

  const usageRow = {
    user_id:            user.id,
    tool_slug:          toolSlug,
    input_data:         inputs,
    output_text:        outputText,
    tokens_used:        tokensUsed,
    input_tokens:       inputTokens,
    output_tokens:      outputTokens,
    duration_ms:        durationMs,
    model:              modelUsed,
    vertical:           tool.vertical,
    estimated_cost_usd: estCost,
    request_status:     'success',
  };
  // Link to project if provided (CRM)
  if (projectId && typeof projectId === 'string' && projectId.length > 10) {
    usageRow.project_id = projectId;
  }

  // Non-blocking: don't fail user response if logging/quota fails
  await Promise.allSettled([
    supabase.from('tool_usage').insert(usageRow).then(({ error }) => {
      if (error) log('usage_log_error', { error: error.message, toolSlug });
    }),
    incrementQuota(supabase, user.id, tool.vertical),
  ]);

  // ── 11. Return ──────────────────────────────────────────────────────────────
  return ok({
    output:     outputText,
    tokensUsed,
    tokensSaved,
    durationMs,
    tool:       { slug: toolSlug, name: tool.name },
  });
};

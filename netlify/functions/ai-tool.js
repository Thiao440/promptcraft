/**
 * ai-tool.js — Netlify Function: Claude API proxy for The Prompt Studio
 *
 * POST /api/ai-tool
 * Body: { toolSlug: string, inputs: object }
 * Headers: Authorization: Bearer <supabase_jwt>
 *
 * Flow:
 *   1. Verify JWT → get user
 *   2. Load tool config from Supabase (min_tier, vertical, system_prompt, prompt_template, max_output_tokens)
 *   3. Check subscription tier + vertical access (filtered by tool.vertical)
 *   4. Check monthly quota (Bronze: 50, Silver: 150, Gold: unlimited)
 *   5. Build system prompt + structured user message
 *   6. Call Anthropic Claude API (with prompt caching on system turn)
 *   7. Log to tool_usage + atomically increment usage_quotas
 *   8. Return generated text
 */

const { createClient } = require('@supabase/supabase-js');
const https = require('https');

// ── Config ────────────────────────────────────────────────────────────────────
const SUPABASE_URL         = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const ANTHROPIC_API_KEY    = process.env.ANTHROPIC_API_KEY;
const ANTHROPIC_API_URL    = 'https://api.anthropic.com/v1/messages';
const CLAUDE_MODEL         = 'claude-3-5-haiku-20241022';
const DEFAULT_MAX_TOKENS   = 800;
const TIER_QUOTA           = { bronze: 50, silver: 150, gold: Infinity };
const TIER_ORDER           = { bronze: 1, silver: 2, gold: 3 };

// ── CORS headers ──────────────────────────────────────────────────────────────
const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

// ── Helpers: HTTP responses ───────────────────────────────────────────────────
const ok  = (body) => ({ statusCode: 200, headers: CORS, body: JSON.stringify(body) });
const err = (code, msg) => ({ statusCode: code, headers: CORS, body: JSON.stringify({ error: msg }) });

// ── Helper: structured XML user message ───────────────────────────────────────
// Sends inputs once, clearly labeled, in the user turn only.
// Template ({{key}}) is used if present to control field ordering/labeling;
// otherwise inputs are serialized as XML for Claude to parse efficiently.
function buildUserMessage(tool, inputs) {
  if (tool.prompt_template) {
    // Template controls the user message shape
    return tool.prompt_template.replace(/\{\{(\w+)\}\}/g, (_, key) =>
      inputs[key] !== undefined ? String(inputs[key]) : `[${key} non fourni]`
    );
  }

  // Default: structured XML block — cheaper and clearer than markdown bullets
  const fields = Object.entries(inputs)
    .filter(([, v]) => v !== undefined && v !== null && String(v).trim() !== '')
    .map(([k, v]) => `  <${k}>${String(v).trim()}</${k}>`)
    .join('\n');

  return `<demande>\n${fields}\n</demande>`;
}

// ── Helper: resolve system prompt ─────────────────────────────────────────────
// Priority: tool.system_prompt (DB) > vertical default
function buildSystemPrompt(tool) {
  if (tool.system_prompt) return tool.system_prompt;
  return getDefaultSystemPrompt(tool);
}

// ── Helper: vertical defaults (fallback when DB has no system_prompt) ─────────
function getDefaultSystemPrompt(tool) {
  const verticalCtx = {
    immo:     "de l'immobilier",
    commerce: 'du commerce et e-commerce',
    legal:    'du droit et du juridique',
    finance:  'de la finance et de l\'investissement',
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
  };

  return base + (extras[tool.vertical] || '');
}

// ── Helper: call Anthropic API with prompt caching on system turn ─────────────
function callClaude(systemPrompt, userMessage, maxTokens) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model:      CLAUDE_MODEL,
      max_tokens: maxTokens,
      system: [
        {
          type: 'text',
          text: systemPrompt,
          // Cache the system prompt — saves ~80% of system turn tokens
          // on repeated calls to the same tool (TTL: 5 min, min 1024 tokens)
          cache_control: { type: 'ephemeral' },
        },
      ],
      messages: [{ role: 'user', content: userMessage }],
    });

    const options = {
      method:  'POST',
      headers: {
        'Content-Type':      'application/json',
        'x-api-key':         ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
        'anthropic-beta':    'prompt-caching-2024-07-31',
        'Content-Length':    Buffer.byteLength(payload),
      },
    };

    const req = https.request(ANTHROPIC_API_URL, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          if (parsed.error) return reject(new Error(parsed.error.message));
          resolve(parsed);
        } catch (e) {
          reject(new Error('Invalid Claude API response'));
        }
      });
    });

    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

// ── Helper: atomic quota increment via RPC ────────────────────────────────────
// Replaces read-modify-write pattern with a single atomic upsert.
async function incrementQuota(supabase, userId) {
  const month = new Date().toISOString().slice(0, 7); // 'YYYY-MM'

  const { error } = await supabase.rpc('increment_usage_quota', {
    p_user_id: userId,
    p_month:   month,
  });

  if (error) {
    // Fallback: non-atomic upsert (safe if RPC not yet deployed)
    console.warn('increment_usage_quota RPC unavailable, using fallback:', error.message);
    const { data: existing } = await supabase
      .from('usage_quotas')
      .select('id, count')
      .eq('user_id', userId)
      .eq('month', month)
      .single();

    if (existing) {
      await supabase
        .from('usage_quotas')
        .update({ count: existing.count + 1 })
        .eq('id', existing.id);
    } else {
      await supabase
        .from('usage_quotas')
        .insert({ user_id: userId, month, count: 1 });
    }
  }
}

// ── Main handler ──────────────────────────────────────────────────────────────
exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: CORS, body: '' };
  if (event.httpMethod !== 'POST')    return err(405, 'Method not allowed');

  // Guard: fail fast with a JSON error if required env vars are missing.
  // Without this, the function crashes mid-execution and Netlify may return
  // a plain-text error page that breaks res.json() on the client side.
  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY || !ANTHROPIC_API_KEY) {
    const missing = ['SUPABASE_URL','SUPABASE_SERVICE_KEY','ANTHROPIC_API_KEY']
      .filter(k => !process.env[k]).join(', ');
    console.error('[ai-tool] Missing env vars:', missing);
    return err(500, 'Server misconfiguration. Contact support.');
  }

  // ── 1. Parse body ──────────────────────────────────────────────────────────
  let toolSlug, inputs;
  try {
    ({ toolSlug, inputs } = JSON.parse(event.body || '{}'));
  } catch {
    return err(400, 'Invalid JSON body');
  }

  if (!toolSlug || !inputs || typeof inputs !== 'object') {
    return err(400, 'Missing toolSlug or inputs');
  }

  // ── 2. Verify JWT ──────────────────────────────────────────────────────────
  const authHeader = event.headers.authorization || event.headers.Authorization || '';
  const token = authHeader.replace('Bearer ', '').trim();
  if (!token) return err(401, 'Missing authorization token');

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) return err(401, 'Invalid or expired token');

  // ── 3. Load tool config ────────────────────────────────────────────────────
  const { data: tool, error: toolError } = await supabase
    .from('tools')
    .select('slug, name, vertical, min_tier, system_prompt, prompt_template, max_output_tokens, is_active')
    .eq('slug', toolSlug)
    .single();

  if (toolError || !tool) return err(404, 'Tool not found');
  if (!tool.is_active)    return err(403, 'Tool is currently unavailable');

  // ── 4. Load subscription — filtered by tool vertical ──────────────────────
  // Critical: a user can have multiple subscriptions (one per vertical).
  // Must query by vertical to get the relevant one.
  const { data: sub } = await supabase
    .from('subscriptions')
    .select('tier, vertical, current_period_end')
    .eq('user_id', user.id)
    .eq('vertical', tool.vertical)
    .eq('status', 'active')
    .single();

  if (!sub) return err(403, JSON.stringify({ reason: 'no_subscription', vertical: tool.vertical }));

  if (sub.current_period_end && new Date(sub.current_period_end) < new Date()) {
    return err(403, JSON.stringify({ reason: 'expired', vertical: tool.vertical }));
  }

  const userTierOrder = TIER_ORDER[sub.tier]      || 0;
  const toolTierOrder = TIER_ORDER[tool.min_tier] || 1;
  if (userTierOrder < toolTierOrder) {
    return err(403, JSON.stringify({
      reason:   'upgrade_required',
      required: tool.min_tier,
      yours:    sub.tier,
    }));
  }

  // ── 5. Check monthly quota ─────────────────────────────────────────────────
  const quota = TIER_QUOTA[sub.tier] ?? 50;

  if (quota !== Infinity) {
    const month = new Date().toISOString().slice(0, 7);
    const { data: usageRow } = await supabase
      .from('usage_quotas')
      .select('count')
      .eq('user_id', user.id)
      .eq('month', month)
      .single();

    const currentCount = usageRow?.count || 0;
    if (currentCount >= quota) {
      return err(429, JSON.stringify({
        reason: 'quota_exceeded',
        used:   currentCount,
        limit:  quota,
      }));
    }
  }

  // ── 6. Build prompt ────────────────────────────────────────────────────────
  const systemPrompt = buildSystemPrompt(tool);
  const userMessage  = buildUserMessage(tool, inputs);
  const maxTokens    = tool.max_output_tokens || DEFAULT_MAX_TOKENS;

  // ── 7. Call Claude ─────────────────────────────────────────────────────────
  const startMs = Date.now();
  let claudeResponse;
  try {
    claudeResponse = await callClaude(systemPrompt, userMessage, maxTokens);
  } catch (e) {
    console.error('Claude API error:', e.message);
    return err(502, 'AI generation failed. Please try again.');
  }

  const durationMs = Date.now() - startMs;
  const outputText = claudeResponse.content?.[0]?.text || '';
  const usage      = claudeResponse.usage || {};
  const tokensUsed = (usage.input_tokens || 0) + (usage.output_tokens || 0);
  // Log cache savings for monitoring (cache_read_input_tokens = tokens saved)
  const tokensSaved = usage.cache_read_input_tokens || 0;

  // ── 8. Log usage ───────────────────────────────────────────────────────────
  await Promise.all([
    supabase.from('tool_usage').insert({
      user_id:      user.id,
      tool_slug:    toolSlug,
      input_data:   inputs,
      output_text:  outputText,
      tokens_used:  tokensUsed,
      duration_ms:  durationMs,
    }),
    incrementQuota(supabase, user.id),
  ]);

  // ── 9. Return ──────────────────────────────────────────────────────────────
  return ok({
    output:      outputText,
    tokensUsed,
    tokensSaved,
    durationMs,
    tool:        { slug: toolSlug, name: tool.name },
  });
};

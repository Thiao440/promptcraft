/**
 * ai-tool.js — Netlify Function: Claude API proxy for The Prompt Studio
 *
 * POST /api/ai-tool
 * Body: { toolSlug: string, inputs: object }
 * Headers: Authorization: Bearer <supabase_jwt>
 *
 * Flow:
 *   1. Verify JWT → get user
 *   2. Load tool config from Supabase (min_tier, vertical, prompt_template, input_schema)
 *   3. Check subscription tier + vertical access
 *   4. Check monthly quota (Bronze: 50, Silver: 150, Gold: unlimited)
 *   5. Build system prompt from template + user inputs
 *   6. Call Anthropic Claude API
 *   7. Log to tool_usage + increment usage_quotas
 *   8. Return generated text
 */

const { createClient } = require('@supabase/supabase-js');
const https = require('https');

// ── Config ────────────────────────────────────────────────────────────────────
const SUPABASE_URL         = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const ANTHROPIC_API_KEY    = process.env.ANTHROPIC_API_KEY;
const ANTHROPIC_API_URL    = 'https://api.anthropic.com/v1/messages';
const CLAUDE_MODEL         = 'claude-3-5-haiku-20241022'; // Fast + affordable
const MAX_TOKENS           = 1500;
const TIER_QUOTA           = { bronze: 50, silver: 150, gold: Infinity };
const TIER_ORDER           = { bronze: 1, silver: 2, gold: 3 };

// ── CORS headers ──────────────────────────────────────────────────────────────
const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

// ── Helper: HTTP response ─────────────────────────────────────────────────────
const ok  = (body) => ({ statusCode: 200, headers: CORS, body: JSON.stringify(body) });
const err = (code, msg) => ({ statusCode: code, headers: CORS, body: JSON.stringify({ error: msg }) });

// ── Helper: call Anthropic API ────────────────────────────────────────────────
function callClaude(systemPrompt, userMessage) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model:      CLAUDE_MODEL,
      max_tokens: MAX_TOKENS,
      system:     systemPrompt,
      messages:   [{ role: 'user', content: userMessage }],
    });

    const options = {
      method:  'POST',
      headers: {
        'Content-Type':            'application/json',
        'x-api-key':               ANTHROPIC_API_KEY,
        'anthropic-version':       '2023-06-01',
        'Content-Length':          Buffer.byteLength(payload),
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

// ── Helper: build prompt from template ───────────────────────────────────────
function buildPrompt(template, inputs) {
  if (!template) return null;
  // Replace {{key}} placeholders with input values
  return template.replace(/\{\{(\w+)\}\}/g, (_, key) => {
    return inputs[key] !== undefined ? String(inputs[key]) : `[${key} non fourni]`;
  });
}

// ── Helper: build user message from inputs ─────────────────────────────────
function buildUserMessage(toolName, inputs) {
  const lines = Object.entries(inputs)
    .filter(([, v]) => v !== undefined && v !== null && v !== '')
    .map(([k, v]) => `- **${k}**: ${v}`);
  return `Génère un contenu pour l'outil "${toolName}" avec les informations suivantes :\n\n${lines.join('\n')}`;
}

// ── Helper: increment usage quota (upsert) ───────────────────────────────────
async function incrementQuota(supabase, userId) {
  const month = new Date().toISOString().slice(0, 7); // 'YYYY-MM'

  // Try to get current count
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
    return existing.count + 1;
  } else {
    await supabase
      .from('usage_quotas')
      .insert({ user_id: userId, month, count: 1 });
    return 1;
  }
}

// ── Main handler ──────────────────────────────────────────────────────────────
exports.handler = async (event) => {
  // Preflight
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers: CORS, body: '' };
  }

  if (event.httpMethod !== 'POST') {
    return err(405, 'Method not allowed');
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
    .select('slug, name, vertical, min_tier, prompt_template, is_active')
    .eq('slug', toolSlug)
    .single();

  if (toolError || !tool) return err(404, 'Tool not found');
  if (!tool.is_active)   return err(403, 'Tool is currently unavailable');

  // ── 4. Load subscription ───────────────────────────────────────────────────
  const { data: sub } = await supabase
    .from('subscriptions')
    .select('*')
    .eq('user_id', user.id)
    .eq('status', 'active')
    .single();

  if (!sub) return err(403, JSON.stringify({ reason: 'no_subscription' }));

  // Check expiry
  if (sub.current_period_end && new Date(sub.current_period_end) < new Date()) {
    return err(403, JSON.stringify({ reason: 'expired' }));
  }

  // Check tier
  const userTierOrder = TIER_ORDER[sub.tier] || 0;
  const toolTierOrder = TIER_ORDER[tool.min_tier] || 1;
  if (userTierOrder < toolTierOrder) {
    return err(403, JSON.stringify({
      reason: 'upgrade_required',
      required: tool.min_tier,
      yours: sub.tier,
    }));
  }

  // Check vertical (Bronze = 1 vertical)
  if (sub.tier === 'bronze' && sub.vertical && sub.vertical !== tool.vertical) {
    return err(403, JSON.stringify({
      reason: 'wrong_vertical',
      yours: sub.vertical,
      toolVertical: tool.vertical,
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
        used: currentCount,
        limit: quota,
      }));
    }
  }

  // ── 6. Build prompt ────────────────────────────────────────────────────────
  const systemPrompt = tool.prompt_template
    ? buildPrompt(tool.prompt_template, inputs)
    : getDefaultSystemPrompt(tool);

  const userMessage = buildUserMessage(tool.name, inputs);

  // ── 7. Call Claude ─────────────────────────────────────────────────────────
  const startMs = Date.now();
  let claudeResponse;
  try {
    claudeResponse = await callClaude(systemPrompt, userMessage);
  } catch (e) {
    console.error('Claude API error:', e.message);
    return err(502, 'AI generation failed. Please try again.');
  }

  const durationMs  = Date.now() - startMs;
  const outputText  = claudeResponse.content?.[0]?.text || '';
  const tokensUsed  = claudeResponse.usage?.input_tokens + claudeResponse.usage?.output_tokens || 0;

  // ── 8. Log usage ───────────────────────────────────────────────────────────
  await Promise.all([
    // Log individual generation
    supabase.from('tool_usage').insert({
      user_id:     user.id,
      tool_slug:   toolSlug,
      input_data:  inputs,
      output_text: outputText,
      tokens_used: tokensUsed,
      duration_ms: durationMs,
    }),
    // Increment monthly quota counter
    incrementQuota(supabase, user.id),
  ]);

  // ── 9. Return result ───────────────────────────────────────────────────────
  return ok({
    output:     outputText,
    tokensUsed,
    durationMs,
    tool:       { slug: toolSlug, name: tool.name },
  });
};

// ── Default system prompts per vertical ────────────────────────────────────────
function getDefaultSystemPrompt(tool) {
  const base = `Tu es un assistant IA expert pour les professionnels ${
    { immo: 'de l\'immobilier', commerce: 'du commerce et e-commerce', legal: 'du droit et du juridique', finance: 'de la finance et de l\'investissement' }[tool.vertical] || ''
  }. Tu rédiges des contenus professionnels, percutants et adaptés au marché français. Réponds toujours en français sauf indication contraire. Sois direct, structuré et actionnable.`;

  const extras = {
    immo: '\n\nTu maîtrises les techniques de copywriting immobilier : mise en valeur des biens, formulations qui créent du désir, vocabulaire professionnel du secteur.',
    commerce: '\n\nTu maîtrises le marketing digital, le copywriting de conversion, le SEO et les meilleures pratiques e-commerce.',
    legal: '\n\nTu produis des documents juridiques clairs et professionnels. Important : précise toujours que le contenu est à titre indicatif et qu\'une vérification par un professionnel est recommandée.',
    finance: '\n\nTu rédiges des analyses financières structurées et professionnelles. Important : précise que le contenu est informatif et ne constitue pas un conseil en investissement.',
  };

  return base + (extras[tool.vertical] || '');
}

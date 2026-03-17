/**
 * ai-chat.js — Netlify Function: Conversational AI assistant proxy (v3 hardened)
 *
 * POST /api/ai-chat
 * Body: { vertical: string, messages: [{role:'user'|'assistant', content:string}] }
 * Headers: Authorization: Bearer <supabase_jwt>
 *
 * Hardened: rate limiting, env-var model, retries, structured logging, all 10 verticals
 */

const { createClient } = require('@supabase/supabase-js');
const https = require('https');

const SUPABASE_URL         = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const ANTHROPIC_API_KEY    = process.env.ANTHROPIC_API_KEY;
const ANTHROPIC_API_URL    = 'https://api.anthropic.com/v1/messages';
const CLAUDE_MODEL         = process.env.CLAUDE_MODEL || 'claude-3-5-haiku-20241022';
const MAX_TOKENS           = parseInt(process.env.CHAT_MAX_TOKENS, 10) || 1200;
const MAX_HISTORY_TURNS    = 24;
const MAX_MSG_CHARS        = 4000;
const TIER_QUOTA           = { bronze: 50, silver: 150, gold: Infinity };

// ── Rate limiting ─────────────────────────────────────────────────────────────
const _rl = new Map();
function isRateLimited(uid) {
  const now = Date.now();
  let ts = _rl.get(uid);
  if (!ts) { ts = []; _rl.set(uid, ts); }
  while (ts.length && ts[0] < now - 60000) ts.shift();
  if (ts.length >= 10) return true;
  ts.push(now);
  return false;
}
setInterval(() => {
  const cutoff = Date.now() - 120000;
  for (const [k, v] of _rl) { if (!v.length || v[v.length-1] < cutoff) _rl.delete(k); }
}, 300000);

function log(event, data = {}) {
  console.log(JSON.stringify({ fn: 'ai-chat', event, ts: new Date().toISOString(), ...data }));
}

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};
const ok   = (body) => ({ statusCode: 200, headers: CORS, body: JSON.stringify(body) });
const fail = (code, errorCode, message, details = {}) => ({
  statusCode: code, headers: CORS,
  body: JSON.stringify({ error: { code: errorCode, message, ...details } }),
});

// ── Bot system prompts (all 10 verticals) ────────────────────────────────────
const BOT_SYSTEM = {
  immo: `Tu es ImmoBot, l'assistant IA expert immobilier de The Prompt Studio. Tu aides les professionnels de l'immobilier. Compétences : estimation, rédaction d'annonces, réglementation (ALUR, Hoguet, DPE), gestion locative, prospection, fiscalité (LMNP, SCI). Direct, structuré, opérationnel. Français uniquement.`,
  commerce: `Tu es CommerceBot, l'assistant IA expert e-commerce de The Prompt Studio. Compétences : SEO, SEA, fiches produit, email marketing, copywriting, CRO, marketplaces. Créatif et orienté résultats. Français uniquement.`,
  legal: `Tu es JuriBot, l'assistant IA expert juridique de The Prompt Studio. Compétences : contrats, droit des affaires, droit du travail, procédure civile, PI. IMPORTANT : assistance informationnelle uniquement, rappelle qu'un avocat doit valider. Français uniquement.`,
  finance: `Tu es FinBot, l'assistant IA expert finance de The Prompt Studio. Compétences : analyse financière, investissement, business plan, comptabilité, fiscalité, M&A. Rappelle que ce n'est pas un conseil en investissement. Français uniquement.`,
  marketing: `Tu es MarketBot, l'assistant IA expert marketing de The Prompt Studio. Compétences : stratégie de contenu, SEO/SEA, réseaux sociaux, email marketing, branding. Créatif et data-driven. Français uniquement.`,
  rh: `Tu es RHBot, l'assistant IA expert ressources humaines de The Prompt Studio. Compétences : recrutement, gestion des talents, droit social, communication interne, marque employeur. Bienveillant et orienté conformité. Français uniquement.`,
  sante: `Tu es SantéBot, l'assistant IA expert santé de The Prompt Studio. Compétences : communication médicale, gestion de cabinet, marketing santé. JAMAIS de diagnostic médical, contenus informatifs uniquement. Français uniquement.`,
  education: `Tu es EduBot, l'assistant IA expert éducation de The Prompt Studio. Compétences : ingénierie pédagogique, e-learning, formation professionnelle, Qualiopi. Pédagogue et structuré. Français uniquement.`,
  restauration: `Tu es RestoBot, l'assistant IA expert restauration de The Prompt Studio. Compétences : menus, descriptions de plats, marketing food, gestion, recrutement restauration. Créatif et orienté business. Français uniquement.`,
  freelance: `Tu es FreelanceBot, l'assistant IA expert freelance de The Prompt Studio. Compétences : prospection, propositions commerciales, personal branding, gestion d'activité, statuts juridiques. Pragmatique et empathique. Français uniquement.`,
};

function buildSystemPrompt(vertical, tier) {
  const base = BOT_SYSTEM[vertical] ||
    `Tu es Studio AI, l'assistant IA de The Prompt Studio. Tu aides les professionnels. Français uniquement.`;
  const tierLabel = { bronze: 'Bronze', silver: 'Silver', gold: 'Gold' }[tier] || tier;
  const today = new Date().toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' });
  return `${base}\n\n---\nContexte : abonnement ${tierLabel} — ${vertical}. Date : ${today}. Ton conversationnel et professionnel.`;
}

function callClaude(systemPrompt, messages, maxTokens, retries = 2) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model: CLAUDE_MODEL, max_tokens: maxTokens,
      system: [{ type: 'text', text: systemPrompt, cache_control: { type: 'ephemeral' } }],
      messages,
    });
    const opts = {
      method: 'POST', timeout: 15000,
      headers: {
        'Content-Type': 'application/json', 'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01', 'anthropic-beta': 'prompt-caching-2024-07-31',
        'Content-Length': Buffer.byteLength(payload),
      },
    };
    const req = https.request(ANTHROPIC_API_URL, opts, (res) => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        try {
          const p = JSON.parse(data);
          if ((res.statusCode === 429 || res.statusCode === 529) && retries > 0) {
            const d = res.statusCode === 429 ? 2000 : 5000;
            return setTimeout(() => callClaude(systemPrompt, messages, maxTokens, retries-1).then(resolve).catch(reject), d);
          }
          if (p.error) return reject(new Error(p.error.message));
          resolve(p);
        } catch { reject(new Error('Invalid Claude API response')); }
      });
    });
    req.on('timeout', () => { req.destroy(); reject(new Error('CLAUDE_TIMEOUT')); });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

async function incrementQuota(supabase, userId) {
  const month = new Date().toISOString().slice(0, 7);
  const { error } = await supabase.rpc('increment_usage_quota', { p_user_id: userId, p_month: month });
  if (error) {
    const { data: ex } = await supabase.from('usage_quotas').select('id, count').eq('user_id', userId).eq('month', month).single();
    if (ex) await supabase.from('usage_quotas').update({ count: ex.count + 1 }).eq('id', ex.id);
    else await supabase.from('usage_quotas').insert({ user_id: userId, month, count: 1 });
  }
}

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: CORS, body: '' };
  if (event.httpMethod !== 'POST') return fail(405, 'METHOD_NOT_ALLOWED', 'Method not allowed');

  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY || !ANTHROPIC_API_KEY) {
    log('missing_env', {});
    return fail(500, 'SERVER_ERROR', 'Server misconfiguration.');
  }

  let vertical, messages;
  try { ({ vertical, messages } = JSON.parse(event.body || '{}')); } catch { return fail(400, 'INVALID_JSON', 'Invalid JSON'); }
  if (!vertical || !Array.isArray(messages) || !messages.length) return fail(400, 'MISSING_PARAMS', 'Missing vertical or messages');

  const sanitized = messages
    .filter(m => m && (m.role === 'user' || m.role === 'assistant') && typeof m.content === 'string' && m.content.trim())
    .slice(-MAX_HISTORY_TURNS)
    .map(m => ({ role: m.role, content: m.content.slice(0, MAX_MSG_CHARS) }));
  if (!sanitized.length || sanitized[sanitized.length - 1].role !== 'user') return fail(400, 'INVALID_MESSAGES', 'Last message must be from user');

  const token = (event.headers.authorization || event.headers.Authorization || '').replace('Bearer ', '').trim();
  if (!token) return fail(401, 'AUTH_REQUIRED', 'Missing token');

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) return fail(401, 'AUTH_REQUIRED', 'Invalid token');

  if (isRateLimited(user.id)) {
    log('rate_limited', { userId: user.id, vertical });
    return fail(429, 'RATE_LIMITED', 'Trop de requêtes. Patientez 1 minute.');
  }

  const { data: sub } = await supabase.from('subscriptions').select('tier, current_period_end')
    .eq('user_id', user.id).eq('vertical', vertical).eq('status', 'active').single();
  if (!sub) return fail(403, 'NO_SUBSCRIPTION', 'Aucun abonnement actif.', { vertical });
  if (sub.current_period_end && new Date(sub.current_period_end) < new Date()) return fail(403, 'SUBSCRIPTION_EXPIRED', 'Abonnement expiré.');

  const quota = TIER_QUOTA[sub.tier] ?? 50;
  if (quota !== Infinity) {
    const month = new Date().toISOString().slice(0, 7);
    const { data: uRow } = await supabase.from('usage_quotas').select('count').eq('user_id', user.id).eq('month', month).single();
    if ((uRow?.count || 0) >= quota) return fail(429, 'QUOTA_EXCEEDED', `Quota atteint.`, { used: uRow?.count, limit: quota });
  }

  const startMs = Date.now();
  let cr;
  try { cr = await callClaude(buildSystemPrompt(vertical, sub.tier), sanitized, MAX_TOKENS); }
  catch (e) {
    log('chat_error', { userId: user.id, vertical, error: e.message, durationMs: Date.now() - startMs });
    return fail(e.message === 'CLAUDE_TIMEOUT' ? 504 : 502, 'GENERATION_FAILED', 'Génération échouée. Réessayez.');
  }

  const durationMs = Date.now() - startMs;
  const reply = cr.content?.[0]?.text || '';
  const usage = cr.usage || {};
  const tokensUsed = (usage.input_tokens || 0) + (usage.output_tokens || 0);

  log('chat_success', { userId: user.id, vertical, tier: sub.tier, durationMs, tokensUsed });
  await incrementQuota(supabase, user.id);

  return ok({ reply, tokensUsed, durationMs });
};

/**
 * ai-chat.js — Netlify Function: Conversational AI assistant proxy
 *
 * POST /api/ai-chat
 * Body: { vertical: string, messages: [{role:'user'|'assistant', content:string}] }
 * Headers: Authorization: Bearer <supabase_jwt>
 *
 * Flow:
 *   1. Verify JWT → get user
 *   2. Check active subscription for the requested vertical
 *   3. Check monthly quota (shared with ai-tool.js)
 *   4. Build vertical-specialized system prompt (+ user tier context)
 *   5. Call Anthropic Claude with full conversation history
 *   6. Increment usage quota
 *   7. Return { reply, tokensUsed, durationMs }
 */

const { createClient } = require('@supabase/supabase-js');
const https = require('https');

// ── Config ────────────────────────────────────────────────────────────────────
const SUPABASE_URL         = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const ANTHROPIC_API_KEY    = process.env.ANTHROPIC_API_KEY;
const ANTHROPIC_API_URL    = 'https://api.anthropic.com/v1/messages';
const CLAUDE_MODEL         = 'claude-3-5-haiku-20241022';
const MAX_TOKENS           = 1200;
const MAX_HISTORY_TURNS    = 24;   // keep last 24 turns (~12 exchanges) to manage context
const MAX_MSG_CHARS        = 4000; // cap per message to avoid prompt injection
const TIER_QUOTA           = { bronze: 50, silver: 150, gold: Infinity };

// ── CORS ──────────────────────────────────────────────────────────────────────
const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

const ok  = (body)       => ({ statusCode: 200, headers: CORS, body: JSON.stringify(body) });
const err = (code, msg)  => ({ statusCode: code, headers: CORS, body: JSON.stringify({ error: msg }) });

// ── Bot system prompts ────────────────────────────────────────────────────────
const BOT_SYSTEM = {
  immo: `Tu es ImmoBot, l'assistant IA expert immobilier de The Prompt Studio.
Tu aides les professionnels de l'immobilier (agents, négociateurs, gestionnaires locatifs, promoteurs, investisseurs) dans leur activité quotidienne.

Domaines de compétence :
- Estimation et analyse de marché : prix au m², rendement locatif brut/net, comparables, tension locative
- Rédaction professionnelle : annonces percutantes, emails clients, courriers officiels, mandats
- Réglementation française : loi ALUR, loi Hoguet, encadrement des loyers, DPE/audit énergétique, diagnostics obligatoires, loi Carrez
- Gestion locative : bail, état des lieux, quittances, contentieux locatif, procédure d'expulsion
- Stratégie commerciale : prospection, pitch de prise de mandat, relance vendeurs, traitement des objections
- Fiscalité immobilière : LMNP, régime réel, Pinel, SCI, plus-value immobilière
- Transactions : compromis, conditions suspensives, financement, montage juridique

Tu es direct, structuré et opérationnel. Tu poses des questions de clarification si besoin. Tu adaptes ton niveau de détail à la question. Tu réponds TOUJOURS en français sauf demande explicite de l'utilisateur.`,

  finance: `Tu es FinBot, l'assistant IA expert finance de The Prompt Studio.
Tu aides les professionnels de la finance, de la comptabilité et de l'investissement dans leur travail quotidien.

Domaines de compétence :
- Analyse financière : lecture de bilans et comptes de résultat, SIG, ratios (solvabilité, liquidité, rentabilité, endettement)
- Investissement : analyse d'actifs, construction de portefeuille, valorisation par DCF, multiples de comparables, LBO simplifié
- Finance d'entreprise : business plan, prévisionnel financier, BFR, trésorerie, levée de fonds
- Comptabilité et fiscalité française : TVA, IS, liasses fiscales, amortissements, provisions, optimisation fiscale
- Reporting : KPIs pertinents, tableaux de bord, visualisation de données financières, présentations investisseurs
- Marchés financiers : actions, obligations, ETF, dérivés, private equity, concepts essentiels
- M&A : processus de cession/acquisition, data room, due diligence, valorisation PME

Tu es précis, rigoureux et structuré. Pour toute analyse ou recommandation, tu rappelles que tes réponses sont informationnelles et ne constituent pas un conseil en investissement ou une prestation de service d'investissement réglementée. Tu réponds TOUJOURS en français.`,

  commerce: `Tu es CommerceBot, l'assistant IA expert commerce & e-commerce de The Prompt Studio.
Tu aides les entrepreneurs et professionnels du commerce à développer leur activité.

Domaines de compétence :
- Marketing digital : SEO on-page/off-page, SEA, réseaux sociaux, email marketing, CRO, A/B testing
- E-commerce : optimisation fiches produit, tunnel de conversion, panier moyen, LTV, récupération d'abandon
- Copywriting : accroches, pages de vente, descriptions produit, newsletters, landing pages
- Gestion commerciale : pricing, marges, gestion des stocks, prévisions de ventes, négociation fournisseurs
- Stratégie : positionnement, segmentation, persona, go-to-market, lancement de produit
- Marketplaces : Amazon, Cdiscount, Etsy — optimisation listings, Buy Box, avis clients
- Analytics : lecture des données GA4/Search Console, attribution, mesure de la performance

Tu es créatif, orienté résultats et pragmatique. Tu donnes des conseils actionnables et mesurables. Tu réponds TOUJOURS en français.`,

  legal: `Tu es JuriBot, l'assistant IA expert juridique de The Prompt Studio.
Tu aides les professionnels du droit dans leur pratique quotidienne.

Domaines de compétence :
- Droit des contrats : rédaction, analyse, négociation de clauses, contrats types (prestation, NDA, partenariat)
- Droit des affaires : création de société (SAS, SARL, SA), pactes d'actionnaires, gouvernance, M&A
- Droit immobilier : baux commerciaux et habitation, promesses, actes, copropriété
- Droit du travail : contrats de travail, ruptures conventionnelles, licenciement, contentieux prud'homal
- Procédure civile : assignations, requêtes, conclusions, référé
- Propriété intellectuelle : marques, droits d'auteur, brevets, bases

IMPORTANT : Tu fournis une assistance documentaire, informationnelle et rédactionnelle. Tu n'es pas un avocat et ne peux pas rendre d'avis juridique au sens légal. Tu rappelles systématiquement que toute décision ou action juridique doit être validée par un professionnel du droit habilité (avocat inscrit au barreau). Tu réponds TOUJOURS en français.`,
};

function buildSystemPrompt(vertical, tier) {
  const base = BOT_SYSTEM[vertical] ||
    `Tu es Studio AI, l'assistant IA de The Prompt Studio. Tu aides les professionnels dans leur activité. Tu réponds en français.`;

  const tierLabel = { bronze: 'Bronze', silver: 'Silver', gold: 'Gold' }[tier] || tier;
  const today     = new Date().toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' });

  return `${base}

---
Contexte session : abonnement ${tierLabel} — ${vertical}. Date : ${today}.
Adopte un ton conversationnel et professionnel. Sois concis dans tes réponses courtes, détaillé quand la question le justifie. Si tu génères une liste ou un document structuré, utilise le markdown (titres, listes, gras).`;
}

// ── Claude API call ───────────────────────────────────────────────────────────
function callClaude(systemPrompt, messages, maxTokens) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model:      CLAUDE_MODEL,
      max_tokens: maxTokens,
      system: [{
        type:          'text',
        text:          systemPrompt,
        cache_control: { type: 'ephemeral' }, // cache system prompt, saves ~80% on repeated turns
      }],
      messages,
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

// ── Quota increment (shared logic with ai-tool.js) ────────────────────────────
async function incrementQuota(supabase, userId) {
  const month = new Date().toISOString().slice(0, 7);

  const { error } = await supabase.rpc('increment_usage_quota', {
    p_user_id: userId,
    p_month:   month,
  });

  if (error) {
    // Fallback: non-atomic upsert
    console.warn('[ai-chat] increment_usage_quota RPC unavailable:', error.message);
    const { data: existing } = await supabase
      .from('usage_quotas').select('id, count')
      .eq('user_id', userId).eq('month', month).single();

    if (existing) {
      await supabase.from('usage_quotas').update({ count: existing.count + 1 }).eq('id', existing.id);
    } else {
      await supabase.from('usage_quotas').insert({ user_id: userId, month, count: 1 });
    }
  }
}

// ── Main handler ──────────────────────────────────────────────────────────────
exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: CORS, body: '' };
  if (event.httpMethod !== 'POST')    return err(405, 'Method not allowed');

  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY || !ANTHROPIC_API_KEY) {
    const missing = ['SUPABASE_URL', 'SUPABASE_SERVICE_KEY', 'ANTHROPIC_API_KEY']
      .filter(k => !process.env[k]).join(', ');
    console.error('[ai-chat] Missing env vars:', missing);
    return err(500, 'Server misconfiguration. Contact support.');
  }

  // ── 1. Parse body ──────────────────────────────────────────────────────────
  let vertical, messages;
  try {
    ({ vertical, messages } = JSON.parse(event.body || '{}'));
  } catch {
    return err(400, 'Invalid JSON body');
  }

  if (!vertical || !Array.isArray(messages) || messages.length === 0) {
    return err(400, 'Missing vertical or messages');
  }

  // Sanitize: only valid roles, trim to last N turns, cap message length
  const sanitized = messages
    .filter(m => m && (m.role === 'user' || m.role === 'assistant') && typeof m.content === 'string' && m.content.trim())
    .slice(-MAX_HISTORY_TURNS)
    .map(m => ({ role: m.role, content: m.content.slice(0, MAX_MSG_CHARS) }));

  if (sanitized.length === 0 || sanitized[sanitized.length - 1].role !== 'user') {
    return err(400, 'Last message must be from user');
  }

  // ── 2. Auth ────────────────────────────────────────────────────────────────
  const authHeader = event.headers.authorization || event.headers.Authorization || '';
  const token = authHeader.replace('Bearer ', '').trim();
  if (!token) return err(401, 'Missing authorization token');

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) return err(401, 'Invalid or expired token');

  // ── 3. Check subscription for the requested vertical ──────────────────────
  const { data: sub } = await supabase
    .from('subscriptions')
    .select('tier, current_period_end')
    .eq('user_id', user.id)
    .eq('vertical', vertical)
    .eq('status', 'active')
    .single();

  if (!sub) return err(403, JSON.stringify({ reason: 'no_subscription', vertical }));

  if (sub.current_period_end && new Date(sub.current_period_end) < new Date()) {
    return err(403, JSON.stringify({ reason: 'expired', vertical }));
  }

  // ── 4. Quota check ─────────────────────────────────────────────────────────
  const quota = TIER_QUOTA[sub.tier] ?? 50;

  if (quota !== Infinity) {
    const month = new Date().toISOString().slice(0, 7);
    const { data: usageRow } = await supabase
      .from('usage_quotas').select('count')
      .eq('user_id', user.id).eq('month', month).single();

    const currentCount = usageRow?.count || 0;
    if (currentCount >= quota) {
      return err(429, JSON.stringify({ reason: 'quota_exceeded', used: currentCount, limit: quota }));
    }
  }

  // ── 5. Build prompt & call Claude ─────────────────────────────────────────
  const systemPrompt = buildSystemPrompt(vertical, sub.tier);
  const startMs      = Date.now();

  let claudeResponse;
  try {
    claudeResponse = await callClaude(systemPrompt, sanitized, MAX_TOKENS);
  } catch (e) {
    console.error('[ai-chat] Claude API error:', e.message);
    return err(502, 'AI generation failed. Please try again.');
  }

  const durationMs  = Date.now() - startMs;
  const reply       = claudeResponse.content?.[0]?.text || '';
  const usage       = claudeResponse.usage || {};
  const tokensUsed  = (usage.input_tokens || 0) + (usage.output_tokens || 0);

  // ── 6. Increment quota ─────────────────────────────────────────────────────
  await incrementQuota(supabase, user.id);

  // ── 7. Return ──────────────────────────────────────────────────────────────
  return ok({ reply, tokensUsed, durationMs });
};

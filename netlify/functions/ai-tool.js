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
 *   8. Load user profile + active project → inject context into system prompt
 *   9. Build final prompt (system + context + user message)
 *  10. Call Anthropic Claude API (with prompt caching on system turn + retry on 429/529)
 *  11. Log to tool_usage + atomically increment usage_quotas (structured logging)
 *  12. Return generated text
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
const DEFAULT_MAX_TOKENS   = parseInt(process.env.DEFAULT_MAX_TOKENS, 10) || 1800;
const TIER_QUOTA           = { starter: 50, pro: 150, gold: Infinity, team: Infinity };
const TIER_ORDER           = { starter: 1, pro: 2, gold: 3, team: 4 };

// Per-vertical token limits (some verticals need more space than others)
const VERTICAL_MAX_TOKENS = {
  legal:     2500,  // Legal documents need to be thorough
  finance:   2200,  // Financial analyses need detail
  rh:        2000,  // HR policies, contracts
  education: 2000,  // Course plans, exercises
  freelance: 1800,  // Proposals, reports
  immo:      1500,  // Annonces, descriptions
  commerce:  1500,  // Product descriptions, emails
  marketing: 1800,  // Landing pages, strategies
  sante:     1800,  // Medical reports, programs
  restauration: 1200, // Menus, recipes
};

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
  // Extract universal enrichment fields (handled separately in system prompt)
  const langue        = inputs.langue || '';
  const longueurSortie = inputs.longueur_sortie || '';
  const infosComp     = inputs.infos_comp || '';

  // Build instructions from universal fields
  const universalInstructions = [];
  if (langue && langue !== 'Français') {
    universalInstructions.push(`IMPORTANT: Réponds entièrement en ${langue}.`);
  }
  if (longueurSortie) {
    const lengthMap = {
      'Court (concis)':      'Sois concis et va droit au but. Format court.',
      'Moyen (standard)':    'Longueur standard, suffisamment détaillé.',
      'Long (détaillé)':     'Sois très détaillé et complet. Format long.',
    };
    if (lengthMap[longueurSortie]) universalInstructions.push(lengthMap[longueurSortie]);
  }
  if (infosComp) {
    universalInstructions.push(`Instructions supplémentaires de l'utilisateur: ${infosComp}`);
  }

  const universalBlock = universalInstructions.length
    ? `\n<instructions_supplementaires>\n${universalInstructions.join('\n')}\n</instructions_supplementaires>`
    : '';

  // Remove universal fields from the main inputs to avoid duplication
  const coreInputs = { ...inputs };
  delete coreInputs.langue;
  delete coreInputs.longueur_sortie;
  delete coreInputs.infos_comp;

  if (tool.prompt_template) {
    const filled = tool.prompt_template.replace(/\{\{(\w+)\}\}/g, (_, key) =>
      coreInputs[key] !== undefined ? String(coreInputs[key]) : `[${key} non fourni]`
    );
    return filled + universalBlock;
  }

  // Build structured user message with field labels from schema
  const fieldLabels = {};
  if (tool.input_schema?.fields) {
    tool.input_schema.fields.forEach(f => { if (f.name && f.label) fieldLabels[f.name] = f.label; });
  }

  const fields = Object.entries(coreInputs)
    .filter(([, v]) => v !== undefined && v !== null && String(v).trim() !== '')
    .map(([k, v]) => {
      const label = fieldLabels[k] || k;
      return `  <${k} label="${label}">${String(v).trim()}</${k}>`;
    })
    .join('\n');

  const toolName = tool.name || tool.slug;
  return `Génère le contenu pour l'outil "${toolName}" avec les paramètres suivants :\n\n<parametres>\n${fields}\n</parametres>${universalBlock}`;
}

// ── Helper: build user context block from profile + project ──────────────────
function buildUserContext(profile, project) {
  const parts = [];

  // ── User profile context ──
  if (profile) {
    const pLines = [];
    if (profile.first_name || profile.last_name) {
      pLines.push(`Nom: ${[profile.first_name, profile.last_name].filter(Boolean).join(' ')}`);
    }
    if (profile.job_title)     pLines.push(`Poste: ${profile.job_title}`);
    if (profile.company_name)  pLines.push(`Entreprise: ${profile.company_name}`);
    if (profile.billing_city)  pLines.push(`Ville: ${profile.billing_city}`);
    if (profile.billing_postal_code) pLines.push(`Code postal: ${profile.billing_postal_code}`);
    if (profile.phone)         pLines.push(`Téléphone: ${profile.phone}`);
    if (profile.email)         pLines.push(`Email: ${profile.email}`);

    if (pLines.length) {
      parts.push(`<profil_utilisateur>\n${pLines.join('\n')}\n</profil_utilisateur>`);
    }
  }

  // ── Active project context ──
  if (project) {
    const projLines = [];
    if (project.name) projLines.push(`Nom du projet: ${project.name}`);
    if (project.vertical) projLines.push(`Secteur: ${project.vertical}`);
    if (project.notes) projLines.push(`Notes: ${project.notes}`);

    // Flatten project.data JSONB into readable key-value pairs
    if (project.data && typeof project.data === 'object') {
      Object.entries(project.data).forEach(([key, value]) => {
        if (value !== null && value !== undefined && String(value).trim()) {
          // Convert snake_case key to readable label
          const label = key.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
          projLines.push(`${label}: ${String(value).trim()}`);
        }
      });
    }

    if (projLines.length) {
      parts.push(`<projet_actif>\n${projLines.join('\n')}\n</projet_actif>`);
    }
  }

  if (!parts.length) return '';

  const instructions = [
    '\n\n<contexte_utilisateur>',
    'IMPORTANT : Utilise activement ces informations pour personnaliser le contenu généré.',
    'Par exemple : le nom de l\'entreprise dans les en-têtes/signatures, la ville pour les références locales,',
    'le poste pour adapter le registre, les données du projet pour pré-remplir les informations métier.',
    'N\'invente PAS d\'informations — utilise uniquement ce qui est fourni.',
    '',
    ...parts,
    '</contexte_utilisateur>',
  ];
  return instructions.join('\n');
}

// ── Helper: resolve system prompt ─────────────────────────────────────────────
function buildSystemPrompt(tool, userContext = '') {
  const base = tool.system_prompt || getDefaultSystemPrompt(tool);
  return base + userContext;
}

function getDefaultSystemPrompt(tool) {
  const toolLabel = tool.name || tool.slug;

  // ── Vertical-specific expert profiles ──
  const verticalProfiles = {
    immo: {
      domain: "de l'immobilier",
      role: "Tu es un expert en rédaction immobilière avec 15 ans d'expérience. Tu maîtrises le copywriting d'annonces, les descriptions de biens de prestige, la prospection vendeur, et l'analyse de marché.",
      expertise: "Vocabulaire immobilier professionnel (DPE, loi Carrez, mandat exclusif, compromis, etc.). Tu sais créer l'émotion et la projection chez l'acheteur/locataire tout en restant factuel sur les caractéristiques.",
      quality: "Chaque annonce doit donner envie de visiter. Chaque email de prospection doit décrocher un rendez-vous. Utilise des verbes d'action, des détails sensoriels, et structure le contenu pour faciliter la lecture rapide.",
    },
    commerce: {
      domain: 'du commerce et e-commerce',
      role: "Tu es un expert en copywriting e-commerce et marketing de conversion. Tu maîtrises les fiches produit persuasives, le SEO on-page, les séquences email, et les stratégies de vente en ligne.",
      expertise: "Psychologie d'achat, techniques AIDA, copywriting de conversion, SEO sémantique, structure de fiche produit optimisée (titre, bullet points, description, CTA). Tu connais les bonnes pratiques Amazon, Shopify, et marketplaces.",
      quality: "Chaque fiche produit doit convertir. Utilise des bénéfices (pas juste des caractéristiques), crée de l'urgence quand pertinent, et optimise chaque mot pour le SEO sans sacrifier la lisibilité.",
    },
    legal: {
      domain: 'du droit et du juridique',
      role: "Tu es un rédacteur juridique senior. Tu maîtrises la rédaction de contrats, mises en demeure, conclusions, analyses juridiques, et documents de conformité.",
      expertise: "Droit français (Code civil, Code du travail, Code de commerce, RGPD). Tu utilises le vocabulaire juridique précis, les formulations consacrées, et les références normatives appropriées.",
      quality: "Chaque document doit être juridiquement rigoureux et exploitable en l'état par un professionnel du droit. Structure claire avec articles numérotés quand approprié. Précision des termes et exhaustivité des clauses.",
      disclaimer: "\n\nIMPORTANT : Termine toujours par : \"⚖️ Ce document est généré à titre indicatif et doit être validé par un professionnel du droit avant utilisation.\"",
    },
    finance: {
      domain: "de la finance et de la comptabilité",
      role: "Tu es un expert-comptable et analyste financier. Tu maîtrises les bilans, comptes de résultat, prévisionnels, optimisation fiscale, reporting, et conseil de gestion.",
      expertise: "Normes comptables françaises (PCG), fiscalité (IS, IR, TVA, CFE), ratios financiers (CAF, BFR, trésorerie nette, EBE, SIG). Tu sais vulgariser les chiffres pour les dirigeants non-financiers.",
      quality: "Chaque analyse doit être chiffrée et actionnable. Présente les KPIs clés, les tendances, les points d'alerte, et les recommandations concrètes. Utilise des tableaux quand c'est plus clair.",
      disclaimer: "\n\nIMPORTANT : Termine toujours par : \"📊 Ce contenu est informatif et ne constitue pas un conseil en investissement ou fiscal personnalisé.\"",
    },
    marketing: {
      domain: 'du marketing et de la communication',
      role: "Tu es un directeur marketing senior et expert en stratégie de contenu. Tu maîtrises le branding, le copywriting, les campagnes ads, le content marketing, les réseaux sociaux, et le growth hacking.",
      expertise: "Frameworks marketing (AIDA, PAS, StoryBrand, AARRR), psychologie de la persuasion, copywriting émotionnel et data-driven, stratégies multi-canal, personas, et funnels de conversion.",
      quality: "Chaque contenu doit avoir un hook percutant, un corps engageant, et un CTA clair. Adapte le style à la plateforme (LinkedIn ≠ Instagram ≠ email). Propose des variantes A/B quand pertinent.",
    },
    rh: {
      domain: 'des ressources humaines et du recrutement',
      role: "Tu es un DRH et expert en recrutement avec une forte culture RH française. Tu maîtrises la rédaction d'offres d'emploi, les process de recrutement, la gestion des talents, et le droit social.",
      expertise: "Code du travail français, conventions collectives, marque employeur, techniques de sourcing, onboarding, entretiens annuels, GPEC. Tu connais les bonnes pratiques inclusives et non-discriminatoires.",
      quality: "Chaque offre d'emploi doit attirer les bons candidats et refléter la culture de l'entreprise. Les documents RH doivent être conformes au droit du travail français. Utilise un langage inclusif.",
    },
    sante: {
      domain: 'de la santé et du bien-être',
      role: "Tu es un expert en communication santé et rédaction médicale. Tu maîtrises la communication patient, les contenus de vulgarisation, les programmes de soins, et la conformité déontologique.",
      expertise: "Terminologie médicale, éducation thérapeutique, communication empathique, normes déontologiques des professions de santé, RGPD santé, et marketing des professionnels de santé.",
      quality: "Chaque contenu doit être scientifiquement exact, rassurant, et compréhensible par le patient. Utilise un ton empathique et professionnel. Respecte la déontologie médicale.",
      disclaimer: "\n\nIMPORTANT : Termine toujours par : \"🏥 Ce contenu est informatif et ne remplace pas un avis médical professionnel.\"",
    },
    education: {
      domain: "de l'éducation et de la formation professionnelle",
      role: "Tu es un ingénieur pédagogique senior et expert en conception de formations. Tu maîtrises la création de programmes, supports de formation, évaluations, et e-learning.",
      expertise: "Taxonomie de Bloom, approche par compétences, pédagogie active, ingénierie de formation (ADDIE), Qualiopi, CPF, blended learning, gamification pédagogique.",
      quality: "Chaque contenu pédagogique doit avoir des objectifs clairs, une progression logique, et des activités variées. Définis les compétences visées, les modalités d'évaluation, et les prérequis.",
    },
    restauration: {
      domain: "de la restauration et de l'hôtellerie",
      role: "Tu es un expert en communication pour la restauration et l'hôtellerie. Tu maîtrises la rédaction de menus, la gestion d'image, les réseaux sociaux food, et le marketing restauration.",
      expertise: "Vocabulaire gastronomique, techniques culinaires, réglementations HACCP et allergènes (14 allergènes UE), tendances food, storytelling culinaire, et communication de crise (avis négatifs).",
      quality: "Chaque description de plat doit être sensorielle et appétissante. Les contenus marketing doivent refléter l'identité du restaurant. Les documents réglementaires (allergènes, HACCP) doivent être conformes et exhaustifs.",
    },
    freelance: {
      domain: 'du consulting et du freelancing',
      role: "Tu es un consultant senior et expert en développement d'activité indépendante. Tu maîtrises la prospection, les propositions commerciales, le personal branding, et la gestion administrative freelance.",
      expertise: "Statuts juridiques (AE, EURL, SASU), portage salarial, pricing, négociation, propositions commerciales, CGV, facturation, et stratégie de positionnement expert.",
      quality: "Chaque proposition doit être convaincante et refléter l'expertise du freelance. Les documents administratifs (CGV, devis) doivent être juridiquement solides. Le personal branding doit être authentique et différenciant.",
    },
  };

  const vp = verticalProfiles[tool.vertical] || {
    domain: '',
    role: "Tu es un assistant IA expert en rédaction professionnelle.",
    expertise: "Rédaction structurée, claire et actionnable.",
    quality: "Chaque contenu doit être professionnel et directement utilisable.",
  };

  // ── Assemble the system prompt ──
  const parts = [
    // 1. Role identity
    vp.role,

    // 2. Current task
    `\nTa tâche actuelle : "${toolLabel}".`,

    // 3. Quality guidelines
    `\n<guidelines_qualite>`,
    `- ${vp.quality}`,
    `- Utilise un vocabulaire professionnel et spécialisé du domaine ${vp.domain || 'concerné'}.`,
    `- Sois direct : pas d'introduction ("Voici…", "Bien sûr…"), pas de méta-commentaire. Commence directement par le contenu demandé.`,
    `- Structure le contenu avec des titres, sections, ou listes quand c'est pertinent pour la lisibilité.`,
    `- Adapte le niveau de détail au type de contenu : concis pour un email, détaillé pour une analyse.`,
    `- Si des données chiffrées sont disponibles dans le contexte, intègre-les naturellement dans le contenu.`,
    `- Si un profil utilisateur ou un projet est fourni en contexte, utilise activement ces informations : nom de l'entreprise dans les en-têtes, ville dans les références géographiques, poste pour adapter le niveau de langage, etc.`,
    `</guidelines_qualite>`,

    // 4. Domain expertise
    `\n<expertise_domaine>`,
    vp.expertise,
    `</expertise_domaine>`,

    // 5. Language
    `\nRéponds en français sauf si l'utilisateur demande une autre langue dans ses instructions.`,
  ];

  // 6. Disclaimer if needed (legal, finance, santé)
  if (vp.disclaimer) parts.push(vp.disclaimer);

  return parts.join('\n');
}

// ── Helper: call Claude API with retry on 429/529 ────────────────────────────
function callClaude(systemPrompt, userMessage, maxTokens, retries = 2) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model:      CLAUDE_MODEL,
      max_tokens: maxTokens,
      // Use structured system format to enable prompt caching
      // The system prompt (role + guidelines) is cacheable across calls to the same tool
      system: [
        {
          type: 'text',
          text: systemPrompt,
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
        'Content-Length':    Buffer.byteLength(payload),
      },
      timeout: 30_000, // 30s timeout (allows for longer, higher-quality outputs)
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

  if (toolError || !tool) {
    log('tool_not_found', { toolSlug, error: toolError?.message || 'no rows' });
    return fail(404, 'TOOL_NOT_FOUND', `Tool not found: ${toolSlug}`);
  }
  if (!tool.is_active)    return fail(403, 'TOOL_UNAVAILABLE', 'Tool is currently unavailable');

  // ── 5. Validate & sanitize inputs against schema ───────────────────────────
  inputs = sanitizeInputs(inputs, tool.input_schema);

  // ── 6. Load subscription — filtered by tool vertical ──────────────────────
  const { data: sub } = await supabase
    .from('subscriptions')
    .select('tier, vertical, current_period_end, trial_ends_at')
    .eq('user_id', user.id)
    .eq('vertical', tool.vertical)
    .in('status', ['active', 'on_trial'])
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

  // ── 8. Load user context (profile + project) ─────────────────────────────
  let profile = null;
  let project = null;

  // Load profile (non-blocking — don't fail generation if profile fetch fails)
  try {
    const { data: profileRow } = await supabase
      .from('profiles')
      .select('first_name, last_name, job_title, company_name, phone, email, billing_city, billing_postal_code')
      .eq('id', user.id)
      .single();
    profile = profileRow;
  } catch (_) { /* best-effort */ }

  // Load active project if provided
  if (projectId && typeof projectId === 'string' && projectId.length > 10) {
    try {
      const { data: projRow } = await supabase
        .from('projects')
        .select('name, vertical, data, notes')
        .eq('id', projectId)
        .eq('user_id', user.id)
        .single();
      project = projRow;
    } catch (_) { /* best-effort */ }
  }

  const userContext = buildUserContext(profile, project);

  // ── 9. Build prompt ────────────────────────────────────────────────────────
  const systemPrompt = buildSystemPrompt(tool, userContext);
  const userMessage  = buildUserMessage(tool, inputs);
  const maxTokens    = tool.max_output_tokens || VERTICAL_MAX_TOKENS[tool.vertical] || DEFAULT_MAX_TOKENS;

  // ── 10. Call Claude with retry ─────────────────────────────────────────────
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

  // ── 11. Log usage (structured) ──────────────────────────────────────────────
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
    // Increment tool-level usage counter for dynamic "Populaire" badges
    supabase.rpc('increment_tool_usage', { tool_slug: toolSlug }).catch(() => {}),
  ]);

  // ── 12. Return ──────────────────────────────────────────────────────────────
  return ok({
    output:     outputText,
    tokensUsed,
    tokensSaved,
    durationMs,
    tool:       { slug: toolSlug, name: tool.name },
  });
};

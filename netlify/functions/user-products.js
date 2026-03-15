/**
 * GET /api/user-products
 * ───────────────────────
 * Returns the list of products the authenticated user has access to.
 * Called by the dashboard to show purchased toolkits.
 *
 * Auth: Bearer token (Supabase JWT) in Authorization header
 */

const { createClient } = require('@supabase/supabase-js');

// Product metadata for frontend display
const PRODUCT_META = {
  immo: {
    name: 'ImmoPrompts Pro',
    icon: '🏠',
    description: '50 prompts + workflows IA pour agents immobiliers',
    price: '€47',
    page: '/promptcraft-immo.html',
    pdf: 'ImmoPrompts_Pack_AgentImmo_Pro.pdf',
    features: [
      'Diagnostic acquisition IA',
      '50 prompts métier immobilier',
      'Workflows automatisation CRM',
      'Formation vidéo incluse',
      'Plan 30 jours d\'implémentation',
    ],
  },
  commerce: {
    name: 'Commerce Pro',
    icon: '🛒',
    description: 'Fiches produits, email marketing, chatbots e-commerce',
    price: '€57',
    page: '/promptcraft-commerce.html',
    pdf: 'PromptCraft_Commerce_Pro.pdf',
    features: [
      'Générateur fiches produits IA',
      'Séquences email automatisées',
      'Chatbot service client',
      'Stratégie réseaux sociaux',
      '40+ prompts commerce',
    ],
  },
  legal: {
    name: 'Juridique Pro',
    icon: '⚖️',
    description: 'Rédaction juridique, recherches, notes de synthèse',
    price: '€97',
    page: '/promptcraft-legal.html',
    pdf: 'PromptCraft_Legal_Pro.pdf',
    features: [
      'Rédaction contrats assistée',
      'Notes juridiques en 5 min',
      'Recherche jurisprudence IA',
      'Analyse de documents',
      'Modèles éditables inclus',
    ],
  },
  pro: {
    name: 'Pro Abonnement',
    icon: '⭐',
    description: 'Accès à tous les toolkits + nouveautés en avant-première',
    price: '€XX/mois',
    page: '/index.html',
    pdf: null,
    features: [
      'Tous les toolkits inclus',
      'Mises à jour prioritaires',
      'Support email dédié',
      'Accès Discord membres',
      'Nouveaux toolkits en avant-première',
    ],
  },
};

exports.handler = async (event) => {
  // CORS headers
  const headers = {
    'Access-Control-Allow-Origin': process.env.SITE_URL || 'https://theprompt.studio',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }
  if (event.httpMethod !== 'GET') {
    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method Not Allowed' }) };
  }

  // ── Authenticate user from JWT ────────────────────────────────────────
  const authHeader = event.headers.authorization || event.headers.Authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: 'Unauthorized' }) };
  }

  const token = authHeader.replace('Bearer ', '');

  // Create client with service key for DB access, but verify JWT first
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

  // Verify the JWT and get the user
  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: 'Invalid token' }) };
  }

  // ── Fetch user's products ─────────────────────────────────────────────
  const { data: products, error: dbError } = await supabase
    .from('user_products')
    .select('product_slug, status, purchased_at, expires_at, lemon_order_id, lemon_subscription_id')
    .eq('user_id', user.id)
    .in('status', ['active']); // Only active (not cancelled/refunded)

  if (dbError) {
    console.error('DB error:', dbError);
    return { statusCode: 500, headers, body: JSON.stringify({ error: 'Database error' }) };
  }

  // Check subscription expiry
  const now = new Date();
  const activeProducts = (products || []).filter(p => {
    if (!p.expires_at) return true; // Lifetime access
    return new Date(p.expires_at) > now;
  });

  // Build enriched product list
  const enriched = activeProducts.map(p => ({
    ...p,
    ...PRODUCT_META[p.product_slug],
    has_access: true,
  }));

  // Pro subscribers get access to all products
  const hasPro = enriched.some(p => p.product_slug === 'pro');
  if (hasPro) {
    const allSlugs = Object.keys(PRODUCT_META).filter(s => s !== 'pro');
    const ownedSlugs = new Set(enriched.map(p => p.product_slug));
    allSlugs.forEach(slug => {
      if (!ownedSlugs.has(slug)) {
        enriched.push({
          product_slug: slug,
          status: 'active',
          via_pro: true,
          ...PRODUCT_META[slug],
          has_access: true,
        });
      }
    });
  }

  return {
    statusCode: 200,
    headers,
    body: JSON.stringify({
      user: {
        id: user.id,
        email: user.email,
        name: user.user_metadata?.full_name || '',
      },
      products: enriched,
      has_pro: hasPro,
    }),
  };
};

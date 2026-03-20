/**
 * GET /api/user-products
 * ───────────────────────
 * Returns the list of active subscriptions for the authenticated user.
 * Called by the dashboard to show accessible verticals and tier info.
 *
 * Auth: Bearer token (Supabase JWT) in Authorization header
 */

const { createClient } = require('@supabase/supabase-js');

function log(event, data = {}) {
  console.log(JSON.stringify({ fn: 'user-products', event, ts: new Date().toISOString(), ...data }));
}

// Vertical metadata for frontend display
const VERTICAL_META = {
  immo: {
    name: 'Outils IA Immobilier',
    icon: '🏠',
    description: 'Outils IA spécialisés pour professionnels de l\'immobilier',
    page: '/promptcraft-immo.html',
  },
  commerce: {
    name: 'Outils IA Commerce',
    icon: '🛒',
    description: 'Outils IA pour e-commerce et retail',
    page: '/promptcraft-commerce.html',
  },
  legal: {
    name: 'Outils IA Juridique',
    icon: '⚖️',
    description: 'Outils IA pour professionnels du droit',
    page: '/promptcraft-legal.html',
  },
};

// Subscription tier labels
const TIER_LABELS = {
  starter: 'Starter',
  pro:     'Pro',
  gold:    'Gold',
  team:    'Team',
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

  // ── Fetch user's subscriptions ────────────────────────────────────────
  const { data: subscriptions, error: dbError } = await supabase
    .from('subscriptions')
    .select('vertical, tier, status, current_period_start, current_period_end, lemon_subscription_id')
    .eq('user_id', user.id)
    .in('status', ['active', 'on_trial']);

  if (dbError) {
    console.error('DB error:', dbError);
    return { statusCode: 500, headers, body: JSON.stringify({ error: 'Database error' }) };
  }

  // Check subscription expiry
  const now = new Date();
  const activeSubs = (subscriptions || []).filter(s => {
    if (!s.current_period_end) return true;
    return new Date(s.current_period_end) > now;
  });

  // Build enriched subscription list with vertical metadata
  const enriched = activeSubs.map(s => ({
    ...s,
    ...VERTICAL_META[s.vertical],
    tier_label: TIER_LABELS[s.tier] || s.tier,
    has_access: true,
  }));

  // Gold/Team subscribers get access to all verticals
  const hasFullAccess = enriched.some(s => s.tier === 'gold' || s.tier === 'team');
  if (hasFullAccess) {
    const allVerticals = Object.keys(VERTICAL_META);
    const ownedVerticals = new Set(enriched.map(s => s.vertical));
    allVerticals.forEach(vertical => {
      if (!ownedVerticals.has(vertical)) {
        enriched.push({
          vertical,
          status: 'active',
          via_full_access: true,
          ...VERTICAL_META[vertical],
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
      subscriptions: enriched,
      has_full_access: hasFullAccess,
    }),
  };
};

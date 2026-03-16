/**
 * ps-auth.js — Shared auth + subscription utilities
 * Include AFTER the Supabase CDN script on every protected page
 *
 * Exposes:
 *   PS.supabase     — Supabase client
 *   PS.session      — current session (null if not logged in)
 *   PS.sub          — current subscription object
 *   PS.canUseTool(slug) → {allowed, reason, tier}
 *   PS.requireAuth()    — redirect to /login if not authenticated
 */
(function(global) {
  const SUPABASE_URL  = 'https://jbrloxoqtfeqvghkzupj.supabase.co';
  const SUPABASE_ANON = 'sb_publishable_47qhKUm9nD9uQ57bTa25Dg_wWdUF4wg';

  const TIER_ORDER = { bronze: 1, silver: 2, gold: 3 };

  const PS = {
    supabase: null,
    session: null,
    sub: null,

    // ── Init: call on every protected page ──────────────────────────────
    async init() {
      PS.supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON);

      // Handle PKCE code exchange (magic link callback)
      const params = new URLSearchParams(window.location.search);
      const code = params.get('code');
      if (code) {
        await PS.supabase.auth.exchangeCodeForSession(window.location.href);
        window.history.replaceState({}, '', window.location.pathname);
      }

      const { data: { session } } = await PS.supabase.auth.getSession();
      PS.session = session;

      if (session) {
        // Load subscription
        const { data } = await PS.supabase
          .from('subscriptions')
          .select('*')
          .eq('user_id', session.user.id)
          .eq('status', 'active')
          .single();
        PS.sub = data || null;
      }

      return PS.session;
    },

    // ── Redirect to login if not authenticated ───────────────────────────
    async requireAuth(redirectBack) {
      const session = await PS.init();
      if (!session) {
        const back = redirectBack || window.location.pathname;
        window.location.href = `/login?next=${encodeURIComponent(back)}`;
        return false;
      }
      return true;
    },

    // ── Check if current user can use a tool ─────────────────────────────
    canUseTool(toolSlug, toolMinTier, toolVertical) {
      if (!PS.session) return { allowed: false, reason: 'not_logged_in' };
      if (!PS.sub)     return { allowed: false, reason: 'no_subscription' };

      const now = new Date();
      if (PS.sub.current_period_end && new Date(PS.sub.current_period_end) < now) {
        return { allowed: false, reason: 'expired' };
      }

      // Tier check
      const userTierOrder = TIER_ORDER[PS.sub.tier] || 0;
      const toolTierOrder = TIER_ORDER[toolMinTier] || 1;
      if (userTierOrder < toolTierOrder) {
        return { allowed: false, reason: 'upgrade_required', required: toolMinTier, yours: PS.sub.tier };
      }

      // Vertical check (Bronze = 1 vertical)
      if (PS.sub.tier === 'bronze' && PS.sub.vertical && toolVertical && PS.sub.vertical !== toolVertical) {
        return { allowed: false, reason: 'wrong_vertical', yours: PS.sub.vertical };
      }

      return { allowed: true, tier: PS.sub.tier };
    },

    // ── Get monthly usage count ──────────────────────────────────────────
    async getMonthlyUsage() {
      if (!PS.session) return 0;
      const month = new Date().toISOString().slice(0, 7);
      const { data } = await PS.supabase
        .from('usage_quotas')
        .select('count')
        .eq('user_id', PS.session.user.id)
        .eq('month', month)
        .single();
      return data?.count || 0;
    },

    // ── Logout ───────────────────────────────────────────────────────────
    async logout() {
      await PS.supabase.auth.signOut();
      window.location.href = '/';
    },

    // ── Tier display helpers ─────────────────────────────────────────────
    tierLabel: { bronze: '🥉 Bronze', silver: '🥈 Silver', gold: '🥇 Gold' },
    tierColor: { bronze: '#cd7f32',   silver: '#a8a9ad',   gold: '#c9a84c' },
  };

  global.PS = PS;
})(window);

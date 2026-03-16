/**
 * ps-auth.js — The Prompt Studio shared auth utility (v3)
 *
 * Architecture: 1 subscription per vertical, user can have multiple
 * Colors: immo=blue, commerce=orange, legal=red, finance=green
 */

const SUPABASE_URL  = 'https://jbrloxoqtfeqvghkzupj.supabase.co';
const SUPABASE_ANON = 'sb_publishable_47qhKUm9nD9uQ57bTa25Dg_wWdUF4wg';

const TIER_ORDER = { bronze: 1, silver: 2, gold: 3 };

const VERTICALS = {
  immo:     { label: 'Immobilier', icon: '🏠', color: '#3b82f6', bg: 'rgba(59,130,246,.12)',  border: 'rgba(59,130,246,.3)'  },
  commerce: { label: 'Commerce',   icon: '🛒', color: '#f97316', bg: 'rgba(249,115,22,.12)',  border: 'rgba(249,115,22,.3)'  },
  legal:    { label: 'Juridique',  icon: '⚖️', color: '#ef4444', bg: 'rgba(239,68,68,.12)',   border: 'rgba(239,68,68,.3)'   },
  finance:  { label: 'Finance',    icon: '📈', color: '#22c55e', bg: 'rgba(34,197,94,.12)',   border: 'rgba(34,197,94,.3)'   },
};

const PS = (() => {
  let _sb       = null;
  let _session  = null;
  let _subs     = [];
  let _subsMap  = {};
  let _ready    = false;

  function getClient() {
    if (!_sb) {
      _sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON, {
        auth: { flowType: 'pkce', autoRefreshToken: true, persistSession: true },
      });
    }
    return _sb;
  }

  async function init() {
    if (_ready) return { session: _session, subs: _subs };
    const sb = getClient();

    // PKCE code exchange
    const params = new URLSearchParams(window.location.search);
    const code   = params.get('code');
    if (code) {
      try { await sb.auth.exchangeCodeForSession(window.location.href); } catch(e) {}
      const clean = window.location.pathname + (params.get('welcome') ? '?welcome=' + params.get('welcome') : '');
      window.history.replaceState({}, '', clean);
    }

    const { data: { session } } = await sb.auth.getSession();
    _session = session;

    if (session) {
      const { data } = await sb
        .from('subscriptions')
        .select('*')
        .eq('user_id', session.user.id)
        .eq('status', 'active');
      _subs = (data || []).filter(s => !s.current_period_end || new Date(s.current_period_end) > new Date());
      _subsMap = {};
      _subs.forEach(s => { _subsMap[s.vertical] = s; });
    }

    _ready = true;
    return { session: _session, subs: _subs };
  }

  async function requireAuth(returnPath) {
    const { session } = await init();
    if (!session) {
      window.location.href = '/login.html?redirect=' + encodeURIComponent(returnPath || window.location.pathname);
      return false;
    }
    return true;
  }

  function subForVertical(v)       { return _subsMap[v] || null; }
  function hasAnySubscription()    { return _subs.length > 0; }
  function subscribedVerticals()   { return _subs.map(s => s.vertical); }

  function canUseTool(toolSlug, toolMinTier, toolVertical) {
    if (!_session) return { allowed: false, reason: 'not_logged_in' };
    const sub = _subsMap[toolVertical];
    if (!sub)  return { allowed: false, reason: 'no_subscription', vertical: toolVertical, label: VERTICALS[toolVertical]?.label };
    const u = TIER_ORDER[sub.tier]     || 0;
    const t = TIER_ORDER[toolMinTier]  || 1;
    if (u < t) return { allowed: false, reason: 'upgrade_required', required: toolMinTier, yours: sub.tier, vertical: toolVertical };
    return { allowed: true, tier: sub.tier, vertical: toolVertical };
  }

  async function getMonthlyUsage() {
    if (!_session) return 0;
    const month = new Date().toISOString().slice(0, 7);
    const { data } = await getClient().from('usage_quotas').select('count').eq('user_id', _session.user.id).eq('month', month);
    return (data || []).reduce((s, r) => s + (r.count || 0), 0);
  }

  function getQuota(vertical) {
    const sub = _subsMap[vertical];
    if (!sub) return 0;
    return { bronze: 50, silver: 150, gold: Infinity }[sub.tier] ?? 50;
  }

  async function logout() {
    await getClient().auth.signOut();
    window.location.href = '/index.html';
  }

  return {
    get supabase()  { return getClient(); },
    get session()   { return _session; },
    get subs()      { return _subs; },
    get subsMap()   { return _subsMap; },
    init, requireAuth, subForVertical,
    hasAnySubscription, subscribedVerticals,
    canUseTool, getMonthlyUsage, getQuota, logout,
    VERTICALS, TIER_ORDER,
  };
})();

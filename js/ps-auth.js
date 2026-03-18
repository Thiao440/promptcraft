/**
 * ps-auth.js — The Prompt Studio shared auth utility (v6 — single session)
 *
 * Auth: email + password via Supabase Auth.
 * Profile: loaded on init(), checked for completeness.
 * Session: single active session per user (prevents account sharing).
 * Subscriptions: 1 per vertical, user can have multiple.
 *
 * Events:
 *   window dispatches 'ps:ready' when init() completes (used by chat widget).
 */

const SUPABASE_URL  = 'https://jbrloxoqtfeqvghkzupj.supabase.co';
const SUPABASE_ANON = 'sb_publishable_47qhKUm9nD9uQ57bTa25Dg_wWdUF4wg';

const TIER_ORDER = { bronze: 1, silver: 2, gold: 3 };

const VERTICALS = {
  immo:         { label: 'Immobilier',            icon: '🏠', color: '#f59e0b', bg: 'rgba(245,158,11,.12)',  border: 'rgba(245,158,11,.3)'  },
  commerce:     { label: 'E-Commerce & Retail',   icon: '🛒', color: '#3b82f6', bg: 'rgba(59,130,246,.12)',  border: 'rgba(59,130,246,.3)'  },
  legal:        { label: 'Juridique',             icon: '⚖️', color: '#8b5cf6', bg: 'rgba(139,92,246,.12)',  border: 'rgba(139,92,246,.3)'  },
  finance:      { label: 'Finance & Comptabilité',icon: '💰', color: '#10b981', bg: 'rgba(16,185,129,.12)', border: 'rgba(16,185,129,.3)' },
  marketing:    { label: 'Marketing & Com.',      icon: '📣', color: '#ec4899', bg: 'rgba(236,72,153,.12)', border: 'rgba(236,72,153,.3)' },
  rh:           { label: 'Ressources Humaines',   icon: '👥', color: '#f97316', bg: 'rgba(249,115,22,.12)', border: 'rgba(249,115,22,.3)' },
  sante:        { label: 'Santé & Bien-être',     icon: '🏥', color: '#06b6d4', bg: 'rgba(6,182,212,.12)',  border: 'rgba(6,182,212,.3)'  },
  education:    { label: 'Éducation & Formation', icon: '🎓', color: '#6366f1', bg: 'rgba(99,102,241,.12)', border: 'rgba(99,102,241,.3)' },
  restauration: { label: 'Restauration',          icon: '🍽️', color: '#ef4444', bg: 'rgba(239,68,68,.12)',  border: 'rgba(239,68,68,.3)'  },
  freelance:    { label: 'Freelances & Consultants',icon:'💼', color: '#84cc16', bg: 'rgba(132,204,22,.12)', border: 'rgba(132,204,22,.3)' },
};

const PS = (() => {
  let _sb       = null;
  let _session  = null;
  let _profile  = null;
  let _subs     = [];
  let _subsMap  = {};
  let _ready    = false;
  let _sessionId = null; // unique per browser tab/login

  function getClient() {
    if (!_sb) {
      _sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON, {
        auth: { autoRefreshToken: true, persistSession: true },
      });
    }
    return _sb;
  }

  // Generate a unique session ID for this browser tab
  function getSessionId() {
    if (!_sessionId) {
      _sessionId = sessionStorage.getItem('ps_session_id');
      if (!_sessionId) {
        _sessionId = crypto.randomUUID ? crypto.randomUUID() : (Date.now().toString(36) + Math.random().toString(36).slice(2));
        sessionStorage.setItem('ps_session_id', _sessionId);
      }
    }
    return _sessionId;
  }

  async function init() {
    if (_ready) return { session: _session, profile: _profile, subs: _subs };
    const sb = getClient();

    const { data: { session } } = await sb.auth.getSession();
    _session = session;

    if (session) {
      // Load profile + subscriptions in parallel
      const [profileRes, subsRes] = await Promise.all([
        sb.from('profiles').select('*').eq('id', session.user.id).single(),
        sb.from('subscriptions').select('*').eq('user_id', session.user.id).eq('status', 'active'),
      ]);

      _profile = profileRes.data || null;
      _subs = (subsRes.data || []).filter(s => !s.current_period_end || new Date(s.current_period_end) > new Date());
      _subsMap = {};
      _subs.forEach(s => { _subsMap[s.vertical] = s; });

      // Ensure profile row exists (in case trigger didn't fire)
      if (!_profile) {
        const meta = session.user.user_metadata || {};
        await sb.from('profiles').upsert({
          id:         session.user.id,
          email:      session.user.email,
          first_name: meta.first_name || '',
          last_name:  meta.last_name || '',
          full_name:  meta.full_name || '',
        }, { onConflict: 'id' });
        const { data } = await sb.from('profiles').select('*').eq('id', session.user.id).single();
        _profile = data;
      }

      // ── Single session enforcement ────────────────────────────────────────
      const sid = getSessionId();
      // Claim this session
      await sb.rpc('claim_session', { p_user_id: session.user.id, p_session_id: sid }).catch(() => {});

      // Periodic check: verify this session is still the active one (every 30s)
      setInterval(async () => {
        if (!_session) return;
        try {
          const { data: valid } = await sb.rpc('check_session', {
            p_user_id: _session.user.id,
            p_session_id: sid,
          });
          if (valid === false) {
            // Another session took over → force logout
            console.warn('[PS] Session invalidated by another login');
            _session = null;
            _profile = null;
            _subs = [];
            _subsMap = {};
            _ready = false;
            await sb.auth.signOut();
            window.location.href = '/login.html?reason=session_replaced';
          }
        } catch (e) {
          // RPC not available yet, silently ignore
        }
      }, 30_000);

      // Track login (fire-and-forget)
      sb.rpc('track_login', { p_user_id: session.user.id }).catch(() => {});
    }

    console.log('[PS] init — user:', _session?.user?.email || 'anon', '| profile:', _profile?.first_name || '?', '| subs:', _subs.length);

    _ready = true;

    // Dispatch event so other scripts (chat widget) know init is complete
    window.dispatchEvent(new CustomEvent('ps:ready', { detail: { session: _session, profile: _profile, subs: _subs } }));

    return { session: _session, profile: _profile, subs: _subs };
  }

  async function refresh() {
    _ready = false;
    _session = null;
    _profile = null;
    _subs = [];
    _subsMap = {};
    return init();
  }

  function isProfileComplete() {
    if (!_profile) return false;
    return !!(
      _profile.first_name &&
      _profile.last_name &&
      _profile.phone &&
      _profile.job_title &&
      _profile.company_name &&
      _profile.billing_address_line1 &&
      _profile.billing_city &&
      _profile.billing_postal_code &&
      _profile.profile_completed_at
    );
  }

  async function requireAuth(returnPath) {
    const { session } = await init();
    if (!session) {
      window.location.href = '/login.html?redirect=' + encodeURIComponent(returnPath || window.location.pathname);
      return false;
    }
    return true;
  }

  function requireProfile() {
    if (!_session) return false;
    if (!isProfileComplete()) {
      if (!window.location.pathname.includes('complete-profile')) {
        window.location.href = '/complete-profile.html?redirect=' + encodeURIComponent(window.location.pathname);
        return false;
      }
    }
    return true;
  }

  async function updateProfile(fields) {
    if (!_session) return { error: 'Not authenticated' };
    const { data, error } = await getClient()
      .from('profiles')
      .update({ ...fields, updated_at: new Date().toISOString() })
      .eq('id', _session.user.id)
      .select()
      .single();
    if (data) _profile = data;
    return { data, error };
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
    // Clear session claim
    if (_session) {
      await getClient().from('profiles')
        .update({ active_session_id: null })
        .eq('id', _session.user.id)
        .catch(() => {});
    }
    await getClient().auth.signOut();
    _session = null;
    _profile = null;
    _subs = [];
    _subsMap = {};
    _ready = false;
    sessionStorage.removeItem('ps_session_id');
    window.location.href = '/login.html';
  }

  return {
    get supabase()  { return getClient(); },
    get session()   { return _session; },
    get profile()   { return _profile; },
    get subs()      { return _subs; },
    get subsMap()   { return _subsMap; },
    get ready()     { return _ready; },
    init, refresh, requireAuth, requireProfile, isProfileComplete,
    updateProfile, subForVertical, hasAnySubscription, subscribedVerticals,
    canUseTool, getMonthlyUsage, getQuota, logout,
    VERTICALS, TIER_ORDER,
  };
})();

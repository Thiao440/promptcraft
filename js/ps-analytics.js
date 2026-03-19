/**
 * ps-analytics.js — Client-side event tracking for The Prompt Studio
 *
 * Tracks: page views, clicks, feature usage, sessions, funnels.
 * Data stored in Supabase `events` table via RPC.
 *
 * Include on EVERY page. Automatically tracks:
 *   - page_view on load
 *   - session_start / session_heartbeat
 *   - last_active_at update
 *
 * Manual tracking via:
 *   PSAnalytics.track('event_name', { key: value })
 *   PSAnalytics.trackClick('button_id')
 *   PSAnalytics.trackFeature('crm_projects')
 */
(function () {
  'use strict';

  // Session ID (persists across pages in same browser tab)
  var SESSION_KEY = 'ps_analytics_sid';
  var _sessionId = '';
  try {
    _sessionId = sessionStorage.getItem(SESSION_KEY);
    if (!_sessionId) {
      _sessionId = 'ses_' + Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
      sessionStorage.setItem(SESSION_KEY, _sessionId);
    }
  } catch (e) {
    _sessionId = 'ses_' + Date.now().toString(36);
  }

  // Queue events before PS is ready
  var _queue = [];
  var _ready = false;
  var _userId = null;

  // ── Core track function ────────────────────────────────────────────────────
  function track(eventName, metadata) {
    if (!_ready || !_userId) {
      _queue.push({ eventName: eventName, metadata: metadata || {} });
      return;
    }
    _send(eventName, metadata || {});
  }

  function _send(eventName, metadata) {
    try {
      var page = location.pathname + location.search;
      var vertical = metadata.vertical || _detectVertical() || '';

      PS.supabase.rpc('log_event', {
        p_user_id:    _userId,
        p_event_name: eventName,
        p_page:       page,
        p_vertical:   vertical,
        p_metadata:   metadata,
        p_session_id: _sessionId,
      }).then(function () {}).catch(function () {});
    } catch (e) { /* silent */ }
  }

  // ── Detect vertical from page context ──────────────────────────────────────
  function _detectVertical() {
    // From URL params
    var params = new URLSearchParams(location.search);
    var v = params.get('v') || params.get('vertical') || '';
    if (v) return v;
    // From tool page
    if (typeof window._toolVertical === 'string') return window._toolVertical;
    return '';
  }

  // ── Convenience methods ────────────────────────────────────────────────────
  function trackClick(elementId, extra) {
    track('click', Object.assign({ element: elementId }, extra || {}));
  }

  function trackFeature(featureName) {
    track('feature_used', { feature: featureName });
    // Also record adoption (first-time use, deduplicated by DB unique constraint)
    try {
      PS.supabase.from('feature_adoptions').insert({
        user_id: _userId,
        feature_name: featureName,
      }).then(function () {}).catch(function () {}); // ignore duplicate
    } catch (e) { /* silent */ }
  }

  function trackToolStart(toolSlug) {
    track('tool_started', { tool_slug: toolSlug });
  }

  function trackToolComplete(toolSlug, durationMs) {
    track('tool_completed', { tool_slug: toolSlug, duration_ms: durationMs });
  }

  function trackOutputAction(action, toolSlug) {
    track('output_action', { action: action, tool_slug: toolSlug }); // copy, export, regenerate, share
  }

  function trackUpgradeClicked(fromTier, context) {
    track('upgrade_clicked', { from_tier: fromTier, context: context });
  }

  // ── UTM capture (on first visit) ───────────────────────────────────────────
  function _captureUTM() {
    try {
      var params = new URLSearchParams(location.search);
      var utm = {
        source:   params.get('utm_source')   || '',
        medium:   params.get('utm_medium')   || '',
        campaign: params.get('utm_campaign') || '',
        ref:      params.get('ref')          || '',
      };
      if (utm.source || utm.medium || utm.campaign || utm.ref) {
        localStorage.setItem('ps_utm', JSON.stringify(utm));
      }
    } catch (e) { /* silent */ }
  }

  function getStoredUTM() {
    try {
      return JSON.parse(localStorage.getItem('ps_utm') || '{}');
    } catch (e) { return {}; }
  }

  // ── Auto-track page view ───────────────────────────────────────────────────
  function _autoPageView() {
    var referrer = document.referrer || '';
    var utm = getStoredUTM();
    track('page_view', {
      referrer: referrer,
      title: document.title,
      utm_source: utm.source || '',
      utm_campaign: utm.campaign || '',
    });
  }

  // ── Update last_active_at ──────────────────────────────────────────────────
  function _updateLastActive() {
    if (!_userId) return;
    try {
      PS.supabase.rpc('update_last_active', { p_user_id: _userId })
        .then(function () {}).catch(function () {});
    } catch (e) { /* silent */ }
  }

  // ── Init: wait for PS.ready ────────────────────────────────────────────────
  _captureUTM();

  window.addEventListener('ps:ready', function (e) {
    if (!e.detail || !e.detail.session) return;
    _userId = e.detail.session.user.id;
    _ready = true;

    // Flush queue
    _queue.forEach(function (q) { _send(q.eventName, q.metadata); });
    _queue = [];

    // Auto-track
    _autoPageView();
    _updateLastActive();
  });

  // Fallback: check PS periodically if ps:ready was missed
  var _initCheck = setInterval(function () {
    if (typeof PS !== 'undefined' && PS.session) {
      _userId = PS.session.user.id;
      _ready = true;
      _queue.forEach(function (q) { _send(q.eventName, q.metadata); });
      _queue = [];
      _autoPageView();
      _updateLastActive();
      clearInterval(_initCheck);
    }
  }, 2000);

  // Stop checking after 30s
  setTimeout(function () { clearInterval(_initCheck); }, 30000);

  // ── Public API ─────────────────────────────────────────────────────────────
  window.PSAnalytics = {
    track: track,
    trackClick: trackClick,
    trackFeature: trackFeature,
    trackToolStart: trackToolStart,
    trackToolComplete: trackToolComplete,
    trackOutputAction: trackOutputAction,
    trackUpgradeClicked: trackUpgradeClicked,
    getStoredUTM: getStoredUTM,
    getSessionId: function () { return _sessionId; },
  };
})();

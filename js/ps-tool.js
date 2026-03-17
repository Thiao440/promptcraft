/**
 * ps-tool.js — The Prompt Studio reusable tool helper
 *
 * Usage: call PSTool.init(config) at the bottom of any tool page.
 *
 * Required config:
 *   toolSlug      {string}   e.g. 'immo-annonce'
 *   toolVertical  {string}   e.g. 'immo'
 *   toolMinTier   {string}   'bronze' | 'silver' | 'gold'
 *   collectInputs {function} returns plain object of form values
 *
 * Optional config:
 *   generateLabel     {string}   Button label (default: 'Générer')
 *   loadingText       {string}   Loading message (default: "L'IA génère votre contenu")
 *   renderHistoryInfo {function} (item) → string shown above history preview
 *   onHistoryClick    {function} (text) → custom handler when history item clicked
 *
 * Expected HTML IDs (standardized across all tool pages):
 *   tool-form, generate-btn, btn-icon, btn-text
 *   result-content, result-meta, meta-duration, meta-tokens, meta-date
 *   copy-btn, regen-btn
 *   quota-label, quota-fill
 *   history-list, history-count
 *   user-email, toast
 */

const PSTool = (() => {

  let _cfg       = null;
  let _lastInputs = null;

  // ── Toast ───────────────────────────────────────────────────────────────────
  function showToast(msg, type = 'success') {
    const t = document.getElementById('toast');
    if (!t) return;
    t.textContent = (type === 'success' ? '✅ ' : '❌ ') + msg;
    t.className   = `toast ${type} show`;
    setTimeout(() => t.classList.remove('show'), 3500);
  }

  // ── Escape ──────────────────────────────────────────────────────────────────
  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }

  // ── Loading state ───────────────────────────────────────────────────────────
  function setLoading(on) {
    const btn     = document.getElementById('generate-btn');
    const btnIcon = document.getElementById('btn-icon');
    const btnText = document.getElementById('btn-text');
    const content = document.getElementById('result-content');
    const label   = _cfg.generateLabel || 'Générer';
    const text    = _cfg.loadingText   || "L'IA génère votre contenu";

    if (on) {
      btn.disabled        = true;
      btnIcon.textContent = '⏳';
      btnText.textContent = 'Génération en cours…';
      content.innerHTML   = `
        <div class="loading-state">
          <div class="spinner"></div>
          <div class="loading-text">${escapeHtml(text)}<span class="loading-dots"></span></div>
        </div>`;
    } else {
      btn.disabled        = false;
      btnIcon.textContent = '✨';
      btnText.textContent = label;
    }
  }

  // ── Display result ──────────────────────────────────────────────────────────
  function displayResult(output, meta = {}) {
    const content = document.getElementById('result-content');
    content.innerHTML = `<textarea class="result-text" id="result-textarea" spellcheck="false">${escapeHtml(output)}</textarea>`;

    const metaEl = document.getElementById('result-meta');
    if (metaEl) {
      metaEl.style.display = 'flex';
      const dur  = document.getElementById('meta-duration');
      const tok  = document.getElementById('meta-tokens');
      const date = document.getElementById('meta-date');
      if (dur)  dur.textContent  = meta.durationMs ? `${(meta.durationMs / 1000).toFixed(1)}s` : '—';
      if (tok)  tok.textContent  = meta.tokensUsed || '—';
      if (date) date.textContent = new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
    }

    const copyBtn  = document.getElementById('copy-btn');
    const regenBtn = document.getElementById('regen-btn');
    if (copyBtn)  copyBtn.disabled  = false;
    if (regenBtn) regenBtn.disabled = false;
  }

  // ── Copy ────────────────────────────────────────────────────────────────────
  function copyResult() {
    const ta = document.getElementById('result-textarea');
    if (!ta) return;
    navigator.clipboard.writeText(ta.value)
      .then(() => showToast('Copié dans le presse-papiers !'))
      .catch(() => showToast('Impossible de copier.', 'error'));
  }

  // ── Regenerate ──────────────────────────────────────────────────────────────
  function regenerate() {
    if (_lastInputs) generate(_lastInputs);
  }

  // ── Quota display ───────────────────────────────────────────────────────────
  async function updateQuotaDisplay() {
    const sub = PS.subForVertical(_cfg.toolVertical);
    if (!sub) return;

    const count  = await PS.getMonthlyUsage();
    const limit  = PS.getQuota(_cfg.toolVertical);
    const pct    = limit === Infinity ? 5 : Math.min(100, Math.round((count / limit) * 100));

    const label = document.getElementById('quota-label');
    const fill  = document.getElementById('quota-fill');

    if (label) label.textContent = limit === Infinity
      ? `${count} générés ce mois (illimité)`
      : `${count} / ${limit} générations ce mois`;

    if (fill) {
      fill.style.width = pct + '%';
      if (pct > 80) fill.classList.add('danger');
      else fill.classList.remove('danger');
    }
  }

  // ── History ─────────────────────────────────────────────────────────────────
  async function loadHistory() {
    if (!PS.session) return;

    const { data } = await PS.supabase
      .from('tool_usage')
      .select('id, created_at, output_text, input_data')
      .eq('user_id', PS.session.user.id)
      .eq('tool_slug', _cfg.toolSlug)
      .order('created_at', { ascending: false })
      .limit(10);

    const list  = document.getElementById('history-list');
    const count = document.getElementById('history-count');
    if (!list) return;

    if (!data?.length) {
      list.innerHTML     = `<div style="color:var(--muted);font-size:.875rem;">Aucune génération pour cet outil.</div>`;
      if (count) count.textContent = '';
      return;
    }

    if (count) count.textContent = `${data.length} dernière(s)`;

    list.innerHTML = data.map(item => {
      const date    = new Date(item.created_at).toLocaleDateString('fr-FR', {
        day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit',
      });
      const preview = (item.output_text || '').slice(0, 120);
      const info    = _cfg.renderHistoryInfo
        ? _cfg.renderHistoryInfo(item)
        : new Date(item.created_at).toLocaleTimeString('fr-FR');

      // Safely encode output for inline handler
      const encoded = encodeURIComponent(item.output_text || '');

      return `
        <div class="history-item" onclick="PSTool._loadFromHistory(decodeURIComponent('${encoded}'))">
          <div class="history-item-header">
            <span>${escapeHtml(info)}</span>
            <span>${date}</span>
          </div>
          <div class="history-item-preview">${escapeHtml(preview)}…</div>
        </div>`;
    }).join('');
  }

  function _loadFromHistory(text) {
    if (_cfg?.onHistoryClick) {
      _cfg.onHistoryClick(text);
    } else {
      displayResult(text, {});
      const content = document.getElementById('result-content');
      if (content) content.scrollIntoView({ behavior: 'smooth' });
    }
  }

  // ── Error message resolver ──────────────────────────────────────────────────
  function resolveErrorMsg(data) {
    // Resolve structured error: either already an object, or a JSON-encoded string.
    // Plain strings (e.g. "Tool not found") are returned as-is — no JSON.parse attempted.
    let e = null;
    if (data.error && typeof data.error === 'object') {
      e = data.error;
    } else if (typeof data.error === 'string' && data.error.trimStart().startsWith('{')) {
      try { e = JSON.parse(data.error); } catch { /* not valid JSON — fall through to plain string */ }
    }

    if (e) {
      if (e.reason === 'quota_exceeded')   return `Quota atteint (${e.used}/${e.limit} générations ce mois).`;
      if (e.reason === 'upgrade_required') return `Upgrade requis pour cet outil (requis : ${e.required}).`;
      if (e.reason === 'wrong_vertical')   return `Cet outil n'est pas dans votre verticale.`;
      if (e.reason === 'no_subscription')  return 'Aucun abonnement actif. Veuillez vous abonner.';
      if (e.reason === 'expired')          return 'Abonnement expiré. Veuillez renouveler.';
    }

    return (typeof data.error === 'string' ? data.error : null) || 'Une erreur est survenue.';
  }

  // ── Core generate ───────────────────────────────────────────────────────────
  async function generate(inputs) {
    setLoading(true);

    const { data: { session } } = await PS.supabase.auth.getSession();
    if (!session?.access_token) {
      setLoading(false);
      return showToast('Session expirée. Veuillez vous reconnecter.', 'error');
    }

    try {
      const res = await fetch('/api/ai-tool', {
        method:  'POST',
        headers: {
          'Content-Type':  'application/json',
          'Authorization': `Bearer ${session.access_token}`,
        },
        body: JSON.stringify({ toolSlug: _cfg.toolSlug, inputs }),
      });

      // Parse response defensively: Netlify can return plain-text errors
      // (cold start crash, missing env var, unhandled exception) that aren't JSON.
      const rawText = await res.text();
      let data;
      try {
        data = JSON.parse(rawText);
      } catch {
        console.error('[PSTool] non-JSON response from server:', rawText.slice(0, 300));
        setLoading(false);
        return showToast('Erreur serveur inattendue. Réessayez dans un instant.', 'error');
      }

      if (!res.ok) {
        setLoading(false);
        return showToast(resolveErrorMsg(data), 'error');
      }

      displayResult(data.output, { durationMs: data.durationMs, tokensUsed: data.tokensUsed });
      updateQuotaDisplay();
      loadHistory();

    } catch (err) {
      console.error('[PSTool] generate error', err);
      showToast('Erreur de connexion. Vérifiez votre réseau.', 'error');
    } finally {
      setLoading(false);
    }
  }

  // ── Form submit handler ─────────────────────────────────────────────────────
  function attachFormHandler() {
    const form = document.getElementById(_cfg.formId || 'tool-form');
    if (!form) return console.warn('[PSTool] form not found');

    form.addEventListener('submit', async (e) => {
      e.preventDefault();

      const access = PS.canUseTool(_cfg.toolSlug, _cfg.toolMinTier, _cfg.toolVertical);
      if (!access.allowed) {
        if (access.reason === 'no_subscription') return window.location.href = '/tarifs.html';
        if (access.reason === 'upgrade_required') return showToast(`Upgrade requis (${access.required}).`, 'error');
        return showToast('Accès non autorisé.', 'error');
      }

      const inputs = _cfg.collectInputs();
      if (!inputs) return;  // validation failed (dynamic tool renderer returns null)
      _lastInputs  = inputs;
      generate(inputs);
    });
  }

  // ── Public init ─────────────────────────────────────────────────────────────
  async function init(config) {
    _cfg = config;

    const ok = await PS.requireAuth(window.location.pathname);
    if (!ok) return;

    // Set user email
    const emailEl = document.getElementById('user-email');
    if (emailEl) emailEl.textContent = PS.session.user.email;

    // Access check
    const access = PS.canUseTool(_cfg.toolSlug, _cfg.toolMinTier, _cfg.toolVertical);
    if (!access.allowed) {
      const btn = document.getElementById('generate-btn');
      if (btn) btn.disabled = true;
      console.warn('[PSTool] access denied:', access);
      showToast(access.reason, 'error');
      return;
    }

    attachFormHandler();

    // Wire copy/regen buttons (no-op if absent)
    const copyBtn  = document.getElementById('copy-btn');
    const regenBtn = document.getElementById('regen-btn');
    if (copyBtn)  copyBtn.onclick  = copyResult;
    if (regenBtn) regenBtn.onclick = regenerate;

    await updateQuotaDisplay();
    await loadHistory();
  }

  return { init, showToast, copyResult, regenerate, _loadFromHistory };

})();

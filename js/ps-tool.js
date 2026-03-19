/**
 * ps-tool.js — The Prompt Studio reusable tool helper
 *
 * Usage: call PSTool.init(config) at the bottom of any tool page.
 *
 * Required config:
 *   toolSlug      {string}   e.g. 'immo-annonce'
 *   toolVertical  {string}   e.g. 'immo'
 *   toolMinTier   {string}   'starter' | 'pro' | 'gold' | 'team'
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

  let _cfg          = null;
  let _lastInputs   = null;
  let _historyCache = {};  // safeId → { output_text, input_data }

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

  // ── Markdown renderer ───────────────────────────────────────────────────────
  function renderMarkdown(text) {
    let s = escapeHtml(text);
    // Headers
    s = s.replace(/^#### (.+)$/gm, '<h5>$1</h5>');
    s = s.replace(/^### (.+)$/gm, '<h4>$1</h4>');
    s = s.replace(/^## (.+)$/gm,  '<h3>$1</h3>');
    s = s.replace(/^# (.+)$/gm,   '<h2>$1</h2>');
    // Horizontal rules
    s = s.replace(/^(?:---+|\*\*\*+)$/gm, '<hr>');
    // Bold / italic / bold-italic
    s = s.replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>');
    s = s.replace(/\*\*(.+?)\*\*/g,     '<strong>$1</strong>');
    s = s.replace(/\*(.+?)\*/g,         '<em>$1</em>');
    // Unordered lists (- or •)
    s = s.replace(/((?:^[ \t]*[-•] .+$\n?)+)/gm, m => {
      const items = m.trim().split('\n')
        .map(l => `<li>${l.replace(/^[ \t]*[-•] /, '')}</li>`).join('');
      return `<ul>${items}</ul>`;
    });
    // Ordered lists
    s = s.replace(/((?:^\d+\. .+$\n?)+)/gm, m => {
      const items = m.trim().split('\n')
        .map(l => `<li>${l.replace(/^\d+\. /, '')}</li>`).join('');
      return `<ol>${items}</ol>`;
    });
    // Paragraphs from double newlines
    return s.split(/\n{2,}/).map(b => {
      b = b.trim();
      if (!b) return '';
      if (/^<(?:h[1-6]|ul|ol|hr)/.test(b)) return b;
      return `<p>${b.replace(/\n/g, '<br>')}</p>`;
    }).filter(Boolean).join('\n');
  }

  // ── Toggle between rendered view and raw edit mode ─────────────────────────
  function toggleResultView() {
    const rendered = document.getElementById('result-rendered');
    const textarea = document.getElementById('result-textarea');
    const btn      = document.getElementById('result-toggle-btn');
    if (!rendered || !textarea || !btn) return;

    const isEditing = !textarea.classList.contains('result-text--hidden');
    if (isEditing) {
      // Switch back to rendered — re-render in case user edited the textarea
      rendered.innerHTML = renderMarkdown(textarea.value);
      rendered.classList.remove('result-rendered--hidden');
      textarea.classList.add('result-text--hidden');
      btn.textContent = '✏️ Éditer';
    } else {
      // Switch to raw edit
      rendered.classList.add('result-rendered--hidden');
      textarea.classList.remove('result-text--hidden');
      textarea.focus();
      btn.textContent = '👁 Aperçu';
    }
  }

  // ── Display result ──────────────────────────────────────────────────────────
  function displayResult(output, meta = {}) {
    const content = document.getElementById('result-content');
    content.innerHTML = `
      <div class="result-rendered" id="result-rendered">${renderMarkdown(output)}</div>
      <textarea class="result-text result-text--hidden" id="result-textarea" spellcheck="false">${escapeHtml(output)}</textarea>
      <div class="result-view-toggle">
        <button class="result-toggle-btn" id="result-toggle-btn" onclick="PSTool._toggleResultView()">✏️ Éditer</button>
      </div>`;

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
      .then(() => {
        showToast('Copié dans le presse-papiers !');
        if (typeof PSAnalytics !== 'undefined') PSAnalytics.trackOutputAction('copy', _cfg.toolSlug);
      })
      .catch(() => showToast('Impossible de copier.', 'error'));
  }

  // ── Regenerate ──────────────────────────────────────────────────────────────
  function regenerate() {
    if (_lastInputs) {
      if (typeof PSAnalytics !== 'undefined') PSAnalytics.trackOutputAction('regenerate', _cfg.toolSlug);
      generate(_lastInputs);
    }
  }

  // ── Quota display ───────────────────────────────────────────────────────────
  async function updateQuotaDisplay() {
    const sub = PS.subForVertical(_cfg.toolVertical);
    if (!sub) return;

    const count  = await PS.getMonthlyUsage(_cfg.toolVertical);
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
      .limit(20);

    const list  = document.getElementById('history-list');
    const count = document.getElementById('history-count');
    if (!list) return;

    if (!data?.length) {
      list.innerHTML = `<div style="color:var(--muted);font-size:.875rem;">Aucune génération pour cet outil.</div>`;
      if (count) count.textContent = '';
      return;
    }

    if (count) count.textContent = `${data.length} entrée(s)`;

    // Label map for common field names
    const FIELD_LABELS = {
      type_bien: 'Type', transaction: 'Transaction', surface: 'Surface',
      pieces: 'Pièces', prix: 'Prix', localisation: 'Ville',
      points_forts: 'Points forts', infos_comp: 'Infos comp.', ton: 'Ton',
      objet: 'Objet', destinataire: 'Destinataire', contexte: 'Contexte',
      vertical: 'Secteur', langue: 'Langue', style: 'Style',
    };

    list.innerHTML = data.map(item => {
      const date = new Date(item.created_at).toLocaleDateString('fr-FR', {
        day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit',
      });
      const info = _cfg.renderHistoryInfo
        ? _cfg.renderHistoryInfo(item)
        : date;

      const preview = (item.output_text || '').slice(0, 100);
      const safeId  = item.id.replace(/-/g, '');

      // Store in cache for onclick lookup
      _historyCache[safeId] = { output_text: item.output_text || '', input_data: item.input_data };

      // Input fields block
      const inputFields = item.input_data
        ? Object.entries(item.input_data)
            .filter(([, v]) => v && String(v).trim())
            .map(([k, v]) => {
              const label = FIELD_LABELS[k] || k;
              return `<div class="hist-field">
                <span class="hist-field-key">${escapeHtml(label)}</span>
                <span class="hist-field-val">${escapeHtml(String(v))}</span>
              </div>`;
            }).join('')
        : '';

      return `
        <div class="history-item" id="hist-${safeId}">
          <div class="history-item-header" onclick="PSTool._loadFromHistory('${safeId}')">
            <div class="hist-header-left">
              <span class="hist-info">${escapeHtml(info)}</span>
              <span class="hist-preview">${escapeHtml(preview)}${preview.length >= 100 ? '…' : ''}</span>
            </div>
            <button class="hist-btn-detail" title="Voir les détails"
              onclick="event.stopPropagation(); PSTool._toggleHistoryDetail('${safeId}')">
              🔍
            </button>
          </div>
          <div class="history-detail" id="hist-detail-${safeId}">
            ${inputFields ? `
              <div class="hist-section">
                <div class="hist-section-label">Paramètres</div>
                <div class="hist-fields">${inputFields}</div>
              </div>` : ''}
            <div class="hist-section">
              <div class="hist-section-label">
                Résultat complet
                <button class="hist-load-btn"
                  onclick="event.stopPropagation(); PSTool._loadFromHistory('${safeId}')">
                  ↑ Charger dans le panneau
                </button>
              </div>
              <div class="result-rendered hist-output-rendered">${renderMarkdown(item.output_text || '')}</div>
            </div>
          </div>
        </div>`;
    }).join('');
  }

  function _loadFromHistory(safeId) {
    const cached = _historyCache[safeId];
    if (!cached) return;
    const text = cached.output_text;
    if (_cfg?.onHistoryClick) {
      _cfg.onHistoryClick(text);
    } else {
      displayResult(text, {});
      const content = document.getElementById('result-content');
      if (content) content.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  function toggleHistoryDetail(safeId) {
    const detail = document.getElementById(`hist-detail-${safeId}`);
    const btn    = document.querySelector(`#hist-${safeId} .hist-btn-detail`);
    if (!detail) return;
    const isOpen = detail.classList.contains('history-detail--open');
    detail.classList.toggle('history-detail--open', !isOpen);
    if (btn) btn.textContent = isOpen ? '🔍' : '✕';
  }

  // ── Error message resolver (v3 standardized + v2 legacy compat) ─────────────
  function resolveErrorMsg(data) {
    let e = null;

    // v3 standardized: { error: { code, message, ... } }
    if (data.error && typeof data.error === 'object' && data.error.code) {
      e = data.error;
      const codeMap = {
        'QUOTA_EXCEEDED':       `Quota atteint (${e.used||'?'}/${e.limit||'?'} ce mois).`,
        'UPGRADE_REQUIRED':     `Upgrade requis (${e.required || 'pro'}).`,
        'NO_SUBSCRIPTION':      'Aucun abonnement actif. Veuillez vous abonner.',
        'SUBSCRIPTION_EXPIRED': 'Abonnement expiré. Veuillez renouveler.',
        'RATE_LIMITED':         'Trop de requêtes. Patientez 1 minute.',
        'GENERATION_TIMEOUT':   'La génération a pris trop de temps. Réessayez.',
        'GENERATION_FAILED':    'Erreur de génération IA. Réessayez.',
        'AUTH_REQUIRED':        'Session expirée. Veuillez vous reconnecter.',
        'TOOL_NOT_FOUND':       'Outil introuvable.',
        'TOOL_UNAVAILABLE':     'Outil temporairement indisponible.',
      };
      return codeMap[e.code] || e.message || 'Une erreur est survenue.';
    }

    // v2 legacy: { error: '{"reason":"..."}' } or { error: "string" }
    if (data.error && typeof data.error === 'object') {
      e = data.error;
    } else if (typeof data.error === 'string' && data.error.trimStart().startsWith('{')) {
      try { e = JSON.parse(data.error); } catch { /* not JSON */ }
    }

    if (e) {
      if (e.reason === 'quota_exceeded')   return `Quota atteint (${e.used}/${e.limit} ce mois).`;
      if (e.reason === 'upgrade_required') return `Upgrade requis (${e.required}).`;
      if (e.reason === 'wrong_vertical')   return `Cet outil n'est pas dans votre verticale.`;
      if (e.reason === 'no_subscription')  return 'Aucun abonnement actif.';
      if (e.reason === 'expired')          return 'Abonnement expiré.';
    }

    return (typeof data.error === 'string' ? data.error : null) || 'Une erreur est survenue.';
  }

  // ── Core generate ───────────────────────────────────────────────────────────
  async function generate(inputs) {
    // Offline detection
    if (!navigator.onLine) {
      return showToast('Pas de connexion internet. Vérifiez votre réseau.', 'error');
    }

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
        body: JSON.stringify({ toolSlug: _cfg.toolSlug, inputs, projectId: window._activeProjectId || undefined }),
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

      // Analytics: track generation complete
      if (typeof PSAnalytics !== 'undefined') {
        PSAnalytics.trackToolComplete(_cfg.toolSlug, data.durationMs);
      }

      // Ads: maybe show interstitial (Starter only, not trial)
      if (typeof PSAds !== 'undefined') {
        PSAds.maybeShowInterstitial();
      }

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

  return { init, showToast, copyResult, regenerate, _loadFromHistory, _toggleResultView: toggleResultView, _toggleHistoryDetail: toggleHistoryDetail };

})();

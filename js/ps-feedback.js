/**
 * ps-feedback.js — Bug reports & Tool suggestions module
 *
 * Provides:
 *   PSFeedback.reportBug(data)        — submit a bug report
 *   PSFeedback.suggestTool(data)      — submit a tool suggestion
 *   PSFeedback.listSuggestions(opts)  — list suggestions (public roadmap)
 *   PSFeedback.vote(suggestionId)     — upvote a suggestion
 *   PSFeedback.unvote(suggestionId)   — remove upvote
 *   PSFeedback.captureContext()       — auto-capture browser/tool context
 *   PSFeedback.captureConsoleLogs()   — get recent console errors
 *   PSFeedback.showBugModal(opts)     — render & show the bug report modal
 *   PSFeedback.showSuggestModal(opts) — render & show the suggestion modal
 *
 * Depends on: ps-auth.js (PS global)
 */
(function () {
  'use strict';

  const sb = () => PS.supabase;

  // ── Console log capture ────────────────────────────────────────────────────
  // Intercept console.error and console.warn to store recent entries
  const _logs = [];
  const MAX_LOGS = 30;
  const _origError = console.error;
  const _origWarn  = console.warn;

  console.error = function () {
    _logs.push({ level: 'error', ts: Date.now(), msg: _argsToString(arguments) });
    if (_logs.length > MAX_LOGS) _logs.shift();
    _origError.apply(console, arguments);
  };
  console.warn = function () {
    _logs.push({ level: 'warn', ts: Date.now(), msg: _argsToString(arguments) });
    if (_logs.length > MAX_LOGS) _logs.shift();
    _origWarn.apply(console, arguments);
  };

  // Also capture unhandled errors
  window.addEventListener('error', function (e) {
    _logs.push({ level: 'exception', ts: Date.now(), msg: e.message, file: e.filename, line: e.lineno, col: e.colno });
    if (_logs.length > MAX_LOGS) _logs.shift();
  });
  window.addEventListener('unhandledrejection', function (e) {
    _logs.push({ level: 'unhandled_promise', ts: Date.now(), msg: String(e.reason) });
    if (_logs.length > MAX_LOGS) _logs.shift();
  });

  function _argsToString(args) {
    return Array.from(args).map(a => {
      if (typeof a === 'string') return a;
      try { return JSON.stringify(a).slice(0, 500); } catch { return String(a); }
    }).join(' ');
  }

  // ── Context capture ────────────────────────────────────────────────────────
  function captureContext() {
    return {
      userAgent: navigator.userAgent,
      screenWidth: screen.width,
      screenHeight: screen.height,
      viewportWidth: window.innerWidth,
      viewportHeight: window.innerHeight,
      language: navigator.language,
      timestamp: new Date().toISOString(),
      url: location.href,
      referrer: document.referrer || '',
    };
  }

  function captureConsoleLogs() {
    return _logs.slice(-20);
  }

  /** Capture current tool state (form inputs, last result, etc.) */
  function captureToolState() {
    const state = {};
    // Collect form inputs
    const form = document.getElementById('form-fields') || document.getElementById('tool-form');
    if (form) {
      state.inputs = {};
      form.querySelectorAll('[name]').forEach(el => {
        state.inputs[el.name] = (el.value || '').slice(0, 200);
      });
    }
    // Current tool slug
    const params = new URLSearchParams(location.search);
    state.toolSlug = params.get('slug') || '';
    state.projectId = params.get('project') || '';
    // Result preview
    const result = document.getElementById('result-rendered') || document.getElementById('result-content');
    if (result) {
      state.resultPreview = (result.textContent || '').slice(0, 300);
    }
    // Quota
    const quota = document.getElementById('quota-label');
    if (quota) state.quota = quota.textContent;
    return state;
  }

  // ── Escape HTML ────────────────────────────────────────────────────────────
  function esc(s) {
    const d = document.createElement('div');
    d.textContent = s;
    return d.innerHTML;
  }

  // ── Bug Report ─────────────────────────────────────────────────────────────
  async function reportBug(data) {
    const row = {
      user_id:      PS.session.user.id,
      tool_slug:    data.tool_slug || null,
      vertical:     data.vertical || null,
      category:     data.category || 'bug',
      severity:     data.severity || 'medium',
      title:        data.title,
      description:  data.description,
      steps:        data.steps || null,
      expected:     data.expected || null,
      actual:       data.actual || null,
      browser_info: captureContext(),
      console_logs: captureConsoleLogs(),
      tool_state:   captureToolState(),
      page_url:     location.href,
    };
    const { error } = await sb().from('bug_reports').insert(row);
    if (error) { console.error('[feedback] reportBug error', error); return false; }
    return true;
  }

  // ── Tool Suggestion ────────────────────────────────────────────────────────
  async function suggestTool(data) {
    // Auto-capture user context
    const sub = PS.subs?.[0];
    const row = {
      user_id:          PS.session.user.id,
      vertical:         data.vertical,
      category:         data.category || '',
      tool_name:        data.tool_name,
      description:      data.description,
      use_case:         data.use_case || null,
      frequency:        data.frequency || 'weekly',
      priority:         data.priority || 'nice_to_have',
      current_solution: data.current_solution || null,
      pain_points:      data.pain_points || null,
      example_input:    data.example_input || null,
      example_output:   data.example_output || null,
      competitors:      data.competitors || null,
      user_vertical:    sub?.vertical || null,
      user_tier:        sub?.tier || null,
      user_job:         PS.profile?.job_title || null,
    };
    const { error } = await sb().from('tool_suggestions').insert(row);
    if (error) { console.error('[feedback] suggestTool error', error); return false; }
    return true;
  }

  // ── List suggestions (public roadmap) ──────────────────────────────────────
  async function listSuggestions({ vertical, status, limit = 50, orderBy = 'vote_count' } = {}) {
    let q = sb()
      .from('tool_suggestions')
      .select('id, vertical, category, tool_name, description, use_case, frequency, priority, vote_count, status, created_at')
      .order(orderBy, { ascending: false })
      .limit(limit);
    if (vertical) q = q.eq('vertical', vertical);
    if (status)   q = q.eq('status', status);
    const { data, error } = await q;
    if (error) { console.error('[feedback] listSuggestions error', error); return []; }
    return data || [];
  }

  async function vote(suggestionId) {
    try { await sb().rpc('vote_suggestion', { p_suggestion_id: suggestionId, p_user_id: PS.session.user.id }); return true; }
    catch (e) { console.warn('[feedback] vote error', e); return false; }
  }

  async function unvote(suggestionId) {
    try { await sb().rpc('unvote_suggestion', { p_suggestion_id: suggestionId, p_user_id: PS.session.user.id }); return true; }
    catch (e) { console.warn('[feedback] unvote error', e); return false; }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UI: BUG REPORT MODAL
  // ══════════════════════════════════════════════════════════════════════════
  function showBugModal({ toolSlug, vertical } = {}) {
    const overlay = document.createElement('div');
    overlay.className = 'fb-overlay';
    overlay.id = 'fb-overlay';
    overlay.onclick = e => { if (e.target === overlay) overlay.remove(); };

    overlay.innerHTML = `
      <div class="fb-modal">
        <div class="fb-modal-head">
          <span>🐛 Signaler un problème</span>
          <button class="fb-close" onclick="document.getElementById('fb-overlay').remove()">✕</button>
        </div>
        <div class="fb-modal-body">
          <div class="fb-row">
            <div class="fb-field fb-half">
              <label>Catégorie *</label>
              <select id="fb-category">
                <option value="bug">🐛 Bug / Erreur</option>
                <option value="generation">🤖 Problème de génération</option>
                <option value="display">🖥 Affichage / UI</option>
                <option value="performance">⚡ Lenteur / Performance</option>
                <option value="other">💬 Autre</option>
              </select>
            </div>
            <div class="fb-field fb-half">
              <label>Gravité *</label>
              <select id="fb-severity">
                <option value="low">🟢 Faible — mineur</option>
                <option value="medium" selected>🟡 Moyen — gênant</option>
                <option value="high">🟠 Élevé — bloquant</option>
                <option value="critical">🔴 Critique — urgent</option>
              </select>
            </div>
          </div>
          <div class="fb-field">
            <label>Titre du problème *</label>
            <input type="text" id="fb-title" placeholder="Ex: Le bouton Générer ne répond pas" maxlength="200"/>
          </div>
          <div class="fb-field">
            <label>Description *</label>
            <textarea id="fb-desc" rows="3" placeholder="Décrivez le problème en détail…" maxlength="2000"></textarea>
          </div>
          <div class="fb-field">
            <label>Étapes pour reproduire</label>
            <textarea id="fb-steps" rows="2" placeholder="1. Remplir le formulaire\n2. Cliquer sur Générer\n3. L'erreur apparaît" maxlength="1000"></textarea>
          </div>
          <div class="fb-row">
            <div class="fb-field fb-half">
              <label>Comportement attendu</label>
              <textarea id="fb-expected" rows="2" placeholder="Ce qui devrait se passer…" maxlength="500"></textarea>
            </div>
            <div class="fb-field fb-half">
              <label>Comportement actuel</label>
              <textarea id="fb-actual" rows="2" placeholder="Ce qui se passe réellement…" maxlength="500"></textarea>
            </div>
          </div>
          <div class="fb-context-info">
            📋 Les informations suivantes seront collectées automatiquement : navigateur, taille d'écran, URL, logs console, état du formulaire.
          </div>
        </div>
        <div class="fb-modal-foot">
          <button class="fb-btn fb-btn-cancel" onclick="document.getElementById('fb-overlay').remove()">Annuler</button>
          <button class="fb-btn fb-btn-submit" id="fb-submit" onclick="PSFeedback._submitBug('${toolSlug || ''}', '${vertical || ''}')">Envoyer le rapport</button>
        </div>
      </div>`;

    document.body.appendChild(overlay);
    setTimeout(() => document.getElementById('fb-title')?.focus(), 50);
  }

  async function _submitBug(toolSlug, vertical) {
    const title = document.getElementById('fb-title')?.value?.trim();
    const desc  = document.getElementById('fb-desc')?.value?.trim();
    if (!title || !desc) { alert('Veuillez remplir le titre et la description.'); return; }

    const btn = document.getElementById('fb-submit');
    btn.disabled = true;
    btn.textContent = 'Envoi en cours…';

    const ok = await reportBug({
      tool_slug:   toolSlug || null,
      vertical:    vertical || null,
      category:    document.getElementById('fb-category')?.value || 'bug',
      severity:    document.getElementById('fb-severity')?.value || 'medium',
      title,
      description: desc,
      steps:       document.getElementById('fb-steps')?.value?.trim() || null,
      expected:    document.getElementById('fb-expected')?.value?.trim() || null,
      actual:      document.getElementById('fb-actual')?.value?.trim() || null,
    });

    document.getElementById('fb-overlay')?.remove();
    if (ok) {
      _showToast('✅ Rapport envoyé ! Merci pour votre retour.');
    } else {
      _showToast('❌ Erreur lors de l\'envoi. Réessayez.', true);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UI: TOOL SUGGESTION MODAL
  // ══════════════════════════════════════════════════════════════════════════
  function showSuggestModal({ vertical } = {}) {
    const vmeta = PS.VERTICALS || {};
    const vOpts = Object.entries(vmeta).map(([k, v]) =>
      `<option value="${k}" ${k === vertical ? 'selected' : ''}>${v.icon} ${v.label}</option>`
    ).join('');

    const overlay = document.createElement('div');
    overlay.className = 'fb-overlay';
    overlay.id = 'fb-overlay';
    overlay.onclick = e => { if (e.target === overlay) overlay.remove(); };

    overlay.innerHTML = `
      <div class="fb-modal fb-modal-lg">
        <div class="fb-modal-head">
          <span>💡 Proposer un nouvel outil</span>
          <button class="fb-close" onclick="document.getElementById('fb-overlay').remove()">✕</button>
        </div>
        <div class="fb-modal-body">
          <p class="fb-intro">Votre avis compte ! Décrivez l'outil IA que vous aimeriez utiliser. Les suggestions les plus demandées seront priorisées.</p>

          <div class="fb-row">
            <div class="fb-field fb-half">
              <label>Verticale / Secteur *</label>
              <select id="fb-vertical">${vOpts}</select>
            </div>
            <div class="fb-field fb-half">
              <label>Catégorie</label>
              <input type="text" id="fb-cat" placeholder="Ex: Emails, Analyse, Création…" maxlength="100"/>
            </div>
          </div>

          <div class="fb-field">
            <label>Nom de l'outil proposé *</label>
            <input type="text" id="fb-toolname" placeholder="Ex: Générateur de devis, Analyse de marché, Script téléphonique…" maxlength="200"/>
          </div>

          <div class="fb-field">
            <label>Description — Que devrait faire cet outil ? *</label>
            <textarea id="fb-tooldesc" rows="3" placeholder="Décrivez précisément ce que l'outil devrait générer ou analyser…" maxlength="2000"></textarea>
          </div>

          <div class="fb-field">
            <label>Votre cas d'usage concret</label>
            <textarea id="fb-usecase" rows="2" placeholder="Dans quelle situation utiliseriez-vous cet outil ? À quelle fréquence ?" maxlength="1000"></textarea>
          </div>

          <div class="fb-row">
            <div class="fb-field fb-half">
              <label>Fréquence d'utilisation estimée</label>
              <select id="fb-freq">
                <option value="daily">Quotidien</option>
                <option value="weekly" selected>Hebdomadaire</option>
                <option value="monthly">Mensuel</option>
                <option value="rarely">Ponctuel</option>
              </select>
            </div>
            <div class="fb-field fb-half">
              <label>Importance pour vous</label>
              <select id="fb-prio">
                <option value="critical">🔴 Critique — j'en ai vraiment besoin</option>
                <option value="important">🟠 Important — ce serait très utile</option>
                <option value="nice_to_have" selected>🟢 Sympa — si ça existe tant mieux</option>
              </select>
            </div>
          </div>

          <div class="fb-field">
            <label>Comment faites-vous aujourd'hui sans cet outil ?</label>
            <textarea id="fb-current" rows="2" placeholder="Ex: Je rédige à la main, j'utilise ChatGPT, je n'ai pas de solution…" maxlength="1000"></textarea>
          </div>

          <div class="fb-field">
            <label>Exemple d'entrée (ce que vous taperiez)</label>
            <textarea id="fb-exinput" rows="2" placeholder="Ex: Nom du client, budget, objectifs…" maxlength="1000"></textarea>
          </div>

          <div class="fb-field">
            <label>Exemple de sortie attendue</label>
            <textarea id="fb-exoutput" rows="2" placeholder="Ex: Un devis formaté avec les sections X, Y, Z…" maxlength="1000"></textarea>
          </div>

          <div class="fb-field">
            <label>Connaissez-vous un outil similaire ?</label>
            <input type="text" id="fb-competitors" placeholder="Ex: Copy.ai, Jasper, un template Excel…" maxlength="500"/>
          </div>
        </div>
        <div class="fb-modal-foot">
          <button class="fb-btn fb-btn-cancel" onclick="document.getElementById('fb-overlay').remove()">Annuler</button>
          <button class="fb-btn fb-btn-submit" id="fb-submit-suggest" onclick="PSFeedback._submitSuggestion()">Envoyer ma proposition</button>
        </div>
      </div>`;

    document.body.appendChild(overlay);
    setTimeout(() => document.getElementById('fb-toolname')?.focus(), 50);
  }

  async function _submitSuggestion() {
    const toolName = document.getElementById('fb-toolname')?.value?.trim();
    const toolDesc = document.getElementById('fb-tooldesc')?.value?.trim();
    const vertical = document.getElementById('fb-vertical')?.value;
    if (!toolName || !toolDesc || !vertical) { alert('Veuillez remplir les champs obligatoires (nom, description, verticale).'); return; }

    const btn = document.getElementById('fb-submit-suggest');
    btn.disabled = true;
    btn.textContent = 'Envoi en cours…';

    const ok = await suggestTool({
      vertical,
      category:         document.getElementById('fb-cat')?.value?.trim() || '',
      tool_name:        toolName,
      description:      toolDesc,
      use_case:         document.getElementById('fb-usecase')?.value?.trim() || null,
      frequency:        document.getElementById('fb-freq')?.value || 'weekly',
      priority:         document.getElementById('fb-prio')?.value || 'nice_to_have',
      current_solution: document.getElementById('fb-current')?.value?.trim() || null,
      example_input:    document.getElementById('fb-exinput')?.value?.trim() || null,
      example_output:   document.getElementById('fb-exoutput')?.value?.trim() || null,
      competitors:      document.getElementById('fb-competitors')?.value?.trim() || null,
    });

    document.getElementById('fb-overlay')?.remove();
    if (ok) {
      _showToast('✅ Proposition envoyée ! Merci pour votre contribution.');
    } else {
      _showToast('❌ Erreur lors de l\'envoi. Réessayez.', true);
    }
  }

  // ── Toast helper ───────────────────────────────────────────────────────────
  function _showToast(msg, isError) {
    // Try PSTool.showToast first (if on tool page)
    if (typeof PSTool !== 'undefined' && PSTool.showToast) {
      PSTool.showToast(msg, isError ? 'error' : 'success');
      return;
    }
    // Fallback: create temporary toast
    const t = document.createElement('div');
    t.style.cssText = 'position:fixed;bottom:20px;right:20px;background:#1a1d27;border:1px solid ' + (isError ? 'rgba(239,68,68,.4)' : 'rgba(34,197,94,.4)') + ';padding:12px 20px;border-radius:10px;font-size:.85rem;z-index:99999;color:#e8eaf0;opacity:0;transition:opacity .2s;';
    t.textContent = msg;
    document.body.appendChild(t);
    requestAnimationFrame(() => t.style.opacity = '1');
    setTimeout(() => { t.style.opacity = '0'; setTimeout(() => t.remove(), 300); }, 3500);
  }

  // ── Public API ─────────────────────────────────────────────────────────────
  window.PSFeedback = {
    reportBug,
    suggestTool,
    listSuggestions,
    vote,
    unvote,
    captureContext,
    captureConsoleLogs,
    captureToolState,
    showBugModal,
    showSuggestModal,
    _submitBug,
    _submitSuggestion,
  };
})();

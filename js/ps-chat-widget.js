/**
 * ps-chat-widget.js — Floating AI assistant widget for The Prompt Studio
 *
 * Self-contained: injects its own DOM + CSS.
 * Depends on PS singleton (ps-auth.js) being loaded before this script.
 * Only renders for authenticated users with at least one active subscription.
 */
(function () {
  'use strict';

  // ── Config ──────────────────────────────────────────────────────────────────
  var API_ENDPOINT = '/api/ai-chat';
  var MAX_TURNS    = 24;

  var BOT_META = {
    immo:     { name: 'ImmoBot',     emoji: '🏠', color: '#00897b' },
    finance:  { name: 'FinBot',      emoji: '📈', color: '#c9a84c' },
    commerce: { name: 'CommerceBot', emoji: '🛒', color: '#3b82f6' },
    legal:    { name: 'JuriBot',     emoji: '⚖️', color: '#7c3aed' },
  };

  // ── State ───────────────────────────────────────────────────────────────────
  var _open      = false;
  var _sending   = false;
  var _vertical  = null;
  var _messages  = [];
  var _subs      = {};

  // ── CSS injection ────────────────────────────────────────────────────────────
  var css = `
    #ps-widget-btn{
      position:fixed;bottom:24px;right:24px;z-index:9800;
      width:52px;height:52px;border-radius:50%;border:none;
      background:#7c3aed;cursor:pointer;
      display:flex;align-items:center;justify-content:center;
      box-shadow:0 4px 24px rgba(124,58,237,0.45);
      transition:transform 0.2s,box-shadow 0.2s;
      font-size:22px;
    }
    #ps-widget-btn:hover{transform:scale(1.08);box-shadow:0 6px 32px rgba(124,58,237,0.6);}
    #ps-widget-btn .ps-w-close{display:none;font-size:20px;color:#fff;font-style:normal;}
    #ps-widget-btn.is-open .ps-w-emoji{display:none;}
    #ps-widget-btn.is-open .ps-w-close{display:block;}

    #ps-widget-panel{
      position:fixed;bottom:88px;right:24px;z-index:9800;
      width:360px;height:520px;
      background:#111009;border:1px solid #2e2a24;border-radius:16px;
      box-shadow:0 24px 64px rgba(0,0,0,0.7);
      display:none;flex-direction:column;overflow:hidden;
      font-family:'Outfit',sans-serif;
    }
    #ps-widget-panel.is-open{display:flex;}

    /* Header */
    #ps-w-header{
      display:flex;align-items:center;justify-content:space-between;
      padding:13px 16px;border-bottom:1px solid #2e2a24;
      background:#1a1814;flex-shrink:0;
    }
    #ps-w-bot-info{display:flex;align-items:center;gap:10px;}
    #ps-w-avatar{
      width:32px;height:32px;border-radius:8px;
      display:flex;align-items:center;justify-content:center;
      font-size:16px;background:rgba(124,58,237,0.15);
      border:1px solid rgba(124,58,237,0.3);
    }
    #ps-w-name{font-size:14px;font-weight:600;color:#f0ead8;}
    #ps-w-sub{font-size:11px;color:#8a8070;margin-top:1px;}
    #ps-w-actions{display:flex;align-items:center;gap:8px;}
    #ps-w-full-btn{
      background:none;border:1px solid #2e2a24;color:#8a8070;
      font-size:11px;padding:4px 10px;border-radius:6px;cursor:pointer;
      font-family:inherit;transition:all 0.15s;text-decoration:none;
      display:inline-flex;align-items:center;
    }
    #ps-w-full-btn:hover{color:#f0ead8;border-color:#8a8070;}
    #ps-w-new-btn{
      background:none;border:none;color:#8a8070;font-size:16px;
      cursor:pointer;padding:2px 4px;line-height:1;transition:color 0.15s;
    }
    #ps-w-new-btn:hover{color:#f0ead8;}

    /* Tabs (only shown if multiple verticals) */
    #ps-w-tabs{
      display:none;padding:8px 12px 0;gap:5px;flex-wrap:wrap;
      background:#1a1814;border-bottom:1px solid #2e2a24;flex-shrink:0;
    }
    #ps-w-tabs.has-tabs{display:flex;}
    .ps-w-tab{
      background:none;border:1px solid #2e2a24;color:#8a8070;
      font-size:11px;padding:4px 10px;border-radius:20px;cursor:pointer;
      font-family:inherit;transition:all 0.15s;margin-bottom:8px;
    }
    .ps-w-tab:hover{border-color:#a78bfa;color:#a78bfa;}
    .ps-w-tab.active{background:rgba(124,58,237,0.15);border-color:#7c3aed;color:#a78bfa;font-weight:600;}

    /* Messages */
    #ps-w-messages{
      flex:1;overflow-y:auto;padding:14px 12px;
      display:flex;flex-direction:column;gap:12px;
    }
    #ps-w-messages::-webkit-scrollbar{width:3px;}
    #ps-w-messages::-webkit-scrollbar-thumb{background:#2e2a24;border-radius:2px;}
    .ps-w-msg{display:flex;align-items:flex-start;gap:8px;}
    .ps-w-msg.ps-w-user{flex-direction:row-reverse;}
    .ps-w-avatar{
      width:24px;height:24px;border-radius:6px;
      display:flex;align-items:center;justify-content:center;
      font-size:13px;flex-shrink:0;margin-top:2px;
      background:rgba(124,58,237,0.12);border:1px solid rgba(124,58,237,0.2);
    }
    .ps-w-user .ps-w-avatar{
      background:rgba(201,168,76,0.1);border-color:rgba(201,168,76,0.2);
      font-size:11px;color:#c9a84c;font-weight:600;font-family:'Cormorant Garamond',serif;
    }
    .ps-w-bubble{
      background:#1a1814;border:1px solid #2e2a24;
      border-radius:4px 12px 12px 12px;
      padding:10px 13px;font-size:13px;line-height:1.6;
      color:#f0ead8;max-width:250px;word-break:break-word;
    }
    .ps-w-user .ps-w-bubble{
      background:#1e1a13;border-color:rgba(201,168,76,0.15);
      border-radius:12px 4px 12px 12px;
    }
    .ps-w-bubble strong{color:#f0ead8;}
    .ps-w-bubble em{color:#8a8070;}
    .ps-w-bubble code{background:#0c0b09;border:1px solid #2e2a24;padding:1px 4px;border-radius:3px;font-size:11px;}
    .ps-w-typing{display:flex;gap:4px;padding:10px 13px;background:#1a1814;border:1px solid #2e2a24;border-radius:4px 12px 12px 12px;width:fit-content;}
    .ps-w-typing span{width:6px;height:6px;background:#8a8070;border-radius:50%;animation:psWTyping 1.2s infinite;}
    .ps-w-typing span:nth-child(2){animation-delay:.2s;}
    .ps-w-typing span:nth-child(3){animation-delay:.4s;}
    @keyframes psWTyping{0%,80%,100%{transform:translateY(0);}40%{transform:translateY(-5px);}}

    /* Input */
    #ps-w-input-area{
      border-top:1px solid #2e2a24;padding:10px 12px;
      display:flex;align-items:flex-end;gap:8px;flex-shrink:0;
      background:#111009;
    }
    #ps-w-input{
      flex:1;background:#1a1814;border:1px solid #2e2a24;
      border-radius:10px;padding:9px 12px;color:#f0ead8;
      font-family:'Outfit',sans-serif;font-size:13px;line-height:1.4;
      resize:none;min-height:38px;max-height:100px;outline:none;
      transition:border-color 0.15s;overflow-y:auto;
    }
    #ps-w-input:focus{border-color:rgba(124,58,237,0.5);}
    #ps-w-input::placeholder{color:#8a8070;}
    #ps-w-send{
      background:#7c3aed;border:none;border-radius:8px;
      width:36px;height:36px;cursor:pointer;flex-shrink:0;
      display:flex;align-items:center;justify-content:center;
      transition:opacity 0.15s;
    }
    #ps-w-send:hover{opacity:0.85;}
    #ps-w-send:disabled{opacity:0.3;cursor:not-allowed;}
    #ps-w-send svg{width:15px;height:15px;fill:none;stroke:#fff;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}

    /* Welcome */
    .ps-w-welcome{
      background:rgba(124,58,237,0.08);border:1px solid rgba(124,58,237,0.18);
      border-radius:12px;padding:14px 15px;font-size:12px;color:#8a8070;
      line-height:1.6;
    }
    .ps-w-welcome strong{color:#f0ead8;display:block;margin-bottom:5px;font-size:13px;}

    @media(max-width:480px){
      #ps-widget-panel{width:calc(100vw - 32px);right:16px;bottom:80px;}
      #ps-widget-btn{right:16px;bottom:16px;}
    }
  `;

  function injectCSS() {
    var style = document.createElement('style');
    style.textContent = css;
    document.head.appendChild(style);
  }

  // ── DOM injection ────────────────────────────────────────────────────────────
  function injectDOM() {
    // Toggle button
    var btn = document.createElement('button');
    btn.id = 'ps-widget-btn';
    btn.title = 'Assistant IA';
    btn.innerHTML = '<em class="ps-w-emoji">✦</em><em class="ps-w-close">✕</em>';
    btn.addEventListener('click', toggleWidget);

    // Panel
    var panel = document.createElement('div');
    panel.id = 'ps-widget-panel';
    panel.innerHTML = `
      <div id="ps-w-header">
        <div id="ps-w-bot-info">
          <div id="ps-w-avatar">✦</div>
          <div>
            <div id="ps-w-name">Assistant IA</div>
            <div id="ps-w-sub">—</div>
          </div>
        </div>
        <div id="ps-w-actions">
          <a href="/assistant.html" id="ps-w-full-btn" title="Ouvrir en plein écran">⤢ Plein écran</a>
          <button id="ps-w-new-btn" onclick="(function(){var e=document.getElementById('ps-w-messages');if(e)e.innerHTML='';window._psWidgetMessages&&(window._psWidgetMessages=[]);window._psWidgetShowWelcome&&window._psWidgetShowWelcome();})()" title="Nouvelle conversation">↺</button>
        </div>
      </div>
      <div id="ps-w-tabs"></div>
      <div id="ps-w-messages"></div>
      <div id="ps-w-input-area">
        <textarea id="ps-w-input" placeholder="Votre question…" rows="1"></textarea>
        <button id="ps-w-send" disabled>
          <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
        </button>
      </div>`;

    document.body.appendChild(btn);
    document.body.appendChild(panel);
  }

  // ── Toggle ───────────────────────────────────────────────────────────────────
  function toggleWidget() {
    _open = !_open;
    document.getElementById('ps-widget-btn').classList.toggle('is-open', _open);
    document.getElementById('ps-widget-panel').classList.toggle('is-open', _open);
    if (_open) {
      setTimeout(function () { document.getElementById('ps-w-input')?.focus(); }, 100);
    }
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  function updateHeader() {
    var bot = BOT_META[_vertical] || { name: 'Studio AI', emoji: '✦', color: '#7c3aed' };
    var sub = _subs[_vertical] || {};
    var tier = sub.tier ? (sub.tier.charAt(0).toUpperCase() + sub.tier.slice(1)) : '';

    var avatar = document.getElementById('ps-w-avatar');
    if (avatar) {
      avatar.textContent = bot.emoji;
      avatar.style.background = bot.color + '22';
      avatar.style.borderColor = bot.color + '44';
    }
    var nameEl = document.getElementById('ps-w-name');
    if (nameEl) nameEl.textContent = bot.name;
    var subEl = document.getElementById('ps-w-sub');
    if (subEl) subEl.textContent = tier || '—';

    // Also update toggle button emoji
    var btnEmoji = document.querySelector('#ps-widget-btn .ps-w-emoji');
    if (btnEmoji) btnEmoji.textContent = bot.emoji;
    document.getElementById('ps-widget-btn').style.background = bot.color;
    document.getElementById('ps-widget-btn').style.boxShadow = '0 4px 24px ' + bot.color + '55';
  }

  // ── Vertical tabs ─────────────────────────────────────────────────────────────
  function renderTabs() {
    var container = document.getElementById('ps-w-tabs');
    if (!container) return;
    var verticals = Object.keys(_subs);
    if (verticals.length <= 1) return;

    container.classList.add('has-tabs');
    container.innerHTML = verticals.map(function (v) {
      var b = BOT_META[v] || { emoji: '✦', name: v };
      return '<button class="ps-w-tab' + (v === _vertical ? ' active' : '') + '" data-v="' + v + '">' + b.emoji + ' ' + b.name + '</button>';
    }).join('');

    container.querySelectorAll('.ps-w-tab').forEach(function (tab) {
      tab.addEventListener('click', function () {
        var v = this.getAttribute('data-v');
        if (v === _vertical) return;
        _vertical = v;
        _messages = [];
        updateHeader();
        container.querySelectorAll('.ps-w-tab').forEach(function (t) { t.classList.remove('active'); });
        this.classList.add('active');
        clearMessages();
        showWelcome();
      });
    });
  }

  // ── Messages ──────────────────────────────────────────────────────────────────
  function clearMessages() {
    var el = document.getElementById('ps-w-messages');
    if (el) el.innerHTML = '';
  }

  function showWelcome() {
    var bot = BOT_META[_vertical] || { name: 'Studio AI', emoji: '✦', label: _vertical };
    clearMessages();
    appendRaw('<div class="ps-w-welcome"><strong>' + bot.emoji + ' ' + bot.name + '</strong>Votre assistant IA spécialisé. Posez-moi vos questions professionnelles.</div>');
    scrollBottom();
  }

  // Store reference for the new-chat button inline handler
  window._psWidgetMessages = _messages;
  window._psWidgetShowWelcome = showWelcome;

  function appendRaw(html) {
    var el = document.getElementById('ps-w-messages');
    if (!el) return;
    var wrap = document.createElement('div');
    wrap.innerHTML = html;
    el.appendChild(wrap.firstChild || wrap);
    scrollBottom();
  }

  function appendBot(content) {
    var bot = BOT_META[_vertical] || { emoji: '✦' };
    var div = document.createElement('div');
    div.className = 'ps-w-msg';
    div.innerHTML = '<div class="ps-w-avatar">' + bot.emoji + '</div>' +
      '<div class="ps-w-bubble">' + simpleRender(content) + '</div>';
    document.getElementById('ps-w-messages').appendChild(div);
    scrollBottom();
  }

  function appendUser(content) {
    var email = (PS._session && PS._session.user && PS._session.user.email) || '?';
    var initial = email[0].toUpperCase();
    var div = document.createElement('div');
    div.className = 'ps-w-msg ps-w-user';
    div.innerHTML = '<div class="ps-w-avatar">' + initial + '</div>' +
      '<div class="ps-w-bubble">' + esc(content).replace(/\n/g, '<br>') + '</div>';
    document.getElementById('ps-w-messages').appendChild(div);
    scrollBottom();
  }

  function appendTyping() {
    var div = document.createElement('div');
    div.className = 'ps-w-msg';
    div.id = 'ps-w-typing-row';
    var bot = BOT_META[_vertical] || { emoji: '✦' };
    div.innerHTML = '<div class="ps-w-avatar">' + bot.emoji + '</div>' +
      '<div class="ps-w-typing"><span></span><span></span><span></span></div>';
    document.getElementById('ps-w-messages').appendChild(div);
    scrollBottom();
  }

  function removeTyping() {
    var el = document.getElementById('ps-w-typing-row');
    if (el) el.remove();
  }

  function scrollBottom() {
    var el = document.getElementById('ps-w-messages');
    if (el) el.scrollTop = el.scrollHeight;
  }

  // ── Send ──────────────────────────────────────────────────────────────────────
  async function send() {
    if (_sending) return;
    var input = document.getElementById('ps-w-input');
    var text  = input.value.trim();
    if (!text) return;

    input.value = '';
    input.style.height = 'auto';
    _messages.push({ role: 'user', content: text });
    appendUser(text);
    setSending(true);
    appendTyping();

    try {
      var session = await PS.getSession();
      if (!session) { removeTyping(); return setSending(false); }

      var rawText = await fetch(API_ENDPOINT, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + session.access_token },
        body:    JSON.stringify({
          vertical: _vertical,
          messages: _messages.slice(-MAX_TURNS),
        }),
      }).then(function (r) { return r.text(); });

      var data;
      try { data = JSON.parse(rawText); } catch (e) { throw new Error('Réponse serveur invalide'); }

      removeTyping();

      if (!data.reply) {
        var errObj = data.error ? tryParseJson(data.error) : null;
        appendBot(errObj
          ? (errObj.reason === 'quota_exceeded' ? '📊 Quota mensuel atteint. Revient le 1er du mois.' : '❌ ' + (errObj.message || data.error || 'Erreur'))
          : ('❌ ' + (data.error || 'Erreur inconnue')));
        _messages.pop();
        return;
      }

      _messages.push({ role: 'assistant', content: data.reply });
      appendBot(data.reply);

    } catch (e) {
      removeTyping();
      appendBot('⚠️ ' + (e.message || 'Erreur de connexion.'));
      _messages.pop();
    } finally {
      setSending(false);
    }
  }

  function setSending(v) {
    _sending = v;
    var btn   = document.getElementById('ps-w-send');
    var input = document.getElementById('ps-w-input');
    if (btn) btn.disabled = v || !(input && input.value.trim());
  }

  // ── Input setup ───────────────────────────────────────────────────────────────
  function setupInput() {
    var input   = document.getElementById('ps-w-input');
    var sendBtn = document.getElementById('ps-w-send');
    if (!input || !sendBtn) return;

    sendBtn.disabled = false;
    input.addEventListener('input', function () {
      this.style.height = 'auto';
      this.style.height = Math.min(this.scrollHeight, 100) + 'px';
      sendBtn.disabled = !this.value.trim() || _sending;
    });
    input.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send(); }
    });
    sendBtn.addEventListener('click', send);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  function esc(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }

  function tryParseJson(s) {
    try { return JSON.parse(s); } catch (_) { return null; }
  }

  // Minimal markdown for widget (smaller subset)
  function simpleRender(text) {
    var s = esc(text);
    s = s.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    s = s.replace(/`([^`\n]+)`/g, '<code>$1</code>');
    s = s.replace(/^[-•] (.+)$/gm, '› $1');
    s = s.replace(/\n\n/g, '<br><br>').replace(/\n/g, '<br>');
    return s;
  }

  // ── Entry point ───────────────────────────────────────────────────────────────
  function initWidget() {
    _subs      = PS._subsMap || {};
    var verts  = Object.keys(_subs);

    if (verts.length === 0) return; // no subscription → don't show widget

    // Don't show widget on the full assistant page (redundant)
    if (window.location.pathname === '/assistant.html') return;

    _vertical = verts[0];

    injectCSS();
    injectDOM();
    updateHeader();
    renderTabs();
    showWelcome();
    setupInput();
  }

  // Wait for PS to be ready (handles pages where ps-auth.js may load async)
  function tryInit() {
    if (typeof PS === 'undefined' || typeof PS._ready === 'undefined') {
      return setTimeout(tryInit, 300);
    }
    PS._ready.then(function () {
      // Only init for authenticated users
      PS.getSession().then(function (session) {
        if (session) initWidget();
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', tryInit);
  } else {
    tryInit();
  }

})();

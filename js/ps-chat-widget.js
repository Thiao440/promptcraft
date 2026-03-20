/**
 * ps-chat-widget.js — Floating AI chat widget (v5 — single assistant + tool redirect)
 *
 * Features:
 *   - Single "Studio AI" assistant (no per-vertical bots)
 *   - Automatically adapts answers based on user profile (vertical, country, lang)
 *   - TOOL REDIRECT: before calling API, checks if a platform tool matches the user's
 *     question and suggests it — saves credits and drives tool adoption
 *   - Multilingual UI (FR/EN/ES/PT/AR)
 *   - Country/locale-aware context sent to API for jurisdiction-specific answers
 *   - Auto-opens on dashboard first visit
 */
(function () {
  'use strict';

  var API = '/api/ai-chat';
  var MAX_TURNS = 24;
  var BOT_LOGO_URL = '/assets/images/bot-avatar.svg';
  var BOT_NAME = 'Studio AI';
  var BOT_EMOJI = '✦';
  var BOT_COLOR = '#6c63ff';

  /* ── i18n ─────────────────────────────────────────────────────────────────── */
  var CHAT_I18N = {
    minibar_teaser:    { fr: 'Posez une question…',         en: 'Ask a question…',              es: 'Haga una pregunta…',           pt: 'Faça uma pergunta…',           ar: 'اطرح سؤالاً…' },
    assistant:         { fr: 'Assistant IA',                 en: 'AI Assistant',                 es: 'Asistente IA',                 pt: 'Assistente IA',                ar: 'مساعد ذكي' },
    new_chat:          { fr: 'Nouvelle conversation',       en: 'New conversation',             es: 'Nueva conversación',           pt: 'Nova conversa',                ar: 'محادثة جديدة' },
    minimize:          { fr: 'Réduire',                     en: 'Minimize',                     es: 'Minimizar',                    pt: 'Minimizar',                    ar: 'تصغير' },
    placeholder:       { fr: 'Votre question…',             en: 'Your question…',               es: 'Su pregunta…',                 pt: 'Sua pergunta…',                ar: 'سؤالك…' },
    greeting:          { fr: 'Bonjour',                     en: 'Hello',                        es: 'Hola',                         pt: 'Olá',                          ar: 'مرحباً' },
    welcome_msg:       { fr: 'Je suis Studio AI, votre assistant. Je connais vos outils et votre secteur — posez-moi n\'importe quelle question !', en: 'I\'m Studio AI, your assistant. I know your tools and your industry — ask me anything!', es: 'Soy Studio AI, su asistente. Conozco sus herramientas y su sector — ¡pregúnteme lo que quiera!', pt: 'Sou o Studio AI, seu assistente. Conheço suas ferramentas e seu setor — pergunte o que quiser!', ar: 'أنا Studio AI، مساعدك. أعرف أدواتك وقطاعك — اسألني أي شيء!' },
    welcome_tip:       { fr: 'Je peux aussi vous rediriger vers l\'outil le plus adapté pour économiser vos crédits.', en: 'I can also redirect you to the right tool to save your credits.', es: 'También puedo redirigirle a la herramienta adecuada para ahorrar créditos.', pt: 'Também posso redirecioná-lo para a ferramenta certa para economizar créditos.', ar: 'يمكنني أيضاً توجيهك للأداة المناسبة لتوفير أرصدتك.' },
    tool_suggest_pre:  { fr: '💡 Plutôt que d\'utiliser un crédit, essayez notre outil dédié :', en: '💡 Rather than using a credit, try our dedicated tool:', es: '💡 En lugar de usar un crédito, pruebe nuestra herramienta dedicada:', pt: '💡 Em vez de usar um crédito, experimente nossa ferramenta dedicada:', ar: '💡 بدلاً من استخدام رصيد، جرّب أداتنا المخصصة:' },
    tool_suggest_open: { fr: 'Ouvrir l\'outil →',           en: 'Open tool →',                  es: 'Abrir herramienta →',          pt: 'Abrir ferramenta →',           ar: 'فتح الأداة →' },
    tool_suggest_skip: { fr: 'Répondre quand même',         en: 'Answer anyway',                es: 'Responder de todas formas',    pt: 'Responder mesmo assim',        ar: 'أجب على أي حال' },
    unlimited:         { fr: 'Illimité',                    en: 'Unlimited',                    es: 'Ilimitado',                    pt: 'Ilimitado',                    ar: 'غير محدود' },
    credits:           { fr: 'crédits',                     en: 'credits',                      es: 'créditos',                     pt: 'créditos',                     ar: 'أرصدة' },
    used:              { fr: 'utilisés',                    en: 'used',                         es: 'usados',                       pt: 'usados',                       ar: 'مستخدمة' },
    error_generic:     { fr: 'Erreur',                      en: 'Error',                        es: 'Error',                        pt: 'Erro',                         ar: 'خطأ' },
    error_invalid:     { fr: 'Réponse invalide',            en: 'Invalid response',             es: 'Respuesta inválida',           pt: 'Resposta inválida',            ar: 'استجابة غير صالحة' },
    error_connection:  { fr: 'Erreur de connexion.',        en: 'Connection error.',            es: 'Error de conexión.',           pt: 'Erro de conexão.',             ar: 'خطأ في الاتصال.' },
    error_quota:       { fr: '📊 Quota atteint. Attendez le 1er du mois ou passez à l\'offre supérieure.', en: '📊 Quota reached. Wait until the 1st of the month or upgrade your plan.', es: '📊 Cuota alcanzada. Espere al 1.° del mes o mejore su plan.', pt: '📊 Cota atingida. Aguarde o 1.° do mês ou melhore seu plano.', ar: '📊 تم بلوغ الحصة. انتظر أول الشهر أو قم بترقية خطتك.' },
    error_rate:        { fr: '⏳ Trop de messages, patientez.', en: '⏳ Too many messages, please wait.', es: '⏳ Demasiados mensajes, espere.', pt: '⏳ Muitas mensagens, aguarde.', ar: '⏳ رسائل كثيرة، يرجى الانتظار.' },
    error_no_sub:      { fr: '🔒 Abonnement requis pour le chatbot.', en: '🔒 Subscription required for chatbot.', es: '🔒 Suscripción requerida para el chatbot.', pt: '🔒 Assinatura necessária para o chatbot.', ar: '🔒 يتطلب اشتراكاً لاستخدام المحادثة.' },
  };

  function _lang() {
    return document.documentElement.getAttribute('data-lang') || 'en';
  }

  function _t(key) {
    var obj = CHAT_I18N[key];
    if (!obj) return key;
    var l = _lang();
    return obj[l] || obj.en || obj.fr || key;
  }

  /* ── State ────────────────────────────────────────────────────────────────── */
  var _open = false, _sending = false, _messages = [], _userName = '';
  var _userCountry = '', _userTimezone = '';
  var _userVerticals = [];  // subscribed verticals
  var _availableTools = []; // flat list of tools for the user's verticals

  /* ── Locale detection ────────────────────────────────────────────────────── */
  function _detectLocale() {
    _userTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone || '';
    var tz = _userTimezone.toLowerCase();
    var tzMap = {
      'europe/paris':'FR','europe/london':'GB','europe/madrid':'ES','europe/lisbon':'PT',
      'europe/berlin':'DE','europe/rome':'IT','europe/brussels':'BE','europe/zurich':'CH',
      'europe/amsterdam':'NL','europe/vienna':'AT','europe/dublin':'IE','europe/luxembourg':'LU',
      'europe/stockholm':'SE','europe/oslo':'NO','europe/copenhagen':'DK','europe/helsinki':'FI',
      'europe/warsaw':'PL','europe/prague':'CZ','europe/bucharest':'RO','europe/athens':'GR',
      'america/new_york':'US','america/chicago':'US','america/denver':'US','america/los_angeles':'US',
      'america/toronto':'CA','america/vancouver':'CA','america/montreal':'CA',
      'america/mexico_city':'MX','america/sao_paulo':'BR','america/argentina/buenos_aires':'AR',
      'america/bogota':'CO','america/lima':'PE','america/santiago':'CL',
      'africa/casablanca':'MA','africa/tunis':'TN','africa/algiers':'DZ','africa/cairo':'EG',
      'africa/lagos':'NG','africa/johannesburg':'ZA','africa/nairobi':'KE',
      'africa/dakar':'SN','africa/abidjan':'CI',
      'asia/dubai':'AE','asia/riyadh':'SA','asia/doha':'QA','asia/kuwait':'KW',
      'asia/beirut':'LB','asia/tokyo':'JP','asia/shanghai':'CN','asia/singapore':'SG',
      'asia/kolkata':'IN','asia/seoul':'KR','asia/hong_kong':'HK',
      'australia/sydney':'AU','pacific/auckland':'NZ',
    };
    _userCountry = tzMap[tz] || '';
    if (!_userCountry && navigator.language) {
      var parts = navigator.language.split('-');
      if (parts.length >= 2) _userCountry = parts[1].toUpperCase();
    }
    if (PS.profile?.country) _userCountry = PS.profile.country;
  }

  var COUNTRY_LABELS = {
    FR:'France',GB:'United Kingdom',US:'United States',CA:'Canada',DE:'Germany',
    ES:'Spain',PT:'Portugal',IT:'Italy',BE:'Belgium',CH:'Switzerland',NL:'Netherlands',
    AT:'Austria',IE:'Ireland',LU:'Luxembourg',SE:'Sweden',NO:'Norway',DK:'Denmark',
    FI:'Finland',PL:'Poland',CZ:'Czech Republic',RO:'Romania',GR:'Greece',
    MX:'Mexico',BR:'Brazil',AR:'Argentina',CO:'Colombia',PE:'Peru',CL:'Chile',
    MA:'Morocco',TN:'Tunisia',DZ:'Algeria',EG:'Egypt',NG:'Nigeria',ZA:'South Africa',
    KE:'Kenya',SN:'Senegal',CI:'Ivory Coast',
    AE:'United Arab Emirates',SA:'Saudi Arabia',QA:'Qatar',KW:'Kuwait',LB:'Lebanon',
    JP:'Japan',CN:'China',SG:'Singapore',IN:'India',KR:'South Korea',HK:'Hong Kong',
    AU:'Australia',NZ:'New Zealand',
  };

  /* ══════════════════════════════════════════════════════════════════════════
   * TOOL REDIRECT ENGINE
   * Before calling the AI API (costs credits), check if one of the user's
   * available tools matches their question. If yes, suggest the tool instead.
   * ══════════════════════════════════════════════════════════════════════════ */

  /**
   * Load the user's available tools from ToolCatalog + subscribed verticals.
   * Each tool: { slug, name, desc, icon, vertical, url }
   */
  async function _loadAvailableTools() {
    _availableTools = [];
    _userVerticals = PS.subscribedVerticals ? PS.subscribedVerticals() : [];
    if (!_userVerticals.length) return;

    try {
      var catalog = typeof ToolCatalog !== 'undefined' ? await ToolCatalog.load() : null;
      if (catalog && catalog.tools) {
        _userVerticals.forEach(function(v) {
          var tools = catalog.tools[v] || [];
          tools.forEach(function(t) {
            var url = typeof ToolCatalog.toolUrl === 'function'
              ? ToolCatalog.toolUrl(t.slug)
              : ('/tools/' + t.slug + '.html');
            _availableTools.push({
              slug: t.slug,
              name: t.name || t.label || t.slug,
              desc: t.description || t.desc || '',
              icon: t.icon || '',
              vertical: v,
              url: url,
            });
          });
        });
      }
    } catch (e) {
      console.warn('[ChatWidget] Failed to load tool catalog:', e);
    }

    console.log('[ChatWidget] Loaded', _availableTools.length, 'tools for redirect matching');
  }

  /**
   * Try to match the user's message to an available tool.
   * Uses keyword matching on tool name + description.
   * Returns the best matching tool or null.
   */
  function _matchTool(userText) {
    if (!_availableTools.length) return null;

    var query = userText.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    var bestTool = null;
    var bestScore = 0;

    _availableTools.forEach(function(tool) {
      var haystack = (tool.name + ' ' + tool.desc).toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
      var words = haystack.split(/[\s,;.()\/\-]+/).filter(function(w) { return w.length > 2; });

      var score = 0;
      words.forEach(function(word) {
        if (query.includes(word)) score += word.length;
      });

      // Also check if query words appear in tool name/desc
      var queryWords = query.split(/[\s,;.()\/\-?!]+/).filter(function(w) { return w.length > 2; });
      queryWords.forEach(function(qw) {
        if (haystack.includes(qw)) score += qw.length * 1.5;
      });

      // Require minimum relevance (at least 2 short words or 1 long word matched)
      if (score > bestScore && score >= 8) {
        bestScore = score;
        bestTool = tool;
      }
    });

    return bestTool;
  }

  /* ── CSS ──────────────────────────────────────────────────────────────────── */
  var css = `
#ps-w-minibar{
  position:fixed;bottom:24px;right:24px;z-index:9800;
  display:flex;align-items:center;gap:10px;
  background:#1a1d27;border:1px solid #2a2d3e;border-radius:28px;
  padding:6px 8px 6px 6px;cursor:pointer;
  box-shadow:0 8px 32px rgba(0,0,0,.5);
  transition:transform .2s,box-shadow .2s;
  max-width:320px;
}
#ps-w-minibar:hover{transform:translateY(-2px);box-shadow:0 12px 40px rgba(0,0,0,.6);}
#ps-w-minibar-logo{width:36px;height:36px;border-radius:50%;flex-shrink:0;object-fit:contain;background:#6c63ff22;padding:4px;}
#ps-w-minibar-text{font-size:13px;color:#7c8098;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;padding-right:8px;}
#ps-w-minibar-text strong{color:#e8eaf0;font-weight:600;}

#ps-widget-panel{
  position:fixed;bottom:24px;right:24px;z-index:9800;
  width:380px;height:520px;
  background:#0f1117;border:1px solid #2a2d3e;border-radius:16px;
  box-shadow:0 24px 64px rgba(0,0,0,.7);
  display:none;flex-direction:column;overflow:hidden;
  font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;color:#e8eaf0;font-size:13px;
}
#ps-widget-panel.is-open{display:flex;}

#ps-w-header{display:flex;align-items:center;justify-content:space-between;padding:10px 14px;border-bottom:1px solid #2a2d3e;background:#1a1d27;flex-shrink:0;}
#ps-w-bot-info{display:flex;align-items:center;gap:10px;}
#ps-w-avatar{width:32px;height:32px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0;overflow:hidden;background:#6c63ff22;border:1px solid #6c63ff44;padding:2px;}
#ps-w-avatar img{width:100%;height:100%;object-fit:contain;}
#ps-w-name{font-size:14px;font-weight:600;}
#ps-w-sub{font-size:11px;color:#7c8098;margin-top:1px;}
#ps-w-header-btns{display:flex;align-items:center;gap:6px;}
.ps-w-hbtn{background:none;border:1px solid #2a2d3e;color:#7c8098;font-size:11px;padding:4px 10px;border-radius:6px;cursor:pointer;font-family:inherit;transition:all .15s;}
.ps-w-hbtn:hover{color:#e8eaf0;border-color:#7c8098;}

/* Quota bar */
#ps-w-quota{display:none;padding:5px 14px;background:#1a1d27;border-bottom:1px solid #2a2d3e;font-size:11px;color:#7c8098;flex-shrink:0;}
#ps-w-quota.show{display:flex;align-items:center;gap:8px;}
#ps-w-quota-bar{flex:1;height:3px;background:#2a2d3e;border-radius:2px;overflow:hidden;}
#ps-w-quota-fill{height:100%;background:#6c63ff;border-radius:2px;transition:width .3s;}

#ps-w-messages{flex:1;overflow-y:auto;padding:14px 12px;display:flex;flex-direction:column;gap:12px;}
#ps-w-messages::-webkit-scrollbar{width:3px;}
#ps-w-messages::-webkit-scrollbar-thumb{background:#2a2d3e;border-radius:2px;}
.ps-w-msg{display:flex;align-items:flex-start;gap:8px;}
.ps-w-msg.ps-w-user{flex-direction:row-reverse;}
.ps-w-av{width:24px;height:24px;border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0;margin-top:2px;overflow:hidden;}
.ps-w-av img{width:100%;height:100%;object-fit:contain;}
.ps-w-user .ps-w-av{background:rgba(108,99,255,.08);border:1px solid rgba(108,99,255,.15);font-size:11px;color:#a78bfa;font-weight:600;}
.ps-w-bubble{background:#1a1d27;border:1px solid #2a2d3e;border-radius:4px 12px 12px 12px;padding:10px 13px;font-size:13px;line-height:1.6;max-width:260px;word-break:break-word;}
.ps-w-user .ps-w-bubble{background:rgba(108,99,255,.08);border-color:rgba(108,99,255,.2);border-radius:12px 4px 12px 12px;}
.ps-w-bubble strong{color:#e8eaf0;}.ps-w-bubble code{background:#0f1117;border:1px solid #2a2d3e;padding:1px 4px;border-radius:3px;font-size:11px;}
.ps-w-typing{display:flex;gap:4px;padding:10px 13px;background:#1a1d27;border:1px solid #2a2d3e;border-radius:4px 12px 12px 12px;width:fit-content;}
.ps-w-typing span{width:6px;height:6px;background:#7c8098;border-radius:50%;animation:psWTyping 1.2s infinite;}
.ps-w-typing span:nth-child(2){animation-delay:.2s;}.ps-w-typing span:nth-child(3){animation-delay:.4s;}
@keyframes psWTyping{0%,80%,100%{transform:translateY(0);}40%{transform:translateY(-5px);}}

.ps-w-welcome{background:rgba(108,99,255,.08);border:1px solid rgba(108,99,255,.18);border-radius:12px;padding:14px 15px;font-size:12px;color:#7c8098;line-height:1.6;}
.ps-w-welcome strong{color:#e8eaf0;display:block;margin-bottom:5px;font-size:13px;}

/* Tool suggestion card */
.ps-w-tool-suggest{background:rgba(108,99,255,.06);border:1px solid rgba(108,99,255,.2);border-radius:12px;padding:12px 14px;margin:0;}
.ps-w-tool-suggest .ps-w-ts-pre{font-size:12px;color:#7c8098;margin-bottom:8px;line-height:1.5;}
.ps-w-tool-suggest .ps-w-ts-card{display:flex;align-items:center;gap:10px;background:#1a1d27;border:1px solid #2a2d3e;border-radius:8px;padding:10px 12px;margin-bottom:8px;}
.ps-w-tool-suggest .ps-w-ts-icon{font-size:1.3rem;flex-shrink:0;}
.ps-w-tool-suggest .ps-w-ts-name{font-size:13px;font-weight:600;color:#e8eaf0;}
.ps-w-tool-suggest .ps-w-ts-desc{font-size:11px;color:#7c8098;margin-top:2px;}
.ps-w-tool-suggest .ps-w-ts-actions{display:flex;gap:8px;align-items:center;}
.ps-w-ts-btn{font-size:11px;padding:6px 14px;border-radius:7px;cursor:pointer;font-family:inherit;font-weight:600;border:none;transition:all .15s;}
.ps-w-ts-btn.primary{background:#6c63ff;color:#fff;}.ps-w-ts-btn.primary:hover{opacity:.85;}
.ps-w-ts-btn.ghost{background:none;color:#7c8098;border:1px solid #2a2d3e;}.ps-w-ts-btn.ghost:hover{color:#e8eaf0;border-color:#7c8098;}

#ps-w-input-area{border-top:1px solid #2a2d3e;padding:10px 12px;display:flex;align-items:flex-end;gap:8px;flex-shrink:0;background:#0f1117;}
#ps-w-input{flex:1;background:#1a1d27;border:1px solid #2a2d3e;border-radius:10px;padding:9px 12px;color:#e8eaf0;font-family:inherit;font-size:13px;line-height:1.4;resize:none;min-height:38px;max-height:100px;outline:none;transition:border-color .15s;overflow-y:auto;}
#ps-w-input:focus{border-color:rgba(108,99,255,.5);}
#ps-w-input::placeholder{color:#7c8098;}
#ps-w-send{background:#6c63ff;border:none;border-radius:8px;width:36px;height:36px;cursor:pointer;flex-shrink:0;display:flex;align-items:center;justify-content:center;transition:opacity .15s;}
#ps-w-send:hover{opacity:.85;}
#ps-w-send:disabled{opacity:.3;cursor:not-allowed;}
#ps-w-send svg{width:15px;height:15px;fill:none;stroke:#fff;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}

@media(max-width:480px){
  #ps-widget-panel{width:calc(100vw - 16px);right:8px;bottom:8px;height:80vh;border-radius:14px;}
  #ps-w-minibar{right:8px;bottom:8px;max-width:calc(100vw - 16px);}
}
  `;

  function injectCSS() { var s = document.createElement('style'); s.textContent = css; document.head.appendChild(s); }

  /* ── DOM ──────────────────────────────────────────────────────────────────── */
  function injectDOM() {
    var minibar = document.createElement('div');
    minibar.id = 'ps-w-minibar';
    minibar.innerHTML =
      '<img id="ps-w-minibar-logo" src="' + BOT_LOGO_URL + '" alt="AI">' +
      '<div id="ps-w-minibar-text"><strong>' + BOT_NAME + '</strong> — ' + _t('minibar_teaser') + '</div>';
    minibar.addEventListener('click', function() { openWidget(); });

    var panel = document.createElement('div');
    panel.id = 'ps-widget-panel';
    panel.innerHTML =
      '<div id="ps-w-header">' +
        '<div id="ps-w-bot-info">' +
          '<div id="ps-w-avatar"><img src="' + BOT_LOGO_URL + '" alt=""></div>' +
          '<div><div id="ps-w-name">' + BOT_NAME + '</div><div id="ps-w-sub">' + _t('assistant') + '</div></div>' +
        '</div>' +
        '<div id="ps-w-header-btns">' +
          '<button class="ps-w-hbtn" id="ps-w-new-btn" title="' + _t('new_chat') + '">↺</button>' +
          '<button class="ps-w-hbtn" id="ps-w-close-btn" title="' + _t('minimize') + '">✕</button>' +
        '</div>' +
      '</div>' +
      '<div id="ps-w-quota"><span id="ps-w-quota-text">—</span><div id="ps-w-quota-bar"><div id="ps-w-quota-fill" style="width:0%"></div></div></div>' +
      '<div id="ps-w-messages"></div>' +
      '<div id="ps-w-input-area">' +
        '<textarea id="ps-w-input" placeholder="' + _t('placeholder') + '" rows="1"></textarea>' +
        '<button id="ps-w-send" disabled><svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg></button>' +
      '</div>';

    document.body.appendChild(minibar);
    document.body.appendChild(panel);

    document.getElementById('ps-w-new-btn').addEventListener('click', function() { _messages = []; clearMessages(); showWelcome(); });
    document.getElementById('ps-w-close-btn').addEventListener('click', function() { closeWidget(); });
  }

  function openWidget() {
    _open = true;
    document.getElementById('ps-w-minibar').style.display = 'none';
    document.getElementById('ps-widget-panel').classList.add('is-open');
    setTimeout(function() { document.getElementById('ps-w-input')?.focus(); }, 100);
  }

  function closeWidget() {
    _open = false;
    document.getElementById('ps-widget-panel').classList.remove('is-open');
    document.getElementById('ps-w-minibar').style.display = 'flex';
  }

  /* ── Quota ───────────────────────────────────────────────────────────────── */
  function updateQuotaBar() {
    var el = document.getElementById('ps-w-quota');
    // Show quota for primary subscribed vertical
    var v = _userVerticals[0];
    if (!v) { el.classList.remove('show'); return; }
    var sub = PS.subForVertical(v);
    if (!sub) { el.classList.remove('show'); return; }
    var limit = { starter: 50, pro: 150, gold: Infinity, team: Infinity }[sub.tier] || 50;
    if (limit === Infinity) {
      document.getElementById('ps-w-quota-text').textContent = (sub.tier === 'team' ? 'Team' : 'Gold') + ' · ' + _t('unlimited');
      document.getElementById('ps-w-quota-fill').style.width = '5%';
      document.getElementById('ps-w-quota-fill').style.background = '#22c55e';
    } else {
      document.getElementById('ps-w-quota-text').textContent = '— / ' + limit + ' ' + _t('credits');
      document.getElementById('ps-w-quota-fill').style.width = '0%';
      document.getElementById('ps-w-quota-fill').style.background = '#6c63ff';
    }
    el.classList.add('show');
  }

  function updateQuotaFromResponse(data) {
    if (!data.quota) return;
    var q = data.quota;
    var txt = document.getElementById('ps-w-quota-text');
    var fill = document.getElementById('ps-w-quota-fill');
    if (q.limit === 'unlimited') {
      txt.textContent = q.used + ' ' + _t('used') + ' · ' + _t('unlimited');
      fill.style.width = '5%'; fill.style.background = '#22c55e';
    } else {
      txt.textContent = q.used + ' / ' + q.limit + ' ' + _t('credits');
      var pct = Math.min(100, Math.round((q.used / q.limit) * 100));
      fill.style.width = pct + '%';
      fill.style.background = pct > 80 ? '#ef4444' : '#6c63ff';
    }
    document.getElementById('ps-w-quota').classList.add('show');
  }

  /* ── Messages ────────────────────────────────────────────────────────────── */
  function clearMessages() { var el = document.getElementById('ps-w-messages'); if (el) el.innerHTML = ''; }

  function showWelcome() {
    clearMessages();
    var greeting = _userName ? (_t('greeting') + ' ' + esc(_userName) + ' 👋') : (_t('greeting') + ' 👋');

    appendRaw(
      '<div class="ps-w-welcome">' +
        '<strong>' + BOT_EMOJI + ' ' + greeting + '</strong>' +
        _t('welcome_msg') +
        '<br><em style="font-size:11px;opacity:.7">' + _t('welcome_tip') + '</em>' +
      '</div>'
    );
  }

  function appendRaw(html) {
    var el = document.getElementById('ps-w-messages');
    if (!el) return;
    var wrap = document.createElement('div'); wrap.innerHTML = html;
    el.appendChild(wrap.firstChild || wrap);
    scrollBottom();
  }

  function botAvatarHtml() {
    return '<div class="ps-w-av" style="background:#6c63ff22;border:1px solid #6c63ff44;padding:2px"><img src="' + BOT_LOGO_URL + '" alt=""></div>';
  }

  function appendBot(content) {
    var div = document.createElement('div'); div.className = 'ps-w-msg';
    div.innerHTML = botAvatarHtml() + '<div class="ps-w-bubble">' + simpleRender(content) + '</div>';
    document.getElementById('ps-w-messages').appendChild(div);
    scrollBottom();
  }

  function appendUser(content) {
    var initial = _userName ? _userName[0].toUpperCase() : (PS.session?.user?.email || '?')[0].toUpperCase();
    var div = document.createElement('div'); div.className = 'ps-w-msg ps-w-user';
    div.innerHTML = '<div class="ps-w-av">' + initial + '</div><div class="ps-w-bubble">' + esc(content).replace(/\n/g, '<br>') + '</div>';
    document.getElementById('ps-w-messages').appendChild(div);
    scrollBottom();
  }

  function appendTyping() {
    var div = document.createElement('div'); div.className = 'ps-w-msg'; div.id = 'ps-w-typing-row';
    div.innerHTML = botAvatarHtml() + '<div class="ps-w-typing"><span></span><span></span><span></span></div>';
    document.getElementById('ps-w-messages').appendChild(div);
    scrollBottom();
  }

  function removeTyping() { var el = document.getElementById('ps-w-typing-row'); if (el) el.remove(); }
  function scrollBottom() { var el = document.getElementById('ps-w-messages'); if (el) el.scrollTop = el.scrollHeight; }

  /**
   * Show a tool suggestion card instead of calling the API.
   * Returns a Promise — resolves with 'open' (user clicked tool) or 'skip' (user wants AI answer).
   */
  function showToolSuggestion(tool, userText) {
    return new Promise(function(resolve) {
      var suggestId = 'ps-ts-' + Date.now();
      var card = document.createElement('div');
      card.className = 'ps-w-msg';
      card.id = suggestId;
      card.innerHTML = botAvatarHtml() +
        '<div class="ps-w-tool-suggest">' +
          '<div class="ps-w-ts-pre">' + _t('tool_suggest_pre') + '</div>' +
          '<div class="ps-w-ts-card">' +
            '<span class="ps-w-ts-icon">' + (tool.icon || '🔧') + '</span>' +
            '<div>' +
              '<div class="ps-w-ts-name">' + esc(tool.name) + '</div>' +
              '<div class="ps-w-ts-desc">' + esc(tool.desc).substring(0, 80) + '</div>' +
            '</div>' +
          '</div>' +
          '<div class="ps-w-ts-actions">' +
            '<button class="ps-w-ts-btn primary" data-action="open">' + _t('tool_suggest_open') + '</button>' +
            '<button class="ps-w-ts-btn ghost" data-action="skip">' + _t('tool_suggest_skip') + '</button>' +
          '</div>' +
        '</div>';

      document.getElementById('ps-w-messages').appendChild(card);
      scrollBottom();

      card.querySelector('[data-action="open"]').addEventListener('click', function() {
        window.open(tool.url, '_blank');
        resolve('open');
      });
      card.querySelector('[data-action="skip"]').addEventListener('click', function() {
        // Remove the suggestion card and proceed with API call
        card.remove();
        resolve('skip');
      });
    });
  }

  /* ── Send ─────────────────────────────────────────────────────────────────── */
  async function send() {
    if (_sending) return;
    var input = document.getElementById('ps-w-input');
    var text = input.value.trim();
    if (!text) return;

    input.value = ''; input.style.height = 'auto';
    appendUser(text);

    // ── Tool redirect check (before API call) ──
    var matchedTool = _matchTool(text);
    if (matchedTool) {
      var action = await showToolSuggestion(matchedTool, text);
      if (action === 'open') {
        // User opened the tool — no credit consumed
        return;
      }
      // action === 'skip' → proceed with AI call below
    }

    _messages.push({ role: 'user', content: text });
    setSending(true);
    appendTyping();

    try {
      var session = PS.session;
      if (!session) { removeTyping(); setSending(false); return; }

      var localeContext = {
        lang: _lang(),
        country: _userCountry || '',
        countryLabel: COUNTRY_LABELS[_userCountry] || _userCountry || '',
        timezone: _userTimezone || '',
        verticals: _userVerticals,
      };

      var res = await fetch(API, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + session.access_token },
        body: JSON.stringify({
          vertical: _userVerticals[0] || 'free',
          messages: _messages.slice(-MAX_TURNS),
          locale: localeContext,
        }),
      });

      var data;
      try { data = await res.json(); } catch (e) { throw new Error(_t('error_invalid')); }
      removeTyping();

      if (!data.reply) {
        var err = data.error;
        var msg = (err && typeof err === 'object') ? (err.message || _t('error_generic')) : (err || _t('error_generic'));
        if (err?.code === 'QUOTA_EXCEEDED') msg = _t('error_quota');
        if (err?.code === 'RATE_LIMITED') msg = _t('error_rate');
        if (err?.code === 'NO_SUBSCRIPTION') msg = _t('error_no_sub');
        appendBot(msg);
        _messages.pop();
        return;
      }

      _messages.push({ role: 'assistant', content: data.reply });
      appendBot(data.reply);
      if (data.quota) updateQuotaFromResponse(data);
    } catch (e) {
      removeTyping();
      appendBot('⚠️ ' + (e.message || _t('error_connection')));
      _messages.pop();
    } finally {
      setSending(false);
    }
  }

  function setSending(v) {
    _sending = v;
    var btn = document.getElementById('ps-w-send');
    var input = document.getElementById('ps-w-input');
    if (btn) btn.disabled = v || !(input && input.value.trim());
  }

  function setupInput() {
    var input = document.getElementById('ps-w-input');
    var sendBtn = document.getElementById('ps-w-send');
    if (!input || !sendBtn) return;
    input.addEventListener('input', function() {
      this.style.height = 'auto';
      this.style.height = Math.min(this.scrollHeight, 100) + 'px';
      sendBtn.disabled = !this.value.trim() || _sending;
    });
    input.addEventListener('keydown', function(e) {
      if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send(); }
    });
    sendBtn.addEventListener('click', send);
  }

  function esc(s) { return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;'); }
  function simpleRender(text) {
    var s = esc(text);
    s = s.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    s = s.replace(/`([^`\n]+)`/g, '<code>$1</code>');
    s = s.replace(/^[-•] (.+)$/gm, '› $1');
    s = s.replace(/\n\n/g, '<br><br>').replace(/\n/g, '<br>');
    return s;
  }

  /* ── Refresh on language change ──────────────────────────────────────────── */
  function refreshWidgetUI() {
    var miniText = document.getElementById('ps-w-minibar-text');
    if (miniText) miniText.innerHTML = '<strong>' + BOT_NAME + '</strong> — ' + _t('minibar_teaser');
    var input = document.getElementById('ps-w-input');
    if (input) input.placeholder = _t('placeholder');
    var newBtn = document.getElementById('ps-w-new-btn');
    if (newBtn) newBtn.title = _t('new_chat');
    var closeBtn = document.getElementById('ps-w-close-btn');
    if (closeBtn) closeBtn.title = _t('minimize');
    var sub = document.getElementById('ps-w-sub');
    if (sub) sub.textContent = _t('assistant');
    if (_messages.length === 0) showWelcome();
  }

  /* ── Init ─────────────────────────────────────────────────────────────────── */
  async function initWidget() {
    if (!PS.session) return;
    if (window.location.pathname.includes('assistant')) return;
    if (window.location.pathname.includes('admin')) return;

    _userName = PS.profile?.first_name || PS.session.user.user_metadata?.first_name || '';
    _detectLocale();

    injectCSS();
    injectDOM();
    updateQuotaBar();
    showWelcome();
    setupInput();

    // Load available tools for redirect matching (async, non-blocking)
    _loadAvailableTools();

    // Listen for language changes
    if (typeof PS_I18N !== 'undefined' && PS_I18N.onChange) {
      PS_I18N.onChange(refreshWidgetUI);
    }

    // Auto-open on dashboard
    var isDashboard = window.location.pathname.includes('dashboard');
    var alreadyOpened = sessionStorage.getItem('ps_chat_opened');
    if (isDashboard && !alreadyOpened) {
      sessionStorage.setItem('ps_chat_opened', '1');
      openWidget();
    }

    console.log('[ChatWidget] v5 Ready — lang:', _lang(), 'country:', _userCountry || 'unknown', 'user:', _userName || 'anonymous');
  }

  window.addEventListener('ps:ready', function(e) {
    if (e.detail?.session) initWidget();
  });
})();

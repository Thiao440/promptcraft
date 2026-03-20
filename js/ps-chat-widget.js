/**
 * ps-chat-widget.js — Floating AI chat widget (v4 — multilingual + locale-aware)
 *
 * Features:
 *   - FREE mode (Studio AI): no credits, short answers, available to all
 *   - EXPERT mode (vertical bot): 1 credit/msg, detailed answers, requires subscription
 *   - Auto-opens on dashboard first visit
 *   - When closed: shows mini-bar with bot logo + input teaser
 *   - Personalized greeting in user's language
 *   - Country/locale-aware context sent to API for jurisdiction-specific answers
 *   - Generic robot logo for free/unsubscribed users
 */
(function () {
  'use strict';

  var API = '/api/ai-chat';
  var MAX_TURNS = 24;
  var BOT_LOGO_URL = '/assets/images/bot-avatar.svg';

  /* ── i18n for chat widget UI ─────────────────────────────────────────────── */
  var CHAT_I18N = {
    minibar_teaser:    { fr: 'Posez une question…',         en: 'Ask a question…',              es: 'Haga una pregunta…',           pt: 'Faça uma pergunta…',           ar: 'اطرح سؤالاً…' },
    free_assistant:    { fr: 'Assistant gratuit',            en: 'Free assistant',               es: 'Asistente gratuito',           pt: 'Assistente gratuito',          ar: 'مساعد مجاني' },
    expert_suffix:     { fr: ' · 1 crédit/msg',             en: ' · 1 credit/msg',              es: ' · 1 crédito/msg',             pt: ' · 1 crédito/msg',             ar: ' · 1 رصيد/رسالة' },
    new_chat:          { fr: 'Nouvelle conversation',       en: 'New conversation',             es: 'Nueva conversación',           pt: 'Nova conversa',                ar: 'محادثة جديدة' },
    minimize:          { fr: 'Réduire',                     en: 'Minimize',                     es: 'Minimizar',                    pt: 'Minimizar',                    ar: 'تصغير' },
    placeholder:       { fr: 'Votre question…',             en: 'Your question…',               es: 'Su pregunta…',                 pt: 'Sua pergunta…',                ar: 'سؤالك…' },
    greeting:          { fr: 'Bonjour',                     en: 'Hello',                        es: 'Hola',                         pt: 'Olá',                          ar: 'مرحباً' },
    i_am:              { fr: 'Je suis',                     en: 'I\'m',                         es: 'Soy',                          pt: 'Eu sou',                       ar: 'أنا' },
    how_help:          { fr: ', votre assistant IA. Comment puis-je vous aider ?', en: ', your AI assistant. How can I help you?', es: ', su asistente de IA. ¿Cómo puedo ayudarle?', pt: ', seu assistente de IA. Como posso ajudá-lo?', ar: '، مساعدك بالذكاء الاصطناعي. كيف يمكنني مساعدتك؟' },
    free_note:         { fr: 'Réponses courtes et gratuites. Pour des réponses détaillées, passez sur un assistant expert.', en: 'Short free answers. For detailed answers, switch to an expert assistant.', es: 'Respuestas cortas y gratuitas. Para respuestas detalladas, use un asistente experto.', pt: 'Respostas curtas e gratuitas. Para respostas detalhadas, use um assistente especialista.', ar: 'إجابات قصيرة ومجانية. للإجابات المفصلة، انتقل إلى مساعد متخصص.' },
    expert_note:       { fr: 'Réponses détaillées et spécialisées · 1 crédit par message', en: 'Detailed specialized answers · 1 credit per message', es: 'Respuestas detalladas y especializadas · 1 crédito por mensaje', pt: 'Respostas detalhadas e especializadas · 1 crédito por mensagem', ar: 'إجابات متخصصة ومفصلة · رصيد واحد لكل رسالة' },
    free_badge:        { fr: 'Gratuit',                     en: 'Free',                         es: 'Gratis',                       pt: 'Grátis',                       ar: 'مجاني' },
    unlimited:         { fr: 'Illimité',                    en: 'Unlimited',                    es: 'Ilimitado',                    pt: 'Ilimitado',                    ar: 'غير محدود' },
    credits:           { fr: 'crédits',                     en: 'credits',                      es: 'créditos',                     pt: 'créditos',                     ar: 'أرصدة' },
    used:              { fr: 'utilisés',                    en: 'used',                         es: 'usados',                       pt: 'usados',                       ar: 'مستخدمة' },
    upgrade_lock:      { fr: 'est disponible à partir de',  en: 'is available starting from',   es: 'está disponible a partir de',  pt: 'está disponível a partir de',  ar: 'متاح ابتداءً من' },
    view_plans:        { fr: 'Voir les offres',             en: 'View plans',                   es: 'Ver ofertas',                  pt: 'Ver ofertas',                  ar: 'عرض الخطط' },
    generic_chatbot:   { fr: 'Le chatbot IA générique',     en: 'The generic AI chatbot',       es: 'El chatbot de IA genérico',    pt: 'O chatbot de IA genérico',     ar: 'روبوت المحادثة العام' },
    specialist_chatbot:{ fr: 'Le chatbot spécialiste',      en: 'The specialist chatbot',       es: 'El chatbot especialista',      pt: 'O chatbot especialista',       ar: 'روبوت المحادثة المتخصص' },
    error_generic:     { fr: 'Erreur',                      en: 'Error',                        es: 'Error',                        pt: 'Erro',                         ar: 'خطأ' },
    error_invalid:     { fr: 'Réponse invalide',            en: 'Invalid response',             es: 'Respuesta inválida',           pt: 'Resposta inválida',            ar: 'استجابة غير صالحة' },
    error_connection:  { fr: 'Erreur de connexion.',        en: 'Connection error.',            es: 'Error de conexión.',           pt: 'Erro de conexão.',             ar: 'خطأ في الاتصال.' },
    error_quota:       { fr: '📊 Quota atteint. Repassez en mode gratuit ou attendez le 1er du mois.', en: '📊 Quota reached. Switch to free mode or wait until the 1st of the month.', es: '📊 Cuota alcanzada. Cambie al modo gratuito o espere al 1.° del mes.', pt: '📊 Cota atingida. Mude para o modo gratuito ou aguarde o 1.° do mês.', ar: '📊 تم بلوغ الحصة. انتقل للوضع المجاني أو انتظر أول الشهر.' },
    error_rate:        { fr: '⏳ Trop de messages, patientez.', en: '⏳ Too many messages, please wait.', es: '⏳ Demasiados mensajes, espere.', pt: '⏳ Muitas mensagens, aguarde.', ar: '⏳ رسائل كثيرة، يرجى الانتظار.' },
    error_no_sub:      { fr: '🔒 Abonnement requis. Utilisez Studio AI (gratuit) ou souscrivez.', en: '🔒 Subscription required. Use Studio AI (free) or subscribe.', es: '🔒 Suscripción requerida. Use Studio AI (gratis) o suscríbase.', pt: '🔒 Assinatura necessária. Use Studio AI (grátis) ou assine.', ar: '🔒 يتطلب اشتراكاً. استخدم Studio AI (مجاني) أو اشترك.' },
  };

  /** Get current language from ps-lang.js / data-lang attribute */
  function _lang() {
    return document.documentElement.getAttribute('data-lang') || 'en';
  }

  /** Translate a chat i18n key */
  function _t(key) {
    var obj = CHAT_I18N[key];
    if (!obj) return key;
    var l = _lang();
    return obj[l] || obj.en || obj.fr || key;
  }

  /* ── Bot descriptors (multilingual) ──────────────────────────────────────── */
  var BOT_META = {
    free:         { name: 'Studio AI',     emoji: '✦', color: '#6c63ff',
                    desc: { fr: 'Gratuit', en: 'Free', es: 'Gratis', pt: 'Grátis', ar: 'مجاني' } },
    immo:         { name: 'ImmoBot',       emoji: '🏠', color: '#f59e0b',
                    desc: { fr: 'Expert Immobilier', en: 'Real Estate Expert', es: 'Experto Inmobiliario', pt: 'Especialista Imobiliário', ar: 'خبير عقاري' } },
    commerce:     { name: 'CommerceBot',   emoji: '🛒', color: '#3b82f6',
                    desc: { fr: 'Expert E-Commerce', en: 'E-Commerce Expert', es: 'Experto E-Commerce', pt: 'Especialista E-Commerce', ar: 'خبير التجارة الإلكترونية' } },
    legal:        { name: 'JuriBot',       emoji: '⚖️', color: '#8b5cf6',
                    desc: { fr: 'Expert Juridique', en: 'Legal Expert', es: 'Experto Jurídico', pt: 'Especialista Jurídico', ar: 'خبير قانوني' } },
    finance:      { name: 'FinBot',        emoji: '💰', color: '#10b981',
                    desc: { fr: 'Expert Finance', en: 'Finance Expert', es: 'Experto Finanzas', pt: 'Especialista Finanças', ar: 'خبير مالي' } },
    marketing:    { name: 'MarketBot',     emoji: '📣', color: '#ec4899',
                    desc: { fr: 'Expert Marketing', en: 'Marketing Expert', es: 'Experto Marketing', pt: 'Especialista Marketing', ar: 'خبير تسويق' } },
    rh:           { name: 'RHBot',         emoji: '👥', color: '#f97316',
                    desc: { fr: 'Expert RH', en: 'HR Expert', es: 'Experto RRHH', pt: 'Especialista RH', ar: 'خبير موارد بشرية' } },
    sante:        { name: 'SantéBot',      emoji: '🏥', color: '#06b6d4',
                    desc: { fr: 'Expert Santé', en: 'Health Expert', es: 'Experto Salud', pt: 'Especialista Saúde', ar: 'خبير صحي' } },
    education:    { name: 'EduBot',        emoji: '🎓', color: '#6366f1',
                    desc: { fr: 'Expert Éducation', en: 'Education Expert', es: 'Experto Educación', pt: 'Especialista Educação', ar: 'خبير تعليم' } },
    restauration: { name: 'RestoBot',      emoji: '🍽️', color: '#ef4444',
                    desc: { fr: 'Expert Restauration', en: 'Food & Hospitality Expert', es: 'Experto Restauración', pt: 'Especialista Restauração', ar: 'خبير مطاعم' } },
    freelance:    { name: 'FreelanceBot',  emoji: '💼', color: '#84cc16',
                    desc: { fr: 'Expert Freelance', en: 'Freelance Expert', es: 'Experto Freelance', pt: 'Especialista Freelance', ar: 'خبير مستقل' } },
  };

  function _botDesc(key) {
    var bot = BOT_META[key] || BOT_META.free;
    if (typeof bot.desc === 'object') return bot.desc[_lang()] || bot.desc.en || bot.desc.fr;
    return bot.desc;
  }

  var _open = false, _sending = false, _vertical = 'free', _messages = [], _userName = '';
  var _userCountry = '', _userTimezone = '';

  /* ── Detect user locale/country ──────────────────────────────────────────── */
  function _detectLocale() {
    // Timezone → rough country mapping
    _userTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone || '';
    var tz = _userTimezone.toLowerCase();
    // Map common timezone prefixes to countries
    var tzCountryMap = {
      'europe/paris': 'FR', 'europe/london': 'GB', 'europe/madrid': 'ES', 'europe/lisbon': 'PT',
      'europe/berlin': 'DE', 'europe/rome': 'IT', 'europe/brussels': 'BE', 'europe/zurich': 'CH',
      'europe/amsterdam': 'NL', 'europe/vienna': 'AT', 'europe/dublin': 'IE', 'europe/luxembourg': 'LU',
      'europe/stockholm': 'SE', 'europe/oslo': 'NO', 'europe/copenhagen': 'DK', 'europe/helsinki': 'FI',
      'europe/warsaw': 'PL', 'europe/prague': 'CZ', 'europe/bucharest': 'RO', 'europe/athens': 'GR',
      'america/new_york': 'US', 'america/chicago': 'US', 'america/denver': 'US', 'america/los_angeles': 'US',
      'america/toronto': 'CA', 'america/vancouver': 'CA', 'america/montreal': 'CA',
      'america/mexico_city': 'MX', 'america/sao_paulo': 'BR', 'america/argentina/buenos_aires': 'AR',
      'america/bogota': 'CO', 'america/lima': 'PE', 'america/santiago': 'CL',
      'africa/casablanca': 'MA', 'africa/tunis': 'TN', 'africa/algiers': 'DZ', 'africa/cairo': 'EG',
      'africa/lagos': 'NG', 'africa/johannesburg': 'ZA', 'africa/nairobi': 'KE',
      'africa/dakar': 'SN', 'africa/abidjan': 'CI',
      'asia/dubai': 'AE', 'asia/riyadh': 'SA', 'asia/doha': 'QA', 'asia/kuwait': 'KW',
      'asia/beirut': 'LB', 'asia/tokyo': 'JP', 'asia/shanghai': 'CN', 'asia/singapore': 'SG',
      'asia/kolkata': 'IN', 'asia/seoul': 'KR', 'asia/hong_kong': 'HK',
      'australia/sydney': 'AU', 'pacific/auckland': 'NZ',
    };
    _userCountry = tzCountryMap[tz] || '';

    // Fallback: try navigator.language region
    if (!_userCountry && navigator.language) {
      var parts = navigator.language.split('-');
      if (parts.length >= 2) _userCountry = parts[1].toUpperCase();
    }

    // Also check profile country if available
    if (PS.profile?.country) _userCountry = PS.profile.country;
  }

  /** Country code → human-readable label for the AI prompt */
  var COUNTRY_LABELS = {
    FR: 'France', GB: 'United Kingdom', US: 'United States', CA: 'Canada', DE: 'Germany',
    ES: 'Spain', PT: 'Portugal', IT: 'Italy', BE: 'Belgium', CH: 'Switzerland', NL: 'Netherlands',
    AT: 'Austria', IE: 'Ireland', LU: 'Luxembourg', SE: 'Sweden', NO: 'Norway', DK: 'Denmark',
    FI: 'Finland', PL: 'Poland', CZ: 'Czech Republic', RO: 'Romania', GR: 'Greece',
    MX: 'Mexico', BR: 'Brazil', AR: 'Argentina', CO: 'Colombia', PE: 'Peru', CL: 'Chile',
    MA: 'Morocco', TN: 'Tunisia', DZ: 'Algeria', EG: 'Egypt', NG: 'Nigeria', ZA: 'South Africa',
    KE: 'Kenya', SN: 'Senegal', CI: 'Ivory Coast',
    AE: 'United Arab Emirates', SA: 'Saudi Arabia', QA: 'Qatar', KW: 'Kuwait', LB: 'Lebanon',
    JP: 'Japan', CN: 'China', SG: 'Singapore', IN: 'India', KR: 'South Korea', HK: 'Hong Kong',
    AU: 'Australia', NZ: 'New Zealand',
  };

  // ── CSS ──────────────────────────────────────────────────────────────────────
  var css = `
/* Mini-bar (when closed) */
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

/* Panel */
#ps-widget-panel{
  position:fixed;bottom:24px;right:24px;z-index:9800;
  width:380px;height:560px;
  background:#0f1117;border:1px solid #2a2d3e;border-radius:16px;
  box-shadow:0 24px 64px rgba(0,0,0,.7);
  display:none;flex-direction:column;overflow:hidden;
  font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;color:#e8eaf0;font-size:13px;
}
#ps-widget-panel.is-open{display:flex;}

#ps-w-header{display:flex;align-items:center;justify-content:space-between;padding:10px 14px;border-bottom:1px solid #2a2d3e;background:#1a1d27;flex-shrink:0;}
#ps-w-bot-info{display:flex;align-items:center;gap:10px;}
#ps-w-avatar{width:32px;height:32px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0;overflow:hidden;}
#ps-w-avatar img{width:100%;height:100%;object-fit:contain;}
#ps-w-name{font-size:14px;font-weight:600;}
#ps-w-sub{font-size:11px;color:#7c8098;margin-top:1px;}
#ps-w-header-btns{display:flex;align-items:center;gap:6px;}
.ps-w-hbtn{background:none;border:1px solid #2a2d3e;color:#7c8098;font-size:11px;padding:4px 10px;border-radius:6px;cursor:pointer;font-family:inherit;transition:all .15s;}
.ps-w-hbtn:hover{color:#e8eaf0;border-color:#7c8098;}

/* Mode tabs */
#ps-w-mode-tabs{display:flex;border-bottom:1px solid #2a2d3e;background:#1a1d27;flex-shrink:0;overflow-x:auto;-webkit-overflow-scrolling:touch;}
.ps-w-mtab{flex:0 0 auto;background:none;border:none;border-bottom:2px solid transparent;color:#7c8098;font-size:11px;padding:8px 12px;cursor:pointer;font-family:inherit;transition:all .15s;white-space:nowrap;display:flex;align-items:center;gap:4px;}
.ps-w-mtab:hover{color:#e8eaf0;}
.ps-w-mtab.active{color:#e8eaf0;border-bottom-color:var(--tab-color,#6c63ff);font-weight:600;}
.ps-w-badge{font-size:9px;padding:1px 6px;border-radius:10px;font-weight:700;text-transform:uppercase;letter-spacing:.04em;}
.ps-w-badge.free{background:rgba(34,197,94,.15);color:#22c55e;border:1px solid rgba(34,197,94,.2);}
.ps-w-badge.paid{background:rgba(108,99,255,.12);color:#a78bfa;border:1px solid rgba(108,99,255,.2);}

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

  // ── DOM ──────────────────────────────────────────────────────────────────────
  function injectDOM() {
    // Mini-bar (shown when panel is closed)
    var minibar = document.createElement('div');
    minibar.id = 'ps-w-minibar';
    minibar.innerHTML =
      '<img id="ps-w-minibar-logo" src="' + BOT_LOGO_URL + '" alt="AI Assistant">' +
      '<div id="ps-w-minibar-text"><strong>Studio AI</strong> — ' + _t('minibar_teaser') + '</div>';
    minibar.addEventListener('click', function() { openWidget(); });

    // Panel
    var panel = document.createElement('div');
    panel.id = 'ps-widget-panel';
    panel.innerHTML =
      '<div id="ps-w-header">' +
        '<div id="ps-w-bot-info">' +
          '<div id="ps-w-avatar"><img src="' + BOT_LOGO_URL + '" alt=""></div>' +
          '<div><div id="ps-w-name">Studio AI</div><div id="ps-w-sub">' + _t('free_assistant') + '</div></div>' +
        '</div>' +
        '<div id="ps-w-header-btns">' +
          '<button class="ps-w-hbtn" id="ps-w-new-btn" title="' + _t('new_chat') + '">↺</button>' +
          '<button class="ps-w-hbtn" id="ps-w-close-btn" title="' + _t('minimize') + '">✕</button>' +
        '</div>' +
      '</div>' +
      '<div id="ps-w-mode-tabs"></div>' +
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

  // ── Header ──────────────────────────────────────────────────────────────────
  function updateHeader() {
    var bot = BOT_META[_vertical] || BOT_META.free;
    var isFree = (_vertical === 'free');
    var avatar = document.getElementById('ps-w-avatar');

    if (isFree) {
      avatar.innerHTML = '<img src="' + BOT_LOGO_URL + '" alt="">';
      avatar.style.background = '#6c63ff22';
      avatar.style.border = '1px solid #6c63ff44';
    } else {
      avatar.innerHTML = bot.emoji;
      avatar.style.background = bot.color + '22';
      avatar.style.border = '1px solid ' + bot.color + '44';
      avatar.style.fontSize = '16px';
    }

    document.getElementById('ps-w-name').textContent = bot.name;
    document.getElementById('ps-w-sub').textContent = isFree
      ? _t('free_assistant')
      : _botDesc(_vertical) + _t('expert_suffix');
    updateQuotaBar();
  }

  function renderTabs() {
    var container = document.getElementById('ps-w-mode-tabs');
    var verts = PS.subscribedVerticals();

    // Check feature gates
    var canGeneric    = PS.canAccessFeature ? PS.canAccessFeature('chatbot_generic').allowed : true;
    var canSpecialist = function(v) { return PS.canAccessFeature ? PS.canAccessFeature('chatbot_specialist', v).allowed : true; };

    var freeBadge = canGeneric ? _t('free_badge') : '🔒 Pro';
    var tabs = '<button class="ps-w-mtab' + (canGeneric ? ' active' : '') + '" data-v="free" style="--tab-color:#6c63ff">'
      + '✦ Studio AI <span class="ps-w-badge free">' + freeBadge + '</span></button>';
    verts.forEach(function(v) {
      var b = BOT_META[v] || { emoji: '?', name: v, color: '#6c63ff' };
      var locked = !canSpecialist(v);
      tabs += '<button class="ps-w-mtab' + (locked ? ' locked' : '') + '" data-v="' + v + '" style="--tab-color:' + b.color + '">'
        + b.emoji + ' ' + b.name + ' <span class="ps-w-badge paid">' + (locked ? '🔒 Pro' : 'Pro') + '</span></button>';
    });
    container.innerHTML = tabs;

    // Default to free if generic is accessible, otherwise show first tab
    if (canGeneric) {
      _vertical = 'free';
    }

    container.querySelectorAll('.ps-w-mtab').forEach(function(tab) {
      tab.addEventListener('click', function() {
        var v = this.getAttribute('data-v');
        if (v === _vertical) return;

        // Check gate when switching
        if (v === 'free' && !canGeneric) {
          _showChatUpgrade(_t('generic_chatbot'), 'Pro');
          return;
        }
        if (v !== 'free' && !canSpecialist(v)) {
          _showChatUpgrade(_t('specialist_chatbot'), 'Pro');
          return;
        }

        _vertical = v;
        _messages = [];
        container.querySelectorAll('.ps-w-mtab').forEach(function(t) { t.classList.remove('active'); });
        this.classList.add('active');
        updateHeader();
        clearMessages();
        showWelcome();
      });
    });
  }

  function _showChatUpgrade(featureName, requiredTier) {
    var body = document.getElementById('ps-w-messages');
    if (!body) return;
    body.innerHTML = '<div style="text-align:center;padding:32px 16px;color:#7c8098;font-size:.85rem;">'
      + '<div style="font-size:2rem;margin-bottom:12px">🔒</div>'
      + '<strong style="color:#e8eaf0">' + featureName + ' ' + _t('upgrade_lock') + ' ' + requiredTier + '</strong><br><br>'
      + '<a href="/tarifs.html" style="background:#6c63ff;color:#fff;padding:8px 18px;border-radius:8px;text-decoration:none;font-weight:600;font-size:.82rem">' + _t('view_plans') + ' →</a>'
      + '</div>';
  }

  function updateQuotaBar() {
    var el = document.getElementById('ps-w-quota');
    if (_vertical === 'free') { el.classList.remove('show'); return; }
    var sub = PS.subForVertical(_vertical);
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
    if (!data.quota || _vertical === 'free') return;
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

  // ── Messages ────────────────────────────────────────────────────────────────
  function clearMessages() { var el = document.getElementById('ps-w-messages'); if (el) el.innerHTML = ''; }

  function showWelcome() {
    var bot = BOT_META[_vertical] || BOT_META.free;
    var isFree = (_vertical === 'free');
    clearMessages();

    var greetWord = _t('greeting');
    var greeting = _userName ? (greetWord + ' ' + esc(_userName) + ' 👋') : (greetWord + ' 👋');
    var extra = isFree
      ? '<br><em style="font-size:11px;opacity:.7">' + _t('free_note') + '</em>'
      : '<br><em style="font-size:11px;opacity:.7">' + _t('expert_note') + '</em>';

    appendRaw(
      '<div class="ps-w-welcome">' +
        '<strong>' + bot.emoji + ' ' + greeting + '</strong>' +
        _t('i_am') + ' ' + bot.name + _t('how_help') +
        extra +
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
    var bot = BOT_META[_vertical] || BOT_META.free;
    if (_vertical === 'free') {
      return '<div class="ps-w-av" style="background:#6c63ff22;border:1px solid #6c63ff44;padding:2px"><img src="' + BOT_LOGO_URL + '" alt=""></div>';
    }
    return '<div class="ps-w-av" style="background:' + bot.color + '22;border:1px solid ' + bot.color + '44">' + bot.emoji + '</div>';
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

  // ── Send ────────────────────────────────────────────────────────────────────
  async function send() {
    if (_sending) return;
    var input = document.getElementById('ps-w-input');
    var text = input.value.trim();
    if (!text) return;

    // Feature gate check before sending
    if (PS.canAccessFeature) {
      var featureName = _vertical === 'free' ? 'chatbot_generic' : 'chatbot_specialist';
      var access = PS.canAccessFeature(featureName, _vertical === 'free' ? undefined : _vertical);
      if (!access.allowed) {
        _showChatUpgrade(featureName === 'chatbot_generic' ? _t('generic_chatbot') : _t('specialist_chatbot'), 'Pro');
        return;
      }
    }

    input.value = ''; input.style.height = 'auto';
    _messages.push({ role: 'user', content: text });
    appendUser(text);
    setSending(true);
    appendTyping();

    try {
      var session = PS.session;
      if (!session) { removeTyping(); setSending(false); return; }

      /*
       * Build the locale context sent to the API.
       * The API uses this to:
       *   1. Reply in the user's language
       *   2. Adapt answers to the user's jurisdiction (e.g. UK law vs French law)
       *   3. Use relevant local regulations, standards, and terminology
       */
      var localeContext = {
        lang: _lang(),
        country: _userCountry || '',
        countryLabel: COUNTRY_LABELS[_userCountry] || _userCountry || '',
        timezone: _userTimezone || '',
      };

      var res = await fetch(API, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + session.access_token },
        body: JSON.stringify({
          vertical: _vertical,
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

  // ── Refresh UI on language change ───────────────────────────────────────────
  function refreshWidgetUI() {
    // Update minibar text
    var miniText = document.getElementById('ps-w-minibar-text');
    if (miniText) miniText.innerHTML = '<strong>Studio AI</strong> — ' + _t('minibar_teaser');

    // Update input placeholder
    var input = document.getElementById('ps-w-input');
    if (input) input.placeholder = _t('placeholder');

    // Update button titles
    var newBtn = document.getElementById('ps-w-new-btn');
    if (newBtn) newBtn.title = _t('new_chat');
    var closeBtn = document.getElementById('ps-w-close-btn');
    if (closeBtn) closeBtn.title = _t('minimize');

    // Update header
    updateHeader();

    // Re-render tabs with translated badges
    renderTabs();

    // Re-show welcome in new language
    if (_messages.length === 0) showWelcome();
  }

  // ── Init ────────────────────────────────────────────────────────────────────
  function initWidget() {
    if (!PS.session) return;
    if (window.location.pathname.includes('assistant')) return;
    if (window.location.pathname.includes('admin')) return;

    // Get user first name for personalized greeting
    _userName = PS.profile?.first_name || PS.session.user.user_metadata?.first_name || '';

    // Detect user locale/country for jurisdiction-aware answers
    _detectLocale();

    _vertical = 'free';
    injectCSS();
    injectDOM();
    updateHeader();
    renderTabs();
    showWelcome();
    setupInput();

    // Listen for language changes from ps-lang.js
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

    console.log('[ChatWidget] Ready — lang:', _lang(), 'country:', _userCountry || 'unknown', 'user:', _userName || 'anonymous');
  }

  // Listen for ps:ready event from ps-auth.js (guaranteed profile is loaded)
  window.addEventListener('ps:ready', function(e) {
    if (e.detail?.session) initWidget();
  });
})();

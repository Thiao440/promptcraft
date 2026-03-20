/**
 * ps-launch-banner.js — Pre-launch countdown banner
 *
 * Auto-injects a premium countdown banner at the top of the page.
 * Set LAUNCH_DATE to the go-live date. Banner auto-removes after launch.
 * Remove this script from pages once live.
 */
(function() {
  'use strict';

  // ─── CONFIG ───
  const LAUNCH_DATE = new Date('2026-03-23T09:00:00+01:00'); // Lundi 23 mars 2026, 9h CET
  const now = new Date();
  if (now >= LAUNCH_DATE) return; // Already launched — don't show banner

  // ─── i18n ───
  const lang = (document.documentElement.getAttribute('data-lang') || localStorage.getItem('ps_lang') || 'fr');
  const T = {
    fr: {
      pre: 'Lancement officiel',
      title: 'dans',
      days: 'j', hours: 'h', mins: 'min', secs: 's',
      cta: 'Me notifier au lancement',
      email: 'votre@email.com',
      sent: 'Vous serez notifié !',
      sub: '10 verticales · 100 outils IA · Accès instantané'
    },
    en: {
      pre: 'Official launch',
      title: 'in',
      days: 'd', hours: 'h', mins: 'min', secs: 's',
      cta: 'Notify me at launch',
      email: 'your@email.com',
      sent: 'You\'ll be notified!',
      sub: '10 verticals · 100 AI tools · Instant access'
    },
    es: {
      pre: 'Lanzamiento oficial',
      title: 'en',
      days: 'd', hours: 'h', mins: 'min', secs: 's',
      cta: 'Notificarme al lanzamiento',
      email: 'tu@email.com',
      sent: '¡Serás notificado!',
      sub: '10 verticales · 100 herramientas IA · Acceso instantáneo'
    },
    pt: {
      pre: 'Lançamento oficial',
      title: 'em',
      days: 'd', hours: 'h', mins: 'min', secs: 's',
      cta: 'Me notifique no lançamento',
      email: 'seu@email.com',
      sent: 'Você será notificado!',
      sub: '10 verticais · 100 ferramentas IA · Acesso instantâneo'
    },
    ar: {
      pre: 'الإطلاق الرسمي',
      title: 'خلال',
      days: 'ي', hours: 'س', mins: 'د', secs: 'ث',
      cta: 'أعلمني عند الإطلاق',
      email: 'بريدك@الإلكتروني',
      sent: 'سيتم إعلامك!',
      sub: '10 قطاعات · 100 أداة ذكاء اصطناعي · وصول فوري'
    }
  };
  const t = T[lang] || T.fr;
  const isRtl = lang === 'ar';

  // ─── STYLES ───
  const style = document.createElement('style');
  style.textContent = `
    .ps-launch{position:fixed;top:0;left:0;right:0;z-index:10000;background:linear-gradient(135deg,#1a1814 0%,#0c0b09 50%,#1a1814 100%);border-bottom:1px solid #2e2a24;padding:0;font-family:'Outfit',sans-serif;transform:translateY(-100%);animation:psLaunchSlide .6s ease .3s forwards;box-shadow:0 4px 24px rgba(0,0,0,.4);}
    @keyframes psLaunchSlide{to{transform:translateY(0);}}
    .ps-launch-inner{max-width:1100px;margin:0 auto;padding:14px 24px;display:flex;align-items:center;justify-content:center;gap:20px;flex-wrap:wrap;${isRtl ? 'direction:rtl;' : ''}}
    .ps-launch-pre{font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:#c9a84c;font-weight:600;}
    .ps-launch-countdown{display:flex;align-items:center;gap:6px;}
    .ps-launch-unit{display:flex;flex-direction:column;align-items:center;min-width:44px;}
    .ps-launch-num{font-size:24px;font-weight:700;color:#f0ead8;font-variant-numeric:tabular-nums;line-height:1;}
    .ps-launch-label{font-size:9px;letter-spacing:.12em;text-transform:uppercase;color:#8a8070;margin-top:2px;}
    .ps-launch-sep{font-size:20px;color:#2e2a24;margin-top:-6px;}
    .ps-launch-form{display:flex;gap:8px;align-items:center;}
    .ps-launch-input{background:#111009;border:1px solid #2e2a24;color:#f0ead8;font-family:'Outfit',sans-serif;font-size:13px;padding:8px 14px;border-radius:6px;outline:none;width:210px;transition:border-color .2s;}
    .ps-launch-input:focus{border-color:#c9a84c;}
    .ps-launch-input::placeholder{color:#5a5040;}
    .ps-launch-btn{background:#c9a84c;color:#0c0b09;font-family:'Outfit',sans-serif;font-size:12px;font-weight:700;letter-spacing:.04em;padding:9px 16px;border:none;cursor:pointer;border-radius:6px;white-space:nowrap;transition:background .2s;}
    .ps-launch-btn:hover{background:#e8c97a;}
    .ps-launch-btn.sent{background:#00897b;color:#fff;cursor:default;}
    .ps-launch-sub{font-size:11px;color:#5a5040;text-align:center;width:100%;}
    .ps-launch-close{position:absolute;top:8px;${isRtl ? 'left' : 'right'}:12px;background:none;border:none;color:#5a5040;font-size:16px;cursor:pointer;padding:4px 8px;transition:color .2s;}
    .ps-launch-close:hover{color:#f0ead8;}
    .ps-launch-dot{width:6px;height:6px;border-radius:50%;background:#22c55e;animation:psDotPulse 2s infinite;}
    @keyframes psDotPulse{0%,100%{opacity:1;}50%{opacity:.3;}}
    @media(max-width:768px){
      .ps-launch-inner{padding:12px 16px;gap:12px;}
      .ps-launch-num{font-size:18px;}
      .ps-launch-unit{min-width:36px;}
      .ps-launch-input{width:160px;font-size:12px;padding:7px 10px;}
      .ps-launch-btn{font-size:11px;padding:8px 12px;}
      .ps-launch-form{flex-wrap:wrap;justify-content:center;}
    }
    @media(max-width:480px){
      .ps-launch-input{width:100%;min-width:0;}
      .ps-launch-form{width:100%;}
    }
    body.ps-has-banner{padding-top:calc(var(--nav-h, 60px) + 80px) !important;}
    body.ps-has-banner .ps-nav{top:80px !important;}
  `;
  document.head.appendChild(style);

  // ─── DOM ───
  const banner = document.createElement('div');
  banner.className = 'ps-launch';
  banner.innerHTML = `
    <div class="ps-launch-inner">
      <span class="ps-launch-dot"></span>
      <span class="ps-launch-pre">${t.pre} ${t.title}</span>
      <div class="ps-launch-countdown">
        <div class="ps-launch-unit"><span class="ps-launch-num" id="ps-cd-d">--</span><span class="ps-launch-label">${t.days}</span></div>
        <span class="ps-launch-sep">:</span>
        <div class="ps-launch-unit"><span class="ps-launch-num" id="ps-cd-h">--</span><span class="ps-launch-label">${t.hours}</span></div>
        <span class="ps-launch-sep">:</span>
        <div class="ps-launch-unit"><span class="ps-launch-num" id="ps-cd-m">--</span><span class="ps-launch-label">${t.mins}</span></div>
        <span class="ps-launch-sep">:</span>
        <div class="ps-launch-unit"><span class="ps-launch-num" id="ps-cd-s">--</span><span class="ps-launch-label">${t.secs}</span></div>
      </div>
      <div class="ps-launch-form">
        <input type="email" class="ps-launch-input" id="ps-launch-email" placeholder="${t.email}" autocomplete="email">
        <button class="ps-launch-btn" id="ps-launch-cta">${t.cta}</button>
      </div>
    </div>
    <button class="ps-launch-close" id="ps-launch-close" aria-label="Close">&times;</button>
  `;
  document.body.prepend(banner);
  document.body.classList.add('ps-has-banner');

  // ─── COUNTDOWN ───
  function updateCountdown() {
    const diff = LAUNCH_DATE - new Date();
    if (diff <= 0) {
      banner.remove();
      document.body.classList.remove('ps-has-banner');
      return;
    }
    const d = Math.floor(diff / 86400000);
    const h = Math.floor((diff % 86400000) / 3600000);
    const m = Math.floor((diff % 3600000) / 60000);
    const s = Math.floor((diff % 60000) / 1000);
    document.getElementById('ps-cd-d').textContent = String(d).padStart(2, '0');
    document.getElementById('ps-cd-h').textContent = String(h).padStart(2, '0');
    document.getElementById('ps-cd-m').textContent = String(m).padStart(2, '0');
    document.getElementById('ps-cd-s').textContent = String(s).padStart(2, '0');
  }
  updateCountdown();
  setInterval(updateCountdown, 1000);

  // ─── EMAIL CAPTURE ───
  document.getElementById('ps-launch-cta').addEventListener('click', function() {
    const input = document.getElementById('ps-launch-email');
    const email = input.value.trim();
    if (!email || !email.includes('@')) { input.style.borderColor = '#e53e3e'; return; }
    input.style.borderColor = '#2e2a24';

    // Store locally (will be synced to Supabase when ready)
    const stored = JSON.parse(localStorage.getItem('ps_launch_emails') || '[]');
    if (!stored.includes(email)) { stored.push(email); localStorage.setItem('ps_launch_emails', JSON.stringify(stored)); }

    // Try Supabase if available
    if (typeof supabase !== 'undefined' && supabase.from) {
      supabase.from('launch_subscribers').insert({ email: email }).then(function(){});
    }

    this.textContent = t.sent;
    this.classList.add('sent');
    input.disabled = true;
  });

  // ─── CLOSE ───
  document.getElementById('ps-launch-close').addEventListener('click', function() {
    banner.style.animation = 'none';
    banner.style.transform = 'translateY(-100%)';
    banner.style.transition = 'transform .3s ease';
    setTimeout(function() {
      banner.remove();
      document.body.classList.remove('ps-has-banner');
    }, 300);
    sessionStorage.setItem('ps_banner_closed', '1');
  });

  // Don't show if already closed this session
  if (sessionStorage.getItem('ps_banner_closed')) {
    banner.remove();
    document.body.classList.remove('ps-has-banner');
  }
})();

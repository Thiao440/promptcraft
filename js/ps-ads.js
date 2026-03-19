/**
 * ps-ads.js — Ad display system for The Prompt Studio
 *
 * Rules:
 *   - Ads shown ONLY to Starter tier users who are NOT in trial period
 *   - Pro / Gold / Team = no ads ever
 *   - Trial users = no ads (full premium experience during trial)
 *   - Not logged in = no ads
 *
 * Supports:
 *   - Banner ads (top of content, between sections)
 *   - Sidebar ads (in tool pages)
 *   - Interstitial ads (after N generations — non-blocking)
 *   - Ad provider integration ready (Google AdSense, custom, or internal upsell)
 *
 * Usage:
 *   PSAds.injectBanner('container-id')   — inject a banner ad into a container
 *   PSAds.injectSidebar('container-id')  — inject a sidebar ad
 *   PSAds.maybeShowInterstitial()        — show interstitial after generation (rate-limited)
 *   PSAds.injectAllSlots()               — auto-inject into all [data-ad-slot] elements
 */
(function () {
  'use strict';

  // ── Config ─────────────────────────────────────────────────────────────────
  var INTERSTITIAL_EVERY = 3;       // Show interstitial every N generations
  var _genCount = 0;

  // Preview mode: force-show ads for specific emails (for testing/demo)
  // Remove emails from this list to disable preview
  var PREVIEW_EMAILS = ['mathieu.thiao@gmail.com'];

  // Ad mix: 'mixed' = rotate between upsell + external partner ads
  // Options: 'internal' (upsell only), 'external' (partner only), 'mixed' (both)
  var AD_MODE = 'mixed';

  // ── Internal upsell creatives ──────────────────────────────────────────────
  var UPSELL_ADS = [
    {
      type: 'upsell',
      title: 'Passez à Pro — sans publicité',
      text: 'Débloquez les chatbots IA, l\'export PDF et 150 générations/mois.',
      cta: 'Upgrade →',
      href: '/tarifs.html',
      color: '#a78bfa',
    },
    {
      type: 'upsell',
      title: 'Essayez Gold — CRM intégré',
      text: 'Gérez vos projets, accédez aux 10 outils, générations illimitées.',
      cta: 'Découvrir Gold →',
      href: '/tarifs.html',
      color: '#c9a84c',
    },
    {
      type: 'upsell',
      title: '0 pub, 100% productivité',
      text: 'Les offres Pro et Gold suppriment toute publicité.',
      cta: 'Voir les offres →',
      href: '/tarifs.html',
      color: '#6c63ff',
    },
    {
      type: 'upsell',
      title: '💡 Vous utilisez souvent cet outil ?',
      text: 'Avec Pro, accédez à 7 outils avancés et au chatbot IA spécialiste.',
      cta: 'Passer à Pro →',
      href: '/tarifs.html',
      color: '#ec4899',
    },
  ];

  // ── External partner ads (affiliate / free tier partnerships) ──────────────
  // These are real products with affiliate programs or free to promote.
  // Replace href with your affiliate links when available.
  var PARTNER_ADS = [
    {
      type: 'partner',
      title: '⚡ Automatisez avec Make',
      text: 'Connectez vos outils et automatisez vos workflows — 1000 opérations gratuites/mois.',
      cta: 'Essayer Make →',
      href: 'https://www.make.com/en/register?utm_source=theprompt.studio',
      color: '#6d28d9',
      logo: '⚡',
    },
    {
      type: 'partner',
      title: '📧 Email pro avec Brevo',
      text: 'Envoyez 300 emails/jour gratuitement. Parfait pour vos campagnes.',
      cta: 'Créer un compte →',
      href: 'https://www.brevo.com/?utm_source=theprompt.studio',
      color: '#0b4dda',
      logo: '📧',
    },
    {
      type: 'partner',
      title: '🎨 Créez vos visuels avec Canva',
      text: 'Complétez vos contenus IA avec des visuels professionnels gratuits.',
      cta: 'Commencer gratis →',
      href: 'https://www.canva.com/?utm_source=theprompt.studio',
      color: '#00c4cc',
      logo: '🎨',
    },
    {
      type: 'partner',
      title: '📊 CRM gratuit avec HubSpot',
      text: 'Gérez vos contacts et prospects avec le CRM gratuit le plus populaire.',
      cta: 'Essayer HubSpot →',
      href: 'https://www.hubspot.com/products/crm?utm_source=theprompt.studio',
      color: '#ff7a59',
      logo: '📊',
    },
    {
      type: 'partner',
      title: '📝 Notion pour votre équipe',
      text: 'Centralisez vos docs, wikis et projets. Gratuit pour les petites équipes.',
      cta: 'Découvrir Notion →',
      href: 'https://www.notion.so/?utm_source=theprompt.studio',
      color: '#000000',
      logo: '📝',
    },
    {
      type: 'partner',
      title: '🔒 Mots de passe sécurisés — Bitwarden',
      text: 'Gestionnaire de mots de passe open source et gratuit pour votre équipe.',
      cta: 'Sécuriser mes accès →',
      href: 'https://bitwarden.com/?utm_source=theprompt.studio',
      color: '#175ddc',
      logo: '🔒',
    },
  ];

  // ── Pick a random ad based on mode ─────────────────────────────────────────
  function _pickAd() {
    if (AD_MODE === 'internal') return UPSELL_ADS[Math.floor(Math.random() * UPSELL_ADS.length)];
    if (AD_MODE === 'external') return PARTNER_ADS[Math.floor(Math.random() * PARTNER_ADS.length)];
    // mixed: 40% upsell, 60% partner
    var pool = Math.random() < 0.4 ? UPSELL_ADS : PARTNER_ADS;
    return pool[Math.floor(Math.random() * pool.length)];
  }

  // ── Should we show ads? ────────────────────────────────────────────────────
  function _shouldShow() {
    // Preview mode: force-show for test emails
    if (typeof PS !== 'undefined' && PS.session) {
      var email = PS.session.user?.email || '';
      if (PREVIEW_EMAILS.indexOf(email) !== -1) return true;
    }
    return typeof PS !== 'undefined' && PS.shouldShowAds && PS.shouldShowAds();
  }

  // ── Render helpers ─────────────────────────────────────────────────────────

  /** Generate a banner ad HTML (upsell or partner) */
  function _renderBanner(size) {
    var ad = _pickAd();
    var isPartner = ad.type === 'partner';
    var target = isPartner ? ' target="_blank" rel="noopener sponsored"' : '';
    var logoHtml = ad.logo ? '<span class="ps-ad-logo">' + ad.logo + '</span>' : '';
    return '<div class="ps-ad ps-ad-banner' + (isPartner ? ' ps-ad-partner' : '') + '" style="--ad-color:' + ad.color + '">'
      + '<div class="ps-ad-ribbon">PUBLICITÉ</div>'
      + '<div class="ps-ad-body">'
      + logoHtml
      + '<div class="ps-ad-content">'
      + '<div class="ps-ad-title">' + ad.title + '</div>'
      + '<div class="ps-ad-text">' + ad.text + '</div>'
      + '</div>'
      + '<a href="' + ad.href + '" class="ps-ad-cta"' + target + '>' + ad.cta + '</a>'
      + '</div>'
      + '<button class="ps-ad-close" onclick="this.closest(\'.ps-ad\').remove()" title="Fermer">✕</button>'
      + '</div>';
  }

  /** Generate AdSense slot HTML (placeholder — replace with real slot IDs) */
  function _renderAdsenseBanner(slotId, format) {
    return '<div class="ps-ad ps-ad-adsense">'
      + '<ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-XXXXXXXXXXXXXXXX" '
      + 'data-ad-slot="' + (slotId || '0000000000') + '" '
      + 'data-ad-format="' + (format || 'auto') + '" data-full-width-responsive="true"></ins>'
      + '<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>'
      + '</div>';
  }

  // ── CSS injection ──────────────────────────────────────────────────────────
  function _injectCSS() {
    if (document.getElementById('ps-ads-css')) return;
    var style = document.createElement('style');
    style.id = 'ps-ads-css';
    style.textContent = [
      /* Container */
      '.ps-ad { border: 1px solid rgba(108,99,255,.2); border-radius: 12px; background: linear-gradient(135deg, rgba(108,99,255,.06) 0%, rgba(108,99,255,.02) 100%); position: relative; overflow: hidden; margin: 16px 0; }',
      '.ps-ad-partner { background: linear-gradient(135deg, rgba(255,255,255,.04) 0%, rgba(255,255,255,.01) 100%); border-color: rgba(255,255,255,.1); }',

      /* Ribbon "PUBLICITÉ" */
      '.ps-ad-ribbon { background: rgba(108,99,255,.15); color: #7c8098; font-size: .6rem; font-weight: 800; letter-spacing: .14em; text-transform: uppercase; text-align: center; padding: 5px 0; border-bottom: 1px solid rgba(108,99,255,.1); }',
      '.ps-ad-partner .ps-ad-ribbon { background: rgba(255,255,255,.05); border-color: rgba(255,255,255,.06); }',

      /* Body (below ribbon) */
      '.ps-ad-body { display: flex; align-items: center; gap: 16px; padding: 18px 22px; }',
      '.ps-ad-banner { display: block; }',

      /* Logo */
      '.ps-ad-logo { font-size: 2.2rem; flex-shrink: 0; width: 48px; height: 48px; display: flex; align-items: center; justify-content: center; background: rgba(255,255,255,.04); border-radius: 10px; }',

      /* Content */
      '.ps-ad-content { flex: 1; min-width: 0; }',
      '.ps-ad-title { font-size: .95rem; font-weight: 700; color: var(--ad-color, #a78bfa); margin-bottom: 4px; line-height: 1.3; }',
      '.ps-ad-text { font-size: .82rem; color: #8a8da8; line-height: 1.5; }',

      /* CTA button */
      '.ps-ad-cta { flex-shrink: 0; padding: 10px 20px; border-radius: 8px; background: var(--ad-color, #6c63ff); color: #fff; font-size: .82rem; font-weight: 700; text-decoration: none; white-space: nowrap; transition: all .18s; box-shadow: 0 2px 8px rgba(0,0,0,.2); }',
      '.ps-ad-cta:hover { opacity: .88; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,.3); }',

      /* Close button */
      '.ps-ad-close { position: absolute; top: 3px; right: 8px; background: none; border: none; color: #7c8098; font-size: .72rem; cursor: pointer; opacity: .4; padding: 2px 4px; transition: opacity .15s; }',
      '.ps-ad-close:hover { opacity: 1; }',

      /* Sidebar variant */
      '.ps-ad-sidebar { text-align: center; }',
      '.ps-ad-sidebar .ps-ad-body { flex-direction: column; align-items: center; gap: 10px; padding: 20px; }',
      '.ps-ad-sidebar .ps-ad-logo { width: 56px; height: 56px; font-size: 2.5rem; }',
      '.ps-ad-sidebar .ps-ad-title { margin-bottom: 6px; }',
      '.ps-ad-sidebar .ps-ad-cta { margin-top: 4px; }',
      '.ps-ad-interstitial-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.5); z-index: 99998; display: flex; align-items: center; justify-content: center; }',
      '.ps-ad-interstitial { background: #1a1d27; border: 1px solid #2a2d3e; border-radius: 16px; padding: 32px; max-width: 420px; width: 90%; text-align: center; }',
      '.ps-ad-interstitial .ps-ad-title { font-size: 1.1rem; margin-bottom: 10px; }',
      '.ps-ad-interstitial .ps-ad-text { margin-bottom: 16px; }',
      '.ps-ad-interstitial .ps-ad-cta { padding: 10px 24px; font-size: .9rem; }',
      '.ps-ad-interstitial .ps-ad-skip { display: block; margin-top: 12px; background: none; border: none; color: #7c8098; font-size: .78rem; cursor: pointer; }',
      /* Interstitial */
      '.ps-ad-interstitial-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.6); z-index: 99998; display: flex; align-items: center; justify-content: center; padding: 20px; }',
      '.ps-ad-interstitial { background: #1a1d27; border: 1px solid #2a2d3e; border-radius: 16px; max-width: 460px; width: 90%; text-align: center; overflow: hidden; }',
      '.ps-ad-interstitial .ps-ad-ribbon { padding: 8px 0; font-size: .65rem; }',
      '.ps-ad-interstitial .ps-ad-inner { padding: 28px 32px; }',
      '.ps-ad-interstitial .ps-ad-logo { font-size: 3rem; margin-bottom: 12px; display: block; width: auto; height: auto; background: none; }',
      '.ps-ad-interstitial .ps-ad-title { font-size: 1.15rem; margin-bottom: 10px; }',
      '.ps-ad-interstitial .ps-ad-text { margin-bottom: 20px; font-size: .88rem; }',
      '.ps-ad-interstitial .ps-ad-cta { padding: 12px 28px; font-size: .92rem; display: inline-block; }',
      '.ps-ad-interstitial .ps-ad-skip { display: block; margin-top: 14px; background: none; border: none; color: #7c8098; font-size: .78rem; cursor: pointer; transition: color .15s; }',
      '.ps-ad-interstitial .ps-ad-skip:hover { color: #e8eaf0; }',

      /* Responsive */
      '@media(max-width:600px) { .ps-ad-body { flex-direction: column; text-align: center; gap: 10px; } .ps-ad-logo { margin: 0 auto; } }',
    ].join('\n');
    document.head.appendChild(style);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /** Inject a banner ad into a container element */
  function injectBanner(containerId, size) {
    if (!_shouldShow()) return;
    _injectCSS();
    var el = document.getElementById(containerId);
    if (!el) return;
    el.insertAdjacentHTML('beforeend', _renderBanner(size || 'normal'));
  }

  /** Inject a sidebar ad */
  function injectSidebar(containerId) {
    if (!_shouldShow()) return;
    _injectCSS();
    var el = document.getElementById(containerId);
    if (!el) return;
    var ad = _pickAd();
    var isPartner = ad.type === 'partner';
    var target = isPartner ? ' target="_blank" rel="noopener sponsored"' : '';
    el.insertAdjacentHTML('beforeend',
      '<div class="ps-ad ps-ad-sidebar' + (isPartner ? ' ps-ad-partner' : '') + '" style="--ad-color:' + ad.color + '">'
      + '<div class="ps-ad-ribbon">PUBLICITÉ</div>'
      + '<div class="ps-ad-body">'
      + (ad.logo ? '<span class="ps-ad-logo">' + ad.logo + '</span>' : '')
      + '<div class="ps-ad-content">'
      + '<div class="ps-ad-title">' + ad.title + '</div>'
      + '<div class="ps-ad-text">' + ad.text + '</div>'
      + '</div>'
      + '<a href="' + ad.href + '" class="ps-ad-cta"' + target + '>' + ad.cta + '</a>'
      + '</div>'
      + '<button class="ps-ad-close" onclick="this.closest(\'.ps-ad\').remove()" title="Fermer">✕</button>'
      + '</div>'
    );
  }

  /** Show interstitial ad (after N generations) — non-blocking, skippable */
  function maybeShowInterstitial() {
    if (!_shouldShow()) return;
    _genCount++;
    if (_genCount % INTERSTITIAL_EVERY !== 0) return;

    _injectCSS();
    var ad = _pickAd();
    var isPartner = ad.type === 'partner';
    var target = isPartner ? ' target="_blank" rel="noopener sponsored"' : '';
    var overlay = document.createElement('div');
    overlay.className = 'ps-ad-interstitial-overlay';
    overlay.innerHTML =
      '<div class="ps-ad-interstitial" style="--ad-color:' + ad.color + '">'
      + '<div class="ps-ad-ribbon">PUBLICITÉ</div>'
      + '<div class="ps-ad-inner">'
      + (ad.logo ? '<span class="ps-ad-logo">' + ad.logo + '</span>' : '')
      + '<div class="ps-ad-title">' + ad.title + '</div>'
      + '<div class="ps-ad-text">' + ad.text + '</div>'
      + '<a href="' + ad.href + '" class="ps-ad-cta"' + target + '>' + ad.cta + '</a>'
      + '<button class="ps-ad-skip" onclick="this.closest(\'.ps-ad-interstitial-overlay\').remove()">Continuer sans publicité ›</button>'
      + '</div>'
      + '</div>';
    document.body.appendChild(overlay);

    // Auto-close after 8 seconds
    setTimeout(function () { if (overlay.parentNode) overlay.remove(); }, 8000);

    // Track
    if (typeof PSAnalytics !== 'undefined') PSAnalytics.track('ad_shown', { type: 'interstitial', ad_title: ad.title });
  }

  /** Auto-inject into all elements with data-ad-slot attribute */
  function injectAllSlots() {
    if (!_shouldShow()) return;
    _injectCSS();
    document.querySelectorAll('[data-ad-slot]').forEach(function (el) {
      if (el.querySelector('.ps-ad')) return; // Already injected
      var type = el.getAttribute('data-ad-slot');
      if (type === 'sidebar') injectSidebar(el.id);
      else injectBanner(el.id, el.getAttribute('data-ad-size') || 'normal');
    });
  }

  /**
   * Show a welcome interstitial on dashboard open (once per session).
   * Skippable, auto-closes after 10s. Only for Starter / preview users.
   */
  function showWelcomeInterstitial() {
    if (!_shouldShow()) return;
    // Only show once per browser session
    var KEY = 'ps_ad_welcome_shown';
    try { if (sessionStorage.getItem(KEY)) return; } catch (_) {}

    _injectCSS();
    var ad = _pickAd();
    var isPartner = ad.type === 'partner';
    var target = isPartner ? ' target="_blank" rel="noopener sponsored"' : '';

    var overlay = document.createElement('div');
    overlay.className = 'ps-ad-interstitial-overlay';
    overlay.innerHTML =
      '<div class="ps-ad-interstitial" style="--ad-color:' + ad.color + '">'
      + '<div class="ps-ad-ribbon">PUBLICITÉ</div>'
      + '<div class="ps-ad-inner">'
      + (ad.logo ? '<span class="ps-ad-logo">' + ad.logo + '</span>' : '')
      + '<div class="ps-ad-title">' + ad.title + '</div>'
      + '<div class="ps-ad-text">' + ad.text + '</div>'
      + '<a href="' + ad.href + '" class="ps-ad-cta"' + target + '>' + ad.cta + '</a>'
      + '<button class="ps-ad-skip" onclick="this.closest(\'.ps-ad-interstitial-overlay\').remove()">Accéder à mon espace ›</button>'
      + '</div>'
      + '</div>';
    document.body.appendChild(overlay);

    try { sessionStorage.setItem(KEY, '1'); } catch (_) {}
    setTimeout(function () { if (overlay.parentNode) overlay.remove(); }, 10000);
    if (typeof PSAnalytics !== 'undefined') PSAnalytics.track('ad_shown', { type: 'welcome_interstitial', ad_title: ad.title });
  }

  // ── Auto-init: inject slots after PS is ready ──────────────────────────────
  window.addEventListener('ps:ready', function () {
    setTimeout(injectAllSlots, 500);
  });

  window.PSAds = {
    injectBanner: injectBanner,
    injectSidebar: injectSidebar,
    maybeShowInterstitial: maybeShowInterstitial,
    showWelcomeInterstitial: showWelcomeInterstitial,
    injectAllSlots: injectAllSlots,
  };
})();

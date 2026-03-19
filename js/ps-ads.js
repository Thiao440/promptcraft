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

  // Ad provider mode: 'internal' (upsell banners) or 'adsense' (Google AdSense)
  // Switch to 'adsense' when you have an approved AdSense account
  var AD_MODE = 'internal';

  // ── Internal upsell ad creatives ───────────────────────────────────────────
  var UPSELL_ADS = [
    {
      title: 'Passez à Pro — sans publicité',
      text: 'Débloquez les chatbots IA, l\'export PDF et 150 générations/mois.',
      cta: 'Upgrade →',
      href: '/tarifs.html',
      color: '#a78bfa',
    },
    {
      title: 'Essayez Gold — CRM intégré',
      text: 'Gérez vos projets, accédez aux 10 outils, générations illimitées.',
      cta: 'Découvrir Gold →',
      href: '/tarifs.html',
      color: '#c9a84c',
    },
    {
      title: '0 pub, 100% productivité',
      text: 'Les offres Pro et Gold suppriment toute publicité. Concentrez-vous sur l\'essentiel.',
      cta: 'Voir les offres →',
      href: '/tarifs.html',
      color: '#6c63ff',
    },
    {
      title: '💡 Vous utilisez souvent cet outil ?',
      text: 'Avec Pro, accédez à 7 outils avancés et au chatbot IA spécialiste de votre métier.',
      cta: 'Passer à Pro →',
      href: '/tarifs.html',
      color: '#ec4899',
    },
  ];

  function _randomUpsell() {
    return UPSELL_ADS[Math.floor(Math.random() * UPSELL_ADS.length)];
  }

  // ── Should we show ads? ────────────────────────────────────────────────────
  function _shouldShow() {
    return typeof PS !== 'undefined' && PS.shouldShowAds && PS.shouldShowAds();
  }

  // ── Render helpers ─────────────────────────────────────────────────────────

  /** Generate internal upsell banner HTML */
  function _renderInternalBanner(size) {
    var ad = _randomUpsell();
    var isSmall = size === 'small';
    return '<div class="ps-ad ps-ad-banner' + (isSmall ? ' ps-ad-sm' : '') + '" style="--ad-color:' + ad.color + '">'
      + '<div class="ps-ad-content">'
      + '<div class="ps-ad-title">' + ad.title + '</div>'
      + (isSmall ? '' : '<div class="ps-ad-text">' + ad.text + '</div>')
      + '</div>'
      + '<a href="' + ad.href + '" class="ps-ad-cta">' + ad.cta + '</a>'
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
      '.ps-ad { border: 1px solid rgba(108,99,255,.15); border-radius: 10px; background: rgba(108,99,255,.04); position: relative; overflow: hidden; }',
      '.ps-ad-banner { display: flex; align-items: center; gap: 14px; padding: 12px 18px; margin: 12px 0; }',
      '.ps-ad-sm { padding: 8px 14px; }',
      '.ps-ad-content { flex: 1; min-width: 0; }',
      '.ps-ad-title { font-size: .85rem; font-weight: 700; color: var(--ad-color, #a78bfa); margin-bottom: 2px; }',
      '.ps-ad-sm .ps-ad-title { font-size: .78rem; margin: 0; }',
      '.ps-ad-text { font-size: .78rem; color: #7c8098; line-height: 1.4; }',
      '.ps-ad-cta { flex-shrink: 0; padding: 6px 14px; border-radius: 7px; background: var(--ad-color, #6c63ff); color: #fff; font-size: .78rem; font-weight: 600; text-decoration: none; white-space: nowrap; transition: opacity .15s; }',
      '.ps-ad-cta:hover { opacity: .85; }',
      '.ps-ad-close { position: absolute; top: 4px; right: 6px; background: none; border: none; color: #7c8098; font-size: .7rem; cursor: pointer; opacity: .5; padding: 2px 4px; }',
      '.ps-ad-close:hover { opacity: 1; }',
      '.ps-ad-sidebar { padding: 14px; margin: 14px 0; text-align: center; }',
      '.ps-ad-sidebar .ps-ad-title { margin-bottom: 6px; }',
      '.ps-ad-sidebar .ps-ad-cta { display: inline-block; margin-top: 8px; }',
      '.ps-ad-interstitial-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.5); z-index: 99998; display: flex; align-items: center; justify-content: center; }',
      '.ps-ad-interstitial { background: #1a1d27; border: 1px solid #2a2d3e; border-radius: 16px; padding: 32px; max-width: 420px; width: 90%; text-align: center; }',
      '.ps-ad-interstitial .ps-ad-title { font-size: 1.1rem; margin-bottom: 10px; }',
      '.ps-ad-interstitial .ps-ad-text { margin-bottom: 16px; }',
      '.ps-ad-interstitial .ps-ad-cta { padding: 10px 24px; font-size: .9rem; }',
      '.ps-ad-interstitial .ps-ad-skip { display: block; margin-top: 12px; background: none; border: none; color: #7c8098; font-size: .78rem; cursor: pointer; }',
      '.ps-ad-label { font-size: .6rem; color: #7c8098; opacity: .5; text-transform: uppercase; letter-spacing: .08em; position: absolute; top: 4px; left: 8px; }',
      '@media(max-width:600px) { .ps-ad-banner { flex-direction: column; text-align: center; gap: 8px; } }',
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
    var html = AD_MODE === 'adsense' ? _renderAdsenseBanner(null, 'auto') : _renderInternalBanner(size || 'normal');
    el.insertAdjacentHTML('beforeend', '<div class="ps-ad-label">Publicité</div>' + html);
  }

  /** Inject a sidebar ad */
  function injectSidebar(containerId) {
    if (!_shouldShow()) return;
    _injectCSS();
    var el = document.getElementById(containerId);
    if (!el) return;
    var ad = _randomUpsell();
    el.insertAdjacentHTML('beforeend',
      '<div class="ps-ad ps-ad-sidebar" style="--ad-color:' + ad.color + '">'
      + '<div class="ps-ad-label">Publicité</div>'
      + '<div class="ps-ad-title">' + ad.title + '</div>'
      + '<div class="ps-ad-text">' + ad.text + '</div>'
      + '<a href="' + ad.href + '" class="ps-ad-cta">' + ad.cta + '</a>'
      + '</div>'
    );
  }

  /** Show interstitial ad (after N generations) — non-blocking, skippable */
  function maybeShowInterstitial() {
    if (!_shouldShow()) return;
    _genCount++;
    if (_genCount % INTERSTITIAL_EVERY !== 0) return;

    _injectCSS();
    var ad = _randomUpsell();
    var overlay = document.createElement('div');
    overlay.className = 'ps-ad-interstitial-overlay';
    overlay.innerHTML =
      '<div class="ps-ad-interstitial" style="--ad-color:' + ad.color + '">'
      + '<div class="ps-ad-title">' + ad.title + '</div>'
      + '<div class="ps-ad-text">' + ad.text + '</div>'
      + '<a href="' + ad.href + '" class="ps-ad-cta">' + ad.cta + '</a>'
      + '<button class="ps-ad-skip" onclick="this.closest(\'.ps-ad-interstitial-overlay\').remove()">Continuer sans upgrade ›</button>'
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

  // ── Auto-init: inject slots after PS is ready ──────────────────────────────
  window.addEventListener('ps:ready', function () {
    setTimeout(injectAllSlots, 500); // Small delay to let page render
  });

  window.PSAds = {
    injectBanner: injectBanner,
    injectSidebar: injectSidebar,
    maybeShowInterstitial: maybeShowInterstitial,
    injectAllSlots: injectAllSlots,
  };
})();

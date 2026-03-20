/**
 * ps-lang.js — Shared language system for The Prompt Studio
 *
 * Include this script on EVERY page (before ps-i18n.js). It will:
 *   1. Inject CSS rules to show/hide [data-XX] elements based on <html data-lang>
 *   2. Restore the saved language from localStorage
 *   3. Expose a global setLang(lang) function for the nav switcher
 *   4. Notify PS_I18N callbacks on language change (for JS-rendered content re-renders)
 *
 * Default language: EN (best for global SEO)
 * Supported: fr, en, es, pt, ar
 * HTML pattern:  <span data-fr>Texte</span><span data-en>Text</span>
 * Active lang:   <html lang="en" data-lang="en">
 */
(function () {
  'use strict';

  var DEFAULT_LANG = 'en';
  var LANGS = ['fr', 'en', 'es', 'pt', 'ar'];
  var FLAGS = { fr: '🇫🇷', en: '🇬🇧', es: '🇪🇸', pt: '🇧🇷', ar: '🇸🇦' };

  // ── 1. Inject CSS (idempotent) ───────────────────────────────────────────
  if (!document.getElementById('ps-lang-css')) {
    var css = '';
    // Hide all lang variants by default
    css += '[data-fr],[data-en],[data-es],[data-pt],[data-ar]{display:none;}';
    // Show the active language (block-level)
    LANGS.forEach(function (l) {
      css += '[data-lang="' + l + '"] [data-' + l + ']{display:revert;}';
    });
    // Inline spans — show as inline
    css += 'span[data-fr],span[data-en],span[data-es],span[data-pt],span[data-ar]{display:none;}';
    LANGS.forEach(function (l) {
      css += '[data-lang="' + l + '"] span[data-' + l + ']{display:inline;}';
    });

    var style = document.createElement('style');
    style.id = 'ps-lang-css';
    style.textContent = css;
    document.head.appendChild(style);
  }

  // ── 2. setLang — global function ─────────────────────────────────────────
  window.setLang = function setLang(lang) {
    if (LANGS.indexOf(lang) === -1) return;

    var prev = document.documentElement.getAttribute('data-lang');

    // Update <html> attributes
    document.documentElement.setAttribute('data-lang', lang);
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';

    // Update the nav flag button (if present)
    var btn = document.getElementById('lang-current');
    if (btn) btn.textContent = FLAGS[lang] + ' \u25be';

    // Update aria-current on language options (if present)
    document.querySelectorAll('.ps-lang-opt').forEach(function (o) {
      var fn = o.getAttribute('onclick') || '';
      o.setAttribute('aria-current', fn.indexOf("'" + lang + "'") !== -1 ? 'true' : 'false');
    });

    // Persist to localStorage
    try { localStorage.setItem('ps_lang', lang); } catch (e) { }

    // Notify PS_I18N callbacks (for re-rendering JS-generated content)
    if (prev !== lang && typeof PS_I18N !== 'undefined' && PS_I18N._notifyChange) {
      PS_I18N._notifyChange(lang);
    }
  };

  // ── 3. Restore saved language on load ────────────────────────────────────
  try {
    var saved = localStorage.getItem('ps_lang');
    if (saved && LANGS.indexOf(saved) !== -1) {
      window.setLang(saved);
    } else {
      // Set default language (EN for global SEO)
      var current = document.documentElement.getAttribute('data-lang');
      if (!current || LANGS.indexOf(current) === -1) {
        document.documentElement.setAttribute('data-lang', DEFAULT_LANG);
        document.documentElement.lang = DEFAULT_LANG;
      }
    }
  } catch (e) { }
})();

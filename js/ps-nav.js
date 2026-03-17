/**
 * ps-nav.js — Prompt Studio shared navigation module
 *
 * Dynamically injects dropdown navigation with all verticals from PS.VERTICALS
 * and updates account link based on user session state
 */

const PSNav = (() => {
  function init() {
    // Inject dropdown items
    const dropdown = document.querySelector('.ps-dd');
    if (dropdown) {
      Object.entries(PS.VERTICALS).forEach(([key, vertical]) => {
        const item = document.createElement('a');
        item.href = `/tarifs.html?v=${key}`;
        item.className = 'ps-dd-row';
        item.innerHTML = `<span>${vertical.icon} ${vertical.label}</span><span class="ps-badge-live">Live</span>`;
        dropdown.appendChild(item);
      });
    }

    // Update account link based on session
    updateAccountLink();
  }

  function updateAccountLink() {
    const accountLink = document.querySelector('.ps-account-link');
    if (!accountLink) return;

    if (PS.session) {
      const email = PS.session.user?.email || 'Account';
      accountLink.textContent = email;
      accountLink.href = '/account.html';
    } else {
      accountLink.textContent = 'Login';
      accountLink.href = '/login.html';
    }
  }

  // Auto-run on DOMContentLoaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  return { init, updateAccountLink };
})();

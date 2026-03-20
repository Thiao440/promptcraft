/**
 * tool-catalog.js — Loads tool metadata from Supabase for the dashboard
 *
 * Replaces the hardcoded ALL_TOOLS constant with a DB-driven catalog.
 * Falls back gracefully to the hardcoded list if the DB query fails.
 *
 * Usage in dashboard.html:
 *   const catalog = await ToolCatalog.load();
 *   // catalog.tools   → { immo: [...], commerce: [...], ... }
 *   // catalog.source  → 'db' | 'fallback'
 *
 * Each tool object matches the shape expected by dashboard rendering:
 *   { slug, icon, name, desc, tier, featured }
 *
 * Badge logic (computed dynamically):
 *   - "Populaire" → top 20% by usage_count within its vertical (min 1 use)
 *
 * Tool links:
 *   ToolCatalog.toolUrl(slug)  → '/t/immo-annonce' (dynamic) or '/tools/immo-annonce.html' (static)
 *   Tools with input_schema use the dynamic page; tools without use the static page.
 */

const ToolCatalog = (() => {

  let _cache = null;
  // Set of slugs that have input_schema (can use dynamic page)
  let _dynamicSlugs = new Set();

  const CACHE_KEY = 'ps_tool_catalog';
  const CACHE_TTL = 5 * 60 * 1000; // 5 minutes in milliseconds

  /**
   * Load and parse localStorage cache if valid
   * Returns { tools, dynamicSlugs, cachedAt } or null
   */
  function _loadFromStorage() {
    try {
      const stored = localStorage.getItem(CACHE_KEY);
      if (!stored) return null;

      const parsed = JSON.parse(stored);
      const age = Date.now() - parsed.cachedAt;

      if (age < CACHE_TTL) {
        console.log(`[ToolCatalog] Using valid localStorage cache (${Math.round(age / 1000)}s old)`);
        return parsed;
      }

      console.log(`[ToolCatalog] localStorage cache expired (${Math.round(age / 1000)}s old)`);
      return null;
    } catch (e) {
      console.warn('[ToolCatalog] Failed to parse localStorage cache:', e);
      return null;
    }
  }

  /**
   * Save cache to localStorage with timestamp
   */
  function _saveToStorage(tools, dynamicSlugs) {
    try {
      const toStore = {
        tools,
        dynamicSlugs: Array.from(dynamicSlugs),
        cachedAt: Date.now(),
      };
      localStorage.setItem(CACHE_KEY, JSON.stringify(toStore));
    } catch (e) {
      console.warn('[ToolCatalog] Failed to save to localStorage:', e);
    }
  }

  /**
   * Load tools from Supabase, grouped by vertical.
   * Returns { tools: { vertical: [...] }, source: 'db' | 'cache' | 'fallback' }
   *
   * Strategy:
   *   1. If in-memory cache exists, return it
   *   2. Check localStorage cache validity
   *      - If valid and online, use it (avoid DB hit)
   *      - If valid but offline, use it
   *      - If expired but offline, use it anyway (better than nothing)
   *   3. If online and cache invalid/missing, fetch from DB
   *   4. If offline and no cache, fallback
   */
  async function load() {
    if (_cache) return _cache;

    // Try localStorage cache first
    const storedCache = _loadFromStorage();
    if (storedCache) {
      _dynamicSlugs = new Set(storedCache.dynamicSlugs);
      _cache = { tools: storedCache.tools, source: 'cache' };
      return _cache;
    }

    // Check if online before attempting DB fetch
    if (!navigator.onLine) {
      console.warn('[ToolCatalog] Offline and no valid cache available, using fallback');
      return _fallback();
    }

    try {
      const { data, error } = await PS.supabase
        .from('tools')
        .select('slug, label, description, icon, vertical, min_tier, sort_order, input_schema, created_at, usage_count')
        .eq('is_active', true)
        .order('sort_order', { ascending: true });

      if (error || !data || data.length === 0) {
        console.warn('[ToolCatalog] DB query failed or empty, using fallback:', error?.message);
        return _fallback();
      }

      // ── Compute dynamic badges ──
      // "Populaire" = top 20% by usage_count per vertical
      const usageByVertical = {};
      data.forEach(row => {
        if (!usageByVertical[row.vertical]) usageByVertical[row.vertical] = [];
        usageByVertical[row.vertical].push(row.usage_count || 0);
      });
      const popularThresholds = {};
      Object.entries(usageByVertical).forEach(([v, counts]) => {
        const sorted = [...counts].sort((a, b) => b - a);
        const idx = Math.max(0, Math.ceil(sorted.length * 0.2) - 1);
        popularThresholds[v] = sorted[idx] || 1; // min threshold of 1 to avoid flagging 0-usage tools
      });

      // Group by vertical
      const tools = {};
      data.forEach(row => {
        if (!tools[row.vertical]) tools[row.vertical] = [];

        // Track which slugs have input_schema
        if (row.input_schema && row.input_schema.fields && row.input_schema.fields.length > 0) {
          _dynamicSlugs.add(row.slug);
        }

        const usage     = row.usage_count || 0;
        const threshold = popularThresholds[row.vertical] || 1;
        const featured  = usage >= threshold && usage > 0;

        tools[row.vertical].push({
          slug:     row.slug,
          icon:     row.icon || '🔧',
          name:     row.label || row.slug,
          desc:     row.description || '',
          tier:     row.min_tier || 'starter',
          featured,
        });
      });

      // Save to localStorage
      _saveToStorage(tools, _dynamicSlugs);

      _cache = { tools, source: 'db' };
      console.log(`[ToolCatalog] Loaded ${data.length} tools from DB`);
      return _cache;

    } catch (e) {
      console.warn('[ToolCatalog] Unexpected error, using fallback:', e);
      return _fallback();
    }
  }

  /**
   * Get the URL for a tool page.
   * ALL tools now route through /tool.html?slug=xxx (dynamic page).
   * tool.html handles missing input_schema with a generic fallback form.
   */
  function toolUrl(slug) {
    return `/tool.html?slug=${slug}`;
  }

  /**
   * Check if a tool uses the dynamic renderer (has input_schema with fields)
   */
  function isDynamic(slug) {
    return _dynamicSlugs.has(slug);
  }

  /**
   * Fallback: return null so dashboard keeps using ALL_TOOLS
   */
  function _fallback() {
    _cache = { tools: null, source: 'fallback' };
    return _cache;
  }

  /**
   * Clear cache (e.g., after admin edits tools)
   * Clears both in-memory and localStorage caches
   */
  function clearCache() {
    _cache = null;
    _dynamicSlugs.clear();
    try {
      localStorage.removeItem(CACHE_KEY);
      console.log('[ToolCatalog] Cleared all caches (memory and localStorage)');
    } catch (e) {
      console.warn('[ToolCatalog] Failed to clear localStorage:', e);
    }
  }

  return { load, toolUrl, isDynamic, clearCache };

})();

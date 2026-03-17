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
 *   { slug, icon, name, desc, tier, featured, isNew }
 *
 * Tool links:
 *   ToolCatalog.toolUrl(slug)  → '/t/immo-annonce' (dynamic) or '/tools/immo-annonce.html' (static)
 *   Tools with input_schema use the dynamic page; tools without use the static page.
 */

const ToolCatalog = (() => {

  let _cache = null;
  // Set of slugs that have input_schema (can use dynamic page)
  let _dynamicSlugs = new Set();

  /**
   * Load tools from Supabase, grouped by vertical.
   * Returns { tools: { vertical: [...] }, source: 'db' | 'fallback' }
   */
  async function load() {
    if (_cache) return _cache;

    try {
      const { data, error } = await PS.supabase
        .from('tools')
        .select('slug, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, input_schema')
        .eq('is_active', true)
        .order('sort_order', { ascending: true });

      if (error || !data || data.length === 0) {
        console.warn('[ToolCatalog] DB query failed or empty, using fallback:', error?.message);
        return _fallback();
      }

      // Group by vertical
      const tools = {};
      data.forEach(row => {
        if (!tools[row.vertical]) tools[row.vertical] = [];

        // Track which slugs have input_schema
        if (row.input_schema && row.input_schema.fields && row.input_schema.fields.length > 0) {
          _dynamicSlugs.add(row.slug);
        }

        tools[row.vertical].push({
          slug:     row.slug,
          icon:     row.icon || '🔧',
          name:     row.label || row.slug,
          desc:     row.description || '',
          tier:     row.min_tier || 'bronze',
          featured: row.is_featured || false,
          isNew:    row.is_new || false,
        });
      });

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
   * Tools with input_schema → /t/slug (dynamic page)
   * Tools without           → /tools/slug.html (static page)
   */
  function toolUrl(slug) {
    if (_dynamicSlugs.has(slug)) {
      return `/t/${slug}`;
    }
    return `/tools/${slug}.html`;
  }

  /**
   * Check if a tool uses the dynamic renderer
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
   */
  function clearCache() {
    _cache = null;
    _dynamicSlugs.clear();
  }

  return { load, toolUrl, isDynamic, clearCache };

})();

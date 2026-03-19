/**
 * ps-projects.js — CRM Projects module for The Prompt Studio
 *
 * Provides CRUD operations for projects and integration with tools.
 * Depends on: ps-auth.js (PS global), supabase
 */
(function () {
  'use strict';

  const sb = () => PS.supabase;

  // ── Cache ──────────────────────────────────────────────────────────────────
  let _fieldTemplatesCache = {};   // vertical → fields[]
  let _toolMappingsCache   = {};   // vertical → { toolSlug → { projectField → toolField } }

  // ── Field Templates ────────────────────────────────────────────────────────
  async function loadFieldTemplates(vertical) {
    if (_fieldTemplatesCache[vertical]) return _fieldTemplatesCache[vertical];
    const { data, error } = await sb()
      .from('project_field_templates')
      .select('*')
      .eq('vertical', vertical)
      .order('sort_order');
    if (error) { console.warn('[projects] loadFieldTemplates error', error); return []; }
    _fieldTemplatesCache[vertical] = data || [];
    return _fieldTemplatesCache[vertical];
  }

  // ── Tool Mappings ──────────────────────────────────────────────────────────
  async function loadToolMappings(vertical) {
    if (_toolMappingsCache[vertical]) return _toolMappingsCache[vertical];
    const { data, error } = await sb()
      .from('project_tool_mappings')
      .select('*')
      .eq('vertical', vertical);
    if (error) { console.warn('[projects] loadToolMappings error', error); return {}; }
    const map = {};
    (data || []).forEach(m => {
      if (!map[m.tool_slug]) map[m.tool_slug] = {};
      map[m.tool_slug][m.project_field] = m.tool_field;
    });
    _toolMappingsCache[vertical] = map;
    return map;
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  /** List projects for current user, optionally filtered by vertical/status */
  async function list({ vertical, status, limit = 50 } = {}) {
    let q = sb()
      .from('projects')
      .select('id, name, vertical, status, data, notes, created_at, updated_at')
      .eq('user_id', PS.session.user.id)
      .order('updated_at', { ascending: false })
      .limit(limit);
    if (vertical) q = q.eq('vertical', vertical);
    if (status)   q = q.eq('status', status);
    const { data, error } = await q;
    if (error) { console.error('[projects] list error', error); return []; }
    return data || [];
  }

  /** Get a single project by ID */
  async function get(id) {
    const { data, error } = await sb()
      .from('projects')
      .select('*')
      .eq('id', id)
      .eq('user_id', PS.session.user.id)
      .single();
    if (error) { console.error('[projects] get error', error); return null; }
    return data;
  }

  /** Create a new project */
  async function create({ vertical, name, data = {}, notes = '' }) {
    const { data: row, error } = await sb()
      .from('projects')
      .insert({ user_id: PS.session.user.id, vertical, name, data, notes })
      .select()
      .single();
    if (error) { console.error('[projects] create error', error); return null; }
    return row;
  }

  /** Update a project (partial update) */
  async function update(id, changes) {
    const { data: row, error } = await sb()
      .from('projects')
      .update(changes)
      .eq('id', id)
      .eq('user_id', PS.session.user.id)
      .select()
      .single();
    if (error) { console.error('[projects] update error', error); return null; }
    return row;
  }

  /** Delete a project */
  async function remove(id) {
    const { error } = await sb()
      .from('projects')
      .delete()
      .eq('id', id)
      .eq('user_id', PS.session.user.id);
    if (error) { console.error('[projects] remove error', error); return false; }
    return true;
  }

  /** Get generations linked to a project */
  async function getGenerations(projectId, { limit = 20 } = {}) {
    const { data, error } = await sb()
      .from('tool_usage')
      .select('id, tool_slug, input_data, output_text, created_at, tokens_used, duration_ms')
      .eq('project_id', projectId)
      .eq('user_id', PS.session.user.id)
      .order('created_at', { ascending: false })
      .limit(limit);
    if (error) { console.error('[projects] getGenerations error', error); return []; }
    return data || [];
  }

  /** Count projects per vertical for the badge */
  async function countByVertical() {
    const { data, error } = await sb()
      .from('projects')
      .select('vertical')
      .eq('user_id', PS.session.user.id)
      .neq('status', 'archived');
    if (error) return {};
    const counts = {};
    (data || []).forEach(p => { counts[p.vertical] = (counts[p.vertical] || 0) + 1; });
    return counts;
  }

  // ── Tool Pre-fill Helper ───────────────────────────────────────────────────

  /**
   * Given a project and a tool slug, returns an object of
   * { toolFieldName: value } that can pre-fill the tool form.
   */
  async function getToolPrefill(project, toolSlug) {
    const mappings = await loadToolMappings(project.vertical);
    const toolMap  = mappings[toolSlug];
    if (!toolMap) return {};
    const prefill = {};
    Object.entries(toolMap).forEach(([projField, toolField]) => {
      const val = project.data?.[projField];
      if (val !== undefined && val !== null && val !== '') {
        prefill[toolField] = String(val);
      }
    });
    return prefill;
  }

  // ── Render Helpers ─────────────────────────────────────────────────────────

  function escapeHtml(s) {
    const d = document.createElement('div');
    d.textContent = s;
    return d.innerHTML;
  }

  /** Render a project form (create or edit) */
  async function renderForm(containerId, vertical, existingData = {}) {
    const fields = await loadFieldTemplates(vertical);
    const el = document.getElementById(containerId);
    if (!el || !fields.length) return;

    el.innerHTML = fields.map(f => {
      const val = existingData[f.field_key] || '';
      const req = f.required ? ' required' : '';
      const reqMark = f.required ? '<span style="color:#ef4444"> *</span>' : '';
      let input = '';

      switch (f.type) {
        case 'textarea':
          input = `<textarea name="${f.field_key}" placeholder="${escapeHtml(f.placeholder || '')}"${req} rows="3" class="pf-input pf-textarea">${escapeHtml(val)}</textarea>`;
          break;
        case 'number':
          input = `<input type="number" name="${f.field_key}" value="${escapeHtml(val)}" placeholder="${escapeHtml(f.placeholder || '')}"${req} class="pf-input"/>`;
          break;
        case 'url':
          input = `<input type="url" name="${f.field_key}" value="${escapeHtml(val)}" placeholder="${escapeHtml(f.placeholder || '')}"${req} class="pf-input"/>`;
          break;
        case 'date':
          input = `<input type="date" name="${f.field_key}" value="${escapeHtml(val)}"${req} class="pf-input"/>`;
          break;
        case 'select': {
          const opts = f.options || [];
          const optHtml = opts.map(o => `<option value="${escapeHtml(o)}"${o === val ? ' selected' : ''}>${escapeHtml(o)}</option>`).join('');
          input = `<select name="${f.field_key}"${req} class="pf-input"><option value="">— Choisir —</option>${optHtml}</select>`;
          break;
        }
        default: // text
          input = `<input type="text" name="${f.field_key}" value="${escapeHtml(val)}" placeholder="${escapeHtml(f.placeholder || '')}"${req} class="pf-input"/>`;
      }

      return `<div class="pf-group">
        <label class="pf-label">${escapeHtml(f.label)}${reqMark}</label>
        ${input}
      </div>`;
    }).join('');
  }

  /** Collect form data from a rendered project form */
  function collectFormData(containerId) {
    const el = document.getElementById(containerId);
    if (!el) return {};
    const data = {};
    el.querySelectorAll('[name]').forEach(input => {
      const val = input.value.trim();
      if (val) data[input.name] = val;
    });
    return data;
  }

  /** Validate required fields, returns array of missing field keys */
  async function validateForm(containerId, vertical) {
    const fields = await loadFieldTemplates(vertical);
    const data   = collectFormData(containerId);
    return fields
      .filter(f => f.required && !data[f.field_key])
      .map(f => f.field_key);
  }

  // ── Status helpers ─────────────────────────────────────────────────────────
  const STATUS_META = {
    active:    { label: 'En cours',  color: '#22c55e', icon: '🟢' },
    completed: { label: 'Terminé',   color: '#3b82f6', icon: '🔵' },
    archived:  { label: 'Archivé',   color: '#6b7090', icon: '⚪' },
  };

  // ── Public API ─────────────────────────────────────────────────────────────
  window.PSProjects = {
    list,
    get,
    create,
    update,
    remove,
    getGenerations,
    countByVertical,
    loadFieldTemplates,
    loadToolMappings,
    getToolPrefill,
    renderForm,
    collectFormData,
    validateForm,
    STATUS_META,
    escapeHtml,
  };
})();

/**
 * tool-renderer.js — Dynamic form renderer for The Prompt Studio
 *
 * Generates HTML forms from a tool's input_schema JSON.
 * Integrates with PSTool for generation, history, quota.
 *
 * Supported field types:
 *   text, number, textarea, select, toggle, tone_grid, radio, hidden
 *
 * Layout hints:
 *   "layout": "half"  → pair fields into 2-column rows
 *   (default)         → full-width row
 *
 * Usage:
 *   const renderer = ToolRenderer.create(schema);
 *   renderer.renderInto(containerEl);
 *   const inputs = renderer.collectInputs();  // → plain object
 *   const valid  = renderer.validate();       // → boolean (shows errors)
 */

const ToolRenderer = (() => {

  // ── Escape HTML ─────────────────────────────────────────────────────────────
  function esc(str) {
    return String(str || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  // ── Render a single field to HTML ───────────────────────────────────────────
  function renderField(field) {
    const req  = field.required ? '<span class="req">*</span>' : '';
    const id   = `field-${field.name}`;
    const ph   = esc(field.placeholder || '');

    switch (field.type) {

      case 'text':
        return `
          <div class="form-group" data-field="${field.name}">
            <label>${esc(field.label)} ${req}</label>
            <input type="text" id="${id}" name="${field.name}"
              placeholder="${ph}"
              ${field.required ? 'required' : ''}
              ${field.maxLength ? `maxlength="${field.maxLength}"` : ''}/>
          </div>`;

      case 'number':
        return `
          <div class="form-group" data-field="${field.name}">
            <label>${esc(field.label)} ${req}</label>
            <input type="number" id="${id}" name="${field.name}"
              placeholder="${ph}"
              ${field.min !== undefined ? `min="${field.min}"` : ''}
              ${field.max !== undefined ? `max="${field.max}"` : ''}
              ${field.required ? 'required' : ''}/>
          </div>`;

      case 'textarea':
        return `
          <div class="form-group" data-field="${field.name}">
            <label>${esc(field.label)} ${req}</label>
            <textarea id="${id}" name="${field.name}"
              placeholder="${ph}"
              rows="${field.rows || 3}"
              ${field.maxLength ? `maxlength="${field.maxLength}"` : ''}
              ${field.required ? 'required' : ''}></textarea>
            ${field.maxLength ? `<div class="char-count" id="${id}-count">0 / ${field.maxLength}</div>` : ''}
          </div>`;

      case 'select': {
        const opts = (field.options || []).map(o => {
          const val   = typeof o === 'string' ? o : o.value;
          const label = typeof o === 'string' ? o : (o.label || o.value);
          return `<option value="${esc(val)}">${esc(label)}</option>`;
        }).join('');
        return `
          <div class="form-group" data-field="${field.name}">
            <label>${esc(field.label)} ${req}</label>
            <select id="${id}" name="${field.name}" ${field.required ? 'required' : ''}>
              <option value="">— Choisir —</option>
              ${opts}
            </select>
          </div>`;
      }

      case 'toggle':
        return `
          <div class="form-group" data-field="${field.name}">
            <label class="toggle-row" for="${id}">
              <div>
                <div class="toggle-label">${esc(field.label)}</div>
                ${field.helpText ? `<div class="toggle-sub">${esc(field.helpText)}</div>` : ''}
              </div>
              <div class="toggle-switch">
                <input type="checkbox" id="${id}" name="${field.name}"
                  data-true-value="${esc(field.trueValue || 'true')}"
                  data-false-value="${esc(field.falseValue || 'false')}"/>
                <div class="toggle-track"></div>
                <div class="toggle-knob"></div>
              </div>
            </label>
          </div>`;

      case 'tone_grid': {
        const defaultVal = field.default || (field.options && field.options[0]?.value) || '';
        const items = (field.options || []).map(o => `
          <label class="tone-opt${o.value === defaultVal ? ' selected' : ''}" data-t="${esc(o.value)}">
            <input type="radio" name="${field.name}" value="${esc(o.value)}" ${o.value === defaultVal ? 'checked' : ''}/>
            <span class="tone-icon">${o.icon || ''}</span>
            <span class="tone-label">${esc(o.label)}</span>
          </label>`).join('');
        return `
          <div class="form-group" data-field="${field.name}">
            <label>${esc(field.label)}</label>
            <div class="tone-grid" id="${id}">${items}</div>
          </div>`;
      }

      case 'radio': {
        const defaultVal = field.default || '';
        const items = (field.options || []).map(o => {
          const val   = typeof o === 'string' ? o : o.value;
          const label = typeof o === 'string' ? o : (o.label || o.value);
          return `
            <label class="radio-option">
              <input type="radio" name="${field.name}" value="${esc(val)}" ${val === defaultVal ? 'checked' : ''}/>
              <span>${esc(label)}</span>
            </label>`;
        }).join('');
        return `
          <div class="form-group" data-field="${field.name}">
            <label>${esc(field.label)} ${req}</label>
            <div class="radio-group">${items}</div>
          </div>`;
      }

      case 'hidden':
        return `<input type="hidden" id="${id}" name="${field.name}" value="${esc(field.default || '')}"/>`;

      default:
        console.warn(`[ToolRenderer] Unknown field type: ${field.type}`);
        return `
          <div class="form-group" data-field="${field.name}">
            <label>${esc(field.label)} ${req}</label>
            <input type="text" id="${id}" name="${field.name}" placeholder="${ph}" ${field.required ? 'required' : ''}/>
          </div>`;
    }
  }

  // ── Arrange fields into layout (half fields pair into rows) ─────────────────
  function renderFields(fields) {
    let html = '';
    let i = 0;

    while (i < fields.length) {
      const f = fields[i];

      // Hidden fields render inline, no layout
      if (f.type === 'hidden') {
        html += renderField(f);
        i++;
        continue;
      }

      // Two consecutive "half" fields → wrap in form-row
      if (f.layout === 'half' && i + 1 < fields.length && fields[i + 1].layout === 'half') {
        html += `<div class="form-row">${renderField(f)}${renderField(fields[i + 1])}</div>`;
        i += 2;
      } else {
        html += renderField(f);
        i++;
      }
    }

    return html;
  }

  // ── Wire up interactive behaviors after DOM render ──────────────────────────
  function wireInteractions(container) {
    // Tone grid toggle
    container.querySelectorAll('.tone-grid').forEach(grid => {
      grid.querySelectorAll('.tone-opt').forEach(opt => {
        opt.addEventListener('click', () => {
          grid.querySelectorAll('.tone-opt').forEach(o => o.classList.remove('selected'));
          opt.classList.add('selected');
          opt.querySelector('input').checked = true;
        });
      });
    });

    // Character counters for textareas with maxLength
    container.querySelectorAll('textarea[maxlength]').forEach(ta => {
      const counter = document.getElementById(ta.id + '-count');
      if (counter) {
        ta.addEventListener('input', () => {
          counter.textContent = `${ta.value.length} / ${ta.maxLength}`;
        });
      }
    });
  }

  // ── Collect all form values into a plain object ─────────────────────────────
  function collectInputs(container, fields) {
    const inputs = {};

    fields.forEach(f => {
      const id = `field-${f.name}`;

      switch (f.type) {
        case 'toggle': {
          const el = document.getElementById(id);
          inputs[f.name] = el?.checked
            ? (f.trueValue || 'true')
            : (f.falseValue || 'false');
          break;
        }
        case 'tone_grid':
        case 'radio': {
          const checked = container.querySelector(`input[name="${f.name}"]:checked`);
          inputs[f.name] = checked?.value || f.default || '';
          break;
        }
        default: {
          const el = document.getElementById(id);
          inputs[f.name] = el?.value || '';
        }
      }
    });

    return inputs;
  }

  // ── Validate required fields ────────────────────────────────────────────────
  function validate(container, fields) {
    let valid = true;

    // Clear previous error states
    container.querySelectorAll('.form-group.error').forEach(g => g.classList.remove('error'));

    fields.forEach(f => {
      if (!f.required) return;

      const id  = `field-${f.name}`;
      const el  = document.getElementById(id);
      const grp = container.querySelector(`[data-field="${f.name}"]`);

      let empty = false;
      if (f.type === 'select') {
        empty = !el?.value;
      } else if (f.type === 'tone_grid' || f.type === 'radio') {
        empty = !container.querySelector(`input[name="${f.name}"]:checked`);
      } else if (el) {
        empty = !el.value.trim();
      }

      if (empty && grp) {
        grp.classList.add('error');
        valid = false;
      }
    });

    return valid;
  }

  // ── Public factory ──────────────────────────────────────────────────────────
  function create(schema) {
    const fields = schema?.fields || [];

    return {
      /** Generate form HTML from schema */
      renderHTML() {
        return renderFields(fields);
      },

      /** Render into a container and wire up interactions */
      renderInto(container) {
        container.innerHTML = renderFields(fields);
        wireInteractions(container);
      },

      /** Collect all field values */
      collectInputs(container) {
        return collectInputs(container, fields);
      },

      /** Validate required fields, return true if all OK */
      validate(container) {
        return validate(container, fields);
      },

      /** Access raw fields array */
      fields,
    };
  }

  return { create };

})();

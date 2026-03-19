-- ============================================================================
-- USAGE TRACKING UPGRADE — Add granular token/cost tracking + admin views
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ── 1. Add missing columns to tool_usage ─────────────────────────────────────
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS input_tokens       INT DEFAULT 0;
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS output_tokens      INT DEFAULT 0;
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS model              TEXT DEFAULT '';
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS vertical           TEXT DEFAULT '';
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS estimated_cost_usd NUMERIC(10,6) DEFAULT 0;
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS request_status     TEXT DEFAULT 'success'
  CHECK (request_status IN ('success', 'error', 'timeout'));

-- ── 2. Indexes for admin queries ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_tool_usage_vertical
  ON tool_usage (vertical);
CREATE INDEX IF NOT EXISTS idx_tool_usage_model
  ON tool_usage (model);
CREATE INDEX IF NOT EXISTS idx_tool_usage_status
  ON tool_usage (request_status);
CREATE INDEX IF NOT EXISTS idx_tool_usage_cost
  ON tool_usage (estimated_cost_usd DESC);
CREATE INDEX IF NOT EXISTS idx_tool_usage_created_at
  ON tool_usage (created_at DESC);

-- ── 3. Admin view: cost per user (monthly) ───────────────────────────────────
CREATE OR REPLACE VIEW admin_cost_per_user AS
SELECT
  user_id,
  date_trunc('month', created_at)::date AS month,
  COUNT(*)                               AS total_requests,
  COUNT(*) FILTER (WHERE request_status = 'success') AS success_count,
  COUNT(*) FILTER (WHERE request_status = 'error')   AS error_count,
  SUM(input_tokens)                      AS total_input_tokens,
  SUM(output_tokens)                     AS total_output_tokens,
  SUM(tokens_used)                       AS total_tokens,
  SUM(estimated_cost_usd)                AS total_cost_usd,
  AVG(duration_ms)::int                  AS avg_duration_ms
FROM tool_usage
GROUP BY user_id, date_trunc('month', created_at);

-- ── 4. Admin view: cost per vertical (monthly) ──────────────────────────────
CREATE OR REPLACE VIEW admin_cost_per_vertical AS
SELECT
  vertical,
  date_trunc('month', created_at)::date AS month,
  COUNT(*)                               AS total_requests,
  COUNT(DISTINCT user_id)                AS unique_users,
  SUM(input_tokens)                      AS total_input_tokens,
  SUM(output_tokens)                     AS total_output_tokens,
  SUM(tokens_used)                       AS total_tokens,
  SUM(estimated_cost_usd)                AS total_cost_usd,
  AVG(duration_ms)::int                  AS avg_duration_ms
FROM tool_usage
WHERE request_status = 'success'
GROUP BY vertical, date_trunc('month', created_at);

-- ── 5. Admin view: cost per tool (monthly) ───────────────────────────────────
CREATE OR REPLACE VIEW admin_cost_per_tool AS
SELECT
  tool_slug,
  vertical,
  date_trunc('month', created_at)::date AS month,
  COUNT(*)                               AS total_requests,
  COUNT(DISTINCT user_id)                AS unique_users,
  SUM(input_tokens)                      AS total_input_tokens,
  SUM(output_tokens)                     AS total_output_tokens,
  SUM(tokens_used)                       AS total_tokens,
  SUM(estimated_cost_usd)                AS total_cost_usd,
  AVG(duration_ms)::int                  AS avg_duration_ms,
  AVG(estimated_cost_usd)                AS avg_cost_per_request
FROM tool_usage
WHERE request_status = 'success'
GROUP BY tool_slug, vertical, date_trunc('month', created_at);

-- ── 6. Admin view: top consuming users (current month) ──────────────────────
CREATE OR REPLACE VIEW admin_top_users AS
SELECT
  user_id,
  COUNT(*)                  AS request_count,
  SUM(tokens_used)          AS total_tokens,
  SUM(estimated_cost_usd)   AS total_cost_usd,
  AVG(duration_ms)::int     AS avg_duration_ms,
  MAX(created_at)           AS last_request_at
FROM tool_usage
WHERE request_status = 'success'
  AND created_at >= date_trunc('month', now())
GROUP BY user_id
ORDER BY total_cost_usd DESC;

-- ── 7. Admin view: failed requests ──────────────────────────────────────────
CREATE OR REPLACE VIEW admin_failed_requests AS
SELECT
  id,
  user_id,
  tool_slug,
  vertical,
  model,
  output_text AS error_message,
  duration_ms,
  created_at
FROM tool_usage
WHERE request_status IN ('error', 'timeout')
ORDER BY created_at DESC
LIMIT 200;

-- ── 8. Admin view: platform-wide summary (current month) ────────────────────
CREATE OR REPLACE VIEW admin_monthly_summary AS
SELECT
  date_trunc('month', created_at)::date   AS month,
  COUNT(*)                                 AS total_requests,
  COUNT(DISTINCT user_id)                  AS active_users,
  COUNT(DISTINCT tool_slug)                AS tools_used,
  COUNT(DISTINCT vertical)                 AS verticals_used,
  SUM(tokens_used)                         AS total_tokens,
  SUM(estimated_cost_usd)                  AS total_cost_usd,
  AVG(estimated_cost_usd)                  AS avg_cost_per_request,
  COUNT(*) FILTER (WHERE request_status = 'error') AS error_count,
  ROUND(100.0 * COUNT(*) FILTER (WHERE request_status = 'success') / NULLIF(COUNT(*), 0), 1) AS success_rate_pct
FROM tool_usage
GROUP BY date_trunc('month', created_at)
ORDER BY month DESC;

-- ============================================================================
-- DONE. New columns + 6 admin views ready for monitoring.
-- ============================================================================

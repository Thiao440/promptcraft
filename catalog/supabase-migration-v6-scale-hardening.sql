-- Migration: v6-scale-hardening (FIXED)
-- Purpose: Database optimizations for 1M user scaling
-- Created: 2026-03-18
--
-- IMPORTANT: Run AFTER v4 and v5 migrations.
--
-- Actual schema reference:
--   usage_quotas:  (id, user_id, month, count) — UNIQUE(user_id, month)
--   tool_usage:    (id, user_id, tool_slug, input_data, output_text, tokens_used, duration_ms, created_at)
--   subscriptions: (id, user_id, tier, status, vertical, lemon_subscription_id, ...)
--   tools:         (slug PK, name, vertical, min_tier, ..., input_schema, category, ...)
--   profiles:      (id, ...)

-- ============================================================================
-- 1. COMPOSITE INDEXES FOR HOT QUERIES
-- ============================================================================

-- Usage quota lookups: ai-tool.js queries (user_id, month) on every generation
CREATE INDEX IF NOT EXISTS idx_usage_quotas_user_month
  ON usage_quotas(user_id, month);

-- Active subscriptions: ai-tool.js queries (user_id, vertical, status) on every call
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_active
  ON subscriptions(user_id, vertical)
  WHERE status = 'active';

-- Tool usage history: ps-tool.js loads last 10 per user+tool
CREATE INDEX IF NOT EXISTS idx_tool_usage_user_slug_recent
  ON tool_usage(user_id, tool_slug, created_at DESC);

-- Tool usage by user sorted by date (for archival queries)
CREATE INDEX IF NOT EXISTS idx_tool_usage_user_created
  ON tool_usage(user_id, created_at DESC);

-- Profiles email lookup (used by webhook-ls.js for O(1) user resolution)
-- Created below in section 5 after adding the email column


-- ============================================================================
-- 2. PER-TOOL MAX_TOKENS CONFIGURATION
-- ============================================================================

ALTER TABLE tools
  ADD COLUMN IF NOT EXISTS max_output_tokens integer DEFAULT 800;

COMMENT ON COLUMN tools.max_output_tokens IS
  'Max output tokens for this tool. ai-tool.js uses: tool.max_output_tokens || DEFAULT_MAX_TOKENS.';

-- Set sensible defaults by tool slug pattern (safe: only changes default 800 values)
UPDATE tools SET max_output_tokens = 400
  WHERE slug LIKE '%-email-%' AND max_output_tokens = 800;

UPDATE tools SET max_output_tokens = 300
  WHERE slug LIKE '%-posts-%' AND max_output_tokens = 800;

UPDATE tools SET max_output_tokens = 1500
  WHERE (slug LIKE '%-rapport-%' OR slug LIKE '%-analyse-%' OR slug LIKE '%-synthese%') AND max_output_tokens = 800;

UPDATE tools SET max_output_tokens = 2000
  WHERE (slug LIKE '%-contrat-%' OR slug LIKE '%-plaidoirie%' OR slug LIKE '%-mise-en-demeure%') AND max_output_tokens = 800;


-- ============================================================================
-- 3. RLS HARDENING: TOOLS_PUBLIC VIEW
-- ============================================================================
-- Hides prompt_template and system_prompt from frontend queries

CREATE OR REPLACE VIEW tools_public AS
  SELECT
    slug,
    label,
    description,
    icon,
    vertical,
    min_tier,
    is_featured,
    is_new,
    sort_order,
    input_schema,
    max_output_tokens,
    category,
    generate_label,
    loading_text,
    empty_state_icon,
    empty_state_title,
    empty_state_text,
    form_panel_title,
    created_at
  FROM tools
  WHERE is_active = true;

COMMENT ON VIEW tools_public IS
  'Public tool metadata. Excludes prompt_template and system_prompt. Frontend uses this; backend uses full tools table via service key.';


-- ============================================================================
-- 4. TOOL_USAGE ARCHIVAL SETUP
-- ============================================================================
-- Archive table mirrors actual tool_usage columns

CREATE TABLE IF NOT EXISTS tool_usage_archive (
  id            uuid PRIMARY KEY,
  user_id       uuid NOT NULL,
  tool_slug     text NOT NULL,
  input_data    jsonb,
  output_text   text,
  tokens_used   integer DEFAULT 0,
  duration_ms   integer,
  created_at    timestamptz,
  archived_at   timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tool_usage_archive_date
  ON tool_usage_archive(archived_at DESC);

-- Function to archive old tool_usage records (default: keep 90 days)
CREATE OR REPLACE FUNCTION archive_old_tool_usage(days_to_keep integer DEFAULT 90)
RETURNS bigint AS $$
DECLARE
  cutoff_date timestamptz;
  rows_moved bigint;
BEGIN
  cutoff_date := now() - (days_to_keep || ' days')::interval;

  INSERT INTO tool_usage_archive (id, user_id, tool_slug, input_data, output_text, tokens_used, duration_ms, created_at)
  SELECT id, user_id, tool_slug, input_data, output_text, tokens_used, duration_ms, created_at
  FROM tool_usage
  WHERE created_at < cutoff_date;

  GET DIAGNOSTICS rows_moved = ROW_COUNT;

  DELETE FROM tool_usage WHERE created_at < cutoff_date;

  RETURN rows_moved;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION archive_old_tool_usage IS
  'Moves tool_usage records older than N days to archive. Run monthly: SELECT archive_old_tool_usage(90);';


-- ============================================================================
-- 5. PROFILES TABLE: ADD EMAIL + DISPLAY_NAME COLUMNS
-- ============================================================================
-- webhook-ls.js uses profiles(email) for O(1) user lookup instead of O(n) listUsers()

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS email text;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS display_name text;

-- Unique index on email for fast lookup + dedup
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_email_unique
  ON profiles(email)
  WHERE email IS NOT NULL;

COMMENT ON COLUMN profiles.email IS
  'Cached from auth.users for O(1) webhook lookups. webhook-ls.js keeps this in sync on user creation.';


-- ============================================================================
-- 6. WEBHOOK IDEMPOTENCY TRACKING
-- ============================================================================

CREATE TABLE IF NOT EXISTS webhook_events (
  id            text PRIMARY KEY,
  event_name    text NOT NULL,
  processed_at  timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_webhook_events_date
  ON webhook_events(processed_at DESC);

COMMENT ON TABLE webhook_events IS
  'Tracks processed webhook event IDs for idempotency. Clean up monthly.';

CREATE OR REPLACE FUNCTION cleanup_old_webhook_events(days_to_keep integer DEFAULT 30)
RETURNS bigint AS $$
DECLARE
  rows_removed bigint;
BEGIN
  DELETE FROM webhook_events
  WHERE processed_at < now() - (days_to_keep || ' days')::interval;
  GET DIAGNOSTICS rows_removed = ROW_COUNT;
  RETURN rows_removed;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- DONE — Post-migration verification:
-- ============================================================================
--   SELECT * FROM tools_public LIMIT 3;           -- should NOT show prompt_template
--   SELECT indexname FROM pg_indexes WHERE tablename = 'usage_quotas';
--   SELECT indexname FROM pg_indexes WHERE tablename = 'subscriptions';
--   SELECT indexname FROM pg_indexes WHERE tablename = 'tool_usage';
--   SELECT archive_old_tool_usage(9999);           -- dry run (nothing old enough to archive)

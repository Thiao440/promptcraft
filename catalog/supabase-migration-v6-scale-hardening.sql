-- Migration: v6-scale-hardening
-- Purpose: Database optimizations and schema changes for 1M user scaling
-- Created: 2026-03-17
-- Changes:
--   1. Composite indexes for hot queries
--   2. Per-tool max_tokens configuration
--   3. RLS hardening with tools_public view
--   4. tool_usage archival setup
--   5. Profiles table enhancements
--   6. Webhook idempotency tracking

-- ============================================================================
-- 1. COMPOSITE INDEXES FOR HOT QUERIES
-- ============================================================================
-- These indexes optimize the most frequently accessed query patterns

-- Usage quota lookups by user, vertical, and month
CREATE INDEX IF NOT EXISTS idx_usage_quotas_lookup
  ON usage_quotas(user_id, vertical, month);

-- Active subscriptions for a user and vertical
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_active
  ON subscriptions(user_id, vertical)
  WHERE status = 'active';

-- Tool usage queries filtered by user with recency ordering
CREATE INDEX IF NOT EXISTS idx_tool_usage_user_recent
  ON tool_usage(user_id, created_at DESC);

-- Email lookups on profiles table
CREATE INDEX IF NOT EXISTS idx_profiles_email
  ON profiles(email);


-- ============================================================================
-- 2. PER-TOOL MAX_TOKENS CONFIGURATION
-- ============================================================================
-- Adds output token limits per tool to prevent runaway costs and manage quality

ALTER TABLE tools
  ADD COLUMN IF NOT EXISTS max_output_tokens integer DEFAULT 800;

-- Comment explaining the column purpose
COMMENT ON COLUMN tools.max_output_tokens IS
  'Maximum allowed output tokens for this tool. Prevents runaway costs and ensures quality. Overridden by tier limits if more restrictive.';

-- Update max_output_tokens for specific tool categories
-- Email tools: shorter output to maintain readability
UPDATE tools
  SET max_output_tokens = 400
  WHERE category = 'email' AND max_output_tokens IS NULL;

-- Social media posts: constrain to platform limits
UPDATE tools
  SET max_output_tokens = 300
  WHERE category = 'social' AND max_output_tokens IS NULL;

-- Reports: allow longer output for comprehensive analysis
UPDATE tools
  SET max_output_tokens = 1500
  WHERE category = 'reports' AND max_output_tokens IS NULL;

-- Contracts and legal: allow extended output for detailed documents
UPDATE tools
  SET max_output_tokens = 2000
  WHERE category IN ('contracts', 'legal') AND max_output_tokens IS NULL;


-- ============================================================================
-- 3. RLS HARDENING: TOOLS_PUBLIC VIEW
-- ============================================================================
-- Separates public tool metadata from sensitive template/system prompt columns
-- Frontend queries this view; serverless functions use service key for full table access

-- Create view that exposes only non-sensitive tool columns
CREATE OR REPLACE VIEW tools_public AS
  SELECT
    id,
    slug,
    label,
    description,
    icon,
    vertical,
    category,
    min_tier,
    is_featured,
    is_new,
    sort_order,
    created_at,
    updated_at
  FROM tools
  WHERE is_active = true;

-- Add comment explaining the view
COMMENT ON VIEW tools_public IS
  'Public-facing tool metadata. Excludes prompt_template and system_prompt. Used by frontend; backend uses full tools table with service key.';

-- Enable RLS on the view
ALTER VIEW tools_public SET (security_invoker = on);


-- ============================================================================
-- 4. TOOL_USAGE ARCHIVAL SETUP
-- ============================================================================
-- Prepares for retention policies and archival of old usage records

-- Create archive table for old tool_usage records
CREATE TABLE IF NOT EXISTS tool_usage_archive (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL,
  tool_id uuid NOT NULL,
  vertical text NOT NULL,
  input_tokens integer,
  output_tokens integer,
  cost_usd numeric(10, 6),
  created_at timestamptz,
  archived_at timestamptz DEFAULT now()
);

-- Index on archived_at for cleanup queries
CREATE INDEX IF NOT EXISTS idx_tool_usage_archive_archived_at
  ON tool_usage_archive(archived_at DESC);

-- Function to archive old tool_usage records
CREATE OR REPLACE FUNCTION archive_old_tool_usage(days_to_keep integer DEFAULT 90)
RETURNS TABLE(rows_archived bigint) AS $$
DECLARE
  cutoff_date timestamptz;
  rows_moved bigint;
BEGIN
  cutoff_date := now() - (days_to_keep || ' days')::interval;

  -- Move old records to archive table
  INSERT INTO tool_usage_archive (user_id, tool_id, vertical, input_tokens, output_tokens, cost_usd, created_at)
  SELECT user_id, tool_id, vertical, input_tokens, output_tokens, cost_usd, created_at
  FROM tool_usage
  WHERE created_at < cutoff_date;

  GET DIAGNOSTICS rows_moved = ROW_COUNT;

  -- Delete from main table
  DELETE FROM tool_usage
  WHERE created_at < cutoff_date;

  RETURN QUERY SELECT rows_moved;
END;
$$ LANGUAGE plpgsql;

-- Comment explaining archival strategy
COMMENT ON FUNCTION archive_old_tool_usage IS
  'Archives tool_usage records older than days_to_keep to tool_usage_archive. Run periodically (e.g., monthly) to maintain query performance. Default retention: 90 days.';

-- Create index for archival queries by user and date range
CREATE INDEX IF NOT EXISTS idx_tool_usage_user_created
  ON tool_usage(user_id, created_at DESC);


-- ============================================================================
-- 5. PROFILES TABLE ENHANCEMENTS
-- ============================================================================
-- Ensures email tracking and indexing for user lookups

-- Add email column if missing
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS email text;

-- Create unique index on email for fast lookups and preventing duplicates
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_email_unique
  ON profiles(email)
  WHERE email IS NOT NULL;

-- Add comment explaining the email field
COMMENT ON COLUMN profiles.email IS
  'User email address cached from auth.users for faster queries without join. Kept in sync via trigger.';


-- ============================================================================
-- 6. WEBHOOK IDEMPOTENCY TRACKING
-- ============================================================================
-- Tracks processed webhook events to prevent duplicate processing

-- Create table to track webhook events for idempotency
CREATE TABLE IF NOT EXISTS webhook_events (
  id text PRIMARY KEY,
  event_name text NOT NULL,
  payload jsonb,
  processed_at timestamptz DEFAULT now(),
  retry_count integer DEFAULT 0
);

-- Index for checking recent events and cleanup
CREATE INDEX IF NOT EXISTS idx_webhook_events_processed_at
  ON webhook_events(processed_at DESC);

-- Index for event type queries
CREATE INDEX IF NOT EXISTS idx_webhook_events_event_name
  ON webhook_events(event_name, processed_at DESC);

-- Add comment explaining idempotency
COMMENT ON TABLE webhook_events IS
  'Tracks webhook event IDs to ensure idempotency. Check this table before processing incoming webhooks. Archive old records monthly.';

-- Function to clean up old webhook events
CREATE OR REPLACE FUNCTION cleanup_old_webhook_events(days_to_keep integer DEFAULT 30)
RETURNS TABLE(rows_deleted bigint) AS $$
DECLARE
  cutoff_date timestamptz;
  rows_removed bigint;
BEGIN
  cutoff_date := now() - (days_to_keep || ' days')::interval;

  DELETE FROM webhook_events
  WHERE processed_at < cutoff_date;

  GET DIAGNOSTICS rows_removed = ROW_COUNT;

  RETURN QUERY SELECT rows_removed;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_old_webhook_events IS
  'Removes webhook events older than days_to_keep (default 30 days). Run monthly to prevent unbounded table growth.';


-- ============================================================================
-- MIGRATION NOTES
-- ============================================================================
--
-- Indexes:
--   All composite indexes use common access patterns from hot queries.
--   Partial index on subscriptions filters to active records only (smaller index size).
--
-- Per-Tool Max Tokens:
--   Tier limits take precedence if more restrictive.
--   Use in serverless functions during tool execution.
--
-- RLS Hardening:
--   The tools_public view exposes metadata without sensitive columns.
--   Frontend should query /api/tools which returns tools_public.
--   Backend services use full tools table with service key.
--
-- Tool Usage Archival:
--   Run archive_old_tool_usage(90) monthly to maintain performance.
--   Archived records stay queryable if needed for historical analysis.
--   Consider partitioning tool_usage by month in future major version.
--
-- Profiles Email:
--   Duplicate email prevention via unique constraint with null handling.
--   Ensure sync trigger exists from auth.users -> profiles.email.
--
-- Webhook Idempotency:
--   Before processing webhook, check SELECT 1 FROM webhook_events WHERE id = $1.
--   Insert after processing: INSERT INTO webhook_events (id, event_name) VALUES ($1, $2).
--   Run cleanup_old_webhook_events(30) monthly.
--
-- Testing:
--   Verify indexes are used with EXPLAIN ANALYZE on hot queries.
--   Test archival function on staging before production.
--   Monitor table sizes with: SELECT * FROM pg_stat_user_tables ORDER BY n_live_tup DESC;


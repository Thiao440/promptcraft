-- ══════════════════════════════════════════════════════════════════════════════
-- Migration: Add dynamic badge columns to tools table
-- Purpose: Enable automatic "Nouveau" (≤30 days) and "Populaire" (top 20% usage) badges
-- ══════════════════════════════════════════════════════════════════════════════

-- 1. Add created_at column (defaults to now() for new tools)
ALTER TABLE tools ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

-- 2. Add usage_count column (incremented by analytics function)
ALTER TABLE tools ADD COLUMN IF NOT EXISTS usage_count INT DEFAULT 0;

-- 3. Backfill created_at for existing tools (set to epoch for already-existing tools)
UPDATE tools SET created_at = '2025-01-01T00:00:00Z' WHERE created_at IS NULL;

-- 4. Create function to increment usage_count (called from tool.html on each generation)
CREATE OR REPLACE FUNCTION increment_tool_usage(tool_slug TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE tools SET usage_count = COALESCE(usage_count, 0) + 1 WHERE slug = tool_slug;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION increment_tool_usage(TEXT) TO authenticated;

-- 6. Drop old static badge columns (no longer needed — badges are computed client-side)
-- NOTE: Keep is_featured and is_new for now as fallback; remove in a future migration.
-- ALTER TABLE tools DROP COLUMN IF EXISTS is_featured;
-- ALTER TABLE tools DROP COLUMN IF EXISTS is_new;

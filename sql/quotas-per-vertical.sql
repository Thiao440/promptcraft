-- ============================================================================
-- QUOTAS PER VERTICAL — Split usage tracking by vertical
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ── 1. Add vertical column to usage_quotas ───────────────────────────────────
ALTER TABLE usage_quotas ADD COLUMN IF NOT EXISTS vertical TEXT DEFAULT '';

-- ── 2. Drop old unique constraint (user_id, month) ──────────────────────────
-- Find and drop the existing constraint (name may vary)
DO $$
DECLARE
  _cname TEXT;
BEGIN
  SELECT conname INTO _cname
    FROM pg_constraint
   WHERE conrelid = 'usage_quotas'::regclass
     AND contype = 'u'
   LIMIT 1;
  IF _cname IS NOT NULL THEN
    EXECUTE 'ALTER TABLE usage_quotas DROP CONSTRAINT ' || _cname;
  END IF;
END $$;

-- ── 3. Add new unique constraint (user_id, month, vertical) ─────────────────
ALTER TABLE usage_quotas
  ADD CONSTRAINT uq_usage_quotas_user_month_vertical
  UNIQUE (user_id, month, vertical);

-- ── 4. Update index ─────────────────────────────────────────────────────────
DROP INDEX IF EXISTS idx_usage_quotas_user_month;
CREATE INDEX IF NOT EXISTS idx_usage_quotas_user_month_vertical
  ON usage_quotas (user_id, month, vertical);

-- ── 5. Replace RPC: increment_usage_quota (now with vertical) ────────────────
CREATE OR REPLACE FUNCTION increment_usage_quota(
  p_user_id UUID,
  p_month   TEXT,
  p_vertical TEXT DEFAULT ''
)
RETURNS void AS $$
BEGIN
  INSERT INTO usage_quotas (user_id, month, vertical, count)
  VALUES (p_user_id, p_month, p_vertical, 1)
  ON CONFLICT (user_id, month, vertical)
  DO UPDATE SET count = usage_quotas.count + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- DONE. Quotas are now tracked per (user, month, vertical).
-- Old rows with vertical='' still count toward global usage if needed.
-- ============================================================================

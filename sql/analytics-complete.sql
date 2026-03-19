-- ============================================================================
-- ANALYTICS COMPLETE — Tracking events, cohorts, acquisition, sessions
-- Safe: IF NOT EXISTS, ADD COLUMN IF NOT EXISTS, CREATE OR REPLACE
-- ============================================================================


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  1. EVENTS TABLE — Client-side event tracking                          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE TABLE IF NOT EXISTS events (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  event_name TEXT NOT NULL,                 -- page_view, click, feature_used, tool_started, tool_abandoned, output_copied, output_exported, upgrade_clicked, etc.
  page       TEXT DEFAULT '',               -- /dashboard.html, /tool.html?slug=immo-annonce
  vertical   TEXT DEFAULT '',
  metadata   JSONB DEFAULT '{}',            -- any extra context { tool_slug, button_id, duration_ms, referrer, etc. }
  session_id TEXT DEFAULT '',               -- links events in same browsing session
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_events_user      ON events (user_id);
CREATE INDEX IF NOT EXISTS idx_events_name      ON events (event_name);
CREATE INDEX IF NOT EXISTS idx_events_created   ON events (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_session   ON events (session_id) WHERE session_id != '';
CREATE INDEX IF NOT EXISTS idx_events_vertical  ON events (vertical) WHERE vertical != '';

ALTER TABLE events ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'events_insert' AND tablename = 'events') THEN
    CREATE POLICY events_insert ON events FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'events_select' AND tablename = 'events') THEN
    CREATE POLICY events_select ON events FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  2. PROFILES — Add missing columns for acquisition & cohort tracking   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS signup_date      TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS signup_source    TEXT DEFAULT '';       -- organic, google, linkedin, referral, direct
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS utm_source       TEXT DEFAULT '';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS utm_medium       TEXT DEFAULT '';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS utm_campaign     TEXT DEFAULT '';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS referral_code    TEXT DEFAULT '';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS referred_by      UUID;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_active_at   TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS billing_country  TEXT DEFAULT '';


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  3. SUBSCRIPTIONS — Add churn tracking & price denormalization          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS cancelled_at          TIMESTAMPTZ;
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS cancellation_reason   TEXT DEFAULT '';
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS cancellation_feedback TEXT DEFAULT '';
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS price_usd             NUMERIC(8,2) DEFAULT 0;
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS billing_cycle         TEXT DEFAULT 'monthly';  -- monthly / yearly
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS trial_ends_at         TIMESTAMPTZ;

-- Subscription change history (for upgrade/downgrade tracking)
CREATE TABLE IF NOT EXISTS subscription_history (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vertical    TEXT NOT NULL,
  old_tier    TEXT,
  new_tier    TEXT,
  old_status  TEXT,
  new_status  TEXT,
  change_type TEXT NOT NULL DEFAULT 'update',  -- created, upgraded, downgraded, cancelled, reactivated, expired
  metadata    JSONB DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sub_history_user ON subscription_history (user_id);
CREATE INDEX IF NOT EXISTS idx_sub_history_vertical ON subscription_history (vertical);
CREATE INDEX IF NOT EXISTS idx_sub_history_type ON subscription_history (change_type);
CREATE INDEX IF NOT EXISTS idx_sub_history_created ON subscription_history (created_at DESC);

ALTER TABLE subscription_history ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'sh_select' AND tablename = 'subscription_history') THEN
    CREATE POLICY sh_select ON subscription_history FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  4. PRICING REFERENCE TABLE                                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE TABLE IF NOT EXISTS pricing_tiers (
  id             SERIAL PRIMARY KEY,
  tier           TEXT NOT NULL,
  billing_cycle  TEXT NOT NULL DEFAULT 'monthly',  -- monthly / yearly
  price_usd      NUMERIC(8,2) NOT NULL,
  generations    INT,                              -- NULL = unlimited
  effective_from TIMESTAMPTZ NOT NULL DEFAULT now(),
  effective_to   TIMESTAMPTZ,                      -- NULL = still active
  UNIQUE (tier, billing_cycle, effective_from)
);

ALTER TABLE pricing_tiers ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'pt_select' AND tablename = 'pricing_tiers') THEN
    CREATE POLICY pt_select ON pricing_tiers FOR SELECT USING (true);
  END IF;
END $$;

-- Seed current pricing
INSERT INTO pricing_tiers (tier, billing_cycle, price_usd, generations) VALUES
  ('starter', 'monthly', 19.00, 50),
  ('starter', 'yearly',  15.00, 50),
  ('pro',     'monthly', 49.00, 150),
  ('pro',     'yearly',  39.00, 150),
  ('gold',    'monthly', 99.00, NULL),
  ('gold',    'yearly',  79.00, NULL),
  ('team',    'monthly', 199.00, NULL),
  ('team',    'yearly',  159.00, NULL)
ON CONFLICT (tier, billing_cycle, effective_from) DO NOTHING;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  5. FEATURE ADOPTION TRACKING                                          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE TABLE IF NOT EXISTS feature_adoptions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  feature_name TEXT NOT NULL,   -- crm_projects, chatbot_generic, chatbot_specialist, export_pdf, etc.
  adopted_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, feature_name)
);

CREATE INDEX IF NOT EXISTS idx_feature_adoptions_feature ON feature_adoptions (feature_name);

ALTER TABLE feature_adoptions ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'fa_select' AND tablename = 'feature_adoptions') THEN
    CREATE POLICY fa_select ON feature_adoptions FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'fa_insert' AND tablename = 'feature_adoptions') THEN
    CREATE POLICY fa_insert ON feature_adoptions FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  6. ADMIN ANALYTICS VIEWS (investor-grade)                             ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- MRR par mois (en joignant avec pricing)
CREATE OR REPLACE VIEW admin_mrr AS
SELECT
  date_trunc('month', s.created_at)::date AS month,
  s.vertical,
  s.tier,
  s.billing_cycle,
  COUNT(*) AS subscription_count,
  SUM(COALESCE(s.price_usd, p.price_usd, 0)) AS mrr_usd
FROM subscriptions s
LEFT JOIN pricing_tiers p ON p.tier = s.tier AND p.billing_cycle = s.billing_cycle AND p.effective_to IS NULL
WHERE s.status = 'active'
GROUP BY date_trunc('month', s.created_at), s.vertical, s.tier, s.billing_cycle;

-- Cohort retention (signup week → activity weeks)
CREATE OR REPLACE VIEW admin_cohort_retention AS
SELECT
  date_trunc('week', p.signup_date)::date AS cohort_week,
  COUNT(DISTINCT p.id) AS cohort_size,
  COUNT(DISTINCT CASE WHEN tu.created_at >= p.signup_date AND tu.created_at < p.signup_date + interval '7 days' THEN p.id END) AS week_0,
  COUNT(DISTINCT CASE WHEN tu.created_at >= p.signup_date + interval '7 days' AND tu.created_at < p.signup_date + interval '14 days' THEN p.id END) AS week_1,
  COUNT(DISTINCT CASE WHEN tu.created_at >= p.signup_date + interval '14 days' AND tu.created_at < p.signup_date + interval '21 days' THEN p.id END) AS week_2,
  COUNT(DISTINCT CASE WHEN tu.created_at >= p.signup_date + interval '21 days' AND tu.created_at < p.signup_date + interval '28 days' THEN p.id END) AS week_3,
  COUNT(DISTINCT CASE WHEN tu.created_at >= p.signup_date + interval '28 days' AND tu.created_at < p.signup_date + interval '56 days' THEN p.id END) AS week_4_7,
  COUNT(DISTINCT CASE WHEN tu.created_at >= p.signup_date + interval '56 days' AND tu.created_at < p.signup_date + interval '84 days' THEN p.id END) AS week_8_11,
  COUNT(DISTINCT CASE WHEN tu.created_at >= p.signup_date + interval '84 days' THEN p.id END) AS week_12_plus
FROM profiles p
LEFT JOIN tool_usage tu ON tu.user_id = p.id AND tu.request_status = 'success'
WHERE p.signup_date IS NOT NULL
GROUP BY date_trunc('week', p.signup_date)
ORDER BY cohort_week DESC;

-- Churn analysis
CREATE OR REPLACE VIEW admin_churn_analysis AS
SELECT
  date_trunc('month', cancelled_at)::date AS churn_month,
  vertical,
  tier,
  COUNT(*) AS churned_count,
  cancellation_reason,
  AVG(EXTRACT(EPOCH FROM (cancelled_at - created_at)) / 86400)::int AS avg_lifetime_days
FROM subscriptions
WHERE status = 'cancelled' AND cancelled_at IS NOT NULL
GROUP BY date_trunc('month', cancelled_at), vertical, tier, cancellation_reason
ORDER BY churn_month DESC;

-- Acquisition funnel
CREATE OR REPLACE VIEW admin_acquisition_funnel AS
SELECT
  date_trunc('week', signup_date)::date AS week,
  signup_source,
  utm_source,
  utm_campaign,
  COUNT(*) AS signups,
  COUNT(*) FILTER (WHERE profile_completed_at IS NOT NULL) AS profiles_completed,
  COUNT(DISTINCT s.user_id) FILTER (WHERE s.status = 'active') AS converted_to_paid,
  ROUND(100.0 * COUNT(DISTINCT s.user_id) FILTER (WHERE s.status = 'active') / NULLIF(COUNT(*), 0), 1) AS conversion_rate_pct
FROM profiles p
LEFT JOIN subscriptions s ON s.user_id = p.id
WHERE p.signup_date IS NOT NULL
GROUP BY date_trunc('week', signup_date), signup_source, utm_source, utm_campaign
ORDER BY week DESC;

-- Feature adoption rates
CREATE OR REPLACE VIEW admin_feature_adoption AS
SELECT
  feature_name,
  COUNT(*) AS total_adopters,
  COUNT(*) FILTER (WHERE adopted_at >= date_trunc('month', now())) AS adopted_this_month,
  MIN(adopted_at) AS first_adoption,
  MAX(adopted_at) AS latest_adoption
FROM feature_adoptions
GROUP BY feature_name
ORDER BY total_adopters DESC;

-- User segmentation
CREATE OR REPLACE VIEW admin_user_segments AS
SELECT
  p.id AS user_id,
  p.email,
  p.signup_date,
  p.signup_source,
  p.job_title,
  p.last_active_at,
  COALESCE(sub_count.cnt, 0) AS subscription_count,
  COALESCE(usage.total_gens, 0) AS total_generations,
  COALESCE(usage.total_cost, 0) AS total_cost_usd,
  COALESCE(usage.last_gen, p.last_active_at) AS last_activity,
  CASE
    WHEN COALESCE(usage.total_gens, 0) = 0 THEN 'inactive'
    WHEN usage.monthly_gens >= 100 THEN 'power_user'
    WHEN usage.monthly_gens >= 20 THEN 'active'
    WHEN usage.monthly_gens >= 5 THEN 'casual'
    ELSE 'dormant'
  END AS usage_segment,
  CASE
    WHEN COALESCE(sub_count.cnt, 0) = 0 THEN 'free'
    WHEN sub_count.cnt > 1 THEN 'multi_vertical'
    ELSE 'single_vertical'
  END AS subscription_segment,
  CASE
    WHEN p.last_active_at < now() - interval '30 days' THEN 'at_risk'
    WHEN p.last_active_at < now() - interval '14 days' THEN 'cooling'
    ELSE 'healthy'
  END AS health_segment
FROM profiles p
LEFT JOIN (
  SELECT user_id, COUNT(*) AS cnt
  FROM subscriptions WHERE status = 'active'
  GROUP BY user_id
) sub_count ON sub_count.user_id = p.id
LEFT JOIN (
  SELECT user_id,
    COUNT(*) AS total_gens,
    SUM(estimated_cost_usd) AS total_cost,
    MAX(created_at) AS last_gen,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', now())) AS monthly_gens
  FROM tool_usage WHERE request_status = 'success'
  GROUP BY user_id
) usage ON usage.user_id = p.id;

-- NRR (Net Revenue Retention) — monthly
CREATE OR REPLACE VIEW admin_nrr AS
WITH monthly_revenue AS (
  SELECT
    date_trunc('month', s.created_at)::date AS month,
    s.user_id,
    SUM(COALESCE(s.price_usd, p.price_usd, 0)) AS revenue
  FROM subscriptions s
  LEFT JOIN pricing_tiers p ON p.tier = s.tier AND p.billing_cycle = s.billing_cycle AND p.effective_to IS NULL
  WHERE s.status = 'active'
  GROUP BY date_trunc('month', s.created_at), s.user_id
)
SELECT
  month,
  COUNT(DISTINCT user_id) AS paying_users,
  SUM(revenue) AS total_mrr
FROM monthly_revenue
GROUP BY month
ORDER BY month DESC;

-- Event analytics (page views, clicks, feature usage)
CREATE OR REPLACE VIEW admin_event_summary AS
SELECT
  event_name,
  date_trunc('day', created_at)::date AS day,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(DISTINCT session_id) FILTER (WHERE session_id != '') AS unique_sessions
FROM events
WHERE created_at >= now() - interval '30 days'
GROUP BY event_name, date_trunc('day', created_at)
ORDER BY day DESC, event_count DESC;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  7. RPC: update last_active_at (called from frontend on each page)     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE OR REPLACE FUNCTION update_last_active(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET last_active_at = now() WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: log event (called from frontend)
CREATE OR REPLACE FUNCTION log_event(
  p_user_id    UUID,
  p_event_name TEXT,
  p_page       TEXT DEFAULT '',
  p_vertical   TEXT DEFAULT '',
  p_metadata   JSONB DEFAULT '{}',
  p_session_id TEXT DEFAULT ''
)
RETURNS void AS $$
BEGIN
  INSERT INTO events (user_id, event_name, page, vertical, metadata, session_id)
  VALUES (p_user_id, p_event_name, p_page, p_vertical, p_metadata, p_session_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================================
-- DONE. All analytics tables, columns, views and RPCs are in place.
-- ============================================================================

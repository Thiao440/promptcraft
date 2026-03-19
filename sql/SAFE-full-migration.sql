-- ============================================================================
-- THE PROMPT STUDIO — SAFE FULL MIGRATION (idempotent, zero data loss)
-- ============================================================================
-- This file can be run MULTIPLE TIMES safely.
-- It NEVER drops tables, NEVER deletes data, NEVER truncates.
-- It only adds what's missing using IF NOT EXISTS / IF NOT FOUND patterns.
--
-- Run this in Supabase SQL Editor to bring the DB up to date.
-- ============================================================================


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 1 — CORE TABLES (create if missing)                              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Profiles
CREATE TABLE IF NOT EXISTS profiles (
  id                     UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email                  TEXT,
  first_name             TEXT DEFAULT '',
  last_name              TEXT DEFAULT '',
  full_name              TEXT DEFAULT '',
  phone                  TEXT DEFAULT '',
  job_title              TEXT DEFAULT '',
  company_name           TEXT DEFAULT '',
  billing_address_line1  TEXT DEFAULT '',
  billing_city           TEXT DEFAULT '',
  billing_postal_code    TEXT DEFAULT '',
  profile_completed_at   TIMESTAMPTZ,
  active_session_id      UUID,
  updated_at             TIMESTAMPTZ DEFAULT now()
);

-- Subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vertical            TEXT NOT NULL,
  tier                TEXT NOT NULL DEFAULT 'starter',
  status              TEXT NOT NULL DEFAULT 'active',
  lemon_subscription_id TEXT,
  lemon_customer_id   TEXT,
  current_period_end  TIMESTAMPTZ,
  created_at          TIMESTAMPTZ DEFAULT now(),
  updated_at          TIMESTAMPTZ DEFAULT now()
);

-- Tools catalog
CREATE TABLE IF NOT EXISTS tools (
  slug           TEXT PRIMARY KEY,
  name           TEXT NOT NULL DEFAULT '',
  label          TEXT DEFAULT '',
  description    TEXT DEFAULT '',
  icon           TEXT DEFAULT '🔧',
  vertical       TEXT NOT NULL DEFAULT '',
  min_tier       TEXT NOT NULL DEFAULT 'starter',
  is_active      BOOLEAN NOT NULL DEFAULT true,
  is_featured    BOOLEAN DEFAULT false,
  is_new         BOOLEAN DEFAULT false,
  sort_order     INT DEFAULT 0,
  category       TEXT DEFAULT '',
  input_schema   JSONB,
  system_prompt  TEXT,
  prompt_template TEXT,
  max_output_tokens INT,
  generate_label TEXT,
  loading_text   TEXT,
  empty_state_icon TEXT,
  empty_state_title TEXT,
  empty_state_text TEXT,
  form_panel_title TEXT,
  created_at     TIMESTAMPTZ DEFAULT now()
);

-- Tool usage / generation history
CREATE TABLE IF NOT EXISTS tool_usage (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tool_slug    TEXT,
  input_data   JSONB DEFAULT '{}',
  output_text  TEXT DEFAULT '',
  tokens_used  INT DEFAULT 0,
  duration_ms  INT DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Usage quotas (monthly generation counters)
CREATE TABLE IF NOT EXISTS usage_quotas (
  id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id  UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  month    TEXT NOT NULL,
  count    INT NOT NULL DEFAULT 0
);


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 2 — SAFE COLUMN ADDITIONS (add only if missing)                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- tool_usage: usage tracking upgrade
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS input_tokens       INT DEFAULT 0;
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS output_tokens      INT DEFAULT 0;
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS model              TEXT DEFAULT '';
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS vertical           TEXT DEFAULT '';
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS estimated_cost_usd NUMERIC(10,6) DEFAULT 0;
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS request_status     TEXT DEFAULT 'success';
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS project_id         UUID;

-- usage_quotas: per-vertical tracking
ALTER TABLE usage_quotas ADD COLUMN IF NOT EXISTS vertical TEXT DEFAULT '';

-- subscriptions: extra fields
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS lemon_variant_id TEXT;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 3 — CRM PROJECTS                                                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE TABLE IF NOT EXISTS projects (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vertical     TEXT NOT NULL,
  name         TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'active',
  data         JSONB NOT NULL DEFAULT '{}',
  notes        TEXT DEFAULT '',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS project_field_templates (
  id         SERIAL PRIMARY KEY,
  vertical   TEXT NOT NULL,
  field_key  TEXT NOT NULL,
  label      TEXT NOT NULL,
  type       TEXT NOT NULL DEFAULT 'text',
  placeholder TEXT DEFAULT '',
  options    JSONB DEFAULT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  required   BOOLEAN NOT NULL DEFAULT false,
  UNIQUE (vertical, field_key)
);

CREATE TABLE IF NOT EXISTS project_tool_mappings (
  id            SERIAL PRIMARY KEY,
  vertical      TEXT NOT NULL,
  tool_slug     TEXT NOT NULL,
  project_field TEXT NOT NULL,
  tool_field    TEXT NOT NULL,
  UNIQUE (vertical, tool_slug, project_field)
);


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 4 — FEEDBACK SYSTEM                                              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE TABLE IF NOT EXISTS bug_reports (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tool_slug    TEXT,
  vertical     TEXT,
  category     TEXT NOT NULL DEFAULT 'bug',
  severity     TEXT NOT NULL DEFAULT 'medium',
  title        TEXT NOT NULL,
  description  TEXT NOT NULL,
  steps        TEXT,
  expected     TEXT,
  actual       TEXT,
  browser_info JSONB DEFAULT '{}',
  console_logs JSONB DEFAULT '[]',
  tool_state   JSONB DEFAULT '{}',
  page_url     TEXT,
  screenshot   TEXT,
  status       TEXT NOT NULL DEFAULT 'new',
  admin_notes  TEXT DEFAULT '',
  resolved_at  TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tool_suggestions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vertical         TEXT NOT NULL,
  category         TEXT DEFAULT '',
  tool_name        TEXT NOT NULL,
  description      TEXT NOT NULL,
  use_case         TEXT,
  frequency        TEXT DEFAULT 'weekly',
  priority         TEXT DEFAULT 'nice_to_have',
  current_solution TEXT,
  pain_points      TEXT,
  example_input    TEXT,
  example_output   TEXT,
  competitors      TEXT,
  user_vertical    TEXT,
  user_tier        TEXT,
  user_job         TEXT,
  vote_count       INT NOT NULL DEFAULT 1,
  status           TEXT NOT NULL DEFAULT 'new',
  admin_notes      TEXT DEFAULT '',
  shipped_slug     TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS suggestion_votes (
  suggestion_id UUID NOT NULL REFERENCES tool_suggestions(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (suggestion_id, user_id)
);


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 5 — INDEXES (all IF NOT EXISTS, safe to re-run)                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- tool_usage
CREATE INDEX IF NOT EXISTS idx_tool_usage_user_slug     ON tool_usage (user_id, tool_slug);
CREATE INDEX IF NOT EXISTS idx_tool_usage_vertical      ON tool_usage (vertical);
CREATE INDEX IF NOT EXISTS idx_tool_usage_model         ON tool_usage (model);
CREATE INDEX IF NOT EXISTS idx_tool_usage_status        ON tool_usage (request_status);
CREATE INDEX IF NOT EXISTS idx_tool_usage_cost          ON tool_usage (estimated_cost_usd DESC);
CREATE INDEX IF NOT EXISTS idx_tool_usage_created_at    ON tool_usage (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tool_usage_project       ON tool_usage (project_id) WHERE project_id IS NOT NULL;

-- projects
CREATE INDEX IF NOT EXISTS idx_projects_user_vertical   ON projects (user_id, vertical);
CREATE INDEX IF NOT EXISTS idx_projects_status          ON projects (user_id, status);
CREATE INDEX IF NOT EXISTS idx_projects_updated         ON projects (user_id, updated_at DESC);

-- bug_reports
CREATE INDEX IF NOT EXISTS idx_bug_reports_user         ON bug_reports (user_id);
CREATE INDEX IF NOT EXISTS idx_bug_reports_tool         ON bug_reports (tool_slug);
CREATE INDEX IF NOT EXISTS idx_bug_reports_status       ON bug_reports (status);

-- tool_suggestions
CREATE INDEX IF NOT EXISTS idx_suggestions_vertical     ON tool_suggestions (vertical);
CREATE INDEX IF NOT EXISTS idx_suggestions_status       ON tool_suggestions (status);
CREATE INDEX IF NOT EXISTS idx_suggestions_votes        ON tool_suggestions (vote_count DESC);

-- usage_quotas (new per-vertical index)
CREATE INDEX IF NOT EXISTS idx_usage_quotas_user_month_vertical
  ON usage_quotas (user_id, month, vertical);


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 6 — USAGE QUOTAS: per-vertical unique constraint                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Safely migrate from (user_id, month) to (user_id, month, vertical)
-- Only drops the old constraint if the new one doesn't exist yet.
DO $$
BEGIN
  -- Check if new constraint already exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'uq_usage_quotas_user_month_vertical'
  ) THEN
    -- Drop old unique constraint (name may vary)
    DECLARE _cname TEXT;
    BEGIN
      SELECT conname INTO _cname
        FROM pg_constraint
       WHERE conrelid = 'usage_quotas'::regclass
         AND contype = 'u'
         AND conname != 'uq_usage_quotas_user_month_vertical'
       LIMIT 1;
      IF _cname IS NOT NULL THEN
        EXECUTE 'ALTER TABLE usage_quotas DROP CONSTRAINT ' || _cname;
      END IF;
    END;
    -- Add new constraint
    ALTER TABLE usage_quotas
      ADD CONSTRAINT uq_usage_quotas_user_month_vertical
      UNIQUE (user_id, month, vertical);
  END IF;
END $$;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 7 — ROW LEVEL SECURITY (idempotent)                              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE tool_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_quotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_field_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_tool_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE bug_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE tool_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE suggestion_votes ENABLE ROW LEVEL SECURITY;

-- Profiles
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'profiles_select' AND tablename = 'profiles') THEN
    CREATE POLICY profiles_select ON profiles FOR SELECT USING (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'profiles_update' AND tablename = 'profiles') THEN
    CREATE POLICY profiles_update ON profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'profiles_insert' AND tablename = 'profiles') THEN
    CREATE POLICY profiles_insert ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;
END $$;

-- Subscriptions
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'subs_select' AND tablename = 'subscriptions') THEN
    CREATE POLICY subs_select ON subscriptions FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

-- Tools (public read)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'tools_select' AND tablename = 'tools') THEN
    CREATE POLICY tools_select ON tools FOR SELECT USING (true);
  END IF;
END $$;

-- Tool usage
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'tu_select' AND tablename = 'tool_usage') THEN
    CREATE POLICY tu_select ON tool_usage FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

-- Usage quotas
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'uq_select' AND tablename = 'usage_quotas') THEN
    CREATE POLICY uq_select ON usage_quotas FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

-- Projects
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'projects_select' AND tablename = 'projects') THEN
    CREATE POLICY projects_select ON projects FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'projects_insert' AND tablename = 'projects') THEN
    CREATE POLICY projects_insert ON projects FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'projects_update' AND tablename = 'projects') THEN
    CREATE POLICY projects_update ON projects FOR UPDATE USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'projects_delete' AND tablename = 'projects') THEN
    CREATE POLICY projects_delete ON projects FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- Project field templates (public read)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'pft_select' AND tablename = 'project_field_templates') THEN
    CREATE POLICY pft_select ON project_field_templates FOR SELECT USING (true);
  END IF;
END $$;

-- Project tool mappings (public read)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'ptm_select' AND tablename = 'project_tool_mappings') THEN
    CREATE POLICY ptm_select ON project_tool_mappings FOR SELECT USING (true);
  END IF;
END $$;

-- Bug reports
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'br_select' AND tablename = 'bug_reports') THEN
    CREATE POLICY br_select ON bug_reports FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'br_insert' AND tablename = 'bug_reports') THEN
    CREATE POLICY br_insert ON bug_reports FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- Tool suggestions (public read for roadmap)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'ts_select' AND tablename = 'tool_suggestions') THEN
    CREATE POLICY ts_select ON tool_suggestions FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'ts_insert' AND tablename = 'tool_suggestions') THEN
    CREATE POLICY ts_insert ON tool_suggestions FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- Suggestion votes
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'sv_select' AND tablename = 'suggestion_votes') THEN
    CREATE POLICY sv_select ON suggestion_votes FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'sv_insert' AND tablename = 'suggestion_votes') THEN
    CREATE POLICY sv_insert ON suggestion_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'sv_delete' AND tablename = 'suggestion_votes') THEN
    CREATE POLICY sv_delete ON suggestion_votes FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 8 — FUNCTIONS / RPCs (CREATE OR REPLACE = safe)                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Auto-update timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

-- Apply to tables that have updated_at
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_projects_updated_at') THEN
    CREATE TRIGGER trg_projects_updated_at BEFORE UPDATE ON projects
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bug_reports_ts') THEN
    CREATE TRIGGER trg_bug_reports_ts BEFORE UPDATE ON bug_reports
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_suggestions_ts') THEN
    CREATE TRIGGER trg_suggestions_ts BEFORE UPDATE ON tool_suggestions
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- Increment usage quota (per vertical)
CREATE OR REPLACE FUNCTION increment_usage_quota(
  p_user_id  UUID,
  p_month    TEXT,
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

-- Session management RPCs
CREATE OR REPLACE FUNCTION claim_session(p_user_id UUID, p_session_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET active_session_id = p_session_id WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION check_session(p_user_id UUID, p_session_id UUID)
RETURNS BOOLEAN AS $$
DECLARE current_sid UUID;
BEGIN
  SELECT active_session_id INTO current_sid FROM profiles WHERE id = p_user_id;
  RETURN current_sid IS NOT NULL AND current_sid = p_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Suggestion votes
CREATE OR REPLACE FUNCTION vote_suggestion(p_suggestion_id UUID, p_user_id UUID)
RETURNS void AS $$
BEGIN
  INSERT INTO suggestion_votes (suggestion_id, user_id) VALUES (p_suggestion_id, p_user_id);
  UPDATE tool_suggestions SET vote_count = vote_count + 1 WHERE id = p_suggestion_id;
EXCEPTION WHEN unique_violation THEN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION unvote_suggestion(p_suggestion_id UUID, p_user_id UUID)
RETURNS void AS $$
BEGIN
  DELETE FROM suggestion_votes WHERE suggestion_id = p_suggestion_id AND user_id = p_user_id;
  IF FOUND THEN
    UPDATE tool_suggestions SET vote_count = vote_count - 1 WHERE id = p_suggestion_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Track login (optional)
CREATE OR REPLACE FUNCTION track_login(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET updated_at = now() WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PART 9 — ADMIN VIEWS (CREATE OR REPLACE = safe, no data impact)       ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE OR REPLACE VIEW admin_cost_per_user AS
SELECT user_id, date_trunc('month', created_at)::date AS month,
  COUNT(*) AS total_requests,
  COUNT(*) FILTER (WHERE request_status = 'success') AS success_count,
  COUNT(*) FILTER (WHERE request_status = 'error') AS error_count,
  SUM(input_tokens) AS total_input_tokens, SUM(output_tokens) AS total_output_tokens,
  SUM(tokens_used) AS total_tokens, SUM(estimated_cost_usd) AS total_cost_usd,
  AVG(duration_ms)::int AS avg_duration_ms
FROM tool_usage GROUP BY user_id, date_trunc('month', created_at);

CREATE OR REPLACE VIEW admin_cost_per_vertical AS
SELECT vertical, date_trunc('month', created_at)::date AS month,
  COUNT(*) AS total_requests, COUNT(DISTINCT user_id) AS unique_users,
  SUM(input_tokens) AS total_input_tokens, SUM(output_tokens) AS total_output_tokens,
  SUM(tokens_used) AS total_tokens, SUM(estimated_cost_usd) AS total_cost_usd,
  AVG(duration_ms)::int AS avg_duration_ms
FROM tool_usage WHERE request_status = 'success'
GROUP BY vertical, date_trunc('month', created_at);

CREATE OR REPLACE VIEW admin_cost_per_tool AS
SELECT tool_slug, vertical, date_trunc('month', created_at)::date AS month,
  COUNT(*) AS total_requests, COUNT(DISTINCT user_id) AS unique_users,
  SUM(input_tokens) AS total_input_tokens, SUM(output_tokens) AS total_output_tokens,
  SUM(tokens_used) AS total_tokens, SUM(estimated_cost_usd) AS total_cost_usd,
  AVG(duration_ms)::int AS avg_duration_ms, AVG(estimated_cost_usd) AS avg_cost_per_request
FROM tool_usage WHERE request_status = 'success'
GROUP BY tool_slug, vertical, date_trunc('month', created_at);

CREATE OR REPLACE VIEW admin_top_users AS
SELECT user_id, COUNT(*) AS request_count,
  SUM(tokens_used) AS total_tokens, SUM(estimated_cost_usd) AS total_cost_usd,
  AVG(duration_ms)::int AS avg_duration_ms, MAX(created_at) AS last_request_at
FROM tool_usage WHERE request_status = 'success' AND created_at >= date_trunc('month', now())
GROUP BY user_id ORDER BY total_cost_usd DESC;

CREATE OR REPLACE VIEW admin_failed_requests AS
SELECT id, user_id, tool_slug, vertical, model, output_text AS error_message,
  duration_ms, created_at
FROM tool_usage WHERE request_status IN ('error', 'timeout')
ORDER BY created_at DESC LIMIT 200;

CREATE OR REPLACE VIEW admin_monthly_summary AS
SELECT date_trunc('month', created_at)::date AS month,
  COUNT(*) AS total_requests, COUNT(DISTINCT user_id) AS active_users,
  COUNT(DISTINCT tool_slug) AS tools_used, COUNT(DISTINCT vertical) AS verticals_used,
  SUM(tokens_used) AS total_tokens, SUM(estimated_cost_usd) AS total_cost_usd,
  AVG(estimated_cost_usd) AS avg_cost_per_request,
  COUNT(*) FILTER (WHERE request_status = 'error') AS error_count,
  ROUND(100.0 * COUNT(*) FILTER (WHERE request_status = 'success') / NULLIF(COUNT(*), 0), 1) AS success_rate_pct
FROM tool_usage GROUP BY date_trunc('month', created_at) ORDER BY month DESC;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  DONE — All tables, columns, indexes, RLS, RPCs and views are up      ║
-- ║  to date. This migration is safe to run multiple times.                ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

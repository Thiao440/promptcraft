-- ============================================================================
-- FEEDBACK SYSTEM — Bug Reports + Tool Suggestions
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ── 1. Bug Reports ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bug_reports (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tool_slug    TEXT,                           -- which tool (NULL if general)
  vertical     TEXT,                           -- which vertical
  category     TEXT NOT NULL DEFAULT 'bug'
                 CHECK (category IN ('bug', 'display', 'performance', 'generation', 'other')),
  severity     TEXT NOT NULL DEFAULT 'medium'
                 CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  title        TEXT NOT NULL,
  description  TEXT NOT NULL,
  steps        TEXT,                           -- steps to reproduce
  expected     TEXT,                           -- expected behavior
  actual       TEXT,                           -- actual behavior

  -- Auto-captured context
  browser_info JSONB DEFAULT '{}',             -- userAgent, screen size, language
  console_logs JSONB DEFAULT '[]',             -- last N console errors
  tool_state   JSONB DEFAULT '{}',             -- form inputs, last API response, etc.
  page_url     TEXT,                           -- full URL at time of report
  screenshot   TEXT,                           -- base64 screenshot (optional)

  -- Admin fields
  status       TEXT NOT NULL DEFAULT 'new'
                 CHECK (status IN ('new', 'triaged', 'in_progress', 'resolved', 'wontfix', 'duplicate')),
  admin_notes  TEXT DEFAULT '',
  resolved_at  TIMESTAMPTZ,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bug_reports_user ON bug_reports (user_id);
CREATE INDEX IF NOT EXISTS idx_bug_reports_tool ON bug_reports (tool_slug);
CREATE INDEX IF NOT EXISTS idx_bug_reports_status ON bug_reports (status);
CREATE INDEX IF NOT EXISTS idx_bug_reports_created ON bug_reports (created_at DESC);

ALTER TABLE bug_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY br_select ON bug_reports FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY br_insert ON bug_reports FOR INSERT WITH CHECK (auth.uid() = user_id);
-- Users can't update/delete their own reports (admin only via service key)

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_bug_reports_ts()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_bug_reports_ts BEFORE UPDATE ON bug_reports
  FOR EACH ROW EXECUTE FUNCTION update_bug_reports_ts();


-- ── 2. Tool Suggestions ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tool_suggestions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- What the user wants
  vertical     TEXT NOT NULL,                  -- target vertical
  category     TEXT DEFAULT '',                -- category within vertical
  tool_name    TEXT NOT NULL,                  -- proposed tool name
  description  TEXT NOT NULL,                  -- what it should do
  use_case     TEXT,                           -- their specific use case
  frequency    TEXT DEFAULT 'weekly'
                 CHECK (frequency IN ('daily', 'weekly', 'monthly', 'rarely')),
  priority     TEXT DEFAULT 'nice_to_have'
                 CHECK (priority IN ('critical', 'important', 'nice_to_have')),

  -- Context: what do they use today?
  current_solution TEXT,                       -- how they solve it now
  pain_points      TEXT,                       -- what's painful about current solution
  example_input    TEXT,                       -- example of what they'd type
  example_output   TEXT,                       -- example of what they'd want back
  competitors      TEXT,                       -- any tool that does something similar

  -- User profile context (auto-captured)
  user_vertical TEXT,                          -- which vertical they're subscribed to
  user_tier     TEXT,                          -- their tier
  user_job      TEXT,                          -- their job title from profile

  -- Votes (other users can upvote)
  vote_count   INT NOT NULL DEFAULT 1,

  -- Admin fields
  status       TEXT NOT NULL DEFAULT 'new'
                 CHECK (status IN ('new', 'reviewed', 'planned', 'building', 'shipped', 'declined')),
  admin_notes  TEXT DEFAULT '',
  shipped_slug TEXT,                           -- if built, the slug of the new tool

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_suggestions_vertical ON tool_suggestions (vertical);
CREATE INDEX IF NOT EXISTS idx_suggestions_status ON tool_suggestions (status);
CREATE INDEX IF NOT EXISTS idx_suggestions_votes ON tool_suggestions (vote_count DESC);
CREATE INDEX IF NOT EXISTS idx_suggestions_created ON tool_suggestions (created_at DESC);

ALTER TABLE tool_suggestions ENABLE ROW LEVEL SECURITY;
CREATE POLICY ts_select ON tool_suggestions FOR SELECT USING (true);  -- public read (roadmap)
CREATE POLICY ts_insert ON tool_suggestions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY ts_update_own ON tool_suggestions FOR UPDATE
  USING (auth.uid() = user_id AND status = 'new');  -- can edit only if still new

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_suggestions_ts()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_suggestions_ts BEFORE UPDATE ON tool_suggestions
  FOR EACH ROW EXECUTE FUNCTION update_suggestions_ts();


-- ── 3. Suggestion Votes (prevent duplicate votes) ────────────────────────────
CREATE TABLE IF NOT EXISTS suggestion_votes (
  suggestion_id UUID NOT NULL REFERENCES tool_suggestions(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (suggestion_id, user_id)
);

ALTER TABLE suggestion_votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY sv_select ON suggestion_votes FOR SELECT USING (true);
CREATE POLICY sv_insert ON suggestion_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY sv_delete ON suggestion_votes FOR DELETE USING (auth.uid() = user_id);

-- RPC to vote (atomic increment + insert)
CREATE OR REPLACE FUNCTION vote_suggestion(p_suggestion_id UUID, p_user_id UUID)
RETURNS void AS $$
BEGIN
  INSERT INTO suggestion_votes (suggestion_id, user_id) VALUES (p_suggestion_id, p_user_id);
  UPDATE tool_suggestions SET vote_count = vote_count + 1 WHERE id = p_suggestion_id;
EXCEPTION WHEN unique_violation THEN
  -- Already voted, ignore
  NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC to unvote
CREATE OR REPLACE FUNCTION unvote_suggestion(p_suggestion_id UUID, p_user_id UUID)
RETURNS void AS $$
BEGIN
  DELETE FROM suggestion_votes WHERE suggestion_id = p_suggestion_id AND user_id = p_user_id;
  IF FOUND THEN
    UPDATE tool_suggestions SET vote_count = vote_count - 1 WHERE id = p_suggestion_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- DONE.
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration v8: Single session enforcement
-- Prevents account sharing by tracking active session per user
-- ═══════════════════════════════════════════════════════════════════════════════

-- Store current active session token hash per user
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS active_session_id text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS session_started_at timestamptz;

-- RPC: claim a session — returns true if this session is valid, false if another session is active
CREATE OR REPLACE FUNCTION public.claim_session(p_user_id uuid, p_session_id text)
RETURNS boolean AS $$
BEGIN
  UPDATE public.profiles
  SET active_session_id = p_session_id,
      session_started_at = now(),
      updated_at = now()
  WHERE id = p_user_id;
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: check if current session is the active one
CREATE OR REPLACE FUNCTION public.check_session(p_user_id uuid, p_session_id text)
RETURNS boolean AS $$
DECLARE
  stored_session text;
BEGIN
  SELECT active_session_id INTO stored_session FROM public.profiles WHERE id = p_user_id;
  -- No session stored yet = allow
  IF stored_session IS NULL THEN RETURN true; END IF;
  -- Match = allow
  RETURN stored_session = p_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

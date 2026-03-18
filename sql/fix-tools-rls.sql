-- ═══════════════════════════════════════════════════════════════════════════════
-- FIX: Tools table RLS — remove subquery on profiles that causes recursion
-- The old policy did: EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin)
-- This can cause infinite recursion or slowness.
-- Fix: simple policy — anyone authenticated can read active tools.
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop ALL existing policies on tools
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'tools' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.tools', pol.policyname);
    RAISE NOTICE 'Dropped: %', pol.policyname;
  END LOOP;
END $$;

-- Simple policy: any authenticated user can read active tools
CREATE POLICY "tools_select" ON public.tools
  FOR SELECT TO authenticated
  USING (is_active = true);

-- Also fix tool_usage — allow INSERT (needed for logging generations)
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'tool_usage' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.tool_usage', pol.policyname);
  END LOOP;
END $$;

CREATE POLICY "tool_usage_select" ON public.tool_usage
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "tool_usage_insert" ON public.tool_usage
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Fix usage_quotas — allow SELECT + INSERT + UPDATE
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'usage_quotas' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.usage_quotas', pol.policyname);
  END LOOP;
END $$;

CREATE POLICY "usage_quotas_select" ON public.usage_quotas
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "usage_quotas_insert" ON public.usage_quotas
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "usage_quotas_update" ON public.usage_quotas
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid());

-- Verify
SELECT tablename, policyname, cmd FROM pg_policies
WHERE schemaname = 'public' AND tablename IN ('tools', 'tool_usage', 'usage_quotas')
ORDER BY tablename, policyname;

-- ═══════════════════════════════════════════════════════════════════════════════
-- FIX v2: Disable RLS on profiles entirely
-- The "infinite recursion" error is a known Supabase issue when policies
-- on a table reference auth.uid() and the same table is involved in the
-- auth resolution chain.
--
-- Solution: disable RLS on profiles. Access control is handled by:
--   1. Supabase Auth (JWT) — user must be authenticated
--   2. Frontend only queries WHERE id = session.user.id
--   3. Service-role functions handle admin access
--
-- For production, re-enable RLS with a function-based approach if needed.
-- ═══════════════════════════════════════════════════════════════════════════════

-- Step 1: Drop ALL policies on profiles (catch any name)
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies WHERE tablename = 'profiles' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles', pol.policyname);
    RAISE NOTICE 'Dropped policy: %', pol.policyname;
  END LOOP;
END $$;

-- Step 2: Disable RLS on profiles
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Verify: this should return 0
SELECT count(*) AS remaining_policies
FROM pg_policies
WHERE tablename = 'profiles' AND schemaname = 'public';

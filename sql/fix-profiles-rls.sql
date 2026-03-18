-- ═══════════════════════════════════════════════════════════════════════════════
-- FIX: Profiles RLS — resolve "infinite recursion detected in policy"
--
-- Problem: RLS policies on profiles use auth.uid() = id which creates recursion
-- when Supabase internally checks policies during INSERT/UPSERT operations.
--
-- Solution: Drop all existing policies, re-create simple non-recursive ones,
-- and add INSERT policy so users can create their own profile row.
-- ═══════════════════════════════════════════════════════════════════════════════

-- Enable RLS (idempotent)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies on profiles to start clean
DROP POLICY IF EXISTS "Users read own profile"     ON public.profiles;
DROP POLICY IF EXISTS "Users update own profile"   ON public.profiles;
DROP POLICY IF EXISTS "Users can read own profile"  ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Anyone can read profiles"   ON public.profiles;
DROP POLICY IF EXISTS "profiles_select"            ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert"            ON public.profiles;
DROP POLICY IF EXISTS "profiles_update"            ON public.profiles;

-- ── New clean policies ───────────────────────────────────────────────────────

-- SELECT: user can read their own profile
CREATE POLICY "profiles_select" ON public.profiles
  FOR SELECT TO authenticated
  USING ( id = auth.uid() );

-- INSERT: user can create their own profile row (needed for upsert fallback)
CREATE POLICY "profiles_insert" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK ( id = auth.uid() );

-- UPDATE: user can update their own profile
CREATE POLICY "profiles_update" ON public.profiles
  FOR UPDATE TO authenticated
  USING ( id = auth.uid() )
  WITH CHECK ( id = auth.uid() );

-- ── Verify ───────────────────────────────────────────────────────────────────
-- After running this, test in Supabase SQL Editor:
--   SELECT * FROM public.profiles WHERE id = auth.uid();
-- Should return the current user's profile without recursion error.

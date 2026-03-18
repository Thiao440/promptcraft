-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration v7: Complete User Profiles
-- Purpose: Full user profiles for billing, analytics, segmentation, CRM
-- Safe to run multiple times (all ALTER TABLE IF NOT EXISTS)
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. PERSONAL IDENTITY ────────────────────────────────────────────────────
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS first_name      text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_name       text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone           text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url      text;

-- ─── 2. PROFESSIONAL INFO ────────────────────────────────────────────────────
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS job_title       text;       -- ex: 'Agent immobilier', 'Avocat', 'CMO'
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS company_name    text;       -- ex: 'Agence Dupont Immobilier'
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS company_size    text;       -- 'solo', '2-10', '11-50', '51-200', '200+'
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS industry        text;       -- maps to verticals: 'immo', 'legal', 'finance'...
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS website         text;

-- ─── 3. BILLING ADDRESS ──────────────────────────────────────────────────────
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS billing_address_line1  text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS billing_address_line2  text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS billing_city          text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS billing_postal_code   text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS billing_country       text DEFAULT 'FR';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS billing_vat_number    text;  -- TVA intra-communautaire

-- ─── 4. ANALYTICS & TRACKING ────────────────────────────────────────────────
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS signup_source    text;      -- 'organic', 'google', 'linkedin', 'referral', 'product_hunt'
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS signup_campaign  text;      -- UTM campaign parameter
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS referral_code    text;      -- who referred this user
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS first_vertical   text;      -- first vertical the user subscribed to
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS first_tool_used  text;      -- slug of the first tool used

-- ─── 5. ENGAGEMENT & LIFECYCLE ───────────────────────────────────────────────
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_login_at        timestamptz;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS login_count          integer DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS total_generations    integer DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS profile_completed_at timestamptz;  -- NULL = profile not yet completed
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS onboarding_step     integer DEFAULT 0; -- 0=new, 1=profile, 2=first_tool, 3=done

-- ─── 6. PREFERENCES ─────────────────────────────────────────────────────────
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS newsletter_optin boolean DEFAULT true;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS timezone         text DEFAULT 'Europe/Paris';

-- ─── 7. UPDATE TRIGGER FUNCTION ──────────────────────────────────────────────
-- Auto-populate profile from auth.users metadata on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id, email, full_name, first_name, last_name, preferred_lang
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'first_name', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'last_name', ''),
    'fr'
  )
  ON CONFLICT (id) DO UPDATE SET
    email      = EXCLUDED.email,
    full_name  = COALESCE(NULLIF(EXCLUDED.full_name, ''), public.profiles.full_name),
    first_name = COALESCE(NULLIF(EXCLUDED.first_name, ''), public.profiles.first_name),
    last_name  = COALESCE(NULLIF(EXCLUDED.last_name, ''), public.profiles.last_name),
    updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── 8. LOGIN TRACKING FUNCTION ─────────────────────────────────────────────
-- Call this RPC from the frontend on each login to track engagement
CREATE OR REPLACE FUNCTION public.track_login(p_user_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET last_login_at = now(),
      login_count   = COALESCE(login_count, 0) + 1,
      updated_at    = now()
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── 9. INDEXES FOR ANALYTICS QUERIES ───────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_profiles_industry    ON public.profiles(industry)    WHERE industry IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_company     ON public.profiles(company_size) WHERE company_size IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_signup_src  ON public.profiles(signup_source) WHERE signup_source IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_onboarding  ON public.profiles(onboarding_step);
CREATE INDEX IF NOT EXISTS idx_profiles_last_login  ON public.profiles(last_login_at DESC);

-- ─── 10. RLS ─────────────────────────────────────────────────────────────────
-- Users can read and update their own profile only
DROP POLICY IF EXISTS "Users read own profile"   ON public.profiles;
DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;

CREATE POLICY "Users read own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ═══════════════════════════════════════════════════════════════════════════════
-- DONE
-- After running this migration:
--   1. Existing profiles get new columns with NULL/defaults
--   2. New signups auto-populate first_name, last_name, email
--   3. Frontend checks profile_completed_at to show completion modal
--   4. track_login() should be called from ps-auth.js on each init()
-- ═══════════════════════════════════════════════════════════════════════════════

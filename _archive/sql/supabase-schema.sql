-- ═══════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Supabase Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Run
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. User Products Table ───────────────────────────────────────────────
-- Tracks which products each user has purchased/subscribed to

CREATE TABLE IF NOT EXISTS public.user_products (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_slug            text NOT NULL,
    -- 'immo' | 'commerce' | 'legal' | 'pro'
  status                  text NOT NULL DEFAULT 'active',
    -- 'active' | 'cancelled' | 'refunded' | 'expired'
  lemon_order_id          text,           -- for one-time purchases
  lemon_subscription_id   text,           -- for recurring subscriptions
  purchased_at            timestamptz NOT NULL DEFAULT now(),
  expires_at              timestamptz,    -- NULL = lifetime access
  updated_at              timestamptz NOT NULL DEFAULT now(),

  -- Prevent duplicate active entries per user+product
  UNIQUE (user_id, product_slug)
);

-- Index for fast lookups by user
CREATE INDEX IF NOT EXISTS idx_user_products_user_id
  ON public.user_products(user_id);

-- Index for fast lookups by subscription ID (for webhook updates)
CREATE INDEX IF NOT EXISTS idx_user_products_sub_id
  ON public.user_products(lemon_subscription_id)
  WHERE lemon_subscription_id IS NOT NULL;

-- Index for fast lookups by order ID (for refund handling)
CREATE INDEX IF NOT EXISTS idx_user_products_order_id
  ON public.user_products(lemon_order_id)
  WHERE lemon_order_id IS NOT NULL;

-- ─── 2. Download Logs Table ───────────────────────────────────────────────
-- Audit trail: who downloaded what and when

CREATE TABLE IF NOT EXISTS public.download_logs (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  filename        text NOT NULL,
  downloaded_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_download_logs_user_id
  ON public.download_logs(user_id);

-- ─── 3. User Profiles Table ───────────────────────────────────────────────
-- Extended profile info (name, preferred language, etc.)
-- Automatically created on user signup via trigger

CREATE TABLE IF NOT EXISTS public.profiles (
  id              uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name       text,
  preferred_lang  text DEFAULT 'fr',
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Trigger: auto-create profile when a new user is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'full_name'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ─── 4. Row Level Security (RLS) ─────────────────────────────────────────
-- Users can only read their own data. Service role (webhook) can write all.

ALTER TABLE public.user_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.download_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles       ENABLE ROW LEVEL SECURITY;

-- user_products: users can see their own products
DROP POLICY IF EXISTS "Users can view own products" ON public.user_products;
CREATE POLICY "Users can view own products"
  ON public.user_products FOR SELECT
  USING (auth.uid() = user_id);

-- Only service role can insert/update (via webhook)
-- (No INSERT/UPDATE policy = only service_role can write)

-- download_logs: users can view their own logs
DROP POLICY IF EXISTS "Users can view own download logs" ON public.download_logs;
CREATE POLICY "Users can view own download logs"
  ON public.download_logs FOR SELECT
  USING (auth.uid() = user_id);

-- profiles: users can view and update their own profile
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- ─── 5. Supabase Storage: "downloads" bucket ─────────────────────────────
-- Run AFTER creating the bucket in Storage UI (set to Private)
-- This SQL just grants service role access (already default for private buckets)

-- NOTE: Create the bucket manually in:
--   Supabase Dashboard → Storage → New bucket
--   Name: downloads
--   Public: OFF (private)
-- Then upload your 3 PDF files to this bucket.

-- ─── 6. Helper view: active user products ────────────────────────────────
-- Convenient view that auto-filters expired subscriptions

CREATE OR REPLACE VIEW public.active_user_products AS
  SELECT
    up.*,
    p.full_name,
    u.email
  FROM public.user_products up
  JOIN auth.users u ON u.id = up.user_id
  LEFT JOIN public.profiles p ON p.id = up.user_id
  WHERE
    up.status = 'active'
    AND (up.expires_at IS NULL OR up.expires_at > now());

-- Only service role can access this view
-- (add RLS if you want users to query it via client)

-- ─── Done! ────────────────────────────────────────────────────────────────
-- After running this schema, go to:
--   Storage → Create bucket "downloads" (private)
--   Storage → Upload the 3 PDF files
--   Authentication → Email templates → Magic Link (customize the email)

-- ═══════════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Baseline Schema
-- Consolidated from migrations v1-v6
-- Safe to run multiple times (idempotent)
-- Execute in: Supabase Dashboard → SQL Editor → Run
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 1: CORE PROFILES TABLE & AUTO-CREATE TRIGGER
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.profiles (
  id              uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name       text,
  preferred_lang  text DEFAULT 'fr',
  email           text,
  display_name    text,
  is_admin        boolean DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Unique index on email for fast lookup (used by webhooks)
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_email_unique
  ON public.profiles(email)
  WHERE email IS NOT NULL;

-- Trigger: auto-create profile when a new user is created in auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data ->> 'full_name')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 2: SUBSCRIPTIONS (1 per user per vertical)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.subscriptions (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tier                    text NOT NULL,
    -- 'bronze' | 'silver' | 'gold'
  status                  text NOT NULL DEFAULT 'active',
    -- 'active' | 'cancelled' | 'past_due' | 'expired' | 'trialing'
  vertical                text NOT NULL DEFAULT 'immo',
    -- 'immo' | 'commerce' | 'legal' | 'finance' | 'marketing' | 'rh' | 'sante' | 'education' | 'restauration' | 'freelance'
  lemon_subscription_id   text UNIQUE,
  lemon_order_id          text,
  current_period_start    timestamptz DEFAULT now(),
  current_period_end      timestamptz,
  cancelled_at            timestamptz,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now(),

  -- 1 subscription per user per vertical
  UNIQUE (user_id, vertical)
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id
  ON public.subscriptions(user_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_vertical
  ON public.subscriptions(vertical);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_vertical
  ON public.subscriptions(user_id, vertical);

CREATE INDEX IF NOT EXISTS idx_subscriptions_ls_id
  ON public.subscriptions(lemon_subscription_id)
  WHERE lemon_subscription_id IS NOT NULL;

-- Hot query index: active subscriptions for ai-tool.js
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_active
  ON public.subscriptions(user_id, vertical)
  WHERE status = 'active';

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 3: VERTICALS (metadata for each vertical)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.verticals (
  key             text PRIMARY KEY,
  label           text NOT NULL,
  icon            text NOT NULL DEFAULT '📁',
  color           text NOT NULL DEFAULT '#6c63ff',
  bg              text,
  border_color    text,
  default_system_prompt text,
  sort_order      integer NOT NULL DEFAULT 100,
  is_active       boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Seed 10 verticals
INSERT INTO public.verticals (key, label, icon, color, bg, border_color, sort_order, is_active) VALUES
  ('immo',         'Immobilier',                    '🏠', '#f59e0b', '#f59e0b15', '#f59e0b40', 1, true),
  ('commerce',     'E-Commerce & Retail',           '🛒', '#3b82f6', '#3b82f615', '#3b82f640', 2, true),
  ('legal',        'Juridique',                     '⚖️', '#8b5cf6', '#8b5cf615', '#8b5cf640', 3, true),
  ('finance',      'Finance & Comptabilité',        '💰', '#10b981', '#10b98115', '#10b98140', 4, true),
  ('marketing',    'Marketing & Communication',     '📣', '#ec4899', '#ec489915', '#ec489940', 5, true),
  ('rh',           'Ressources Humaines',           '👥', '#f97316', '#f9731615', '#f9731640', 6, true),
  ('sante',        'Santé & Bien-être',             '🏥', '#06b6d4', '#06b6d415', '#06b6d440', 7, true),
  ('education',    'Éducation & Formation',         '🎓', '#6366f1', '#6366f115', '#6366f140', 8, true),
  ('restauration', 'Restauration & Hôtellerie',     '🍽️', '#ef4444', '#ef444415', '#ef444440', 9, true),
  ('freelance',    'Freelances & Consultants',      '💼', '#84cc16', '#84cc1615', '#84cc1640', 10, true)
ON CONFLICT (key) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, color = EXCLUDED.color, sort_order = EXCLUDED.sort_order;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 4: TOOLS (complete catalog with full metadata)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.tools (
  slug                    text PRIMARY KEY,
  name                    text NOT NULL,
  label                   text,
  description             text,
  vertical                text NOT NULL,
  min_tier                text NOT NULL DEFAULT 'bronze',
    -- 'bronze' | 'silver' | 'gold'
  icon                    text DEFAULT '🔧',
  category                text,
  is_featured             boolean NOT NULL DEFAULT false,
  is_new                  boolean NOT NULL DEFAULT false,
  is_active               boolean NOT NULL DEFAULT true,
  sort_order              integer NOT NULL DEFAULT 100,

  -- Prompt & output configuration
  prompt_template         text,
  system_prompt           text,
  max_output_tokens       integer NOT NULL DEFAULT 800,
  output_format           text DEFAULT 'text',

  -- UI configuration
  input_schema            jsonb,
  generate_label          text,
  loading_text            text,
  empty_state_icon        text,
  empty_state_title       text,
  empty_state_text        text,
  form_panel_title        text,

  created_at              timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tools_vertical_sort
  ON public.tools(vertical, sort_order);

CREATE INDEX IF NOT EXISTS idx_tools_slug
  ON public.tools(slug);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 5: TOOL USAGE HISTORY & QUOTAS
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.tool_usage (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tool_slug     text NOT NULL REFERENCES public.tools(slug),
  input_data    jsonb,
  output_text   text,
  tokens_used   integer DEFAULT 0,
  duration_ms   integer,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tool_usage_user_id
  ON public.tool_usage(user_id);

CREATE INDEX IF NOT EXISTS idx_tool_usage_tool_slug
  ON public.tool_usage(tool_slug);

CREATE INDEX IF NOT EXISTS idx_tool_usage_created_at
  ON public.tool_usage(created_at DESC);

-- Hot query index: last 10 usages per user+tool
CREATE INDEX IF NOT EXISTS idx_tool_usage_user_slug_recent
  ON public.tool_usage(user_id, tool_slug, created_at DESC);

-- Hot query index: user tool usage by date (for archival)
CREATE INDEX IF NOT EXISTS idx_tool_usage_user_created
  ON public.tool_usage(user_id, created_at DESC);

-- Monthly usage quota (tracks calls per user per month)
CREATE TABLE IF NOT EXISTS public.usage_quotas (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  month       text NOT NULL,  -- format: 'YYYY-MM'
  count       integer NOT NULL DEFAULT 0,
  UNIQUE (user_id, month)
);

-- Hot query index: quota lookup by user + month
CREATE INDEX IF NOT EXISTS idx_usage_quotas_user_month
  ON public.usage_quotas(user_id, month);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 6: LEGACY TABLES (one-time downloads)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.user_products (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_slug            text NOT NULL,
  status                  text NOT NULL DEFAULT 'active',
  lemon_order_id          text,
  purchased_at            timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, product_slug)
);

CREATE INDEX IF NOT EXISTS idx_user_products_user_id
  ON public.user_products(user_id);

CREATE INDEX IF NOT EXISTS idx_user_products_order_id
  ON public.user_products(lemon_order_id)
  WHERE lemon_order_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.download_logs (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  filename      text NOT NULL,
  downloaded_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_download_logs_user_id
  ON public.download_logs(user_id);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 7: ARCHIVAL & WEBHOOK TRACKING
-- ═══════════════════════════════════════════════════════════════════════════════

-- Archive old tool_usage records for long-term storage/analytics
CREATE TABLE IF NOT EXISTS public.tool_usage_archive (
  id            uuid PRIMARY KEY,
  user_id       uuid NOT NULL,
  tool_slug     text NOT NULL,
  input_data    jsonb,
  output_text   text,
  tokens_used   integer DEFAULT 0,
  duration_ms   integer,
  created_at    timestamptz,
  archived_at   timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tool_usage_archive_date
  ON public.tool_usage_archive(archived_at DESC);

-- Webhook event tracking for idempotency
CREATE TABLE IF NOT EXISTS public.webhook_events (
  id            text PRIMARY KEY,
  event_name    text NOT NULL,
  processed_at  timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_webhook_events_date
  ON public.webhook_events(processed_at DESC);

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 8: RPC FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Atomic quota increment: replaces read-modify-write with single upsert
CREATE OR REPLACE FUNCTION public.increment_usage_quota(
  p_user_id uuid,
  p_month   text
)
RETURNS void AS $$
BEGIN
  INSERT INTO public.usage_quotas (user_id, month, count)
  VALUES (p_user_id, p_month, 1)
  ON CONFLICT (user_id, month)
  DO UPDATE SET count = usage_quotas.count + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check tool access: validates subscription tier + vertical for a given tool
CREATE OR REPLACE FUNCTION public.check_tool_access(p_tool_slug text)
RETURNS jsonb AS $$
DECLARE
  v_user_id     uuid := auth.uid();
  v_tool        record;
  v_sub         record;
  v_tier_order  int;
  v_min_order   int;
BEGIN
  -- Get tool
  SELECT * INTO v_tool FROM public.tools WHERE slug = p_tool_slug AND is_active = true;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'tool_not_found');
  END IF;

  -- Get subscription for this user + vertical
  SELECT * INTO v_sub FROM public.subscriptions
  WHERE user_id  = v_user_id
    AND vertical = v_tool.vertical
    AND status   = 'active'
    AND (current_period_end IS NULL OR current_period_end > now());

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'allowed',   false,
      'reason',    'no_subscription',
      'vertical',  v_tool.vertical,
      'tool',      v_tool.name
    );
  END IF;

  -- Tier hierarchy check
  v_tier_order := CASE v_sub.tier WHEN 'bronze' THEN 1 WHEN 'silver' THEN 2 WHEN 'gold' THEN 3 ELSE 0 END;
  v_min_order  := CASE v_tool.min_tier WHEN 'bronze' THEN 1 WHEN 'silver' THEN 2 WHEN 'gold' THEN 3 ELSE 1 END;

  IF v_tier_order < v_min_order THEN
    RETURN jsonb_build_object(
      'allowed',       false,
      'reason',        'upgrade_required',
      'required_tier', v_tool.min_tier,
      'your_tier',     v_sub.tier,
      'vertical',      v_tool.vertical
    );
  END IF;

  RETURN jsonb_build_object('allowed', true, 'tier', v_sub.tier, 'vertical', v_sub.vertical, 'tool', v_tool.name);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Archive tool_usage records older than N days
CREATE OR REPLACE FUNCTION public.archive_old_tool_usage(days_to_keep integer DEFAULT 90)
RETURNS bigint AS $$
DECLARE
  cutoff_date timestamptz;
  rows_moved bigint;
BEGIN
  cutoff_date := now() - (days_to_keep || ' days')::interval;

  INSERT INTO public.tool_usage_archive (id, user_id, tool_slug, input_data, output_text, tokens_used, duration_ms, created_at)
  SELECT id, user_id, tool_slug, input_data, output_text, tokens_used, duration_ms, created_at
  FROM public.tool_usage
  WHERE created_at < cutoff_date;

  GET DIAGNOSTICS rows_moved = ROW_COUNT;

  DELETE FROM public.tool_usage WHERE created_at < cutoff_date;

  RETURN rows_moved;
END;
$$ LANGUAGE plpgsql;

-- Clean up old webhook events (default: keep 30 days)
CREATE OR REPLACE FUNCTION public.cleanup_old_webhook_events(days_to_keep integer DEFAULT 30)
RETURNS bigint AS $$
DECLARE
  rows_removed bigint;
BEGIN
  DELETE FROM public.webhook_events
  WHERE processed_at < now() - (days_to_keep || ' days')::interval;
  GET DIAGNOSTICS rows_removed = ROW_COUNT;
  RETURN rows_removed;
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 9: VIEWS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Public tool view: excludes sensitive prompt data (used by frontend)
CREATE OR REPLACE VIEW public.tools_public AS
  SELECT
    slug,
    label,
    description,
    icon,
    vertical,
    min_tier,
    is_featured,
    is_new,
    sort_order,
    input_schema,
    max_output_tokens,
    category,
    generate_label,
    loading_text,
    empty_state_icon,
    empty_state_title,
    empty_state_text,
    form_panel_title,
    created_at
  FROM public.tools
  WHERE is_active = true;

-- Active user products (expired excluded)
CREATE OR REPLACE VIEW public.active_user_products AS
  SELECT
    up.*,
    p.full_name,
    u.email
  FROM public.user_products up
  JOIN auth.users u ON u.id = up.user_id
  LEFT JOIN public.profiles p ON p.id = up.user_id
  WHERE up.status = 'active';

-- Admin view: all users with their subscriptions
CREATE OR REPLACE VIEW public.admin_users_view AS
  SELECT
    p.id,
    p.full_name,
    p.is_admin,
    p.created_at,
    json_agg(
      json_build_object(
        'vertical',           s.vertical,
        'tier',               s.tier,
        'status',             s.status,
        'current_period_end', s.current_period_end
      ) ORDER BY s.vertical
    ) FILTER (WHERE s.id IS NOT NULL) AS subscriptions
  FROM public.profiles p
  LEFT JOIN public.subscriptions s ON s.user_id = p.id
  GROUP BY p.id, p.full_name, p.is_admin, p.created_at
  ORDER BY p.created_at DESC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 10: ROW LEVEL SECURITY (RLS)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Enable RLS on all user data tables
ALTER TABLE public.profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tool_usage     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_quotas   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_products  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.download_logs  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verticals      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tools          ENABLE ROW LEVEL SECURITY;

-- Profiles: users can view and update their own
DROP POLICY IF EXISTS "Users view own profile"   ON public.profiles;
DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
CREATE POLICY "Users view own profile"   ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Subscriptions: users view own, admins can manage
DROP POLICY IF EXISTS "Users view own subscriptions"     ON public.subscriptions;
DROP POLICY IF EXISTS "Users update own subscriptions"   ON public.subscriptions;
DROP POLICY IF EXISTS "Admin can update subscriptions"   ON public.subscriptions;
DROP POLICY IF EXISTS "Admin can insert subscriptions"   ON public.subscriptions;

CREATE POLICY "Users view own subscriptions"
  ON public.subscriptions FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

CREATE POLICY "Users update own subscriptions"
  ON public.subscriptions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admin can update subscriptions"
  ON public.subscriptions FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true));

CREATE POLICY "Admin can insert subscriptions"
  ON public.subscriptions FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true));

-- Verticals: anyone can read
DROP POLICY IF EXISTS "Anyone can read verticals" ON public.verticals;
CREATE POLICY "Anyone can read verticals" ON public.verticals FOR SELECT USING (true);

-- Tools: public read (authenticated users see active, admins see all)
DROP POLICY IF EXISTS "Authenticated users read active tools" ON public.tools;
CREATE POLICY "Authenticated users read active tools"
  ON public.tools FOR SELECT
  USING (is_active = true OR EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true
  ));

-- Tool usage: users can view their own
DROP POLICY IF EXISTS "Users view own usage" ON public.tool_usage;
CREATE POLICY "Users view own usage" ON public.tool_usage FOR SELECT USING (auth.uid() = user_id);

-- Usage quotas: users can view their own
DROP POLICY IF EXISTS "Users view own quotas" ON public.usage_quotas;
CREATE POLICY "Users view own quotas" ON public.usage_quotas FOR SELECT USING (auth.uid() = user_id);

-- User products: users can view their own
DROP POLICY IF EXISTS "Users view own products" ON public.user_products;
CREATE POLICY "Users view own products" ON public.user_products FOR SELECT USING (auth.uid() = user_id);

-- Download logs: users can view their own
DROP POLICY IF EXISTS "Users view own download logs" ON public.download_logs;
CREATE POLICY "Users view own download logs" ON public.download_logs FOR SELECT USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════════════════════
-- Done! Baseline schema ready for tool catalog seeding
-- ═══════════════════════════════════════════════════════════════════════════════

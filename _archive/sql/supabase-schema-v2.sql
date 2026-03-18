-- ═══════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Schema v2 (SaaS Abonnements)
-- Exécuter dans Supabase → SQL Editor → New query → Run
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. Profiles (déjà existant — skip si déjà là) ───────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id              uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name       text,
  preferred_lang  text DEFAULT 'fr',
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

-- ─── 2. Subscriptions ────────────────────────────────────────────────────
-- Un user peut avoir un seul abonnement actif à la fois
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tier                    text NOT NULL,
    -- 'bronze' | 'silver' | 'gold'
  status                  text NOT NULL DEFAULT 'active',
    -- 'active' | 'cancelled' | 'past_due' | 'expired' | 'trialing'
  vertical                text,
    -- NULL = toutes | 'immo' | 'commerce' | 'legal' | 'finance'
    -- (pour Bronze qui est limité à 1 verticale)
  lemon_subscription_id   text UNIQUE,
  lemon_order_id          text,
  current_period_start    timestamptz DEFAULT now(),
  current_period_end      timestamptz,
  cancelled_at            timestamptz,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now(),

  UNIQUE (user_id)  -- 1 seul abonnement actif par user
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id
  ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_ls_id
  ON public.subscriptions(lemon_subscription_id)
  WHERE lemon_subscription_id IS NOT NULL;

-- ─── 3. Tools Catalog ────────────────────────────────────────────────────
-- Référentiel de tous les outils disponibles
CREATE TABLE IF NOT EXISTS public.tools (
  slug          text PRIMARY KEY,
  name          text NOT NULL,
  description   text,
  vertical      text NOT NULL,
    -- 'immo' | 'commerce' | 'legal' | 'finance'
  min_tier      text NOT NULL DEFAULT 'bronze',
    -- 'bronze' | 'silver' | 'gold'
  icon          text,
  prompt_template text,  -- template de prompt système pour cet outil
  input_schema  jsonb,   -- définition des champs du formulaire
  is_active     boolean NOT NULL DEFAULT true,
  sort_order    integer DEFAULT 0,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- ─── 4. Tool Usage ────────────────────────────────────────────────────────
-- Historique de chaque génération IA par user
CREATE TABLE IF NOT EXISTS public.tool_usage (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tool_slug     text NOT NULL REFERENCES public.tools(slug),
  input_data    jsonb,   -- les inputs du formulaire (pas de données sensibles)
  output_text   text,    -- la réponse générée
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

-- ─── 5. Monthly Usage Quotas ──────────────────────────────────────────────
-- Compteur mensuel de générations par user (reset chaque mois)
CREATE TABLE IF NOT EXISTS public.usage_quotas (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  month       text NOT NULL,  -- format: '2025-03'
  count       integer NOT NULL DEFAULT 0,
  UNIQUE (user_id, month)
);

-- ─── 6. Downloads (one-shot PDFs legacy) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_products (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_slug            text NOT NULL,
  status                  text NOT NULL DEFAULT 'active',
  lemon_order_id          text,
  purchased_at            timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, product_slug)
);

CREATE TABLE IF NOT EXISTS public.download_logs (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  filename      text NOT NULL,
  downloaded_at timestamptz NOT NULL DEFAULT now()
);

-- ─── 7. Seed: Tools Catalog ───────────────────────────────────────────────

-- VERTICALE IMMOBILIER
INSERT INTO public.tools (slug, name, description, vertical, min_tier, icon, sort_order) VALUES
('immo-annonce',        'Générateur d''annonces',        'Rédigez une annonce immobilière percutante en 30 secondes', 'immo', 'bronze', '📝', 1),
('immo-email-suivi',    'Email de suivi acquéreur',      'Relancez vos prospects avec des emails personnalisés',       'immo', 'bronze', '📧', 2),
('immo-rapport-visite', 'Rapport de visite',             'Générez un compte-rendu de visite professionnel',           'immo', 'silver', '📋', 3),
('immo-analyse-prix',   'Analyse comparative de prix',   'Rédigez une analyse de marché argumentée pour votre client','immo', 'silver', '📊', 4),
('immo-script-prosp',   'Script de prospection',         'Scripts d''appel et SMS pour convaincre de nouveaux mandats','immo', 'silver', '📞', 5),
('immo-mandat-exclusif','Argumentaire mandat exclusif',  'Argumentaire personnalisé pour obtenir le mandat exclusif',  'immo', 'gold',   '🏆', 6),
('immo-posts-sociaux',  'Posts réseaux sociaux',         'Créez des posts LinkedIn/Instagram pour vos biens',         'immo', 'gold',   '📱', 7),
('immo-email-vendeur',  'Email de présentation vendeur', 'Email professionnel pour présenter une offre au vendeur',   'immo', 'gold',   '💌', 8)
ON CONFLICT (slug) DO NOTHING;

-- VERTICALE COMMERCE
INSERT INTO public.tools (slug, name, description, vertical, min_tier, icon, sort_order) VALUES
('commerce-fiche-produit',    'Générateur de fiches produits',    'Rédigez des fiches produits SEO-optimisées en masse',        'commerce', 'bronze', '🛒', 1),
('commerce-email-promo',      'Email promotionnel',               'Créez des emails marketing qui convertissent',               'commerce', 'bronze', '📧', 2),
('commerce-seo-description',  'Description SEO',                  'Optimisez vos descriptions pour le référencement naturel',  'commerce', 'silver', '🔍', 3),
('commerce-posts-sociaux',    'Contenu réseaux sociaux',          'Posts produits pour Instagram, Facebook, TikTok',           'commerce', 'silver', '📱', 4),
('commerce-relance-panier',   'Relance panier abandonné',         'Séquence email pour récupérer les paniers abandonnés',      'commerce', 'silver', '🛍️', 5),
('commerce-chatbot-sav',      'Script chatbot SAV',               'Créez un script de chatbot service client complet',         'commerce', 'gold',   '💬', 6),
('commerce-strategie',        'Stratégie de contenu',             'Plan de contenu marketing mensuel complet',                 'commerce', 'gold',   '🎯', 7),
('commerce-analyse-concur',   'Analyse concurrentielle',          'Analyse IA de votre positionnement face à la concurrence',  'commerce', 'gold',   '📊', 8)
ON CONFLICT (slug) DO NOTHING;

-- VERTICALE JURIDIQUE
INSERT INTO public.tools (slug, name, description, vertical, min_tier, icon, sort_order) VALUES
('legal-courrier',          'Rédacteur de courriers',        'Courriers juridiques professionnels en quelques clics',     'legal', 'bronze', '✉️', 1),
('legal-resume-contrat',    'Résumé de contrat',             'Obtenez les points clés d''un contrat en moins d''1 minute','legal', 'bronze', '📋', 2),
('legal-note-juridique',    'Note juridique',                'Rédigez une note de synthèse juridique structurée',         'legal', 'silver', '⚖️', 3),
('legal-analyse-clause',    'Analyse de clause',             'Identifiez les risques dans une clause contractuelle',      'legal', 'silver', '🔎', 4),
('legal-mise-en-demeure',   'Mise en demeure',               'Rédigez une mise en demeure légalement solide',             'legal', 'silver', '📜', 5),
('legal-contrat-standard',  'Contrat type',                  'Générez un contrat adapté à votre situation',               'legal', 'gold',   '📄', 6),
('legal-jurisprudence',     'Recherche jurisprudentielle',   'Synthèse de jurisprudence sur une question de droit',       'legal', 'gold',   '🏛️', 7),
('legal-plaidoirie',        'Arguments de plaidoirie',       'Structurez vos arguments pour une audience',                'legal', 'gold',   '🎤', 8)
ON CONFLICT (slug) DO NOTHING;

-- VERTICALE FINANCE
INSERT INTO public.tools (slug, name, description, vertical, min_tier, icon, sort_order) VALUES
('finance-synthese',        'Synthèse de rapport',           'Résumez un rapport financier complexe en points clés',      'finance', 'bronze', '📊', 1),
('finance-email-pro',       'Email professionnel finance',   'Emails formels pour directeurs financiers et investisseurs','finance', 'bronze', '📧', 2),
('finance-analyse-kpi',     'Analyse de KPIs',               'Interprétez vos indicateurs financiers avec l''IA',         'finance', 'silver', '📈', 3),
('finance-rapport-invest',  'Rapport d''investissement',     'Rédigez un rapport d''analyse d''investissement',           'finance', 'silver', '💰', 4),
('finance-budget-prevision','Budget prévisionnel',           'Commentaire et analyse de votre budget prévisionnel',       'finance', 'silver', '📅', 5),
('finance-deck-invest',     'Deck investisseur',             'Rédigez le contenu d''un pitch deck pour levée de fonds',   'finance', 'gold',   '🚀', 6),
('finance-strategie',       'Stratégie financière',          'Recommandations IA pour optimiser votre stratégie',         'finance', 'gold',   '🎯', 7),
('finance-due-diligence',   'Due diligence',                 'Check-list et analyse IA pour une acquisition',             'finance', 'gold',   '🔬', 8)
ON CONFLICT (slug) DO NOTHING;

-- ─── 8. Row Level Security ────────────────────────────────────────────────
ALTER TABLE public.subscriptions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tools          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tool_usage     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_quotas   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_products  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.download_logs  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles       ENABLE ROW LEVEL SECURITY;

-- Profiles
DROP POLICY IF EXISTS "Users view own profile"   ON public.profiles;
DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
CREATE POLICY "Users view own profile"   ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Subscriptions
DROP POLICY IF EXISTS "Users view own subscription" ON public.subscriptions;
CREATE POLICY "Users view own subscription" ON public.subscriptions FOR SELECT USING (auth.uid() = user_id);

-- Tools (public read — tout le monde peut voir le catalogue)
DROP POLICY IF EXISTS "Tools are public" ON public.tools;
CREATE POLICY "Tools are public" ON public.tools FOR SELECT USING (true);

-- Tool usage
DROP POLICY IF EXISTS "Users view own usage" ON public.tool_usage;
CREATE POLICY "Users view own usage" ON public.tool_usage FOR SELECT USING (auth.uid() = user_id);

-- Usage quotas
DROP POLICY IF EXISTS "Users view own quotas" ON public.usage_quotas;
CREATE POLICY "Users view own quotas" ON public.usage_quotas FOR SELECT USING (auth.uid() = user_id);

-- User products (PDFs)
DROP POLICY IF EXISTS "Users view own products" ON public.user_products;
CREATE POLICY "Users view own products" ON public.user_products FOR SELECT USING (auth.uid() = user_id);

-- Download logs
DROP POLICY IF EXISTS "Users view own download logs" ON public.download_logs;
CREATE POLICY "Users view own download logs" ON public.download_logs FOR SELECT USING (auth.uid() = user_id);

-- ─── 9. Trigger: auto-create profile ──────────────────────────────────────
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

-- ─── 10. Helper: check user tool access ──────────────────────────────────
-- Fonction RPC appelable depuis le frontend pour vérifier l'accès
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

  -- Get subscription
  SELECT * INTO v_sub FROM public.subscriptions
  WHERE user_id = v_user_id AND status = 'active'
  AND (current_period_end IS NULL OR current_period_end > now());

  IF NOT FOUND THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'no_subscription', 'tool', v_tool.name);
  END IF;

  -- Tier hierarchy
  v_tier_order := CASE v_sub.tier WHEN 'bronze' THEN 1 WHEN 'silver' THEN 2 WHEN 'gold' THEN 3 ELSE 0 END;
  v_min_order  := CASE v_tool.min_tier WHEN 'bronze' THEN 1 WHEN 'silver' THEN 2 WHEN 'gold' THEN 3 ELSE 1 END;

  -- Check vertical restriction (Bronze = 1 verticale)
  IF v_sub.tier = 'bronze' AND v_sub.vertical IS NOT NULL AND v_sub.vertical != v_tool.vertical THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'wrong_vertical', 'your_vertical', v_sub.vertical);
  END IF;

  -- Check tier level
  IF v_tier_order < v_min_order THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'upgrade_required', 'required_tier', v_tool.min_tier, 'your_tier', v_sub.tier);
  END IF;

  RETURN jsonb_build_object('allowed', true, 'tier', v_sub.tier, 'tool', v_tool.name);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Done! ────────────────────────────────────────────────────────────────
SELECT 'Schema v2 installed successfully' AS status;

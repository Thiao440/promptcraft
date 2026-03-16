-- ═══════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Admin & Test User Setup
-- Exécuter dans Supabase → SQL Editor → New query → Run
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. Créer un utilisateur admin pour les tests ─────────────────────────
-- Remplace YOUR_ADMIN_UUID par l'UUID généré après avoir créé le compte
-- dans Supabase Authentication → Users → Add user

-- Exemple: créer un abonnement Gold permanent pour tester
-- INSERT INTO public.subscriptions (user_id, tier, status, current_period_end)
-- VALUES ('YOUR_ADMIN_UUID', 'gold', 'active', '2099-01-01T00:00:00Z');


-- ─── 2. Politique RLS pour que l'admin puisse lire toutes les données ─────
-- Par défaut, les utilisateurs ne voient que leurs propres données.
-- Pour l'admin panel, on doit contourner le RLS en appelant l'API
-- avec le service key (backend uniquement) OU créer des politiques admin.

-- Option A: Politique basée sur un rôle admin (email-based)
-- Ajouter une colonne is_admin dans la table profiles

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin boolean DEFAULT false;

-- Marquer un utilisateur comme admin (remplacer l'UUID)
-- UPDATE public.profiles SET is_admin = true WHERE id = 'YOUR_ADMIN_UUID';


-- Option B (recommandée pour prod): Utiliser une Netlify Function avec service key
-- pour que l'admin panel appelle /api/admin-* endpoints sécurisés côté serveur.


-- ─── 3. RLS: Politique SELECT pour l'admin sur subscriptions ─────────────
DROP POLICY IF EXISTS "Admin can view all subscriptions" ON public.subscriptions;
CREATE POLICY "Admin can view all subscriptions"
  ON public.subscriptions FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Admin peut lire tous les profils
DROP POLICY IF EXISTS "Admin can view all profiles" ON public.profiles;
CREATE POLICY "Admin can view all profiles"
  ON public.profiles FOR SELECT
  USING (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM public.profiles AS p2
      WHERE p2.id = auth.uid() AND p2.is_admin = true
    )
  );

-- Admin peut lire toutes les utilisations
DROP POLICY IF EXISTS "Admin can view all tool_usage" ON public.tool_usage;
CREATE POLICY "Admin can view all tool_usage"
  ON public.tool_usage FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Admin peut lire tous les quotas
DROP POLICY IF EXISTS "Admin can view all quotas" ON public.usage_quotas;
CREATE POLICY "Admin can view all quotas"
  ON public.usage_quotas FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Admin peut modifier les abonnements
DROP POLICY IF EXISTS "Admin can update subscriptions" ON public.subscriptions;
CREATE POLICY "Admin can update subscriptions"
  ON public.subscriptions FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Admin peut insérer des abonnements (pour test users)
DROP POLICY IF EXISTS "Admin can insert subscriptions" ON public.subscriptions;
CREATE POLICY "Admin can insert subscriptions"
  ON public.subscriptions FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Admin peut mettre à jour les profils
DROP POLICY IF EXISTS "Admin can update profiles" ON public.profiles;
CREATE POLICY "Admin can update profiles"
  ON public.profiles FOR UPDATE
  USING (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM public.profiles AS p2
      WHERE p2.id = auth.uid() AND p2.is_admin = true
    )
  );


-- ─── 4. Créer un compte de test complet ───────────────────────────────────
-- Étapes manuelles à suivre dans Supabase Dashboard:
--
-- A) Authentication → Users → Add user
--    Email: mathieu.thiao@gmail.com (ou votre email)
--    Auto Confirm User: ✅ coché
--
-- B) Copier l'UUID généré (ex: abc123-...)
--
-- C) Exécuter ce SQL avec votre UUID:
/*
UPDATE public.profiles
  SET is_admin = true, full_name = 'Mathieu (Admin)'
  WHERE id = 'VOTRE_UUID_ICI';

INSERT INTO public.subscriptions (user_id, tier, status, current_period_end)
  VALUES ('VOTRE_UUID_ICI', 'gold', 'active', '2099-01-01T00:00:00Z')
  ON CONFLICT (user_id) DO UPDATE SET
    tier = 'gold',
    status = 'active',
    current_period_end = '2099-01-01T00:00:00Z',
    updated_at = now();
*/

-- ─── 5. Vue admin utile ───────────────────────────────────────────────────
-- Vue qui joint profiles + subscriptions pour l'admin panel
CREATE OR REPLACE VIEW public.admin_users_view AS
  SELECT
    p.id,
    p.full_name,
    p.preferred_lang,
    p.is_admin,
    p.created_at,
    s.tier,
    s.status       AS sub_status,
    s.vertical,
    s.current_period_end,
    s.lemon_subscription_id
  FROM public.profiles p
  LEFT JOIN public.subscriptions s ON s.user_id = p.id
  ORDER BY p.created_at DESC;

-- Cette vue est accessible uniquement via service role (pas de RLS sur les views)


-- ─── Done! ────────────────────────────────────────────────────────────────
SELECT 'Admin setup complete. Now update is_admin = true for your user.' AS status;

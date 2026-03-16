-- ═══════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Migration v3
-- Architecture : 1 abonnement PAR VERTICALE (un user peut cumuler)
-- Bronze/Silver/Gold appliqués à la verticale choisie
--
-- Exécuter dans Supabase → SQL Editor → New query → Run
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. Modifier la table subscriptions ──────────────────────────────────

-- Supprimer l'ancienne contrainte UNIQUE (user_id seul)
ALTER TABLE public.subscriptions
  DROP CONSTRAINT IF EXISTS subscriptions_user_id_key;

-- Rendre vertical obligatoire
ALTER TABLE public.subscriptions
  ALTER COLUMN vertical SET NOT NULL,
  ALTER COLUMN vertical SET DEFAULT 'immo';

-- Nouvelle contrainte : 1 abonnement actif PAR (user + vertical)
ALTER TABLE public.subscriptions
  ADD CONSTRAINT subscriptions_user_vertical_key UNIQUE (user_id, vertical);

-- Index pour les requêtes par vertical
CREATE INDEX IF NOT EXISTS idx_subscriptions_vertical
  ON public.subscriptions(vertical);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_vertical
  ON public.subscriptions(user_id, vertical);

-- ─── 2. Mettre à jour les politiques RLS ─────────────────────────────────

DROP POLICY IF EXISTS "Users view own subscription"   ON public.subscriptions;
DROP POLICY IF EXISTS "Admin can view all subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "Admin can update subscriptions"   ON public.subscriptions;
DROP POLICY IF EXISTS "Admin can insert subscriptions"   ON public.subscriptions;

-- User voit ses propres abonnements (potentiellement plusieurs)
CREATE POLICY "Users view own subscriptions"
  ON public.subscriptions FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- User peut mettre à jour ses propres abonnements (changement de vertical)
CREATE POLICY "Users update own subscriptions"
  ON public.subscriptions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admin can update subscriptions"
  ON public.subscriptions FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

CREATE POLICY "Admin can insert subscriptions"
  ON public.subscriptions FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

-- ─── 3. Mettre à jour la fonction check_tool_access ──────────────────────

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

  -- Get subscription FOR THIS SPECIFIC VERTICAL
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

-- ─── 4. Mettre à jour l'abonnement test de l'admin ───────────────────────
-- (Si vous aviez un abonnement Gold sans vertical, le mettre à jour)

UPDATE public.subscriptions
SET vertical = 'immo', updated_at = now()
WHERE vertical IS NULL OR vertical = '';

-- Ajouter les 3 autres verticales pour votre compte admin (test complet)
INSERT INTO public.subscriptions (user_id, tier, status, vertical, current_period_end)
VALUES
  ('3332e009-379e-45df-b136-28f8388be022', 'gold', 'active', 'immo',     '2099-01-01T00:00:00Z'),
  ('3332e009-379e-45df-b136-28f8388be022', 'gold', 'active', 'commerce', '2099-01-01T00:00:00Z'),
  ('3332e009-379e-45df-b136-28f8388be022', 'gold', 'active', 'legal',    '2099-01-01T00:00:00Z'),
  ('3332e009-379e-45df-b136-28f8388be022', 'gold', 'active', 'finance',  '2099-01-01T00:00:00Z')
ON CONFLICT (user_id, vertical) DO UPDATE SET
  tier               = 'gold',
  status             = 'active',
  current_period_end = '2099-01-01T00:00:00Z',
  updated_at         = now();

-- ─── 5. Vue admin mise à jour ─────────────────────────────────────────────

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

-- ─── Done! ────────────────────────────────────────────────────────────────
SELECT 'Migration v3 OK — subscriptions now unique per (user, vertical)' AS status;

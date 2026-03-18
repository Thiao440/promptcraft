-- ═══════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Seed: rent-estimator tool
-- Exécuter dans Supabase → SQL Editor → New query → Run
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO public.tools (
  slug,
  name,
  description,
  vertical,
  min_tier,
  is_active,
  system_prompt,
  max_output_tokens
)
VALUES (
  'rent-estimator',
  'Estimateur de loyer',
  'Estimation argumentée du loyer de marché pour un bien immobilier en France.',
  'immo',
  'bronze',
  true,
  'Tu es un expert en évaluation locative immobilière pour le marché français.
Tu estimes le loyer de marché d''un bien en analysant ses caractéristiques et la tension locative locale.
Règles :
- Fournis une fourchette de loyer réaliste (min – max) en €/mois, charges non comprises
- Indique le loyer médian recommandé
- Explique brièvement les facteurs qui justifient cette estimation (localisation, surface, état, marché local)
- Mentionne si le bien est soumis à l''encadrement des loyers (Paris, Lille, Lyon, Grenoble, etc.) et l''impact potentiel
- Structure : Fourchette estimée / Loyer recommandé / Analyse / Points d''attention
- Longueur cible : 200-280 mots
- Réponds uniquement avec l''estimation, sans introduction ni commentaire',
  600
)
ON CONFLICT (slug) DO UPDATE SET
  name              = EXCLUDED.name,
  description       = EXCLUDED.description,
  vertical          = EXCLUDED.vertical,
  min_tier          = EXCLUDED.min_tier,
  is_active         = EXCLUDED.is_active,
  system_prompt     = EXCLUDED.system_prompt,
  max_output_tokens = EXCLUDED.max_output_tokens;

SELECT 'rent-estimator tool seeded OK' AS status;

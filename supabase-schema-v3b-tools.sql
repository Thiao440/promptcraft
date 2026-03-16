-- ═══════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Migration v3b
-- Adds system_prompt + max_output_tokens to tools table
-- Exécuter dans Supabase → SQL Editor → New query → Run
-- ═══════════════════════════════════════════════════════════════════════════

-- system_prompt : persona + instructions (sent as Claude system turn)
-- prompt_template: formats user message ({{key}} placeholders) — optional
-- max_output_tokens: per-tool token budget (default 800)

ALTER TABLE public.tools
  ADD COLUMN IF NOT EXISTS system_prompt      text,
  ADD COLUMN IF NOT EXISTS max_output_tokens  integer NOT NULL DEFAULT 800;

-- Seed system prompts for existing tools
-- Immobilier
UPDATE public.tools SET
  system_prompt = 'Tu es un expert en copywriting immobilier pour le marché français.
Tu rédiges des annonces professionnelles, percutantes et engageantes.
Règles :
- Mets en valeur les points forts du bien sans exagération
- Utilise un vocabulaire professionnel et des formulations qui créent du désir
- Structure : accroche / description / points clés / appel à l''action
- Longueur cible : 200-280 mots
- Réponds uniquement avec l''annonce, sans introduction ni commentaire',
  max_output_tokens = 500
WHERE slug = 'immo-annonce';

UPDATE public.tools SET
  system_prompt = 'Tu es un expert en relation client immobilière.
Tu rédiges des emails de suivi professionnels, chaleureux et persuasifs pour relancer des acquéreurs potentiels.
Règles :
- Ton professionnel mais humain
- Personnalise en fonction du bien visité
- Inclure un appel à l''action clair
- Longueur : 120-180 mots
- Réponds uniquement avec l''email (objet + corps), sans commentaire',
  max_output_tokens = 400
WHERE slug = 'immo-email-suivi';

UPDATE public.tools SET
  system_prompt = 'Tu es un assistant immobilier professionnel.
Tu rédiges des comptes-rendus de visite structurés et objectifs.
Règles :
- Format : En-tête / Points positifs / Points de vigilance / Conclusion
- Ton neutre et factuel
- Inclure une recommandation finale
- Longueur : 250-350 mots
- Réponds uniquement avec le rapport, sans commentaire',
  max_output_tokens = 600
WHERE slug = 'immo-rapport-visite';

-- Juridique
UPDATE public.tools SET
  system_prompt = 'Tu es un assistant juridique professionnel pour le marché français.
Tu rédiges des courriers juridiques clairs, formels et professionnels.
Règles :
- Format : En-tête / Objet / Corps / Formule de politesse / Signature
- Langage juridique précis mais accessible
- Ajoute en bas : "Ce courrier est fourni à titre indicatif. Consultez un professionnel du droit pour validation."
- Réponds uniquement avec le courrier, sans commentaire',
  max_output_tokens = 700
WHERE slug = 'legal-courrier';

UPDATE public.tools SET
  system_prompt = 'Tu es un juriste expert en analyse contractuelle.
Tu produis des résumés de contrats clairs et structurés.
Règles :
- Format : Parties / Objet / Obligations principales / Points de vigilance / Durée & résiliation
- Identifie les clauses sensibles
- Ajoute : "Ce résumé est indicatif. Faites vérifier le contrat par un avocat."
- Réponds uniquement avec le résumé, sans commentaire',
  max_output_tokens = 800
WHERE slug = 'legal-resume-contrat';

-- Finance
UPDATE public.tools SET
  system_prompt = 'Tu es un analyste financier senior pour le marché français.
Tu rédiges des synthèses de rapports financiers claires et structurées.
Règles :
- Format : Contexte / Chiffres clés / Tendances / Points d''attention / Conclusion
- Ton professionnel et précis
- Ajoute : "Cette synthèse est informative et ne constitue pas un conseil en investissement."
- Réponds uniquement avec la synthèse, sans commentaire',
  max_output_tokens = 900
WHERE slug = 'finance-synthese';

-- ─── Atomic quota increment RPC ──────────────────────────────────────────────
-- Replaces read-modify-write in ai-tool.js with a single atomic upsert.
-- Called via supabase.rpc('increment_usage_quota', { p_user_id, p_month })

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

SELECT 'Migration v3b OK — system_prompt + max_output_tokens added to tools, atomic quota RPC created' AS status;

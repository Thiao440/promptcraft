-- ═══════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Migration v4: Dynamic Tool Configuration
-- Adds input_schema, label, description, icon, output_format, UI flags
-- to the tools table to enable config-driven tool rendering.
--
-- SAFE: All changes are additive (new columns with defaults).
-- No existing columns are modified or removed.
-- Existing queries continue to work unchanged.
--
-- Execute in Supabase → SQL Editor → New query → Run
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. Add new columns to tools table ──────────────────────────────────────

ALTER TABLE public.tools
  ADD COLUMN IF NOT EXISTS input_schema    jsonb,
  ADD COLUMN IF NOT EXISTS label           text,
  ADD COLUMN IF NOT EXISTS description     text,
  ADD COLUMN IF NOT EXISTS icon            text DEFAULT '🔧',
  ADD COLUMN IF NOT EXISTS output_format   text DEFAULT 'text',
  ADD COLUMN IF NOT EXISTS category        text,
  ADD COLUMN IF NOT EXISTS is_featured     boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_new          boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS sort_order      integer NOT NULL DEFAULT 100,
  ADD COLUMN IF NOT EXISTS generate_label  text,
  ADD COLUMN IF NOT EXISTS loading_text    text,
  ADD COLUMN IF NOT EXISTS empty_state_icon text,
  ADD COLUMN IF NOT EXISTS empty_state_title text,
  ADD COLUMN IF NOT EXISTS empty_state_text  text,
  ADD COLUMN IF NOT EXISTS form_panel_title  text;

-- ─── 2. Create verticals table ──────────────────────────────────────────────

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

-- Enable RLS on verticals (read-only for authenticated users)
ALTER TABLE public.verticals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read verticals"
  ON public.verticals FOR SELECT
  USING (true);

-- ─── 3. Seed verticals ─────────────────────────────────────────────────────

INSERT INTO public.verticals (key, label, icon, color, bg, border_color, sort_order) VALUES
  ('immo',     'Immobilier', '🏠', '#3b82f6', 'rgba(59,130,246,.12)',  'rgba(59,130,246,.3)',  1),
  ('commerce', 'Commerce',   '🛒', '#f97316', 'rgba(249,115,22,.12)',  'rgba(249,115,22,.3)',  2),
  ('legal',    'Juridique',  '⚖️', '#ef4444', 'rgba(239,68,68,.12)',   'rgba(239,68,68,.3)',   3),
  ('finance',  'Finance',    '📈', '#22c55e', 'rgba(34,197,94,.12)',   'rgba(34,197,94,.3)',   4)
ON CONFLICT (key) DO NOTHING;

-- ─── 4. Backfill existing tools with label, description, icon, flags ────────

-- immo-annonce
UPDATE public.tools SET
  label = 'Générateur d''annonces immobilières',
  description = 'Annonces percutantes en 30s',
  icon = '📝',
  is_featured = true,
  sort_order = 1,
  generate_label = 'Générer l''annonce',
  loading_text = 'L''IA rédige votre annonce',
  empty_state_icon = '📝',
  empty_state_title = 'Votre annonce apparaîtra ici',
  empty_state_text = 'Remplissez le formulaire à gauche et cliquez sur Générer l''annonce pour commencer.',
  form_panel_title = '✍️ Informations du bien',
  input_schema = '{
    "fields": [
      {"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "layout": "half",
       "options": [
         {"value": "appartement", "label": "Appartement"},
         {"value": "maison", "label": "Maison"},
         {"value": "studio", "label": "Studio"},
         {"value": "loft", "label": "Loft"},
         {"value": "villa", "label": "Villa"},
         {"value": "terrain", "label": "Terrain"},
         {"value": "local commercial", "label": "Local commercial"},
         {"value": "bureau", "label": "Bureau"},
         {"value": "immeuble", "label": "Immeuble"}
       ]},
      {"name": "transaction", "type": "select", "label": "Transaction", "required": true, "layout": "half",
       "options": [
         {"value": "vente", "label": "Vente"},
         {"value": "location", "label": "Location"},
         {"value": "location meublée", "label": "Location meublée"},
         {"value": "viager", "label": "Viager"}
       ]},
      {"name": "surface", "type": "number", "label": "Surface (m²)", "required": true, "placeholder": "Ex: 75", "min": 1, "max": 99999, "layout": "half"},
      {"name": "pieces", "type": "number", "label": "Nombre de pièces", "placeholder": "Ex: 4", "min": 1, "max": 99, "layout": "half"},
      {"name": "prix", "type": "number", "label": "Prix (€)", "required": true, "placeholder": "Ex: 295000", "min": 1, "layout": "half"},
      {"name": "localisation", "type": "text", "label": "Localisation", "required": true, "placeholder": "Ex: Lyon 6ème, 69006", "layout": "half"},
      {"name": "points_forts", "type": "textarea", "label": "Points forts du bien", "placeholder": "Ex: Lumineux, vue dégagée, double vitrage, parquet ancien, cave, parking...", "rows": 3, "maxLength": 400},
      {"name": "infos_comp", "type": "textarea", "label": "Informations complémentaires", "placeholder": "Ex: Proche école, commerces à 200m, quartier calme, refait à neuf en 2022...", "rows": 2},
      {"name": "ton", "type": "tone_grid", "label": "Ton souhaité", "default": "professionnel",
       "options": [
         {"value": "professionnel", "icon": "💼", "label": "Professionnel"},
         {"value": "enthousiaste", "icon": "🌟", "label": "Enthousiaste"},
         {"value": "luxe", "icon": "✨", "label": "Prestige"},
         {"value": "minimaliste", "icon": "📋", "label": "Épuré"},
         {"value": "investisseur", "icon": "📈", "label": "Investissement"},
         {"value": "chaleureux", "icon": "🏡", "label": "Chaleureux"}
       ]}
    ]
  }'::jsonb
WHERE slug = 'immo-annonce';

-- rent-estimator
UPDATE public.tools SET
  label = 'Estimateur de loyer',
  description = 'Fourchette de loyer argumentée',
  icon = '💰',
  is_featured = true,
  is_new = true,
  sort_order = 3,
  generate_label = 'Estimer le loyer',
  loading_text = 'L''IA analyse le marché locatif',
  empty_state_icon = '💰',
  empty_state_title = 'L''estimation apparaîtra ici',
  empty_state_text = 'Remplissez les informations du bien à gauche et cliquez sur Estimer le loyer.',
  form_panel_title = '🏘️ Caractéristiques du bien',
  input_schema = '{
    "fields": [
      {"name": "property_type", "type": "select", "label": "Type de bien", "required": true, "layout": "half",
       "options": [
         {"value": "studio", "label": "Studio"},
         {"value": "appartement T1", "label": "Appartement T1"},
         {"value": "appartement T2", "label": "Appartement T2"},
         {"value": "appartement T3", "label": "Appartement T3"},
         {"value": "appartement T4+", "label": "Appartement T4+"},
         {"value": "maison", "label": "Maison"},
         {"value": "villa", "label": "Villa"},
         {"value": "loft", "label": "Loft"},
         {"value": "chambre", "label": "Chambre"},
         {"value": "local commercial", "label": "Local commercial"},
         {"value": "bureau", "label": "Bureau"}
       ]},
      {"name": "surface_m2", "type": "number", "label": "Surface (m²)", "required": true, "placeholder": "Ex: 42", "min": 5, "max": 9999, "layout": "half"},
      {"name": "city", "type": "text", "label": "Ville ou quartier", "required": true, "placeholder": "Ex: Paris 11ème, Lyon Part-Dieu, Bordeaux Chartrons…"},
      {"name": "condition", "type": "select", "label": "État général du bien", "required": true,
       "options": [
         {"value": "neuf / récent (moins de 5 ans)", "label": "Neuf / récent (moins de 5 ans)"},
         {"value": "bon état, rénové", "label": "Bon état, rénové"},
         {"value": "état correct, entretenu", "label": "État correct, entretenu"},
         {"value": "à rafraîchir", "label": "À rafraîchir"},
         {"value": "travaux importants nécessaires", "label": "Travaux importants nécessaires"}
       ]},
      {"name": "features", "type": "text", "label": "Atouts supplémentaires", "placeholder": "Ex: balcon, parking, gardien, ascenseur, cave, vue dégagée…"},
      {"name": "furnished", "type": "toggle", "label": "Location meublée", "helpText": "Inclut les meubles et équipements essentiels", "trueValue": "meublé", "falseValue": "vide"}
    ]
  }'::jsonb
WHERE slug = 'rent-estimator';

-- client-email-generator
UPDATE public.tools SET
  label = 'Générateur d''emails client',
  description = 'Relance, négociation, estimation',
  icon = '✉️',
  is_featured = true,
  is_new = true,
  sort_order = 4,
  generate_label = 'Générer l''email',
  loading_text = 'L''IA rédige votre email',
  form_panel_title = '📧 Paramètres de l''email'
WHERE slug = 'client-email-generator';

-- investment-analyzer
UPDATE public.tools SET
  label = 'Analyseur d''investissement',
  description = 'Rendement brut, net & recommandation',
  icon = '📈',
  is_featured = true,
  is_new = true,
  sort_order = 8
WHERE slug = 'investment-analyzer';

-- airbnb-profitability
UPDATE public.tools SET
  label = 'Rentabilité loc. courte durée',
  description = 'Potentiel Airbnb / Booking analysé',
  icon = '🏡',
  is_new = true,
  sort_order = 9
WHERE slug = 'airbnb-profitability';

-- Batch update remaining immo tools with labels/descriptions from dashboard
UPDATE public.tools SET label = 'Email de suivi acquéreur', description = 'Relancez vos prospects', icon = '📧', sort_order = 2 WHERE slug = 'immo-email-suivi' AND label IS NULL;
UPDATE public.tools SET label = 'Rapport de visite', description = 'Compte-rendu professionnel', icon = '📋', sort_order = 5 WHERE slug = 'immo-rapport-visite' AND label IS NULL;
UPDATE public.tools SET label = 'Analyse comparative de prix', description = 'Analyse de marché argumentée', icon = '📊', sort_order = 6 WHERE slug = 'immo-analyse-prix' AND label IS NULL;
UPDATE public.tools SET label = 'Script de prospection', description = 'Appels & SMS nouveaux mandats', icon = '📞', sort_order = 7 WHERE slug = 'immo-script-prosp' AND label IS NULL;
UPDATE public.tools SET label = 'Argumentaire mandat exclusif', description = 'Décrochez le mandat exclusif', icon = '🏆', sort_order = 10 WHERE slug = 'immo-mandat-exclusif' AND label IS NULL;
UPDATE public.tools SET label = 'Posts réseaux sociaux', description = 'LinkedIn/Instagram pour vos biens', icon = '📱', sort_order = 11 WHERE slug = 'immo-posts-sociaux' AND label IS NULL;
UPDATE public.tools SET label = 'Email présentation vendeur', description = 'Présentez une offre au vendeur', icon = '💌', sort_order = 12 WHERE slug = 'immo-email-vendeur' AND label IS NULL;

-- Commerce tools
UPDATE public.tools SET label = 'Fiches produits SEO', description = 'Fiches optimisées en masse', icon = '🛒', is_featured = true, sort_order = 1 WHERE slug = 'commerce-fiche-produit' AND label IS NULL;
UPDATE public.tools SET label = 'Email promotionnel', description = 'Emails marketing qui convertissent', icon = '📧', is_featured = true, sort_order = 2 WHERE slug = 'commerce-email-promo' AND label IS NULL;
UPDATE public.tools SET label = 'Description SEO', description = 'Optimisez pour le référencement', icon = '🔍', sort_order = 3 WHERE slug = 'commerce-seo-description' AND label IS NULL;
UPDATE public.tools SET label = 'Contenu réseaux sociaux', description = 'Posts Instagram, Facebook, TikTok', icon = '📱', sort_order = 4 WHERE slug = 'commerce-posts-sociaux' AND label IS NULL;
UPDATE public.tools SET label = 'Relance panier abandonné', description = 'Récupérez les paniers', icon = '🛍️', sort_order = 5 WHERE slug = 'commerce-relance-panier' AND label IS NULL;
UPDATE public.tools SET label = 'Script chatbot SAV', description = 'Script service client complet', icon = '💬', sort_order = 6 WHERE slug = 'commerce-chatbot-sav' AND label IS NULL;
UPDATE public.tools SET label = 'Stratégie de contenu', description = 'Plan marketing mensuel complet', icon = '🎯', sort_order = 7 WHERE slug = 'commerce-strategie' AND label IS NULL;
UPDATE public.tools SET label = 'Analyse concurrentielle', description = 'Positionnement vs concurrence', icon = '📊', sort_order = 8 WHERE slug = 'commerce-analyse-concur' AND label IS NULL;

-- Legal tools
UPDATE public.tools SET label = 'Rédacteur de courriers', description = 'Courriers juridiques professionnels', icon = '✉️', is_featured = true, sort_order = 1 WHERE slug = 'legal-courrier' AND label IS NULL;
UPDATE public.tools SET label = 'Résumé de contrat', description = 'Points clés en moins d''1 minute', icon = '📋', is_featured = true, sort_order = 2 WHERE slug = 'legal-resume-contrat' AND label IS NULL;
UPDATE public.tools SET label = 'Note juridique', description = 'Note de synthèse structurée', icon = '⚖️', sort_order = 3 WHERE slug = 'legal-note-juridique' AND label IS NULL;
UPDATE public.tools SET label = 'Analyse de clause', description = 'Identifiez les risques contractuels', icon = '🔎', sort_order = 4 WHERE slug = 'legal-analyse-clause' AND label IS NULL;
UPDATE public.tools SET label = 'Mise en demeure', description = 'Rédaction légalement solide', icon = '📜', sort_order = 5 WHERE slug = 'legal-mise-en-demeure' AND label IS NULL;
UPDATE public.tools SET label = 'Contrat type', description = 'Contrat adapté à votre situation', icon = '📄', sort_order = 6 WHERE slug = 'legal-contrat-standard' AND label IS NULL;
UPDATE public.tools SET label = 'Recherche jurisprudentielle', description = 'Synthèse sur une question de droit', icon = '🏛️', sort_order = 7 WHERE slug = 'legal-jurisprudence' AND label IS NULL;
UPDATE public.tools SET label = 'Arguments de plaidoirie', description = 'Structurez vos arguments', icon = '🎤', sort_order = 8 WHERE slug = 'legal-plaidoirie' AND label IS NULL;

-- Finance tools
UPDATE public.tools SET label = 'Synthèse de rapport', description = 'Résumez un rapport financier', icon = '📊', is_featured = true, sort_order = 1 WHERE slug = 'finance-synthese' AND label IS NULL;
UPDATE public.tools SET label = 'Email professionnel finance', description = 'Emails formels pour DAF/investisseurs', icon = '📧', sort_order = 2 WHERE slug = 'finance-email-pro' AND label IS NULL;
UPDATE public.tools SET label = 'Analyse de KPIs', description = 'Interprétez vos indicateurs', icon = '📈', is_featured = true, sort_order = 3 WHERE slug = 'finance-analyse-kpi' AND label IS NULL;
UPDATE public.tools SET label = 'Rapport d''investissement', description = 'Analyse d''investissement', icon = '💰', sort_order = 4 WHERE slug = 'finance-rapport-invest' AND label IS NULL;
UPDATE public.tools SET label = 'Budget prévisionnel', description = 'Commentaire de votre budget', icon = '📅', sort_order = 5 WHERE slug = 'finance-budget-prevision' AND label IS NULL;
UPDATE public.tools SET label = 'Deck investisseur', description = 'Pitch deck pour levée de fonds', icon = '🚀', sort_order = 6 WHERE slug = 'finance-deck-invest' AND label IS NULL;
UPDATE public.tools SET label = 'Stratégie financière', description = 'Optimisez votre stratégie', icon = '🎯', sort_order = 7 WHERE slug = 'finance-strategie' AND label IS NULL;
UPDATE public.tools SET label = 'Due diligence', description = 'Analyse IA pour une acquisition', icon = '🔬', sort_order = 8 WHERE slug = 'finance-due-diligence' AND label IS NULL;

-- ─── 5. Add RLS policy for tools read ───────────────────────────────────────

-- Allow authenticated users to read active tools
DROP POLICY IF EXISTS "Authenticated users read active tools" ON public.tools;
CREATE POLICY "Authenticated users read active tools"
  ON public.tools FOR SELECT
  USING (is_active = true OR EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true
  ));

-- ─── 6. Index for tool listing queries ──────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_tools_vertical_sort
  ON public.tools(vertical, sort_order);

CREATE INDEX IF NOT EXISTS idx_tools_slug
  ON public.tools(slug);

-- ─── Done! ──────────────────────────────────────────────────────────────────
SELECT 'Migration v4 OK — Dynamic tool configuration columns added, verticals table created, 2 tools fully seeded with input_schema' AS status;

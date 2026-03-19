-- ============================================================================
-- CRM PROJECTS — The Prompt Studio
-- Run this migration in Supabase SQL Editor
-- ============================================================================

-- ── 1. Projects table ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vertical     TEXT NOT NULL,
  name         TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'active'
                 CHECK (status IN ('active', 'completed', 'archived')),
  data         JSONB NOT NULL DEFAULT '{}',
  notes        TEXT DEFAULT '',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_projects_user_vertical
  ON projects (user_id, vertical);
CREATE INDEX IF NOT EXISTS idx_projects_status
  ON projects (user_id, status);
CREATE INDEX IF NOT EXISTS idx_projects_updated
  ON projects (user_id, updated_at DESC);

-- RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY projects_select ON projects FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY projects_insert ON projects FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY projects_update ON projects FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY projects_delete ON projects FOR DELETE USING (auth.uid() = user_id);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_projects_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_projects_updated_at
  BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_projects_updated_at();

-- ── 2. Link generations to projects ──────────────────────────────────────────
ALTER TABLE tool_usage ADD COLUMN IF NOT EXISTS project_id UUID REFERENCES projects(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_tool_usage_project ON tool_usage (project_id) WHERE project_id IS NOT NULL;

-- ── 3. Project field templates per vertical ──────────────────────────────────
-- These define which structured fields each vertical's projects have.
-- Stored as a reference table so the frontend can dynamically render forms.
CREATE TABLE IF NOT EXISTS project_field_templates (
  id         SERIAL PRIMARY KEY,
  vertical   TEXT NOT NULL,
  field_key  TEXT NOT NULL,
  label      TEXT NOT NULL,
  type       TEXT NOT NULL DEFAULT 'text'
               CHECK (type IN ('text', 'textarea', 'number', 'select', 'url', 'date', 'tags')),
  placeholder TEXT DEFAULT '',
  options    JSONB DEFAULT NULL,          -- for select type: ["opt1","opt2"]
  sort_order INT NOT NULL DEFAULT 0,
  required   BOOLEAN NOT NULL DEFAULT false,
  UNIQUE (vertical, field_key)
);

-- ── 4. Seed field templates for each vertical ────────────────────────────────

-- IMMOBILIER
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('immo', 'type_bien',     'Type de bien',    'select', '', 1, true),
  ('immo', 'transaction',   'Transaction',     'select', '', 2, true),
  ('immo', 'adresse',       'Adresse',         'text',   'Ex: 12 rue de la Paix, 75002 Paris', 3, false),
  ('immo', 'surface',       'Surface (m²)',    'number', 'Ex: 85', 4, true),
  ('immo', 'pieces',        'Nombre de pièces','number', 'Ex: 4', 5, false),
  ('immo', 'prix',          'Prix (€)',        'number', 'Ex: 450000', 6, true),
  ('immo', 'lien_annonce',  'Lien annonce',    'url',    'https://...', 7, false),
  ('immo', 'points_forts',  'Points forts',    'textarea','Ex: Vue dégagée, parquet, cave...', 8, false),
  ('immo', 'description',   'Description libre','textarea','Notes sur le bien...', 9, false),
  ('immo', 'contact_nom',   'Nom du contact',  'text',   'Ex: M. Dupont', 10, false),
  ('immo', 'contact_tel',   'Téléphone',       'text',   'Ex: 06 12 34 56 78', 11, false),
  ('immo', 'contact_email', 'Email contact',   'text',   'Ex: dupont@email.com', 12, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

-- Options for select fields
UPDATE project_field_templates SET options = '["Appartement","Maison","Studio","Loft","Terrain","Commerce","Bureau","Parking","Autre"]'
  WHERE vertical = 'immo' AND field_key = 'type_bien';
UPDATE project_field_templates SET options = '["Vente","Location","Viager","Colocation"]'
  WHERE vertical = 'immo' AND field_key = 'transaction';

-- JURIDIQUE
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('legal', 'ref_dossier',   'Référence dossier',  'text',     'Ex: DOS-2026-042', 1, false),
  ('legal', 'type_affaire',  'Type d''affaire',     'select',   '', 2, true),
  ('legal', 'client_nom',    'Nom du client',       'text',     'Ex: SAS Dupont & Fils', 3, true),
  ('legal', 'partie_adverse','Partie adverse',      'text',     'Ex: SARL Martin', 4, false),
  ('legal', 'juridiction',   'Juridiction',         'text',     'Ex: TGI Paris', 5, false),
  ('legal', 'date_audience', 'Date d''audience',    'date',     '', 6, false),
  ('legal', 'enjeu',         'Enjeu / montant',     'text',     'Ex: 150 000 €', 7, false),
  ('legal', 'resume_faits',  'Résumé des faits',    'textarea', 'Décrivez brièvement les faits...', 8, true),
  ('legal', 'documents',     'Documents clés',      'textarea', 'Listez les pièces du dossier...', 9, false),
  ('legal', 'notes',         'Notes internes',      'textarea', '', 10, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["Contentieux civil","Contentieux commercial","Droit du travail","Droit pénal","Droit de la famille","Droit immobilier","Propriété intellectuelle","Droit des sociétés","Autre"]'
  WHERE vertical = 'legal' AND field_key = 'type_affaire';

-- E-COMMERCE
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('commerce', 'nom_produit',   'Nom du produit',     'text',     'Ex: Sac en cuir vegan', 1, true),
  ('commerce', 'categorie',     'Catégorie',          'select',   '', 2, false),
  ('commerce', 'prix',          'Prix (€)',           'number',   'Ex: 89', 3, true),
  ('commerce', 'lien_produit',  'Lien produit',       'url',      'https://...', 4, false),
  ('commerce', 'marque',        'Marque',             'text',     'Ex: EcoChic', 5, false),
  ('commerce', 'description',   'Description produit','textarea', 'Caractéristiques, matériaux...', 6, true),
  ('commerce', 'public_cible',  'Public cible',       'text',     'Ex: Femmes 25-45 ans, CSP+', 7, false),
  ('commerce', 'avantages',     'Avantages clés',     'textarea', 'Ex: Éco-responsable, fait main...', 8, false),
  ('commerce', 'mots_cles_seo', 'Mots-clés SEO',     'textarea', 'Ex: sac cuir vegan, maroquinerie...', 9, false),
  ('commerce', 'notes',         'Notes',              'textarea', '', 10, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["Mode & Accessoires","Beauté & Santé","Maison & Déco","Tech & Électronique","Sport & Plein air","Alimentation","Enfants","Autre"]'
  WHERE vertical = 'commerce' AND field_key = 'categorie';

-- FINANCE
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('finance', 'client_nom',    'Nom du client',      'text',     'Ex: M. Bernard Martin', 1, true),
  ('finance', 'type_mission',  'Type de mission',    'select',   '', 2, true),
  ('finance', 'societe',       'Société concernée',  'text',     'Ex: SAS TechVision', 3, false),
  ('finance', 'ca_annuel',     'CA annuel (€)',      'number',   '', 4, false),
  ('finance', 'secteur',       'Secteur d''activité','text',     'Ex: SaaS B2B', 5, false),
  ('finance', 'periode',       'Période concernée',  'text',     'Ex: Q4 2025 / Année 2025', 6, false),
  ('finance', 'objectifs',     'Objectifs',          'textarea', 'Ex: Optimisation fiscale, levée de fonds...', 7, false),
  ('finance', 'documents',     'Documents disponibles','textarea','Ex: Bilan, compte de résultat, liasse fiscale...', 8, false),
  ('finance', 'notes',         'Notes',              'textarea', '', 9, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["Bilan & clôture","Analyse financière","Prévisionnel","Optimisation fiscale","Levée de fonds","Audit","Conseil CGP","Autre"]'
  WHERE vertical = 'finance' AND field_key = 'type_mission';

-- MARKETING
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('marketing', 'nom_campagne', 'Nom campagne/projet','text',    'Ex: Lancement produit X Q2', 1, true),
  ('marketing', 'client',       'Client / Marque',    'text',    'Ex: NaturaBio', 2, true),
  ('marketing', 'objectif',     'Objectif',           'select',  '', 3, true),
  ('marketing', 'cible',        'Audience cible',     'text',    'Ex: Hommes 25-40, urbains, CSP+', 4, false),
  ('marketing', 'canaux',       'Canaux',             'text',    'Ex: LinkedIn, Email, SEO', 5, false),
  ('marketing', 'budget',       'Budget (€)',         'number',  '', 6, false),
  ('marketing', 'deadline',     'Deadline',           'date',    '', 7, false),
  ('marketing', 'brief',        'Brief créatif',      'textarea','Ton, messages clés, contraintes...', 8, false),
  ('marketing', 'urls',         'Liens utiles',       'textarea','Site, réseaux, landing pages...', 9, false),
  ('marketing', 'notes',        'Notes',              'textarea','', 10, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["Acquisition","Notoriété","Engagement","Conversion","Fidélisation","Lancement produit","Rebranding","Autre"]'
  WHERE vertical = 'marketing' AND field_key = 'objectif';

-- RH
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('rh', 'intitule_poste','Intitulé du poste',   'text',    'Ex: Développeur Full-Stack Senior', 1, true),
  ('rh', 'type_contrat',  'Type de contrat',     'select',  '', 2, true),
  ('rh', 'departement',   'Département',         'text',    'Ex: Tech / Engineering', 3, false),
  ('rh', 'localisation',  'Localisation',        'text',    'Ex: Paris, remote partiel', 4, false),
  ('rh', 'salaire',       'Fourchette salariale','text',    'Ex: 55-65K€', 5, false),
  ('rh', 'candidat_nom',  'Nom du candidat',     'text',    '', 6, false),
  ('rh', 'profil',        'Profil recherché',    'textarea','Compétences, expérience...', 7, false),
  ('rh', 'contexte',      'Contexte recrutement','textarea','Remplacement, création de poste...', 8, false),
  ('rh', 'notes',         'Notes',               'textarea','', 9, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["CDI","CDD","Stage","Alternance","Freelance","Intérim","Autre"]'
  WHERE vertical = 'rh' AND field_key = 'type_contrat';

-- SANTÉ
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('sante', 'patient_ref',   'Réf. patient/dossier','text',   'Ex: PAT-2026-115', 1, false),
  ('sante', 'type_soin',     'Type de soin',        'select', '', 2, true),
  ('sante', 'specialite',    'Spécialité',          'text',   'Ex: Kinésithérapie', 3, false),
  ('sante', 'diagnostic',    'Diagnostic / motif',  'textarea','', 4, false),
  ('sante', 'traitement',    'Traitement en cours', 'textarea','', 5, false),
  ('sante', 'objectifs',     'Objectifs de soins',  'textarea','', 6, false),
  ('sante', 'notes',         'Notes',               'textarea','', 7, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["Consultation","Suivi","Programme de soins","Bilan","Rééducation","Prévention","Autre"]'
  WHERE vertical = 'sante' AND field_key = 'type_soin';

-- EDUCATION
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('education', 'nom_formation','Nom de la formation','text',    'Ex: Initiation au marketing digital', 1, true),
  ('education', 'type',         'Type',               'select',  '', 2, true),
  ('education', 'public',       'Public cible',       'text',    'Ex: Cadres en reconversion', 3, false),
  ('education', 'duree',        'Durée',              'text',    'Ex: 3 jours / 21h', 4, false),
  ('education', 'objectifs',    'Objectifs pédagogiques','textarea','', 5, false),
  ('education', 'programme',    'Programme / plan',   'textarea', '', 6, false),
  ('education', 'notes',        'Notes',              'textarea', '', 7, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["Formation présentielle","Formation en ligne","E-learning","Webinaire","Atelier","Cours particulier","Certification","Autre"]'
  WHERE vertical = 'education' AND field_key = 'type';

-- RESTAURATION
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('restauration', 'nom_etablissement','Nom établissement', 'text',    'Ex: Le Bistrot du Marché', 1, true),
  ('restauration', 'type_cuisine',     'Type de cuisine',   'select',  '', 2, false),
  ('restauration', 'localisation',     'Localisation',      'text',    'Ex: Bordeaux centre', 3, false),
  ('restauration', 'specialites',      'Spécialités',       'textarea','Ex: Cuisine du marché, bio, végétarien...', 4, false),
  ('restauration', 'ambiance',         'Ambiance / concept','textarea','Ex: Bistrot moderne, décontracté...', 5, false),
  ('restauration', 'gamme_prix',       'Gamme de prix',     'text',    'Ex: 15-35€ le plat', 6, false),
  ('restauration', 'urls',             'Liens (site, avis)','textarea','', 7, false),
  ('restauration', 'notes',            'Notes',             'textarea','', 8, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["Française","Italienne","Japonaise","Méditerranéenne","Fast casual","Street food","Gastronomique","Brasserie","Pâtisserie","Autre"]'
  WHERE vertical = 'restauration' AND field_key = 'type_cuisine';

-- FREELANCE
INSERT INTO project_field_templates (vertical, field_key, label, type, placeholder, sort_order, required) VALUES
  ('freelance', 'nom_client',   'Nom du client',      'text',    'Ex: SAS InnoTech', 1, true),
  ('freelance', 'type_mission', 'Type de mission',    'select',  '', 2, true),
  ('freelance', 'budget',       'Budget / TJM',       'text',    'Ex: 5 000€ ou 550€/j', 3, false),
  ('freelance', 'deadline',     'Deadline',           'date',    '', 4, false),
  ('freelance', 'contexte',     'Contexte de mission','textarea','Besoin du client, enjeux...', 5, false),
  ('freelance', 'livrables',    'Livrables attendus', 'textarea','Ex: Audit SEO, plan d''action, rapport...', 6, false),
  ('freelance', 'contact',      'Contact client',     'text',    'Ex: Jean Martin — jean@innotech.fr', 7, false),
  ('freelance', 'notes',        'Notes',              'textarea','', 8, false)
ON CONFLICT (vertical, field_key) DO NOTHING;

UPDATE project_field_templates SET options = '["Conseil","Développement","Design","Rédaction","Marketing","Formation","Audit","Accompagnement","Autre"]'
  WHERE vertical = 'freelance' AND field_key = 'type_mission';

-- RLS for field templates (read-only for all authenticated users)
ALTER TABLE project_field_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY pft_select ON project_field_templates FOR SELECT USING (true);

-- ── 5. Mapping: project fields → tool input fields ───────────────────────────
-- This tells the system which project data field maps to which tool input field
-- so tools can be pre-filled from project context.
CREATE TABLE IF NOT EXISTS project_tool_mappings (
  id          SERIAL PRIMARY KEY,
  vertical    TEXT NOT NULL,
  tool_slug   TEXT NOT NULL,
  project_field TEXT NOT NULL,    -- key from projects.data
  tool_field    TEXT NOT NULL,    -- key from tool input_schema.fields[].name
  UNIQUE (vertical, tool_slug, project_field)
);

ALTER TABLE project_tool_mappings ENABLE ROW LEVEL SECURITY;
CREATE POLICY ptm_select ON project_tool_mappings FOR SELECT USING (true);

-- Seed mappings for IMMOBILIER tools
INSERT INTO project_tool_mappings (vertical, tool_slug, project_field, tool_field) VALUES
  ('immo', 'immo-annonce', 'type_bien', 'type_bien'),
  ('immo', 'immo-annonce', 'surface', 'surface'),
  ('immo', 'immo-annonce', 'pieces', 'pieces'),
  ('immo', 'immo-annonce', 'prix', 'prix'),
  ('immo', 'immo-annonce', 'adresse', 'localisation'),
  ('immo', 'immo-annonce', 'points_forts', 'points_forts')
ON CONFLICT (vertical, tool_slug, project_field) DO NOTHING;

-- ============================================================================
-- DONE. Run this SQL in Supabase SQL Editor.
-- ============================================================================

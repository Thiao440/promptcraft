-- ═══════════════════════════════════════════════════════════════════════════
-- The Prompt Studio — Tool Catalog Migration v5
-- 100 tools across 10 verticals with full input_schema and prompt_template
-- Generated: 2026-03-17
-- ═══════════════════════════════════════════════════════════════════════════

-- Add new verticals (existing ones will be skipped via ON CONFLICT)
INSERT INTO verticals (key, label, icon, color, bg, border_color, sort_order, is_active) VALUES
  ('immo', 'Immobilier', '🏠', '#f59e0b', '#f59e0b15', '#f59e0b40', 1, true),
  ('commerce', 'E-Commerce & Retail', '🛒', '#3b82f6', '#3b82f615', '#3b82f640', 2, true),
  ('legal', 'Juridique', '⚖️', '#8b5cf6', '#8b5cf615', '#8b5cf640', 3, true),
  ('finance', 'Finance & Comptabilité', '💰', '#10b981', '#10b98115', '#10b98140', 4, true),
  ('marketing', 'Marketing & Communication', '📣', '#ec4899', '#ec489915', '#ec489940', 5, true),
  ('rh', 'Ressources Humaines', '👥', '#f97316', '#f9731615', '#f9731640', 6, true),
  ('sante', 'Santé & Bien-être', '🏥', '#06b6d4', '#06b6d415', '#06b6d440', 7, true),
  ('education', 'Éducation & Formation', '🎓', '#6366f1', '#6366f115', '#6366f140', 8, true),
  ('restauration', 'Restauration & Hôtellerie', '🍽️', '#ef4444', '#ef444415', '#ef444440', 9, true),
  ('freelance', 'Freelances & Consultants', '💼', '#84cc16', '#84cc1615', '#84cc1640', 10, true)
ON CONFLICT (key) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, color = EXCLUDED.color, sort_order = EXCLUDED.sort_order;

-- ═══════════════════════════════════════════════════════════════════════════
-- Insert all 100 tools
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-annonce',
  'immo-annonce',
  'Générateur d''annonces immobilières',
  'Créez des annonces immobilières percutantes et optimisées SEO',
  '🏡',
  'immo',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "options": ["Appartement", "Maison", "Studio", "Loft", "Villa", "Terrain", "Local commercial", "Parking"]}, {"name": "operation", "type": "radio", "label": "Type d''opération", "required": true, "options": ["Vente", "Location", "Location saisonnière"]}, {"name": "surface", "type": "number", "label": "Surface (m²)", "required": true, "placeholder": "85"}, {"name": "pieces", "type": "number", "label": "Nombre de pièces", "required": true, "placeholder": "3"}, {"name": "ville", "type": "text", "label": "Ville / Quartier", "required": true, "placeholder": "Lyon 6ème"}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "350 000 €"}, {"name": "atouts", "type": "textarea", "label": "Points forts du bien", "required": true, "placeholder": "Balcon sud, parquet massif, cave, gardien…", "maxlength": 500}, {"name": "dpe", "type": "select", "label": "DPE", "required": false, "options": ["A", "B", "C", "D", "E", "F", "G", "Non renseigné"]}, {"name": "ton", "type": "tone_grid", "label": "Ton de l''annonce", "required": true, "options": ["Professionnel", "Chaleureux", "Luxe", "Dynamique", "Sobre"]}]}'::jsonb,
  'Tu es un expert en rédaction d''annonces immobilières en France. Rédige une annonce immobilière complète, percutante et optimisée SEO.

Bien : {{type_bien}} — {{operation}}
Surface : {{surface}} m² — {{pieces}} pièces
Localisation : {{ville}}
Prix : {{prix}}
DPE : {{dpe}}
Points forts : {{atouts}}
Ton souhaité : {{ton}}

Rédige une annonce structurée avec : un titre accrocheur, une description détaillée (200-300 mots), les points forts mis en valeur, et une conclusion incitant à la prise de contact. Optimise pour le SEO immobilier local.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-description-luxe',
  'immo-description-luxe',
  'Description bien de prestige',
  'Rédigez des descriptions haut de gamme pour biens d''exception',
  '🏰',
  'immo',
  'silver',
  false,
  false,
  2,
  true,
  '{"fields": [{"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "options": ["Villa", "Penthouse", "Hôtel particulier", "Château", "Mas provençal", "Chalet", "Appartement d''exception"]}, {"name": "surface", "type": "number", "label": "Surface (m²)", "required": true, "placeholder": "350"}, {"name": "ville", "type": "text", "label": "Localisation", "required": true, "placeholder": "Cap d''Antibes"}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "2 800 000 €"}, {"name": "prestations", "type": "textarea", "label": "Prestations exceptionnelles", "required": true, "placeholder": "Piscine à débordement, vue mer panoramique, domotique…", "maxlength": 600}, {"name": "histoire", "type": "textarea", "label": "Histoire / cachet du bien", "required": false, "placeholder": "Bastide du XVIIIe siècle rénovée par…", "maxlength": 400}]}'::jsonb,
  'Tu es un rédacteur spécialisé dans l''immobilier de prestige. Rédige une description haut de gamme digne des plus belles agences de luxe.

Bien : {{type_bien}}
Surface : {{surface}} m²
Localisation : {{ville}}
Prix : {{prix}}
Prestations : {{prestations}}
Histoire / cachet : {{histoire}}

Rédige une description élégante et évocatrice (300-400 mots) qui fait rêver l''acquéreur potentiel. Utilise un vocabulaire raffiné, des métaphores sensorielles, et mets en valeur l''art de vivre lié à ce bien d''exception.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-titre-accrocheur',
  'immo-titre-accrocheur',
  'Titres d''annonces accrocheurs',
  'Générez 10 titres percutants pour vos annonces immobilières',
  '✏️',
  'immo',
  'bronze',
  false,
  true,
  3,
  true,
  '{"fields": [{"name": "type_bien", "type": "text", "label": "Type de bien", "required": true, "placeholder": "Appartement T3"}, {"name": "ville", "type": "text", "label": "Localisation", "required": true, "placeholder": "Bordeaux centre"}, {"name": "atout_principal", "type": "text", "label": "Atout principal", "required": true, "placeholder": "Terrasse 30m² vue Garonne"}, {"name": "prix", "type": "text", "label": "Prix", "required": false, "placeholder": "285 000 €"}, {"name": "style", "type": "select", "label": "Style souhaité", "required": true, "options": ["Classique", "Percutant", "Émotionnel", "Factuel", "Mystérieux"]}]}'::jsonb,
  'Tu es un expert en copywriting immobilier. Génère 10 titres d''annonces percutants et variés.

Bien : {{type_bien}}
Localisation : {{ville}}
Atout principal : {{atout_principal}}
Prix : {{prix}}
Style souhaité : {{style}}

Génère exactement 10 titres numérotés, chacun unique et accrocheur. Varie les approches : émotion, chiffres, question, bénéfice, rareté. Chaque titre doit faire max 80 caractères.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-visite-virtuelle',
  'immo-visite-virtuelle',
  'Script visite virtuelle',
  'Rédigez le script narré pour vos visites virtuelles vidéo',
  '🎬',
  'immo',
  'silver',
  false,
  true,
  4,
  true,
  '{"fields": [{"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "options": ["Appartement", "Maison", "Villa", "Loft", "Local commercial"]}, {"name": "pieces_description", "type": "textarea", "label": "Description pièce par pièce", "required": true, "placeholder": "Entrée avec placard intégré, séjour double avec cheminée, cuisine américaine équipée…", "maxlength": 800}, {"name": "points_forts", "type": "textarea", "label": "Points forts à mettre en avant", "required": true, "placeholder": "Luminosité, volumes, vue dégagée…", "maxlength": 400}, {"name": "duree", "type": "select", "label": "Durée cible", "required": true, "options": ["1 minute", "2 minutes", "3 minutes", "5 minutes"]}]}'::jsonb,
  'Tu es un scénariste spécialisé en visites virtuelles immobilières. Rédige un script narré professionnel.

Bien : {{type_bien}}
Description des pièces : {{pieces_description}}
Points forts : {{points_forts}}
Durée cible : {{duree}}

Rédige un script fluide avec : introduction accueillante, transition entre chaque pièce, mise en valeur des points forts, conclusion avec appel à l''action. Indique les pauses et les moments où la caméra doit s''attarder.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rent-estimator',
  'rent-estimator',
  'Estimation de loyer',
  'Estimez le loyer optimal selon le marché et les caractéristiques du bien',
  '💶',
  'immo',
  'bronze',
  true,
  false,
  5,
  true,
  '{"fields": [{"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "options": ["Appartement", "Maison", "Studio", "Chambre", "Local commercial"]}, {"name": "surface", "type": "number", "label": "Surface (m²)", "required": true, "placeholder": "45"}, {"name": "pieces", "type": "number", "label": "Nombre de pièces", "required": true, "placeholder": "2"}, {"name": "ville", "type": "text", "label": "Ville / Quartier", "required": true, "placeholder": "Paris 11ème"}, {"name": "meuble", "type": "toggle", "label": "Meublé", "required": false}, {"name": "equipements", "type": "textarea", "label": "Équipements notables", "required": false, "placeholder": "Balcon, parking, cave, gardien…", "maxlength": 300}, {"name": "dpe", "type": "select", "label": "DPE", "required": false, "options": ["A", "B", "C", "D", "E", "F", "G"]}]}'::jsonb,
  'Tu es un expert du marché locatif français. Estime le loyer optimal pour ce bien en te basant sur ta connaissance du marché.

Bien : {{type_bien}}
Surface : {{surface}} m²
Pièces : {{pieces}}
Localisation : {{ville}}
Meublé : {{meuble}}
Équipements : {{equipements}}
DPE : {{dpe}}

Fournis : une fourchette de loyer (min/moyen/max), une analyse des facteurs de valorisation et dévalorisation, des conseils pour optimiser le loyer, et une comparaison avec le marché local. Mentionne l''encadrement des loyers si applicable.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-analyse-marche',
  'immo-analyse-marche',
  'Analyse de marché local',
  'Obtenez une analyse détaillée du marché immobilier de votre secteur',
  '📊',
  'immo',
  'silver',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "ville", "type": "text", "label": "Ville / Secteur", "required": true, "placeholder": "Nantes — Île de Nantes"}, {"name": "type_bien", "type": "select", "label": "Segment", "required": true, "options": ["Résidentiel", "Commercial", "Bureaux", "Terrain", "Mixte"]}, {"name": "rayon", "type": "select", "label": "Rayon d''analyse", "required": true, "options": ["Quartier", "Ville", "Agglomération", "Département"]}, {"name": "objectif", "type": "textarea", "label": "Objectif de l''analyse", "required": true, "placeholder": "Estimer la faisabilité d''un programme neuf de 20 lots", "maxlength": 400}]}'::jsonb,
  'Tu es un analyste du marché immobilier français. Fournis une analyse de marché structurée et actionnable.

Secteur : {{ville}}
Segment : {{type_bien}}
Rayon : {{rayon}}
Objectif : {{objectif}}

Structure ton analyse : tendances des prix (évolution récente), dynamique offre/demande, profil des acheteurs/locataires, projets urbains impactants, perspectives à 6-12 mois, et recommandations concrètes liées à l''objectif.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-comparatif-biens',
  'immo-comparatif-biens',
  'Comparatif de biens',
  'Générez un tableau comparatif professionnel pour vos clients',
  '📋',
  'immo',
  'bronze',
  false,
  false,
  7,
  true,
  '{"fields": [{"name": "bien1", "type": "textarea", "label": "Bien 1", "required": true, "placeholder": "T3 65m², Lyon 3, 280K€, balcon, DPE C", "maxlength": 300}, {"name": "bien2", "type": "textarea", "label": "Bien 2", "required": true, "placeholder": "T3 58m², Lyon 7, 265K€, parking, DPE D", "maxlength": 300}, {"name": "bien3", "type": "textarea", "label": "Bien 3 (optionnel)", "required": false, "placeholder": "T3 72m², Lyon 8, 310K€, terrasse, DPE B", "maxlength": 300}, {"name": "criteres", "type": "text", "label": "Critères prioritaires", "required": true, "placeholder": "Prix au m², transports, DPE, extérieur"}]}'::jsonb,
  'Tu es un conseiller immobilier expert. Génère un tableau comparatif professionnel et objectif.

Bien 1 : {{bien1}}
Bien 2 : {{bien2}}
Bien 3 : {{bien3}}
Critères prioritaires : {{criteres}}

Crée un comparatif structuré avec : tableau synthétique (critères en lignes, biens en colonnes), analyse des forces/faiblesses de chaque bien, note sur 10 par critère, recommandation finale argumentée.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-email-prospect',
  'immo-email-prospect',
  'Email de prospection vendeur',
  'Rédigez des emails de prospection pour décrocher des mandats',
  '📧',
  'immo',
  'bronze',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "nom_prospect", "type": "text", "label": "Nom du prospect", "required": true, "placeholder": "M. et Mme Dupont"}, {"name": "contexte", "type": "select", "label": "Contexte", "required": true, "options": ["Première prise de contact", "Relance après estimation", "Après visite quartier", "Après événement local", "Recommandation"]}, {"name": "argument_cle", "type": "textarea", "label": "Argument clé", "required": true, "placeholder": "Hausse des prix de 8% dans leur quartier, moment idéal pour vendre", "maxlength": 400}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Amical", "Direct", "Rassurant"]}]}'::jsonb,
  'Tu es un agent immobilier expert en prospection. Rédige un email de prospection vendeur percutant.

Prospect : {{nom_prospect}}
Contexte : {{contexte}}
Argument clé : {{argument_cle}}
Ton : {{ton}}

Rédige un email court (150-200 mots max), personnalisé, avec : objet accrocheur, accroche personnalisée, argument de valeur, appel à l''action clair. L''objectif est d''obtenir un rendez-vous d''estimation.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-compte-rendu-visite',
  'immo-compte-rendu-visite',
  'Compte-rendu de visite',
  'Générez un compte-rendu de visite professionnel pour vos acquéreurs',
  '📝',
  'immo',
  'bronze',
  false,
  true,
  9,
  true,
  '{"fields": [{"name": "bien", "type": "text", "label": "Bien visité", "required": true, "placeholder": "T4 92m² — 15 rue des Lilas, Lyon 3"}, {"name": "client", "type": "text", "label": "Nom du client", "required": true, "placeholder": "M. Martin"}, {"name": "impressions", "type": "textarea", "label": "Impressions et remarques", "required": true, "placeholder": "Client satisfait de la luminosité, s''interroge sur le bruit de la rue…", "maxlength": 600}, {"name": "points_positifs", "type": "textarea", "label": "Points positifs relevés", "required": true, "placeholder": "Volumes, état général, proximité métro", "maxlength": 300}, {"name": "reserves", "type": "textarea", "label": "Réserves / Points négatifs", "required": false, "placeholder": "DPE E, travaux copropriété à prévoir", "maxlength": 300}]}'::jsonb,
  'Tu es un agent immobilier professionnel. Rédige un compte-rendu de visite structuré et objectif.

Bien visité : {{bien}}
Client : {{client}}
Impressions : {{impressions}}
Points positifs : {{points_positifs}}
Réserves : {{reserves}}

Rédige un compte-rendu professionnel avec : rappel du bien, synthèse des impressions du client, points forts constatés, réserves identifiées, prochaines étapes recommandées.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'immo-relance-mandat',
  'immo-relance-mandat',
  'Relance propriétaire',
  'Rédigez des messages de relance pour propriétaires hésitants',
  '🔔',
  'immo',
  'silver',
  false,
  false,
  10,
  true,
  '{"fields": [{"name": "nom", "type": "text", "label": "Nom du propriétaire", "required": true, "placeholder": "Mme Lefebvre"}, {"name": "bien", "type": "text", "label": "Bien concerné", "required": true, "placeholder": "Maison T5 — Caluire-et-Cuire"}, {"name": "derniere_interaction", "type": "text", "label": "Dernière interaction", "required": true, "placeholder": "Estimation gratuite il y a 3 semaines"}, {"name": "argument", "type": "textarea", "label": "Nouvel argument / actualité", "required": true, "placeholder": "Vente similaire dans la rue à prix record", "maxlength": 400}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Doux", "Direct", "Informatif", "Urgent"]}]}'::jsonb,
  'Tu es un agent immobilier expérimenté. Rédige un message de relance subtil et efficace.

Propriétaire : {{nom}}
Bien : {{bien}}
Dernière interaction : {{derniere_interaction}}
Nouvel argument : {{argument}}
Ton : {{ton}}

Rédige un message court (100-150 mots), naturel et non intrusif, qui réengage la conversation avec le propriétaire. Intègre le nouvel argument de manière pertinente et propose un prochain pas simple.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-fiche-produit',
  'commerce-fiche-produit',
  'Fiche produit optimisée',
  'Créez des fiches produit persuasives et SEO-friendly',
  '📦',
  'commerce',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "nom_produit", "type": "text", "label": "Nom du produit", "required": true, "placeholder": "Sac à dos urbain NOMAD 25L"}, {"name": "categorie", "type": "text", "label": "Catégorie", "required": true, "placeholder": "Bagagerie / Sacs à dos"}, {"name": "caracteristiques", "type": "textarea", "label": "Caractéristiques techniques", "required": true, "placeholder": "Polyester recyclé 600D, compartiment laptop 15\", poche anti-vol…", "maxlength": 600}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "89,90 €"}, {"name": "cible", "type": "text", "label": "Client cible", "required": true, "placeholder": "Urbains actifs 25-40 ans, trajets quotidiens"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Premium", "Décontracté", "Technique", "Inspirant", "Minimaliste"]}, {"name": "mots_cles", "type": "text", "label": "Mots-clés SEO (optionnel)", "required": false, "placeholder": "sac à dos ville, sac laptop, sac éco-responsable"}]}'::jsonb,
  'Tu es un expert en rédaction de fiches produit e-commerce. Crée une fiche produit optimisée pour la conversion et le SEO.

Produit : {{nom_produit}}
Catégorie : {{categorie}}
Caractéristiques : {{caracteristiques}}
Prix : {{prix}}
Client cible : {{cible}}
Ton : {{ton}}
Mots-clés SEO : {{mots_cles}}

Rédige : un titre SEO optimisé, une description courte (50 mots), une description longue (200 mots), 5 bullet points clés, et une section "Pourquoi choisir ce produit". Optimise pour le SEO tout en restant persuasif.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-bulk-descriptions',
  'commerce-bulk-descriptions',
  'Descriptions en lot',
  'Générez des descriptions pour plusieurs produits à partir d''un CSV',
  '📑',
  'commerce',
  'gold',
  false,
  true,
  2,
  true,
  '{"fields": [{"name": "instructions", "type": "textarea", "label": "Instructions générales", "required": true, "placeholder": "Ton premium, focus sur les matériaux et le confort. Chaque description doit faire 100-150 mots.", "maxlength": 500}, {"name": "produits", "type": "textarea", "label": "Liste des produits (un par ligne)", "required": true, "placeholder": "Nom | caractéristiques clés | prix\nChaussure TREK X1 | Gore-Tex, semelle Vibram | 159€\nVeste ALPINE PRO | Duvet 800, ultra-légère | 299€", "maxlength": 2000}, {"name": "ton", "type": "tone_grid", "label": "Ton global", "required": true, "options": ["Premium", "Technique", "Fun", "Éco-responsable"]}]}'::jsonb,
  'Tu es un rédacteur e-commerce expérimenté. Génère des descriptions produit en lot selon les instructions.

Instructions : {{instructions}}
Ton : {{ton}}

Produits à décrire :
{{produits}}

Pour chaque produit, génère : un titre optimisé, une description respectant les instructions (longueur, ton), et 3 bullet points clés. Sépare clairement chaque produit.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-fiche-amazon',
  'commerce-fiche-amazon',
  'Fiche produit Amazon',
  'Optimisez vos fiches produit pour le format Amazon/marketplace',
  '📱',
  'commerce',
  'silver',
  false,
  false,
  3,
  true,
  '{"fields": [{"name": "nom_produit", "type": "text", "label": "Nom du produit", "required": true, "placeholder": "Chargeur sans fil rapide 15W"}, {"name": "caracteristiques", "type": "textarea", "label": "Caractéristiques / bullet points", "required": true, "placeholder": "Compatible Qi, LED indicateur, protection surchauffe…", "maxlength": 600}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "29,99 €"}, {"name": "mots_cles", "type": "text", "label": "Mots-clés Amazon", "required": true, "placeholder": "chargeur sans fil, chargeur induction rapide, chargeur iPhone"}, {"name": "avantage_concurrent", "type": "text", "label": "Avantage vs concurrence", "required": true, "placeholder": "Seul modèle avec support magnétique intégré"}]}'::jsonb,
  'Tu es un expert en optimisation de fiches Amazon. Crée une fiche produit conforme aux standards Amazon.

Produit : {{nom_produit}}
Caractéristiques : {{caracteristiques}}
Prix : {{prix}}
Mots-clés : {{mots_cles}}
Avantage concurrentiel : {{avantage_concurrent}}

Génère : un titre Amazon optimisé (max 200 caractères, avec mots-clés), 5 bullet points produit (max 500 caractères chacun), une description A+ (HTML simplifié), et 5 backend search terms.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-upsell-cross',
  'commerce-upsell-cross',
  'Textes upsell & cross-sell',
  'Rédigez des textes de recommandation produit convaincants',
  '🔗',
  'commerce',
  'silver',
  false,
  false,
  4,
  true,
  '{"fields": [{"name": "produit_principal", "type": "text", "label": "Produit principal", "required": true, "placeholder": "Machine à café automatique BARISTA Pro"}, {"name": "produits_suggeres", "type": "textarea", "label": "Produits à suggérer", "required": true, "placeholder": "Pack 3 cafés en grains, kit détartrage, tasses espresso", "maxlength": 400}, {"name": "type_reco", "type": "radio", "label": "Type de recommandation", "required": true, "options": ["Upsell (montée en gamme)", "Cross-sell (complémentaire)", "Bundle (pack)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Subtil", "Direct", "Enthousiaste", "Expert"]}]}'::jsonb,
  'Tu es un expert en conversion e-commerce. Rédige des textes de recommandation produit persuasifs.

Produit principal : {{produit_principal}}
Produits suggérés : {{produits_suggeres}}
Type : {{type_reco}}
Ton : {{ton}}

Pour chaque produit suggéré, rédige : un titre de recommandation accrocheur, un texte court (2-3 phrases) expliquant pourquoi ce produit complète parfaitement l''achat principal, et un micro-CTA.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-meta-seo',
  'commerce-meta-seo',
  'Méta-descriptions SEO',
  'Générez titres et méta-descriptions optimisés pour vos pages produit',
  '🔍',
  'commerce',
  'bronze',
  false,
  false,
  5,
  true,
  '{"fields": [{"name": "page_type", "type": "select", "label": "Type de page", "required": true, "options": ["Fiche produit", "Page catégorie", "Page d''accueil", "Blog", "Landing page"]}, {"name": "titre_page", "type": "text", "label": "Titre / sujet de la page", "required": true, "placeholder": "Chaussures de running homme"}, {"name": "mots_cles", "type": "text", "label": "Mots-clés cibles", "required": true, "placeholder": "chaussures running homme, basket course à pied"}, {"name": "usp", "type": "text", "label": "Avantage principal", "required": true, "placeholder": "Livraison gratuite, +200 modèles"}]}'::jsonb,
  'Tu es un expert SEO e-commerce. Génère des méta-données optimisées pour le référencement.

Type de page : {{page_type}}
Sujet : {{titre_page}}
Mots-clés cibles : {{mots_cles}}
Avantage principal : {{usp}}

Génère : 3 variantes de title tag (max 60 caractères, avec mot-clé principal en début), 3 variantes de méta-description (max 155 caractères, avec CTA), et des suggestions de H1/H2 optimisés.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-blog-produit',
  'commerce-blog-produit',
  'Article de blog produit',
  'Rédigez un article de blog optimisé autour d''un produit ou catégorie',
  '📰',
  'commerce',
  'silver',
  true,
  false,
  6,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de l''article", "required": true, "placeholder": "Comment choisir son matelas en 2025"}, {"name": "produits_a_placer", "type": "textarea", "label": "Produits à intégrer", "required": true, "placeholder": "Matelas NUIT Pro (mousse), Matelas CLOUD (latex), Sur-matelas CONFORT+", "maxlength": 400}, {"name": "mots_cles", "type": "text", "label": "Mots-clés SEO", "required": true, "placeholder": "choisir matelas, meilleur matelas, comparatif matelas"}, {"name": "longueur", "type": "select", "label": "Longueur", "required": true, "options": ["Court (500 mots)", "Moyen (1000 mots)", "Long (1500+ mots)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Expert", "Conversationnel", "Comparatif", "Guide pratique"]}]}'::jsonb,
  'Tu es un rédacteur SEO spécialisé en e-commerce. Rédige un article de blog optimisé qui intègre naturellement les produits.

Sujet : {{sujet}}
Produits à intégrer : {{produits_a_placer}}
Mots-clés SEO : {{mots_cles}}
Longueur : {{longueur}}
Ton : {{ton}}

Rédige un article structuré (H2/H3), informatif et engageant, qui intègre les produits de manière naturelle (pas de placement forcé). Inclus une introduction accrocheuse, des sous-titres SEO, et une conclusion avec CTA.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-faq-produit',
  'commerce-faq-produit',
  'FAQ produit',
  'Générez une FAQ complète pour votre page produit',
  '❓',
  'commerce',
  'bronze',
  false,
  true,
  7,
  true,
  '{"fields": [{"name": "nom_produit", "type": "text", "label": "Nom du produit", "required": true, "placeholder": "Aspirateur robot CLEAN X500"}, {"name": "caracteristiques", "type": "textarea", "label": "Caractéristiques principales", "required": true, "placeholder": "Navigation laser, autonomie 180min, bac 600ml, compatible app…", "maxlength": 400}, {"name": "nb_questions", "type": "select", "label": "Nombre de questions", "required": true, "options": ["5", "8", "10", "15"]}, {"name": "themes", "type": "text", "label": "Thèmes à couvrir", "required": false, "placeholder": "Utilisation, entretien, compatibilité, garantie"}]}'::jsonb,
  'Tu es un expert produit e-commerce. Génère une FAQ complète et optimisée SEO.

Produit : {{nom_produit}}
Caractéristiques : {{caracteristiques}}
Nombre de questions : {{nb_questions}}
Thèmes : {{themes}}

Génère {{nb_questions}} questions-réponses au format FAQ. Chaque réponse doit être concise (2-4 phrases), informative et rassurante. Inclus des questions que les clients posent réellement. Optimise pour les featured snippets Google.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-email-panier',
  'commerce-email-panier',
  'Email panier abandonné',
  'Créez des séquences d''email pour récupérer les paniers abandonnés',
  '🛒',
  'commerce',
  'silver',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "nom_boutique", "type": "text", "label": "Nom de la boutique", "required": true, "placeholder": "Maison du Café"}, {"name": "type_produit", "type": "text", "label": "Type de produit abandonné", "required": true, "placeholder": "Cafetière italienne + pack de café"}, {"name": "incentive", "type": "select", "label": "Incentive", "required": true, "options": ["Aucun", "Livraison gratuite", "-10% de réduction", "-15% de réduction", "Cadeau offert", "Stock limité"]}, {"name": "nb_emails", "type": "select", "label": "Nombre d''emails dans la séquence", "required": true, "options": ["1 (rappel simple)", "3 (séquence complète)", "5 (séquence avancée)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Amical", "Urgent", "Humoristique", "Premium"]}]}'::jsonb,
  'Tu es un expert en email marketing e-commerce. Crée une séquence d''emails de récupération de panier abandonné.

Boutique : {{nom_boutique}}
Produit abandonné : {{type_produit}}
Incentive : {{incentive}}
Nombre d''emails : {{nb_emails}}
Ton : {{ton}}

Pour chaque email de la séquence, génère : objet (max 50 car.), preview text, corps de l''email (court, 100-150 mots), CTA principal. Espace les emails de manière logique (1h, 24h, 72h…).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-newsletter',
  'commerce-newsletter',
  'Newsletter e-commerce',
  'Rédigez une newsletter engageante pour votre base client',
  '💌',
  'commerce',
  'bronze',
  false,
  false,
  9,
  true,
  '{"fields": [{"name": "nom_boutique", "type": "text", "label": "Nom de la boutique", "required": true, "placeholder": "Maison du Café"}, {"name": "theme", "type": "text", "label": "Thème de la newsletter", "required": true, "placeholder": "Nouveautés de printemps + promotion -20%"}, {"name": "produits", "type": "textarea", "label": "Produits à mettre en avant", "required": true, "placeholder": "Cafetière V60, Café éthiopien Yirgacheffe, Mug isotherme", "maxlength": 400}, {"name": "cta", "type": "text", "label": "Objectif / CTA principal", "required": true, "placeholder": "Découvrir la collection printemps"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Enthousiaste", "Élégant", "Décontracté", "Informatif"]}]}'::jsonb,
  'Tu es un expert en email marketing. Rédige une newsletter e-commerce engageante.

Boutique : {{nom_boutique}}
Thème : {{theme}}
Produits à mettre en avant : {{produits}}
CTA principal : {{cta}}
Ton : {{ton}}

Rédige : objet accrocheur + 2 variantes, preview text, corps de la newsletter structuré (intro, sections produits, CTA), et un PS engageant.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'commerce-post-instagram',
  'commerce-post-instagram',
  'Post Instagram produit',
  'Créez des posts Instagram captivants avec hashtags optimisés',
  '📸',
  'commerce',
  'bronze',
  false,
  false,
  10,
  true,
  '{"fields": [{"name": "produit", "type": "text", "label": "Produit à promouvoir", "required": true, "placeholder": "Sneakers URBAN FLOW édition limitée"}, {"name": "occasion", "type": "select", "label": "Occasion", "required": true, "options": ["Lancement produit", "Promotion", "Tendance saison", "Behind the scenes", "UGC / témoignage", "Concours"]}, {"name": "cta", "type": "text", "label": "Call-to-action", "required": true, "placeholder": "Lien en bio pour commander"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Cool", "Premium", "Fun", "Inspirant"]}]}'::jsonb,
  'Tu es un community manager e-commerce expert. Crée un post Instagram captivant.

Produit : {{produit}}
Occasion : {{occasion}}
CTA : {{cta}}
Ton : {{ton}}

Génère : le texte du post (max 2200 caractères, avec emojis dosés), 20 hashtags pertinents (mix populaires et niche), et une suggestion de format visuel.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-mise-en-demeure',
  'legal-mise-en-demeure',
  'Mise en demeure',
  'Rédigez une lettre de mise en demeure professionnelle',
  '⚠️',
  'legal',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "expediteur", "type": "text", "label": "Expéditeur (vous / votre client)", "required": true, "placeholder": "SCI Résidence Parc, représentée par Me Durand"}, {"name": "destinataire", "type": "text", "label": "Destinataire", "required": true, "placeholder": "M. Jean Dupont, locataire au 12 rue des Lilas"}, {"name": "objet", "type": "select", "label": "Objet", "required": true, "options": ["Impayés de loyer", "Non-respect contractuel", "Trouble de voisinage", "Livraison non conforme", "Vice caché", "Autre"]}, {"name": "faits", "type": "textarea", "label": "Exposé des faits", "required": true, "placeholder": "Depuis le 1er janvier 2025, le locataire ne s''est pas acquitté de ses loyers…", "maxlength": 800}, {"name": "montant", "type": "text", "label": "Montant réclamé (si applicable)", "required": false, "placeholder": "3 600 € (3 mois de loyer)"}, {"name": "delai", "type": "select", "label": "Délai accordé", "required": true, "options": ["8 jours", "15 jours", "30 jours", "2 mois"]}]}'::jsonb,
  'Tu es un juriste spécialisé en droit français. Rédige une lettre de mise en demeure formelle et professionnelle.

Expéditeur : {{expediteur}}
Destinataire : {{destinataire}}
Objet : {{objet}}
Faits : {{faits}}
Montant réclamé : {{montant}}
Délai accordé : {{delai}}

Rédige une mise en demeure conforme aux usages juridiques français : en-tête, rappel des faits, fondement juridique, demande précise avec délai, mention des suites en cas de non-exécution. Utilise un langage juridique précis mais compréhensible.

IMPORTANT : Ajoute un avertissement que ce document est un modèle et doit être validé par un avocat.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-contrat-type',
  'legal-contrat-type',
  'Contrat type',
  'Générez un projet de contrat adapté à votre besoin',
  '📄',
  'legal',
  'silver',
  true,
  false,
  2,
  true,
  '{"fields": [{"name": "type_contrat", "type": "select", "label": "Type de contrat", "required": true, "options": ["Prestation de services", "NDA / Confidentialité", "Bail commercial", "Bail professionnel", "Contrat de travail CDI", "Contrat de travail CDD", "Cession de droits", "Sous-traitance", "Partenariat"]}, {"name": "partie1", "type": "text", "label": "Partie 1", "required": true, "placeholder": "SARL Digital Agency, RCS Paris 123 456 789"}, {"name": "partie2", "type": "text", "label": "Partie 2", "required": true, "placeholder": "M. Martin Paul, auto-entrepreneur, SIRET 987 654 321"}, {"name": "objet", "type": "textarea", "label": "Objet du contrat", "required": true, "placeholder": "Développement d''un site web e-commerce avec 50 fiches produit", "maxlength": 600}, {"name": "duree", "type": "text", "label": "Durée", "required": true, "placeholder": "6 mois à compter de la signature"}, {"name": "montant", "type": "text", "label": "Montant / rémunération", "required": true, "placeholder": "12 000 € HT, payable en 3 échéances"}, {"name": "clauses_speciales", "type": "textarea", "label": "Clauses spéciales souhaitées", "required": false, "placeholder": "Clause de non-concurrence, pénalités de retard 3x…", "maxlength": 400}]}'::jsonb,
  'Tu es un juriste d''affaires spécialisé en droit des contrats français. Rédige un projet de contrat complet.

Type : {{type_contrat}}
Partie 1 : {{partie1}}
Partie 2 : {{partie2}}
Objet : {{objet}}
Durée : {{duree}}
Montant : {{montant}}
Clauses spéciales : {{clauses_speciales}}

Rédige un contrat structuré avec : préambule, définitions, objet, obligations des parties, conditions financières, durée et résiliation, responsabilité, confidentialité, droit applicable et juridiction. Numérote les articles.

IMPORTANT : Mentionne que ce modèle doit être adapté et validé par un professionnel du droit.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-clauses-specifiques',
  'legal-clauses-specifiques',
  'Clauses spécifiques',
  'Rédigez des clauses contractuelles sur mesure',
  '🔏',
  'legal',
  'silver',
  false,
  false,
  3,
  true,
  '{"fields": [{"name": "type_clause", "type": "select", "label": "Type de clause", "required": true, "options": ["Non-concurrence", "Confidentialité", "Pénalités", "Force majeure", "Résiliation", "Propriété intellectuelle", "Limitation de responsabilité", "RGPD", "Médiation/Arbitrage"]}, {"name": "contexte", "type": "textarea", "label": "Contexte du contrat", "required": true, "placeholder": "Contrat de prestation IT entre une ESN et un client grand compte", "maxlength": 400}, {"name": "specificites", "type": "textarea", "label": "Spécificités souhaitées", "required": true, "placeholder": "Non-concurrence limitée à 12 mois et au secteur bancaire", "maxlength": 400}]}'::jsonb,
  'Tu es un juriste expert en rédaction contractuelle. Rédige des clauses contractuelles sur mesure.

Type de clause : {{type_clause}}
Contexte : {{contexte}}
Spécificités : {{specificites}}

Rédige 2-3 variantes de la clause demandée, de la plus protectrice à la plus équilibrée. Pour chaque variante, explique brièvement ses implications juridiques et dans quel contexte l''utiliser.

IMPORTANT : Ces clauses sont des modèles à adapter par un juriste qualifié.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-conclusions',
  'legal-conclusions',
  'Conclusions judiciaires',
  'Structurez et rédigez des conclusions pour le tribunal',
  '🏛️',
  'legal',
  'gold',
  false,
  false,
  4,
  true,
  '{"fields": [{"name": "juridiction", "type": "select", "label": "Juridiction", "required": true, "options": ["Tribunal judiciaire", "Tribunal de commerce", "Conseil de prud''hommes", "Cour d''appel", "Tribunal administratif"]}, {"name": "partie", "type": "radio", "label": "Vous représentez", "required": true, "options": ["Le demandeur", "Le défendeur", "L''intervenant"]}, {"name": "objet_litige", "type": "textarea", "label": "Objet du litige", "required": true, "placeholder": "Résiliation abusive d''un contrat de distribution exclusive", "maxlength": 600}, {"name": "faits", "type": "textarea", "label": "Exposé des faits", "required": true, "placeholder": "Le 15 mars 2024, la société X a notifié la résiliation…", "maxlength": 1000}, {"name": "fondements", "type": "textarea", "label": "Fondements juridiques", "required": true, "placeholder": "Art. 1104 et 1195 du Code civil, jurisprudence Cass. Com. 2022", "maxlength": 600}, {"name": "demandes", "type": "textarea", "label": "Demandes formulées", "required": true, "placeholder": "100 000 € de dommages-intérêts, publication du jugement", "maxlength": 400}]}'::jsonb,
  'Tu es un avocat plaidant expérimenté. Structure et rédige des conclusions judiciaires.

Juridiction : {{juridiction}}
Représentation : {{partie}}
Objet du litige : {{objet_litige}}
Faits : {{faits}}
Fondements juridiques : {{fondements}}
Demandes : {{demandes}}

Rédige des conclusions structurées selon les usages : identification des parties, rappel de la procédure, exposé des faits, discussion juridique (moyens de droit et de fait), et dispositif (PAR CES MOTIFS).

IMPORTANT : Ce document est un modèle qui doit être revu et adapté par l''avocat en charge du dossier.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-analyse-contrat',
  'legal-analyse-contrat',
  'Analyse de contrat',
  'Identifiez les risques et points d''attention dans un contrat',
  '🔎',
  'legal',
  'silver',
  false,
  true,
  5,
  true,
  '{"fields": [{"name": "type_contrat", "type": "text", "label": "Type de contrat", "required": true, "placeholder": "Contrat de licence SaaS"}, {"name": "contenu", "type": "textarea", "label": "Collez le contenu du contrat (ou les clauses clés)", "required": true, "placeholder": "Article 1 - Objet…", "maxlength": 3000}, {"name": "point_vue", "type": "radio", "label": "Votre position", "required": true, "options": ["Je suis le prestataire", "Je suis le client", "Analyse neutre"]}, {"name": "focus", "type": "text", "label": "Points d''attention spécifiques", "required": false, "placeholder": "Clauses de résiliation, responsabilité, propriété IP"}]}'::jsonb,
  'Tu es un juriste d''affaires. Analyse ce contrat et identifie les points d''attention.

Type de contrat : {{type_contrat}}
Votre position : {{point_vue}}
Focus : {{focus}}

Contenu du contrat :
{{contenu}}

Fournis une analyse structurée : points conformes, clauses déséquilibrées, risques identifiés (classés par gravité), clauses manquantes, et recommandations concrètes d''amélioration.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-recherche-jurisprudence',
  'legal-recherche-jurisprudence',
  'Recherche jurisprudence',
  'Trouvez et synthétisez la jurisprudence pertinente',
  '📚',
  'legal',
  'gold',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "domaine", "type": "select", "label": "Domaine", "required": true, "options": ["Droit des contrats", "Droit du travail", "Droit immobilier", "Droit des sociétés", "Droit de la consommation", "Droit du numérique", "Droit pénal des affaires", "Droit de la propriété intellectuelle"]}, {"name": "question", "type": "textarea", "label": "Question juridique", "required": true, "placeholder": "Un employeur peut-il licencier pour des propos tenus sur un réseau social privé ?", "maxlength": 600}, {"name": "periode", "type": "select", "label": "Période", "required": true, "options": ["5 dernières années", "10 dernières années", "Toute la jurisprudence pertinente"]}]}'::jsonb,
  'Tu es un juriste-chercheur spécialisé en droit français. Synthétise la jurisprudence pertinente.

Domaine : {{domaine}}
Question : {{question}}
Période : {{periode}}

Fournis : les décisions clés pertinentes (avec références si connues), les principes dégagés par la jurisprudence, l''évolution de la position des juridictions, et une synthèse de l''état du droit actuel sur cette question.

IMPORTANT : Précise que cette synthèse doit être vérifiée sur des bases juridiques officielles (Légifrance, etc.).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-vulgarisation',
  'legal-vulgarisation',
  'Vulgarisation juridique',
  'Transformez un texte juridique complexe en langage clair',
  '💬',
  'legal',
  'bronze',
  false,
  false,
  7,
  true,
  '{"fields": [{"name": "texte", "type": "textarea", "label": "Texte juridique à vulgariser", "required": true, "placeholder": "Collez ici le texte juridique complexe…", "maxlength": 2000}, {"name": "public_cible", "type": "select", "label": "Public cible", "required": true, "options": ["Client particulier", "Client entreprise (non-juriste)", "Grand public", "Journaliste", "Étudiant"]}, {"name": "format", "type": "select", "label": "Format de sortie", "required": true, "options": ["Texte explicatif", "FAQ", "Points clés", "Infographie textuelle"]}]}'::jsonb,
  'Tu es un juriste pédagogue. Transforme ce texte juridique en langage clair et accessible.

Public cible : {{public_cible}}
Format : {{format}}

Texte à vulgariser :
{{texte}}

Réécris ce texte de manière compréhensible pour le public cible, sans perdre la substance juridique. Explique les termes techniques, donne des exemples concrets, et structure de manière logique.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-email-client',
  'legal-email-client',
  'Email client juridique',
  'Rédigez des emails professionnels à vos clients',
  '📧',
  'legal',
  'bronze',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "destinataire", "type": "text", "label": "Destinataire", "required": true, "placeholder": "M. Dupont, dirigeant de la SAS TechVision"}, {"name": "objet_email", "type": "select", "label": "Type d''email", "required": true, "options": ["Compte-rendu d''avancement", "Demande de pièces", "Stratégie recommandée", "Résultat de procédure", "Honoraires", "Information juridique"]}, {"name": "contenu", "type": "textarea", "label": "Éléments à communiquer", "required": true, "placeholder": "L''audience du 15 mars s''est bien passée, le juge a retenu…", "maxlength": 600}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Formel", "Rassurant", "Direct", "Pédagogue"]}]}'::jsonb,
  'Tu es un avocat professionnel. Rédige un email client clair, professionnel et rassurant.

Destinataire : {{destinataire}}
Type d''email : {{objet_email}}
Contenu : {{contenu}}
Ton : {{ton}}

Rédige un email avec : objet clair, formule d''appel, corps structuré (contexte, information, prochaines étapes), formule de politesse. Reste accessible tout en maintenant la rigueur juridique.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-rgpd-audit',
  'legal-rgpd-audit',
  'Audit RGPD simplifié',
  'Générez une checklist d''audit RGPD pour un site web ou service',
  '🛡️',
  'legal',
  'silver',
  false,
  true,
  9,
  true,
  '{"fields": [{"name": "type_organisation", "type": "select", "label": "Type d''organisation", "required": true, "options": ["Site e-commerce", "Application mobile", "SaaS B2B", "Cabinet / profession libérale", "Association", "Collectivité"]}, {"name": "url", "type": "text", "label": "URL du site (optionnel)", "required": false, "placeholder": "https://www.example.com"}, {"name": "traitements", "type": "textarea", "label": "Principaux traitements de données", "required": true, "placeholder": "Newsletter, création de compte, paiement en ligne, analytics…", "maxlength": 600}, {"name": "niveau", "type": "select", "label": "Niveau de détail souhaité", "required": true, "options": ["Checklist rapide", "Audit intermédiaire", "Audit détaillé avec recommandations"]}]}'::jsonb,
  'Tu es un DPO (Data Protection Officer) expérimenté. Réalise un audit RGPD simplifié.

Type d''organisation : {{type_organisation}}
URL : {{url}}
Traitements : {{traitements}}
Niveau de détail : {{niveau}}

Génère une checklist d''audit couvrant : base légale des traitements, information des personnes, droits des personnes, sécurité des données, sous-traitants, registre des traitements, DPO. Pour chaque point, indique le statut probable et les actions correctives.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'legal-veille-juridique',
  'legal-veille-juridique',
  'Synthèse veille juridique',
  'Résumez les dernières évolutions légales de votre domaine',
  '📡',
  'legal',
  'gold',
  false,
  false,
  10,
  true,
  '{"fields": [{"name": "domaine", "type": "select", "label": "Domaine", "required": true, "options": ["Droit du numérique", "Droit du travail", "Droit immobilier", "Droit fiscal", "Droit de la consommation", "Droit des sociétés", "RGPD / données personnelles"]}, {"name": "periode", "type": "select", "label": "Période", "required": true, "options": ["Dernière semaine", "Dernier mois", "Dernier trimestre"]}, {"name": "focus", "type": "textarea", "label": "Sujets spécifiques", "required": false, "placeholder": "IA Act, télétravail obligatoire, nouvelle directive NIS2", "maxlength": 400}]}'::jsonb,
  'Tu es un veilleur juridique expert. Synthétise les évolutions juridiques récentes.

Domaine : {{domaine}}
Période : {{periode}}
Focus : {{focus}}

Fournis une synthèse structurée : nouveaux textes législatifs/réglementaires, jurisprudence marquante, projets de loi en cours, impacts pratiques pour les professionnels, et actions recommandées.

IMPORTANT : Précise que cette veille doit être complétée par une recherche sur les sources officielles.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-rapport-gestion',
  'finance-rapport-gestion',
  'Rapport de gestion',
  'Générez un rapport de gestion annuel structuré',
  '📊',
  'finance',
  'silver',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "societe", "type": "text", "label": "Nom de la société", "required": true, "placeholder": "SAS TechVision"}, {"name": "exercice", "type": "text", "label": "Exercice concerné", "required": true, "placeholder": "Du 01/01/2025 au 31/12/2025"}, {"name": "ca", "type": "text", "label": "Chiffre d''affaires", "required": true, "placeholder": "1 250 000 €"}, {"name": "resultat", "type": "text", "label": "Résultat net", "required": true, "placeholder": "185 000 €"}, {"name": "faits_marquants", "type": "textarea", "label": "Faits marquants de l''exercice", "required": true, "placeholder": "Lancement nouveau produit, recrutement de 5 personnes, ouverture bureau Lyon…", "maxlength": 600}, {"name": "perspectives", "type": "textarea", "label": "Perspectives", "required": true, "placeholder": "Objectif CA 1.8M€, expansion internationale, levée série A", "maxlength": 400}]}'::jsonb,
  'Tu es un expert-comptable. Rédige un rapport de gestion annuel professionnel et conforme.

Société : {{societe}}
Exercice : {{exercice}}
CA : {{ca}}
Résultat net : {{resultat}}
Faits marquants : {{faits_marquants}}
Perspectives : {{perspectives}}

Rédige un rapport de gestion structuré : situation de la société, activité et résultats, analyse financière, événements significatifs, perspectives, affectation du résultat proposée. Respecte les mentions obligatoires.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-analyse-bilan',
  'finance-analyse-bilan',
  'Analyse de bilan',
  'Obtenez une analyse commentée des principaux ratios financiers',
  '📈',
  'finance',
  'silver',
  false,
  false,
  2,
  true,
  '{"fields": [{"name": "societe", "type": "text", "label": "Société", "required": true, "placeholder": "SARL Boulangerie Martin"}, {"name": "total_actif", "type": "text", "label": "Total actif", "required": true, "placeholder": "450 000 €"}, {"name": "capitaux_propres", "type": "text", "label": "Capitaux propres", "required": true, "placeholder": "180 000 €"}, {"name": "dettes", "type": "text", "label": "Total dettes", "required": true, "placeholder": "270 000 €"}, {"name": "ca", "type": "text", "label": "Chiffre d''affaires", "required": true, "placeholder": "620 000 €"}, {"name": "resultat", "type": "text", "label": "Résultat net", "required": true, "placeholder": "42 000 €"}, {"name": "tresorerie", "type": "text", "label": "Trésorerie", "required": true, "placeholder": "35 000 €"}, {"name": "secteur", "type": "select", "label": "Secteur d''activité", "required": true, "options": ["Commerce", "Industrie", "Services", "Artisanat", "BTP", "Tech / IT", "Restauration", "Santé"]}]}'::jsonb,
  'Tu es un analyste financier. Fournis une analyse commentée du bilan et des ratios.

Société : {{societe}} — Secteur : {{secteur}}
Total actif : {{total_actif}}
Capitaux propres : {{capitaux_propres}}
Dettes : {{dettes}}
CA : {{ca}}
Résultat net : {{resultat}}
Trésorerie : {{tresorerie}}

Calcule et commente les ratios clés : autonomie financière, endettement, rentabilité, liquidité, BFR estimé. Compare aux normes du secteur et formule des recommandations.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-previsionnel',
  'finance-previsionnel',
  'Business plan prévisionnel',
  'Structurez un prévisionnel financier sur 3 ans',
  '🎯',
  'finance',
  'gold',
  true,
  false,
  3,
  true,
  '{"fields": [{"name": "projet", "type": "text", "label": "Nom du projet", "required": true, "placeholder": "Ouverture restaurant bistronomique"}, {"name": "secteur", "type": "select", "label": "Secteur", "required": true, "options": ["Restauration", "Commerce", "Services", "Tech", "Industrie", "BTP", "Santé", "Formation"]}, {"name": "investissement", "type": "text", "label": "Investissement initial", "required": true, "placeholder": "180 000 €"}, {"name": "ca_prevu_an1", "type": "text", "label": "CA prévisionnel Année 1", "required": true, "placeholder": "350 000 €"}, {"name": "charges_fixes", "type": "textarea", "label": "Charges fixes mensuelles estimées", "required": true, "placeholder": "Loyer 3000€, salaires 8000€, assurances 500€…", "maxlength": 600}, {"name": "financement", "type": "textarea", "label": "Sources de financement", "required": true, "placeholder": "Apport personnel 60K€, prêt bancaire 100K€, BPI 20K€", "maxlength": 400}]}'::jsonb,
  'Tu es un expert en business plan. Structure un prévisionnel financier sur 3 ans.

Projet : {{projet}}
Secteur : {{secteur}}
Investissement : {{investissement}}
CA prévisionnel An 1 : {{ca_prevu_an1}}
Charges fixes : {{charges_fixes}}
Financement : {{financement}}

Structure le prévisionnel : hypothèses retenues, compte de résultat prévisionnel (3 ans), plan de financement initial, plan de trésorerie An 1, calcul du point mort, principaux ratios, analyse de sensibilité.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-dashboard-comment',
  'finance-dashboard-comment',
  'Commentaire de dashboard',
  'Rédigez l''analyse narrative de vos KPIs mensuels',
  '💹',
  'finance',
  'bronze',
  false,
  true,
  4,
  true,
  '{"fields": [{"name": "periode", "type": "text", "label": "Période analysée", "required": true, "placeholder": "Mars 2025"}, {"name": "kpis", "type": "textarea", "label": "KPIs du mois (copiez vos chiffres)", "required": true, "placeholder": "CA: 105K€ (+12% vs N-1), Marge brute: 62%, Tréso: 45K€, Effectif: 12", "maxlength": 600}, {"name": "evenements", "type": "textarea", "label": "Événements notables", "required": true, "placeholder": "Perte client X (-8K€/mois), gain appel d''offre Y (+15K€/mois)", "maxlength": 400}, {"name": "format", "type": "select", "label": "Format de commentaire", "required": true, "options": ["Synthèse exécutive (1 page)", "Analyse détaillée", "Bullet points"]}]}'::jsonb,
  'Tu es un contrôleur de gestion. Rédige l''analyse narrative des KPIs mensuels.

Période : {{periode}}
KPIs : {{kpis}}
Événements notables : {{evenements}}
Format : {{format}}

Rédige un commentaire structuré : synthèse de la performance, analyse des écarts vs budget/N-1, explication des variations, alertes et points de vigilance, recommandations d''action.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-lettre-mission',
  'finance-lettre-mission',
  'Lettre de mission',
  'Rédigez une lettre de mission comptable personnalisée',
  '✉️',
  'finance',
  'bronze',
  false,
  false,
  5,
  true,
  '{"fields": [{"name": "cabinet", "type": "text", "label": "Nom du cabinet", "required": true, "placeholder": "Cabinet Expertise Durand & Associés"}, {"name": "client", "type": "text", "label": "Nom du client", "required": true, "placeholder": "SARL Les Jardins de Provence"}, {"name": "missions", "type": "textarea", "label": "Missions confiées", "required": true, "placeholder": "Tenue comptable, établissement des comptes annuels, déclarations fiscales, conseil de gestion", "maxlength": 600}, {"name": "honoraires", "type": "text", "label": "Honoraires proposés", "required": true, "placeholder": "350 € HT / mois"}, {"name": "duree", "type": "select", "label": "Durée", "required": true, "options": ["1 an renouvelable", "3 ans", "Durée indéterminée"]}]}'::jsonb,
  'Tu es un expert-comptable. Rédige une lettre de mission conforme aux normes professionnelles.

Cabinet : {{cabinet}}
Client : {{client}}
Missions : {{missions}}
Honoraires : {{honoraires}}
Durée : {{duree}}

Rédige une lettre de mission structurée : identification des parties, périmètre de la mission, obligations réciproques, conditions financières, durée et résiliation, confidentialité, responsabilité.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-conseil-optimisation',
  'finance-conseil-optimisation',
  'Conseil optimisation fiscale',
  'Proposez des pistes d''optimisation fiscale adaptées',
  '💡',
  'finance',
  'gold',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "type_client", "type": "select", "label": "Type de client", "required": true, "options": ["Entreprise IS", "Entreprise IR", "Profession libérale", "SCI", "Particulier (patrimoine)"]}, {"name": "ca_annuel", "type": "text", "label": "CA annuel ou revenus", "required": true, "placeholder": "450 000 €"}, {"name": "resultat", "type": "text", "label": "Résultat / bénéfice", "required": true, "placeholder": "120 000 €"}, {"name": "situation", "type": "textarea", "label": "Situation particulière", "required": true, "placeholder": "Dirigeant TNS, pas de PER, 2 enfants, véhicule de fonction…", "maxlength": 600}, {"name": "objectif", "type": "select", "label": "Objectif principal", "required": true, "options": ["Réduire l''IS", "Optimiser la rémunération dirigeant", "Préparer la retraite", "Structurer le patrimoine", "Transmettre l''entreprise"]}]}'::jsonb,
  'Tu es un conseiller fiscal expérimenté. Propose des pistes d''optimisation fiscale légales.

Type de client : {{type_client}}
CA / revenus : {{ca_annuel}}
Résultat : {{resultat}}
Situation : {{situation}}
Objectif : {{objectif}}

Propose des pistes d''optimisation : dispositifs applicables, montant d''économie estimé, avantages et inconvénients, mise en œuvre, et alertes sur les risques.

IMPORTANT : Ce sont des pistes de réflexion. Toute mise en œuvre doit être validée par un expert-comptable ou avocat fiscaliste.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-email-relance',
  'finance-email-relance',
  'Email relance paiement',
  'Rédigez des emails de relance graduels et professionnels',
  '🔔',
  'finance',
  'bronze',
  false,
  false,
  7,
  true,
  '{"fields": [{"name": "client", "type": "text", "label": "Client", "required": true, "placeholder": "SAS Digital Solutions"}, {"name": "facture", "type": "text", "label": "Référence facture", "required": true, "placeholder": "FA-2025-0042 du 15/01/2025"}, {"name": "montant", "type": "text", "label": "Montant dû", "required": true, "placeholder": "4 800 € TTC"}, {"name": "retard", "type": "select", "label": "Retard de paiement", "required": true, "options": ["1-15 jours", "15-30 jours", "30-60 jours", "60-90 jours", "+90 jours"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Courtois", "Ferme", "Dernier rappel", "Juridique"]}]}'::jsonb,
  'Tu es un gestionnaire de recouvrement professionnel. Rédige un email de relance adapté au niveau de retard.

Client : {{client}}
Facture : {{facture}}
Montant : {{montant}}
Retard : {{retard}}
Ton : {{ton}}

Rédige un email de relance avec : objet, rappel de la facture, demande de réglement, mention des éventuelles pénalités de retard si applicable, et proposition de solution (échelonnement, etc.).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-note-fiscale',
  'finance-note-fiscale',
  'Note fiscale client',
  'Rédigez une note explicative sur un sujet fiscal',
  '📝',
  'finance',
  'silver',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet fiscal", "required": true, "placeholder": "Régime TVA sur les prestations de services intra-UE"}, {"name": "client", "type": "text", "label": "Client destinataire", "required": true, "placeholder": "M. Martin, gérant de WebAgency SARL"}, {"name": "contexte", "type": "textarea", "label": "Contexte de la question", "required": true, "placeholder": "Le client facture des prestations de développement web à des clients allemands…", "maxlength": 600}, {"name": "niveau_detail", "type": "select", "label": "Niveau de détail", "required": true, "options": ["Synthétique (1 page)", "Détaillé avec références", "Note complète avec exemples"]}]}'::jsonb,
  'Tu es un fiscaliste. Rédige une note fiscale claire et structurée.

Sujet : {{sujet}}
Client : {{client}}
Contexte : {{contexte}}
Niveau de détail : {{niveau_detail}}

Rédige une note structurée : problématique, textes applicables, analyse, conclusion et recommandations pratiques. Adapte le niveau de technicité au client.

IMPORTANT : Cette note doit être validée par un professionnel qualifié.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-declaration-aide',
  'finance-declaration-aide',
  'Aide déclaration',
  'Guidez vos clients sur leur déclaration fiscale',
  '📋',
  'finance',
  'bronze',
  false,
  true,
  9,
  true,
  '{"fields": [{"name": "type_declaration", "type": "select", "label": "Type de déclaration", "required": true, "options": ["IR - Déclaration de revenus", "IS - Liasse fiscale", "TVA - Déclaration CA3", "CFE / CVAE", "Déclaration auto-entrepreneur", "DAS2"]}, {"name": "situation", "type": "textarea", "label": "Situation du client", "required": true, "placeholder": "Auto-entrepreneur en prestations de services, CA 2025: 45 000 €, versement libératoire", "maxlength": 600}, {"name": "questions", "type": "textarea", "label": "Questions spécifiques", "required": false, "placeholder": "Quelles cases remplir ? Quels montants déclarer ? Quels justificatifs ?", "maxlength": 400}]}'::jsonb,
  'Tu es un assistant comptable expert. Fournis un guide pratique pour cette déclaration.

Type de déclaration : {{type_declaration}}
Situation : {{situation}}
Questions : {{questions}}

Fournis un guide étape par étape : documents nécessaires, cases à remplir, montants à déclarer, dates limites, erreurs fréquentes à éviter, et conseils pratiques.

IMPORTANT : Pour toute situation complexe, recommande de consulter un expert-comptable.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'finance-process-interne',
  'finance-process-interne',
  'Procédure interne cabinet',
  'Documentez une procédure ou process de votre cabinet',
  '⚙️',
  'finance',
  'silver',
  false,
  false,
  10,
  true,
  '{"fields": [{"name": "processus", "type": "text", "label": "Nom du processus", "required": true, "placeholder": "Clôture mensuelle des comptes clients"}, {"name": "description", "type": "textarea", "label": "Description du processus", "required": true, "placeholder": "Rapprochement bancaire, lettrage, relances, provisions douteuses…", "maxlength": 600}, {"name": "frequence", "type": "select", "label": "Fréquence", "required": true, "options": ["Quotidien", "Hebdomadaire", "Mensuel", "Trimestriel", "Annuel"]}, {"name": "responsable", "type": "text", "label": "Responsable", "required": true, "placeholder": "Collaborateur comptable senior"}, {"name": "format", "type": "select", "label": "Format souhaité", "required": true, "options": ["Checklist étapes", "Procédure narrative", "Logigramme textuel"]}]}'::jsonb,
  'Tu es un consultant en organisation de cabinet comptable. Documente cette procédure interne.

Processus : {{processus}}
Description : {{description}}
Fréquence : {{frequence}}
Responsable : {{responsable}}
Format : {{format}}

Rédige la procédure au format demandé : objectif, périmètre, prérequis, étapes détaillées (avec timing), contrôles qualité, cas particuliers, et indicateurs de suivi.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-landing-page',
  'marketing-landing-page',
  'Texte landing page',
  'Rédigez un texte de landing page à haute conversion',
  '🖥️',
  'marketing',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "produit_service", "type": "text", "label": "Produit ou service", "required": true, "placeholder": "Formation en ligne \"Maîtrisez le SEO en 30 jours\""}, {"name": "cible", "type": "text", "label": "Cible principale", "required": true, "placeholder": "Entrepreneurs et freelances qui veulent plus de trafic organique"}, {"name": "probleme", "type": "textarea", "label": "Problème résolu", "required": true, "placeholder": "Vous dépensez des milliers en publicité sans résultats durables…", "maxlength": 400}, {"name": "benefices", "type": "textarea", "label": "Bénéfices clés (3-5)", "required": true, "placeholder": "Trafic x3 en 90 jours, méthodologie éprouvée, support illimité…", "maxlength": 400}, {"name": "prix", "type": "text", "label": "Prix / offre", "required": true, "placeholder": "497 € au lieu de 997 € — offre de lancement"}, {"name": "preuve_sociale", "type": "textarea", "label": "Preuves sociales", "required": false, "placeholder": "500+ élèves formés, note 4.8/5, témoignages…", "maxlength": 300}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Persuasif", "Éducatif", "Urgence", "Premium", "Décontracté"]}]}'::jsonb,
  'Tu es un copywriter expert en conversion. Rédige le texte complet d''une landing page à haute conversion.

Produit/Service : {{produit_service}}
Cible : {{cible}}
Problème résolu : {{probleme}}
Bénéfices : {{benefices}}
Prix/Offre : {{prix}}
Preuves sociales : {{preuve_sociale}}
Ton : {{ton}}

Rédige une landing page complète : headline + sous-titre, section problème/agitation, solution, bénéfices (avec sous-titres), preuves sociales, FAQ (3-5 questions), CTA principal et secondaire. Utilise des power words et le framework PAS ou AIDA.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-headline',
  'marketing-headline',
  'Headlines & accroches',
  'Générez 10 accroches percutantes pour votre campagne',
  '🎯',
  'marketing',
  'bronze',
  false,
  false,
  2,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet / produit", "required": true, "placeholder": "Application de méditation pour cadres stressés"}, {"name": "objectif", "type": "select", "label": "Objectif de l''accroche", "required": true, "options": ["Attirer des clics", "Générer des inscriptions", "Vendre", "Créer la curiosité", "Éduquer"]}, {"name": "cible", "type": "text", "label": "Audience cible", "required": true, "placeholder": "Cadres 30-50 ans, urbains, surchargés"}, {"name": "style", "type": "select", "label": "Style", "required": true, "options": ["Question", "Chiffre / statistique", "Promesse de résultat", "Contraste avant/après", "Storytelling"]}]}'::jsonb,
  'Tu es un copywriter expert en accroches. Génère 10 headlines percutantes.

Sujet : {{sujet}}
Objectif : {{objectif}}
Audience : {{cible}}
Style : {{style}}

Génère exactement 10 accroches numérotées, toutes différentes. Pour chaque accroche, indique entre parenthèses le framework utilisé (PAS, AIDA, 4U, question, etc.). Optimise pour le clic et l''engagement.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-script-video',
  'marketing-script-video',
  'Script vidéo marketing',
  'Rédigez un script vidéo engageant de 30s à 3min',
  '🎬',
  'marketing',
  'silver',
  false,
  true,
  3,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de la vidéo", "required": true, "placeholder": "Présentation du nouveau service de livraison express"}, {"name": "duree", "type": "select", "label": "Durée cible", "required": true, "options": ["30 secondes (Reel/Short)", "1 minute", "2 minutes", "3 minutes", "5 minutes"]}, {"name": "plateforme", "type": "select", "label": "Plateforme principale", "required": true, "options": ["YouTube", "Instagram Reels", "TikTok", "LinkedIn", "Site web"]}, {"name": "cible", "type": "text", "label": "Audience", "required": true, "placeholder": "Restaurateurs indépendants en zone urbaine"}, {"name": "cta", "type": "text", "label": "Call-to-action final", "required": true, "placeholder": "Testez gratuitement pendant 14 jours"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Dynamique", "Corporate", "Humoristique", "Inspirant", "Éducatif"]}]}'::jsonb,
  'Tu es un scénariste vidéo marketing. Rédige un script vidéo structuré et engageant.

Sujet : {{sujet}}
Durée : {{duree}}
Plateforme : {{plateforme}}
Audience : {{cible}}
CTA : {{cta}}
Ton : {{ton}}

Rédige un script avec : hook (3 premières secondes), développement, CTA. Indique les timecodes, les indications visuelles [VISUEL:], les transitions, et le texte à l''écran [TEXTE:].',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-ad-copy',
  'marketing-ad-copy',
  'Texte publicitaire',
  'Créez des textes publicitaires pour Google/Meta Ads',
  '📢',
  'marketing',
  'bronze',
  true,
  false,
  4,
  true,
  '{"fields": [{"name": "plateforme", "type": "select", "label": "Plateforme", "required": true, "options": ["Google Ads (Search)", "Google Ads (Display)", "Meta Ads (Facebook/Instagram)", "LinkedIn Ads", "TikTok Ads"]}, {"name": "produit", "type": "text", "label": "Produit / service", "required": true, "placeholder": "Logiciel de comptabilité pour auto-entrepreneurs"}, {"name": "cible", "type": "text", "label": "Audience cible", "required": true, "placeholder": "Auto-entrepreneurs, freelances, micro-entreprises"}, {"name": "budget_indication", "type": "select", "label": "Type de campagne", "required": true, "options": ["Acquisition", "Retargeting", "Notoriété", "Événement"]}, {"name": "usp", "type": "text", "label": "Avantage principal", "required": true, "placeholder": "Gratuit la 1ère année, conforme TVA auto"}, {"name": "nb_variantes", "type": "select", "label": "Nombre de variantes", "required": true, "options": ["3", "5", "10"]}]}'::jsonb,
  'Tu es un expert en publicité digitale. Crée des textes publicitaires optimisés pour la performance.

Plateforme : {{plateforme}}
Produit : {{produit}}
Cible : {{cible}}
Type de campagne : {{budget_indication}}
USP : {{usp}}
Nombre de variantes : {{nb_variantes}}

Génère {{nb_variantes}} variantes publicitaires adaptées au format de la plateforme. Pour chaque variante : headline, description, CTA. Respecte les limites de caractères de la plateforme.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-strategie-contenu',
  'marketing-strategie-contenu',
  'Plan de contenu mensuel',
  'Générez un calendrier éditorial complet sur 30 jours',
  '📅',
  'marketing',
  'silver',
  false,
  false,
  5,
  true,
  '{"fields": [{"name": "entreprise", "type": "text", "label": "Entreprise / marque", "required": true, "placeholder": "Studio Pilates Harmony"}, {"name": "objectif", "type": "select", "label": "Objectif principal", "required": true, "options": ["Acquisition clients", "Notoriété", "Engagement communauté", "Lancement produit", "Recrutement"]}, {"name": "canaux", "type": "text", "label": "Canaux utilisés", "required": true, "placeholder": "Instagram, blog, newsletter, LinkedIn"}, {"name": "cible", "type": "text", "label": "Audience cible", "required": true, "placeholder": "Femmes 25-45 ans, urbaines, intéressées par le bien-être"}, {"name": "themes", "type": "textarea", "label": "Thématiques récurrentes", "required": true, "placeholder": "Exercices, nutrition, témoignages, behind the scenes", "maxlength": 400}]}'::jsonb,
  'Tu es un stratège de contenu. Génère un calendrier éditorial complet sur 30 jours.

Entreprise : {{entreprise}}
Objectif : {{objectif}}
Canaux : {{canaux}}
Cible : {{cible}}
Thématiques : {{themes}}

Crée un calendrier sur 4 semaines avec : date, canal, type de contenu, titre, angle, CTA, hashtags. Alterne les formats (éducatif, inspirant, promotionnel, UGC). Inclus 2-3 marronniers pertinents du mois.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-brief-creatif',
  'marketing-brief-creatif',
  'Brief créatif',
  'Structurez un brief créatif complet pour votre équipe ou agence',
  '🎨',
  'marketing',
  'silver',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "projet", "type": "text", "label": "Nom du projet / campagne", "required": true, "placeholder": "Campagne de rentrée \"Back to Business\""}, {"name": "objectif", "type": "textarea", "label": "Objectif de la campagne", "required": true, "placeholder": "Recruter 500 nouveaux abonnés premium en septembre", "maxlength": 400}, {"name": "cible", "type": "text", "label": "Cible", "required": true, "placeholder": "PME 10-50 salariés, secteur services"}, {"name": "livrables", "type": "textarea", "label": "Livrables attendus", "required": true, "placeholder": "3 visuels social media, 1 vidéo 30s, 1 landing page, 1 email", "maxlength": 400}, {"name": "contraintes", "type": "textarea", "label": "Contraintes / charte", "required": false, "placeholder": "Couleurs bleu/blanc, logo visible, baseline obligatoire", "maxlength": 300}]}'::jsonb,
  'Tu es un directeur de création. Structure un brief créatif complet et actionnable.

Projet : {{projet}}
Objectif : {{objectif}}
Cible : {{cible}}
Livrables : {{livrables}}
Contraintes : {{contraintes}}

Structure le brief : contexte et objectifs, cible (insight consommateur), proposition de valeur, ton et personnalité, livrables et spécifications, planning, KPIs de succès, références/moodboard textuels.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-persona',
  'marketing-persona',
  'Persona marketing',
  'Créez des personas détaillés pour votre stratégie',
  '👤',
  'marketing',
  'bronze',
  false,
  false,
  7,
  true,
  '{"fields": [{"name": "produit", "type": "text", "label": "Produit / service", "required": true, "placeholder": "Application de gestion de projet"}, {"name": "secteur", "type": "text", "label": "Secteur", "required": true, "placeholder": "SaaS B2B"}, {"name": "nb_personas", "type": "select", "label": "Nombre de personas", "required": true, "options": ["1", "2", "3"]}, {"name": "donnees_existantes", "type": "textarea", "label": "Données clients existantes (optionnel)", "required": false, "placeholder": "80% de nos clients sont des PME tech, 60% femmes, utilisent Slack…", "maxlength": 400}]}'::jsonb,
  'Tu es un stratège marketing. Crée des personas marketing détaillés et actionnables.

Produit : {{produit}}
Secteur : {{secteur}}
Nombre de personas : {{nb_personas}}
Données existantes : {{donnees_existantes}}

Pour chaque persona, génère : prénom fictif et photo type, données démographiques, poste et revenus, objectifs et frustrations, parcours d''achat type, canaux préférés, objections à l''achat, messages marketing qui résonnent.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-post-linkedin',
  'marketing-post-linkedin',
  'Post LinkedIn',
  'Rédigez des posts LinkedIn engageants et professionnels',
  '💼',
  'marketing',
  'bronze',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du post", "required": true, "placeholder": "Retour d''expérience sur le passage de freelance à fondateur de startup"}, {"name": "objectif", "type": "select", "label": "Objectif", "required": true, "options": ["Partager une expertise", "Storytelling personnel", "Promouvoir un contenu", "Recruter", "Générer des leads"]}, {"name": "cta", "type": "text", "label": "Call-to-action", "required": true, "placeholder": "Commentez avec votre expérience"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Inspirant", "Expert", "Conversationnel", "Provocateur", "Humble"]}]}'::jsonb,
  'Tu es un expert LinkedIn. Rédige un post LinkedIn optimisé pour l''engagement.

Sujet : {{sujet}}
Objectif : {{objectif}}
CTA : {{cta}}
Ton : {{ton}}

Rédige un post LinkedIn (1200-1500 caractères max) avec : accroche forte (2 premières lignes visibles avant le "voir plus"), développement structuré avec sauts de ligne, storytelling si pertinent, CTA en fin de post. Pas de hashtags dans le corps, ajoute-les en commentaire.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-thread-twitter',
  'marketing-thread-twitter',
  'Thread X (Twitter)',
  'Créez un thread viral et structuré pour X',
  '🐦',
  'marketing',
  'bronze',
  false,
  true,
  9,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du thread", "required": true, "placeholder": "10 erreurs SEO qui vous coûtent des milliers d''euros"}, {"name": "nb_tweets", "type": "select", "label": "Nombre de tweets", "required": true, "options": ["5", "7", "10", "15"]}, {"name": "cible", "type": "text", "label": "Audience", "required": true, "placeholder": "Entrepreneurs et marketeurs digitaux"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Éducatif", "Provocateur", "Storytelling", "Data-driven"]}]}'::jsonb,
  'Tu es un expert en threads X (Twitter). Crée un thread viral et structuré.

Sujet : {{sujet}}
Nombre de tweets : {{nb_tweets}}
Audience : {{cible}}
Ton : {{ton}}

Rédige un thread de {{nb_tweets}} tweets. Tweet 1 = accroche irrésistible avec "🧵". Chaque tweet fait max 280 caractères. Inclus des emojis pertinents. Dernier tweet = récapitulatif + CTA + "Si ce thread vous a aidé, RT le premier tweet.".',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'marketing-email-sequence',
  'marketing-email-sequence',
  'Séquence email nurturing',
  'Créez une séquence de 5 emails pour convertir vos prospects',
  '💌',
  'marketing',
  'silver',
  false,
  false,
  10,
  true,
  '{"fields": [{"name": "objectif", "type": "select", "label": "Objectif de la séquence", "required": true, "options": ["Convertir un prospect en client", "Onboarding nouveau client", "Réactiver un client dormant", "Lancer un produit", "Éduquer / nurturing"]}, {"name": "produit", "type": "text", "label": "Produit / service", "required": true, "placeholder": "Formation \"SEO Mastery\" à 497€"}, {"name": "cible", "type": "text", "label": "Profil du destinataire", "required": true, "placeholder": "A téléchargé l''ebook gratuit sur le SEO, n''a pas encore acheté"}, {"name": "nb_emails", "type": "select", "label": "Nombre d''emails", "required": true, "options": ["3", "5", "7"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Éducatif", "Persuasif", "Amical", "Urgent"]}]}'::jsonb,
  'Tu es un expert en email marketing et automation. Crée une séquence email complète.

Objectif : {{objectif}}
Produit : {{produit}}
Profil destinataire : {{cible}}
Nombre d''emails : {{nb_emails}}
Ton : {{ton}}

Pour chaque email : timing d''envoi (J+X), objet (+ variante A/B), preview text, corps (150-200 mots), CTA principal, PS optionnel. La séquence doit créer une progression logique vers la conversion.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-offre-emploi',
  'rh-offre-emploi',
  'Offre d''emploi attractive',
  'Rédigez une offre d''emploi percutante et inclusive',
  '📋',
  'rh',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "poste", "type": "text", "label": "Intitulé du poste", "required": true, "placeholder": "Développeur Full-Stack Senior"}, {"name": "entreprise", "type": "text", "label": "Nom de l''entreprise", "required": true, "placeholder": "TechVision SAS"}, {"name": "type_contrat", "type": "select", "label": "Type de contrat", "required": true, "options": ["CDI", "CDD", "Stage", "Alternance", "Freelance", "Intérim"]}, {"name": "localisation", "type": "text", "label": "Localisation", "required": true, "placeholder": "Lyon + 2j télétravail/semaine"}, {"name": "salaire", "type": "text", "label": "Rémunération", "required": true, "placeholder": "55-65K€ + variable + BSPCE"}, {"name": "missions", "type": "textarea", "label": "Missions principales", "required": true, "placeholder": "Développer de nouvelles features, code review, mentoring juniors…", "maxlength": 600}, {"name": "profil", "type": "textarea", "label": "Profil recherché", "required": true, "placeholder": "5+ ans d''expérience, React/Node, esprit startup, autonome", "maxlength": 400}, {"name": "avantages", "type": "textarea", "label": "Avantages", "required": false, "placeholder": "RTT, mutuelle Alan, tickets resto, budget formation…", "maxlength": 300}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Corporate", "Startup", "Décontracté", "Inspirant"]}]}'::jsonb,
  'Tu es un expert en marque employeur. Rédige une offre d''emploi attractive et inclusive.

Poste : {{poste}}
Entreprise : {{entreprise}}
Contrat : {{type_contrat}}
Localisation : {{localisation}}
Rémunération : {{salaire}}
Missions : {{missions}}
Profil : {{profil}}
Avantages : {{avantages}}
Ton : {{ton}}

Rédige une offre structurée : accroche engageante, présentation de l''entreprise (culture, valeurs), missions détaillées, profil recherché (must-have vs nice-to-have), package et avantages, process de recrutement. Utilise l''écriture inclusive.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-sourcing-message',
  'rh-sourcing-message',
  'Message de sourcing',
  'Créez des messages d''approche candidat personnalisés',
  '🔍',
  'rh',
  'bronze',
  false,
  false,
  2,
  true,
  '{"fields": [{"name": "poste", "type": "text", "label": "Poste", "required": true, "placeholder": "Head of Product"}, {"name": "entreprise", "type": "text", "label": "Entreprise", "required": true, "placeholder": "FinTech en série B, 80 personnes"}, {"name": "profil_candidat", "type": "text", "label": "Profil du candidat", "required": true, "placeholder": "Actuellement Product Director chez un concurrent SaaS"}, {"name": "accroche", "type": "text", "label": "Accroche / raison du contact", "required": true, "placeholder": "Son talk au ProductCon m''a marqué"}, {"name": "canal", "type": "select", "label": "Canal", "required": true, "options": ["LinkedIn InMail", "Email direct", "Message Twitter/X"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Décontracté", "Flatteur", "Direct"]}]}'::jsonb,
  'Tu es un recruteur expert en approche directe. Rédige un message de sourcing personnalisé.

Poste : {{poste}}
Entreprise : {{entreprise}}
Profil du candidat : {{profil_candidat}}
Accroche : {{accroche}}
Canal : {{canal}}
Ton : {{ton}}

Rédige un message court (max 150 mots pour LinkedIn, 200 pour email) qui : capte l''attention, montre que tu as étudié le profil, présente l''opportunité de manière attractive, et propose un échange sans pression.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-grille-entretien',
  'rh-grille-entretien',
  'Grille d''entretien',
  'Générez une grille d''entretien structurée avec critères d''évaluation',
  '📝',
  'rh',
  'silver',
  true,
  false,
  3,
  true,
  '{"fields": [{"name": "poste", "type": "text", "label": "Poste", "required": true, "placeholder": "Chef de projet marketing"}, {"name": "competences_cles", "type": "textarea", "label": "Compétences clés à évaluer", "required": true, "placeholder": "Gestion de projet, créativité, analytics, leadership d''équipe", "maxlength": 400}, {"name": "type_entretien", "type": "select", "label": "Type d''entretien", "required": true, "options": ["Entretien RH (fit culturel)", "Entretien technique", "Entretien manager", "Entretien final (direction)"]}, {"name": "duree", "type": "select", "label": "Durée prévue", "required": true, "options": ["30 minutes", "45 minutes", "1 heure", "1h30"]}]}'::jsonb,
  'Tu es un expert en recrutement. Génère une grille d''entretien structurée et objectivable.

Poste : {{poste}}
Compétences : {{competences_cles}}
Type d''entretien : {{type_entretien}}
Durée : {{duree}}

Crée une grille avec : accueil (5 min), questions par compétence (3-4 questions/compétence, mix comportemental STAR et situationnel), évaluation (grille 1-5 par compétence), questions du candidat, grille de synthèse.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-compte-rendu-entretien',
  'rh-compte-rendu-entretien',
  'Compte-rendu d''entretien',
  'Structurez le compte-rendu d''un entretien de recrutement',
  '📄',
  'rh',
  'bronze',
  false,
  true,
  4,
  true,
  '{"fields": [{"name": "candidat", "type": "text", "label": "Nom du candidat", "required": true, "placeholder": "Marie Dupont"}, {"name": "poste", "type": "text", "label": "Poste visé", "required": true, "placeholder": "Responsable marketing digital"}, {"name": "date_entretien", "type": "text", "label": "Date de l''entretien", "required": true, "placeholder": "15/03/2025"}, {"name": "notes", "type": "textarea", "label": "Notes brutes de l''entretien", "required": true, "placeholder": "Bonne présentation, 7 ans d''expérience, hésitante sur le management…", "maxlength": 800}, {"name": "avis", "type": "select", "label": "Avis global", "required": true, "options": ["Très favorable", "Favorable", "Réservé", "Défavorable"]}]}'::jsonb,
  'Tu es un recruteur professionnel. Structure un compte-rendu d''entretien objectif et exploitable.

Candidat : {{candidat}}
Poste : {{poste}}
Date : {{date_entretien}}
Notes brutes : {{notes}}
Avis global : {{avis}}

Rédige un compte-rendu structuré : informations candidat, synthèse de l''entretien, évaluation par compétence, points forts, axes d''amélioration, avis motivé, recommandation (go/no-go/réserve).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-plan-integration',
  'rh-plan-integration',
  'Plan d''intégration (onboarding)',
  'Créez un programme d''onboarding sur 90 jours',
  '🚀',
  'rh',
  'silver',
  false,
  false,
  5,
  true,
  '{"fields": [{"name": "poste", "type": "text", "label": "Poste du nouvel arrivant", "required": true, "placeholder": "Développeur frontend junior"}, {"name": "equipe", "type": "text", "label": "Équipe d''accueil", "required": true, "placeholder": "Équipe Produit — 8 personnes"}, {"name": "manager", "type": "text", "label": "Manager direct", "required": true, "placeholder": "Sophie Martin, VP Engineering"}, {"name": "outils", "type": "text", "label": "Outils principaux à maîtriser", "required": true, "placeholder": "Jira, GitLab, Figma, Slack"}, {"name": "duree", "type": "select", "label": "Durée du programme", "required": true, "options": ["30 jours", "60 jours", "90 jours"]}]}'::jsonb,
  'Tu es un expert en onboarding. Crée un programme d''intégration structuré.

Poste : {{poste}}
Équipe : {{equipe}}
Manager : {{manager}}
Outils : {{outils}}
Durée : {{duree}}

Crée un plan d''intégration semaine par semaine : objectifs de la semaine, activités (rencontres, formations, missions), livrables attendus, points de contrôle, et critères de validation de la période d''essai.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-entretien-annuel',
  'rh-entretien-annuel',
  'Trame entretien annuel',
  'Générez une trame d''entretien annuel d''évaluation',
  '🎯',
  'rh',
  'silver',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "poste", "type": "text", "label": "Poste du collaborateur", "required": true, "placeholder": "Chargé de communication"}, {"name": "departement", "type": "text", "label": "Département", "required": true, "placeholder": "Marketing & Communication"}, {"name": "objectifs_precedents", "type": "textarea", "label": "Objectifs de l''année écoulée", "required": true, "placeholder": "Refonte site web, +30% followers LinkedIn, 2 événements organisés", "maxlength": 400}, {"name": "competences", "type": "textarea", "label": "Compétences à évaluer", "required": true, "placeholder": "Créativité, respect des délais, travail d''équipe, prise d''initiative", "maxlength": 400}]}'::jsonb,
  'Tu es un expert RH. Génère une trame d''entretien annuel d''évaluation complète.

Poste : {{poste}}
Département : {{departement}}
Objectifs précédents : {{objectifs_precedents}}
Compétences : {{competences}}

Crée une trame structurée : bilan de l''année (objectifs atteints/non atteints), évaluation des compétences, points forts et axes de progrès, souhaits d''évolution du collaborateur, objectifs N+1 (SMART), plan de développement, synthèse.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-feedback-360',
  'rh-feedback-360',
  'Feedback 360° synthèse',
  'Synthétisez les retours d''un feedback 360° en plan d''action',
  '🔄',
  'rh',
  'gold',
  false,
  true,
  7,
  true,
  '{"fields": [{"name": "collaborateur", "type": "text", "label": "Collaborateur évalué", "required": true, "placeholder": "Thomas Leroy, Manager Opérations"}, {"name": "retours", "type": "textarea", "label": "Retours collectés (synthèse brute)", "required": true, "placeholder": "Manager: excellent sur la rigueur, doit déléguer plus. Pairs: très coopératif mais parfois directif. N-1: bon mentor mais réunions trop longues…", "maxlength": 1000}, {"name": "nb_evaluateurs", "type": "text", "label": "Nombre d''évaluateurs", "required": true, "placeholder": "8 (1 N+1, 3 pairs, 4 N-1)"}, {"name": "format", "type": "select", "label": "Format de restitution", "required": true, "options": ["Synthèse + plan d''action", "Rapport détaillé", "Présentation visuelle"]}]}'::jsonb,
  'Tu es un coach professionnel certifié. Synthétise les retours d''un feedback 360° en plan d''action.

Collaborateur : {{collaborateur}}
Évaluateurs : {{nb_evaluateurs}}
Format : {{format}}

Retours bruts :
{{retours}}

Synthétise : thèmes récurrents (forces et axes), matrice forces/faiblesses, plan de développement (3 actions prioritaires avec indicateurs), et guide de restitution au collaborateur.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-communication-interne',
  'rh-communication-interne',
  'Communication interne',
  'Rédigez des messages internes (arrivées, départs, changements)',
  '📣',
  'rh',
  'bronze',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "type_com", "type": "select", "label": "Type de communication", "required": true, "options": ["Arrivée collaborateur", "Départ collaborateur", "Promotion", "Réorganisation", "Nouvelle politique", "Événement interne", "Résultats / succès"]}, {"name": "details", "type": "textarea", "label": "Détails", "required": true, "placeholder": "Marie Dupont rejoint l''équipe Marketing le 1er avril en tant que Directrice Marketing, en remplacement de…", "maxlength": 600}, {"name": "canal", "type": "select", "label": "Canal de diffusion", "required": true, "options": ["Email all-hands", "Slack / Teams", "Intranet", "Affichage"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Enthousiaste", "Formel", "Neutre", "Chaleureux"]}]}'::jsonb,
  'Tu es un responsable communication interne. Rédige un message interne professionnel.

Type : {{type_com}}
Détails : {{details}}
Canal : {{canal}}
Ton : {{ton}}

Rédige le message adapté au canal et au type de communication. Sois clair, positif quand pertinent, et inclus les informations pratiques nécessaires.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-politique-entreprise',
  'rh-politique-entreprise',
  'Politique d''entreprise',
  'Rédigez une politique RH (télétravail, congés, éthique…)',
  '📘',
  'rh',
  'silver',
  false,
  false,
  9,
  true,
  '{"fields": [{"name": "sujet", "type": "select", "label": "Sujet de la politique", "required": true, "options": ["Télétravail / remote", "Congés & absences", "Code de conduite", "Utilisation IT / données", "Frais professionnels", "RSE / diversité", "Harcèlement / discrimination"]}, {"name": "contexte", "type": "textarea", "label": "Contexte de l''entreprise", "required": true, "placeholder": "Start-up de 45 personnes, 3 bureaux (Paris, Lyon, Nantes), politique hybrid actuelle 2j/semaine", "maxlength": 600}, {"name": "specificites", "type": "textarea", "label": "Spécificités souhaitées", "required": false, "placeholder": "Possibilité de full remote pour les devs, max 3 mois/an depuis l''étranger", "maxlength": 400}]}'::jsonb,
  'Tu es un DRH expérimenté. Rédige une politique d''entreprise claire et applicable.

Sujet : {{sujet}}
Contexte : {{contexte}}
Spécificités : {{specificites}}

Rédige une politique structurée : objet et champ d''application, définitions, principes directeurs, règles détaillées, exceptions et dérogations, entrée en vigueur. Le document doit être conforme au droit du travail français.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'rh-reglement-interieur',
  'rh-reglement-interieur',
  'Règlement intérieur',
  'Générez un projet de règlement intérieur conforme',
  '⚖️',
  'rh',
  'gold',
  false,
  false,
  10,
  true,
  '{"fields": [{"name": "entreprise", "type": "text", "label": "Nom de l''entreprise", "required": true, "placeholder": "SAS TechVision"}, {"name": "effectif", "type": "text", "label": "Effectif", "required": true, "placeholder": "85 salariés"}, {"name": "secteur", "type": "select", "label": "Secteur", "required": true, "options": ["Tech / IT", "Commerce", "Industrie", "Services", "BTP", "Santé", "Finance", "Restauration"]}, {"name": "specificites", "type": "textarea", "label": "Spécificités à inclure", "required": false, "placeholder": "Travail en open space, dress code client, accès locaux sécurisés", "maxlength": 400}]}'::jsonb,
  'Tu es un juriste en droit social. Rédige un projet de règlement intérieur conforme au Code du travail.

Entreprise : {{entreprise}}
Effectif : {{effectif}}
Secteur : {{secteur}}
Spécificités : {{specificites}}

Rédige un règlement intérieur conforme (art. L1321-1 et suivants) : hygiène et sécurité, discipline (échelle des sanctions), droit de la défense, harcèlement et discrimination, droit d''expression. Respecte les mentions obligatoires.

IMPORTANT : Ce document doit être soumis au CSE et à l''inspection du travail.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-email-patient',
  'sante-email-patient',
  'Email patient',
  'Rédigez des emails professionnels et empathiques à vos patients',
  '📧',
  'sante',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "praticien", "type": "text", "label": "Votre titre et nom", "required": true, "placeholder": "Dr. Sophie Martin, kinésithérapeute"}, {"name": "patient", "type": "text", "label": "Nom du patient", "required": true, "placeholder": "M. Dupont"}, {"name": "objet", "type": "select", "label": "Objet de l''email", "required": true, "options": ["Suivi post-consultation", "Résultats d''examens", "Renouvellement ordonnance", "Information préventive", "Changement d''horaires", "Absence / remplacement"]}, {"name": "contenu", "type": "textarea", "label": "Éléments à communiquer", "required": true, "placeholder": "Suite à votre consultation, je souhaite vous rappeler les exercices…", "maxlength": 600}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Chaleureux", "Rassurant", "Pédagogue"]}]}'::jsonb,
  'Tu es un professionnel de santé. Rédige un email patient professionnel, empathique et conforme à la déontologie.

Praticien : {{praticien}}
Patient : {{patient}}
Objet : {{objet}}
Contenu : {{contenu}}
Ton : {{ton}}

Rédige un email professionnel avec : objet clair, formule d''appel personnalisée, message principal (clair et rassurant), informations pratiques si nécessaire, formule de conclusion. Respecte le secret médical.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-rappel-rdv',
  'sante-rappel-rdv',
  'SMS/Email rappel RDV',
  'Créez des messages de rappel de rendez-vous personnalisés',
  '🔔',
  'sante',
  'bronze',
  false,
  false,
  2,
  true,
  '{"fields": [{"name": "praticien", "type": "text", "label": "Cabinet / Praticien", "required": true, "placeholder": "Cabinet de kinésithérapie Martin"}, {"name": "type_rdv", "type": "text", "label": "Type de rendez-vous", "required": true, "placeholder": "Séance de rééducation du genou"}, {"name": "canal", "type": "radio", "label": "Canal", "required": true, "options": ["SMS", "Email"]}, {"name": "delai", "type": "select", "label": "Délai avant le RDV", "required": true, "options": ["24h avant", "48h avant", "1 semaine avant"]}, {"name": "infos_pratiques", "type": "textarea", "label": "Informations pratiques", "required": false, "placeholder": "Apporter tenue confortable, ordonnance, carte vitale", "maxlength": 300}]}'::jsonb,
  'Tu es un assistant de cabinet médical. Crée un message de rappel de rendez-vous.

Cabinet : {{praticien}}
Type de RDV : {{type_rdv}}
Canal : {{canal}}
Délai : {{delai}}
Infos pratiques : {{infos_pratiques}}

Rédige un message de rappel {{canal}} : court, clair, avec date/heure du RDV, informations pratiques, et instructions pour annuler/reporter. Max 160 caractères pour SMS, 200 mots pour email.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-consentement',
  'sante-consentement',
  'Formulaire consentement',
  'Générez un formulaire de consentement éclairé adapté',
  '✅',
  'sante',
  'silver',
  false,
  false,
  3,
  true,
  '{"fields": [{"name": "acte", "type": "text", "label": "Acte / traitement", "required": true, "placeholder": "Injection d''acide hyaluronique — sillons nasogéniens"}, {"name": "praticien", "type": "text", "label": "Praticien", "required": true, "placeholder": "Dr. Pierre Leroy, médecin esthétique"}, {"name": "risques", "type": "textarea", "label": "Risques principaux à mentionner", "required": true, "placeholder": "Hématome, gonflement, asymétrie, infection rare, migration produit", "maxlength": 600}, {"name": "alternatives", "type": "textarea", "label": "Alternatives au traitement", "required": false, "placeholder": "Peeling, laser, abstention thérapeutique", "maxlength": 300}]}'::jsonb,
  'Tu es un médecin. Rédige un formulaire de consentement éclairé conforme aux bonnes pratiques.

Acte : {{acte}}
Praticien : {{praticien}}
Risques : {{risques}}
Alternatives : {{alternatives}}

Rédige un formulaire structuré : description de l''acte en langage clair, bénéfices attendus, risques possibles, alternatives, questions fréquentes, déclaration de consentement, espace signature.

IMPORTANT : Ce modèle doit être adapté à votre pratique et validé par votre assurance professionnelle.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-fiche-conseil',
  'sante-fiche-conseil',
  'Fiche conseil patient',
  'Créez des fiches d''information patient claires et illustrées',
  '📋',
  'sante',
  'bronze',
  true,
  false,
  4,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de la fiche", "required": true, "placeholder": "Exercices post-opératoires du genou"}, {"name": "public", "type": "select", "label": "Public", "required": true, "options": ["Patient adulte", "Patient enfant", "Aidant / famille", "Sportif", "Senior"]}, {"name": "contenu_cle", "type": "textarea", "label": "Informations essentielles à transmettre", "required": true, "placeholder": "5 exercices à faire quotidiennement, durée 15min, précautions…", "maxlength": 600}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Fiche A4 imprimable", "Email patient", "Infographie textuelle"]}]}'::jsonb,
  'Tu es un professionnel de santé pédagogue. Crée une fiche conseil patient claire et utile.

Sujet : {{sujet}}
Public : {{public}}
Informations : {{contenu_cle}}
Format : {{format}}

Rédige une fiche conseil structurée : titre clair, introduction (pourquoi c''est important), conseils numérotés (langage simple, phrases courtes), points de vigilance, quand consulter, et coordonnées utiles.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-programme-soin',
  'sante-programme-soin',
  'Programme de soins',
  'Structurez un programme de soins ou d''exercices personnalisé',
  '📊',
  'sante',
  'silver',
  false,
  true,
  5,
  true,
  '{"fields": [{"name": "pathologie", "type": "text", "label": "Pathologie / objectif", "required": true, "placeholder": "Rééducation épaule post-luxation"}, {"name": "patient", "type": "textarea", "label": "Profil patient", "required": true, "placeholder": "Homme 35 ans, sportif amateur, luxation antérieure épaule droite il y a 6 semaines", "maxlength": 400}, {"name": "duree", "type": "select", "label": "Durée du programme", "required": true, "options": ["4 semaines", "8 semaines", "12 semaines", "6 mois"]}, {"name": "frequence", "type": "select", "label": "Fréquence des séances", "required": true, "options": ["2x/semaine", "3x/semaine", "Quotidien"]}]}'::jsonb,
  'Tu es un professionnel de santé spécialisé. Structure un programme de soins personnalisé.

Pathologie/Objectif : {{pathologie}}
Profil patient : {{patient}}
Durée : {{duree}}
Fréquence : {{frequence}}

Structure le programme semaine par semaine : objectifs, exercices/soins détaillés (séries, répétitions, durée), progressions, critères de passage au niveau suivant, signes d''alerte, et exercices d''auto-rééducation à domicile.

IMPORTANT : Ce programme est un modèle à adapter au patient par le praticien.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-article-blog',
  'sante-article-blog',
  'Article santé vulgarisé',
  'Rédigez un article santé accessible et fiable pour votre site',
  '📰',
  'sante',
  'silver',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet", "required": true, "placeholder": "Comment prévenir le mal de dos au bureau"}, {"name": "specialite", "type": "text", "label": "Votre spécialité", "required": true, "placeholder": "Kinésithérapie / ostéopathie"}, {"name": "cible", "type": "select", "label": "Public cible", "required": true, "options": ["Grand public", "Patients", "Professionnels de santé", "Sportifs"]}, {"name": "longueur", "type": "select", "label": "Longueur", "required": true, "options": ["Court (400 mots)", "Moyen (800 mots)", "Long (1200+ mots)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Scientifique", "Accessible", "Rassurant", "Pratique"]}]}'::jsonb,
  'Tu es un professionnel de santé rédacteur. Rédige un article santé accessible, fiable et engageant.

Sujet : {{sujet}}
Spécialité : {{specialite}}
Public : {{cible}}
Longueur : {{longueur}}
Ton : {{ton}}

Rédige un article structuré, basé sur des données médicales fiables, en langage accessible. Inclus : introduction engageante, développement structuré (H2/H3), conseils pratiques, et conclusion avec CTA (prendre RDV, etc.).

IMPORTANT : Ajoute une mention que cet article ne remplace pas une consultation médicale.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-compte-rendu',
  'sante-compte-rendu',
  'Compte-rendu consultation',
  'Structurez un compte-rendu de consultation professionnel',
  '📝',
  'sante',
  'silver',
  false,
  false,
  7,
  true,
  '{"fields": [{"name": "patient", "type": "text", "label": "Patient", "required": true, "placeholder": "M. Martin, 52 ans"}, {"name": "motif", "type": "text", "label": "Motif de consultation", "required": true, "placeholder": "Douleurs lombaires chroniques depuis 3 mois"}, {"name": "examen", "type": "textarea", "label": "Examen clinique", "required": true, "placeholder": "Limitation flexion 60°, contracture para-vertébrale bilatérale, Lasègue négatif…", "maxlength": 600}, {"name": "diagnostic", "type": "text", "label": "Diagnostic / hypothèse", "required": true, "placeholder": "Lombalgie commune sur sédentarité"}, {"name": "traitement", "type": "textarea", "label": "Traitement proposé", "required": true, "placeholder": "10 séances kiné, renforcement core, étirements quotidiens", "maxlength": 400}]}'::jsonb,
  'Tu es un professionnel de santé. Structure un compte-rendu de consultation professionnel.

Patient : {{patient}}
Motif : {{motif}}
Examen clinique : {{examen}}
Diagnostic : {{diagnostic}}
Traitement : {{traitement}}

Rédige un compte-rendu structuré : motif, anamnèse, examen clinique, diagnostic ou hypothèse diagnostique, plan de traitement, et suivi prévu. Utilise la terminologie médicale appropriée.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-bio-praticien',
  'sante-bio-praticien',
  'Bio praticien',
  'Rédigez une bio professionnelle pour votre site ou annuaire',
  '👤',
  'sante',
  'bronze',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "nom", "type": "text", "label": "Nom complet", "required": true, "placeholder": "Dr. Sophie Martin"}, {"name": "specialite", "type": "text", "label": "Spécialité", "required": true, "placeholder": "Kinésithérapeute, spécialisée en rééducation sportive"}, {"name": "parcours", "type": "textarea", "label": "Parcours / formations", "required": true, "placeholder": "IFMK Lyon 2012, DU de thérapie manuelle, certifiée McKenzie…", "maxlength": 400}, {"name": "approche", "type": "textarea", "label": "Votre approche", "required": true, "placeholder": "Prise en charge globale, éducation thérapeutique, retour au sport…", "maxlength": 400}, {"name": "plateforme", "type": "select", "label": "Plateforme", "required": true, "options": ["Site web personnel", "Doctolib", "Annuaire professionnel", "LinkedIn", "Google My Business"]}]}'::jsonb,
  'Tu es un expert en communication santé. Rédige une bio professionnelle engageante.

Praticien : {{nom}}
Spécialité : {{specialite}}
Parcours : {{parcours}}
Approche : {{approche}}
Plateforme : {{plateforme}}

Rédige une bio professionnelle adaptée à la plateforme : présentation chaleureuse, parcours valorisé, approche thérapeutique expliquée en langage patient, et invitation à prendre rendez-vous.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-post-instagram',
  'sante-post-instagram',
  'Post Instagram santé',
  'Créez des posts Instagram éducatifs et engageants',
  '📸',
  'sante',
  'bronze',
  false,
  true,
  9,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du post", "required": true, "placeholder": "3 exercices simples contre le mal de dos"}, {"name": "specialite", "type": "text", "label": "Votre spécialité", "required": true, "placeholder": "Kinésithérapie"}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Carrousel (5-10 slides)", "Post unique avec texte long", "Reel (script)", "Story"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Éducatif", "Fun", "Professionnel", "Motivant"]}]}'::jsonb,
  'Tu es un community manager santé. Crée un post Instagram éducatif et engageant.

Sujet : {{sujet}}
Spécialité : {{specialite}}
Format : {{format}}
Ton : {{ton}}

Génère le contenu adapté au format : texte du post (éducatif, accessible), contenu des slides si carrousel, hashtags santé pertinents (20 max), et CTA. Respecte la déontologie médicale (pas de diagnostic à distance).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'sante-avis-google',
  'sante-avis-google',
  'Réponse avis Google',
  'Rédigez des réponses professionnelles à vos avis Google',
  '⭐',
  'sante',
  'bronze',
  false,
  false,
  10,
  true,
  '{"fields": [{"name": "avis", "type": "textarea", "label": "Contenu de l''avis", "required": true, "placeholder": "Collez ici l''avis Google auquel répondre…", "maxlength": 800}, {"name": "note", "type": "select", "label": "Note de l''avis", "required": true, "options": ["⭐ (1 étoile)", "⭐⭐ (2 étoiles)", "⭐⭐⭐ (3 étoiles)", "⭐⭐⭐⭐ (4 étoiles)", "⭐⭐⭐⭐⭐ (5 étoiles)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton de la réponse", "required": true, "options": ["Professionnel", "Chaleureux", "Empathique", "Factuel"]}]}'::jsonb,
  'Tu es un professionnel de santé. Rédige une réponse professionnelle et empathique à cet avis.

Note : {{note}}
Ton : {{ton}}

Avis :
{{avis}}

Rédige une réponse professionnelle (max 150 mots) : remerciement, réponse personnalisée au contenu, invitation à en discuter en privé si négatif. Respecte le secret médical (ne jamais confirmer qu''une personne est patient).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-plan-cours',
  'edu-plan-cours',
  'Plan de cours',
  'Structurez un plan de cours complet avec objectifs pédagogiques',
  '📚',
  'education',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "matiere", "type": "text", "label": "Matière / sujet", "required": true, "placeholder": "Introduction au Machine Learning"}, {"name": "niveau", "type": "select", "label": "Niveau", "required": true, "options": ["Débutant", "Intermédiaire", "Avancé", "Expert"]}, {"name": "duree", "type": "select", "label": "Durée totale", "required": true, "options": ["2 heures", "Demi-journée (3h30)", "Journée (7h)", "2 jours", "5 jours"]}, {"name": "public", "type": "text", "label": "Public cible", "required": true, "placeholder": "Développeurs web souhaitant se reconvertir en data science"}, {"name": "objectifs", "type": "textarea", "label": "Objectifs pédagogiques", "required": true, "placeholder": "Comprendre les bases du ML, savoir choisir un algorithme, implémenter un modèle simple", "maxlength": 400}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Présentiel", "Distanciel synchrone", "E-learning asynchrone", "Hybride"]}]}'::jsonb,
  'Tu es un ingénieur pédagogique expert. Structure un plan de cours complet.

Matière : {{matiere}}
Niveau : {{niveau}}
Durée : {{duree}}
Public : {{public}}
Objectifs : {{objectifs}}
Format : {{format}}

Crée un plan de cours détaillé : objectifs pédagogiques (taxonomie de Bloom), prérequis, programme séquencé (timing par module), méthodes pédagogiques, supports nécessaires, modalités d''évaluation.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-support-formation',
  'edu-support-formation',
  'Support de formation',
  'Générez un support de formation structuré et engageant',
  '📖',
  'education',
  'silver',
  true,
  false,
  2,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de la formation", "required": true, "placeholder": "Gestion de projet Agile avec Scrum"}, {"name": "duree", "type": "select", "label": "Durée de la formation", "required": true, "options": ["2 heures", "Demi-journée", "Journée", "2 jours", "5 jours"]}, {"name": "public", "type": "text", "label": "Public cible", "required": true, "placeholder": "Chefs de projet en transition vers l''agilité"}, {"name": "plan", "type": "textarea", "label": "Plan / modules (si existant)", "required": false, "placeholder": "Module 1: Manifeste Agile, Module 2: Rôles Scrum…", "maxlength": 600}, {"name": "style", "type": "select", "label": "Style pédagogique", "required": true, "options": ["Magistral illustré", "Participatif / ateliers", "Learning by doing", "Classe inversée"]}]}'::jsonb,
  'Tu es un formateur expert. Génère un support de formation structuré et engageant.

Sujet : {{sujet}}
Durée : {{duree}}
Public : {{public}}
Plan existant : {{plan}}
Style pédagogique : {{style}}

Génère un support de formation complet : objectifs par module, contenu théorique structuré, exercices pratiques, études de cas, quiz intermédiaires, synthèse par module, et évaluation finale.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-exercice-pratique',
  'edu-exercice-pratique',
  'Exercice pratique',
  'Créez des exercices et cas pratiques avec corrigés',
  '✍️',
  'education',
  'bronze',
  false,
  false,
  3,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de l''exercice", "required": true, "placeholder": "Calcul de ROI d''une campagne marketing"}, {"name": "niveau", "type": "select", "label": "Niveau", "required": true, "options": ["Débutant", "Intermédiaire", "Avancé"]}, {"name": "type_exercice", "type": "select", "label": "Type d''exercice", "required": true, "options": ["Cas pratique", "Étude de cas", "Mise en situation", "Exercice d''application", "Jeu de rôle"]}, {"name": "competences", "type": "text", "label": "Compétences évaluées", "required": true, "placeholder": "Analyse de données, calcul financier, prise de décision"}, {"name": "duree", "type": "select", "label": "Durée estimée", "required": true, "options": ["15 minutes", "30 minutes", "1 heure", "2 heures"]}, {"name": "avec_corrige", "type": "toggle", "label": "Inclure un corrigé détaillé", "required": false}]}'::jsonb,
  'Tu es un formateur créatif. Crée un exercice pratique engageant et pédagogique.

Sujet : {{sujet}}
Niveau : {{niveau}}
Type : {{type_exercice}}
Compétences évaluées : {{competences}}
Durée : {{duree}}
Corrigé : {{avec_corrige}}

Crée l''exercice avec : contexte/mise en situation, consignes claires, ressources fournies, critères d''évaluation, et corrigé détaillé si demandé.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-script-elearning',
  'edu-script-elearning',
  'Script e-learning',
  'Rédigez un script de module e-learning engageant',
  '🎬',
  'education',
  'silver',
  false,
  true,
  4,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du module", "required": true, "placeholder": "Les bases de la cybersécurité au quotidien"}, {"name": "duree", "type": "select", "label": "Durée du module", "required": true, "options": ["5 minutes", "10 minutes", "15 minutes", "20 minutes", "30 minutes"]}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Voix off + slides", "Vidéo animée", "Screencast", "Dialogue interactif"]}, {"name": "objectif", "type": "textarea", "label": "Objectif d''apprentissage", "required": true, "placeholder": "L''apprenant saura reconnaître un email de phishing et adopter les bons réflexes", "maxlength": 400}]}'::jsonb,
  'Tu es un concepteur e-learning. Rédige un script de module e-learning engageant.

Sujet : {{sujet}}
Durée : {{duree}}
Format : {{format}}
Objectif : {{objectif}}

Rédige un script structuré avec : écran par écran (numéroté), narration/voix off, texte affiché, interactions (quiz, clic, drag&drop), et évaluation de fin de module. Utilise le storytelling et les micro-apprentissages.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-qcm-generateur',
  'edu-qcm-generateur',
  'Générateur de QCM',
  'Créez des QCM avec réponses, distracteurs et explications',
  '📝',
  'education',
  'bronze',
  false,
  false,
  5,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet", "required": true, "placeholder": "Droit du travail — Le contrat de travail"}, {"name": "nb_questions", "type": "select", "label": "Nombre de questions", "required": true, "options": ["5", "10", "15", "20"]}, {"name": "niveau", "type": "select", "label": "Niveau de difficulté", "required": true, "options": ["Facile", "Moyen", "Difficile", "Mixte"]}, {"name": "contenu_source", "type": "textarea", "label": "Contenu source (optionnel)", "required": false, "placeholder": "Collez ici le texte de cours sur lequel baser les questions…", "maxlength": 2000}, {"name": "avec_explications", "type": "toggle", "label": "Inclure des explications par réponse", "required": false}]}'::jsonb,
  'Tu es un expert en évaluation pédagogique. Crée un QCM professionnel.

Sujet : {{sujet}}
Nombre de questions : {{nb_questions}}
Difficulté : {{niveau}}
Source : {{contenu_source}}
Explications : {{avec_explications}}

Génère {{nb_questions}} questions QCM avec : énoncé clair, 4 choix (1 correcte, 3 distracteurs plausibles), indication de la bonne réponse, et explication si demandé. Varie les types de questions (connaissance, compréhension, application).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-grille-evaluation',
  'edu-grille-evaluation',
  'Grille d''évaluation',
  'Générez une grille d''évaluation par compétences',
  '📊',
  'education',
  'silver',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "intitule", "type": "text", "label": "Intitulé de l''évaluation", "required": true, "placeholder": "Présentation orale du projet de fin d''études"}, {"name": "competences", "type": "textarea", "label": "Compétences à évaluer", "required": true, "placeholder": "Maîtrise technique, qualité de présentation, réponse aux questions, originalité", "maxlength": 400}, {"name": "echelle", "type": "select", "label": "Échelle de notation", "required": true, "options": ["1 à 4", "1 à 5", "1 à 10", "A/B/C/D", "Acquis / En cours / Non acquis"]}, {"name": "ponderation", "type": "toggle", "label": "Ajouter une pondération", "required": false}]}'::jsonb,
  'Tu es un expert en évaluation par compétences. Génère une grille d''évaluation professionnelle.

Évaluation : {{intitule}}
Compétences : {{competences}}
Échelle : {{echelle}}
Pondération : {{ponderation}}

Crée une grille structurée : compétences et critères observables, descripteurs par niveau, pondération si demandée, espace commentaires, et barème de notation global.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-certification-texte',
  'edu-certification-texte',
  'Texte de certification',
  'Rédigez les textes officiels de vos certifications',
  '🏆',
  'education',
  'silver',
  false,
  false,
  7,
  true,
  '{"fields": [{"name": "titre_certification", "type": "text", "label": "Titre de la certification", "required": true, "placeholder": "Certification Scrum Master"}, {"name": "organisme", "type": "text", "label": "Organisme certificateur", "required": true, "placeholder": "Agile Academy France"}, {"name": "competences", "type": "textarea", "label": "Compétences certifiées", "required": true, "placeholder": "Facilitation d''équipe Scrum, gestion de backlog, animation de cérémonies…", "maxlength": 400}, {"name": "prerequis", "type": "textarea", "label": "Prérequis", "required": false, "placeholder": "2 ans d''expérience en gestion de projet, formation préalable recommandée", "maxlength": 300}]}'::jsonb,
  'Tu es un responsable certification. Rédige les textes officiels de certification.

Certification : {{titre_certification}}
Organisme : {{organisme}}
Compétences : {{competences}}
Prérequis : {{prerequis}}

Rédige : référentiel de compétences, modalités d''évaluation, conditions d''obtention, validité et renouvellement, et texte du certificat lui-même.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-programme-catalogue',
  'edu-programme-catalogue',
  'Programme catalogue',
  'Rédigez le descriptif de programme pour votre catalogue',
  '📋',
  'education',
  'bronze',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "titre_formation", "type": "text", "label": "Titre de la formation", "required": true, "placeholder": "Management d''équipe — Niveau 1"}, {"name": "duree", "type": "text", "label": "Durée", "required": true, "placeholder": "2 jours (14 heures)"}, {"name": "public", "type": "text", "label": "Public cible", "required": true, "placeholder": "Managers nouvellement promus"}, {"name": "objectifs", "type": "textarea", "label": "Objectifs", "required": true, "placeholder": "Adapter son style de management, conduire des entretiens, gérer les conflits", "maxlength": 400}, {"name": "certification", "type": "toggle", "label": "Formation certifiante", "required": false}]}'::jsonb,
  'Tu es un responsable pédagogique. Rédige un descriptif de programme pour le catalogue.

Formation : {{titre_formation}}
Durée : {{duree}}
Public : {{public}}
Objectifs : {{objectifs}}
Certifiante : {{certification}}

Rédige un descriptif catalogue conforme : intitulé, durée, objectifs opérationnels, public et prérequis, programme détaillé, méthodes pédagogiques, modalités d''évaluation, et informations pratiques.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-landing-formation',
  'edu-landing-formation',
  'Landing page formation',
  'Créez une page de vente persuasive pour votre formation',
  '🖥️',
  'education',
  'silver',
  false,
  false,
  9,
  true,
  '{"fields": [{"name": "titre", "type": "text", "label": "Titre de la formation", "required": true, "placeholder": "Maîtrisez Excel en 5 jours"}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "1 490 € (éligible CPF)"}, {"name": "cible", "type": "text", "label": "Public cible", "required": true, "placeholder": "Professionnels voulant gagner en productivité avec Excel"}, {"name": "benefices", "type": "textarea", "label": "Bénéfices clés", "required": true, "placeholder": "Formules avancées, TCD, macros, dashboards automatisés", "maxlength": 400}, {"name": "preuve", "type": "textarea", "label": "Preuves sociales", "required": false, "placeholder": "4.9/5 sur 200 avis, +3000 stagiaires formés, certification reconnue", "maxlength": 300}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Dynamique", "Rassurant", "Premium"]}]}'::jsonb,
  'Tu es un copywriter spécialisé en formation. Crée une page de vente persuasive.

Formation : {{titre}}
Prix : {{prix}}
Cible : {{cible}}
Bénéfices : {{benefices}}
Preuves : {{preuve}}
Ton : {{ton}}

Rédige une landing page complète : headline + sous-titre, section douleur/problème, solution (la formation), programme détaillé, témoignages, garantie, FAQ, CTA, et urgence/rareté si pertinent.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'edu-email-prospect',
  'edu-email-prospect',
  'Email prospection formation',
  'Rédigez des emails pour promouvoir vos formations',
  '📧',
  'education',
  'bronze',
  false,
  true,
  10,
  true,
  '{"fields": [{"name": "formation", "type": "text", "label": "Formation à promouvoir", "required": true, "placeholder": "Formation Cybersécurité — 3 jours"}, {"name": "cible", "type": "text", "label": "Cible", "required": true, "placeholder": "Responsables IT de PME"}, {"name": "argument_cle", "type": "text", "label": "Argument principal", "required": true, "placeholder": "Conformité NIS2 obligatoire avant octobre 2025"}, {"name": "offre", "type": "text", "label": "Offre spéciale (optionnel)", "required": false, "placeholder": "-20% pour les inscriptions avant le 30 avril"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Expert", "Urgent", "Amical", "Corporate"]}]}'::jsonb,
  'Tu es un commercial en formation professionnelle. Rédige un email de prospection efficace.

Formation : {{formation}}
Cible : {{cible}}
Argument : {{argument_cle}}
Offre : {{offre}}
Ton : {{ton}}

Rédige un email court (150-200 mots max) avec : objet accrocheur, accroche liée à l''actualité/besoin, présentation de la formation (bénéfices, pas features), offre spéciale, et CTA clair.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-menu-description',
  'resto-menu-description',
  'Descriptions de plats',
  'Rédigez des descriptions de plats appétissantes et élégantes',
  '🍽️',
  'restauration',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "plat", "type": "text", "label": "Nom du plat", "required": true, "placeholder": "Filet de bar rôti, émulsion safranée"}, {"name": "ingredients", "type": "textarea", "label": "Ingrédients principaux", "required": true, "placeholder": "Bar de ligne, crème, safran, pommes grenaille, haricots verts, beurre noisette", "maxlength": 400}, {"name": "type_cuisine", "type": "select", "label": "Type de cuisine", "required": true, "options": ["Bistronomique", "Gastronomique", "Brasserie", "Fast-casual", "Végétarien/Vegan", "World food", "Terroir"]}, {"name": "prix", "type": "text", "label": "Prix", "required": false, "placeholder": "28 €"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Poétique", "Factuel", "Gourmand", "Minimaliste", "Luxe"]}]}'::jsonb,
  'Tu es un rédacteur gastronomique. Rédige une description de plat appétissante.

Plat : {{plat}}
Ingrédients : {{ingredients}}
Type de cuisine : {{type_cuisine}}
Prix : {{prix}}
Ton : {{ton}}

Rédige 3 variantes de description (courte 15 mots, moyenne 30 mots, longue 60 mots). Utilise un vocabulaire sensoriel (textures, saveurs, couleurs) adapté au type de cuisine et au ton demandé.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-carte-saison',
  'resto-carte-saison',
  'Carte de saison',
  'Créez une carte saisonnière complète avec suggestions d''accords',
  '🍂',
  'restauration',
  'silver',
  false,
  true,
  2,
  true,
  '{"fields": [{"name": "saison", "type": "select", "label": "Saison", "required": true, "options": ["Printemps", "Été", "Automne", "Hiver"]}, {"name": "type_resto", "type": "select", "label": "Type de restaurant", "required": true, "options": ["Bistronomique", "Gastronomique", "Brasserie", "Italien", "Végétarien", "Fusion"]}, {"name": "nb_plats", "type": "select", "label": "Nombre de plats souhaités", "required": true, "options": ["Entrées (5) + Plats (5) + Desserts (3)", "Menu dégustation (7 plats)", "Carte complète (15+ plats)"]}, {"name": "contraintes", "type": "textarea", "label": "Contraintes / préférences", "required": false, "placeholder": "Produits locaux privilégiés, toujours 1 option végé, budget matière 30%", "maxlength": 400}]}'::jsonb,
  'Tu es un consultant en restauration et chef créatif. Crée une carte de saison complète.

Saison : {{saison}}
Type de restaurant : {{type_resto}}
Nombre de plats : {{nb_plats}}
Contraintes : {{contraintes}}

Crée la carte avec : nom de chaque plat, description courte, produits de saison utilisés, suggestion d''accord vin/boisson, et fourchette de prix suggérée. Assure la cohérence de la carte.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-menu-allergen',
  'resto-menu-allergen',
  'Fiches allergènes',
  'Générez les fiches allergènes réglementaires de vos plats',
  '⚠️',
  'restauration',
  'bronze',
  false,
  false,
  3,
  true,
  '{"fields": [{"name": "plat", "type": "text", "label": "Nom du plat", "required": true, "placeholder": "Risotto aux cèpes et parmesan"}, {"name": "ingredients", "type": "textarea", "label": "Liste complète des ingrédients", "required": true, "placeholder": "Riz arborio, cèpes, oignon, vin blanc, bouillon de volaille, parmesan, beurre, crème…", "maxlength": 600}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Fiche individuelle", "Tableau récapitulatif", "Liste avec pictogrammes"]}]}'::jsonb,
  'Tu es un expert en sécurité alimentaire. Génère les fiches allergènes réglementaires.

Plat : {{plat}}
Ingrédients : {{ingredients}}
Format : {{format}}

Analyse les ingrédients et identifie les 14 allergènes réglementaires (gluten, crustacés, œufs, poissons, arachides, soja, lait, fruits à coque, céleri, moutarde, sésame, sulfites, lupin, mollusques). Génère la fiche au format demandé.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-cocktail-carte',
  'resto-cocktail-carte',
  'Carte cocktails',
  'Rédigez des descriptions de cocktails créatives et évocatrices',
  '🍸',
  'restauration',
  'bronze',
  false,
  false,
  4,
  true,
  '{"fields": [{"name": "cocktail", "type": "text", "label": "Nom du cocktail", "required": true, "placeholder": "Le Jardin Méditerranéen"}, {"name": "ingredients", "type": "textarea", "label": "Ingrédients et proportions", "required": true, "placeholder": "4cl gin, 2cl Chartreuse verte, 3cl citron vert, basilic frais, sirop de miel", "maxlength": 400}, {"name": "style", "type": "select", "label": "Style de la carte", "required": true, "options": ["Classique élégant", "Fun & décalé", "Tiki", "Speakeasy", "Naturel / bio"]}, {"name": "prix", "type": "text", "label": "Prix", "required": false, "placeholder": "14 €"}]}'::jsonb,
  'Tu es un expert en mixologie et rédacteur de cartes de bar. Rédige une description de cocktail évocatrice.

Cocktail : {{cocktail}}
Ingrédients : {{ingredients}}
Style de carte : {{style}}
Prix : {{prix}}

Rédige 2 variantes de description : une courte (15-20 mots) et une storytelling (40-50 mots). Suggère aussi un accord mets si pertinent.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-reponse-avis',
  'resto-reponse-avis',
  'Réponse aux avis',
  'Rédigez des réponses professionnelles aux avis en ligne',
  '⭐',
  'restauration',
  'bronze',
  true,
  false,
  5,
  true,
  '{"fields": [{"name": "plateforme", "type": "select", "label": "Plateforme", "required": true, "options": ["Google", "TripAdvisor", "TheFork", "Yelp", "Instagram"]}, {"name": "avis", "type": "textarea", "label": "Contenu de l''avis", "required": true, "placeholder": "Collez ici l''avis du client…", "maxlength": 800}, {"name": "note", "type": "select", "label": "Note", "required": true, "options": ["⭐ (1)", "⭐⭐ (2)", "⭐⭐⭐ (3)", "⭐⭐⭐⭐ (4)", "⭐⭐⭐⭐⭐ (5)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Chaleureux", "Professionnel", "Humble", "Factuel"]}]}'::jsonb,
  'Tu es un restaurateur professionnel. Rédige une réponse d''avis appropriée et stratégique.

Plateforme : {{plateforme}}
Note : {{note}}
Ton : {{ton}}

Avis :
{{avis}}

Rédige une réponse (max 150 mots) : remerciement sincère, réponse personnalisée au contenu spécifique, reconnaissance si critique justifiée, invitation à revenir. Ne sois jamais défensif ni agressif.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-email-evenement',
  'resto-email-evenement',
  'Email événement',
  'Créez des emails pour promouvoir vos événements et soirées',
  '🎉',
  'restauration',
  'bronze',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "restaurant", "type": "text", "label": "Nom du restaurant", "required": true, "placeholder": "Le Bistrot des Halles"}, {"name": "evenement", "type": "text", "label": "Événement", "required": true, "placeholder": "Soirée dégustation vins naturels avec le vigneron"}, {"name": "date", "type": "text", "label": "Date et horaire", "required": true, "placeholder": "Jeudi 20 mars 2025, 19h30"}, {"name": "prix", "type": "text", "label": "Prix / formule", "required": true, "placeholder": "55 € par personne (5 vins + menu accord)"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Gourmand", "Exclusif", "Décontracté", "Festif"]}]}'::jsonb,
  'Tu es un responsable marketing restaurant. Crée un email promotionnel pour un événement.

Restaurant : {{restaurant}}
Événement : {{evenement}}
Date : {{date}}
Prix : {{prix}}
Ton : {{ton}}

Rédige un email avec : objet accrocheur, visuel textuel (mise en page), description de l''événement, menu/programme, conditions de réservation, CTA, et PS.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-post-instagram',
  'resto-post-instagram',
  'Post Instagram restaurant',
  'Créez des posts Instagram gourmands avec hashtags optimisés',
  '📸',
  'restauration',
  'bronze',
  false,
  false,
  7,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du post", "required": true, "placeholder": "Nouveau plat du jour : risotto aux truffes noires"}, {"name": "occasion", "type": "select", "label": "Occasion", "required": true, "options": ["Plat du jour", "Nouveau menu", "Événement", "Behind the scenes", "Équipe", "Produit / fournisseur"]}, {"name": "restaurant", "type": "text", "label": "Nom du restaurant", "required": true, "placeholder": "Le Bistrot des Halles"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Gourmand", "Authentique", "Fun", "Premium"]}]}'::jsonb,
  'Tu es un community manager Food & Beverage. Crée un post Instagram gourmand.

Sujet : {{sujet}}
Occasion : {{occasion}}
Restaurant : {{restaurant}}
Ton : {{ton}}

Génère : texte du post (max 2200 car., emojis food dosés), 20 hashtags (mix food, localité, tendance), et suggestion de contenu visuel.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-fiche-recette',
  'resto-fiche-recette',
  'Fiche recette standardisée',
  'Documentez vos recettes avec grammages et process de production',
  '📋',
  'restauration',
  'silver',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "plat", "type": "text", "label": "Nom du plat", "required": true, "placeholder": "Tarte Tatin traditionnelle"}, {"name": "nb_portions", "type": "number", "label": "Nombre de portions", "required": true, "placeholder": "8"}, {"name": "ingredients", "type": "textarea", "label": "Ingrédients avec grammages", "required": true, "placeholder": "250g pâte feuilletée, 8 pommes Golden, 150g sucre, 80g beurre…", "maxlength": 600}, {"name": "process", "type": "textarea", "label": "Étapes de production", "required": true, "placeholder": "1. Éplucher et couper les pommes en quartiers. 2. Caraméliser sucre et beurre…", "maxlength": 1000}, {"name": "allergenes", "type": "text", "label": "Allergènes", "required": true, "placeholder": "Gluten, lait, œufs"}]}'::jsonb,
  'Tu es un chef de cuisine. Documente cette recette de manière standardisée pour la production.

Plat : {{plat}}
Portions : {{nb_portions}}
Ingrédients : {{ingredients}}
Process : {{process}}
Allergènes : {{allergenes}}

Rédige une fiche recette standardisée : nom, nombre de portions, coût matière estimé, liste des ingrédients (grammages pour {{nb_portions}} portions), process de production étape par étape, points de contrôle (température, textures), dressage, et allergènes.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-formation-equipe',
  'resto-formation-equipe',
  'Fiche formation équipe',
  'Créez des fiches de formation pour vos nouveaux employés',
  '👥',
  'restauration',
  'silver',
  false,
  true,
  9,
  true,
  '{"fields": [{"name": "poste", "type": "select", "label": "Poste concerné", "required": true, "options": ["Serveur", "Barman", "Commis de cuisine", "Chef de rang", "Réceptionniste", "Plongeur"]}, {"name": "sujet", "type": "text", "label": "Sujet de la formation", "required": true, "placeholder": "Accueil client et prise de commande"}, {"name": "niveau", "type": "select", "label": "Niveau", "required": true, "options": ["Nouvel arrivant", "Rappel / perfectionnement", "Promotion au poste"]}, {"name": "points_cles", "type": "textarea", "label": "Points clés à couvrir", "required": true, "placeholder": "Saluer le client, présenter la carte, gérer les allergies, upselling boissons…", "maxlength": 600}]}'::jsonb,
  'Tu es un formateur en restauration. Crée une fiche de formation pratique.

Poste : {{poste}}
Sujet : {{sujet}}
Niveau : {{niveau}}
Points clés : {{points_cles}}

Rédige une fiche de formation structurée : objectif, durée estimée, contenu point par point, mises en situation pratiques, erreurs fréquentes à éviter, et checklist de validation des acquis.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'resto-communique-presse',
  'resto-communique-presse',
  'Communiqué de presse',
  'Rédigez un communiqué de presse pour une ouverture ou événement',
  '📰',
  'restauration',
  'silver',
  false,
  false,
  10,
  true,
  '{"fields": [{"name": "restaurant", "type": "text", "label": "Nom du restaurant", "required": true, "placeholder": "Le Comptoir du Marché"}, {"name": "evenement", "type": "select", "label": "Type d''événement", "required": true, "options": ["Ouverture", "Nouveau chef", "Étoile / distinction", "Nouveau concept", "Anniversaire", "Événement spécial"]}, {"name": "details", "type": "textarea", "label": "Détails de l''événement", "required": true, "placeholder": "Ouverture le 15 avril, cuisine bistronomique, produits 100% locaux, chef ex-Bocuse…", "maxlength": 600}, {"name": "contact_presse", "type": "text", "label": "Contact presse", "required": true, "placeholder": "Marie Dupont — presse@lecomptoir.fr — 06 12 34 56 78"}]}'::jsonb,
  'Tu es un attaché de presse F&B. Rédige un communiqué de presse professionnel.

Restaurant : {{restaurant}}
Type : {{evenement}}
Détails : {{details}}
Contact : {{contact_presse}}

Rédige un communiqué structuré : titre accrocheur, sous-titre, corps (qui/quoi/où/quand/pourquoi), citation du chef ou propriétaire, informations pratiques, et contact presse.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-proposition',
  'freelance-proposition',
  'Proposition commerciale',
  'Générez une proposition commerciale professionnelle et persuasive',
  '📄',
  'freelance',
  'bronze',
  true,
  false,
  1,
  true,
  '{"fields": [{"name": "client", "type": "text", "label": "Nom du client", "required": true, "placeholder": "SAS TechVision"}, {"name": "projet", "type": "text", "label": "Projet", "required": true, "placeholder": "Refonte du site web corporate + SEO"}, {"name": "contexte", "type": "textarea", "label": "Contexte et besoin", "required": true, "placeholder": "Site actuel vieillissant, pas responsive, SEO en chute. Objectif: +50% trafic en 6 mois", "maxlength": 600}, {"name": "prestations", "type": "textarea", "label": "Prestations proposées", "required": true, "placeholder": "Audit UX, design 5 pages, intégration WordPress, optimisation SEO, formation", "maxlength": 600}, {"name": "tarif", "type": "text", "label": "Budget / tarif", "required": true, "placeholder": "8 500 € HT, payable en 3 échéances"}, {"name": "delai", "type": "text", "label": "Délai de réalisation", "required": true, "placeholder": "6 semaines après validation du devis"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Dynamique", "Premium", "Décontracté"]}]}'::jsonb,
  'Tu es un consultant senior. Rédige une proposition commerciale professionnelle et persuasive.

Client : {{client}}
Projet : {{projet}}
Contexte : {{contexte}}
Prestations : {{prestations}}
Tarif : {{tarif}}
Délai : {{delai}}
Ton : {{ton}}

Structure la proposition : page de garde, contexte et compréhension du besoin, méthodologie et approche, livrables détaillés, planning, investissement (tarif), conditions, à propos (votre expertise).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-email-prospection',
  'freelance-email-prospection',
  'Email de prospection',
  'Rédigez des emails de prospection personnalisés et percutants',
  '📧',
  'freelance',
  'bronze',
  true,
  false,
  2,
  true,
  '{"fields": [{"name": "cible", "type": "text", "label": "Cible (fonction + entreprise)", "required": true, "placeholder": "Responsable marketing chez une PME e-commerce"}, {"name": "service", "type": "text", "label": "Votre service principal", "required": true, "placeholder": "Création de contenus SEO + stratégie éditoriale"}, {"name": "accroche", "type": "text", "label": "Accroche / angle d''attaque", "required": true, "placeholder": "J''ai remarqué que votre blog n''a pas été mis à jour depuis 6 mois"}, {"name": "preuve", "type": "text", "label": "Preuve / crédibilité", "required": true, "placeholder": "+200% de trafic organique pour un client similaire en 4 mois"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Direct", "Amical", "Consultative", "Audacieux"]}]}'::jsonb,
  'Tu es un expert en business development freelance. Rédige un email de prospection percutant.

Cible : {{cible}}
Service : {{service}}
Accroche : {{accroche}}
Preuve : {{preuve}}
Ton : {{ton}}

Rédige un email court (max 150 mots) avec : objet irrésistible, accroche personnalisée, proposition de valeur en 2 phrases, preuve sociale, CTA simple (appel de 15 min ?). Pas de pièce jointe, pas de pavé.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-elevator-pitch',
  'freelance-elevator-pitch',
  'Elevator pitch',
  'Créez un pitch percutant de 30 secondes pour vous présenter',
  '🎤',
  'freelance',
  'bronze',
  false,
  false,
  3,
  true,
  '{"fields": [{"name": "metier", "type": "text", "label": "Votre métier", "required": true, "placeholder": "Consultant en transformation digitale"}, {"name": "cible", "type": "text", "label": "Client idéal", "required": true, "placeholder": "PME industrielles en transformation numérique"}, {"name": "probleme", "type": "text", "label": "Problème que vous résolvez", "required": true, "placeholder": "Perte de compétitivité faute de digitalisation des process"}, {"name": "resultat", "type": "text", "label": "Résultat concret", "required": true, "placeholder": "-30% de coûts opérationnels en moyenne"}, {"name": "contexte", "type": "select", "label": "Contexte d''utilisation", "required": true, "options": ["Networking event", "LinkedIn", "Rendez-vous prospect", "Salon professionnel", "Appel téléphonique"]}]}'::jsonb,
  'Tu es un coach en pitch. Crée un elevator pitch mémorable.

Métier : {{metier}}
Client idéal : {{cible}}
Problème résolu : {{probleme}}
Résultat : {{resultat}}
Contexte : {{contexte}}

Génère 3 versions : ultra-courte (15 secondes), standard (30 secondes), développée (60 secondes). Chaque version doit être naturelle à l''oral, mémorable, et adaptée au contexte.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-objection-handler',
  'freelance-objection-handler',
  'Réponses aux objections',
  'Préparez des réponses aux objections courantes de vos prospects',
  '🛡️',
  'freelance',
  'silver',
  false,
  true,
  4,
  true,
  '{"fields": [{"name": "service", "type": "text", "label": "Votre service", "required": true, "placeholder": "Création de sites web"}, {"name": "prix_moyen", "type": "text", "label": "Prix moyen de vos prestations", "required": true, "placeholder": "5 000 — 15 000 €"}, {"name": "objections", "type": "textarea", "label": "Objections fréquentes", "required": true, "placeholder": "C''est trop cher, mon neveu peut le faire, je n''ai pas le temps, on verra plus tard…", "maxlength": 600}, {"name": "ton", "type": "tone_grid", "label": "Ton des réponses", "required": true, "options": ["Empathique", "Factuel", "Challenge", "Storytelling"]}]}'::jsonb,
  'Tu es un expert en négociation commerciale. Prépare des réponses aux objections.

Service : {{service}}
Prix moyen : {{prix_moyen}}
Ton : {{ton}}

Objections :
{{objections}}

Pour chaque objection : reformule-la (montrer l''empathie), propose une réponse structurée (acknowledge, bridge, close), et donne un exemple de phrase à utiliser.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-rapport-mission',
  'freelance-rapport-mission',
  'Rapport de mission',
  'Structurez un rapport de fin de mission professionnel',
  '📊',
  'freelance',
  'silver',
  false,
  false,
  5,
  true,
  '{"fields": [{"name": "client", "type": "text", "label": "Client", "required": true, "placeholder": "SAS GreenTech"}, {"name": "mission", "type": "text", "label": "Intitulé de la mission", "required": true, "placeholder": "Audit UX et refonte de l''application mobile"}, {"name": "periode", "type": "text", "label": "Période", "required": true, "placeholder": "Du 15 janvier au 15 mars 2025"}, {"name": "actions", "type": "textarea", "label": "Actions réalisées", "required": true, "placeholder": "Audit UX (20 interviews), wireframes, prototype Figma, tests utilisateurs, handoff dev", "maxlength": 600}, {"name": "resultats", "type": "textarea", "label": "Résultats obtenus", "required": true, "placeholder": "NPS passé de 32 à 67, temps de conversion -40%, taux de rétention +25%", "maxlength": 400}, {"name": "recommandations", "type": "textarea", "label": "Recommandations", "required": false, "placeholder": "Implémenter un chatbot, revoir le tunnel d''onboarding, A/B tester la homepage", "maxlength": 400}]}'::jsonb,
  'Tu es un consultant professionnel. Rédige un rapport de fin de mission structuré.

Client : {{client}}
Mission : {{mission}}
Période : {{periode}}
Actions : {{actions}}
Résultats : {{resultats}}
Recommandations : {{recommandations}}

Structure le rapport : executive summary, rappel du contexte et objectifs, actions réalisées (détaillées), résultats obtenus (chiffrés si possible), recommandations pour la suite, et annexes éventuelles.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-executive-summary',
  'freelance-executive-summary',
  'Executive summary',
  'Rédigez un résumé exécutif percutant de votre travail',
  '📋',
  'freelance',
  'bronze',
  false,
  false,
  6,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du document", "required": true, "placeholder": "Audit de performance du site e-commerce"}, {"name": "destinataire", "type": "text", "label": "Destinataire", "required": true, "placeholder": "Direction Générale de ModaShop"}, {"name": "contenu", "type": "textarea", "label": "Points clés à synthétiser", "required": true, "placeholder": "Temps de chargement 5.2s (objectif 2s), taux de conversion 1.2% (moyenne secteur 2.8%), 3 quick wins identifiés…", "maxlength": 800}, {"name": "longueur", "type": "select", "label": "Longueur", "required": true, "options": ["1/2 page", "1 page", "2 pages"]}]}'::jsonb,
  'Tu es un consultant senior. Rédige un executive summary percutant.

Sujet : {{sujet}}
Destinataire : {{destinataire}}
Longueur : {{longueur}}

Points clés :
{{contenu}}

Rédige un executive summary à la longueur demandée : contexte en 1-2 phrases, constats majeurs, recommandations prioritaires, et prochaines étapes. Chaque phrase doit apporter de la valeur. Privilégie les chiffres et le concret.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-cgv',
  'freelance-cgv',
  'CGV freelance',
  'Générez des conditions générales de vente adaptées à votre activité',
  '⚖️',
  'freelance',
  'silver',
  false,
  false,
  7,
  true,
  '{"fields": [{"name": "activite", "type": "text", "label": "Votre activité", "required": true, "placeholder": "Développement web et conseil digital"}, {"name": "statut", "type": "select", "label": "Statut juridique", "required": true, "options": ["Auto-entrepreneur", "EURL", "SASU", "SARL", "Profession libérale"]}, {"name": "prestations", "type": "textarea", "label": "Types de prestations", "required": true, "placeholder": "Création de sites web, maintenance, formation, conseil", "maxlength": 400}, {"name": "paiement", "type": "text", "label": "Conditions de paiement", "required": true, "placeholder": "30% à la commande, 70% à la livraison, paiement à 30 jours"}]}'::jsonb,
  'Tu es un juriste spécialisé en droit des affaires. Rédige des CGV adaptées.

Activité : {{activite}}
Statut : {{statut}}
Prestations : {{prestations}}
Conditions de paiement : {{paiement}}

Rédige des CGV complètes : objet, prestations, tarifs et facturation, paiement, délais, obligations des parties, propriété intellectuelle, responsabilité, résiliation, données personnelles, droit applicable.

IMPORTANT : Ces CGV sont un modèle à faire valider par un professionnel du droit.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-relance-facture',
  'freelance-relance-facture',
  'Relance facture impayée',
  'Rédigez des emails de relance graduels pour factures impayées',
  '💰',
  'freelance',
  'bronze',
  false,
  false,
  8,
  true,
  '{"fields": [{"name": "client", "type": "text", "label": "Client", "required": true, "placeholder": "SAS Digital Agency"}, {"name": "facture", "type": "text", "label": "Numéro et date de facture", "required": true, "placeholder": "FA-2025-012 du 15/01/2025"}, {"name": "montant", "type": "text", "label": "Montant TTC", "required": true, "placeholder": "3 600 €"}, {"name": "retard", "type": "select", "label": "Retard", "required": true, "options": ["1ère relance (J+7)", "2ème relance (J+15)", "3ème relance (J+30)", "Dernière relance avant contentieux"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Courtois", "Ferme", "Factuel", "Ultimatum"]}]}'::jsonb,
  'Tu es un freelance professionnel. Rédige un email de relance adapté au niveau de retard.

Client : {{client}}
Facture : {{facture}}
Montant : {{montant}}
Retard : {{retard}}
Ton : {{ton}}

Rédige l''email de relance avec : objet clair, rappel factuel, demande de réglement, mention des pénalités si applicable, et ouverture au dialogue. Adapte la fermeté au niveau de retard.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-bio-linkedin',
  'freelance-bio-linkedin',
  'Bio LinkedIn optimisée',
  'Rédigez une bio LinkedIn percutante qui attire vos clients idéaux',
  '💼',
  'freelance',
  'bronze',
  false,
  false,
  9,
  true,
  '{"fields": [{"name": "nom", "type": "text", "label": "Votre nom", "required": true, "placeholder": "Sophie Martin"}, {"name": "metier", "type": "text", "label": "Votre métier", "required": true, "placeholder": "Consultante en stratégie digitale"}, {"name": "experience", "type": "textarea", "label": "Expériences clés", "required": true, "placeholder": "10 ans en marketing digital, ex-CMO startup, +50 clients accompagnés", "maxlength": 400}, {"name": "cible", "type": "text", "label": "Votre client idéal", "required": true, "placeholder": "PME tech en scale-up"}, {"name": "personnalite", "type": "text", "label": "Ce qui vous différencie", "required": true, "placeholder": "Approche data-driven, formation continue en neuromarketing"}]}'::jsonb,
  'Tu es un expert LinkedIn et personal branding. Rédige une bio LinkedIn optimisée.

Nom : {{nom}}
Métier : {{metier}}
Expériences : {{experience}}
Client idéal : {{cible}}
Différenciateur : {{personnalite}}

Rédige : headline LinkedIn (max 120 car., avec mots-clés), section "À propos" (max 2600 car., structurée avec emojis discrets), et 3 variantes de headline à tester.',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_featured, is_new, sort_order, is_active, input_schema, prompt_template, output_format)
VALUES (
  'freelance-post-expertise',
  'freelance-post-expertise',
  'Post expertise LinkedIn',
  'Créez des posts LinkedIn montrant votre expertise sectorielle',
  '✍️',
  'freelance',
  'bronze',
  false,
  true,
  10,
  true,
  '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet / thématique", "required": true, "placeholder": "Pourquoi 80% des refontes de site échouent"}, {"name": "angle", "type": "select", "label": "Angle", "required": true, "options": ["Retour d''expérience", "Conseil actionnable", "Analyse de tendance", "Erreur à éviter", "Framework / méthode"]}, {"name": "expertise", "type": "text", "label": "Votre domaine d''expertise", "required": true, "placeholder": "UX Design & Conversion"}, {"name": "cta", "type": "text", "label": "Call-to-action", "required": true, "placeholder": "Suivez-moi pour plus de conseils UX"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Expert", "Storytelling", "Provocateur", "Éducatif", "Personnel"]}]}'::jsonb,
  'Tu es un expert en personal branding LinkedIn. Crée un post LinkedIn qui démontre votre expertise.

Sujet : {{sujet}}
Angle : {{angle}}
Expertise : {{expertise}}
CTA : {{cta}}
Ton : {{ton}}

Rédige un post LinkedIn (1200-1500 car.) avec : accroche forte, développement structuré (retour d''expérience, conseil, framework…), conclusion + CTA. Optimise pour l''engagement (commentaires, partages).',
  'text'
)
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical,
  min_tier = EXCLUDED.min_tier,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order,
  input_schema = EXCLUDED.input_schema,
  prompt_template = EXCLUDED.prompt_template,
  output_format = EXCLUDED.output_format;

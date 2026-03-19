-- ============================================================================
-- UPDATE ALL 100 TOOLS: add input_schema to enable dynamic rendering
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ── 1. Ensure all tools exist (UPSERT) ──────────────────────────────────────

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-annonce', 'Générateur d''annonces immobilières', 'Générateur d''annonces immobilières', 'Créez des annonces immobilières percutantes et optimisées SEO', '🏡', 'immo', 'starter', true, true, false, 1, 'Annonces & Descriptions')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-description-luxe', 'Description bien de prestige', 'Description bien de prestige', 'Rédigez des descriptions haut de gamme pour biens d''exception', '🏰', 'immo', 'pro', true, false, false, 2, 'Annonces & Descriptions')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-titre-accrocheur', 'Titres d''annonces accrocheurs', 'Titres d''annonces accrocheurs', 'Générez 10 titres percutants pour vos annonces immobilières', '✏️', 'immo', 'starter', true, false, true, 3, 'Annonces & Descriptions')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-visite-virtuelle', 'Script visite virtuelle', 'Script visite virtuelle', 'Rédigez le script narré pour vos visites virtuelles vidéo', '🎬', 'immo', 'pro', true, false, true, 4, 'Annonces & Descriptions')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rent-estimator', 'Estimation de loyer', 'Estimation de loyer', 'Estimez le loyer optimal selon le marché et les caractéristiques du bien', '💶', 'immo', 'starter', true, true, false, 5, 'Analyse & Estimation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-analyse-marche', 'Analyse de marché local', 'Analyse de marché local', 'Obtenez une analyse détaillée du marché immobilier de votre secteur', '📊', 'immo', 'pro', true, false, false, 6, 'Analyse & Estimation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-comparatif-biens', 'Comparatif de biens', 'Comparatif de biens', 'Générez un tableau comparatif professionnel pour vos clients', '📋', 'immo', 'starter', true, false, false, 7, 'Analyse & Estimation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-email-prospect', 'Email de prospection vendeur', 'Email de prospection vendeur', 'Rédigez des emails de prospection pour décrocher des mandats', '📧', 'immo', 'starter', true, false, false, 8, 'Communication Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-compte-rendu-visite', 'Compte-rendu de visite', 'Compte-rendu de visite', 'Générez un compte-rendu de visite professionnel pour vos acquéreurs', '📝', 'immo', 'starter', true, false, true, 9, 'Communication Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('immo-relance-mandat', 'Relance propriétaire', 'Relance propriétaire', 'Rédigez des messages de relance pour propriétaires hésitants', '🔔', 'immo', 'pro', true, false, false, 10, 'Communication Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-fiche-produit', 'Fiche produit optimisée', 'Fiche produit optimisée', 'Créez des fiches produit persuasives et SEO-friendly', '📦', 'commerce', 'starter', true, true, false, 1, 'Fiches Produit')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-bulk-descriptions', 'Descriptions en lot', 'Descriptions en lot', 'Générez des descriptions pour plusieurs produits à partir d''un CSV', '📑', 'commerce', 'gold', true, false, true, 2, 'Fiches Produit')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-fiche-amazon', 'Fiche produit Amazon', 'Fiche produit Amazon', 'Optimisez vos fiches produit pour le format Amazon/marketplace', '📱', 'commerce', 'pro', true, false, false, 3, 'Fiches Produit')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-upsell-cross', 'Textes upsell & cross-sell', 'Textes upsell & cross-sell', 'Rédigez des textes de recommandation produit convaincants', '🔗', 'commerce', 'pro', true, false, false, 4, 'Fiches Produit')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-meta-seo', 'Méta-descriptions SEO', 'Méta-descriptions SEO', 'Générez titres et méta-descriptions optimisés pour vos pages produit', '🔍', 'commerce', 'starter', true, false, false, 5, 'SEO & Contenu')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-blog-produit', 'Article de blog produit', 'Article de blog produit', 'Rédigez un article de blog optimisé autour d''un produit ou catégorie', '📰', 'commerce', 'pro', true, true, false, 6, 'SEO & Contenu')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-faq-produit', 'FAQ produit', 'FAQ produit', 'Générez une FAQ complète pour votre page produit', '❓', 'commerce', 'starter', true, false, true, 7, 'SEO & Contenu')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-email-panier', 'Email panier abandonné', 'Email panier abandonné', 'Créez des séquences d''email pour récupérer les paniers abandonnés', '🛒', 'commerce', 'pro', true, false, false, 8, 'Emailing & CRM')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-newsletter', 'Newsletter e-commerce', 'Newsletter e-commerce', 'Rédigez une newsletter engageante pour votre base client', '💌', 'commerce', 'starter', true, false, false, 9, 'Emailing & CRM')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('commerce-post-instagram', 'Post Instagram produit', 'Post Instagram produit', 'Créez des posts Instagram captivants avec hashtags optimisés', '📸', 'commerce', 'starter', true, false, false, 10, 'Réseaux Sociaux')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-mise-en-demeure', 'Mise en demeure', 'Mise en demeure', 'Rédigez une lettre de mise en demeure professionnelle', '⚠️', 'legal', 'starter', true, true, false, 1, 'Rédaction Juridique')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-contrat-type', 'Contrat type', 'Contrat type', 'Générez un projet de contrat adapté à votre besoin', '📄', 'legal', 'pro', true, true, false, 2, 'Rédaction Juridique')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-clauses-specifiques', 'Clauses spécifiques', 'Clauses spécifiques', 'Rédigez des clauses contractuelles sur mesure', '🔏', 'legal', 'pro', true, false, false, 3, 'Rédaction Juridique')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-conclusions', 'Conclusions judiciaires', 'Conclusions judiciaires', 'Structurez et rédigez des conclusions pour le tribunal', '🏛️', 'legal', 'gold', true, false, false, 4, 'Rédaction Juridique')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-analyse-contrat', 'Analyse de contrat', 'Analyse de contrat', 'Identifiez les risques et points d''attention dans un contrat', '🔎', 'legal', 'pro', true, false, true, 5, 'Analyse & Recherche')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-recherche-jurisprudence', 'Recherche jurisprudence', 'Recherche jurisprudence', 'Trouvez et synthétisez la jurisprudence pertinente', '📚', 'legal', 'gold', true, false, false, 6, 'Analyse & Recherche')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-vulgarisation', 'Vulgarisation juridique', 'Vulgarisation juridique', 'Transformez un texte juridique complexe en langage clair', '💬', 'legal', 'starter', true, false, false, 7, 'Communication Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-email-client', 'Email client juridique', 'Email client juridique', 'Rédigez des emails professionnels à vos clients', '📧', 'legal', 'starter', true, false, false, 8, 'Communication Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-rgpd-audit', 'Audit RGPD simplifié', 'Audit RGPD simplifié', 'Générez une checklist d''audit RGPD pour un site web ou service', '🛡️', 'legal', 'pro', true, false, true, 9, 'Conformité & Veille')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('legal-veille-juridique', 'Synthèse veille juridique', 'Synthèse veille juridique', 'Résumez les dernières évolutions légales de votre domaine', '📡', 'legal', 'gold', true, false, false, 10, 'Conformité & Veille')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-rapport-gestion', 'Rapport de gestion', 'Rapport de gestion', 'Générez un rapport de gestion annuel structuré', '📊', 'finance', 'pro', true, true, false, 1, 'Rapports & Analyses')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-analyse-bilan', 'Analyse de bilan', 'Analyse de bilan', 'Obtenez une analyse commentée des principaux ratios financiers', '📈', 'finance', 'pro', true, false, false, 2, 'Rapports & Analyses')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-previsionnel', 'Business plan prévisionnel', 'Business plan prévisionnel', 'Structurez un prévisionnel financier sur 3 ans', '🎯', 'finance', 'gold', true, true, false, 3, 'Rapports & Analyses')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-dashboard-comment', 'Commentaire de dashboard', 'Commentaire de dashboard', 'Rédigez l''analyse narrative de vos KPIs mensuels', '💹', 'finance', 'starter', true, false, true, 4, 'Rapports & Analyses')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-lettre-mission', 'Lettre de mission', 'Lettre de mission', 'Rédigez une lettre de mission comptable personnalisée', '✉️', 'finance', 'starter', true, false, false, 5, 'Conseil Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-conseil-optimisation', 'Conseil optimisation fiscale', 'Conseil optimisation fiscale', 'Proposez des pistes d''optimisation fiscale adaptées', '💡', 'finance', 'gold', true, false, false, 6, 'Conseil Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-email-relance', 'Email relance paiement', 'Email relance paiement', 'Rédigez des emails de relance graduels et professionnels', '🔔', 'finance', 'starter', true, false, false, 7, 'Conseil Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-note-fiscale', 'Note fiscale client', 'Note fiscale client', 'Rédigez une note explicative sur un sujet fiscal', '📝', 'finance', 'pro', true, false, false, 8, 'Fiscalité')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-declaration-aide', 'Aide déclaration', 'Aide déclaration', 'Guidez vos clients sur leur déclaration fiscale', '📋', 'finance', 'starter', true, false, true, 9, 'Fiscalité')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('finance-process-interne', 'Procédure interne cabinet', 'Procédure interne cabinet', 'Documentez une procédure ou process de votre cabinet', '⚙️', 'finance', 'pro', true, false, false, 10, 'Gestion Interne')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-landing-page', 'Texte landing page', 'Texte landing page', 'Rédigez un texte de landing page à haute conversion', '🖥️', 'marketing', 'starter', true, true, false, 1, 'Copywriting')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-headline', 'Headlines & accroches', 'Headlines & accroches', 'Générez 10 accroches percutantes pour votre campagne', '🎯', 'marketing', 'starter', true, false, false, 2, 'Copywriting')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-script-video', 'Script vidéo marketing', 'Script vidéo marketing', 'Rédigez un script vidéo engageant de 30s à 3min', '🎬', 'marketing', 'pro', true, false, true, 3, 'Copywriting')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-ad-copy', 'Texte publicitaire', 'Texte publicitaire', 'Créez des textes publicitaires pour Google/Meta Ads', '📢', 'marketing', 'starter', true, true, false, 4, 'Copywriting')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-strategie-contenu', 'Plan de contenu mensuel', 'Plan de contenu mensuel', 'Générez un calendrier éditorial complet sur 30 jours', '📅', 'marketing', 'pro', true, false, false, 5, 'Stratégie & Planning')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-brief-creatif', 'Brief créatif', 'Brief créatif', 'Structurez un brief créatif complet pour votre équipe ou agence', '🎨', 'marketing', 'pro', true, false, false, 6, 'Stratégie & Planning')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-persona', 'Persona marketing', 'Persona marketing', 'Créez des personas détaillés pour votre stratégie', '👤', 'marketing', 'starter', true, false, false, 7, 'Stratégie & Planning')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-post-linkedin', 'Post LinkedIn', 'Post LinkedIn', 'Rédigez des posts LinkedIn engageants et professionnels', '💼', 'marketing', 'starter', true, false, false, 8, 'Réseaux Sociaux')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-thread-twitter', 'Thread X (Twitter)', 'Thread X (Twitter)', 'Créez un thread viral et structuré pour X', '🐦', 'marketing', 'starter', true, false, true, 9, 'Réseaux Sociaux')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('marketing-email-sequence', 'Séquence email nurturing', 'Séquence email nurturing', 'Créez une séquence de 5 emails pour convertir vos prospects', '💌', 'marketing', 'pro', true, false, false, 10, 'Emailing')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-offre-emploi', 'Offre d''emploi attractive', 'Offre d''emploi attractive', 'Rédigez une offre d''emploi percutante et inclusive', '📋', 'rh', 'starter', true, true, false, 1, 'Recrutement')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-sourcing-message', 'Message de sourcing', 'Message de sourcing', 'Créez des messages d''approche candidat personnalisés', '🔍', 'rh', 'starter', true, false, false, 2, 'Recrutement')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-grille-entretien', 'Grille d''entretien', 'Grille d''entretien', 'Générez une grille d''entretien structurée avec critères d''évaluation', '📝', 'rh', 'pro', true, true, false, 3, 'Recrutement')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-compte-rendu-entretien', 'Compte-rendu d''entretien', 'Compte-rendu d''entretien', 'Structurez le compte-rendu d''un entretien de recrutement', '📄', 'rh', 'starter', true, false, true, 4, 'Recrutement')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-plan-integration', 'Plan d''intégration (onboarding)', 'Plan d''intégration (onboarding)', 'Créez un programme d''onboarding sur 90 jours', '🚀', 'rh', 'pro', true, false, false, 5, 'Gestion des Talents')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-entretien-annuel', 'Trame entretien annuel', 'Trame entretien annuel', 'Générez une trame d''entretien annuel d''évaluation', '🎯', 'rh', 'pro', true, false, false, 6, 'Gestion des Talents')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-feedback-360', 'Feedback 360° synthèse', 'Feedback 360° synthèse', 'Synthétisez les retours d''un feedback 360° en plan d''action', '🔄', 'rh', 'gold', true, false, true, 7, 'Gestion des Talents')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-communication-interne', 'Communication interne', 'Communication interne', 'Rédigez des messages internes (arrivées, départs, changements)', '📣', 'rh', 'starter', true, false, false, 8, 'Communication Interne')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-politique-entreprise', 'Politique d''entreprise', 'Politique d''entreprise', 'Rédigez une politique RH (télétravail, congés, éthique…)', '📘', 'rh', 'pro', true, false, false, 9, 'Documents RH')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('rh-reglement-interieur', 'Règlement intérieur', 'Règlement intérieur', 'Générez un projet de règlement intérieur conforme', '⚖️', 'rh', 'gold', true, false, false, 10, 'Documents RH')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-email-patient', 'Email patient', 'Email patient', 'Rédigez des emails professionnels et empathiques à vos patients', '📧', 'sante', 'starter', true, true, false, 1, 'Communication Patient')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-rappel-rdv', 'SMS/Email rappel RDV', 'SMS/Email rappel RDV', 'Créez des messages de rappel de rendez-vous personnalisés', '🔔', 'sante', 'starter', true, false, false, 2, 'Communication Patient')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-consentement', 'Formulaire consentement', 'Formulaire consentement', 'Générez un formulaire de consentement éclairé adapté', '✅', 'sante', 'pro', true, false, false, 3, 'Communication Patient')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-fiche-conseil', 'Fiche conseil patient', 'Fiche conseil patient', 'Créez des fiches d''information patient claires et illustrées', '📋', 'sante', 'starter', true, true, false, 4, 'Contenu Éducatif')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-programme-soin', 'Programme de soins', 'Programme de soins', 'Structurez un programme de soins ou d''exercices personnalisé', '📊', 'sante', 'pro', true, false, true, 5, 'Contenu Éducatif')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-article-blog', 'Article santé vulgarisé', 'Article santé vulgarisé', 'Rédigez un article santé accessible et fiable pour votre site', '📰', 'sante', 'pro', true, false, false, 6, 'Contenu Éducatif')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-compte-rendu', 'Compte-rendu consultation', 'Compte-rendu consultation', 'Structurez un compte-rendu de consultation professionnel', '📝', 'sante', 'pro', true, false, false, 7, 'Gestion Cabinet')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-bio-praticien', 'Bio praticien', 'Bio praticien', 'Rédigez une bio professionnelle pour votre site ou annuaire', '👤', 'sante', 'starter', true, false, false, 8, 'Marketing Santé')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-post-instagram', 'Post Instagram santé', 'Post Instagram santé', 'Créez des posts Instagram éducatifs et engageants', '📸', 'sante', 'starter', true, false, true, 9, 'Marketing Santé')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('sante-avis-google', 'Réponse avis Google', 'Réponse avis Google', 'Rédigez des réponses professionnelles à vos avis Google', '⭐', 'sante', 'starter', true, false, false, 10, 'Marketing Santé')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-plan-cours', 'Plan de cours', 'Plan de cours', 'Structurez un plan de cours complet avec objectifs pédagogiques', '📚', 'education', 'starter', true, true, false, 1, 'Création de Contenu')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-support-formation', 'Support de formation', 'Support de formation', 'Générez un support de formation structuré et engageant', '📖', 'education', 'pro', true, true, false, 2, 'Création de Contenu')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-exercice-pratique', 'Exercice pratique', 'Exercice pratique', 'Créez des exercices et cas pratiques avec corrigés', '✍️', 'education', 'starter', true, false, false, 3, 'Création de Contenu')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-script-elearning', 'Script e-learning', 'Script e-learning', 'Rédigez un script de module e-learning engageant', '🎬', 'education', 'pro', true, false, true, 4, 'Création de Contenu')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-qcm-generateur', 'Générateur de QCM', 'Générateur de QCM', 'Créez des QCM avec réponses, distracteurs et explications', '📝', 'education', 'starter', true, false, false, 5, 'Évaluation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-grille-evaluation', 'Grille d''évaluation', 'Grille d''évaluation', 'Générez une grille d''évaluation par compétences', '📊', 'education', 'pro', true, false, false, 6, 'Évaluation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-certification-texte', 'Texte de certification', 'Texte de certification', 'Rédigez les textes officiels de vos certifications', '🏆', 'education', 'pro', true, false, false, 7, 'Administration')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-programme-catalogue', 'Programme catalogue', 'Programme catalogue', 'Rédigez le descriptif de programme pour votre catalogue', '📋', 'education', 'starter', true, false, false, 8, 'Administration')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-landing-formation', 'Landing page formation', 'Landing page formation', 'Créez une page de vente persuasive pour votre formation', '🖥️', 'education', 'pro', true, false, false, 9, 'Marketing Formation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('edu-email-prospect', 'Email prospection formation', 'Email prospection formation', 'Rédigez des emails pour promouvoir vos formations', '📧', 'education', 'starter', true, false, true, 10, 'Marketing Formation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-menu-description', 'Descriptions de plats', 'Descriptions de plats', 'Rédigez des descriptions de plats appétissantes et élégantes', '🍽️', 'restauration', 'starter', true, true, false, 1, 'Menu & Carte')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-carte-saison', 'Carte de saison', 'Carte de saison', 'Créez une carte saisonnière complète avec suggestions d''accords', '🍂', 'restauration', 'pro', true, false, true, 2, 'Menu & Carte')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-menu-allergen', 'Fiches allergènes', 'Fiches allergènes', 'Générez les fiches allergènes réglementaires de vos plats', '⚠️', 'restauration', 'starter', true, false, false, 3, 'Menu & Carte')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-cocktail-carte', 'Carte cocktails', 'Carte cocktails', 'Rédigez des descriptions de cocktails créatives et évocatrices', '🍸', 'restauration', 'starter', true, false, false, 4, 'Menu & Carte')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-reponse-avis', 'Réponse aux avis', 'Réponse aux avis', 'Rédigez des réponses professionnelles aux avis en ligne', '⭐', 'restauration', 'starter', true, true, false, 5, 'Communication Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-email-evenement', 'Email événement', 'Email événement', 'Créez des emails pour promouvoir vos événements et soirées', '🎉', 'restauration', 'starter', true, false, false, 6, 'Communication Client')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-post-instagram', 'Post Instagram restaurant', 'Post Instagram restaurant', 'Créez des posts Instagram gourmands avec hashtags optimisés', '📸', 'restauration', 'starter', true, false, false, 7, 'Marketing Local')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-fiche-recette', 'Fiche recette standardisée', 'Fiche recette standardisée', 'Documentez vos recettes avec grammages et process de production', '📋', 'restauration', 'pro', true, false, false, 8, 'Gestion & Opérations')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-formation-equipe', 'Fiche formation équipe', 'Fiche formation équipe', 'Créez des fiches de formation pour vos nouveaux employés', '👥', 'restauration', 'pro', true, false, true, 9, 'Gestion & Opérations')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('resto-communique-presse', 'Communiqué de presse', 'Communiqué de presse', 'Rédigez un communiqué de presse pour une ouverture ou événement', '📰', 'restauration', 'pro', true, false, false, 10, 'Marketing Local')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-proposition', 'Proposition commerciale', 'Proposition commerciale', 'Générez une proposition commerciale professionnelle et persuasive', '📄', 'freelance', 'starter', true, true, false, 1, 'Prospection & Vente')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-email-prospection', 'Email de prospection', 'Email de prospection', 'Rédigez des emails de prospection personnalisés et percutants', '📧', 'freelance', 'starter', true, true, false, 2, 'Prospection & Vente')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-elevator-pitch', 'Elevator pitch', 'Elevator pitch', 'Créez un pitch percutant de 30 secondes pour vous présenter', '🎤', 'freelance', 'starter', true, false, false, 3, 'Prospection & Vente')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-objection-handler', 'Réponses aux objections', 'Réponses aux objections', 'Préparez des réponses aux objections courantes de vos prospects', '🛡️', 'freelance', 'pro', true, false, true, 4, 'Prospection & Vente')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-rapport-mission', 'Rapport de mission', 'Rapport de mission', 'Structurez un rapport de fin de mission professionnel', '📊', 'freelance', 'pro', true, false, false, 5, 'Livrables & Rapports')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-executive-summary', 'Executive summary', 'Executive summary', 'Rédigez un résumé exécutif percutant de votre travail', '📋', 'freelance', 'starter', true, false, false, 6, 'Livrables & Rapports')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-cgv', 'CGV freelance', 'CGV freelance', 'Générez des conditions générales de vente adaptées à votre activité', '⚖️', 'freelance', 'pro', true, false, false, 7, 'Admin & Facturation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-relance-facture', 'Relance facture impayée', 'Relance facture impayée', 'Rédigez des emails de relance graduels pour factures impayées', '💰', 'freelance', 'starter', true, false, false, 8, 'Admin & Facturation')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-bio-linkedin', 'Bio LinkedIn optimisée', 'Bio LinkedIn optimisée', 'Rédigez une bio LinkedIn percutante qui attire vos clients idéaux', '💼', 'freelance', 'starter', true, false, false, 9, 'Personal Branding')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;

INSERT INTO tools (slug, name, label, description, icon, vertical, min_tier, is_active, is_featured, is_new, sort_order, category)
VALUES ('freelance-post-expertise', 'Post expertise LinkedIn', 'Post expertise LinkedIn', 'Créez des posts LinkedIn montrant votre expertise sectorielle', '✍️', 'freelance', 'starter', true, false, true, 10, 'Personal Branding')
ON CONFLICT (slug) DO UPDATE SET
  label = EXCLUDED.label, description = EXCLUDED.description, icon = EXCLUDED.icon,
  vertical = EXCLUDED.vertical, min_tier = EXCLUDED.min_tier, is_active = true,
  is_featured = EXCLUDED.is_featured, is_new = EXCLUDED.is_new,
  sort_order = EXCLUDED.sort_order, category = EXCLUDED.category;


-- ── 2. Update input_schema for all tools ────────────────────────────────────

UPDATE tools SET input_schema = '{"fields": [{"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "options": ["Appartement", "Maison", "Studio", "Loft", "Villa", "Terrain", "Local commercial", "Parking"]}, {"name": "operation", "type": "radio", "label": "Type d''opération", "required": true, "options": ["Vente", "Location", "Location saisonnière"]}, {"name": "surface", "type": "number", "label": "Surface (m²)", "required": true, "placeholder": "85"}, {"name": "pieces", "type": "number", "label": "Nombre de pièces", "required": true, "placeholder": "3"}, {"name": "ville", "type": "text", "label": "Ville / Quartier", "required": true, "placeholder": "Lyon 6ème"}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "350 000 €"}, {"name": "atouts", "type": "textarea", "label": "Points forts du bien", "required": true, "placeholder": "Balcon sud, parquet massif, cave, gardien…", "maxlength": 500}, {"name": "dpe", "type": "select", "label": "DPE", "required": false, "options": ["A", "B", "C", "D", "E", "F", "G", "Non renseigné"]}, {"name": "ton", "type": "tone_grid", "label": "Ton de l''annonce", "required": true, "options": ["Professionnel", "Chaleureux", "Luxe", "Dynamique", "Sobre"]}]}'::jsonb WHERE slug = 'immo-annonce';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "options": ["Villa", "Penthouse", "Hôtel particulier", "Château", "Mas provençal", "Chalet", "Appartement d''exception"]}, {"name": "surface", "type": "number", "label": "Surface (m²)", "required": true, "placeholder": "350"}, {"name": "ville", "type": "text", "label": "Localisation", "required": true, "placeholder": "Cap d''Antibes"}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "2 800 000 €"}, {"name": "prestations", "type": "textarea", "label": "Prestations exceptionnelles", "required": true, "placeholder": "Piscine à débordement, vue mer panoramique, domotique…", "maxlength": 600}, {"name": "histoire", "type": "textarea", "label": "Histoire / cachet du bien", "required": false, "placeholder": "Bastide du XVIIIe siècle rénovée par…", "maxlength": 400}]}'::jsonb WHERE slug = 'immo-description-luxe';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_bien", "type": "text", "label": "Type de bien", "required": true, "placeholder": "Appartement T3"}, {"name": "ville", "type": "text", "label": "Localisation", "required": true, "placeholder": "Bordeaux centre"}, {"name": "atout_principal", "type": "text", "label": "Atout principal", "required": true, "placeholder": "Terrasse 30m² vue Garonne"}, {"name": "prix", "type": "text", "label": "Prix", "required": false, "placeholder": "285 000 €"}, {"name": "style", "type": "select", "label": "Style souhaité", "required": true, "options": ["Classique", "Percutant", "Émotionnel", "Factuel", "Mystérieux"]}]}'::jsonb WHERE slug = 'immo-titre-accrocheur';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "options": ["Appartement", "Maison", "Villa", "Loft", "Local commercial"]}, {"name": "pieces_description", "type": "textarea", "label": "Description pièce par pièce", "required": true, "placeholder": "Entrée avec placard intégré, séjour double avec cheminée, cuisine américaine équipée…", "maxlength": 800}, {"name": "points_forts", "type": "textarea", "label": "Points forts à mettre en avant", "required": true, "placeholder": "Luminosité, volumes, vue dégagée…", "maxlength": 400}, {"name": "duree", "type": "select", "label": "Durée cible", "required": true, "options": ["1 minute", "2 minutes", "3 minutes", "5 minutes"]}]}'::jsonb WHERE slug = 'immo-visite-virtuelle';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_bien", "type": "select", "label": "Type de bien", "required": true, "options": ["Appartement", "Maison", "Studio", "Chambre", "Local commercial"]}, {"name": "surface", "type": "number", "label": "Surface (m²)", "required": true, "placeholder": "45"}, {"name": "pieces", "type": "number", "label": "Nombre de pièces", "required": true, "placeholder": "2"}, {"name": "ville", "type": "text", "label": "Ville / Quartier", "required": true, "placeholder": "Paris 11ème"}, {"name": "meuble", "type": "toggle", "label": "Meublé", "required": false}, {"name": "equipements", "type": "textarea", "label": "Équipements notables", "required": false, "placeholder": "Balcon, parking, cave, gardien…", "maxlength": 300}, {"name": "dpe", "type": "select", "label": "DPE", "required": false, "options": ["A", "B", "C", "D", "E", "F", "G"]}]}'::jsonb WHERE slug = 'rent-estimator';
UPDATE tools SET input_schema = '{"fields": [{"name": "ville", "type": "text", "label": "Ville / Secteur", "required": true, "placeholder": "Nantes — Île de Nantes"}, {"name": "type_bien", "type": "select", "label": "Segment", "required": true, "options": ["Résidentiel", "Commercial", "Bureaux", "Terrain", "Mixte"]}, {"name": "rayon", "type": "select", "label": "Rayon d''analyse", "required": true, "options": ["Quartier", "Ville", "Agglomération", "Département"]}, {"name": "objectif", "type": "textarea", "label": "Objectif de l''analyse", "required": true, "placeholder": "Estimer la faisabilité d''un programme neuf de 20 lots", "maxlength": 400}]}'::jsonb WHERE slug = 'immo-analyse-marche';
UPDATE tools SET input_schema = '{"fields": [{"name": "bien1", "type": "textarea", "label": "Bien 1", "required": true, "placeholder": "T3 65m², Lyon 3, 280K€, balcon, DPE C", "maxlength": 300}, {"name": "bien2", "type": "textarea", "label": "Bien 2", "required": true, "placeholder": "T3 58m², Lyon 7, 265K€, parking, DPE D", "maxlength": 300}, {"name": "bien3", "type": "textarea", "label": "Bien 3 (optionnel)", "required": false, "placeholder": "T3 72m², Lyon 8, 310K€, terrasse, DPE B", "maxlength": 300}, {"name": "criteres", "type": "text", "label": "Critères prioritaires", "required": true, "placeholder": "Prix au m², transports, DPE, extérieur"}]}'::jsonb WHERE slug = 'immo-comparatif-biens';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom_prospect", "type": "text", "label": "Nom du prospect", "required": true, "placeholder": "M. et Mme Dupont"}, {"name": "contexte", "type": "select", "label": "Contexte", "required": true, "options": ["Première prise de contact", "Relance après estimation", "Après visite quartier", "Après événement local", "Recommandation"]}, {"name": "argument_cle", "type": "textarea", "label": "Argument clé", "required": true, "placeholder": "Hausse des prix de 8% dans leur quartier, moment idéal pour vendre", "maxlength": 400}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Amical", "Direct", "Rassurant"]}]}'::jsonb WHERE slug = 'immo-email-prospect';
UPDATE tools SET input_schema = '{"fields": [{"name": "bien", "type": "text", "label": "Bien visité", "required": true, "placeholder": "T4 92m² — 15 rue des Lilas, Lyon 3"}, {"name": "client", "type": "text", "label": "Nom du client", "required": true, "placeholder": "M. Martin"}, {"name": "impressions", "type": "textarea", "label": "Impressions et remarques", "required": true, "placeholder": "Client satisfait de la luminosité, s''interroge sur le bruit de la rue…", "maxlength": 600}, {"name": "points_positifs", "type": "textarea", "label": "Points positifs relevés", "required": true, "placeholder": "Volumes, état général, proximité métro", "maxlength": 300}, {"name": "reserves", "type": "textarea", "label": "Réserves / Points négatifs", "required": false, "placeholder": "DPE E, travaux copropriété à prévoir", "maxlength": 300}]}'::jsonb WHERE slug = 'immo-compte-rendu-visite';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom", "type": "text", "label": "Nom du propriétaire", "required": true, "placeholder": "Mme Lefebvre"}, {"name": "bien", "type": "text", "label": "Bien concerné", "required": true, "placeholder": "Maison T5 — Caluire-et-Cuire"}, {"name": "derniere_interaction", "type": "text", "label": "Dernière interaction", "required": true, "placeholder": "Estimation gratuite il y a 3 semaines"}, {"name": "argument", "type": "textarea", "label": "Nouvel argument / actualité", "required": true, "placeholder": "Vente similaire dans la rue à prix record", "maxlength": 400}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Doux", "Direct", "Informatif", "Urgent"]}]}'::jsonb WHERE slug = 'immo-relance-mandat';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom_produit", "type": "text", "label": "Nom du produit", "required": true, "placeholder": "Sac à dos urbain NOMAD 25L"}, {"name": "categorie", "type": "text", "label": "Catégorie", "required": true, "placeholder": "Bagagerie / Sacs à dos"}, {"name": "caracteristiques", "type": "textarea", "label": "Caractéristiques techniques", "required": true, "placeholder": "Polyester recyclé 600D, compartiment laptop 15\", poche anti-vol…", "maxlength": 600}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "89,90 €"}, {"name": "cible", "type": "text", "label": "Client cible", "required": true, "placeholder": "Urbains actifs 25-40 ans, trajets quotidiens"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Premium", "Décontracté", "Technique", "Inspirant", "Minimaliste"]}, {"name": "mots_cles", "type": "text", "label": "Mots-clés SEO (optionnel)", "required": false, "placeholder": "sac à dos ville, sac laptop, sac éco-responsable"}]}'::jsonb WHERE slug = 'commerce-fiche-produit';
UPDATE tools SET input_schema = '{"fields": [{"name": "instructions", "type": "textarea", "label": "Instructions générales", "required": true, "placeholder": "Ton premium, focus sur les matériaux et le confort. Chaque description doit faire 100-150 mots.", "maxlength": 500}, {"name": "produits", "type": "textarea", "label": "Liste des produits (un par ligne)", "required": true, "placeholder": "Nom | caractéristiques clés | prix\nChaussure TREK X1 | Gore-Tex, semelle Vibram | 159€\nVeste ALPINE PRO | Duvet 800, ultra-légère | 299€", "maxlength": 2000}, {"name": "ton", "type": "tone_grid", "label": "Ton global", "required": true, "options": ["Premium", "Technique", "Fun", "Éco-responsable"]}]}'::jsonb WHERE slug = 'commerce-bulk-descriptions';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom_produit", "type": "text", "label": "Nom du produit", "required": true, "placeholder": "Chargeur sans fil rapide 15W"}, {"name": "caracteristiques", "type": "textarea", "label": "Caractéristiques / bullet points", "required": true, "placeholder": "Compatible Qi, LED indicateur, protection surchauffe…", "maxlength": 600}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "29,99 €"}, {"name": "mots_cles", "type": "text", "label": "Mots-clés Amazon", "required": true, "placeholder": "chargeur sans fil, chargeur induction rapide, chargeur iPhone"}, {"name": "avantage_concurrent", "type": "text", "label": "Avantage vs concurrence", "required": true, "placeholder": "Seul modèle avec support magnétique intégré"}]}'::jsonb WHERE slug = 'commerce-fiche-amazon';
UPDATE tools SET input_schema = '{"fields": [{"name": "produit_principal", "type": "text", "label": "Produit principal", "required": true, "placeholder": "Machine à café automatique BARISTA Pro"}, {"name": "produits_suggeres", "type": "textarea", "label": "Produits à suggérer", "required": true, "placeholder": "Pack 3 cafés en grains, kit détartrage, tasses espresso", "maxlength": 400}, {"name": "type_reco", "type": "radio", "label": "Type de recommandation", "required": true, "options": ["Upsell (montée en gamme)", "Cross-sell (complémentaire)", "Bundle (pack)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Subtil", "Direct", "Enthousiaste", "Expert"]}]}'::jsonb WHERE slug = 'commerce-upsell-cross';
UPDATE tools SET input_schema = '{"fields": [{"name": "page_type", "type": "select", "label": "Type de page", "required": true, "options": ["Fiche produit", "Page catégorie", "Page d''accueil", "Blog", "Landing page"]}, {"name": "titre_page", "type": "text", "label": "Titre / sujet de la page", "required": true, "placeholder": "Chaussures de running homme"}, {"name": "mots_cles", "type": "text", "label": "Mots-clés cibles", "required": true, "placeholder": "chaussures running homme, basket course à pied"}, {"name": "usp", "type": "text", "label": "Avantage principal", "required": true, "placeholder": "Livraison gratuite, +200 modèles"}]}'::jsonb WHERE slug = 'commerce-meta-seo';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de l''article", "required": true, "placeholder": "Comment choisir son matelas en 2025"}, {"name": "produits_a_placer", "type": "textarea", "label": "Produits à intégrer", "required": true, "placeholder": "Matelas NUIT Pro (mousse), Matelas CLOUD (latex), Sur-matelas CONFORT+", "maxlength": 400}, {"name": "mots_cles", "type": "text", "label": "Mots-clés SEO", "required": true, "placeholder": "choisir matelas, meilleur matelas, comparatif matelas"}, {"name": "longueur", "type": "select", "label": "Longueur", "required": true, "options": ["Court (500 mots)", "Moyen (1000 mots)", "Long (1500+ mots)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Expert", "Conversationnel", "Comparatif", "Guide pratique"]}]}'::jsonb WHERE slug = 'commerce-blog-produit';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom_produit", "type": "text", "label": "Nom du produit", "required": true, "placeholder": "Aspirateur robot CLEAN X500"}, {"name": "caracteristiques", "type": "textarea", "label": "Caractéristiques principales", "required": true, "placeholder": "Navigation laser, autonomie 180min, bac 600ml, compatible app…", "maxlength": 400}, {"name": "nb_questions", "type": "select", "label": "Nombre de questions", "required": true, "options": ["5", "8", "10", "15"]}, {"name": "themes", "type": "text", "label": "Thèmes à couvrir", "required": false, "placeholder": "Utilisation, entretien, compatibilité, garantie"}]}'::jsonb WHERE slug = 'commerce-faq-produit';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom_boutique", "type": "text", "label": "Nom de la boutique", "required": true, "placeholder": "Maison du Café"}, {"name": "type_produit", "type": "text", "label": "Type de produit abandonné", "required": true, "placeholder": "Cafetière italienne + pack de café"}, {"name": "incentive", "type": "select", "label": "Incentive", "required": true, "options": ["Aucun", "Livraison gratuite", "-10% de réduction", "-15% de réduction", "Cadeau offert", "Stock limité"]}, {"name": "nb_emails", "type": "select", "label": "Nombre d''emails dans la séquence", "required": true, "options": ["1 (rappel simple)", "3 (séquence complète)", "5 (séquence avancée)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Amical", "Urgent", "Humoristique", "Premium"]}]}'::jsonb WHERE slug = 'commerce-email-panier';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom_boutique", "type": "text", "label": "Nom de la boutique", "required": true, "placeholder": "Maison du Café"}, {"name": "theme", "type": "text", "label": "Thème de la newsletter", "required": true, "placeholder": "Nouveautés de printemps + promotion -20%"}, {"name": "produits", "type": "textarea", "label": "Produits à mettre en avant", "required": true, "placeholder": "Cafetière V60, Café éthiopien Yirgacheffe, Mug isotherme", "maxlength": 400}, {"name": "cta", "type": "text", "label": "Objectif / CTA principal", "required": true, "placeholder": "Découvrir la collection printemps"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Enthousiaste", "Élégant", "Décontracté", "Informatif"]}]}'::jsonb WHERE slug = 'commerce-newsletter';
UPDATE tools SET input_schema = '{"fields": [{"name": "produit", "type": "text", "label": "Produit à promouvoir", "required": true, "placeholder": "Sneakers URBAN FLOW édition limitée"}, {"name": "occasion", "type": "select", "label": "Occasion", "required": true, "options": ["Lancement produit", "Promotion", "Tendance saison", "Behind the scenes", "UGC / témoignage", "Concours"]}, {"name": "cta", "type": "text", "label": "Call-to-action", "required": true, "placeholder": "Lien en bio pour commander"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Cool", "Premium", "Fun", "Inspirant"]}]}'::jsonb WHERE slug = 'commerce-post-instagram';
UPDATE tools SET input_schema = '{"fields": [{"name": "expediteur", "type": "text", "label": "Expéditeur (vous / votre client)", "required": true, "placeholder": "SCI Résidence Parc, représentée par Me Durand"}, {"name": "destinataire", "type": "text", "label": "Destinataire", "required": true, "placeholder": "M. Jean Dupont, locataire au 12 rue des Lilas"}, {"name": "objet", "type": "select", "label": "Objet", "required": true, "options": ["Impayés de loyer", "Non-respect contractuel", "Trouble de voisinage", "Livraison non conforme", "Vice caché", "Autre"]}, {"name": "faits", "type": "textarea", "label": "Exposé des faits", "required": true, "placeholder": "Depuis le 1er janvier 2025, le locataire ne s''est pas acquitté de ses loyers…", "maxlength": 800}, {"name": "montant", "type": "text", "label": "Montant réclamé (si applicable)", "required": false, "placeholder": "3 600 € (3 mois de loyer)"}, {"name": "delai", "type": "select", "label": "Délai accordé", "required": true, "options": ["8 jours", "15 jours", "30 jours", "2 mois"]}]}'::jsonb WHERE slug = 'legal-mise-en-demeure';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_contrat", "type": "select", "label": "Type de contrat", "required": true, "options": ["Prestation de services", "NDA / Confidentialité", "Bail commercial", "Bail professionnel", "Contrat de travail CDI", "Contrat de travail CDD", "Cession de droits", "Sous-traitance", "Partenariat"]}, {"name": "partie1", "type": "text", "label": "Partie 1", "required": true, "placeholder": "SARL Digital Agency, RCS Paris 123 456 789"}, {"name": "partie2", "type": "text", "label": "Partie 2", "required": true, "placeholder": "M. Martin Paul, auto-entrepreneur, SIRET 987 654 321"}, {"name": "objet", "type": "textarea", "label": "Objet du contrat", "required": true, "placeholder": "Développement d''un site web e-commerce avec 50 fiches produit", "maxlength": 600}, {"name": "duree", "type": "text", "label": "Durée", "required": true, "placeholder": "6 mois à compter de la signature"}, {"name": "montant", "type": "text", "label": "Montant / rémunération", "required": true, "placeholder": "12 000 € HT, payable en 3 échéances"}, {"name": "clauses_speciales", "type": "textarea", "label": "Clauses spéciales souhaitées", "required": false, "placeholder": "Clause de non-concurrence, pénalités de retard 3x…", "maxlength": 400}]}'::jsonb WHERE slug = 'legal-contrat-type';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_clause", "type": "select", "label": "Type de clause", "required": true, "options": ["Non-concurrence", "Confidentialité", "Pénalités", "Force majeure", "Résiliation", "Propriété intellectuelle", "Limitation de responsabilité", "RGPD", "Médiation/Arbitrage"]}, {"name": "contexte", "type": "textarea", "label": "Contexte du contrat", "required": true, "placeholder": "Contrat de prestation IT entre une ESN et un client grand compte", "maxlength": 400}, {"name": "specificites", "type": "textarea", "label": "Spécificités souhaitées", "required": true, "placeholder": "Non-concurrence limitée à 12 mois et au secteur bancaire", "maxlength": 400}]}'::jsonb WHERE slug = 'legal-clauses-specifiques';
UPDATE tools SET input_schema = '{"fields": [{"name": "juridiction", "type": "select", "label": "Juridiction", "required": true, "options": ["Tribunal judiciaire", "Tribunal de commerce", "Conseil de prud''hommes", "Cour d''appel", "Tribunal administratif"]}, {"name": "partie", "type": "radio", "label": "Vous représentez", "required": true, "options": ["Le demandeur", "Le défendeur", "L''intervenant"]}, {"name": "objet_litige", "type": "textarea", "label": "Objet du litige", "required": true, "placeholder": "Résiliation abusive d''un contrat de distribution exclusive", "maxlength": 600}, {"name": "faits", "type": "textarea", "label": "Exposé des faits", "required": true, "placeholder": "Le 15 mars 2024, la société X a notifié la résiliation…", "maxlength": 1000}, {"name": "fondements", "type": "textarea", "label": "Fondements juridiques", "required": true, "placeholder": "Art. 1104 et 1195 du Code civil, jurisprudence Cass. Com. 2022", "maxlength": 600}, {"name": "demandes", "type": "textarea", "label": "Demandes formulées", "required": true, "placeholder": "100 000 € de dommages-intérêts, publication du jugement", "maxlength": 400}]}'::jsonb WHERE slug = 'legal-conclusions';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_contrat", "type": "text", "label": "Type de contrat", "required": true, "placeholder": "Contrat de licence SaaS"}, {"name": "contenu", "type": "textarea", "label": "Collez le contenu du contrat (ou les clauses clés)", "required": true, "placeholder": "Article 1 - Objet…", "maxlength": 3000}, {"name": "point_vue", "type": "radio", "label": "Votre position", "required": true, "options": ["Je suis le prestataire", "Je suis le client", "Analyse neutre"]}, {"name": "focus", "type": "text", "label": "Points d''attention spécifiques", "required": false, "placeholder": "Clauses de résiliation, responsabilité, propriété IP"}]}'::jsonb WHERE slug = 'legal-analyse-contrat';
UPDATE tools SET input_schema = '{"fields": [{"name": "domaine", "type": "select", "label": "Domaine", "required": true, "options": ["Droit des contrats", "Droit du travail", "Droit immobilier", "Droit des sociétés", "Droit de la consommation", "Droit du numérique", "Droit pénal des affaires", "Droit de la propriété intellectuelle"]}, {"name": "question", "type": "textarea", "label": "Question juridique", "required": true, "placeholder": "Un employeur peut-il licencier pour des propos tenus sur un réseau social privé ?", "maxlength": 600}, {"name": "periode", "type": "select", "label": "Période", "required": true, "options": ["5 dernières années", "10 dernières années", "Toute la jurisprudence pertinente"]}]}'::jsonb WHERE slug = 'legal-recherche-jurisprudence';
UPDATE tools SET input_schema = '{"fields": [{"name": "texte", "type": "textarea", "label": "Texte juridique à vulgariser", "required": true, "placeholder": "Collez ici le texte juridique complexe…", "maxlength": 2000}, {"name": "public_cible", "type": "select", "label": "Public cible", "required": true, "options": ["Client particulier", "Client entreprise (non-juriste)", "Grand public", "Journaliste", "Étudiant"]}, {"name": "format", "type": "select", "label": "Format de sortie", "required": true, "options": ["Texte explicatif", "FAQ", "Points clés", "Infographie textuelle"]}]}'::jsonb WHERE slug = 'legal-vulgarisation';
UPDATE tools SET input_schema = '{"fields": [{"name": "destinataire", "type": "text", "label": "Destinataire", "required": true, "placeholder": "M. Dupont, dirigeant de la SAS TechVision"}, {"name": "objet_email", "type": "select", "label": "Type d''email", "required": true, "options": ["Compte-rendu d''avancement", "Demande de pièces", "Stratégie recommandée", "Résultat de procédure", "Honoraires", "Information juridique"]}, {"name": "contenu", "type": "textarea", "label": "Éléments à communiquer", "required": true, "placeholder": "L''audience du 15 mars s''est bien passée, le juge a retenu…", "maxlength": 600}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Formel", "Rassurant", "Direct", "Pédagogue"]}]}'::jsonb WHERE slug = 'legal-email-client';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_organisation", "type": "select", "label": "Type d''organisation", "required": true, "options": ["Site e-commerce", "Application mobile", "SaaS B2B", "Cabinet / profession libérale", "Association", "Collectivité"]}, {"name": "url", "type": "text", "label": "URL du site (optionnel)", "required": false, "placeholder": "https://www.example.com"}, {"name": "traitements", "type": "textarea", "label": "Principaux traitements de données", "required": true, "placeholder": "Newsletter, création de compte, paiement en ligne, analytics…", "maxlength": 600}, {"name": "niveau", "type": "select", "label": "Niveau de détail souhaité", "required": true, "options": ["Checklist rapide", "Audit intermédiaire", "Audit détaillé avec recommandations"]}]}'::jsonb WHERE slug = 'legal-rgpd-audit';
UPDATE tools SET input_schema = '{"fields": [{"name": "domaine", "type": "select", "label": "Domaine", "required": true, "options": ["Droit du numérique", "Droit du travail", "Droit immobilier", "Droit fiscal", "Droit de la consommation", "Droit des sociétés", "RGPD / données personnelles"]}, {"name": "periode", "type": "select", "label": "Période", "required": true, "options": ["Dernière semaine", "Dernier mois", "Dernier trimestre"]}, {"name": "focus", "type": "textarea", "label": "Sujets spécifiques", "required": false, "placeholder": "IA Act, télétravail obligatoire, nouvelle directive NIS2", "maxlength": 400}]}'::jsonb WHERE slug = 'legal-veille-juridique';
UPDATE tools SET input_schema = '{"fields": [{"name": "societe", "type": "text", "label": "Nom de la société", "required": true, "placeholder": "SAS TechVision"}, {"name": "exercice", "type": "text", "label": "Exercice concerné", "required": true, "placeholder": "Du 01/01/2025 au 31/12/2025"}, {"name": "ca", "type": "text", "label": "Chiffre d''affaires", "required": true, "placeholder": "1 250 000 €"}, {"name": "resultat", "type": "text", "label": "Résultat net", "required": true, "placeholder": "185 000 €"}, {"name": "faits_marquants", "type": "textarea", "label": "Faits marquants de l''exercice", "required": true, "placeholder": "Lancement nouveau produit, recrutement de 5 personnes, ouverture bureau Lyon…", "maxlength": 600}, {"name": "perspectives", "type": "textarea", "label": "Perspectives", "required": true, "placeholder": "Objectif CA 1.8M€, expansion internationale, levée série A", "maxlength": 400}]}'::jsonb WHERE slug = 'finance-rapport-gestion';
UPDATE tools SET input_schema = '{"fields": [{"name": "societe", "type": "text", "label": "Société", "required": true, "placeholder": "SARL Boulangerie Martin"}, {"name": "total_actif", "type": "text", "label": "Total actif", "required": true, "placeholder": "450 000 €"}, {"name": "capitaux_propres", "type": "text", "label": "Capitaux propres", "required": true, "placeholder": "180 000 €"}, {"name": "dettes", "type": "text", "label": "Total dettes", "required": true, "placeholder": "270 000 €"}, {"name": "ca", "type": "text", "label": "Chiffre d''affaires", "required": true, "placeholder": "620 000 €"}, {"name": "resultat", "type": "text", "label": "Résultat net", "required": true, "placeholder": "42 000 €"}, {"name": "tresorerie", "type": "text", "label": "Trésorerie", "required": true, "placeholder": "35 000 €"}, {"name": "secteur", "type": "select", "label": "Secteur d''activité", "required": true, "options": ["Commerce", "Industrie", "Services", "Artisanat", "BTP", "Tech / IT", "Restauration", "Santé"]}]}'::jsonb WHERE slug = 'finance-analyse-bilan';
UPDATE tools SET input_schema = '{"fields": [{"name": "projet", "type": "text", "label": "Nom du projet", "required": true, "placeholder": "Ouverture restaurant bistronomique"}, {"name": "secteur", "type": "select", "label": "Secteur", "required": true, "options": ["Restauration", "Commerce", "Services", "Tech", "Industrie", "BTP", "Santé", "Formation"]}, {"name": "investissement", "type": "text", "label": "Investissement initial", "required": true, "placeholder": "180 000 €"}, {"name": "ca_prevu_an1", "type": "text", "label": "CA prévisionnel Année 1", "required": true, "placeholder": "350 000 €"}, {"name": "charges_fixes", "type": "textarea", "label": "Charges fixes mensuelles estimées", "required": true, "placeholder": "Loyer 3000€, salaires 8000€, assurances 500€…", "maxlength": 600}, {"name": "financement", "type": "textarea", "label": "Sources de financement", "required": true, "placeholder": "Apport personnel 60K€, prêt bancaire 100K€, BPI 20K€", "maxlength": 400}]}'::jsonb WHERE slug = 'finance-previsionnel';
UPDATE tools SET input_schema = '{"fields": [{"name": "periode", "type": "text", "label": "Période analysée", "required": true, "placeholder": "Mars 2025"}, {"name": "kpis", "type": "textarea", "label": "KPIs du mois (copiez vos chiffres)", "required": true, "placeholder": "CA: 105K€ (+12% vs N-1), Marge brute: 62%, Tréso: 45K€, Effectif: 12", "maxlength": 600}, {"name": "evenements", "type": "textarea", "label": "Événements notables", "required": true, "placeholder": "Perte client X (-8K€/mois), gain appel d''offre Y (+15K€/mois)", "maxlength": 400}, {"name": "format", "type": "select", "label": "Format de commentaire", "required": true, "options": ["Synthèse exécutive (1 page)", "Analyse détaillée", "Bullet points"]}]}'::jsonb WHERE slug = 'finance-dashboard-comment';
UPDATE tools SET input_schema = '{"fields": [{"name": "cabinet", "type": "text", "label": "Nom du cabinet", "required": true, "placeholder": "Cabinet Expertise Durand & Associés"}, {"name": "client", "type": "text", "label": "Nom du client", "required": true, "placeholder": "SARL Les Jardins de Provence"}, {"name": "missions", "type": "textarea", "label": "Missions confiées", "required": true, "placeholder": "Tenue comptable, établissement des comptes annuels, déclarations fiscales, conseil de gestion", "maxlength": 600}, {"name": "honoraires", "type": "text", "label": "Honoraires proposés", "required": true, "placeholder": "350 € HT / mois"}, {"name": "duree", "type": "select", "label": "Durée", "required": true, "options": ["1 an renouvelable", "3 ans", "Durée indéterminée"]}]}'::jsonb WHERE slug = 'finance-lettre-mission';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_client", "type": "select", "label": "Type de client", "required": true, "options": ["Entreprise IS", "Entreprise IR", "Profession libérale", "SCI", "Particulier (patrimoine)"]}, {"name": "ca_annuel", "type": "text", "label": "CA annuel ou revenus", "required": true, "placeholder": "450 000 €"}, {"name": "resultat", "type": "text", "label": "Résultat / bénéfice", "required": true, "placeholder": "120 000 €"}, {"name": "situation", "type": "textarea", "label": "Situation particulière", "required": true, "placeholder": "Dirigeant TNS, pas de PER, 2 enfants, véhicule de fonction…", "maxlength": 600}, {"name": "objectif", "type": "select", "label": "Objectif principal", "required": true, "options": ["Réduire l''IS", "Optimiser la rémunération dirigeant", "Préparer la retraite", "Structurer le patrimoine", "Transmettre l''entreprise"]}]}'::jsonb WHERE slug = 'finance-conseil-optimisation';
UPDATE tools SET input_schema = '{"fields": [{"name": "client", "type": "text", "label": "Client", "required": true, "placeholder": "SAS Digital Solutions"}, {"name": "facture", "type": "text", "label": "Référence facture", "required": true, "placeholder": "FA-2025-0042 du 15/01/2025"}, {"name": "montant", "type": "text", "label": "Montant dû", "required": true, "placeholder": "4 800 € TTC"}, {"name": "retard", "type": "select", "label": "Retard de paiement", "required": true, "options": ["1-15 jours", "15-30 jours", "30-60 jours", "60-90 jours", "+90 jours"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Courtois", "Ferme", "Dernier rappel", "Juridique"]}]}'::jsonb WHERE slug = 'finance-email-relance';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet fiscal", "required": true, "placeholder": "Régime TVA sur les prestations de services intra-UE"}, {"name": "client", "type": "text", "label": "Client destinataire", "required": true, "placeholder": "M. Martin, gérant de WebAgency SARL"}, {"name": "contexte", "type": "textarea", "label": "Contexte de la question", "required": true, "placeholder": "Le client facture des prestations de développement web à des clients allemands…", "maxlength": 600}, {"name": "niveau_detail", "type": "select", "label": "Niveau de détail", "required": true, "options": ["Synthétique (1 page)", "Détaillé avec références", "Note complète avec exemples"]}]}'::jsonb WHERE slug = 'finance-note-fiscale';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_declaration", "type": "select", "label": "Type de déclaration", "required": true, "options": ["IR - Déclaration de revenus", "IS - Liasse fiscale", "TVA - Déclaration CA3", "CFE / CVAE", "Déclaration auto-entrepreneur", "DAS2"]}, {"name": "situation", "type": "textarea", "label": "Situation du client", "required": true, "placeholder": "Auto-entrepreneur en prestations de services, CA 2025: 45 000 €, versement libératoire", "maxlength": 600}, {"name": "questions", "type": "textarea", "label": "Questions spécifiques", "required": false, "placeholder": "Quelles cases remplir ? Quels montants déclarer ? Quels justificatifs ?", "maxlength": 400}]}'::jsonb WHERE slug = 'finance-declaration-aide';
UPDATE tools SET input_schema = '{"fields": [{"name": "processus", "type": "text", "label": "Nom du processus", "required": true, "placeholder": "Clôture mensuelle des comptes clients"}, {"name": "description", "type": "textarea", "label": "Description du processus", "required": true, "placeholder": "Rapprochement bancaire, lettrage, relances, provisions douteuses…", "maxlength": 600}, {"name": "frequence", "type": "select", "label": "Fréquence", "required": true, "options": ["Quotidien", "Hebdomadaire", "Mensuel", "Trimestriel", "Annuel"]}, {"name": "responsable", "type": "text", "label": "Responsable", "required": true, "placeholder": "Collaborateur comptable senior"}, {"name": "format", "type": "select", "label": "Format souhaité", "required": true, "options": ["Checklist étapes", "Procédure narrative", "Logigramme textuel"]}]}'::jsonb WHERE slug = 'finance-process-interne';
UPDATE tools SET input_schema = '{"fields": [{"name": "produit_service", "type": "text", "label": "Produit ou service", "required": true, "placeholder": "Formation en ligne \"Maîtrisez le SEO en 30 jours\""}, {"name": "cible", "type": "text", "label": "Cible principale", "required": true, "placeholder": "Entrepreneurs et freelances qui veulent plus de trafic organique"}, {"name": "probleme", "type": "textarea", "label": "Problème résolu", "required": true, "placeholder": "Vous dépensez des milliers en publicité sans résultats durables…", "maxlength": 400}, {"name": "benefices", "type": "textarea", "label": "Bénéfices clés (3-5)", "required": true, "placeholder": "Trafic x3 en 90 jours, méthodologie éprouvée, support illimité…", "maxlength": 400}, {"name": "prix", "type": "text", "label": "Prix / offre", "required": true, "placeholder": "497 € au lieu de 997 € — offre de lancement"}, {"name": "preuve_sociale", "type": "textarea", "label": "Preuves sociales", "required": false, "placeholder": "500+ élèves formés, note 4.8/5, témoignages…", "maxlength": 300}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Persuasif", "Éducatif", "Urgence", "Premium", "Décontracté"]}]}'::jsonb WHERE slug = 'marketing-landing-page';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet / produit", "required": true, "placeholder": "Application de méditation pour cadres stressés"}, {"name": "objectif", "type": "select", "label": "Objectif de l''accroche", "required": true, "options": ["Attirer des clics", "Générer des inscriptions", "Vendre", "Créer la curiosité", "Éduquer"]}, {"name": "cible", "type": "text", "label": "Audience cible", "required": true, "placeholder": "Cadres 30-50 ans, urbains, surchargés"}, {"name": "style", "type": "select", "label": "Style", "required": true, "options": ["Question", "Chiffre / statistique", "Promesse de résultat", "Contraste avant/après", "Storytelling"]}]}'::jsonb WHERE slug = 'marketing-headline';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de la vidéo", "required": true, "placeholder": "Présentation du nouveau service de livraison express"}, {"name": "duree", "type": "select", "label": "Durée cible", "required": true, "options": ["30 secondes (Reel/Short)", "1 minute", "2 minutes", "3 minutes", "5 minutes"]}, {"name": "plateforme", "type": "select", "label": "Plateforme principale", "required": true, "options": ["YouTube", "Instagram Reels", "TikTok", "LinkedIn", "Site web"]}, {"name": "cible", "type": "text", "label": "Audience", "required": true, "placeholder": "Restaurateurs indépendants en zone urbaine"}, {"name": "cta", "type": "text", "label": "Call-to-action final", "required": true, "placeholder": "Testez gratuitement pendant 14 jours"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Dynamique", "Corporate", "Humoristique", "Inspirant", "Éducatif"]}]}'::jsonb WHERE slug = 'marketing-script-video';
UPDATE tools SET input_schema = '{"fields": [{"name": "plateforme", "type": "select", "label": "Plateforme", "required": true, "options": ["Google Ads (Search)", "Google Ads (Display)", "Meta Ads (Facebook/Instagram)", "LinkedIn Ads", "TikTok Ads"]}, {"name": "produit", "type": "text", "label": "Produit / service", "required": true, "placeholder": "Logiciel de comptabilité pour auto-entrepreneurs"}, {"name": "cible", "type": "text", "label": "Audience cible", "required": true, "placeholder": "Auto-entrepreneurs, freelances, micro-entreprises"}, {"name": "budget_indication", "type": "select", "label": "Type de campagne", "required": true, "options": ["Acquisition", "Retargeting", "Notoriété", "Événement"]}, {"name": "usp", "type": "text", "label": "Avantage principal", "required": true, "placeholder": "Gratuit la 1ère année, conforme TVA auto"}, {"name": "nb_variantes", "type": "select", "label": "Nombre de variantes", "required": true, "options": ["3", "5", "10"]}]}'::jsonb WHERE slug = 'marketing-ad-copy';
UPDATE tools SET input_schema = '{"fields": [{"name": "entreprise", "type": "text", "label": "Entreprise / marque", "required": true, "placeholder": "Studio Pilates Harmony"}, {"name": "objectif", "type": "select", "label": "Objectif principal", "required": true, "options": ["Acquisition clients", "Notoriété", "Engagement communauté", "Lancement produit", "Recrutement"]}, {"name": "canaux", "type": "text", "label": "Canaux utilisés", "required": true, "placeholder": "Instagram, blog, newsletter, LinkedIn"}, {"name": "cible", "type": "text", "label": "Audience cible", "required": true, "placeholder": "Femmes 25-45 ans, urbaines, intéressées par le bien-être"}, {"name": "themes", "type": "textarea", "label": "Thématiques récurrentes", "required": true, "placeholder": "Exercices, nutrition, témoignages, behind the scenes", "maxlength": 400}]}'::jsonb WHERE slug = 'marketing-strategie-contenu';
UPDATE tools SET input_schema = '{"fields": [{"name": "projet", "type": "text", "label": "Nom du projet / campagne", "required": true, "placeholder": "Campagne de rentrée \"Back to Business\""}, {"name": "objectif", "type": "textarea", "label": "Objectif de la campagne", "required": true, "placeholder": "Recruter 500 nouveaux abonnés premium en septembre", "maxlength": 400}, {"name": "cible", "type": "text", "label": "Cible", "required": true, "placeholder": "PME 10-50 salariés, secteur services"}, {"name": "livrables", "type": "textarea", "label": "Livrables attendus", "required": true, "placeholder": "3 visuels social media, 1 vidéo 30s, 1 landing page, 1 email", "maxlength": 400}, {"name": "contraintes", "type": "textarea", "label": "Contraintes / charte", "required": false, "placeholder": "Couleurs bleu/blanc, logo visible, baseline obligatoire", "maxlength": 300}]}'::jsonb WHERE slug = 'marketing-brief-creatif';
UPDATE tools SET input_schema = '{"fields": [{"name": "produit", "type": "text", "label": "Produit / service", "required": true, "placeholder": "Application de gestion de projet"}, {"name": "secteur", "type": "text", "label": "Secteur", "required": true, "placeholder": "SaaS B2B"}, {"name": "nb_personas", "type": "select", "label": "Nombre de personas", "required": true, "options": ["1", "2", "3"]}, {"name": "donnees_existantes", "type": "textarea", "label": "Données clients existantes (optionnel)", "required": false, "placeholder": "80% de nos clients sont des PME tech, 60% femmes, utilisent Slack…", "maxlength": 400}]}'::jsonb WHERE slug = 'marketing-persona';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du post", "required": true, "placeholder": "Retour d''expérience sur le passage de freelance à fondateur de startup"}, {"name": "objectif", "type": "select", "label": "Objectif", "required": true, "options": ["Partager une expertise", "Storytelling personnel", "Promouvoir un contenu", "Recruter", "Générer des leads"]}, {"name": "cta", "type": "text", "label": "Call-to-action", "required": true, "placeholder": "Commentez avec votre expérience"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Inspirant", "Expert", "Conversationnel", "Provocateur", "Humble"]}]}'::jsonb WHERE slug = 'marketing-post-linkedin';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du thread", "required": true, "placeholder": "10 erreurs SEO qui vous coûtent des milliers d''euros"}, {"name": "nb_tweets", "type": "select", "label": "Nombre de tweets", "required": true, "options": ["5", "7", "10", "15"]}, {"name": "cible", "type": "text", "label": "Audience", "required": true, "placeholder": "Entrepreneurs et marketeurs digitaux"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Éducatif", "Provocateur", "Storytelling", "Data-driven"]}]}'::jsonb WHERE slug = 'marketing-thread-twitter';
UPDATE tools SET input_schema = '{"fields": [{"name": "objectif", "type": "select", "label": "Objectif de la séquence", "required": true, "options": ["Convertir un prospect en client", "Onboarding nouveau client", "Réactiver un client dormant", "Lancer un produit", "Éduquer / nurturing"]}, {"name": "produit", "type": "text", "label": "Produit / service", "required": true, "placeholder": "Formation \"SEO Mastery\" à 497€"}, {"name": "cible", "type": "text", "label": "Profil du destinataire", "required": true, "placeholder": "A téléchargé l''ebook gratuit sur le SEO, n''a pas encore acheté"}, {"name": "nb_emails", "type": "select", "label": "Nombre d''emails", "required": true, "options": ["3", "5", "7"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Éducatif", "Persuasif", "Amical", "Urgent"]}]}'::jsonb WHERE slug = 'marketing-email-sequence';
UPDATE tools SET input_schema = '{"fields": [{"name": "poste", "type": "text", "label": "Intitulé du poste", "required": true, "placeholder": "Développeur Full-Stack Senior"}, {"name": "entreprise", "type": "text", "label": "Nom de l''entreprise", "required": true, "placeholder": "TechVision SAS"}, {"name": "type_contrat", "type": "select", "label": "Type de contrat", "required": true, "options": ["CDI", "CDD", "Stage", "Alternance", "Freelance", "Intérim"]}, {"name": "localisation", "type": "text", "label": "Localisation", "required": true, "placeholder": "Lyon + 2j télétravail/semaine"}, {"name": "salaire", "type": "text", "label": "Rémunération", "required": true, "placeholder": "55-65K€ + variable + BSPCE"}, {"name": "missions", "type": "textarea", "label": "Missions principales", "required": true, "placeholder": "Développer de nouvelles features, code review, mentoring juniors…", "maxlength": 600}, {"name": "profil", "type": "textarea", "label": "Profil recherché", "required": true, "placeholder": "5+ ans d''expérience, React/Node, esprit startup, autonome", "maxlength": 400}, {"name": "avantages", "type": "textarea", "label": "Avantages", "required": false, "placeholder": "RTT, mutuelle Alan, tickets resto, budget formation…", "maxlength": 300}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Corporate", "Startup", "Décontracté", "Inspirant"]}]}'::jsonb WHERE slug = 'rh-offre-emploi';
UPDATE tools SET input_schema = '{"fields": [{"name": "poste", "type": "text", "label": "Poste", "required": true, "placeholder": "Head of Product"}, {"name": "entreprise", "type": "text", "label": "Entreprise", "required": true, "placeholder": "FinTech en série B, 80 personnes"}, {"name": "profil_candidat", "type": "text", "label": "Profil du candidat", "required": true, "placeholder": "Actuellement Product Director chez un concurrent SaaS"}, {"name": "accroche", "type": "text", "label": "Accroche / raison du contact", "required": true, "placeholder": "Son talk au ProductCon m''a marqué"}, {"name": "canal", "type": "select", "label": "Canal", "required": true, "options": ["LinkedIn InMail", "Email direct", "Message Twitter/X"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Décontracté", "Flatteur", "Direct"]}]}'::jsonb WHERE slug = 'rh-sourcing-message';
UPDATE tools SET input_schema = '{"fields": [{"name": "poste", "type": "text", "label": "Poste", "required": true, "placeholder": "Chef de projet marketing"}, {"name": "competences_cles", "type": "textarea", "label": "Compétences clés à évaluer", "required": true, "placeholder": "Gestion de projet, créativité, analytics, leadership d''équipe", "maxlength": 400}, {"name": "type_entretien", "type": "select", "label": "Type d''entretien", "required": true, "options": ["Entretien RH (fit culturel)", "Entretien technique", "Entretien manager", "Entretien final (direction)"]}, {"name": "duree", "type": "select", "label": "Durée prévue", "required": true, "options": ["30 minutes", "45 minutes", "1 heure", "1h30"]}]}'::jsonb WHERE slug = 'rh-grille-entretien';
UPDATE tools SET input_schema = '{"fields": [{"name": "candidat", "type": "text", "label": "Nom du candidat", "required": true, "placeholder": "Marie Dupont"}, {"name": "poste", "type": "text", "label": "Poste visé", "required": true, "placeholder": "Responsable marketing digital"}, {"name": "date_entretien", "type": "text", "label": "Date de l''entretien", "required": true, "placeholder": "15/03/2025"}, {"name": "notes", "type": "textarea", "label": "Notes brutes de l''entretien", "required": true, "placeholder": "Bonne présentation, 7 ans d''expérience, hésitante sur le management…", "maxlength": 800}, {"name": "avis", "type": "select", "label": "Avis global", "required": true, "options": ["Très favorable", "Favorable", "Réservé", "Défavorable"]}]}'::jsonb WHERE slug = 'rh-compte-rendu-entretien';
UPDATE tools SET input_schema = '{"fields": [{"name": "poste", "type": "text", "label": "Poste du nouvel arrivant", "required": true, "placeholder": "Développeur frontend junior"}, {"name": "equipe", "type": "text", "label": "Équipe d''accueil", "required": true, "placeholder": "Équipe Produit — 8 personnes"}, {"name": "manager", "type": "text", "label": "Manager direct", "required": true, "placeholder": "Sophie Martin, VP Engineering"}, {"name": "outils", "type": "text", "label": "Outils principaux à maîtriser", "required": true, "placeholder": "Jira, GitLab, Figma, Slack"}, {"name": "duree", "type": "select", "label": "Durée du programme", "required": true, "options": ["30 jours", "60 jours", "90 jours"]}]}'::jsonb WHERE slug = 'rh-plan-integration';
UPDATE tools SET input_schema = '{"fields": [{"name": "poste", "type": "text", "label": "Poste du collaborateur", "required": true, "placeholder": "Chargé de communication"}, {"name": "departement", "type": "text", "label": "Département", "required": true, "placeholder": "Marketing & Communication"}, {"name": "objectifs_precedents", "type": "textarea", "label": "Objectifs de l''année écoulée", "required": true, "placeholder": "Refonte site web, +30% followers LinkedIn, 2 événements organisés", "maxlength": 400}, {"name": "competences", "type": "textarea", "label": "Compétences à évaluer", "required": true, "placeholder": "Créativité, respect des délais, travail d''équipe, prise d''initiative", "maxlength": 400}]}'::jsonb WHERE slug = 'rh-entretien-annuel';
UPDATE tools SET input_schema = '{"fields": [{"name": "collaborateur", "type": "text", "label": "Collaborateur évalué", "required": true, "placeholder": "Thomas Leroy, Manager Opérations"}, {"name": "retours", "type": "textarea", "label": "Retours collectés (synthèse brute)", "required": true, "placeholder": "Manager: excellent sur la rigueur, doit déléguer plus. Pairs: très coopératif mais parfois directif. N-1: bon mentor mais réunions trop longues…", "maxlength": 1000}, {"name": "nb_evaluateurs", "type": "text", "label": "Nombre d''évaluateurs", "required": true, "placeholder": "8 (1 N+1, 3 pairs, 4 N-1)"}, {"name": "format", "type": "select", "label": "Format de restitution", "required": true, "options": ["Synthèse + plan d''action", "Rapport détaillé", "Présentation visuelle"]}]}'::jsonb WHERE slug = 'rh-feedback-360';
UPDATE tools SET input_schema = '{"fields": [{"name": "type_com", "type": "select", "label": "Type de communication", "required": true, "options": ["Arrivée collaborateur", "Départ collaborateur", "Promotion", "Réorganisation", "Nouvelle politique", "Événement interne", "Résultats / succès"]}, {"name": "details", "type": "textarea", "label": "Détails", "required": true, "placeholder": "Marie Dupont rejoint l''équipe Marketing le 1er avril en tant que Directrice Marketing, en remplacement de…", "maxlength": 600}, {"name": "canal", "type": "select", "label": "Canal de diffusion", "required": true, "options": ["Email all-hands", "Slack / Teams", "Intranet", "Affichage"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Enthousiaste", "Formel", "Neutre", "Chaleureux"]}]}'::jsonb WHERE slug = 'rh-communication-interne';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "select", "label": "Sujet de la politique", "required": true, "options": ["Télétravail / remote", "Congés & absences", "Code de conduite", "Utilisation IT / données", "Frais professionnels", "RSE / diversité", "Harcèlement / discrimination"]}, {"name": "contexte", "type": "textarea", "label": "Contexte de l''entreprise", "required": true, "placeholder": "Start-up de 45 personnes, 3 bureaux (Paris, Lyon, Nantes), politique hybrid actuelle 2j/semaine", "maxlength": 600}, {"name": "specificites", "type": "textarea", "label": "Spécificités souhaitées", "required": false, "placeholder": "Possibilité de full remote pour les devs, max 3 mois/an depuis l''étranger", "maxlength": 400}]}'::jsonb WHERE slug = 'rh-politique-entreprise';
UPDATE tools SET input_schema = '{"fields": [{"name": "entreprise", "type": "text", "label": "Nom de l''entreprise", "required": true, "placeholder": "SAS TechVision"}, {"name": "effectif", "type": "text", "label": "Effectif", "required": true, "placeholder": "85 salariés"}, {"name": "secteur", "type": "select", "label": "Secteur", "required": true, "options": ["Tech / IT", "Commerce", "Industrie", "Services", "BTP", "Santé", "Finance", "Restauration"]}, {"name": "specificites", "type": "textarea", "label": "Spécificités à inclure", "required": false, "placeholder": "Travail en open space, dress code client, accès locaux sécurisés", "maxlength": 400}]}'::jsonb WHERE slug = 'rh-reglement-interieur';
UPDATE tools SET input_schema = '{"fields": [{"name": "praticien", "type": "text", "label": "Votre titre et nom", "required": true, "placeholder": "Dr. Sophie Martin, kinésithérapeute"}, {"name": "patient", "type": "text", "label": "Nom du patient", "required": true, "placeholder": "M. Dupont"}, {"name": "objet", "type": "select", "label": "Objet de l''email", "required": true, "options": ["Suivi post-consultation", "Résultats d''examens", "Renouvellement ordonnance", "Information préventive", "Changement d''horaires", "Absence / remplacement"]}, {"name": "contenu", "type": "textarea", "label": "Éléments à communiquer", "required": true, "placeholder": "Suite à votre consultation, je souhaite vous rappeler les exercices…", "maxlength": 600}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Chaleureux", "Rassurant", "Pédagogue"]}]}'::jsonb WHERE slug = 'sante-email-patient';
UPDATE tools SET input_schema = '{"fields": [{"name": "praticien", "type": "text", "label": "Cabinet / Praticien", "required": true, "placeholder": "Cabinet de kinésithérapie Martin"}, {"name": "type_rdv", "type": "text", "label": "Type de rendez-vous", "required": true, "placeholder": "Séance de rééducation du genou"}, {"name": "canal", "type": "radio", "label": "Canal", "required": true, "options": ["SMS", "Email"]}, {"name": "delai", "type": "select", "label": "Délai avant le RDV", "required": true, "options": ["24h avant", "48h avant", "1 semaine avant"]}, {"name": "infos_pratiques", "type": "textarea", "label": "Informations pratiques", "required": false, "placeholder": "Apporter tenue confortable, ordonnance, carte vitale", "maxlength": 300}]}'::jsonb WHERE slug = 'sante-rappel-rdv';
UPDATE tools SET input_schema = '{"fields": [{"name": "acte", "type": "text", "label": "Acte / traitement", "required": true, "placeholder": "Injection d''acide hyaluronique — sillons nasogéniens"}, {"name": "praticien", "type": "text", "label": "Praticien", "required": true, "placeholder": "Dr. Pierre Leroy, médecin esthétique"}, {"name": "risques", "type": "textarea", "label": "Risques principaux à mentionner", "required": true, "placeholder": "Hématome, gonflement, asymétrie, infection rare, migration produit", "maxlength": 600}, {"name": "alternatives", "type": "textarea", "label": "Alternatives au traitement", "required": false, "placeholder": "Peeling, laser, abstention thérapeutique", "maxlength": 300}]}'::jsonb WHERE slug = 'sante-consentement';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de la fiche", "required": true, "placeholder": "Exercices post-opératoires du genou"}, {"name": "public", "type": "select", "label": "Public", "required": true, "options": ["Patient adulte", "Patient enfant", "Aidant / famille", "Sportif", "Senior"]}, {"name": "contenu_cle", "type": "textarea", "label": "Informations essentielles à transmettre", "required": true, "placeholder": "5 exercices à faire quotidiennement, durée 15min, précautions…", "maxlength": 600}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Fiche A4 imprimable", "Email patient", "Infographie textuelle"]}]}'::jsonb WHERE slug = 'sante-fiche-conseil';
UPDATE tools SET input_schema = '{"fields": [{"name": "pathologie", "type": "text", "label": "Pathologie / objectif", "required": true, "placeholder": "Rééducation épaule post-luxation"}, {"name": "patient", "type": "textarea", "label": "Profil patient", "required": true, "placeholder": "Homme 35 ans, sportif amateur, luxation antérieure épaule droite il y a 6 semaines", "maxlength": 400}, {"name": "duree", "type": "select", "label": "Durée du programme", "required": true, "options": ["4 semaines", "8 semaines", "12 semaines", "6 mois"]}, {"name": "frequence", "type": "select", "label": "Fréquence des séances", "required": true, "options": ["2x/semaine", "3x/semaine", "Quotidien"]}]}'::jsonb WHERE slug = 'sante-programme-soin';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet", "required": true, "placeholder": "Comment prévenir le mal de dos au bureau"}, {"name": "specialite", "type": "text", "label": "Votre spécialité", "required": true, "placeholder": "Kinésithérapie / ostéopathie"}, {"name": "cible", "type": "select", "label": "Public cible", "required": true, "options": ["Grand public", "Patients", "Professionnels de santé", "Sportifs"]}, {"name": "longueur", "type": "select", "label": "Longueur", "required": true, "options": ["Court (400 mots)", "Moyen (800 mots)", "Long (1200+ mots)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Scientifique", "Accessible", "Rassurant", "Pratique"]}]}'::jsonb WHERE slug = 'sante-article-blog';
UPDATE tools SET input_schema = '{"fields": [{"name": "patient", "type": "text", "label": "Patient", "required": true, "placeholder": "M. Martin, 52 ans"}, {"name": "motif", "type": "text", "label": "Motif de consultation", "required": true, "placeholder": "Douleurs lombaires chroniques depuis 3 mois"}, {"name": "examen", "type": "textarea", "label": "Examen clinique", "required": true, "placeholder": "Limitation flexion 60°, contracture para-vertébrale bilatérale, Lasègue négatif…", "maxlength": 600}, {"name": "diagnostic", "type": "text", "label": "Diagnostic / hypothèse", "required": true, "placeholder": "Lombalgie commune sur sédentarité"}, {"name": "traitement", "type": "textarea", "label": "Traitement proposé", "required": true, "placeholder": "10 séances kiné, renforcement core, étirements quotidiens", "maxlength": 400}]}'::jsonb WHERE slug = 'sante-compte-rendu';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom", "type": "text", "label": "Nom complet", "required": true, "placeholder": "Dr. Sophie Martin"}, {"name": "specialite", "type": "text", "label": "Spécialité", "required": true, "placeholder": "Kinésithérapeute, spécialisée en rééducation sportive"}, {"name": "parcours", "type": "textarea", "label": "Parcours / formations", "required": true, "placeholder": "IFMK Lyon 2012, DU de thérapie manuelle, certifiée McKenzie…", "maxlength": 400}, {"name": "approche", "type": "textarea", "label": "Votre approche", "required": true, "placeholder": "Prise en charge globale, éducation thérapeutique, retour au sport…", "maxlength": 400}, {"name": "plateforme", "type": "select", "label": "Plateforme", "required": true, "options": ["Site web personnel", "Doctolib", "Annuaire professionnel", "LinkedIn", "Google My Business"]}]}'::jsonb WHERE slug = 'sante-bio-praticien';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du post", "required": true, "placeholder": "3 exercices simples contre le mal de dos"}, {"name": "specialite", "type": "text", "label": "Votre spécialité", "required": true, "placeholder": "Kinésithérapie"}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Carrousel (5-10 slides)", "Post unique avec texte long", "Reel (script)", "Story"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Éducatif", "Fun", "Professionnel", "Motivant"]}]}'::jsonb WHERE slug = 'sante-post-instagram';
UPDATE tools SET input_schema = '{"fields": [{"name": "avis", "type": "textarea", "label": "Contenu de l''avis", "required": true, "placeholder": "Collez ici l''avis Google auquel répondre…", "maxlength": 800}, {"name": "note", "type": "select", "label": "Note de l''avis", "required": true, "options": ["⭐ (1 étoile)", "⭐⭐ (2 étoiles)", "⭐⭐⭐ (3 étoiles)", "⭐⭐⭐⭐ (4 étoiles)", "⭐⭐⭐⭐⭐ (5 étoiles)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton de la réponse", "required": true, "options": ["Professionnel", "Chaleureux", "Empathique", "Factuel"]}]}'::jsonb WHERE slug = 'sante-avis-google';
UPDATE tools SET input_schema = '{"fields": [{"name": "matiere", "type": "text", "label": "Matière / sujet", "required": true, "placeholder": "Introduction au Machine Learning"}, {"name": "niveau", "type": "select", "label": "Niveau", "required": true, "options": ["Débutant", "Intermédiaire", "Avancé", "Expert"]}, {"name": "duree", "type": "select", "label": "Durée totale", "required": true, "options": ["2 heures", "Demi-journée (3h30)", "Journée (7h)", "2 jours", "5 jours"]}, {"name": "public", "type": "text", "label": "Public cible", "required": true, "placeholder": "Développeurs web souhaitant se reconvertir en data science"}, {"name": "objectifs", "type": "textarea", "label": "Objectifs pédagogiques", "required": true, "placeholder": "Comprendre les bases du ML, savoir choisir un algorithme, implémenter un modèle simple", "maxlength": 400}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Présentiel", "Distanciel synchrone", "E-learning asynchrone", "Hybride"]}]}'::jsonb WHERE slug = 'edu-plan-cours';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de la formation", "required": true, "placeholder": "Gestion de projet Agile avec Scrum"}, {"name": "duree", "type": "select", "label": "Durée de la formation", "required": true, "options": ["2 heures", "Demi-journée", "Journée", "2 jours", "5 jours"]}, {"name": "public", "type": "text", "label": "Public cible", "required": true, "placeholder": "Chefs de projet en transition vers l''agilité"}, {"name": "plan", "type": "textarea", "label": "Plan / modules (si existant)", "required": false, "placeholder": "Module 1: Manifeste Agile, Module 2: Rôles Scrum…", "maxlength": 600}, {"name": "style", "type": "select", "label": "Style pédagogique", "required": true, "options": ["Magistral illustré", "Participatif / ateliers", "Learning by doing", "Classe inversée"]}]}'::jsonb WHERE slug = 'edu-support-formation';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet de l''exercice", "required": true, "placeholder": "Calcul de ROI d''une campagne marketing"}, {"name": "niveau", "type": "select", "label": "Niveau", "required": true, "options": ["Débutant", "Intermédiaire", "Avancé"]}, {"name": "type_exercice", "type": "select", "label": "Type d''exercice", "required": true, "options": ["Cas pratique", "Étude de cas", "Mise en situation", "Exercice d''application", "Jeu de rôle"]}, {"name": "competences", "type": "text", "label": "Compétences évaluées", "required": true, "placeholder": "Analyse de données, calcul financier, prise de décision"}, {"name": "duree", "type": "select", "label": "Durée estimée", "required": true, "options": ["15 minutes", "30 minutes", "1 heure", "2 heures"]}, {"name": "avec_corrige", "type": "toggle", "label": "Inclure un corrigé détaillé", "required": false}]}'::jsonb WHERE slug = 'edu-exercice-pratique';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du module", "required": true, "placeholder": "Les bases de la cybersécurité au quotidien"}, {"name": "duree", "type": "select", "label": "Durée du module", "required": true, "options": ["5 minutes", "10 minutes", "15 minutes", "20 minutes", "30 minutes"]}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Voix off + slides", "Vidéo animée", "Screencast", "Dialogue interactif"]}, {"name": "objectif", "type": "textarea", "label": "Objectif d''apprentissage", "required": true, "placeholder": "L''apprenant saura reconnaître un email de phishing et adopter les bons réflexes", "maxlength": 400}]}'::jsonb WHERE slug = 'edu-script-elearning';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet", "required": true, "placeholder": "Droit du travail — Le contrat de travail"}, {"name": "nb_questions", "type": "select", "label": "Nombre de questions", "required": true, "options": ["5", "10", "15", "20"]}, {"name": "niveau", "type": "select", "label": "Niveau de difficulté", "required": true, "options": ["Facile", "Moyen", "Difficile", "Mixte"]}, {"name": "contenu_source", "type": "textarea", "label": "Contenu source (optionnel)", "required": false, "placeholder": "Collez ici le texte de cours sur lequel baser les questions…", "maxlength": 2000}, {"name": "avec_explications", "type": "toggle", "label": "Inclure des explications par réponse", "required": false}]}'::jsonb WHERE slug = 'edu-qcm-generateur';
UPDATE tools SET input_schema = '{"fields": [{"name": "intitule", "type": "text", "label": "Intitulé de l''évaluation", "required": true, "placeholder": "Présentation orale du projet de fin d''études"}, {"name": "competences", "type": "textarea", "label": "Compétences à évaluer", "required": true, "placeholder": "Maîtrise technique, qualité de présentation, réponse aux questions, originalité", "maxlength": 400}, {"name": "echelle", "type": "select", "label": "Échelle de notation", "required": true, "options": ["1 à 4", "1 à 5", "1 à 10", "A/B/C/D", "Acquis / En cours / Non acquis"]}, {"name": "ponderation", "type": "toggle", "label": "Ajouter une pondération", "required": false}]}'::jsonb WHERE slug = 'edu-grille-evaluation';
UPDATE tools SET input_schema = '{"fields": [{"name": "titre_certification", "type": "text", "label": "Titre de la certification", "required": true, "placeholder": "Certification Scrum Master"}, {"name": "organisme", "type": "text", "label": "Organisme certificateur", "required": true, "placeholder": "Agile Academy France"}, {"name": "competences", "type": "textarea", "label": "Compétences certifiées", "required": true, "placeholder": "Facilitation d''équipe Scrum, gestion de backlog, animation de cérémonies…", "maxlength": 400}, {"name": "prerequis", "type": "textarea", "label": "Prérequis", "required": false, "placeholder": "2 ans d''expérience en gestion de projet, formation préalable recommandée", "maxlength": 300}]}'::jsonb WHERE slug = 'edu-certification-texte';
UPDATE tools SET input_schema = '{"fields": [{"name": "titre_formation", "type": "text", "label": "Titre de la formation", "required": true, "placeholder": "Management d''équipe — Niveau 1"}, {"name": "duree", "type": "text", "label": "Durée", "required": true, "placeholder": "2 jours (14 heures)"}, {"name": "public", "type": "text", "label": "Public cible", "required": true, "placeholder": "Managers nouvellement promus"}, {"name": "objectifs", "type": "textarea", "label": "Objectifs", "required": true, "placeholder": "Adapter son style de management, conduire des entretiens, gérer les conflits", "maxlength": 400}, {"name": "certification", "type": "toggle", "label": "Formation certifiante", "required": false}]}'::jsonb WHERE slug = 'edu-programme-catalogue';
UPDATE tools SET input_schema = '{"fields": [{"name": "titre", "type": "text", "label": "Titre de la formation", "required": true, "placeholder": "Maîtrisez Excel en 5 jours"}, {"name": "prix", "type": "text", "label": "Prix", "required": true, "placeholder": "1 490 € (éligible CPF)"}, {"name": "cible", "type": "text", "label": "Public cible", "required": true, "placeholder": "Professionnels voulant gagner en productivité avec Excel"}, {"name": "benefices", "type": "textarea", "label": "Bénéfices clés", "required": true, "placeholder": "Formules avancées, TCD, macros, dashboards automatisés", "maxlength": 400}, {"name": "preuve", "type": "textarea", "label": "Preuves sociales", "required": false, "placeholder": "4.9/5 sur 200 avis, +3000 stagiaires formés, certification reconnue", "maxlength": 300}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Dynamique", "Rassurant", "Premium"]}]}'::jsonb WHERE slug = 'edu-landing-formation';
UPDATE tools SET input_schema = '{"fields": [{"name": "formation", "type": "text", "label": "Formation à promouvoir", "required": true, "placeholder": "Formation Cybersécurité — 3 jours"}, {"name": "cible", "type": "text", "label": "Cible", "required": true, "placeholder": "Responsables IT de PME"}, {"name": "argument_cle", "type": "text", "label": "Argument principal", "required": true, "placeholder": "Conformité NIS2 obligatoire avant octobre 2025"}, {"name": "offre", "type": "text", "label": "Offre spéciale (optionnel)", "required": false, "placeholder": "-20% pour les inscriptions avant le 30 avril"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Expert", "Urgent", "Amical", "Corporate"]}]}'::jsonb WHERE slug = 'edu-email-prospect';
UPDATE tools SET input_schema = '{"fields": [{"name": "plat", "type": "text", "label": "Nom du plat", "required": true, "placeholder": "Filet de bar rôti, émulsion safranée"}, {"name": "ingredients", "type": "textarea", "label": "Ingrédients principaux", "required": true, "placeholder": "Bar de ligne, crème, safran, pommes grenaille, haricots verts, beurre noisette", "maxlength": 400}, {"name": "type_cuisine", "type": "select", "label": "Type de cuisine", "required": true, "options": ["Bistronomique", "Gastronomique", "Brasserie", "Fast-casual", "Végétarien/Vegan", "World food", "Terroir"]}, {"name": "prix", "type": "text", "label": "Prix", "required": false, "placeholder": "28 €"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Poétique", "Factuel", "Gourmand", "Minimaliste", "Luxe"]}]}'::jsonb WHERE slug = 'resto-menu-description';
UPDATE tools SET input_schema = '{"fields": [{"name": "saison", "type": "select", "label": "Saison", "required": true, "options": ["Printemps", "Été", "Automne", "Hiver"]}, {"name": "type_resto", "type": "select", "label": "Type de restaurant", "required": true, "options": ["Bistronomique", "Gastronomique", "Brasserie", "Italien", "Végétarien", "Fusion"]}, {"name": "nb_plats", "type": "select", "label": "Nombre de plats souhaités", "required": true, "options": ["Entrées (5) + Plats (5) + Desserts (3)", "Menu dégustation (7 plats)", "Carte complète (15+ plats)"]}, {"name": "contraintes", "type": "textarea", "label": "Contraintes / préférences", "required": false, "placeholder": "Produits locaux privilégiés, toujours 1 option végé, budget matière 30%", "maxlength": 400}]}'::jsonb WHERE slug = 'resto-carte-saison';
UPDATE tools SET input_schema = '{"fields": [{"name": "plat", "type": "text", "label": "Nom du plat", "required": true, "placeholder": "Risotto aux cèpes et parmesan"}, {"name": "ingredients", "type": "textarea", "label": "Liste complète des ingrédients", "required": true, "placeholder": "Riz arborio, cèpes, oignon, vin blanc, bouillon de volaille, parmesan, beurre, crème…", "maxlength": 600}, {"name": "format", "type": "select", "label": "Format", "required": true, "options": ["Fiche individuelle", "Tableau récapitulatif", "Liste avec pictogrammes"]}]}'::jsonb WHERE slug = 'resto-menu-allergen';
UPDATE tools SET input_schema = '{"fields": [{"name": "cocktail", "type": "text", "label": "Nom du cocktail", "required": true, "placeholder": "Le Jardin Méditerranéen"}, {"name": "ingredients", "type": "textarea", "label": "Ingrédients et proportions", "required": true, "placeholder": "4cl gin, 2cl Chartreuse verte, 3cl citron vert, basilic frais, sirop de miel", "maxlength": 400}, {"name": "style", "type": "select", "label": "Style de la carte", "required": true, "options": ["Classique élégant", "Fun & décalé", "Tiki", "Speakeasy", "Naturel / bio"]}, {"name": "prix", "type": "text", "label": "Prix", "required": false, "placeholder": "14 €"}]}'::jsonb WHERE slug = 'resto-cocktail-carte';
UPDATE tools SET input_schema = '{"fields": [{"name": "plateforme", "type": "select", "label": "Plateforme", "required": true, "options": ["Google", "TripAdvisor", "TheFork", "Yelp", "Instagram"]}, {"name": "avis", "type": "textarea", "label": "Contenu de l''avis", "required": true, "placeholder": "Collez ici l''avis du client…", "maxlength": 800}, {"name": "note", "type": "select", "label": "Note", "required": true, "options": ["⭐ (1)", "⭐⭐ (2)", "⭐⭐⭐ (3)", "⭐⭐⭐⭐ (4)", "⭐⭐⭐⭐⭐ (5)"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Chaleureux", "Professionnel", "Humble", "Factuel"]}]}'::jsonb WHERE slug = 'resto-reponse-avis';
UPDATE tools SET input_schema = '{"fields": [{"name": "restaurant", "type": "text", "label": "Nom du restaurant", "required": true, "placeholder": "Le Bistrot des Halles"}, {"name": "evenement", "type": "text", "label": "Événement", "required": true, "placeholder": "Soirée dégustation vins naturels avec le vigneron"}, {"name": "date", "type": "text", "label": "Date et horaire", "required": true, "placeholder": "Jeudi 20 mars 2025, 19h30"}, {"name": "prix", "type": "text", "label": "Prix / formule", "required": true, "placeholder": "55 € par personne (5 vins + menu accord)"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Gourmand", "Exclusif", "Décontracté", "Festif"]}]}'::jsonb WHERE slug = 'resto-email-evenement';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du post", "required": true, "placeholder": "Nouveau plat du jour : risotto aux truffes noires"}, {"name": "occasion", "type": "select", "label": "Occasion", "required": true, "options": ["Plat du jour", "Nouveau menu", "Événement", "Behind the scenes", "Équipe", "Produit / fournisseur"]}, {"name": "restaurant", "type": "text", "label": "Nom du restaurant", "required": true, "placeholder": "Le Bistrot des Halles"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Gourmand", "Authentique", "Fun", "Premium"]}]}'::jsonb WHERE slug = 'resto-post-instagram';
UPDATE tools SET input_schema = '{"fields": [{"name": "plat", "type": "text", "label": "Nom du plat", "required": true, "placeholder": "Tarte Tatin traditionnelle"}, {"name": "nb_portions", "type": "number", "label": "Nombre de portions", "required": true, "placeholder": "8"}, {"name": "ingredients", "type": "textarea", "label": "Ingrédients avec grammages", "required": true, "placeholder": "250g pâte feuilletée, 8 pommes Golden, 150g sucre, 80g beurre…", "maxlength": 600}, {"name": "process", "type": "textarea", "label": "Étapes de production", "required": true, "placeholder": "1. Éplucher et couper les pommes en quartiers. 2. Caraméliser sucre et beurre…", "maxlength": 1000}, {"name": "allergenes", "type": "text", "label": "Allergènes", "required": true, "placeholder": "Gluten, lait, œufs"}]}'::jsonb WHERE slug = 'resto-fiche-recette';
UPDATE tools SET input_schema = '{"fields": [{"name": "poste", "type": "select", "label": "Poste concerné", "required": true, "options": ["Serveur", "Barman", "Commis de cuisine", "Chef de rang", "Réceptionniste", "Plongeur"]}, {"name": "sujet", "type": "text", "label": "Sujet de la formation", "required": true, "placeholder": "Accueil client et prise de commande"}, {"name": "niveau", "type": "select", "label": "Niveau", "required": true, "options": ["Nouvel arrivant", "Rappel / perfectionnement", "Promotion au poste"]}, {"name": "points_cles", "type": "textarea", "label": "Points clés à couvrir", "required": true, "placeholder": "Saluer le client, présenter la carte, gérer les allergies, upselling boissons…", "maxlength": 600}]}'::jsonb WHERE slug = 'resto-formation-equipe';
UPDATE tools SET input_schema = '{"fields": [{"name": "restaurant", "type": "text", "label": "Nom du restaurant", "required": true, "placeholder": "Le Comptoir du Marché"}, {"name": "evenement", "type": "select", "label": "Type d''événement", "required": true, "options": ["Ouverture", "Nouveau chef", "Étoile / distinction", "Nouveau concept", "Anniversaire", "Événement spécial"]}, {"name": "details", "type": "textarea", "label": "Détails de l''événement", "required": true, "placeholder": "Ouverture le 15 avril, cuisine bistronomique, produits 100% locaux, chef ex-Bocuse…", "maxlength": 600}, {"name": "contact_presse", "type": "text", "label": "Contact presse", "required": true, "placeholder": "Marie Dupont — presse@lecomptoir.fr — 06 12 34 56 78"}]}'::jsonb WHERE slug = 'resto-communique-presse';
UPDATE tools SET input_schema = '{"fields": [{"name": "client", "type": "text", "label": "Nom du client", "required": true, "placeholder": "SAS TechVision"}, {"name": "projet", "type": "text", "label": "Projet", "required": true, "placeholder": "Refonte du site web corporate + SEO"}, {"name": "contexte", "type": "textarea", "label": "Contexte et besoin", "required": true, "placeholder": "Site actuel vieillissant, pas responsive, SEO en chute. Objectif: +50% trafic en 6 mois", "maxlength": 600}, {"name": "prestations", "type": "textarea", "label": "Prestations proposées", "required": true, "placeholder": "Audit UX, design 5 pages, intégration WordPress, optimisation SEO, formation", "maxlength": 600}, {"name": "tarif", "type": "text", "label": "Budget / tarif", "required": true, "placeholder": "8 500 € HT, payable en 3 échéances"}, {"name": "delai", "type": "text", "label": "Délai de réalisation", "required": true, "placeholder": "6 semaines après validation du devis"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Professionnel", "Dynamique", "Premium", "Décontracté"]}]}'::jsonb WHERE slug = 'freelance-proposition';
UPDATE tools SET input_schema = '{"fields": [{"name": "cible", "type": "text", "label": "Cible (fonction + entreprise)", "required": true, "placeholder": "Responsable marketing chez une PME e-commerce"}, {"name": "service", "type": "text", "label": "Votre service principal", "required": true, "placeholder": "Création de contenus SEO + stratégie éditoriale"}, {"name": "accroche", "type": "text", "label": "Accroche / angle d''attaque", "required": true, "placeholder": "J''ai remarqué que votre blog n''a pas été mis à jour depuis 6 mois"}, {"name": "preuve", "type": "text", "label": "Preuve / crédibilité", "required": true, "placeholder": "+200% de trafic organique pour un client similaire en 4 mois"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Direct", "Amical", "Consultative", "Audacieux"]}]}'::jsonb WHERE slug = 'freelance-email-prospection';
UPDATE tools SET input_schema = '{"fields": [{"name": "metier", "type": "text", "label": "Votre métier", "required": true, "placeholder": "Consultant en transformation digitale"}, {"name": "cible", "type": "text", "label": "Client idéal", "required": true, "placeholder": "PME industrielles en transformation numérique"}, {"name": "probleme", "type": "text", "label": "Problème que vous résolvez", "required": true, "placeholder": "Perte de compétitivité faute de digitalisation des process"}, {"name": "resultat", "type": "text", "label": "Résultat concret", "required": true, "placeholder": "-30% de coûts opérationnels en moyenne"}, {"name": "contexte", "type": "select", "label": "Contexte d''utilisation", "required": true, "options": ["Networking event", "LinkedIn", "Rendez-vous prospect", "Salon professionnel", "Appel téléphonique"]}]}'::jsonb WHERE slug = 'freelance-elevator-pitch';
UPDATE tools SET input_schema = '{"fields": [{"name": "service", "type": "text", "label": "Votre service", "required": true, "placeholder": "Création de sites web"}, {"name": "prix_moyen", "type": "text", "label": "Prix moyen de vos prestations", "required": true, "placeholder": "5 000 — 15 000 €"}, {"name": "objections", "type": "textarea", "label": "Objections fréquentes", "required": true, "placeholder": "C''est trop cher, mon neveu peut le faire, je n''ai pas le temps, on verra plus tard…", "maxlength": 600}, {"name": "ton", "type": "tone_grid", "label": "Ton des réponses", "required": true, "options": ["Empathique", "Factuel", "Challenge", "Storytelling"]}]}'::jsonb WHERE slug = 'freelance-objection-handler';
UPDATE tools SET input_schema = '{"fields": [{"name": "client", "type": "text", "label": "Client", "required": true, "placeholder": "SAS GreenTech"}, {"name": "mission", "type": "text", "label": "Intitulé de la mission", "required": true, "placeholder": "Audit UX et refonte de l''application mobile"}, {"name": "periode", "type": "text", "label": "Période", "required": true, "placeholder": "Du 15 janvier au 15 mars 2025"}, {"name": "actions", "type": "textarea", "label": "Actions réalisées", "required": true, "placeholder": "Audit UX (20 interviews), wireframes, prototype Figma, tests utilisateurs, handoff dev", "maxlength": 600}, {"name": "resultats", "type": "textarea", "label": "Résultats obtenus", "required": true, "placeholder": "NPS passé de 32 à 67, temps de conversion -40%, taux de rétention +25%", "maxlength": 400}, {"name": "recommandations", "type": "textarea", "label": "Recommandations", "required": false, "placeholder": "Implémenter un chatbot, revoir le tunnel d''onboarding, A/B tester la homepage", "maxlength": 400}]}'::jsonb WHERE slug = 'freelance-rapport-mission';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet du document", "required": true, "placeholder": "Audit de performance du site e-commerce"}, {"name": "destinataire", "type": "text", "label": "Destinataire", "required": true, "placeholder": "Direction Générale de ModaShop"}, {"name": "contenu", "type": "textarea", "label": "Points clés à synthétiser", "required": true, "placeholder": "Temps de chargement 5.2s (objectif 2s), taux de conversion 1.2% (moyenne secteur 2.8%), 3 quick wins identifiés…", "maxlength": 800}, {"name": "longueur", "type": "select", "label": "Longueur", "required": true, "options": ["1/2 page", "1 page", "2 pages"]}]}'::jsonb WHERE slug = 'freelance-executive-summary';
UPDATE tools SET input_schema = '{"fields": [{"name": "activite", "type": "text", "label": "Votre activité", "required": true, "placeholder": "Développement web et conseil digital"}, {"name": "statut", "type": "select", "label": "Statut juridique", "required": true, "options": ["Auto-entrepreneur", "EURL", "SASU", "SARL", "Profession libérale"]}, {"name": "prestations", "type": "textarea", "label": "Types de prestations", "required": true, "placeholder": "Création de sites web, maintenance, formation, conseil", "maxlength": 400}, {"name": "paiement", "type": "text", "label": "Conditions de paiement", "required": true, "placeholder": "30% à la commande, 70% à la livraison, paiement à 30 jours"}]}'::jsonb WHERE slug = 'freelance-cgv';
UPDATE tools SET input_schema = '{"fields": [{"name": "client", "type": "text", "label": "Client", "required": true, "placeholder": "SAS Digital Agency"}, {"name": "facture", "type": "text", "label": "Numéro et date de facture", "required": true, "placeholder": "FA-2025-012 du 15/01/2025"}, {"name": "montant", "type": "text", "label": "Montant TTC", "required": true, "placeholder": "3 600 €"}, {"name": "retard", "type": "select", "label": "Retard", "required": true, "options": ["1ère relance (J+7)", "2ème relance (J+15)", "3ème relance (J+30)", "Dernière relance avant contentieux"]}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Courtois", "Ferme", "Factuel", "Ultimatum"]}]}'::jsonb WHERE slug = 'freelance-relance-facture';
UPDATE tools SET input_schema = '{"fields": [{"name": "nom", "type": "text", "label": "Votre nom", "required": true, "placeholder": "Sophie Martin"}, {"name": "metier", "type": "text", "label": "Votre métier", "required": true, "placeholder": "Consultante en stratégie digitale"}, {"name": "experience", "type": "textarea", "label": "Expériences clés", "required": true, "placeholder": "10 ans en marketing digital, ex-CMO startup, +50 clients accompagnés", "maxlength": 400}, {"name": "cible", "type": "text", "label": "Votre client idéal", "required": true, "placeholder": "PME tech en scale-up"}, {"name": "personnalite", "type": "text", "label": "Ce qui vous différencie", "required": true, "placeholder": "Approche data-driven, formation continue en neuromarketing"}]}'::jsonb WHERE slug = 'freelance-bio-linkedin';
UPDATE tools SET input_schema = '{"fields": [{"name": "sujet", "type": "text", "label": "Sujet / thématique", "required": true, "placeholder": "Pourquoi 80% des refontes de site échouent"}, {"name": "angle", "type": "select", "label": "Angle", "required": true, "options": ["Retour d''expérience", "Conseil actionnable", "Analyse de tendance", "Erreur à éviter", "Framework / méthode"]}, {"name": "expertise", "type": "text", "label": "Votre domaine d''expertise", "required": true, "placeholder": "UX Design & Conversion"}, {"name": "cta", "type": "text", "label": "Call-to-action", "required": true, "placeholder": "Suivez-moi pour plus de conseils UX"}, {"name": "ton", "type": "tone_grid", "label": "Ton", "required": true, "options": ["Expert", "Storytelling", "Provocateur", "Éducatif", "Personnel"]}]}'::jsonb WHERE slug = 'freelance-post-expertise';

-- ── 3. Fix any remaining bronze/silver tier names ────────────────────────────
UPDATE tools SET min_tier = 'starter' WHERE min_tier = 'bronze';
UPDATE tools SET min_tier = 'pro' WHERE min_tier = 'silver';

-- ============================================================================
-- DONE. All 100 tools should now have input_schema and render dynamically.
-- ============================================================================
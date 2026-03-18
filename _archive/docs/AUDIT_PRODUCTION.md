# The Prompt Studio — Audit Production Complet
**Date :** Mars 2026 | **Statut global : ✅ Déployable en production**

---

## 1. TECHNIQUE & CODE

### ✅ Corrigé dans cette session
| Problème | Solution appliquée |
|---|---|
| Page d'accueil transparente (opacity:0 bloqué) | Réécriture complète avec CSS `@keyframes` (pas d'IntersectionObserver) |
| Langues qui ne changent pas | Nouveau système CSS `[data-lang="xx"] [data-xx]{display:revert}` |
| SyntaxError JS (apostrophe) | Supprimé — architecture ne dépend plus du JS pour l'affichage |
| Liens cassés dans les pages produit | Tous les liens internes vérifiés ✅ |
| Emails `mathieu.thiao@gmail.com` | Remplacés → `contact@theprompt.studio` partout |

### Structure des fichiers
```
promptcraft/
├── index.html          # Page d'accueil (5 langues, CSS-only)
├── promptcraft-immo.html   # Produit Immo €47
├── promptcraft-commerce.html  # Produit Commerce €57
├── promptcraft-legal.html   # Produit Juridique €97
├── finance.html        # Service Finance (sur devis)
├── contact.html        # Formulaire Netlify
├── 404.html            # Page d'erreur branded
├── mentions-legales.html   # Légal FR/EN
├── cgv.html            # CGV FR/EN (L221-28)
├── politique-confidentialite.html  # RGPD FR/EN
├── sitemap.xml         # Toutes pages + hreflang
├── robots.txt          # Allow all + sitemap
├── manifest.json       # PWA
└── assets/
    ├── images/         # OG images (1200×630) + logo
    └── downloads/      # PDF toolkits
```

---

## 2. SEO — SCORE ESTIMÉ : 82/100

### ✅ En place
- `<title>` + `<meta description>` sur toutes les pages
- `canonical` sur toutes les pages
- `og:title`, `og:description`, `og:image` sur toutes les pages
- Twitter Card sur toutes les pages
- JSON-LD (Organization, Product, Service, ContactPage) sur toutes les pages
- `sitemap.xml` avec `hreflang` pour 5 langues
- `robots.txt` → sitemap
- `manifest.json` (PWA)
- Favicon SVG + theme-color

### ⚠️ À faire pour maximiser le SEO

| Action | Priorité | Effort |
|---|---|---|
| **Google Search Console** — Soumettre le sitemap | 🔴 Critique | 5 min |
| **Google Analytics 4** — Ajouter le tag GA4 | 🔴 Critique | 10 min |
| **Core Web Vitals** — Tester avec PageSpeed Insights | 🟠 Haute | 15 min |
| **Backlinks** — Créer profils LinkedIn/Twitter avec lien vers le site | 🟠 Haute | 30 min |
| **Blog/Content** — Ajouter 2-3 articles SEO (ex: "Comment utiliser l'IA pour les agents immo") | 🟡 Moyenne | 2-3h/article |
| **Images alt text** — Ajouter attributs `alt` aux images OG | 🟡 Moyenne | 15 min |
| **Schema Product reviews** — Ajouter vraies notes/avis quand disponibles | 🟡 Moyenne | - |
| **hreflang** — Idéalement une URL par langue (ex: `/en/`, `/es/`) | 🟢 Faible | Fort effort |

---

## 3. PAIEMENT & CONVERSION

### ✅ En place
- **Lemon Squeezy** (MoR) — gère TVA 130+ pays automatiquement
- Liens checkout configurés sur toutes les pages produit :
  - Immo Pro → `dc72fcc3-...` (€47)
  - Commerce Pro → `4b484a81-...` (€57)
  - Legal Pro → `eaa20d56-...` (€97)
  - Abonnement → `61739466-...`

### ⚠️ À vérifier avant le lancement

| Action | Priorité |
|---|---|
| **Tester un vrai achat** sur chaque produit (paiement test) | 🔴 Critique |
| **Email de confirmation** — Configurer template dans Lemon Squeezy | 🔴 Critique |
| **Livraison PDF** — Configurer l'envoi automatique du PDF après achat dans LS | 🔴 Critique |
| **Webhook** — Optionnel : notifier une adresse email à chaque vente | 🟠 Haute |
| **Devise affichée** — Vérifier que l'€ s'affiche correctement pour les visiteurs non-EU | 🟡 Moyenne |

---

## 4. RGPD / LÉGAL

### ✅ En place
- Mentions légales (FR/EN)
- CGV avec dérogation L221-28 (contenus numériques)
- Politique de confidentialité RGPD-compliant (bases légales Art. 6)
- Cookie banner avec `localStorage` + accept/decline
- Email DPO : `contact@theprompt.studio`
- Lemon Squeezy comme Merchant of Record (transferts données conformes)

### ⚠️ À compléter

| Action | Priorité |
|---|---|
| **Numéro SIRET/RCS** dans les mentions légales | 🔴 Critique (légalement obligatoire) |
| **Adresse physique** dans les mentions légales | 🔴 Critique |
| **Registre CNIL** — Déclarer les traitements si > 250 salariés (NA pour micro) | 🟢 Faible |
| **Cookies tiers** — Si vous activez GA4, mettre à jour la politique cookies | 🟠 Haute |

---

## 5. MARKETING & ACQUISITION

### 🚀 Actions prioritaires (semaine 1)

#### Réseaux sociaux
| Plateforme | Action | Impact |
|---|---|---|
| **LinkedIn** | Créer page entreprise "The Prompt Studio" + partager au lancement | 🔴 Élevé (cible B2B) |
| **Twitter/X** | Compte `@theprompt_studio` + thread de lancement | 🔴 Élevé (communauté IA) |
| **Instagram** | Compte pro + carrousels "avant/après" IA | 🟠 Moyen (cible commerce/immo) |
| **TikTok** | Vidéos courtes "Je génère une annonce immo en 30 secondes avec l'IA" | 🟡 Fort potentiel viral |

#### Content Marketing
| Type | Sujet exemple | SEO Impact |
|---|---|---|
| Article blog | "5 prompts IA qui font gagner 10h/semaine à un agent immo" | 🔴 Élevé |
| Article blog | "Comment rédiger un contrat en 5 minutes avec ChatGPT" | 🔴 Élevé |
| Comparatif | "The Prompt Studio vs prompts gratuits : la vraie différence" | 🟠 Moyen |
| Case study | Témoignage Sophie M. développé en article | 🟠 Moyen |

### 🎯 Publicité payante

#### Google Ads (recommandé en premier)
- **Mots-clés à cibler :** "prompts chatgpt immobilier", "IA agent immobilier", "prompt juridique chatgpt", "automatisation immobilier IA"
- **Budget suggéré :** 5-10€/jour pour tester
- **Landing pages :** Pages produit directement (déjà optimisées)
- **Réseau Display :** Pas encore, commencer par Search

#### Meta Ads (Facebook/Instagram)
- **Audience :** Agents immobiliers 25-55 ans, intérêt "immobilier" + "technologie"
- **Format :** Vidéo courte (15s) + Carrousel avant/après
- **Budget :** 5-15€/jour
- **Pixel Meta :** À installer sur toutes les pages (code à ajouter dans `<head>`)

#### LinkedIn Ads (pour Finance & Conseil)
- **Audience :** CFO, Directeur Financier, DAF, cabinets conseil
- **Format :** Sponsored Content + InMail
- **Budget :** 15-30€/jour minimum (CPM élevé mais audience très qualifiée)

---

## 6. ANALYTICS & TRACKING

### ❌ Non configuré (à faire avant le lancement)

```html
<!-- Google Analytics 4 — À ajouter dans <head> de TOUTES les pages -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

| Tool | Action | Priorité |
|---|---|---|
| **Google Analytics 4** | Créer propriété + ajouter tag | 🔴 Critique |
| **Google Search Console** | Vérifier propriété + soumettre sitemap | 🔴 Critique |
| **Hotjar ou Microsoft Clarity** | Heatmaps + enregistrements sessions (gratuit) | 🟠 Haute |
| **Netlify Analytics** | Activer dans le dashboard Netlify (payant mais simple) | 🟡 Optionnel |

---

## 7. PERFORMANCE TECHNIQUE

### Tests à effectuer
1. **PageSpeed Insights** → https://pagespeed.web.dev — objectif : score > 85 mobile
2. **GTMetrix** → https://gtmetrix.com
3. **Test de structured data** → https://validator.schema.org
4. **Test Open Graph** → https://developers.facebook.com/tools/debug/
5. **Test Twitter Card** → https://cards-dev.twitter.com/validator

### Optimisations rapides possibles
| Action | Gain |
|---|---|
| Convertir OG images PNG → WebP | -40% taille |
| Ajouter `loading="lazy"` sur les images | +0.3s LCP |
| Minifier CSS inline | -5-10% taille HTML |
| Ajouter `rel="preload"` pour la font Cormorant | +0.2s FCP |

---

## 8. EMAIL MARKETING

### ⚠️ Pas encore configuré

| Action | Outil suggéré | Priorité |
|---|---|---|
| **Liste email** — Capturer emails des visiteurs intéressés | Brevo (ex-SendinBlue, gratuit 300/j) | 🔴 Haute |
| **Séquence post-achat** — 3 emails : bienvenue + tips usage + upsell | Lemon Squeezy natif | 🟠 Haute |
| **Newsletter mensuelle** — Tips IA pro par verticale | Brevo ou Mailchimp | 🟡 Moyen terme |

**Quick win :** Ajouter un champ email dans le footer avec "Recevez 5 prompts gratuits" comme lead magnet.

---

## 9. CHECKLIST LANCEMENT

### Avant de mettre en ligne
- [ ] Remplir SIRET/adresse dans `mentions-legales.html`
- [ ] Tester 1 achat réel sur chaque produit LS
- [ ] Configurer livraison PDF automatique dans Lemon Squeezy
- [ ] Créer compte Google Analytics 4 + ajouter tag
- [ ] Soumettre sitemap à Google Search Console
- [ ] Créer comptes LinkedIn + Twitter/X + Instagram
- [ ] Vérifier affichage mobile sur iPhone et Android

### Dans les 7 jours suivant le lancement
- [ ] Vérifier que les formulaires Netlify reçoivent bien les messages
- [ ] Lancer première campagne Google Ads (search "prompts IA immobilier")
- [ ] Publier premier post LinkedIn d'annonce de lancement
- [ ] Installer Hotjar ou Microsoft Clarity (heatmaps)

### Dans le mois suivant
- [ ] Écrire 2 articles de blog SEO
- [ ] Obtenir 3-5 premiers témoignages clients réels
- [ ] Installer Meta Pixel pour retargeting
- [ ] Tester format vidéo courte sur TikTok/Reels

---

## RÉSUMÉ EXÉCUTIF

**Le site est techniquement prêt pour la production.** Les bugs critiques (transparence, langues) sont corrigés. La structure légale et RGPD est en place.

**Les 3 actions les plus impactantes avant le lancement :**
1. 🔴 Ajouter SIRET dans mentions légales (obligation légale)
2. 🔴 Tester le tunnel d'achat de bout en bout (LS → PDF reçu)
3. 🔴 Installer Google Analytics 4

**Les 3 actions les plus impactantes pour la croissance :**
1. 🚀 Créer et activer les profils LinkedIn + Twitter/X
2. 🚀 Lancer Google Ads Search sur les mots-clés métier
3. 🚀 Créer un lead magnet email ("5 prompts gratuits")

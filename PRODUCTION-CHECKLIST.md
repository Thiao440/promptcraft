# The Prompt Studio — Plan de mise en production

## Statut actuel du code : PRÊT (après refactor)

Le code a été audité et durci. Voici ce qui reste à faire **côté opérations** pour lancer en production.

---

## 1. ACTIONS IMMÉDIATES (avant tout déploiement)

### 1.1 Rotation des secrets
Les clés dans `.env` ont été exposées localement. **Régénérer toutes les clés :**

| Secret | Où le régénérer | Variable d'environnement |
|--------|----------------|-------------------------|
| Supabase Service Key | Supabase → Settings → API → service_role | `SUPABASE_SERVICE_KEY` |
| Anthropic API Key | console.anthropic.com → API Keys | `ANTHROPIC_API_KEY` |
| Lemon Squeezy Webhook Secret | Lemon Squeezy → Settings → Webhooks | `LS_WEBHOOK_SECRET` |

### 1.2 Variables d'environnement Netlify
Aller dans **Netlify → Site → Environment Variables** et configurer :

```
SUPABASE_URL=https://jbrloxoqtfeqvghkzupj.supabase.co
SUPABASE_SERVICE_KEY=<nouvelle clé service>
ANTHROPIC_API_KEY=<nouvelle clé>
CLAUDE_MODEL=claude-haiku-4-5-20251001
DEFAULT_MAX_TOKENS=800
LS_WEBHOOK_SECRET=<nouveau secret>
ALLOWED_ORIGIN=https://theprompt.studio
```

### 1.3 Exécuter les SQL en base
Dans Supabase SQL Editor, exécuter **dans cet ordre** :

1. `sql/SAFE-full-migration.sql` — Crée toutes les tables, colonnes, RLS, RPCs, vues admin
2. `sql/update-all-tool-schemas.sql` — Injecte les input_schema des 100 outils

---

## 2. DOMAINE & DNS

### 2.1 Configurer le domaine sur Netlify
- Netlify → Domain management → Add domain → `theprompt.studio`
- Ajouter le sous-domaine `www.theprompt.studio` → redirect vers apex
- Activer HTTPS automatique (Let's Encrypt)

### 2.2 DNS (chez votre registrar)
```
Type    Name    Value
A       @       75.2.60.5         (Netlify load balancer)
CNAME   www     theprompt.studio.
```

---

## 3. SUPABASE PRODUCTION

### 3.1 Vérifier la configuration
- [ ] **RLS activé** sur toutes les tables (le SQL le fait automatiquement)
- [ ] **Email templates** personnalisés (Supabase → Auth → Email Templates)
  - Confirmation email → branding The Prompt Studio
  - Password reset email → branding + redirect vers `/login.html`
  - Password reset → branding
- [ ] **Redirect URLs** : Auth → URL Configuration
  - Site URL : `https://theprompt.studio`
  - Redirect URLs : `https://theprompt.studio/**`
- [ ] **Rate limiting** : Auth → Rate Limits → ajuster si nécessaire

### 3.2 Auth providers
- [ ] Email/Password activé
- [ ] Authentification email + mot de passe activée
- [ ] Google OAuth (optionnel pour faciliter l'inscription)

### 3.3 Backups
- [ ] Activer les backups automatiques (Supabase → Settings → Database → Backups)
- [ ] Point-in-Time Recovery si plan Pro

---

## 4. LEMON SQUEEZY (paiements)

### 4.1 Produits à créer
Pour chaque verticale (10 verticales × 4 tiers × 2 périodes = 80 produits) :

| Verticale | Tier | Mensuel | Annuel |
|-----------|------|---------|--------|
| Immobilier | Starter | 19€/mois | 180€/an (15€/mois) |
| Immobilier | Pro | 49€/mois | 468€/an (39€/mois) |
| Immobilier | Gold | 99€/mois | 948€/an (79€/mois) |
| Immobilier | Team | 199€/mois | 1908€/an (159€/mois) |
| ... (idem pour chaque verticale) |

### 4.2 Custom data sur chaque produit
Chaque produit Lemon Squeezy doit inclure dans les custom fields :
- `tier` : starter / pro / gold / team
- `vertical` : immo / commerce / legal / finance / etc.
- `period` : monthly / yearly

### 4.3 Webhook
- URL : `https://theprompt.studio/api/webhook-ls`
- Events à activer :
  - `subscription_created`
  - `subscription_updated`
  - `subscription_cancelled`
  - `subscription_expired`
  - `subscription_payment_success`
  - `subscription_payment_failed`

### 4.4 Mettre à jour les UUIDs dans tarifs.html
Remplacer les placeholders (`IMMO_UUID_SM`, `COM_UUID_PM`, etc.) dans le fichier `tarifs.html` par les vrais UUIDs des produits Lemon Squeezy.

---

## 5. EMAILS TRANSACTIONNELS

### 5.1 Option A : Supabase Auth (déjà en place)
- Email + mot de passe pour la connexion
- Confirmation email
- Personnaliser les templates dans Supabase

### 5.2 Option B : Service tiers (recommandé pour le marketing)
Pour les emails post-achat, onboarding, relances :
- **Resend** ou **Postmark** (simple, fiable)
- Configurer un domaine d'envoi : `mail.theprompt.studio`
- DNS : ajouter les records SPF, DKIM, DMARC

### 5.3 Emails à implémenter
| Email | Déclencheur | Contenu |
|-------|------------|---------|
| Bienvenue | Après inscription | Présentation + lien dashboard |
| Abonnement confirmé | Webhook subscription_created | Récap offre + accès outils |
| Facture | Webhook payment_success | Lemon Squeezy gère automatiquement |
| Rappel essai | J+5 de l'essai gratuit | Conversion reminder |
| Résiliation | Webhook subscription_cancelled | Feedback + offre rétention |

---

## 6. MONITORING & ALERTES

### 6.1 Netlify
- [ ] Activer les notifications de deploy (email ou Slack)
- [ ] Configurer les alerts sur les fonctions (erreurs > 5%)

### 6.2 Supabase
- [ ] Dashboard → Reports → surveiller les requêtes lentes
- [ ] Configurer des alertes sur l'usage (quota base de données)

### 6.3 Anthropic
- [ ] Configurer un budget limite sur console.anthropic.com
- [ ] Alertes quand le budget atteint 80%
- [ ] Surveiller via l'onglet admin "Coûts & Usage" déjà intégré

### 6.4 Uptime monitoring
- [ ] UptimeRobot ou BetterStack (gratuit) sur `https://theprompt.studio`
- [ ] Check toutes les 5 minutes
- [ ] Alerte SMS + email en cas de downtime

---

## 7. LEGAL & CONFORMITÉ

### 7.1 Pages déjà créées
- [x] CGV (`cgv.html`)
- [x] Mentions légales (`mentions-legales.html`)
- [x] Politique de confidentialité (`politique-confidentialite.html`)

### 7.2 À vérifier/mettre à jour
- [ ] Numéro SIRET / raison sociale dans les mentions légales
- [ ] Coordonnées de l'hébergeur (Netlify + Supabase)
- [ ] DPO / contact RGPD
- [ ] Durée de conservation des données
- [ ] Bandeau cookies : déjà intégré dans index.html

---

## 8. SEO & ANALYTICS

### 8.1 Analytics
- [ ] Google Analytics 4 ou Plausible/Fathom (privacy-friendly)
- [ ] Tag sur toutes les pages (ajouter dans le `<head>`)
- [ ] Events : inscription, génération, upgrade, checkout

### 8.2 Search Console
- [ ] Ajouter `theprompt.studio` dans Google Search Console
- [ ] Soumettre le sitemap
- [ ] Vérifier l'indexation des pages verticales

### 8.3 Sitemap
- [ ] Créer `sitemap.xml` (pages statiques + pages outils)
- [ ] Référencer dans `robots.txt`

---

## 9. PERFORMANCE & SCALABILITÉ

### 9.1 Déjà en place
- [x] Headers de cache configurés (JS: 1h, assets: 1 an)
- [x] CSP activé
- [x] HSTS activé
- [x] Rate limiting par user sur les fonctions AI
- [x] Quota par verticale
- [x] Indexes DB optimisés

### 9.2 À faire quand le volume augmente
- [ ] CDN pour les assets (Netlify le fait par défaut)
- [ ] Supabase connection pooling (si > 50 connexions simultanées)
- [ ] Passer de Haiku à un modèle plus rapide si latence trop haute
- [ ] Redis pour le rate limiting distribué (si > 1 instance de fonction)

---

## 10. CHECKLIST DE LANCEMENT

### Avant le premier utilisateur
- [ ] Secrets régénérés et configurés dans Netlify
- [ ] SQL exécuté en base (SAFE-full-migration + tool schemas)
- [ ] Domaine configuré + HTTPS actif
- [ ] Lemon Squeezy : au moins 1 verticale configurée (Immobilier)
- [ ] Webhook Lemon Squeezy testé (envoyer un test event)
- [ ] Emails Supabase personnalisés
- [ ] Test complet du parcours : inscription → essai → génération → upgrade → paiement
- [ ] Page 404 fonctionnelle
- [ ] Mentions légales à jour

### Semaine 1
- [ ] Ouvrir les 3 premières verticales (Immo, Legal, Finance)
- [ ] Monitoring activé (UptimeRobot + budget Anthropic)
- [ ] Analytics installé
- [ ] Premier post LinkedIn

### Mois 1
- [ ] Ouvrir les 10 verticales
- [ ] Configurer les 80 produits Lemon Squeezy
- [ ] Mettre en place les emails de nurturing
- [ ] Analyser les premières données admin (coûts, usage, suggestions)

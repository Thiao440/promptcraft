# Configuration Supabase + Netlify Functions
## Guide d'installation — The Prompt Studio

**Durée estimée : 30-45 minutes**

---

## ÉTAPE 1 — Créer votre projet Supabase (5 min)

1. Aller sur **https://supabase.com** → "Start your project" → se connecter avec GitHub
2. Cliquer "New project"
   - **Name :** `the-prompt-studio`
   - **Database Password :** générer un mot de passe fort (le noter)
   - **Region :** `West EU (Ireland)` (le plus proche de vos utilisateurs FR)
3. Attendre ~2 minutes que le projet se crée

---

## ÉTAPE 2 — Créer la base de données (5 min)

1. Dans Supabase, aller dans **SQL Editor** (icône code à gauche)
2. Cliquer "New query"
3. Copier-coller **l'intégralité du fichier `supabase-schema.sql`** de votre projet
4. Cliquer **Run** (bouton vert)
5. Vérifier que vous voyez "Success. No rows returned" — c'est normal.

---

## ÉTAPE 3 — Créer le bucket de fichiers (5 min)

1. Dans Supabase, aller dans **Storage** (icône bucket à gauche)
2. Cliquer "New bucket"
   - **Name :** `downloads`
   - **Public bucket :** **NON** (laisser désactivé — bucket privé)
3. Cliquer "Save"
4. Ouvrir le bucket `downloads`
5. **Uploader vos 3 PDF** (drag & drop) :
   - `ImmoPrompts_Pack_AgentImmo_Pro.pdf`
   - `PromptCraft_Commerce_Pro.pdf`
   - `PromptCraft_Legal_Pro.pdf`

---

## ÉTAPE 4 — Récupérer vos clés API Supabase (2 min)

1. Dans Supabase, aller dans **Settings → API** (icône engrenage)
2. Copier ces 3 valeurs :
   - **Project URL** → ex: `https://abcdefgh.supabase.co`
   - **anon public key** → clé longue qui commence par `eyJ...`
   - **service_role key** → ⚠️ clé SECRÈTE à ne JAMAIS mettre dans le front-end

---

## ÉTAPE 5 — Configurer les variables d'environnement Netlify (5 min)

1. Aller sur **https://app.netlify.com** → votre site → **Site settings → Environment variables**
2. Ajouter ces variables une par une (cliquer "Add variable") :

| Variable | Valeur |
|---|---|
| `SUPABASE_URL` | Votre Project URL (ex: `https://abcdefgh.supabase.co`) |
| `SUPABASE_SERVICE_KEY` | Votre `service_role` key ⚠️ SECRÈTE |
| `LS_WEBHOOK_SECRET` | Voir Étape 6 ci-dessous |
| `SITE_URL` | `https://theprompt.studio` |

3. Après avoir ajouté toutes les variables, cliquer **"Trigger deploy"** pour relancer un déploiement avec les nouvelles variables.

---

## ÉTAPE 6 — Configurer le webhook Lemon Squeezy (5 min)

1. Dans **Lemon Squeezy** → Settings → **Webhooks**
2. Cliquer "Add webhook"
   - **URL :** `https://theprompt.studio/api/webhook-ls`
   - **Events à cocher :**
     - ✅ `order_created`
     - ✅ `subscription_created`
     - ✅ `subscription_cancelled`
     - ✅ `subscription_expired`
     - ✅ `order_refunded`
   - **Signing secret :** Cliquer "Generate" → copier la valeur générée
3. Copier ce "Signing secret" → le coller dans la variable `LS_WEBHOOK_SECRET` sur Netlify (Étape 5)
4. Cliquer "Save"

---

## ÉTAPE 7 — Mettre à jour le code front-end (5 min)

Dans votre éditeur de code (ou demander à Claude), remplacer `VOTRE_SUPABASE_URL` et `VOTRE_SUPABASE_ANON_KEY` dans ces fichiers :

- `login.html` (ligne ~70)
- `dashboard.html` (ligne ~120)
- `index.html` (bas du fichier)

Remplacer par vos vraies valeurs :
```javascript
const SUPABASE_URL  = 'https://abcdefgh.supabase.co';  // votre URL
const SUPABASE_ANON = 'eyJhbGci...';                   // votre anon key
```

⚠️ La clé `anon` est **publique** → OK de la mettre dans le front-end.
⚠️ La clé `service_role` est **SECRÈTE** → uniquement dans les variables Netlify.

---

## ÉTAPE 8 — Configurer l'email de connexion Supabase (5 min)

1. Dans Supabase → **Authentication → Email Templates**
2. Cliquer sur "Magic Link"
3. Personnaliser l'email :

**Sujet :** `Votre lien d'accès à The Prompt Studio`

**Corps :**
```html
<h2>Bienvenue sur The Prompt Studio</h2>
<p>Cliquez sur le bouton ci-dessous pour accéder à votre espace :</p>
<a href="{{ .ConfirmationURL }}" style="background:#c9a84c;color:#0c0b09;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:600;">
  Accéder à mon espace →
</a>
<p style="color:#666;font-size:12px;margin-top:20px;">Ce lien expire dans 1 heure.</p>
```

4. Dans **Authentication → URL Configuration** :
   - **Site URL :** `https://theprompt.studio`
   - **Redirect URLs :** Ajouter `https://theprompt.studio/dashboard`

---

## ÉTAPE 9 — Déployer et tester (10 min)

### Déploiement
```bash
cd ~/Documents/promptcraft
git add -A
git commit -m "feat: Supabase auth + user dashboard + protected downloads"
git push
```

### Test complet du flow
1. **Simuler un webhook** : Dans LS → Webhooks → cliquer "Send test" sur `order_created`
2. Vérifier dans Supabase → Table Editor → `user_products` qu'une ligne a été créée
3. Vérifier dans Supabase → Authentication → Users qu'un utilisateur a été créé
4. Aller sur `https://theprompt.studio/login` → entrer l'email → vérifier la réception du magic link
5. Cliquer le magic link → vérifier la redirection vers `/dashboard`
6. Cliquer "Télécharger le PDF" → vérifier le téléchargement

---

## Architecture Finale

```
VISITEUR
  │
  ├─→ Clique "Acheter Immo Pro" sur la page produit
  │   URL: theprompt-studio.lemonsqueezy.com/checkout/buy/dc72fcc3-...?checkout[custom][slug]=immo
  │
  └─→ LEMON SQUEEZY (checkout sécurisé, gère TVA)
        │
        └─→ Paiement réussi → Webhook POST /api/webhook-ls
              │
              └─→ NETLIFY FUNCTION (webhook-ls.js)
                    1. Vérifie signature HMAC ✓
                    2. Crée utilisateur Supabase Auth
                    3. Insère dans user_products (slug: 'immo')
                    4. Génère magic link → envoie email
                    │
                    └─→ CLIENT reçoit email "Accédez à votre toolkit"
                          │
                          └─→ Clique magic link → /dashboard?welcome=immo
                                │
                                └─→ DASHBOARD
                                      GET /api/user-products (JWT vérifié)
                                      ↳ Affiche produits achetés
                                      ↳ Bouton "Télécharger PDF"
                                            │
                                            └─→ GET /api/download?file=ImmoPrompts...
                                                  1. Vérifie JWT ✓
                                                  2. Vérifie accès dans DB ✓
                                                  3. Génère URL signée Supabase Storage (60s)
                                                  4. Retourne URL → navigateur déclenche le download
```

---

## Résolution des problèmes fréquents

**"Invalid signature" dans les logs Netlify**
→ Vérifier que `LS_WEBHOOK_SECRET` correspond exactement au "Signing secret" dans LS

**L'utilisateur ne reçoit pas l'email**
→ Dans Supabase → Authentication → Logs → vérifier les erreurs d'envoi
→ En production, configurer un serveur SMTP custom (Resend, Brevo) dans Supabase → Settings → Auth → SMTP

**"Storage object not found" lors du téléchargement**
→ Vérifier que les fichiers PDF sont bien uploadés dans le bucket `downloads` avec le bon nom

**Les functions Netlify ne se déploient pas**
→ Vérifier que `netlify/functions/` est bien le chemin (case-sensitive)
→ Vérifier dans Netlify → Functions → logs

---

## Évolutions possibles

| Fonctionnalité | Effort | Description |
|---|---|---|
| **Espace membres complet** | Moyen | Ajouter forum, ressources exclusives, vidéos |
| **Affiliate program** | Moyen | Lemon Squeezy a un système d'affiliation natif |
| **Multi-langues dashboard** | Faible | Appliquer le même système `[data-lang]` au dashboard |
| **Notifications email** | Faible | Supabase peut envoyer des emails lors de mises à jour |
| **API rate limiting** | Moyen | Ajouter rate limiting sur les fonctions download |
| **Analytics ventes** | Moyen | Dashboard admin dans Supabase Studio |

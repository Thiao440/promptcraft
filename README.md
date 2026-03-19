# The Prompt Studio

**SaaS IA vertical — 100 outils pour 10 métiers**

[theprompt.studio](https://theprompt.studio)

## Stack

- Frontend : HTML/CSS/JS vanilla (zero framework)
- Backend : Netlify Functions (Node.js)
- Base de données : Supabase (PostgreSQL + Auth + RLS)
- IA : Anthropic Claude API (serveur uniquement)
- Paiements : Lemon Squeezy (webhooks)

## Structure

```
├── index.html                    → Landing page (multilingue FR/EN/ES/PT/AR)
├── tarifs.html                   → Pricing (4 tiers × 10 verticales)
├── dashboard.html                → Espace utilisateur (outils + projets)
├── tool.html                     → Page outil dynamique (100 outils)
├── project.html                  → Détail projet CRM
├── admin.html                    → Admin (10 onglets analytics)
├── js/
│   ├── ps-auth.js                → Auth, sessions, feature gating, trial
│   ├── ps-tool.js                → Génération IA, résultat, historique
│   ├── ps-projects.js            → CRM projets (CRUD, prefill)
│   ├── ps-feedback.js            → Bug reports, suggestions d'outils
│   ├── ps-ads.js                 → Système publicitaire (Starter only)
│   ├── ps-analytics.js           → Event tracking client
│   ├── ps-chat-widget.js         → Chatbot IA (free + expert)
│   ├── ps-lang.js                → Système multilingue
│   ├── tool-catalog.js           → Chargement catalogue outils
│   └── tool-renderer.js          → Rendu dynamique formulaires
├── netlify/functions/
│   ├── ai-tool.js                → Proxy Claude pour outils
│   ├── ai-chat.js                → Proxy Claude pour chatbot
│   ├── webhook-ls.js             → Webhooks Lemon Squeezy
│   └── download.js               → Téléchargements sécurisés
├── sql/
│   ├── SAFE-full-migration.sql   → Migration complète (idempotente)
│   ├── analytics-complete.sql    → Tables + vues analytics
│   └── update-all-tool-schemas.sql → 100 outils input_schema
└── catalog/
    ├── tool-catalog-data.json    → Référence des 100 outils
    └── tool-schemas.json         → Schemas des formulaires
```

## Offres

| Tier | Prix | Highlights |
|------|------|-----------|
| Starter | 19€/mois | 3 outils, 50 gen/mois, avec pub |
| Pro | 49€/mois | 7 outils, chatbots IA, sans pub |
| Gold | 99€/mois | 10 outils, CRM, illimité, sans pub |
| Team | 199€/mois | 3 verticales, API, automatisations |

## Déploiement

Push sur `main` → déploiement automatique Netlify.

Variables d'environnement requises : voir `PRODUCTION-CHECKLIST.md`.

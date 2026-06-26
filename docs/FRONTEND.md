# Frontend Angular — MedNova UI

## Structure (architecture entreprise)

```
mednova-ui/src/app/
├── core/                 # Singletons : auth, interceptors, guards, modèles
│   ├── guards/
│   ├── interceptors/
│   ├── models/
│   └── services/
├── shared/               # Composants réutilisables (à étendre)
├── layout/               # Shell applicatif (sidebar, topbar)
├── features/             # Modules fonctionnels lazy-loaded
│   ├── auth/login/
│   ├── dashboard/
│   ├── patients/
│   ├── doctors/
│   ├── appointments/
│   └── audit/
└── app.routes.ts         # Routing + guards RBAC
```

## Développement local

Prérequis : Node.js 22+, backend gateway sur `http://localhost:8080`.

```bash
cd mednova-ui
npm install
npm start
```

Application : http://localhost:4200

Comptes de test (mot de passe **`password123`**) — créés automatiquement au démarrage de `auth-service` :

| Rôle | Email |
|------|-------|
| Admin | `admin@mednova.ai` |
| Médecin | `dr.smith@mednova.ai` |
| Infirmier(ère) | `nurse@mednova.ai` |
| Patient | `patient.test@mednova.ai` |
| Auditeur | `auditor@mednova.ai` |

> Si la connexion échoue, **redémarrez auth-service** (les comptes sont créés par `DemoUserSeeder` s'ils n'existent pas).

## Build production

```bash
npm run build -- --configuration production
```

Sortie : `dist/mednova-ui/browser/`

En production, `apiBaseUrl` = `/api/v1` (proxy Nginx vers le gateway).

## Déploiement Docker

```bash
# Stack complète (infra + microservices + UI)
docker compose -f docker-compose.yml -f docker-compose.apps.yml up --build -d
```

UI accessible sur **http://localhost:4200** — Nginx sert l'Angular et proxifie `/api/` vers `api-gateway:8080`.

### Déploiement en ligne (VPS / cloud)

1. Build et push de l'image :
   ```bash
   docker build -t mednova-ui ./mednova-ui
   ```
2. Déployer avec la stack backend (même réseau Docker que `api-gateway`).
3. Exposer le port 80/443 (HTTPS recommandé via Traefik, Caddy ou un load balancer).
4. Variables : aucune côté frontend en prod (proxy Nginx intégré).

Alternative **statique** (Netlify, Vercel, S3+CloudFront) :
- Build avec `apiBaseUrl` pointant vers l'URL publique du gateway, ex. `https://api.votredomaine.com/api/v1`
- Modifier `environment.prod.ts` avant le build.

## Fonctionnalités implémentées

- Login JWT + support 2FA (challenge TOTP)
- Guards `authGuard` et `roleGuard` (RBAC aligné backend)
- Intercepteurs HTTP (token Bearer, déconnexion sur 401)
- Pages : dashboard, patients, médecins, rendez-vous, audit
- Lazy loading des features
- Dockerfile multi-stage (Node build + Nginx)

## Prochaines étapes suggérées

- Formulaires CRUD patients / RDV
- WebSocket monitoring (`/ws/**`)
- i18n (fr/en)
- Tests e2e (Playwright / Cypress)

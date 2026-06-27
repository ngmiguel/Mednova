# MedNova AI — Mobile

Application Flutter connectée à l'API Gateway MedNova (`/api/v1`).

## Prérequis

- Flutter SDK 3.11+
- Backend MedNova en cours d'exécution (port **8080**)

```bash
# Depuis la racine du monorepo
docker compose up --build -d
# ou Windows : .\scripts\docker\up.ps1 -Build
```

## Lancement

```bash
cd mednova_mobile
flutter pub get
flutter run
```

### URL API par plateforme

| Plateforme | Base URL |
|------------|----------|
| Android émulateur | `http://10.0.2.2:8080/api/v1` |
| iOS simulateur / desktop | `http://localhost:8080/api/v1` |

Configuration : `lib/core/config/app_config.dart`

## Architecture

```
lib/
├── core/           # config, theme, network, storage, animations 3D
├── domain/         # interfaces repositories
├── data/           # modèles + implémentations API
└── presentation/   # Riverpod, GoRouter, features, shared widgets
```

**State management :** Riverpod  
**Navigation :** GoRouter + shell RBAC  
**HTTP :** Dio + intercepteur JWT

## Comptes démo

Mot de passe : `password123`

| Rôle | Email |
|------|-------|
| Admin | admin@mednova.ai |
| Médecin | dr.smith@mednova.ai |
| Infirmier | nurse@mednova.ai |
| Patient | patient.test@mednova.ai |
| Auditeur | auditor@mednova.ai |

## Modules

- **Dashboard** — stats rapides + accès modules
- **Patients / Médecins** — listes avec fiche détaillée (bottom sheet)
- **Messagerie** — contacts role-based + chat avec polling 4 s
- **IA Prédictive** — évaluations de risque par patient
- **Admin** — blocage accès utilisateur depuis la fiche (ROLE_ADMIN)

## Analyse

```bash
flutter analyze
flutter test
```

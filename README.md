# MedNova AI

> Plateforme intelligente de gestion médicale prédictive — architecture microservices Spring Boot

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.1-green.svg)](https://spring.io/projects/spring-boot)

## Description

MedNova AI est une plateforme de santé capable de :

- Centraliser les dossiers patients
- Analyser les données médicales en temps réel
- Détecter les anomalies et prédire les risques (Health Risk Engine)
- Gérer les rendez-vous et le planning médical
- Surveiller les patients via WebSocket
- Générer des alertes et notifications automatiques

## Architecture

```
API Gateway (8080)  ← Point d'entrée unique
    ├── Auth Service          (8081)  ✅
    ├── Patient Service       (8082)  ✅
    ├── Doctor Service        (8083)  ✅
    ├── Appointment Service   (8084)  ✅
    ├── Monitoring Service    (8085)  ✅
    ├── AI Prediction Service (8086)  ✅
    ├── Notification Service  (8087)  ✅
    └── Audit Service         (8088)  ✅
```

## Stack technique

| Catégorie | Technologies |
|-----------|-------------|
| Backend | Spring Boot 3.4, Spring Cloud Gateway, Spring Security JWT |
| Base de données | PostgreSQL 16 (port 5433) |
| Cache | Redis 7 |
| Messaging | Apache Kafka 7.6 |
| Temps réel | WebSocket (STOMP) |
| API Docs | Swagger / OpenAPI 3 |
| Conteneurisation | Docker, Kubernetes |
| Architecture | Clean Architecture, DDD, Event-Driven |

## Structure du projet

```
mednova-ai/
├── common-lib/              # Bibliothèque partagée (exceptions, DTOs, events)
├── api-gateway/             # Point d'entrée unique — routage, JWT, rate limiting
├── auth-service/            # Authentification JWT + RBAC
├── patient-service/         # Gestion patients
├── doctor-service/          # Gestion médecins
├── appointment-service/     # Rendez-vous
├── monitoring-service/      # Monitoring temps réel
├── ai-prediction-service/   # Health Risk Engine
├── notification-service/    # Alertes et emails
├── audit-service/           # Logs d'audit conformité
├── docker-compose.yml       # Infrastructure locale
└── docs/                    # Documentation
    ├── API.md               # Documentation des endpoints
    └── ARCHITECTURE.md      # Diagrammes et flux événementiels
```

Chaque microservice suit la **Clean Architecture** :

```
src/main/java/com/mednova/{service}/
├── domain/          # Modèles métier, ports
├── application/     # Use cases
├── infrastructure/  # JPA, Kafka, Redis, config
└── presentation/    # Controllers REST, DTOs, mappers
```

## Rôles et permissions (RBAC)

MedNova utilise un contrôle d'accès basé sur les rôles (**RBAC**). À l'inscription ou à la connexion, l'utilisateur reçoit un **JWT** contenant son rôle. L'**API Gateway** valide le token et propage l'identité vers chaque microservice via les headers :

| Header | Description |
|--------|-------------|
| `X-User-Id` | UUID de l'utilisateur connecté |
| `X-User-Roles` | Rôle(s) RBAC (ex. `ROLE_DOCTOR`) |
| `Authorization` | `Bearer <JWT>` (fourni par le client) |

Chaque microservice applique ses propres règles via un `*AccessGuard` (Clean Architecture).

### Les 5 rôles

| Rôle | Qui est-ce ? | Mission principale |
|------|--------------|-------------------|
| `ROLE_ADMIN` | Administrateur système | Gestion complète de la plateforme : création de comptes médecins, suppressions, supervision globale |
| `ROLE_DOCTOR` | Médecin | Soins cliniques : consultation des dossiers, enregistrement des constantes vitales, gestion de ses propres rendez-vous et de son planning |
| `ROLE_NURSE` | Infirmier(ère) | Support clinique : saisie des constantes vitales, gestion des rendez-vous, mise à jour des dossiers patients |
| `ROLE_PATIENT` | Patient | Accès à son propre dossier médical, ses constantes vitales, ses rendez-vous et ses notifications personnelles |
| `ROLE_AUDITOR` | Auditeur conformité | **Lecture seule** : contrôle et traçabilité des actions (journal d'audit Kafka), sans intervention clinique |

### Authentification renforcée

- **2FA TOTP** : Google Authenticator / Authy (`/api/v1/auth/2fa/*`)
- **Mot de passe oublié** : OTP par email simulé + réinitialisation (`/api/v1/auth/password/*`)

### Détail par rôle

#### `ROLE_ADMIN` — Administrateur

Responsable de l'exploitation et de la gouvernance de la plateforme.

- Créer et supprimer des profils **médecins**
- Créer, modifier et **supprimer** des dossiers **patients**
- Créer, modifier, confirmer, annuler et **supprimer** des **rendez-vous**
- Enregistrer des **constantes vitales** (monitoring)
- Consulter les **évaluations de risque AI**, les **notifications staff** et le **journal d'audit**
- Accès le plus large du système (lecture + écriture + suppressions)

#### `ROLE_DOCTOR` — Médecin

Intervient sur le plan clinique pour les patients dont il a la charge.

- Consulter la **liste** et les **dossiers patients**
- Enregistrer des **constantes vitales** et consulter le monitoring (REST + WebSocket)
- Consulter les **alertes d'anomalies** et les **évaluations de risque AI**
- Lire et gérer **ses propres rendez-vous** (modifier, annuler, confirmer)
- Modifier **son propre profil médecin** et gérer **son propre planning**
- Recevoir les **notifications staff** (alertes santé, anomalies vitals, RDV)
- **Ne peut pas** : créer un profil médecin, supprimer un patient, planifier un RDV en tant que médecin (réservé au patient, infirmier ou admin)

#### `ROLE_NURSE` — Infirmier(ère)

Assiste l'équipe médicale au quotidien.

- Consulter la **liste** et les **dossiers patients**
- **Créer et modifier** des dossiers patients
- Enregistrer des **constantes vitales** et consulter le monitoring (REST + WebSocket)
- Consulter les **alertes d'anomalies** et les **évaluations de risque AI**
- **Créer, modifier, annuler et confirmer** des rendez-vous (tous les RDV)
- Gérer le **planning** des médecins (disponibilités)
- Recevoir les **notifications staff**
- **Ne peut pas** : créer un profil médecin, supprimer un patient ou un RDV

#### `ROLE_PATIENT` — Patient

Utilisateur final qui consulte ses propres informations de santé.

- Lire **son propre dossier patient** (pas la liste complète)
- Consulter **ses constantes vitales** et s'abonner au flux WebSocket de **son patient**
- Consulter **ses propres rendez-vous** et en **créer** de nouveaux
- Modifier ou **annuler ses propres rendez-vous**
- Consulter **ses évaluations de risque AI** (liées à son compte)
- Recevoir les **notifications patient** (confirmations et annulations de RDV)
- **Ne peut pas** : voir les dossiers d'autres patients, enregistrer des vitals, consulter les alertes staff, accéder au journal d'audit

#### `ROLE_AUDITOR` — Auditeur

Profil de **conformité et traçabilité** (contrôleur interne, responsable qualité, DPO technique). Il **observe** le système sans jamais modifier les données médicales.

- Consulter le **journal d'audit** Kafka (`/api/v1/audit/events`) — accès exclusif avec l'admin
- Lire les **dossiers patients** et la **liste des patients**
- Consulter le **monitoring**, les **alertes d'anomalies** et les **évaluations de risque AI**
- Recevoir les **notifications staff** (lecture uniquement)
- **Ne peut pas** : créer, modifier ou supprimer quoi que ce soit (patients, RDV, vitals, médecins)

> En production, le rôle auditeur est typiquement attribué à un service conformité / sécurité, distinct de l'équipe soignante.

### Matrice des permissions par service

Légende : ✅ autorisé · 🔒 limité (ses propres données) · ❌ refusé

#### Patients (`/api/v1/patients/**`)

| Action | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|--------|:-----:|:------:|:-----:|:-------:|:-------:|
| Lister les patients | ✅ | ✅ | ✅ | ❌ | ✅ |
| Lire un dossier | ✅ | ✅ | ✅ | 🔒 | ✅ |
| Créer / modifier | ✅ | ✅ | ✅ | ❌ | ❌ |
| Supprimer | ✅ | ❌ | ❌ | ❌ | ❌ |

#### Médecins (`/api/v1/doctors/**`)

| Action | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|--------|:-----:|:------:|:-----:|:-------:|:-------:|
| Lire les profils | ✅ | ✅ | ✅ | ✅ | ✅ |
| Créer un médecin | ✅ | ❌ | ❌ | ❌ | ❌ |
| Modifier un profil | ✅ | 🔒 | ❌ | ❌ | ❌ |
| Gérer le planning | ✅ | 🔒 | ✅ | ❌ | ❌ |
| Supprimer | ✅ | ❌ | ❌ | ❌ | ❌ |

#### Rendez-vous (`/api/v1/appointments/**`)

| Action | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|--------|:-----:|:------:|:-----:|:-------:|:-------:|
| Lire un RDV | ✅ | 🔒 | ✅ | 🔒 | ✅ |
| Créer un RDV | ✅ | ❌ | ✅ | ✅ | ❌ |
| Modifier / annuler | ✅ | 🔒 | ✅ | 🔒 | ❌ |
| Confirmer | ✅ | 🔒 | ✅ | ❌ | ❌ |
| Supprimer | ✅ | ❌ | ❌ | ❌ | ❌ |

#### Monitoring (`/api/v1/monitoring/**` + WebSocket)

| Action | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|--------|:-----:|:------:|:-----:|:-------:|:-------:|
| Enregistrer des vitals | ✅ | ✅ | ✅ | ❌ | ❌ |
| Lire les vitals | ✅ | ✅ | ✅ | 🔒 | ✅ |
| WebSocket temps réel | ✅ | ✅ | ✅ | 🔒 | ✅ |
| Alertes anomalies | ✅ | ✅ | ✅ | ❌ | ✅ |

#### AI Prediction (`/api/v1/ai/**`)

| Action | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|--------|:-----:|:------:|:-----:|:-------:|:-------:|
| Lire les évaluations de risque | ✅ | ✅ | ✅ | 🔒 | ✅ |

#### Notifications (`/api/v1/notifications/**`)

| Cible | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|-------|:-----:|:------:|:-----:|:-------:|:-------:|
| Notifications **staff** (alertes santé, anomalies, RDV équipe) | ✅ | ✅ | ✅ | ❌ | ✅ |
| Notifications **patient** (confirmations / annulations RDV) | ❌ | ❌ | ❌ | ✅ | ❌ |

#### Audit (`/api/v1/audit/**`)

| Action | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|--------|:-----:|:------:|:-----:|:-------:|:-------:|
| Consulter le journal Kafka | ✅ | ❌ | ❌ | ❌ | ✅ |

### Créer un compte avec un rôle

Lors de l'inscription, le rôle est choisi dans le champ `role` :

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "auditeur@mednova.ai",
    "password": "password123",
    "firstName": "Alice",
    "lastName": "Martin",
    "role": "ROLE_AUDITOR"
  }'
```

**Rôles disponibles :** `ROLE_ADMIN`, `ROLE_DOCTOR`, `ROLE_NURSE`, `ROLE_PATIENT`, `ROLE_AUDITOR`

## Prérequis

- Java 21+
- Maven 3.9+
- Docker & Docker Compose
- Git

## Démarrage rapide

```bash
# 1. Cloner le projet
git clone https://github.com/ngmiguel/mednova-ai.git
cd mednova-ai

# 2. Copier les variables d'environnement
cp .env.example .env

# 3. Lancer l'infrastructure Docker
docker compose up -d

# 4. Compiler le projet
mvn clean install -DskipTests

# 5. Lancer Auth Service
mvn -pl auth-service spring-boot:run

# 6. Lancer API Gateway (dans un autre terminal)
mvn -pl api-gateway spring-boot:run

# 7. Lancer Patient Service (dans un autre terminal)
mvn -pl patient-service spring-boot:run

# 8. Lancer Doctor Service (dans un autre terminal)
mvn -pl doctor-service spring-boot:run

# 9. Lancer Appointment Service (dans un autre terminal)
mvn -pl appointment-service spring-boot:run

# 10. Lancer Monitoring Service (dans un autre terminal)
mvn -pl monitoring-service spring-boot:run

# 11. Lancer Audit Service (dans un autre terminal)
mvn -pl audit-service spring-boot:run

# 12. Lancer AI Prediction Service (dans un autre terminal)
mvn -pl ai-prediction-service spring-boot:run

# 13. Lancer Notification Service (dans un autre terminal)
mvn -pl notification-service spring-boot:run
```

## Documentation API

| Ressource | URL |
|-----------|-----|
| **Swagger UI (agrégé)** | http://localhost:8080/swagger-ui.html |
| **Auth Service direct** | http://localhost:8081/swagger-ui.html |
| **Documentation complète** | [docs/API.md](docs/API.md) |
| **Health Gateway** | http://localhost:8080/actuator/health |
| **Health Auth** | http://localhost:8081/actuator/health |

### Test rapide via Gateway

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@mednova.ai","password":"password123","firstName":"Jean","lastName":"Dupont","role":"ROLE_PATIENT"}'

# Créer un patient (avec token médecin)
curl -X POST http://localhost:8080/api/v1/patients \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Marie","lastName":"Dupont","dateOfBirth":"1990-05-15","bloodType":"A_POSITIVE"}'
```

## Infrastructure Docker

| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL | **5433** | 8 bases (1 par microservice) |
| Redis | 6379 | Cache, sessions JWT, rate limiting |
| Kafka | 9092 | Messaging événementiel |
| Zookeeper | 2181 | Coordination Kafka |

> PostgreSQL utilise le port **5433** pour éviter les conflits avec une installation locale sur 5432.

## Branches

| Branche | Rôle |
|---------|------|
| `main` | Code stable, production-ready |
| `develop` | Intégration continue des features |

## Roadmap

- [x] Initialisation du projet et structure multi-module
- [x] Bibliothèque commune (`common-lib`)
- [x] Infrastructure Docker (PostgreSQL, Redis, Kafka)
- [x] Auth Service (JWT + RBAC)
- [x] API Gateway (routage, JWT, rate limiting, Swagger)
- [x] Patient Service
- [x] Doctor Service
- [x] Appointment Service
- [x] Monitoring Service + WebSocket
- [x] Kafka Event-Driven Architecture
- [x] AI Prediction Service (Health Risk Engine)
- [x] Notification Service
- [x] Audit Service (consumer Kafka + journal)
- [x] Tests + CI/CD

## Tests et CI/CD

### Lancer les tests localement

```bash
# Suite complète (Linux / Git Bash / CI)
./scripts/test/run-all.sh

# Windows PowerShell
.\scripts\test\run-all.ps1

# Un module précis
./scripts/test/test-module.sh auth-service

# Windows
.\scripts\test\test-module.ps1 -Module auth-service
```

### Scripts par module

| Script | Description |
|--------|-------------|
| `test-build.sh` | Compile tous les modules (`mvn package -DskipTests`) |
| `test-module.sh <module>` | **Tous** les tests du module (+ common-lib via `-am`) |
| `run-all.sh` | Build + tests des **10 modules** |

Modules testés : `common-lib`, `api-gateway`, `auth-service`, `patient-service`, `doctor-service`, `appointment-service`, `monitoring-service`, `ai-prediction-service`, `notification-service`, `audit-service`.

### Couverture actuelle (~36 tests unitaires)

| Module | Classes testées |
|--------|-----------------|
| `common-lib` | `BaseEventTest` |
| `api-gateway` | `GatewayJwtServiceTest` |
| `auth-service` | `TotpServiceTest` |
| `patient-service` | `GatewayUserAuthenticationTest`, `PatientAccessGuardTest` |
| `doctor-service` | `DoctorAccessGuardTest` |
| `appointment-service` | `AppointmentAccessGuardTest`, `AppointmentTest` |
| `monitoring-service` | `AnomalyDetectionServiceTest` |
| `ai-prediction-service` | `HealthRiskEngineTest` |
| `notification-service` | `DomainEventHandlerTest` |
| `audit-service` | `AuditAccessGuardTest`, `AuditIngestionServiceTest` |

### Pipeline GitHub Actions

Le workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) s'exécute sur chaque push/PR vers `main` et `develop` :

1. JDK 21 (Temurin) + cache Maven
2. `./scripts/test/run-all.sh` — build puis tests unitaires par catégorie
3. **Ne plus utiliser** `mvn clean verify` seul (échoue si des JAR sont verrouillés localement)

### Configuration email (SMTP)

Voir le guide complet : [docs/EMAIL.md](docs/EMAIL.md)

```env
MAIL_ENABLED=true
MAIL_HOST=smtp.gmail.com
MAIL_USERNAME=votre.email@gmail.com
MAIL_PASSWORD=mot-de-passe-application
MAIL_STAFF_ALERT_TO=medecin@mednova.ai
```

## Frontend Angular (`mednova-ui`)

Application SPA Angular 19 — structure entreprise (core / features / layout), déployable via Docker + Nginx.

```bash
cd mednova-ui && npm install && npm start   # dev → http://localhost:4200
```

Guide complet : [docs/FRONTEND.md](docs/FRONTEND.md)

## Déploiement Docker (stack complète)

Une seule commande lance l'infrastructure, tous les microservices et l'interface Angular :

```bash
docker compose up --build -d
```

```powershell
# Windows — avec vérification automatique de la connexion
.\scripts\docker\up.ps1 -Build

# Réinitialiser toutes les données (volumes PostgreSQL, Redis, Kafka)
.\scripts\docker\up.ps1 -Build -ResetVolumes
```

| URL | Description |
|-----|-------------|
| http://localhost:4200 | Interface Angular (Nginx → Gateway) |
| http://localhost:8080 | API Gateway |
| http://localhost:8080/swagger-ui.html | Swagger |

**Comptes démo** (mot de passe `password123`) : `admin@mednova.ai`, `dr.smith@mednova.ai`, `nurse@mednova.ai`, `patient.test@mednova.ai`, `auditor@mednova.ai`

Les données sont persistées dans les volumes Docker (`mednova-postgres-data`, `mednova-redis-data`, etc.). Guide complet : [docs/DOCKER.md](docs/DOCKER.md)

```bash
# Vérifier la gateway
curl http://localhost:8080/actuator/health

# Démo du flux complet
.\scripts\demo-flow.ps1

# Arrêter (conserver les données)
docker compose down

# Arrêter et supprimer les volumes
docker compose down -v
```

> Le premier build Docker peut prendre 15–20 min (compilation Maven par service).
> En développement, on garde souvent l'infra Docker + les services lancés via `mvn spring-boot:run`.

## Documentation

| Document | Description |
|----------|-------------|
| [docs/API.md](docs/API.md) | Endpoints REST détaillés |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Diagrammes, flux Kafka, Clean Architecture |
| [scripts/demo-flow.ps1](scripts/demo-flow.ps1) | Démo automatisée vitals → AI → notification → audit |

## Roadmap — Phase 2

- [x] Containerisation Docker des microservices
- [x] Documentation architecture + script de démo
- [ ] Manifests Kubernetes
- [ ] Tests d'intégration (Testcontainers)
- [ ] Extraction `GatewayUserAuthentication` dans `common-lib`

## Auteur

**ngmiguel** — [GitHub](https://github.com/ngmiguel)

## Licence

Ce projet est sous licence [MIT](LICENSE).

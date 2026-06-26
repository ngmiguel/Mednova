# MedNova AI — Déploiement Docker

## Démarrage rapide (stack complète)

```powershell
# Premier lancement (build + volumes persistants)
.\scripts\docker\up.ps1 -Build

# Réinitialiser toutes les données (PostgreSQL, Redis, Kafka)
.\scripts\docker\up.ps1 -Build -ResetVolumes
```

```bash
docker compose up --build -d
./scripts/docker/wait-for-services.sh   # si disponible
```

## URLs

| Service | URL |
|---------|-----|
| Interface Angular | http://localhost:4200 |
| API Gateway | http://localhost:8080 |
| Swagger | http://localhost:8080/swagger-ui.html |
| PostgreSQL | localhost:5433 |

## Comptes démo

Mot de passe commun : **`password123`**

| Email | Rôle |
|-------|------|
| admin@mednova.ai | Administrateur |
| dr.smith@mednova.ai | Médecin |
| nurse@mednova.ai | Infirmier(ère) |
| patient.test@mednova.ai | Patient |
| auditor@mednova.ai | Auditeur |

Les comptes sont créés automatiquement par :

1. **Flyway** (`V3__seed_demo_users.sql`) au premier démarrage
2. **`DemoUserSeeder`** à chaque démarrage d'`auth-service` (resynchronise le mot de passe)

## Volumes persistants

| Volume Docker | Contenu |
|---------------|---------|
| `mednova-postgres-data` | Bases PostgreSQL (auth, patient, doctor, …) |
| `mednova-redis-data` | Sessions JWT, OTP, rate limiting |
| `mednova-kafka-data` | Topics et messages Kafka |
| `mednova-zookeeper-data` | Métadonnées Zookeeper |

Les données survivent à `docker compose down`. Pour repartir de zéro :

```powershell
docker compose down -v
.\scripts\docker\up.ps1 -Build
```

## Dockerfiles

Chaque microservice possède son propre `Dockerfile` (contexte de build = racine du dépôt) :

```
auth-service/Dockerfile
patient-service/Dockerfile
...
mednova-ui/Dockerfile
```

Regénérer les Dockerfiles Java :

```powershell
.\scripts\docker\generate-dockerfiles.ps1
```

## Dépannage connexion

```powershell
# Vérifier les logs auth
docker logs mednova-auth --tail 50

# Tester l'API directement
.\scripts\docker\verify-login.ps1

# Vérifier les utilisateurs en base
docker exec mednova-postgres psql -U mednova -d auth_db -c "SELECT email, enabled, two_factor_enabled FROM users;"
```

Si la connexion échoue après une ancienne installation, réinitialisez les volumes :

```powershell
.\scripts\docker\up.ps1 -Build -ResetVolumes
```

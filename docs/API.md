# Documentation API — MedNova AI

> Point d'entrée unique : **http://localhost:8080**
> Swagger UI agrégé : **http://localhost:8080/swagger-ui.html**

## Architecture des routes

Toutes les requêtes client passent par l'**API Gateway** (port 8080) qui route vers les microservices internes.

```
Client → API Gateway (:8080) → Microservice (:808x)
```

## Headers propagés

| Header | Description | Ajouté par |
|--------|-------------|------------|
| `X-Correlation-Id` | Traçabilité distribuée | Gateway |
| `X-User-Id` | UUID de l'utilisateur connecté | Gateway (après validation JWT) |
| `X-User-Roles` | Rôles RBAC (séparés par virgule) | Gateway (après validation JWT) |
| `Authorization` | Bearer JWT | Client |

## Routes configurées

| Préfixe Gateway | Service cible | Port interne | Statut |
|-----------------|---------------|--------------|--------|
| `/api/v1/auth/**` | auth-service | 8081 | ✅ Implémenté |
| `/api/v1/patients/**` | patient-service | 8082 | ✅ Implémenté |
| `/api/v1/doctors/**` | doctor-service | 8083 | ✅ Implémenté |
| `/api/v1/appointments/**` | appointment-service | 8084 | ✅ Implémenté |
| `/api/v1/monitoring/**` | monitoring-service | 8085 | ✅ Implémenté |
| `/ws/**` | monitoring-service (WebSocket STOMP) | 8085 | ✅ Implémenté |
| `/api/v1/ai/**` | ai-prediction-service | 8086 | ✅ Implémenté |
| `/api/v1/notifications/**` | notification-service | 8087 | ✅ Implémenté |
| `/api/v1/audit/**` | audit-service | 8088 | ✅ Implémenté |

## Endpoints publics (sans JWT)

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/2fa/verify-login`
- `POST /api/v1/auth/password/forgot`
- `POST /api/v1/auth/password/verify-otp`
- `POST /api/v1/auth/password/reset`
- `GET /actuator/health`
- `GET /swagger-ui.html`
- `GET /v3/api-docs/**`

Tous les autres endpoints nécessitent un header `Authorization: Bearer <token>`.

## Auth Service — Endpoints

### Inscription
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "dr.smith@mednova.ai",
  "password": "password123",
  "firstName": "John",
  "lastName": "Smith",
  "role": "ROLE_DOCTOR"
}
```

**Rôles disponibles :** `ROLE_ADMIN`, `ROLE_DOCTOR`, `ROLE_NURSE`, `ROLE_PATIENT`, `ROLE_AUDITOR`

### Connexion
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "dr.smith@mednova.ai",
  "password": "password123"
}
```

**Réponse :**
```json
{
  "success": true,
  "message": "Connexion réussie",
  "data": {
    "accessToken": "eyJhbG...",
    "refreshToken": "uuid.uuid",
    "tokenType": "Bearer",
    "expiresIn": 900,
    "roles": ["ROLE_DOCTOR"]
  },
  "timestamp": "2026-06-24T10:00:00Z",
  "correlationId": "abc-123"
}
```

### Profil utilisateur
```http
GET /api/v1/auth/me
Authorization: Bearer <accessToken>
```

### Rafraîchir le token
```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "<refreshToken>"
}
```

### Déconnexion
```http
POST /api/v1/auth/logout
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "refreshToken": "<refreshToken>"
}
```

### Double authentification (2FA TOTP)

Compatible **Google Authenticator** / Authy. Flux en 3 étapes :

**1. Activer la 2FA** (utilisateur connecté)
```http
POST /api/v1/auth/2fa/setup
Authorization: Bearer <accessToken>
```
Réponse : `secret`, `otpAuthUrl`, `qrCodeBase64` (scanner le QR dans l'app)

```http
POST /api/v1/auth/2fa/enable
Authorization: Bearer <accessToken>
Content-Type: application/json

{ "code": "123456" }
```

**2. Connexion avec 2FA**
```http
POST /api/v1/auth/login
{ "email": "...", "password": "..." }
```
Si 2FA activée → `requiresTwoFactor: true` + `challengeToken` (pas de JWT)

```http
POST /api/v1/auth/2fa/verify-login
{ "challengeToken": "...", "code": "123456" }
```
→ Retourne les tokens JWT habituels.

**3. Désactiver**
```http
POST /api/v1/auth/2fa/disable
Authorization: Bearer <accessToken>
{ "code": "123456", "password": "password123" }
```

### Mot de passe oublié (OTP email)

Même mécanisme OTP que la 2FA, réutilisé pour la réinitialisation :

```http
POST /api/v1/auth/password/forgot
{ "email": "user@mednova.ai" }
```
→ Code 6 chiffres envoyé par email (simulé dans les logs serveur)

```http
POST /api/v1/auth/password/verify-otp
{ "email": "user@mednova.ai", "otp": "123456" }
```
→ Retourne `resetToken` (valide 15 min)

```http
POST /api/v1/auth/password/reset
{ "resetToken": "...", "newPassword": "nouveauMotDePasse123" }
```

## Patient Service — Endpoints

> Nécessite un JWT valide. Le rôle détermine les permissions (voir tableau ci-dessous).

### Permissions RBAC

| Action | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|--------|-------|--------|-------|---------|---------|
| Lister patients | ✅ | ✅ | ✅ | ❌ | ✅ |
| Voir un patient | ✅ | ✅ | ✅ | Son dossier | ✅ |
| Créer / modifier | ✅ | ✅ | ✅ | ❌ | ❌ |
| Supprimer | ✅ | ❌ | ❌ | ❌ | ❌ |

### CRUD Patient

```http
POST   /api/v1/patients
GET    /api/v1/patients?page=0&size=20
GET    /api/v1/patients/{id}
PUT    /api/v1/patients/{id}
DELETE /api/v1/patients/{id}
```

**Exemple création :**
```json
{
  "firstName": "Marie",
  "lastName": "Dupont",
  "email": "marie.dupont@email.com",
  "phone": "+33612345678",
  "dateOfBirth": "1990-05-15",
  "bloodType": "A_POSITIVE",
  "gender": "F",
  "address": "12 rue de la Santé, Paris",
  "emergencyContact": "Jean Dupont — +33698765432"
}
```

**Types sanguins :** `A_POSITIVE`, `A_NEGATIVE`, `B_POSITIVE`, `B_NEGATIVE`, `AB_POSITIVE`, `AB_NEGATIVE`, `O_POSITIVE`, `O_NEGATIVE`

### Dossier médical

```http
GET    /api/v1/patients/{patientId}/medical-records
POST   /api/v1/patients/{patientId}/medical-records
GET    /api/v1/patients/{patientId}/medical-records/{recordId}
```

### Traitements

```http
GET    /api/v1/patients/{patientId}/treatments
POST   /api/v1/patients/{patientId}/treatments
```

### Allergies

```http
GET    /api/v1/patients/{patientId}/allergies
POST   /api/v1/patients/{patientId}/allergies
DELETE /api/v1/patients/{patientId}/allergies/{allergyId}
```

**Sévérités allergie :** `LOW`, `MODERATE`, `HIGH`, `CRITICAL`

## Doctor Service — Endpoints

### Permissions RBAC

| Action | ADMIN | DOCTOR | NURSE | PATIENT | AUDITOR |
|--------|-------|--------|-------|---------|---------|
| Lister / voir médecins | ✅ | ✅ | ✅ | ✅ | ✅ |
| Créer / supprimer médecin | ✅ | ❌ | ❌ | ❌ | ❌ |
| Modifier profil | ✅ | Son profil | ❌ | ❌ | ❌ |
| Gérer disponibilités | ✅ | Son planning | ✅ | ❌ | ❌ |

### CRUD Médecin

```http
POST   /api/v1/doctors
GET    /api/v1/doctors?specialty=CARDIOLOGY&page=0&size=20
GET    /api/v1/doctors/{id}
PUT    /api/v1/doctors/{id}
DELETE /api/v1/doctors/{id}
```

**Spécialités :** `GENERAL_PRACTICE`, `CARDIOLOGY`, `NEUROLOGY`, `PEDIATRICS`, `ONCOLOGY`, `DERMATOLOGY`, `ORTHOPEDICS`, `PSYCHIATRY`, `RADIOLOGY`, `SURGERY`

**Exemple création :**
```json
{
  "userId": "3868e111-77f6-4a2f-a615-c29eb06f4227",
  "firstName": "John",
  "lastName": "Smith",
  "email": "dr.smith@mednova.ai",
  "phone": "+33612345678",
  "specialty": "CARDIOLOGY",
  "licenseNumber": "MED-FR-2024-001",
  "bio": "Cardiologue spécialisé en prévention"
}
```

### Disponibilités

```http
GET    /api/v1/doctors/{doctorId}/availabilities
POST   /api/v1/doctors/{doctorId}/availabilities
DELETE /api/v1/doctors/{doctorId}/availabilities/{availabilityId}
```

**Exemple créneau :**
```json
{
  "dayOfWeek": "MONDAY",
  "startTime": "09:00",
  "endTime": "17:00"
}
```

## Appointment Service — Endpoints

### Rendez-vous

```http
POST   /api/v1/appointments
GET    /api/v1/appointments?patientId={uuid}&doctorId={uuid}&status=SCHEDULED&page=0&size=20
GET    /api/v1/appointments/{id}
PUT    /api/v1/appointments/{id}
PATCH  /api/v1/appointments/{id}/cancel
PATCH  /api/v1/appointments/{id}/confirm
DELETE /api/v1/appointments/{id}
```

**Statuts :** `SCHEDULED`, `CONFIRMED`, `CANCELLED`, `COMPLETED`, `NO_SHOW`

**Exemple planification (ADMIN / infirmier) :**
```json
{
  "patientId": "uuid-du-patient",
  "doctorId": "uuid-du-medecin",
  "patientUserId": "uuid-utilisateur-patient",
  "doctorUserId": "3868e111-77f6-4a2f-a615-c29eb06f4227",
  "scheduledAt": "2026-07-01T10:00:00Z",
  "durationMinutes": 30,
  "reason": "Consultation de suivi",
  "notes": "Première visite"
}
```

**RBAC :**
- **Planifier** : PATIENT (pour soi), ADMIN, NURSE
- **Lire** : concernés (patient/médecin), ADMIN, NURSE, AUDITOR
- **Modifier / annuler** : patient ou médecin concerné, ADMIN, NURSE
- **Confirmer** : médecin concerné, ADMIN, NURSE
- **Supprimer** : ADMIN uniquement

## Monitoring Service — Endpoints

### Constantes vitales (REST)

```http
POST   /api/v1/monitoring/vitals
GET    /api/v1/monitoring/vitals/{id}
GET    /api/v1/monitoring/patients/{patientId}/vitals?page=0&size=20
GET    /api/v1/monitoring/patients/{patientId}/vitals/latest
GET    /api/v1/monitoring/alerts
```

**Exemple enregistrement (médecin / infirmier) :**
```json
{
  "patientId": "70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6",
  "patientUserId": "efce145f-4523-4dc0-8768-423022d70505",
  "heartRate": 130,
  "systolicBp": 145,
  "diastolicBp": 95,
  "temperature": 37.2,
  "oxygenSaturation": 96
}
```

### WebSocket STOMP (temps réel)

| Élément | Valeur |
|---------|--------|
| **URL via Gateway** | `ws://localhost:8080/ws` |
| **Protocole** | STOMP over WebSocket |
| **Auth** | Header `Authorization: Bearer <token>` lors du handshake HTTP |

**Topics :**
| Topic | Description | Accès |
|-------|-------------|-------|
| `/topic/patients/{patientId}/vitals` | Nouvelles mesures d'un patient | Staff ou patient concerné |
| `/topic/monitoring/alerts` | Alertes anomalies | Staff uniquement |

**Exemple abonnement (JavaScript avec @stomp/stompjs) :**
```javascript
import { Client } from '@stomp/stompjs';

const client = new Client({
  brokerURL: 'ws://localhost:8080/ws',
  connectHeaders: { Authorization: 'Bearer ' + token },
  onConnect: () => {
    client.subscribe('/topic/patients/' + patientId + '/vitals', msg => {
      console.log(JSON.parse(msg.body));
    });
    client.subscribe('/topic/monitoring/alerts', msg => {
      console.log('ALERTE', JSON.parse(msg.body));
    });
  }
});
client.activate();
```

**Détection d'anomalies (seuils par défaut) :**
- Fréquence cardiaque : 50–120 bpm
- Pression systolique : 90–180 mmHg
- Pression diastolique : 60–110 mmHg
- Température : 35.0–38.5 °C
- SpO2 : minimum 92 %

## Architecture événementielle Kafka

### Topic central

| Topic | Description |
|-------|-------------|
| `mednova.domain.events` | Tous les événements métier (enveloppe `BaseEvent`) |

### Producteurs

| Service | Événements publiés |
|---------|-------------------|
| **patient-service** | `PATIENT_CREATED` |
| **appointment-service** | `APPOINTMENT_SCHEDULED`, `APPOINTMENT_CANCELLED` |
| **monitoring-service** | `VITALS_RECORDED`, `VITALS_ANOMALY_DETECTED` |
| **ai-prediction-service** | `RISK_ASSESSMENT_COMPLETED`, `HEALTH_ALERT_TRIGGERED` |

### Consommateurs

| Service | Rôle |
|---------|------|
| **audit-service** | Persiste chaque événement dans `audit_db` |
| **ai-prediction-service** | Consomme `VITALS_RECORDED` → calcule le score de risque |

### Enveloppe événement

```json
{
  "eventId": "uuid",
  "eventType": "VITALS_RECORDED",
  "version": "1.0",
  "timestamp": "2026-06-24T15:00:00Z",
  "source": "monitoring-service",
  "correlationId": "uuid",
  "payload": { }
}
```

## Audit Service — Endpoints

```http
GET /api/v1/audit/events?eventType=VITALS_ANOMALY_DETECTED&page=0&size=20
```

**Accès :** `ROLE_ADMIN`, `ROLE_AUDITOR`

## AI Prediction Service — Endpoints

```http
GET /api/v1/ai/risk-assessments/{id}
GET /api/v1/ai/patients/{patientId}/risk-assessments?page=0&size=20
GET /api/v1/ai/patients/{patientId}/risk-assessments/latest
```

**Niveaux de risque :** `LOW`, `MODERATE`, `HIGH`, `CRITICAL`

**Déclenchement automatique :** à chaque événement Kafka `VITALS_RECORDED`, le Health Risk Engine calcule un score (0–100) et publie `RISK_ASSESSMENT_COMPLETED`. Si le risque est `HIGH` ou `CRITICAL`, un `HEALTH_ALERT_TRIGGERED` est également émis.

**Exemple réponse :**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "patientId": "uuid",
    "riskScore": 75,
    "riskLevel": "HIGH",
    "factors": ["Anomalie détectée sur les constantes vitales", "Tachycardie (130 bpm)"],
    "recommendation": "Surveillance rapprochée et consultation médicale dans les 24h"
  }
}
```

**RBAC :** lecture par staff médical, auditeur, ou patient concerné.

## Notification Service — Endpoints

```http
GET /api/v1/notifications?patientId={uuid}&status=UNREAD&type=HEALTH_ALERT&page=0&size=20
GET /api/v1/notifications/{id}
GET /api/v1/notifications/unread-count
PATCH /api/v1/notifications/{id}/read
```

**Types :** `HEALTH_ALERT`, `VITALS_ANOMALY`, `APPOINTMENT_SCHEDULED`, `APPOINTMENT_CANCELLED`

**Déclenchement automatique (Kafka consumer) :**

| Événement entrant | Action |
|-------------------|--------|
| `HEALTH_ALERT_TRIGGERED` | Alerte staff + email simulé |
| `VITALS_ANOMALY_DETECTED` | Alerte staff in-app |
| `APPOINTMENT_SCHEDULED` | Notification staff + patient |
| `APPOINTMENT_CANCELLED` | Notification staff + patient |

Après création, le service publie `NOTIFICATION_SENT` sur Kafka.

**RBAC :** staff médical voit les notifications `STAFF` ; les patients voient les notifications `ROLE_PATIENT`.

## Format d'erreur standard

```json
{
  "timestamp": "2026-06-24T10:00:00Z",
  "status": 404,
  "error": "NOT_FOUND",
  "message": "Patient not found with id: xxx",
  "path": "/api/v1/patients/xxx",
  "correlationId": "abc-123",
  "details": null
}
```

## Rate limiting

| Route | Limite | Clé |
|-------|--------|-----|
| `/api/v1/auth/**` | 30 req/s, burst 50 | Adresse IP |

## Swagger par service

| Service | URL OpenAPI via Gateway |
|---------|------------------------|
| Auth | http://localhost:8080/v3/api-docs/auth |
| Patient | http://localhost:8080/v3/api-docs/patient |
| Doctor | http://localhost:8080/v3/api-docs/doctor |
| Appointment | http://localhost:8080/v3/api-docs/appointment |
| Monitoring | http://localhost:8080/v3/api-docs/monitoring |
| Audit | http://localhost:8080/v3/api-docs/audit |
| AI | http://localhost:8080/v3/api-docs/ai |
| Notification | http://localhost:8080/v3/api-docs/notification |
| Gateway | http://localhost:8080/v3/api-docs/gateway |

## Démarrage local

```bash
# 1. Infrastructure
docker compose up -d

# 2. Auth Service
mvn -pl auth-service spring-boot:run

# 3. API Gateway
mvn -pl api-gateway spring-boot:run

# 4. Patient Service (autre terminal)
mvn -pl patient-service spring-boot:run

# 5. Tester via Gateway
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dr.smith@mednova.ai","password":"password123"}'
```

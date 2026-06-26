# Configuration email — MedNova AI

## Vue d'ensemble

| Service | Usage email |
|---------|-------------|
| **auth-service** | OTP mot de passe oublié → email de l'utilisateur |
| **notification-service** | Alertes santé CRITICAL/HIGH → `MAIL_STAFF_ALERT_TO` |

Par défaut (`MAIL_ENABLED=false`), les emails sont **loggés** dans la console (mode dev).

---

## Ce que vous devez compléter

### 1. Copier `.env.example` vers `.env`

```bash
cp .env.example .env
```

### 2. Activer l'envoi réel

```env
MAIL_ENABLED=true
```

### 3. Renseigner le serveur SMTP

#### Option A — Gmail (recommandé pour tests)

1. Activer la **validation en 2 étapes** sur votre compte Google  
   https://myaccount.google.com/security

2. Créer un **mot de passe d'application**  
   https://myaccount.google.com/apppasswords  
   (Application : « Mail », Appareil : « MedNova »)

3. Configurer `.env` :

```env
MAIL_ENABLED=true
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre.email@gmail.com
MAIL_PASSWORD=xxxx xxxx xxxx xxxx
MAIL_FROM=MedNova AI <votre.email@gmail.com>
MAIL_STARTTLS=true
MAIL_STAFF_ALERT_TO=votre.email@gmail.com
```

> `MAIL_PASSWORD` = le mot de passe d'application (16 caractères), **pas** votre mot de passe Gmail.

#### Option B — Outlook / Microsoft 365

```env
MAIL_HOST=smtp.office365.com
MAIL_PORT=587
MAIL_USERNAME=votre.email@outlook.com
MAIL_PASSWORD=votre-mot-de-passe
MAIL_FROM=MedNova AI <votre.email@outlook.com>
```

#### Option C — SendGrid, Mailgun, Brevo…

Utilisez les identifiants SMTP fournis par votre prestataire (`MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`).

---

## Variables d'environnement

| Variable | Obligatoire si `MAIL_ENABLED=true` | Description |
|----------|-------------------------------------|-------------|
| `MAIL_ENABLED` | — | `true` = SMTP réel, `false` = logs console |
| `MAIL_HOST` | ✅ | Serveur SMTP (ex. `smtp.gmail.com`) |
| `MAIL_PORT` | — | Défaut `587` |
| `MAIL_USERNAME` | ✅ | Identifiant SMTP |
| `MAIL_PASSWORD` | ✅ | Mot de passe / app password |
| `MAIL_FROM` | — | Expéditeur affiché |
| `MAIL_STARTTLS` | — | `true` par défaut |
| `MAIL_STAFF_ALERT_TO` | Pour alertes | Email qui reçoit les alertes santé |

---

## Lancer avec emails réels

### Maven (local)

```powershell
# PowerShell — charger .env puis démarrer auth-service
Get-Content .env | ForEach-Object {
  if ($_ -match '^([^#=]+)=(.*)$') { Set-Item -Path "env:$($matches[1])" -Value $matches[2] }
}
mvn -pl auth-service spring-boot:run
```

### Docker Compose

Les variables `MAIL_*` du fichier `.env` à la racine sont lues automatiquement par Docker Compose.  
Ajoutez-les dans `docker-compose.apps.yml` (déjà configuré pour `auth-service` et `notification-service`).

---

## Tester

### OTP mot de passe oublié

```http
POST http://localhost:8080/api/v1/auth/password/forgot
{ "email": "votre.email@gmail.com" }
```

→ Vérifiez votre boîte mail (ou les logs si `MAIL_ENABLED=false`).

### Alerte santé (email staff)

1. Configurer `MAIL_STAFF_ALERT_TO`
2. Lancer le flux démo : `.\scripts\demo-flow.ps1`
3. Une alerte CRITICAL déclenche un email vers `MAIL_STAFF_ALERT_TO`

---

## Dépannage

| Problème | Solution |
|----------|----------|
| `Authentication failed` | Vérifiez mot de passe d'application (Gmail) |
| `Could not connect to SMTP` | Vérifiez `MAIL_HOST` / `MAIL_PORT` / pare-feu |
| Pas d'email alerte | Vérifiez `MAIL_STAFF_ALERT_TO` |
| Emails en log seulement | `MAIL_ENABLED` doit être `true` |

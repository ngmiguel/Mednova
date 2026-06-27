# MedNova AI — Application mobile Flutter

Application **Android & iOS** (`mednova_mobile/`) connectée à l'API Gateway MedNova.

## Prérequis

| Outil | Version | Plateforme |
|-------|---------|------------|
| Flutter SDK | 3.11+ | Tous |
| Android Studio + SDK | API 24+ | Android |
| Xcode | 15+ | iOS (macOS uniquement) |
| CocoaPods | 1.14+ | iOS |
| Backend MedNova | port **8080** | Mode API (optionnel en mode démo) |

## Guide rapide

### 1. Démarrer le backend (mode API)

Depuis la **racine du dépôt** :

```bash
docker compose up --build -d
```

```powershell
# Windows
.\scripts\docker\up.ps1 -Build
```

Vérifier la gateway :

```bash
curl http://localhost:8080/actuator/health
```

### 2. Installer les dépendances Flutter

```bash
cd mednova_mobile
flutter pub get
```

**iOS (première fois, macOS) :**

```bash
cd ios && pod install && cd ..
```

### 3. Lancer l'application

#### Mode démo (sans backend)

Sur l'écran de connexion, appuyez sur un **chip démo** (Admin, Médecin, Patient, etc.) ou connectez-vous avec :

- Mot de passe : `password123`
- Emails : `admin@mednova.ai`, `dr.smith@mednova.ai`, `patient.test@mednova.ai`, …

Les données sont chargées localement (`DemoCatalog`).

#### Mode API — Android

```bash
flutter run --flavor dev
```

| Contexte | URL API (automatique ou `--dart-define`) |
|----------|------------------------------------------|
| Émulateur Android | `http://10.0.2.2:8080/api/v1` |
| Appareil physique | `--dart-define=API_BASE_URL=http://<IP_LAN>:8080/api/v1` |

Exemple appareil physique :

```bash
flutter run --flavor dev --dart-define=API_BASE_URL=http://192.168.1.42:8080/api/v1
```

#### Mode API — iOS

```bash
flutter run -d ios
```

| Contexte | URL API |
|----------|---------|
| Simulateur iOS | `http://localhost:8080/api/v1` |
| iPhone physique | `--dart-define=API_BASE_URL=http://<IP_LAN>:8080/api/v1` |

#### Production

```bash
flutter run --flavor prod \
  --dart-define=APP_ENV=prod \
  --dart-define=API_BASE_URL=https://api.mednova.ai/api/v1
```

## Builds release

### Android

```bash
flutter build apk --flavor prod --release \
  --dart-define=APP_ENV=prod \
  --dart-define=API_BASE_URL=https://api.mednova.ai/api/v1

flutter build appbundle --flavor prod --release \
  --dart-define=APP_ENV=prod \
  --dart-define=API_BASE_URL=https://api.mednova.ai/api/v1
```

Configurez un keystore dans `android/app/build.gradle.kts` (`signingConfigs`).

### iOS (macOS + certificat Apple Developer)

```bash
flutter build ipa --release \
  --dart-define=APP_ENV=prod \
  --dart-define=API_BASE_URL=https://api.mednova.ai/api/v1
```

## Identifiants natifs

| Plateforme | Application ID |
|------------|----------------|
| Android prod | `com.mednova.mednovaMobile` |
| Android dev | `com.mednova.mednovaMobile.dev` |
| iOS | `com.mednova.mednovaMobile` |

## Flavors Android

| Flavor | Usage | HTTP local |
|--------|-------|------------|
| `dev` | Développement | Autorisé (émulateur / LAN) |
| `prod` | Production | Désactivé (HTTPS requis) |

Toujours spécifier `--flavor dev` ou `--flavor prod` pour Android.

## Configuration Dart

Fichier central : `lib/core/config/platform_config.dart`

| Variable | Exemple |
|----------|---------|
| `API_BASE_URL` | `http://192.168.1.10:8080/api/v1` |
| `APP_ENV` | `dev` ou `prod` |

## VS Code

Configurations prêtes dans `mednova_mobile/.vscode/launch.json` :

- MedNova · Android (dev)
- MedNova · Android (prod)
- MedNova · iOS
- MedNova · Chrome (web)

## Dépannage

### NDK Android corrompu

```
NDK at ... did not have a source.properties file
```

Supprimez le dossier NDK indiqué et réinstallez-le via Android Studio → SDK Manager → NDK.

### Connexion refusée sur appareil physique

- Vérifiez que le backend écoute sur `0.0.0.0:8080` (Docker le fait par défaut).
- Utilisez l'**IP LAN** de votre PC, pas `localhost`.
- Autorisez le port 8080 dans le pare-feu Windows.

### iOS — pods manquants

```bash
cd mednova_mobile/ios
pod deintegrate && pod install
```

## Architecture

```
mednova_mobile/lib/
├── core/config/      # app_config, platform_config
├── core/platform/    # bootstrap, secure storage
├── domain/
├── data/             # repositories + demo_catalog
└── presentation/     # Riverpod, GoRouter, features
```

Stockage sécurisé : **EncryptedSharedPreferences** (Android) · **Keychain** (iOS).

## Modules

Dashboard analytique, Patients, Médecins, RDV, IA prédictive, Messagerie, Notifications, Audit, Paramètres — navigation filtrée par **RBAC**.

Voir aussi : [README racine](../README.md) · [DOCKER.md](DOCKER.md)

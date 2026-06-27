# MedNova AI — Mobile (Android & iOS)

Application Flutter **multiplateforme** connectée à l'API Gateway MedNova.

> **Guide complet (backend + mobile) :** [README racine](../README.md#guide-de-lancement-complet) · [docs/MOBILE.md](../docs/MOBILE.md)

## Prérequis

| Outil | Version |
|-------|---------|
| Flutter SDK | 3.11+ |
| Android Studio / SDK | API 24+ (Android 7.0) |
| Xcode (macOS) | 15+ pour builds iOS |
| CocoaPods | 1.14+ (iOS) |
| Backend MedNova | port **8080** (optionnel en mode démo) |

## Démarrage en 3 commandes

```bash
# 1. Backend (depuis la racine du dépôt)
docker compose up --build -d

# 2. Dépendances Flutter
cd mednova_mobile && flutter pub get

# 3. Lancer (Android)
flutter run --flavor dev
```

**Mode démo sans backend :** chips sur l'écran de connexion ou `password123` avec les emails démo.

## Installation iOS (macOS, première fois)

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

## Lancement détaillé

### Android

```bash
flutter run --flavor dev
flutter run --flavor prod --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.mednova.ai/api/v1
```

### iOS

```bash
flutter run -d ios
```

### Appareil physique

```bash
flutter run --flavor dev --dart-define=API_BASE_URL=http://192.168.1.42:8080/api/v1
```

## URL API par plateforme

| Contexte | URL |
|----------|-----|
| Android émulateur | `http://10.0.2.2:8080/api/v1` |
| iOS simulateur | `http://localhost:8080/api/v1` |
| Appareil physique | `--dart-define=API_BASE_URL=http://<IP>:8080/api/v1` |

Config : `lib/core/config/platform_config.dart`

## Builds release

```bash
# Android APK
flutter build apk --flavor prod --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.mednova.ai/api/v1

# Android App Bundle
flutter build appbundle --flavor prod --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.mednova.ai/api/v1

# iOS IPA (macOS)
flutter build ipa --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.mednova.ai/api/v1
```

## Identifiants natifs

| Plateforme | Application ID |
|------------|----------------|
| Android prod | `com.mednova.mednovaMobile` |
| Android dev | `com.mednova.mednovaMobile.dev` |
| iOS | `com.mednova.mednovaMobile` |

## Comptes démo

Mot de passe : `password123`

| Rôle | Email |
|------|-------|
| Admin | admin@mednova.ai |
| Médecin | dr.smith@mednova.ai |
| Infirmier | nurse@mednova.ai |
| Patient | patient.test@mednova.ai |
| Auditeur | auditor@mednova.ai |

## VS Code

Configurations dans `.vscode/launch.json` (Android dev/prod, iOS, Chrome).

## Analyse

```bash
flutter analyze
flutter test
```

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Platform-tuned secure storage (EncryptedSharedPreferences on Android, Keychain on iOS).
FlutterSecureStorage createSecureStorage() {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'MedNovaSecureStorage',
    ),
  );
}

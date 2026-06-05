import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Хранилище для чувствительных данных (пароли, биометрические креды).
///
/// Раньше пароль лежал в GetStorage открытым текстом. Здесь используется
/// платформенное шифрованное хранилище (Keystore/Keychain). При первом
/// запуске после обновления выполняется миграция старых значений из
/// GetStorage и их удаление оттуда.
class SecureStorageService extends GetxService {
  static const _kPassword = 'auth_password';
  static const _kBioUsername = 'bio_username';
  static const _kBioPassword = 'bio_password';

  // Старые ключи в GetStorage (plaintext) — для одноразовой миграции
  static const _legacyPasswordKey = 'password';
  static const _legacyBiometricKey = 'biometric_credentials';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Завершается, когда одноразовая миграция из GetStorage закончена.
  /// Потребители (BiometricService) должны дождаться её перед чтением.
  late final Future<void> ready;

  @override
  void onInit() {
    super.onInit();
    ready = _migrateFromGetStorage();
  }

  // ========================================
  // ПАРОЛЬ (для refresh-токена)
  // ========================================

  Future<void> writePassword(String value) =>
      _storage.write(key: _kPassword, value: value);

  Future<String?> readPassword() => _storage.read(key: _kPassword);

  Future<void> deletePassword() => _storage.delete(key: _kPassword);

  // ========================================
  // БИОМЕТРИЧЕСКИЕ КРЕДЫ
  // ========================================

  Future<void> writeBiometricCredentials(
      String username, String password) async {
    await _storage.write(key: _kBioUsername, value: username);
    await _storage.write(key: _kBioPassword, value: password);
  }

  Future<Map<String, String>?> readBiometricCredentials() async {
    final username = await _storage.read(key: _kBioUsername);
    final password = await _storage.read(key: _kBioPassword);
    if (username == null || password == null) return null;
    return {'username': username, 'password': password};
  }

  Future<void> deleteBiometricCredentials() async {
    await _storage.delete(key: _kBioUsername);
    await _storage.delete(key: _kBioPassword);
  }

  /// Полная очистка чувствительных данных (logout / сброс сессии)
  Future<void> clearAll() async {
    await deletePassword();
    await deleteBiometricCredentials();
  }

  // ========================================
  // МИГРАЦИЯ ИЗ GetStorage (одноразовая)
  // ========================================

  Future<void> _migrateFromGetStorage() async {
    try {
      final gs = GetStorage();

      // Пароль
      final legacyPassword = gs.read(_legacyPasswordKey);
      if (legacyPassword is String && legacyPassword.isNotEmpty) {
        if (await readPassword() == null) {
          await writePassword(legacyPassword);
        }
        await gs.remove(_legacyPasswordKey);
      }

      // Биометрические креды ({username, password})
      final legacyBio = gs.read(_legacyBiometricKey);
      if (legacyBio is Map) {
        final username = legacyBio['username'];
        final password = legacyBio['password'];
        if (username is String && password is String) {
          if (await readBiometricCredentials() == null) {
            await writeBiometricCredentials(username, password);
          }
        }
        await gs.remove(_legacyBiometricKey);
      }
    } catch (e) {
      // Миграция не критична: при неудаче пользователь просто залогинится заново
      // ignore: avoid_print
      print('[SECURE STORAGE] Migration error: $e');
    }
  }
}

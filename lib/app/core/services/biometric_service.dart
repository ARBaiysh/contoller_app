import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get_storage/get_storage.dart';

class BiometricService extends GetxService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final GetStorage _storage = GetStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricCredentialsKey = 'biometric_credentials';

  @override
  void onInit() {
    super.onInit();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    try {
      await isDeviceSupported;
      await isBiometricAvailable;
      await availableBiometrics;
    } catch (e) {
      // Игнорируем ошибки при инициализации
    }
  }

  Future<bool> get isDeviceSupported async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<bool> get isBiometricAvailable async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await this.isDeviceSupported;
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  bool get isBiometricEnabled {
    return _storage.read(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(_biometricEnabledKey, enabled);
  }

  Future<void> saveBiometricCredentials(String username, String password) async {
    await _storage.write(_biometricCredentialsKey, {
      'username': username,
      'password': password,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Map<String, dynamic>? get savedCredentials {
    return _storage.read(_biometricCredentialsKey);
  }

  Future<void> clearBiometricCredentials() async {
    await _storage.remove(_biometricCredentialsKey);
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      if (!isBiometricEnabled) {
        return false;
      }

      final bool isAvailable = await isBiometricAvailable;
      if (!isAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Подтвердите свою личность для входа в приложение',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      _handlePlatformException(e);
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setupBiometricAuth(String username, String password) async {
    try {
      final bool isAvailable = await isBiometricAvailable;
      if (!isAvailable) {
        Get.snackbar(
          'Биометрия недоступна',
          'На этом устройстве биометрическая аутентификация не поддерживается',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Подтвердите настройку биометрической аутентификации',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await setBiometricEnabled(true);
        await saveBiometricCredentials(username, password);
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      _handlePlatformException(e);
      return false;
    } catch (e) {
      return false;
    }
  }

  void _handlePlatformException(PlatformException e) {
    String message;
    switch (e.code) {
      case 'NotAvailable':
        message = 'Биометрическая аутентификация недоступна на этом устройстве';
        break;
      case 'NotEnrolled':
        message = 'Настройте биометрическую аутентификацию в настройках устройства';
        break;
      case 'LockedOut':
        message = 'Биометрическая аутентификация заблокирована. Попробуйте позже';
        break;
      case 'PermanentlyLockedOut':
        message = 'Биометрическая аутентификация заблокирована навсегда';
        break;
      case 'BiometricOnly':
        message = 'Используйте только биометрическую аутентификацию';
        break;
      default:
        message = 'Ошибка биометрической аутентификации: ${e.message}';
    }

    Get.snackbar(
      'Ошибка биометрии',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
    );
  }

  Future<void> disableBiometricAuth() async {
    await setBiometricEnabled(false);
    await clearBiometricCredentials();
  }

  String getBiometricTypeText(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Отпечаток пальца';
    } else if (types.contains(BiometricType.iris)) {
      return 'Сканер радужки';
    } else {
      return 'Биометрия';
    }
  }

  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    try {
      return {
        'device_supported': await isDeviceSupported,
        'biometric_available': await isBiometricAvailable,
        'can_check_biometrics': await _localAuth.canCheckBiometrics,
        'available_biometrics': await availableBiometrics,
        'biometric_enabled': isBiometricEnabled,
        'has_saved_credentials': savedCredentials != null,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
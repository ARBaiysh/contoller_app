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
    print('BiometricService: Initializing...');
    _checkInitialState();
  }

  // Проверка начального состояния
  Future<void> _checkInitialState() async {
    try {
      final isSupported = await isDeviceSupported;
      final isAvailable = await isBiometricAvailable;
      final availableTypes = await availableBiometrics;

      print('BiometricService: Device supported: $isSupported');
      print('BiometricService: Biometric available: $isAvailable');
      print('BiometricService: Available types: $availableTypes');
      print('BiometricService: Currently enabled: $isBiometricEnabled');
    } catch (e) {
      print('BiometricService: Error checking initial state: $e');
    }
  }

  // Проверка поддержки биометрии на устройстве
  Future<bool> get isDeviceSupported async {
    try {
      final result = await _localAuth.isDeviceSupported();
      print('BiometricService: Device supported check result: $result');
      return result;
    } catch (e) {
      print('BiometricService: Error checking device support: $e');
      return false;
    }
  }

  // Проверка доступности биометрии
  Future<bool> get isBiometricAvailable async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await this.isDeviceSupported;
      final result = isAvailable && isDeviceSupported;

      print('BiometricService: Can check biometrics: $isAvailable');
      print('BiometricService: Device supported: $isDeviceSupported');
      print('BiometricService: Final availability: $result');

      return result;
    } catch (e) {
      print('BiometricService: Error checking biometric availability: $e');
      return false;
    }
  }

  // Получение доступных типов биометрии
  Future<List<BiometricType>> get availableBiometrics async {
    try {
      final types = await _localAuth.getAvailableBiometrics();
      print('BiometricService: Available biometric types: $types');
      return types;
    } catch (e) {
      print('BiometricService: Error getting available biometrics: $e');
      return [];
    }
  }

  // Проверка включена ли биометрия в настройках
  bool get isBiometricEnabled {
    final enabled = _storage.read(_biometricEnabledKey) ?? false;
    print('BiometricService: Biometric enabled in storage: $enabled');
    return enabled;
  }

  // Включение/отключение биометрии
  Future<void> setBiometricEnabled(bool enabled) async {
    print('BiometricService: Setting biometric enabled to: $enabled');
    await _storage.write(_biometricEnabledKey, enabled);
  }

  // Сохранение учетных данных для биометрии
  Future<void> saveBiometricCredentials(String username, String password) async {
    print('BiometricService: Saving biometric credentials for user: $username');
    if (isBiometricEnabled) {
      await _storage.write(_biometricCredentialsKey, {
        'username': username,
        'password': password,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('BiometricService: Credentials saved successfully');
    } else {
      print('BiometricService: Cannot save credentials - biometric not enabled');
    }
  }

  // Получение сохраненных учетных данных
  Map<String, dynamic>? get savedCredentials {
    final credentials = _storage.read(_biometricCredentialsKey);
    print('BiometricService: Retrieved credentials: ${credentials != null ? 'Found' : 'Not found'}');
    return credentials;
  }

  // Очистка сохраненных учетных данных
  Future<void> clearBiometricCredentials() async {
    print('BiometricService: Clearing biometric credentials');
    await _storage.remove(_biometricCredentialsKey);
  }

  // Аутентификация с помощью биометрии
  Future<bool> authenticateWithBiometrics() async {
    print('BiometricService: Starting biometric authentication...');

    try {
      if (!isBiometricEnabled) {
        print('BiometricService: Biometric not enabled');
        return false;
      }

      final bool isAvailable = await isBiometricAvailable;
      if (!isAvailable) {
        print('BiometricService: Biometric not available');
        return false;
      }

      print('BiometricService: Attempting authentication...');
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Подтвердите свою личность для входа в приложение',
        options: const AuthenticationOptions(
          biometricOnly: false, // Изменено с true на false для тестирования
          stickyAuth: true,
        ),
      );

      print('BiometricService: Authentication result: $didAuthenticate');
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('BiometricService: PlatformException during authentication: ${e.code} - ${e.message}');
      _handlePlatformException(e);
      return false;
    } catch (e) {
      print('BiometricService: Unexpected error during authentication: $e');
      return false;
    }
  }

  // Настройка биометрии (с проверкой и сохранением учетных данных)
  Future<bool> setupBiometricAuth(String username, String password) async {
    print('BiometricService: Setting up biometric auth for user: $username');

    try {
      final bool isAvailable = await isBiometricAvailable;
      if (!isAvailable) {
        print('BiometricService: Biometric not available for setup');
        Get.snackbar(
          'Биометрия недоступна',
          'На этом устройстве биометрическая аутентификация не поддерживается',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      print('BiometricService: Attempting setup authentication...');
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Подтвердите настройку биометрической аутентификации',
        options: const AuthenticationOptions(
          biometricOnly: false, // Изменено с true на false
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        print('BiometricService: Setup authentication successful');
        await setBiometricEnabled(true);
        await saveBiometricCredentials(username, password);
        return true;
      } else {
        print('BiometricService: Setup authentication failed');
      }
      return false;
    } on PlatformException catch (e) {
      print('BiometricService: PlatformException during setup: ${e.code} - ${e.message}');
      _handlePlatformException(e);
      return false;
    } catch (e) {
      print('BiometricService: Error setting up biometric auth: $e');
      return false;
    }
  }

  // Обработка платформенных исключений
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
      colorText: Colors.red.withOpacity(0.1)
    );
  }

  // Отключение биометрии
  Future<void> disableBiometricAuth() async {
    print('BiometricService: Disabling biometric auth');
    await setBiometricEnabled(false);
    await clearBiometricCredentials();
  }

  // Получение текста для типа биометрии
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

  // Диагностическая информация
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
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../providers/api_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/values/constants.dart';

class AuthRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final BiometricService _biometricService = Get.find<BiometricService>();
  final GetStorage _storage = GetStorage();

  // Current user data
  Map<String, dynamic>? _currentUser;
  String? _authToken;

  // Getters
  bool get isAuthenticated => _authToken != null;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get authToken => _authToken;

  // Initialize repository
  Future<void> init() async {
    // Load saved auth data
    _authToken = _storage.read(Constants.tokenKey);
    final userData = _storage.read(Constants.userKey);
    if (userData != null) {
      _currentUser = Map<String, dynamic>.from(userData);
    }
  }

  // Login with username and password
  Future<bool> login({
    required String username,
    required String password,
    bool saveForBiometric = false,
  }) async {
    try {
      final response = await _apiProvider.login(username, password);

      if (response['success'] == true) {
        // Save auth data
        _authToken = response['token'];
        _currentUser = response['user'];

        // Persist to storage
        await _storage.write(Constants.tokenKey, _authToken);
        await _storage.write(Constants.userKey, _currentUser);

        // Сохранить учетные данные для биометрии если необходимо
        if (saveForBiometric && _biometricService.isBiometricEnabled) {
          await _biometricService.saveBiometricCredentials(username, password);
        }

        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Биометрический вход
  Future<bool> loginWithBiometrics() async {
    try {
      // Проверяем включена ли биометрия
      if (!_biometricService.isBiometricEnabled) {
        return false;
      }

      // Получаем сохраненные учетные данные
      final credentials = _biometricService.savedCredentials;
      if (credentials == null) {
        return false;
      }

      // Проверяем не устарели ли учетные данные (30 дней)
      final timestamp = credentials['timestamp'] as int?;
      if (timestamp != null) {
        final savedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final daysDifference = DateTime.now().difference(savedDate).inDays;
        if (daysDifference > 30) {
          // Очищаем устаревшие данные
          await _biometricService.clearBiometricCredentials();
          return false;
        }
      }

      // Выполняем биометрическую аутентификацию
      final authenticated = await _biometricService.authenticateWithBiometrics();
      if (!authenticated) {
        return false;
      }

      // Если биометрия прошла успешно, выполняем обычный вход
      final username = credentials['username'] as String;
      final password = credentials['password'] as String;

      return await login(
        username: username,
        password: password,
        saveForBiometric: false, // Уже сохранено
      );
    } catch (e) {
      print('Biometric login error: $e');
      return false;
    }
  }

  // Настройка биометрии после успешного входа
  Future<bool> setupBiometricAuth(String username, String password) async {
    try {
      final success = await _biometricService.setupBiometricAuth(username, password);
      return success;
    } catch (e) {
      print('Setup biometric auth error: $e');
      return false;
    }
  }

  // Отключение биометрии
  Future<void> disableBiometricAuth() async {
    await _biometricService.disableBiometricAuth();
  }

  // Проверка доступности биометрии
  Future<bool> get isBiometricAvailable => _biometricService.isBiometricAvailable;

  // Проверка включена ли биометрия
  bool get isBiometricEnabled => _biometricService.isBiometricEnabled;

  // Logout
  Future<void> logout() async {
    // Clear auth data
    _authToken = null;
    _currentUser = null;

    // Clear storage
    await _storage.remove(Constants.tokenKey);
    await _storage.remove(Constants.userKey);

    // НЕ очищаем биометрические данные при обычном выходе
    // Они останутся для быстрого входа
  }

  // Полный выход с очисткой биометрии
  Future<void> logoutAndClearBiometric() async {
    await logout();
    await _biometricService.disableBiometricAuth();
  }

  // Check if session is valid
  Future<bool> checkSession() async {
    if (!isAuthenticated) return false;

    // In real app, would validate token with server
    // For now, just check if token exists
    return _authToken != null;
  }

  // Get user full name
  String get userFullName {
    return _currentUser?['full_name'] ?? 'Пользователь';
  }

  // Get user role
  String get userRole {
    return _currentUser?['role'] ?? 'controller';
  }

  // Get assigned TPs
  List<String> get assignedTps {
    final tps = _currentUser?['assigned_tps'];
    if (tps is List) {
      return tps.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      // In real app, would call API to update profile
      // For now, just update local data
      _currentUser?.addAll(profileData);
      await _storage.write(Constants.userKey, _currentUser);
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // In real app, would call API to change password
      // For mock, just simulate success
      await Future.delayed(Constants.networkDelay);

      // Если биометрия включена, обновляем сохраненный пароль
      if (_biometricService.isBiometricEnabled) {
        final credentials = _biometricService.savedCredentials;
        if (credentials != null) {
          final username = credentials['username'] as String;
          await _biometricService.saveBiometricCredentials(username, newPassword);
        }
      }

      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
}
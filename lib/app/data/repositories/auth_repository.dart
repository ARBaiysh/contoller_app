import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/token_storage.dart';
import '../providers/api_provider.dart';
import '../models/region_model.dart';
import '../models/auth_response_model.dart';
import '../../core/values/constants.dart';

class AuthRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final TokenStorage _tokenStorage = Get.find<TokenStorage>();
  final GetStorage _storage = GetStorage();

  // Current user data
  InspectorData? _currentUser;

  // Getters
  /// Сессия активна, пока есть refresh-токен в защищённом хранилище.
  bool get isAuthenticated => _tokenStorage.hasSession;
  InspectorData? get currentUser => _currentUser;
  String? get authToken => _tokenStorage.accessToken;

  // Initialize repository
  Future<void> init() async {
    // Токены уже загружены TokenStorage.load() при старте приложения.
    final userData = _storage.read(Constants.userKey);
    if (userData != null) {
      _currentUser = InspectorData.fromJson(Map<String, dynamic>.from(userData));
    }
  }

  // Get available regions
  Future<List<RegionModel>> getRegions() async {
    try {
      return await _apiProvider.getRegions();
    } catch (e) {
      print('Get regions error: $e');
      throw e;
    }
  }

  // Login with username and password
  Future<AuthResponseModel> login({
    required String username,
    required String password,
    required String regionCode,
  }) async {
    try {
      final response = await _apiProvider.login(
        username: username,
        password: password,
        regionCode: regionCode,
      );

      await _saveAuthData(response);
      return response;
    } catch (e) {
      print('Login error: $e');
      throw e;
    }
  }

  /// Обновить сессию по refresh-токену (без пароля).
  /// Используется при входе по биометрии и автологине.
  Future<bool> refreshSession() {
    return _apiProvider.refreshSession();
  }

  /// Получить профиль текущего инспектора
  Future<InspectorData> getProfile() async {
    try {
      final profile = await _apiProvider.getProfile();
      _currentUser = profile;
      await _storage.write(Constants.userKey, profile.toJson());
      return profile;
    } catch (e) {
      print('Get profile error: $e');
      throw e;
    }
  }

  // Save auth data: токены — в защищённое хранилище, профиль — в GetStorage.
  // Пароль НЕ сохраняется нигде.
  Future<void> _saveAuthData(AuthResponseModel response) async {
    _currentUser = response.inspector;

    await _tokenStorage.saveTokens(
      accessToken: response.token,
      refreshToken: response.refreshToken ?? '',
    );
    await _storage.write(Constants.userKey, response.inspector.toJson());

    // Успешный вход — снимаем флаг «сессия истекла»
    _apiProvider.resetAuthFailureFlag();
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;

    // Отзываем refresh-токен на сервере (best-effort), затем чистим локально
    await _apiProvider.revokeRefreshToken();
    await _tokenStorage.clear();

    // Чистим профиль и флаги
    await _storage.remove(Constants.userKey);
    await _storage.remove(Constants.biometricKey);

    // Устаревшие ключи (миграция со старых версий)
    await _storage.remove(Constants.tokenKey);
    await _storage.remove(Constants.usernameKey);
    await _storage.remove(Constants.passwordKey);
    await _storage.remove(Constants.regionCodeKey);
    await _storage.remove('saved_username');
    await _storage.remove('saved_password');
    await _storage.remove('saved_region_code');
    await _storage.remove('remember_me');
  }

  // Get user full name
  String get userFullName {
    return _currentUser?.fullName ?? 'Пользователь';
  }

  // Get user role (для совместимости)
  String get userRole {
    return 'controller';
  }

  // Get assigned TPs (для совместимости, позже заменим на реальные данные)
  List<String> get assignedTps {
    return [];
  }

  // Check if biometric enabled (для совместимости)
  bool get isBiometricEnabled {
    return _storage.read(Constants.biometricKey) ?? false;
  }

  // Check biometric availability (для совместимости)
  Future<bool> get isBiometricAvailable async {
    final BiometricService _biometricService = Get.find<BiometricService>();
    return await _biometricService.isBiometricAvailable;
  }
}

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/biometric_service.dart';
import '../providers/api_provider.dart';
import '../models/region_model.dart';
import '../models/auth_response_model.dart';
import '../../core/values/constants.dart';

class AuthRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final GetStorage _storage = GetStorage();

  // Current user data
  InspectorData? _currentUser;
  String? _authToken;

  // Getters
  bool get isAuthenticated => _authToken != null;
  InspectorData? get currentUser => _currentUser;
  String? get authToken => _authToken;

  // Initialize repository
  Future<void> init() async {
    // Load saved auth data
    _authToken = _storage.read(Constants.tokenKey);
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

      // Handle successful login - новая структура API
      await _saveAuthData(
        token: response.token,
        username: username,
        password: password,
        regionCode: regionCode,
        inspectorData: response.inspector,
      );

      return response;
    } catch (e) {
      print('Login error: $e');
      throw e;
    }
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

  // Save auth data
  Future<void> _saveAuthData({
    required String token,
    required String username,
    required String password,
    required String regionCode,
    required InspectorData inspectorData,
  }) async {
    _authToken = token;
    _currentUser = inspectorData;

    // Persist to storage
    await _storage.write(Constants.tokenKey, token);
    await _storage.write(Constants.usernameKey, username);
    await _storage.write(Constants.passwordKey, password);
    await _storage.write(Constants.regionCodeKey, regionCode);
    await _storage.write(Constants.userKey, inspectorData.toJson());
  }


  // Logout
  Future<void> logout() async {
    _authToken = null;
    _currentUser = null;

    // Clear all saved data
    await _storage.remove(Constants.tokenKey);
    await _storage.remove(Constants.usernameKey);
    await _storage.remove(Constants.passwordKey);
    await _storage.remove(Constants.regionCodeKey);
    await _storage.remove(Constants.userKey);
    await _storage.remove(Constants.biometricKey);

    // Clear saved login data
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
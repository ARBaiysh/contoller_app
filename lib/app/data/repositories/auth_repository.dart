import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../providers/api_provider.dart';
import '../../core/values/constants.dart';

class AuthRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
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

        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    // Clear auth data
    _authToken = null;
    _currentUser = null;

    // Clear storage
    await _storage.remove(Constants.tokenKey);
    await _storage.remove(Constants.userKey);
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
      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
}
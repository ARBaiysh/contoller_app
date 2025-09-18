import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../core/services/biometric_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final BiometricService _biometricService = Get.find<BiometricService>();
  final GetStorage _storage = GetStorage();

  // Observable states
  final _isLoading = false.obs;
  final _notificationsEnabled = true.obs;
  final _autoSyncEnabled = true.obs;
  final _cacheSize = 0.obs;
  final _biometricAvailable = false.obs;
  final _biometricEnabled = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get autoSyncEnabled => _autoSyncEnabled.value;
  int get cacheSize => _cacheSize.value;
  String get cacheFormattedSize => '${(_cacheSize.value / 1024).toStringAsFixed(1)} МБ';
  bool get biometricAvailable => _biometricAvailable.value;
  bool get biometricEnabled => _biometricEnabled.value;

  // User info getters
  String get userName => _authRepository.userFullName;
  String get userRole => _getRoleDisplayName(_authRepository.userRole);
  List<String> get assignedTps => _authRepository.assignedTps;
  bool get isDarkTheme => Get.find<ThemeController>().isDarkMode;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _calculateCacheSize();
    _checkBiometricAvailability();
  }

  // Load settings from storage
  void _loadSettings() {
    _notificationsEnabled.value = _storage.read('notifications_enabled') ?? true;
    _autoSyncEnabled.value = _storage.read('auto_sync_enabled') ?? true;
    _biometricEnabled.value = _authRepository.isBiometricEnabled;
  }

  // Check biometric availability
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _authRepository.isBiometricAvailable;
      _biometricAvailable.value = isAvailable;
    } catch (e) {
      print('Error checking biometric availability: $e');
      _biometricAvailable.value = false;
    }
  }

  // Calculate cache size (mock)
  void _calculateCacheSize() {
    // Mock cache size calculation
    _cacheSize.value = 15 * 1024; // 15 KB in bytes
  }

  // Toggle notifications
  void toggleNotifications(bool value) {
    _notificationsEnabled.value = value;
    _storage.write('notifications_enabled', value);

    Get.snackbar(
      'Настройки',
      value ? 'Уведомления включены' : 'Уведомления отключены',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Toggle auto sync
  void toggleAutoSync(bool value) {
    _autoSyncEnabled.value = value;
    _storage.write('auto_sync_enabled', value);

    Get.snackbar(
      'Настройки',
      value ? 'Автосинхронизация включена' : 'Автосинхронизация отключена',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Toggle theme
  void toggleTheme(bool value) {
    final themeController = Get.find<ThemeController>();
    themeController.setTheme(value);

    // Опционально: показать уведомление
    Get.snackbar(
      'Тема изменена',
      value ? 'Включена темная тема' : 'Включена светлая тема',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }
  // Toggle biometric authentication
  Future<void> toggleBiometric(bool value) async {
    if (value) {
      await _enableBiometric();
    } else {
      await _disableBiometric();
    }
  }

  // Enable biometric authentication
  Future<void> _enableBiometric() async {
    // Временно отключаем биометрию
    Get.snackbar(
      'Информация',
      'Биометрическая аутентификация временно недоступна',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;

    // TODO: Реализовать после добавления поддержки биометрии
    // final success = await _authRepository.setupBiometricAuth();
    // if (success) {
    //   _biometricEnabled.value = true;
    // }
  }

  // Disable biometric authentication
  Future<void> _disableBiometric() async {
    _biometricEnabled.value = false;
    await _storage.write(Constants.biometricKey, false);

    // TODO: Реализовать после добавления поддержки биометрии
    // await _authRepository.disableBiometricAuth();
  }

  // Show credentials dialog for biometric setup
  Future<Map<String, String>?> _showCredentialsDialog() async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await Get.dialog<Map<String, String>>(
      AlertDialog(
        title: const Text('Настройка биометрии'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Введите ваши учетные данные для настройки биометрической аутентификации',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Логин',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите логин';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back(result: {
                  'username': usernameController.text.trim(),
                  'password': passwordController.text,
                });
              }
            },
            child: const Text('Настроить'),
          ),
        ],
      ),
    );
  }

  // Clear cache
  Future<void> clearCache() async {
    _isLoading.value = true;

    try {
      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 1));

      // Clear repositories cache
      // In real app, would clear actual cache
      _cacheSize.value = 0;

      Get.snackbar(
        'Успех',
        'Кэш очищен',
        backgroundColor: Constants.success.withValues(alpha: 0.1),
        colorText: Constants.success,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось очистить кэш',
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Show logout confirmation
  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Выход из системы'),
        content: const Text('Вы уверены, что хотите выйти из приложения?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await _logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Constants.error,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  // Logout
  Future<void> _logout() async {
    _isLoading.value = true;

    try {
      await _authRepository.logout();
      Get.offAllNamed(Routes.AUTH);
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось выйти из системы',
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Get role display name
  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'controller':
        return 'Контролер';
      case 'admin':
        return 'Администратор';
      case 'manager':
        return 'Менеджер';
      default:
        return 'Пользователь';
    }
  }

  // Get app settings info
  Map<String, dynamic> getAppInfo() {
    return {
      'app_name': Constants.appName,
      'app_version': Constants.appVersion,
      'company_name': Constants.companyName,
      'cache_size': cacheFormattedSize,
      'notifications': notificationsEnabled,
      'auto_sync': autoSyncEnabled,
      'biometric_enabled': biometricEnabled,
      'theme': _themeController.isDarkMode ? 'Темная' : 'Светлая',
    };
  }
}
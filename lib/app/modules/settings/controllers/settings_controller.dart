import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final GetStorage _storage = GetStorage();

  // Observable states
  final _isLoading = false.obs;
  final _notificationsEnabled = true.obs;
  final _autoSyncEnabled = true.obs;
  final _cacheSize = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get autoSyncEnabled => _autoSyncEnabled.value;
  int get cacheSize => _cacheSize.value;
  String get cacheFormattedSize => '${(_cacheSize.value / 1024).toStringAsFixed(1)} МБ';

  // User info getters
  String get userName => _authRepository.userFullName;
  String get userRole => _getRoleDisplayName(_authRepository.userRole);
  List<String> get assignedTps => _authRepository.assignedTps;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _calculateCacheSize();
  }

  // Load settings from storage
  void _loadSettings() {
    _notificationsEnabled.value = _storage.read('notifications_enabled') ?? true;
    _autoSyncEnabled.value = _storage.read('auto_sync_enabled') ?? true;
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
  void toggleTheme(bool isDark) {
    _themeController.setTheme(isDark);
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
        backgroundColor: Constants.success.withOpacity(0.1),
        colorText: Constants.success,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось очистить кэш',
        backgroundColor: Constants.error.withOpacity(0.1),
        colorText: Constants.error,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Show about dialog
  void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${Constants.appName}'),
            const SizedBox(height: 8),
            Text('Версия: ${Constants.appVersion}'),
            const SizedBox(height: 8),
            Text('${Constants.companyName}'),
            const SizedBox(height: 16),
            const Text(
              'Мобильное приложение для контролеров электросетевой компании для сбора показаний электросчетчиков.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
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
        backgroundColor: Constants.error.withOpacity(0.1),
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
      'theme': _themeController.isDarkMode ? 'Темная' : 'Светлая',
    };
  }
}
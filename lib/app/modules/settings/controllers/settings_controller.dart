import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/values/constants.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Observable states
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // User info getters
  String get userName => _authRepository.userFullName;
  String get userRole => _getRoleDisplayName(_authRepository.userRole);
  bool get isDarkTheme => Get.find<ThemeController>().isDarkMode;

  // Toggle theme (без снекбара — смена темы и так видна по всему UI)
  void toggleTheme(bool value) {
    Get.find<ThemeController>().setTheme(value);
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
      AppSnackbar.error('Ошибка', 'Не удалось выйти из системы');
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
}

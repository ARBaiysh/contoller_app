import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable states
  final _isLoading = false.obs;
  final _isPasswordVisible = false.obs;
  final _rememberMe = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get rememberMe => _rememberMe.value;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Check if user is already logged in
  Future<void> _checkSession() async {
    await _authRepository.init();

    if (_authRepository.isAuthenticated) {
      final isValid = await _authRepository.checkSession();
      if (isValid) {
        // Navigate to home if session is valid
        Get.offAllNamed(Routes.HOME);
      }
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    _rememberMe.value = !_rememberMe.value;
  }

  // Validate username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите логин';
    }
    if (value.length < 2) {
      return 'Логин слишком короткий';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 4) {
      return 'Пароль должен содержать минимум 4 символа';
    }
    return null;
  }

  // Login
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading.value = true;

    try {
      final success = await _authRepository.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        // Show success message
        Get.snackbar(
          'Успех',
          Constants.loginSuccess,
          backgroundColor: Constants.success.withOpacity(0.1),
          colorText: Constants.success,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigate to home
        Get.offAllNamed(Routes.HOME);
      } else {
        // Show error message
        _showError(Constants.authError);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'Ошибка',
      message,
      backgroundColor: Constants.error.withOpacity(0.1),
      colorText: Constants.error,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // Clear form
  void clearForm() {
    usernameController.clear();
    passwordController.clear();
    formKey.currentState?.reset();
  }
}
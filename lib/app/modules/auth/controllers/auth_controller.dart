import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/biometric_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final BiometricService _biometricService = Get.find<BiometricService>();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable states
  final _isLoading = false.obs;
  final _isPasswordVisible = false.obs;
  final _rememberMe = false.obs;
  final _showBiometricOption = false.obs;
  final _isBiometricLoading = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get rememberMe => _rememberMe.value;
  bool get showBiometricOption => _showBiometricOption.value;
  bool get isBiometricLoading => _isBiometricLoading.value;

  @override
  void onInit() {
    super.onInit();
    _checkBiometricAvailability();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Проверка доступности биометрии
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _authRepository.isBiometricAvailable;
      final isEnabled = _authRepository.isBiometricEnabled;
      final hasCredentials = _biometricService.savedCredentials != null;

      // Показываем опцию биометрии если:
      // 1. Устройство поддерживает биометрию
      // 2. Биометрия включена И есть сохраненные данные
      _showBiometricOption.value = isAvailable && isEnabled && hasCredentials;
    } catch (e) {
      print('Error checking biometric availability: $e');
      _showBiometricOption.value = false;
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

  // Обычный вход
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading.value = true;

    try {
      final username = usernameController.text.trim();
      final password = passwordController.text;

      final success = await _authRepository.login(
        username: username,
        password: password,
        saveForBiometric: _rememberMe.value,
      );

      if (success) {
        // Предложить настроить биометрию если включена галочка "Запомнить"
        if (_rememberMe.value) {
          await _offerBiometricSetup(username, password);
        }

        // Show success message
        Get.snackbar(
          'Успех',
          Constants.loginSuccess,
          backgroundColor: Constants.success.withValues(alpha: 0.1),
          colorText: Constants.success,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigate to home
        Get.offAllNamed(Routes.NAVBAR);
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

  // Биометрический вход
  Future<void> loginWithBiometrics() async {
    _isBiometricLoading.value = true;

    try {
      final success = await _authRepository.loginWithBiometrics();

      if (success) {
        Get.snackbar(
          'Успех',
          'Вход выполнен с помощью биометрии',
          backgroundColor: Constants.success.withValues(alpha: 0.1),
          colorText: Constants.success,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        Get.offAllNamed(Routes.HOME);
      } else {
        _showError('Ошибка биометрической аутентификации');
      }
    } catch (e) {
      _showError('Ошибка биометрической аутентификации');
    } finally {
      _isBiometricLoading.value = false;
    }
  }

  // Предложение настроить биометрию
  Future<void> _offerBiometricSetup(String username, String password) async {
    try {
      final isAvailable = await _authRepository.isBiometricAvailable;
      final isEnabled = _authRepository.isBiometricEnabled;

      // Если биометрия доступна но не настроена
      if (isAvailable && !isEnabled) {
        final availableTypes = await _biometricService.availableBiometrics;
        final biometricText = _biometricService.getBiometricTypeText(availableTypes);

        final result = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Настроить $biometricText?'),
            content: Text(
              'Хотите использовать $biometricText для быстрого входа в приложение?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Настроить'),
              ),
            ],
          ),
        );

        if (result == true) {
          final setupSuccess = await _authRepository.setupBiometricAuth(username, password);
          if (setupSuccess) {
            Get.snackbar(
              'Успех',
              '$biometricText успешно настроен',
              backgroundColor: Constants.success.withValues(alpha: 0.1),
              colorText: Constants.success,
              snackPosition: SnackPosition.TOP,
            );
            _showBiometricOption.value = true;
          } else {
            Get.snackbar(
              'Ошибка',
              'Не удалось настроить $biometricText',
              backgroundColor: Constants.error.withValues(alpha: 0.1),
              colorText: Constants.error,
              snackPosition: SnackPosition.TOP,
            );
          }
        }
      }
    } catch (e) {
      print('Error offering biometric setup: $e');
    }
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'Ошибка',
      message,
      backgroundColor: Constants.error.withValues(alpha: 0.1),
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

  // Получить текст для биометрии
  Future<String> getBiometricButtonText() async {
    try {
      final availableTypes = await _biometricService.availableBiometrics;
      return _biometricService.getBiometricTypeText(availableTypes);
    } catch (e) {
      return 'Биометрия';
    }
  }
}
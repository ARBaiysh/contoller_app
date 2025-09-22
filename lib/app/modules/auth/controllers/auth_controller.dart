import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/auth_response_model.dart';
import '../../../data/models/region_model.dart';
import '../../../data/models/sync_status_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final BiometricService _biometricService = Get.find<BiometricService>();
  final SyncService _syncService = Get.find<SyncService>();
  final GetStorage _storage = GetStorage();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable states
  final _isLoading = false.obs;
  final _regions = <RegionModel>[].obs;
  final _selectedRegion = Rxn<RegionModel>();
  final _isSyncing = false.obs;
  final _syncMessage = ''.obs;
  final _isPasswordVisible = false.obs;
  final _rememberMe = false.obs;
  final _showBiometricOption = false.obs;
  final _isBiometricLoading = false.obs;
  final _isFormValid = false.obs;  // ДОБАВЛЕНО: явная реактивная переменная

  // Getters - просто возвращают значения без логики
  bool get isLoading => _isLoading.value;
  List<RegionModel> get regions => _regions;
  RegionModel? get selectedRegion => _selectedRegion.value;
  bool get isSyncing => _isSyncing.value;
  String get syncMessage => _syncMessage.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get rememberMe => _rememberMe.value;
  bool get showBiometricOption => _showBiometricOption.value;
  bool get isBiometricLoading => _isBiometricLoading.value;
  bool get isFormValid => _isFormValid.value;

  @override
  void onInit() {
    super.onInit();
    _loadRegions();
    _checkBiometricAvailability();
    _loadSavedCredentials();
    _setupFormValidation();
  }

  @override
  void onClose() {
    usernameController.removeListener(_updateFormState);
    passwordController.removeListener(_updateFormState);
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ========================================
  // FORM VALIDATION
  // ========================================

  void _setupFormValidation() {
    usernameController.addListener(_updateFormState);
    passwordController.addListener(_updateFormState);
    _selectedRegion.listen((_) => _updateFormState());
    _isLoading.listen((_) => _updateFormState());
    _isSyncing.listen((_) => _updateFormState());
  }

  // НОВЫЙ МЕТОД: Обновление состояния валидности формы
  void _updateFormState() {
    final isUsernameValid = usernameController.text.trim().isNotEmpty;
    final isPasswordValid = passwordController.text.trim().isNotEmpty;
    final isRegionSelected = _selectedRegion.value != null;

    _isFormValid.value = isUsernameValid &&
        isPasswordValid &&
        isRegionSelected &&
        !_isLoading.value &&
        !_isSyncing.value;
  }

  // ========================================
  // INITIALIZATION
  // ========================================

  Future<void> _loadRegions() async {
    try {
      print('[AUTH] Loading regions...');
      _isLoading.value = true;

      final regionsList = await _authRepository.getRegions();
      print('[AUTH] Loaded ${regionsList.length} regions');

      _regions.value = regionsList;

      // Auto-select saved region if exists
      final savedRegionCode = _storage.read('saved_region_code');
      if (savedRegionCode != null) {
        final savedRegion = regionsList.firstWhereOrNull((r) => r.code == savedRegionCode);
        if (savedRegion != null) {
          _selectedRegion.value = savedRegion;
        }
      }

      // Auto-select if only one region
      if (_selectedRegion.value == null && regionsList.length == 1) {
        _selectedRegion.value = regionsList.first;
      }
    } catch (e) {
      print('[AUTH] Error loading regions: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить список регионов',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      _updateFormState(); // Обновляем состояние формы
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Проверяем есть ли сохраненные credentials
      final hasSavedCredentials = _storage.read('saved_username') != null && _storage.read('saved_password') != null;

      // Показываем кнопку биометрии только если:
      // 1. Есть сохраненные данные
      // 2. Биометрия доступна на устройстве
      if (hasSavedCredentials) {
        final isAvailable = await _biometricService.isBiometricAvailable;
        _showBiometricOption.value = isAvailable;
        print('[AUTH] Biometric option: $isAvailable (has saved credentials: $hasSavedCredentials)');
      } else {
        _showBiometricOption.value = false;
        print('[AUTH] No saved credentials - hiding biometric option');
      }
    } catch (e) {
      print('[AUTH] Error checking biometric availability: $e');
      _showBiometricOption.value = false;
    }
  }

  void _loadSavedCredentials() {
    if (_storage.read('remember_me') == true) {
      _rememberMe.value = true;
      usernameController.text = _storage.read('saved_username') ?? '';
    }
  }

  // ========================================
  // FORM ACTIONS
  // ========================================

  void selectRegion(RegionModel? region) {
    _selectedRegion.value = region;
    _updateFormState(); // Обновляем состояние формы
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  void toggleRememberMe() {
    _rememberMe.value = !_rememberMe.value;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите логин';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    return null;
  }


  // ========================================
  // LOGIN LOGIC
  // ========================================

  Future<void> login() async {
    if (!_isFormValid.value) return;
    if (!formKey.currentState!.validate()) return;
    if (_selectedRegion.value == null) {
      Get.snackbar(
        'Ошибка',
        'Выберите регион',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _isLoading.value = true;
      _updateFormState(); // Обновляем состояние формы

      final response = await _authRepository.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        regionCode: _selectedRegion.value!.code,
      );

      // Save credentials if remember me is checked
      if (_rememberMe.value) {
        // Проверяем доступность биометрии
        final isBiometricAvailable = await _biometricService.isBiometricAvailable;

        if (isBiometricAvailable && response.status == 'SUCCESS') {
          // Запрашиваем биометрию для защиты сохраненных данных
          final biometricConfirmed = await _biometricService.authenticateWithBiometrics();

          if (biometricConfirmed) {
            // Сохраняем все данные включая пароль
            await _storage.write('remember_me', true);
            await _storage.write('saved_username', usernameController.text.trim());
            await _storage.write('saved_password', passwordController.text.trim());
            await _storage.write('saved_region_code', _selectedRegion.value!.code);
            await _storage.write(Constants.biometricKey, true);

            print('[AUTH] Credentials saved with biometric protection');
            Get.snackbar(
              'Успешно',
              'Данные для входа сохранены и защищены биометрией',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } else if (response.status == 'SUCCESS') {
          // Сохраняем только username если биометрия недоступна
          await _storage.write('remember_me', true);
          await _storage.write('saved_username', usernameController.text.trim());
          print('[AUTH] Username saved (biometric not available)');
        }
      }

      await _handleLoginResponse(response);
    } catch (e) {
      print('[AUTH] Login error: $e');
      Get.snackbar(
        'Ошибка',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      _updateFormState(); // Обновляем состояние формы
    }
  }

  Future<void> loginWithBiometrics() async {
    if (_isLoading.value || _isSyncing.value) return;

    try {
      _isBiometricLoading.value = true;
      print('[AUTH] Starting biometric login...');

      // Проверяем биометрию
      final authenticated = await _biometricService.authenticateWithBiometrics();

      if (!authenticated) {
        print('[AUTH] Biometric authentication failed or cancelled');
        return;
      }

      // Получаем сохраненные credentials из обычного storage
      final savedUsername = _storage.read('saved_username');
      final savedPassword = _storage.read('saved_password');
      final savedRegionCode = _storage.read('saved_region_code');

      if (savedUsername == null || savedPassword == null || savedRegionCode == null) {
        print('[AUTH] No saved credentials found');
        Get.snackbar(
          'Ошибка',
          'Не найдены сохраненные данные для входа',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white,
        );
        return;
      }

      print('[AUTH] Biometric authenticated, logging in with saved credentials...');

      // Выполняем вход с сохраненными данными
      _isLoading.value = true;
      _updateFormState();

      final response = await _authRepository.login(
        username: savedUsername,
        password: savedPassword,
        regionCode: savedRegionCode,
      );

      await _handleLoginResponse(response);

    } catch (e) {
      print('[AUTH] Biometric login error: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось выполнить вход',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isBiometricLoading.value = false;
      _isLoading.value = false;
      _updateFormState();
    }
  }

  Future<String> getBiometricButtonText() async {
    return 'биометрии';
  }

  // ========================================
  // SYNC LOGIC (USING SYNCSERVICE)
  // ========================================

  Future<void> _handleLoginResponse(AuthResponseModel response) async {
    switch (response.status) {
      case 'SUCCESS':
        Get.offAllNamed(Routes.NAVBAR);
        Get.snackbar(
          'Успешно',
          'Добро пожаловать, ${response.fullName ?? ""}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        break;

      case 'SYNCING':
        if (response.syncMessageId != null) {
          await _startSyncProcess(response.syncMessageId!);
        }
        break;

      case 'ERROR':
        throw Exception(response.message ?? 'Ошибка авторизации');

      default:
        throw Exception('Неизвестный статус: ${response.status}');
    }
  }

  Future<void> _startSyncProcess(int syncMessageId) async {
    _isSyncing.value = true;
    _syncMessage.value = 'Идет синхронизация с 1С...';
    _updateFormState();

    print('[AUTH] Starting sync monitoring for messageId: $syncMessageId');

    await _syncService.monitorSync(
      messageId: syncMessageId,
      timeout: Constants.authSyncTimeout,
      // 2 минуты
      checkInterval: Constants.authSyncCheckInterval,
      // 3 секунды
      onSuccess: _onSyncSuccess,
      onError: _onSyncError,
      onProgress: _onSyncProgress,
    );
  }

  void _onSyncProgress(String message, Duration elapsed) {
    _syncMessage.value = message;
    print('[AUTH] Sync progress: $message (${elapsed.inSeconds}s)');
  }

  Future<void> _onSyncSuccess(SyncStatusModel syncStatus) async {
    _isSyncing.value = false;
    _syncMessage.value = '';
    _updateFormState();

    print('[AUTH] Sync completed successfully, retrying login...');

    try {
      _isLoading.value = true;
      _updateFormState();

      // Повторный запрос авторизации после успешной синхронизации
      final response = await _authRepository.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        regionCode: _selectedRegion.value!.code,
      );

      if (response.status == 'SUCCESS') {
        print('[AUTH] Retry login successful!');
        Get.offAllNamed(Routes.NAVBAR);
        Get.snackbar(
          'Успешно',
          'Добро пожаловать, ${response.fullName ?? ""}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(response.message ?? 'Повторная авторизация не удалась');
      }
    } catch (e) {
      print('[AUTH] Retry login failed: $e');
      Get.snackbar(
        'Ошибка повторной авторизации',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      _updateFormState();
    }
  }

  void _onSyncError(String error) {
    _isSyncing.value = false;
    _syncMessage.value = '';
    _updateFormState();

    print('[AUTH] Sync failed: $error');

    Get.snackbar(
      'Ошибка синхронизации',
      error,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }
}

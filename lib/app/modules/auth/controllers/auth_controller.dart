import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/region_model.dart';
import '../../../data/models/auth_response_model.dart';
import '../../../data/models/sync_status_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/sync_service.dart';
import 'package:get_storage/get_storage.dart';

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
  final _isFormValid = false.obs;

  // Getters
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
    usernameController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ========================================
  // FORM VALIDATION
  // ========================================

  void _setupFormValidation() {
    usernameController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    _selectedRegion.listen((_) => _validateForm());
  }

  void _validateForm() {
    final isUsernameValid = usernameController.text.trim().isNotEmpty;
    final isPasswordValid = passwordController.text.trim().isNotEmpty;
    final isRegionSelected = _selectedRegion.value != null;

    _isFormValid.value = isUsernameValid && isPasswordValid && isRegionSelected && !_isLoading.value && !_isSyncing.value;
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
      _validateForm();
    }
  }

  Future<void> _checkBiometricAvailability() async {
    _showBiometricOption.value = false;
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
    _validateForm();
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
      _validateForm();

      final response = await _authRepository.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        regionCode: _selectedRegion.value!.code,
      );

      // Save credentials if remember me is checked
      if (_rememberMe.value) {
        await _storage.write('remember_me', true);
        await _storage.write('saved_username', usernameController.text.trim());
        await _storage.write('saved_region_code', _selectedRegion.value!.code);
      } else {
        await _storage.remove('remember_me');
        await _storage.remove('saved_username');
        await _storage.remove('saved_region_code');
      }

      await _handleLoginResponse(response);
    } catch (e) {
      Get.snackbar(
        'Ошибка авторизации',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      _validateForm();
    }
  }

  Future<void> loginWithBiometrics() async {
    _isBiometricLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    _isBiometricLoading.value = false;

    Get.snackbar(
      'Информация',
      'Биометрическая аутентификация временно недоступна',
      snackPosition: SnackPosition.BOTTOM,
    );
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
    _validateForm();

    print('[AUTH] Starting sync monitoring for messageId: $syncMessageId');

    await _syncService.monitorSync(
      messageId: syncMessageId,
      timeout: Constants.authSyncTimeout,        // 2 минуты
      checkInterval: Constants.authSyncCheckInterval, // 3 секунды
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
    _validateForm();

    print('[AUTH] Sync completed successfully, retrying login...');

    try {
      _isLoading.value = true;
      _validateForm();

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
      _validateForm();
    }
  }

  void _onSyncError(String error) {
    _isSyncing.value = false;
    _syncMessage.value = '';
    _validateForm();

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
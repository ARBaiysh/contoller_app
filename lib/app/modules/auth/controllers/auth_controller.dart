import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/region_model.dart';
import '../../../data/models/auth_response_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';
import '../../../core/services/biometric_service.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final BiometricService _biometricService = Get.find<BiometricService>();
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

  // Timer for sync status checking
  Timer? _syncTimer;
  int? _currentSyncMessageId;

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

  @override
  void onInit() {
    super.onInit();
    _loadRegions();
    _checkBiometricAvailability();
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    _syncTimer?.cancel();
    super.onClose();
  }

  // Load regions
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
    }
  }

  // Check biometric availability
  Future<void> _checkBiometricAvailability() async {
    // Временно отключаем биометрию
    _showBiometricOption.value = false;
  }

  // Load saved credentials
  void _loadSavedCredentials() {
    if (_storage.read('remember_me') == true) {
      _rememberMe.value = true;
      usernameController.text = _storage.read('saved_username') ?? '';
    }
  }

  // Select region
  void selectRegion(RegionModel? region) {
    _selectedRegion.value = region;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    _rememberMe.value = !_rememberMe.value;
  }

  // Form validation
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

  // Login
  Future<void> login() async {
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
    }
  }

  // Login with biometrics (stub for now)
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

  // Get biometric button text
  Future<String> getBiometricButtonText() async {
    return 'биометрии';
  }

  // Handle login response
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
          _startSyncProcess(response.syncMessageId!);
        }
        break;

      case 'ERROR':
        throw Exception(response.message ?? 'Ошибка авторизации');

      default:
        throw Exception('Неизвестный статус: ${response.status}');
    }
  }

  // Start sync process
  void _startSyncProcess(int syncMessageId) {
    _isSyncing.value = true;
    _syncMessage.value = 'Идет синхронизация с 1С...';
    _currentSyncMessageId = syncMessageId;

    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Constants.syncCheckInterval, (_) {
      _checkSyncStatus();
    });

    Future.delayed(Constants.maxSyncWaitTime, () {
      if (_isSyncing.value) {
        _syncTimer?.cancel();
        _isSyncing.value = false;
        _syncMessage.value = '';
        Get.snackbar(
          'Ошибка',
          'Время ожидания синхронизации истекло',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white,
        );
      }
    });
  }

  // Check sync status
  Future<void> _checkSyncStatus() async {
    if (_currentSyncMessageId == null) return;

    try {
      final response = await _authRepository.checkSyncStatus(_currentSyncMessageId!);

      if (response.status == 'SUCCESS') {
        _syncTimer?.cancel();
        _isSyncing.value = false;
        _syncMessage.value = '';
        await login();
      } else if (response.status == 'ERROR') {
        _syncTimer?.cancel();
        _isSyncing.value = false;
        _syncMessage.value = '';
        throw Exception(response.message ?? 'Ошибка синхронизации');
      }
    } catch (e) {
      _syncTimer?.cancel();
      _isSyncing.value = false;
      _syncMessage.value = '';
      Get.snackbar(
        'Ошибка',
        'Ошибка при проверке статуса синхронизации',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    }
  }
}
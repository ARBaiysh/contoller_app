import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/app_update_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  late final AuthRepository _authRepository;
  late final BiometricService _biometricService;
  final GetStorage _storage = GetStorage();
  late final AppUpdateService _appUpdateService;

  // Observable states для UI
  final _isLoading = true.obs;
  final _loadingText = 'Инициализация...'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get loadingText => _loadingText.value;

  @override
  void onInit() {
    super.onInit();
    try {
      _authRepository = Get.find<AuthRepository>();
      _biometricService = Get.find<BiometricService>();
      _appUpdateService = Get.find<AppUpdateService>();
    } catch (e) {
      Get.put(AuthRepository());
      Get.put(BiometricService());
      Get.put(AppUpdateService());
      _authRepository = Get.find<AuthRepository>();
      _biometricService = Get.find<BiometricService>();
      _appUpdateService = Get.find<AppUpdateService>();
    }
  }

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _loadingText.value = 'Загрузка данных...';

    await Future.delayed(const Duration(seconds: 1));

    // ========================================
    // ПРОВЕРКА ВЕРСИИ ПРИЛОЖЕНИЯ
    // ========================================
    _loadingText.value = 'Проверка версии...';

    try {
      // Проверяем, требуется ли обновление
      final needsUpdate = await _appUpdateService.checkForUpdate();
      final versionInfo = _appUpdateService.versionInfo;

      if (versionInfo != null && _appUpdateService.currentBuildNumber != null) {
        final currentAppBuildNumber = _appUpdateService.currentBuildNumber!;

        // ЖЕСТКАЯ БЛОКИРОВКА (forceUpdate = true И версия устарела)
        if (needsUpdate && versionInfo.forceUpdate) {
          print('[SPLASH] ⚠️ CRITICAL update required! Force blocking...');

          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAllNamed(Routes.UPDATE_REQUIRED);
          return; // Останавливаем дальнейшую инициализацию
        }

        // МЯГКОЕ ОБНОВЛЕНИЕ (есть новая версия, но не критично)
        if (versionInfo.hasNewerVersion(currentAppBuildNumber) && !needsUpdate) {
          print('[SPLASH] 💡 Soft update available (optional)');
          print('[SPLASH] Current: $currentAppBuildNumber, Latest: ${versionInfo.currentBuildNumber}');

          // Сохраняем информацию о доступном обновлении
          Get.find<AppUpdateService>().softUpdateAvailable = true;
        }

        print('[SPLASH] ✅ App version check completed');
      }
    } catch (e) {
      // Если произошла ошибка при проверке версии, продолжаем работу
      print('[SPLASH] ⚠️ Error checking app version: $e');
      print('[SPLASH] Continuing without version check...');
    }

    // ========================================
    // ДАЛЬНЕЙШАЯ ИНИЦИАЛИЗАЦИЯ
    // ========================================
    _loadingText.value = 'Проверка авторизации...';

    await _authRepository.init();

    await Future.delayed(const Duration(milliseconds: 500));

    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Проверяем, настроена ли биометрия
    final hasBiometricCredentials = _biometricService.savedCredentials != null &&
        _biometricService.isBiometricEnabled;

    // Если биометрия настроена - ВСЕГДА запрашиваем её
    if (hasBiometricCredentials) {
      _loadingText.value = 'Проверка биометрии...';

      await Future.delayed(const Duration(milliseconds: 300));

      final success = await _tryBiometricLogin();

      if (success) {
        Get.offAllNamed(Routes.NAVBAR);
      } else {
        Get.offAllNamed(Routes.AUTH);
      }
      return;
    }

    // Если биометрии нет, проверяем галочку "Запомнить меня"
    final rememberMe = _storage.read('remember_me') ?? false;

    if (!rememberMe) {
      // Пользователь НЕ хотел сохранять сессию
      await _authRepository.logout();
      Get.offAllNamed(Routes.AUTH);
      return;
    }

    // Если галочка "Запомнить меня" стоит, проверяем активную сессию
    if (_authRepository.isAuthenticated) {
      Get.offAllNamed(Routes.NAVBAR);
    } else {
      Get.offAllNamed(Routes.AUTH);
    }
  }

  /// Попытка автоматического входа через биометрию
  Future<bool> _tryBiometricLogin() async {
    try {
      final authenticated = await _biometricService.authenticateWithBiometrics();

      if (!authenticated) {
        return false;
      }

      final credentials = _biometricService.savedCredentials;
      final savedRegionCode = _storage.read('saved_region_code');

      if (credentials == null || savedRegionCode == null) {
        return false;
      }

      final username = credentials['username'] as String?;
      final password = credentials['password'] as String?;

      if (username == null || password == null) {
        return false;
      }

      final response = await _authRepository.login(
        username: username,
        password: password,
        regionCode: savedRegionCode,
      );

      if (response.status == 'SUCCESS') {
        return true;
      } else if (response.status == 'SYNCING') {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
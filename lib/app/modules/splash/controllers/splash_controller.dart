import 'package:get/get.dart';

import '../../../core/services/biometric_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final BiometricService _biometricService = Get.find<BiometricService>();

  // Observable states
  final _isLoading = true.obs;
  final _loadingText = 'Загрузка...'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get loadingText => _loadingText.value;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // Инициализация приложения
  Future<void> _initializeApp() async {
    try {
      // Инициализация сервисов
      _updateLoadingText('Инициализация...');
      await _authRepository.init();

      // Небольшая задержка для показа сплеша
      await Future.delayed(const Duration(seconds: 2));

      // Проверка сохраненной сессии
      _updateLoadingText('Проверка сессии...');
      await _checkSession();
    } catch (e) {
      print('Error during app initialization: $e');
      _navigateToAuth();
    }
  }

  // Проверка сессии и биометрии
  Future<void> _checkSession() async {
    // Проверяем есть ли активная сессия
    if (_authRepository.isAuthenticated) {
      final isValid = await _authRepository.checkSession();

      if (isValid) {
        // Если включена биометрия, предлагаем её использовать
        if (_biometricService.isBiometricEnabled) {
          _updateLoadingText('Биометрическая аутентификация...');
          await _handleBiometricAuth();
        } else {
          // Переходим сразу на главную
          _navigateToNavBar();
        }
      } else {
        // Сессия истекла
        await _authRepository.logout();
        _navigateToAuth();
      }
    } else {
      // Нет активной сессии
      _navigateToAuth();
    }
  }

  // Обработка биометрической аутентификации
  Future<void> _handleBiometricAuth() async {
    try {
      final credentials = _biometricService.savedCredentials;

      if (credentials == null) {
        // Нет сохраненных учетных данных
        _navigateToAuth();
        return;
      }

      // Попытка биометрической аутентификации
      final authenticated =
          await _biometricService.authenticateWithBiometrics();

      if (authenticated) {
        // Успешная биометрическая аутентификация
        _navigateToNavBar();
      } else {
        // Биометрия не прошла - переходим к обычному входу
        _navigateToAuth();
      }
    } catch (e) {
      print('Error during biometric auth: $e');
      _navigateToAuth();
    }
  }

  // Обновление текста загрузки
  void _updateLoadingText(String text) {
    _loadingText.value = text;
  }

  // Навигация к экрану авторизации
  void _navigateToAuth() {
    _isLoading.value = false;
    Get.offAllNamed(Routes.AUTH);
  }

  // Навигация к главному экрану
  void _navigateToNavBar() {
    _isLoading.value = false;
    Get.offAllNamed(Routes.NAVBAR);
  }

  // Принудительный переход к авторизации (например, при ошибке)
  void forceNavigateToAuth() {
    _navigateToAuth();
  }
}

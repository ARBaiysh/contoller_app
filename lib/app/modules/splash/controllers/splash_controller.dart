import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  late final AuthRepository _authRepository;

  // Observable states для UI
  final _isLoading = true.obs;
  final _loadingText = 'Инициализация...'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get loadingText => _loadingText.value;

  @override
  void onInit() {
    super.onInit();
    print('[SPLASH] Controller onInit');
    try {
      _authRepository = Get.find<AuthRepository>();
      print('[SPLASH] AuthRepository found');
    } catch (e) {
      print('[SPLASH] Error finding AuthRepository: $e');
      Get.put(AuthRepository());
      _authRepository = Get.find<AuthRepository>();
    }
  }

  @override
  void onReady() {
    super.onReady();
    print('[SPLASH] Controller onReady');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('[SPLASH] Starting initialization...');
    _loadingText.value = 'Загрузка данных...';

    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));

    print('[SPLASH] Initializing auth repository...');
    _loadingText.value = 'Проверка авторизации...';

    // Initialize auth repository
    await _authRepository.init();

    print('[SPLASH] Checking auth status...');
    // Check authentication status
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    if (_authRepository.isAuthenticated) {
      print('[SPLASH] User authenticated, going to NAVBAR');
      Get.offAllNamed(Routes.NAVBAR);
    } else {
      print('[SPLASH] User not authenticated, going to AUTH');
      Get.offAllNamed(Routes.AUTH);
    }
  }
}
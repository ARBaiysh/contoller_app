import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/api_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';
import '../../navbar/main_nav_controller.dart';

class HomeController extends GetxController {
  final StatisticsRepository _statisticsRepository = Get.find<StatisticsRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // Observable states
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _dashboard = Rxn<DashboardModel>();
  final _lastError = ''.obs;

  // Новые состояния для полной синхронизации
  final _isFullSyncStarting = false.obs;
  Timer? _autoRefreshTimer;

  // Getters
  bool get isLoading => _isLoading.value;

  bool get isRefreshing => _isRefreshing.value;

  DashboardModel? get dashboard => _dashboard.value;

  String get userName => _authRepository.userFullName;

  String get lastError => _lastError.value;

  bool get hasError => _lastError.value.isNotEmpty;

  bool get isFullSyncStarting => _isFullSyncStarting.value;

  // Геттеры для полной синхронизации
  bool get canStartFullSync => dashboard != null && !dashboard!.fullSyncInProgress && !_isFullSyncStarting.value;

  bool get isFullSyncInProgress => dashboard?.fullSyncInProgress ?? false;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  @override
  void onClose() {
    _stopAutoRefresh();
    super.onClose();
  }

  // ========================================
  // ОСНОВНЫЕ МЕТОДЫ ЗАГРУЗКИ
  // ========================================

  /// Загрузка данных дашборда
  Future<void> loadDashboard({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.value = true;
    }
    _lastError.value = '';

    try {
      final stats = await _statisticsRepository.getDashboardStatistics();
      _dashboard.value = stats;

      // Запускаем автообновление если синхронизация в процессе
      _handleAutoRefresh();
    } catch (e) {
      print('[HOME] Error loading dashboard: $e');
      _lastError.value = 'Не удалось загрузить статистику';

      if (showLoading) {
        Get.snackbar(
          'Ошибка',
          'Не удалось загрузить статистику',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Constants.error.withValues(alpha: 0.1),
          colorText: Constants.error,
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// Обновление дашборда (pull-to-refresh)
  Future<void> refreshDashboard() async {
    _isRefreshing.value = true;
    try {
      final stats = await _statisticsRepository.getDashboardStatistics(forceRefresh: true);
      _dashboard.value = stats;
      _lastError.value = '';

      // Обновляем автообновление
      _handleAutoRefresh();
    } catch (e) {
      print('[HOME] Error refreshing dashboard: $e');
      _lastError.value = 'Ошибка обновления данных';
    } finally {
      _isRefreshing.value = false;
    }
  }

  // ========================================
  // ПОЛНАЯ СИНХРОНИЗАЦИЯ
  // ========================================

  /// Запуск полной синхронизации
  Future<void> startFullSync() async {
    if (!canStartFullSync) {
      print('[HOME] Cannot start full sync - conditions not met');
      return;
    }

    _isFullSyncStarting.value = true;

    try {
      print('[HOME] Starting full sync...');
      final response = await _apiProvider.startFullSync();

      if (response.isInitiated) {
        // Синхронизация успешно запущена
        Get.snackbar(
          'Синхронизация',
          response.displayMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Constants.success.withValues(alpha: 0.1),
          colorText: Constants.success,
          duration: const Duration(seconds: 2),
        );

        // Сразу обновляем дашборд чтобы получить новый статус
        await Future.delayed(const Duration(milliseconds: 500));
        await loadDashboard(showLoading: false);
      } else if (response.isAlreadyRunning) {
        // Синхронизация уже выполняется
        Get.snackbar(
          'Информация',
          response.displayMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Constants.warning.withValues(alpha: 0.1),
          colorText: Constants.warning,
          duration: const Duration(seconds: 2),
        );

        // Обновляем дашборд для актуального статуса
        await loadDashboard(showLoading: false);
      } else {
        // Ошибка запуска
        Get.snackbar(
          'Ошибка',
          response.displayMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Constants.error.withValues(alpha: 0.1),
          colorText: Constants.error,
        );
      }
    } catch (e) {
      print('[HOME] Error starting full sync: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось запустить синхронизацию',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
      );
    } finally {
      _isFullSyncStarting.value = false;
    }
  }

  // ========================================
  // АВТООБНОВЛЕНИЕ ВО ВРЕМЯ СИНХРОНИЗАЦИИ
  // ========================================

  /// Управление автообновлением
  void _handleAutoRefresh() {
    if (isFullSyncInProgress) {
      _startAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
  }

  /// Запуск автообновления каждые 15 секунд
  void _startAutoRefresh() {
    if (_autoRefreshTimer?.isActive == true) return;

    print('[HOME] Starting auto-refresh for full sync monitoring');
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (!isFullSyncInProgress) {
        print('[HOME] Full sync completed, stopping auto-refresh');
        _stopAutoRefresh();
        return;
      }

      print('[HOME] Auto-refreshing dashboard during full sync');
      await loadDashboard(showLoading: false);
    });
  }

  /// Остановка автообновления
  void _stopAutoRefresh() {
    if (_autoRefreshTimer?.isActive == true) {
      print('[HOME] Stopping auto-refresh');
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
    }
  }

  // ========================================
  // НАВИГАЦИЯ
  // ========================================

  void navigateToTpList() => _switchMainTab(1);

  void navigateToSearch() => _switchMainTab(2);

  void navigateToReports() => _switchMainTab(3);

  void _switchMainTab(int index) {
    try {
      final nav = Get.find<MainNavController>();
      nav.switchTo(index);
    } catch (_) {
      // Fallback navigation
      switch (index) {
        case 1:
          Get.toNamed(Routes.TP_LIST);
          break;
        case 2:
          Get.toNamed(Routes.SEARCH);
          break;
        case 3:
          Get.toNamed(Routes.REPORTS);
          break;
        default:
          break;
      }
    }
  }

  /// Выход из системы
  Future<void> logout() async {
    Get.defaultDialog(
      title: 'Выход',
      middleText: 'Вы уверены, что хотите выйти?',
      textConfirm: 'Да',
      textCancel: 'Отмена',
      confirmTextColor: Get.theme.cardColor,
      onConfirm: () async {
        await _authRepository.logout();
        Get.offAllNamed(Routes.AUTH);
      },
    );
  }
}

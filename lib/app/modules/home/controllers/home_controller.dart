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

  // Все состояния как реактивные переменные
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  Rx<DashboardModel> dashboard = Rx<DashboardModel>(DashboardModel.empty());
  final lastError = ''.obs;
  final hasError = false.obs;

  // Состояния синхронизации
  final isFullSyncStarting = false.obs;
  final isFullSyncInProgress = false.obs;
  final minutesUntilSyncAvailable = 0.obs;
  final canStartSync = true.obs;
  final syncButtonText = 'Полная синхронизация'.obs;

  // Данные пользователя
  final userName = ''.obs;

  Timer? _syncAvailabilityTimer;

  @override
  void onInit() {
    super.onInit();
    print('[HOME] Controller initialized: ${hashCode}');
    userName.value = _authRepository.userFullName;
    loadDashboard();
    _startSyncAvailabilityTimer();
  }

  @override
  void onClose() {
    _syncAvailabilityTimer?.cancel();
    super.onClose();
  }

  // ========================================
  // ТАЙМЕР ДЛЯ ОТСЛЕЖИВАНИЯ ДОСТУПНОСТИ СИНХРОНИЗАЦИИ
  // ========================================

  void _startSyncAvailabilityTimer() {
    _syncAvailabilityTimer?.cancel();

    _syncAvailabilityTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateSyncAvailability();
    });

    // Сразу обновляем
    _updateSyncAvailability();
  }

  void _updateSyncAvailability() {
    final dashboardData = dashboard.value;
    if (dashboardData == null) {
      canStartSync.value = false;
      syncButtonText.value = 'Полная синхронизация';
      return;
    }

    // Обновляем флаг синхронизации
    isFullSyncInProgress.value = dashboardData.fullSyncInProgress;

    if (isFullSyncInProgress.value) {
      canStartSync.value = false;
      syncButtonText.value = 'Идет синхронизация...';
      minutesUntilSyncAvailable.value = 0;
      return;
    }

    if (dashboardData.lastFullSyncCompleted != null) {
      final now = DateTime.now();
      final localLastSync = dashboardData.lastFullSyncCompleted!.toLocal();

      // Защита от будущих дат
      if (localLastSync.isAfter(now)) {
        print('[SYNC AVAILABILITY] WARNING: Last sync time is in the future!');
        canStartSync.value = false;
        minutesUntilSyncAvailable.value = Constants.fullSyncCooldown.inMinutes;
        syncButtonText.value = 'Доступно через ${Constants.fullSyncCooldown.inMinutes} мин';
        return;
      }

      final timeSinceLastSync = now.difference(localLastSync);
      final cooldownMinutes = Constants.fullSyncCooldown.inMinutes;
      final timeSinceInMinutes = timeSinceLastSync.inMinutes;

      print('[SYNC AVAILABILITY] Time since last sync: ${timeSinceInMinutes} minutes');

      if (timeSinceInMinutes < cooldownMinutes) {
        final remaining = cooldownMinutes - timeSinceInMinutes;
        minutesUntilSyncAvailable.value = remaining;
        canStartSync.value = false;
        syncButtonText.value = 'Доступно через $remaining мин';
      } else {
        minutesUntilSyncAvailable.value = 0;
        canStartSync.value = !isFullSyncStarting.value;
        syncButtonText.value = 'Полная синхронизация';
      }
    } else {
      // Никогда не было синхронизации
      minutesUntilSyncAvailable.value = 0;
      canStartSync.value = !isFullSyncStarting.value;
      syncButtonText.value = 'Полная синхронизация';
    }
  }

  // ========================================
  // ЗАГРУЗКА ДАННЫХ DASHBOARD
  // ========================================

  Future<void> loadDashboard({bool showLoading = true}) async {
    if (showLoading && !isRefreshing.value) {
      isLoading.value = true;
    }

    try {
      lastError.value = '';
      hasError.value = false;

      print('[HOME] Loading dashboard...');
      final dashboardData = await _statisticsRepository.getDashboardStatistics();
      print('[HOME] Dashboard loaded: fullSyncInProgress=${dashboardData.fullSyncInProgress}');
      print('[HOME] Dashboard loaded: $dashboardData');

      dashboard.value = dashboardData;

      // Обновляем все связанные состояния
      _updateSyncAvailability();

    } catch (e) {
      print('[HOME] Error loading dashboard: $e');
      lastError.value = e.toString();
      hasError.value = true;

      if (!_authRepository.isAuthenticated) {
        Get.offAllNamed(Routes.AUTH);
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    await loadDashboard(showLoading: false);
  }

  // ========================================
  // ПОЛНАЯ СИНХРОНИЗАЦИЯ
  // ========================================

  Future<void> startFullSync() async {
    if (!canStartSync.value) {
      print('[HOME] Cannot start sync - button disabled');
      return;
    }

    isFullSyncStarting.value = true;
    canStartSync.value = false;

    try {
      print('[HOME] Starting full sync...');
      final response = await _apiProvider.startFullSync();

      if (response.status == 'INITIATED') {
        Get.snackbar(
          'Синхронизация запущена',
          'Полная синхронизация данных начата',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Constants.primary.withOpacity(0.1),
          colorText: Constants.primary,
          duration: const Duration(seconds: 3),
        );

        // Ждем немного и обновляем dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        _statisticsRepository.clearCache();
        await loadDashboard(showLoading: false);

      } else if (response.status == 'ALREADY_RUNNING') {
        Get.snackbar(
          'Внимание',
          response.message ?? 'Синхронизация уже выполняется',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Constants.warning.withOpacity(0.1),
          colorText: Constants.warning,
          duration: const Duration(seconds: 3),
        );

      } else {
        throw Exception(response.message ?? 'Неизвестная ошибка');
      }
    } catch (e) {
      print('[HOME] Error starting full sync: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось запустить синхронизацию: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Constants.error.withOpacity(0.1),
        colorText: Constants.error,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isFullSyncStarting.value = false;
      _updateSyncAvailability();
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
      }
    }
  }

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
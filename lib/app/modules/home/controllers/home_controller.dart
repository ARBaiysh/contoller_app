import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/app_update_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/api_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';
import '../../../widgets/soft_update_dialog.dart';
import '../../navbar/main_nav_controller.dart';

class HomeController extends GetxController {
  final StatisticsRepository _statisticsRepository = Get.find<StatisticsRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AppUpdateService _appUpdateService = Get.find<AppUpdateService>();

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

  // Таймер для проверки статуса синхронизации
  Timer? _syncStatusTimer;

  @override
  void onInit() {
    super.onInit();
    print('[HOME] Controller initialized: ${hashCode}');
    userName.value = _authRepository.userFullName;
    loadDashboard();
  }

  @override
  void onClose() {
    _stopSyncStatusTimer();
    super.onClose();
  }

  // ========================================
  // МОНИТОРИНГ СИНХРОНИЗАЦИИ
  // ========================================

  void _startSyncStatusMonitoring() {
    _stopSyncStatusTimer();

    _syncStatusTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await loadDashboard(showLoading: false);

      // Если синхронизация завершена, останавливаем таймер
      if (!isFullSyncInProgress.value) {
        _stopSyncStatusTimer();
      }
    });
  }

  void _stopSyncStatusTimer() {
    _syncStatusTimer?.cancel();
    _syncStatusTimer = null;
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
      syncButtonText.value = 'Полная синхронизация'; // Всегда один текст
      minutesUntilSyncAvailable.value = 0;
      return;
    }

    if (dashboardData.lastFullSyncCompleted != null) {
      final now = DateTime.now();
      final localLastSync = dashboardData.lastFullSyncCompleted!.toLocal();

      // Защита от будущих дат
      if (localLastSync.isAfter(now)) {
        canStartSync.value = false;
        minutesUntilSyncAvailable.value = Constants.fullSyncCooldown.inMinutes;
        syncButtonText.value = 'Полная синхронизация'; // Всегда один текст
        return;
      }

      final timeSinceLastSync = now.difference(localLastSync);
      final cooldownMinutes = Constants.fullSyncCooldown.inMinutes;
      final timeSinceInMinutes = timeSinceLastSync.inMinutes;

      if (timeSinceInMinutes < cooldownMinutes) {
        final remaining = cooldownMinutes - timeSinceInMinutes;
        minutesUntilSyncAvailable.value = remaining;
        canStartSync.value = false;
        syncButtonText.value = 'Полная синхронизация'; // Всегда один текст
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

      final dashboardData = await _statisticsRepository.getDashboardStatistics();


      dashboard.value = dashboardData;

      // Обновляем все связанные состояния
      _updateSyncAvailability();

    } catch (e) {
      lastError.value = e.toString();
      hasError.value = true;

      if (!_authRepository.isAuthenticated) {
        Get.offAllNamed(Routes.AUTH);
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;

      if (showLoading && _appUpdateService.softUpdateAvailable) {
        // Показываем диалог после небольшой задержки
        Future.delayed(const Duration(milliseconds: 500), () {
          SoftUpdateDialog.show();
        });
      }

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
        await loadDashboard(showLoading: false);

        // Запускаем мониторинг статуса синхронизации
        _startSyncStatusMonitoring();

      } else if (response.status == 'ALREADY_RUNNING') {
        Get.snackbar(
          'Внимание',
          response.message ?? 'Синхронизация уже выполняется',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Constants.warning.withOpacity(0.1),
          colorText: Constants.warning,
          duration: const Duration(seconds: 3),
        );

        // Обновляем данные и запускаем мониторинг
        await loadDashboard(showLoading: false);
        if (isFullSyncInProgress.value) {
          _startSyncStatusMonitoring();
        }

      } else {
        throw Exception(response.message ?? 'Неизвестная ошибка');
      }
    } catch (e) {
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

// Замените метод logout() в lib/app/modules/home/controllers/home_controller.dart

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Выход из системы',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вы действительно хотите выйти?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'При выходе вам потребуется заново ввести данные для входа',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Отмена',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Get.theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Выйти',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await _authRepository.logout();
      Get.offAllNamed(Routes.AUTH);
    }
  }
}
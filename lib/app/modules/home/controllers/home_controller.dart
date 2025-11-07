import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/app_update_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/soft_update_dialog.dart';
import '../../navbar/main_nav_controller.dart';

class HomeController extends GetxController {
  final StatisticsRepository _statisticsRepository = Get.find<StatisticsRepository>();
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final AppUpdateService _appUpdateService = Get.find<AppUpdateService>();

  // Observable states
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isForceRefreshing = false.obs; // Индикатор принудительного обновления
  Rx<DashboardModel> dashboard = Rx<DashboardModel>(DashboardModel.empty());
  final lastError = ''.obs;
  final hasError = false.obs;

  // User data
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('[HOME] Controller initialized: ${hashCode}');
    userName.value = _authRepository.userFullName;
    loadDashboard();
  }

  // ========================================
  // ЗАГРУЗКА DASHBOARD
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
        Future.delayed(const Duration(milliseconds: 500), () {
          SoftUpdateDialog.show();
        });
      }
    }
  }

  /// Обновление через свайп (pull to refresh) - из кеша
  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    try {
      // Обновляем статистику
      await loadDashboard(showLoading: false);

      // Обновляем абонентов из кеша (forceRefresh=false)
      await _subscriberRepository.getAllSubscribers(forceRefresh: false);
      print('[HOME] Dashboard and subscribers refreshed from cache');
    } catch (e) {
      print('[HOME] Error refreshing dashboard: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Принудительное обновление из 1С (кнопка в AppBar)
  Future<void> forceRefreshFromServer() async {
    if (isForceRefreshing.value) return;

    isForceRefreshing.value = true;

    try {
      print('[HOME] Starting force refresh from 1C...');

      // Обновляем абонентов из 1С (forceRefresh=true)
      await _subscriberRepository.getAllSubscribers(forceRefresh: true);

      // Обновляем статистику
      await _statisticsRepository.getDashboardStatistics();
      final dashboardData = await _statisticsRepository.getDashboardStatistics();
      dashboard.value = dashboardData;

      print('[HOME] Force refresh completed successfully');

      Get.snackbar(
        'Успешно',
        'Данные обновлены из 1С',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('[HOME] Error force refreshing: $e');

      Get.snackbar(
        'Ошибка',
        'Не удалось обновить данные: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isForceRefreshing.value = false;
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

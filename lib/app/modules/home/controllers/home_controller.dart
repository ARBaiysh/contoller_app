import 'package:get/get.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../navbar/main_nav_controller.dart';

class HomeController extends GetxController {
  final StatisticsRepository _statisticsRepository = Get.find<StatisticsRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Observable states
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _dashboard = Rxn<DashboardModel>();
  final _lastError = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  DashboardModel? get dashboard => _dashboard.value;
  String get userName => _authRepository.userFullName;
  String get lastError => _lastError.value;
  bool get hasError => _lastError.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  // Load dashboard statistics
  Future<void> loadDashboard({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.value = true;
    }
    _lastError.value = '';

    try {
      final stats = await _statisticsRepository.getDashboardStatistics();
      _dashboard.value = stats;
    } catch (e) {
      print('[HOME] Error loading dashboard: $e');
      _lastError.value = 'Не удалось загрузить статистику';

      // Показываем snackbar только при первой загрузке
      if (showLoading) {
        Get.snackbar(
          'Ошибка',
          'Не удалось загрузить статистику',
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh dashboard (pull-to-refresh)
  Future<void> refreshDashboard() async {
    _isRefreshing.value = true;
    try {
      final stats = await _statisticsRepository.getDashboardStatistics(forceRefresh: true);
      _dashboard.value = stats;
      _lastError.value = '';
    } catch (e) {
      print('[HOME] Error refreshing dashboard: $e');
      // При обновлении не показываем snackbar, только обновляем ошибку
      _lastError.value = 'Ошибка обновления данных';
    } finally {
      _isRefreshing.value = false;
    }
  }

  // Quick actions navigation
  void navigateToTpList() {
    _switchMainTab(1);
  }

  void navigateToSearch() {
    _switchMainTab(2);
  }

  void navigateToReports() {
    _switchMainTab(3);
  }

  void _switchMainTab(int index) {
    try {
      final nav = Get.find<MainNavController>();
      nav.switchTo(index);
    } catch (_) {
      // Fallback navigation
      switch (index) {
        case 1: Get.toNamed(Routes.TP_LIST); break;
        case 2: Get.toNamed(Routes.SEARCH); break;
        case 3: Get.toNamed(Routes.REPORTS); break;
        default: break;
      }
    }
  }

  // Logout
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
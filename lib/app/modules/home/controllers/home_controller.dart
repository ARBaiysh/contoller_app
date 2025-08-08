import 'package:get/get.dart';
import '../../../data/models/statistics_model.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

import '../../navbar/main_nav_controller.dart';

class HomeController extends GetxController {
  final StatisticsRepository _statisticsRepository = Get.find<StatisticsRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Observable states
  final _isLoading = false.obs;
  final _statistics = Rxn<StatisticsModel>();

  // Getters
  bool get isLoading => _isLoading.value;
  StatisticsModel? get statistics => _statistics.value;
  String get userName => _authRepository.userFullName;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  // Load statistics
  Future<void> loadStatistics() async {
    _isLoading.value = true;
    try {
      final stats = await _statisticsRepository.getStatistics();
      _statistics.value = stats;
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось загрузить статистику');
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh statistics
  Future<void> refreshStatistics() async {
    await loadStatistics();
  }

  // ---- Quick actions should switch tabs, not push screens
  void navigateToTpList() {
    _switchMainTab(1); // TP
  }

  void navigateToSearch() {
    _switchMainTab(2); // Search
  }

  void navigateToReports() {
    _switchMainTab(3); // Reports
  }

  void _switchMainTab(int index) {
    try {
      final nav = Get.find<MainNavController>();
      nav.switchTo(index);
    } catch (_) {
      // Fallback (just in case MainNav is not in tree)
      // You can keep or remove these depending on your route setup
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

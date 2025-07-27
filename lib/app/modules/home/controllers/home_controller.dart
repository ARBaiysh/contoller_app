import 'package:get/get.dart';
import '../../../data/models/statistics_model.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final StatisticsRepository _statisticsRepository = Get.find<StatisticsRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Observable states
  final _isLoading = false.obs;
  final _statistics = Rxn<StatisticsModel>();
  final _currentIndex = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  StatisticsModel? get statistics => _statistics.value;
  int get currentIndex => _currentIndex.value;
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
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить статистику',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh statistics
  Future<void> refreshStatistics() async {
    await loadStatistics();
  }

  // Bottom Navigation bar handler
  void changeTabIndex(int index) {
    _currentIndex.value = index;

    switch (index) {
      case 0:
      // Already on home - refresh data
        refreshStatistics();
        break;
      case 1:
        navigateToTpList();
        break;
      case 2:
        navigateToSearch();
        break;
      case 3:
        navigateToReports();
        break;
    }
  }

  // Navigation methods
  void navigateToTpList() {
    Get.toNamed(Routes.TP_LIST);
  }

  void navigateToSearch() {
    Get.toNamed(Routes.SEARCH);
  }

  void navigateToReports() {
    Get.toNamed(Routes.REPORTS);
  }

  void navigateToSettings() {
    Get.toNamed(Routes.SETTINGS);
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
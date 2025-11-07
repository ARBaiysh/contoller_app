import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/tp_model.dart';
import '../../../data/repositories/tp_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class TpListController extends GetxController {
  final TpRepository _tpRepository = Get.find<TpRepository>();

  // Observable states
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _tpList = <TpModel>[].obs;
  final _filteredTpList = <TpModel>[].obs;
  final _searchQuery = ''.obs;
  final _sortBy = 'default'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<TpModel> get tpList => _filteredTpList;
  bool get isEmpty => _filteredTpList.isEmpty;
  bool get hasData => _filteredTpList.isNotEmpty;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;

  @override
  void onInit() {
    super.onInit();
    loadTpList();
  }

  // ========================================
  // ЗАГРУЗКА ДАННЫХ
  // ========================================

  /// Загрузка списка ТП
  Future<void> loadTpList({bool forceRefresh = false}) async {
    try {
      _isLoading.value = true;
      print('[TP CONTROLLER] Loading TP list (forceRefresh: $forceRefresh)...');

      final tpList = await _tpRepository.getTpList(forceRefresh: forceRefresh);
      _tpList.value = tpList;

      print('[TP CONTROLLER] Loaded ${tpList.length} TPs');
      applyFiltersAndSort();

    } catch (e) {
      print('[TP CONTROLLER] Error loading TP list: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить список ТП',
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  /// Pull-to-refresh - принудительное обновление из 1С
  Future<void> refreshTpList() async {
    _isRefreshing.value = true;
    await loadTpList(forceRefresh: true);
  }

  // ========================================
  // ПОИСК И ФИЛЬТРАЦИЯ
  // ========================================

  /// Поиск ТП
  void searchTps(String query) {
    _searchQuery.value = query;
    applyFiltersAndSort();
  }

  /// Установка сортировки
  void setSorting(String sort) {
    _sortBy.value = sort;
    applyFiltersAndSort();
  }

  /// Применение фильтров и сортировки
  void applyFiltersAndSort() {
    var filtered = _tpRepository.searchTp(_tpList, _searchQuery.value);

    // Фильтрация ТП с 0 абонентов
    filtered = filtered.where((tp) => tp.totalSubscribers > 0).toList();

    // Сортировка
    switch (_sortBy.value) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'code':
        filtered.sort((a, b) => a.code.compareTo(b.code));
        break;
      case 'abonent_count':
        filtered.sort((a, b) => b.abonentCount.compareTo(a.abonentCount));
        break;
      case 'default':
      default:
        filtered.sort((a, b) => a.code.compareTo(b.code));
        break;
    }

    _filteredTpList.value = filtered;
  }

  // ========================================
  // НАВИГАЦИЯ
  // ========================================

  /// Переход к списку абонентов ТП
  void navigateToSubscribers(TpModel tp) {
    Get.toNamed(
      Routes.SUBSCRIBERS,
      arguments: {
        'tpCode': tp.code,
        'tpName': tp.name,
      },
    );
  }

  // ========================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ========================================

  /// Опции сортировки
  List<SortOption> get sortOptions => [
    SortOption(value: 'default', label: 'По умолчанию'),
    SortOption(value: 'name', label: 'По названию'),
    SortOption(value: 'code', label: 'По коду'),
    SortOption(value: 'abonent_count', label: 'По количеству абонентов'),
  ];

  /// Показать диалог сортировки
  void showSortDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Constants.borderRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сортировка',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Constants.paddingM),
            ...sortOptions.map((option) => Obx(() => RadioListTile<String>(
              title: Text(option.label),
              value: option.value,
              groupValue: _sortBy.value,
              onChanged: (value) {
                if (value != null) {
                  setSorting(value);
                  Get.back();
                }
              },
            ))),
            const SizedBox(height: Constants.paddingS),
          ],
        ),
      ),
    );
  }
}

// Модель опции сортировки
class SortOption {
  final String value;
  final String label;

  SortOption({
    required this.value,
    required this.label,
  });
}

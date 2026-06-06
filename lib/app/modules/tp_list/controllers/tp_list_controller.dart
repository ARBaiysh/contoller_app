import 'package:get/get.dart';
import '../../../data/models/tp_model.dart';
import '../../../data/repositories/tp_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/natural_sort.dart';
import '../../../core/services/sort_prefs_service.dart';
import '../../../widgets/sort_bottom_sheet.dart';

class TpListController extends GetxController {
  final TpRepository _tpRepository = Get.find<TpRepository>();
  final SortPrefsService _sortPrefs = Get.find<SortPrefsService>();

  // Observable states
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _tpList = <TpModel>[].obs;
  final _filteredTpList = <TpModel>[].obs;
  final _searchQuery = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<TpModel> get tpList => _filteredTpList;
  bool get isEmpty => _filteredTpList.isEmpty;
  bool get hasData => _filteredTpList.isNotEmpty;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortPrefs.tpSort.value;

  @override
  void onInit() {
    super.onInit();
    // Реагируем на смену порядка по умолчанию (например, из Настроек).
    ever(_sortPrefs.tpSort, (_) => applyFiltersAndSort());
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
      AppSnackbar.error('Ошибка', 'Не удалось загрузить список ТП');
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

  /// Установка сортировки (сохраняется постоянно).
  void setSorting(String sort) {
    _sortPrefs.setTpSort(sort);
    applyFiltersAndSort();
  }

  /// Применение фильтров и сортировки
  void applyFiltersAndSort() {
    var filtered = _tpRepository.searchTp(_tpList, _searchQuery.value);

    // Фильтрация ТП с 0 абонентов
    filtered = filtered.where((tp) => tp.totalSubscribers > 0).toList();

    // Сортировка
    switch (_sortPrefs.tpSort.value) {
      case 'name':
        filtered.sort((a, b) => naturalCompare(a.name, b.name));
        break;
      case 'abonent_count':
        filtered.sort((a, b) => b.abonentCount.compareTo(a.abonentCount));
        break;
      case 'code':
      default:
        filtered.sort((a, b) => naturalCompare(a.code, b.code));
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

  /// Показать шторку сортировки
  void showSortDialog() {
    SortBottomSheet.show(
      title: 'Сортировка ТП',
      options: SortPrefsService.tpOptions,
      selected: _sortPrefs.tpSort.value,
      onSelected: setSorting,
    );
  }
}

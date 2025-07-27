import 'package:get/get.dart';
import '../../../data/models/tp_model.dart';
import '../../../data/repositories/tp_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class TpListController extends GetxController {
  final TpRepository _tpRepository = Get.find<TpRepository>();

  // Observable states
  final _isLoading = false.obs;
  final _tpList = <TpModel>[].obs;
  final _filteredTpList = <TpModel>[].obs;
  final _selectedFilter = 'all'.obs;
  final _searchQuery = ''.obs;
  final _sortBy = 'default'.obs; // Добавляем состояние для сортировки

  // Getters
  bool get isLoading => _isLoading.value;
  List<TpModel> get tpList => _filteredTpList;
  String get selectedFilter => _selectedFilter.value;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;
  int get totalTps => _tpList.length;
  int get completedTps => _tpList.where((tp) => tp.isCompleted).length;
  int get inProgressTps => _tpList.where((tp) => !tp.isCompleted).length;

  @override
  void onInit() {
    super.onInit();
    loadTpList();
  }

  // Load TP list
  Future<void> loadTpList() async {
    _isLoading.value = true;
    try {
      final tps = await _tpRepository.getTpList();
      _tpList.value = tps;
      applyFilter();
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить список ТП',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Constants.error.withOpacity(0.1),
        colorText: Constants.error,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh TP list
  Future<void> refreshTpList() async {
    await loadTpList();
  }

  // Apply filter
  void applyFilter() {
    List<TpModel> filtered = List.from(_tpList);

    // Apply status filter
    switch (_selectedFilter.value) {
      case 'completed':
        filtered = filtered.where((tp) => tp.isCompleted).toList();
        break;
      case 'in_progress':
        filtered = filtered.where((tp) => !tp.isCompleted).toList();
        break;
      case 'all':
      default:
      // No filtering needed
        break;
    }

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((tp) {
        return tp.number.toLowerCase().contains(query) ||
            tp.name.toLowerCase().contains(query) ||
            tp.address.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy.value) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'number':
        filtered.sort((a, b) => a.number.compareTo(b.number));
        break;
      case 'progress':
        filtered.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
        break;
      case 'default':
      default:
      // Sort by progress (uncompleted first)
        filtered.sort((a, b) {
          if (a.isCompleted && !b.isCompleted) return 1;
          if (!a.isCompleted && b.isCompleted) return -1;
          return a.progressPercentage.compareTo(b.progressPercentage);
        });
        break;
    }

    _filteredTpList.value = filtered;
  }

  // Set filter
  void setFilter(String filter) {
    _selectedFilter.value = filter;
    applyFilter();
  }

  // Search TPs
  void searchTps(String query) {
    _searchQuery.value = query;
    applyFilter();
  }

  // Set sorting
  void setSorting(String sort) {
    _sortBy.value = sort;
    applyFilter();
  }

  // Navigate to subscribers
  void navigateToSubscribers(TpModel tp) {
    Get.toNamed(
      Routes.SUBSCRIBERS,
      arguments: {
        'tpId': tp.id,
        'tpName': '${tp.number} ${tp.name}',
      },
    );
  }

  // Get filter options
  List<FilterOption> get filterOptions => [
    FilterOption(
      value: 'all',
      label: 'Все ТП',
      count: _tpList.length,
    ),
    FilterOption(
      value: 'in_progress',
      label: 'В работе',
      count: inProgressTps,
    ),
    FilterOption(
      value: 'completed',
      label: 'Завершены',
      count: completedTps,
    ),
  ];

  // Get sort options
  List<SortOption> get sortOptions => [
    SortOption(value: 'default', label: 'По умолчанию'),
    SortOption(value: 'name', label: 'По названию'),
    SortOption(value: 'number', label: 'По номеру'),
    SortOption(value: 'progress', label: 'По прогрессу'),
  ];
}

// Filter option model
class FilterOption {
  final String value;
  final String label;
  final int count;

  FilterOption({
    required this.value,
    required this.label,
    required this.count,
  });
}

// Sort option model
class SortOption {
  final String value;
  final String label;

  SortOption({
    required this.value,
    required this.label,
  });
}
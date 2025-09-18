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
  final _isSyncing = false.obs;
  final _tpList = <TpModel>[].obs;
  final _filteredTpList = <TpModel>[].obs;
  final _searchQuery = ''.obs;
  final _sortBy = 'default'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSyncing => _isSyncing.value;
  List<TpModel> get tpList => _filteredTpList;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;
  int get totalTps => _tpList.length;

  @override
  void onInit() {
    super.onInit();
    loadTpList();
  }

  // Load TP list
  Future<void> loadTpList({bool forceRefresh = false}) async {
    _isLoading.value = true;
    try {
      final tps = await _tpRepository.getTpList(forceRefresh: forceRefresh);
      _tpList.value = tps;
      applyFiltersAndSort();
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Sync TP abonents
  Future<void> syncTpAbonents(String tpCode) async {
    _isSyncing.value = true;
    try {
      final result = await _tpRepository.syncTpAbonents(tpCode);

      Get.snackbar(
        'Синхронизация завершена',
        'Синхронизировано: ${result['synced'] ?? 0}, '
            'Создано: ${result['created'] ?? 0}, '
            'Обновлено: ${result['updated'] ?? 0}',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
      );

      // Перезагружаем список для обновления статистики
      await loadTpList();
    } catch (e) {
      Get.snackbar(
        'Ошибка синхронизации',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
      );
    } finally {
      _isSyncing.value = false;
    }
  }

  // Refresh TP list
  Future<void> refreshTpList() async {
    await loadTpList(forceRefresh: true);
  }

  // Apply filters and sorting
  void applyFiltersAndSort() {
    var filtered = List<TpModel>.from(_tpList);

    // Apply search
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((tp) {
        return tp.number.toLowerCase().contains(query) ||
            tp.name.toLowerCase().contains(query) ||
            tp.fider.toLowerCase().contains(query);
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
      // Сортировка по умолчанию - по номеру
        filtered.sort((a, b) => a.number.compareTo(b.number));
        break;
    }

    _filteredTpList.value = filtered;
  }

  // Search TPs
  void searchTps(String query) {
    _searchQuery.value = query;
    applyFiltersAndSort();
  }

  // Set sorting
  void setSorting(String sort) {
    _sortBy.value = sort;
    applyFiltersAndSort();
  }

  // Navigate to subscribers
  void navigateToSubscribers(TpModel tp) {
    Get.toNamed(
      Routes.SUBSCRIBERS,
      arguments: {
        'tpId': tp.id,
        'tpCode': tp.id, // Для API используем id как code
        'tpName': '${tp.number} ${tp.name}',
      },
    );
  }

  // Get sort options (упрощенные)
  List<SortOption> get sortOptions => [
    SortOption(value: 'default', label: 'По умолчанию'),
    SortOption(value: 'name', label: 'По названию'),
    SortOption(value: 'number', label: 'По номеру'),
    SortOption(value: 'progress', label: 'По прогрессу'),
  ];
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
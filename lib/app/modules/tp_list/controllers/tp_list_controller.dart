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
  final _syncProgress = ''.obs;
  final _syncElapsed = Duration.zero.obs;
  final _tpList = <TpModel>[].obs;
  final _filteredTpList = <TpModel>[].obs;
  final _searchQuery = ''.obs;
  final _sortBy = 'default'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSyncing => _isSyncing.value;
  String get syncProgress => _syncProgress.value;
  Duration get syncElapsed => _syncElapsed.value;
  List<TpModel> get tpList => _filteredTpList;
  bool get isEmpty => _tpList.isEmpty;
  bool get hasData => _tpList.isNotEmpty;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;

  // Форматированное время синхронизации
  String get syncElapsedFormatted {
    final minutes = _syncElapsed.value.inMinutes;
    final seconds = _syncElapsed.value.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    loadTpList();
  }

  // ========================================
  // ОСНОВНЫЕ МЕТОДЫ
  // ========================================

  /// Загрузка списка ТП
  Future<void> loadTpList({bool forceRefresh = false}) async {
    if (_isSyncing.value) return; // Не загружаем во время синхронизации

    try {
      _isLoading.value = true;
      print('[TP CONTROLLER] Loading TP list...');

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
    }
  }

  /// Pull-to-refresh
  Future<void> refreshTpList() async {
    await loadTpList(forceRefresh: true);
  }

  // ========================================
  // СИНХРОНИЗАЦИЯ
  // ========================================

  Future<void> syncTpList() async {
    if (_isSyncing.value || _isLoading.value) return;

    print('[TP CONTROLLER] Starting TP sync...');

    await _tpRepository.syncTpList(
      onSyncStarted: _onSyncStarted,
      onProgress: _onSyncProgress,
      onSuccess: _onSyncSuccess,      // Изменено с onSyncCompleted
      onError: _onSyncError,          // Изменено с onSyncError
    );
  }

  /// Колбэк: синхронизация запущена
  void _onSyncStarted() {
    _isSyncing.value = true;
    _syncProgress.value = 'Запуск синхронизации...';
    _syncElapsed.value = Duration.zero;

    print('[TP CONTROLLER] Sync started');

    Get.snackbar(
      'Синхронизация',
      'Запущена синхронизация списка ТП',
      backgroundColor: Constants.info.withValues(alpha: 0.1),
      colorText: Constants.info,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Колбэк: прогресс синхронизации
  void _onSyncProgress(String message, Duration elapsed) {
    _syncProgress.value = message;
    _syncElapsed.value = elapsed;
    print('[TP CONTROLLER] Sync progress: $message (${elapsed.inSeconds}s)');
  }

  /// Колбэк: синхронизация завершена успешно
  void _onSyncSuccess() async {
    _isSyncing.value = false;
    _syncProgress.value = '';
    _syncElapsed.value = Duration.zero;

    print('[TP CONTROLLER] Sync completed successfully');

    Get.snackbar(
      'Успешно',
      'Синхронизация завершена',
      backgroundColor: Constants.success.withValues(alpha: 0.1),
      colorText: Constants.success,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );

    // Автоматически обновляем список после успешной синхронизации
    await loadTpList(forceRefresh: true);
  }

  /// Колбэк: ошибка синхронизации
  void _onSyncError(String error) {
    _isSyncing.value = false;
    _syncProgress.value = '';
    _syncElapsed.value = Duration.zero;

    print('[TP CONTROLLER] Sync failed: $error');

    Get.snackbar(
      'Ошибка синхронизации',
      error,
      backgroundColor: Constants.error.withValues(alpha: 0.1),
      colorText: Constants.error,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
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
    var filtered = List<TpModel>.from(_tpList);

    // Поиск
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((tp) {
        return tp.number.toLowerCase().contains(query) ||
            tp.name.toLowerCase().contains(query) ||
            tp.fider.toLowerCase().contains(query);
      }).toList();
    }

    // Сортировка
    switch (_sortBy.value) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'number':
        filtered.sort((a, b) => a.number.compareTo(b.number));
        break;
      case 'fider':
        filtered.sort((a, b) => a.fider.compareTo(b.fider));
        break;
      case 'default':
      default:
        filtered.sort((a, b) => a.number.compareTo(b.number));
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
        'tpId': tp.id,
        'tpCode': tp.id,
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
    SortOption(value: 'number', label: 'По номеру'),
    SortOption(value: 'fider', label: 'По фидеру'),
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
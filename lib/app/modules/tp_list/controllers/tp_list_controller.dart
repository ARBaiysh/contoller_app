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

  // ДОБАВЛЕНО: Новые реактивные переменные для замены геттеров с логикой
  final _isEmpty = true.obs;
  final _hasData = false.obs;
  final _syncElapsedFormatted = '00:00'.obs;

  // Getters - просто возвращают значения
  bool get isLoading => _isLoading.value;
  bool get isSyncing => _isSyncing.value;
  String get syncProgress => _syncProgress.value;
  Duration get syncElapsed => _syncElapsed.value;
  List<TpModel> get tpList => _filteredTpList;
  bool get isEmpty => _isEmpty.value;  // ИЗМЕНЕНО
  bool get hasData => _hasData.value;  // ИЗМЕНЕНО
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;
  String get syncElapsedFormatted => _syncElapsedFormatted.value;  // ИЗМЕНЕНО

  @override
  void onInit() {
    super.onInit();

    // ДОБАВЛЕНО: Слушатели для обновления зависимых состояний
    _tpList.listen((_) => _updateListState());
    _syncElapsed.listen((_) => _updateSyncElapsedFormatted());

    loadTpList();
  }

  // ДОБАВЛЕНО: Метод для обновления состояния списка
  void _updateListState() {
    _isEmpty.value = _tpList.isEmpty;
    _hasData.value = _tpList.isNotEmpty;
  }

  // ДОБАВЛЕНО: Метод для форматирования времени синхронизации
  void _updateSyncElapsedFormatted() {
    final minutes = _syncElapsed.value.inMinutes;
    final seconds = _syncElapsed.value.inSeconds % 60;
    _syncElapsedFormatted.value = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
      _updateListState(); // ДОБАВЛЕНО: обновляем состояние

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

// ========================================
  // СИНХРОНИЗАЦИЯ
  // ========================================

  Future<void> syncTpList() async {
    // ✅ ЗАЩИТА: Проверяем, не идет ли уже синхронизация
    if (_isSyncing.value || _isLoading.value) {
      print('[TP CONTROLLER] ⚠️ Sync already in progress, ignoring click');
      return;
    }

    // ✅ СРАЗУ устанавливаем флаг, чтобы заблокировать повторные нажатия
    _isSyncing.value = true;
    _syncProgress.value = 'Инициализация синхронизации...';
    _syncElapsed.value = Duration.zero;
    _updateSyncElapsedFormatted();

    print('[TP CONTROLLER] Starting TP sync...');

    try {
      await _tpRepository.syncTpList(
        onSyncStarted: _onSyncStarted,
        onProgress: _onSyncProgress,
        onSuccess: _onSyncSuccess,
        onError: _onSyncError,
      );
    } catch (e) {
      // ✅ Если произошла ошибка ДО вызова колбэков, сбрасываем флаг
      print('[TP CONTROLLER] ❌ Error before sync started: $e');
      _isSyncing.value = false;
      _syncProgress.value = '';

      Get.snackbar(
        'Ошибка',
        'Не удалось запустить синхронизацию: ${e.toString()}',
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Колбэк: синхронизация запущена
  void _onSyncStarted() {
    // Флаг уже установлен в syncTpList()
    _syncProgress.value = 'Запуск синхронизации...';
    print('[TP CONTROLLER] Sync confirmed by server');

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
    _updateSyncElapsedFormatted();

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
    _updateSyncElapsedFormatted();

    print('[TP CONTROLLER] Sync failed: $error');

    Get.snackbar(
      'Ошибка синхронизации',
      error,
      backgroundColor: Constants.error.withValues(alpha: 0.1),
      colorText: Constants.error,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
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
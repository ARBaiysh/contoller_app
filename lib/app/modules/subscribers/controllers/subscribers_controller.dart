import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../core/values/constants.dart';
import '../../../routes/app_pages.dart';

class SubscribersController extends GetxController {
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();

  // Arguments
  late String tpId;
  late String tpCode;
  late String tpName;

  // Observable states
  final _isLoading = false.obs;
  final _isSyncing = false.obs;
  final _syncProgress = ''.obs;
  final _syncElapsed = Duration.zero.obs;
  final _subscribers = <SubscriberModel>[].obs;
  final _filteredSubscribers = <SubscriberModel>[].obs;
  final _selectedStatus = 'all'.obs;
  final _searchQuery = ''.obs;
  final _sortBy = 'default'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSyncing => _isSyncing.value;
  String get syncProgress => _syncProgress.value;
  Duration get syncElapsed => _syncElapsed.value;
  List<SubscriberModel> get subscribers => _filteredSubscribers;
  String get selectedStatus => _selectedStatus.value;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;
  bool get isEmpty => _subscribers.isEmpty;
  bool get hasData => _subscribers.isNotEmpty;

  // Форматированное время синхронизации MM:SS / MAX_TIME
  String get syncElapsedFormatted {
    final minutes = _syncElapsed.value.inMinutes;
    final seconds = _syncElapsed.value.inSeconds % 60;
    final maxMinutes = Constants.abonentsSyncTimeout.inMinutes;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} / ${maxMinutes.toString().padLeft(2, '0')}:00';
  }

  // Statistics
  int get totalSubscribers => _subscribers.length;
  int get readingsCollected => _subscribers.where((s) => _hasReadingInCurrentMonth(s)).length;
  int get readingsAvailable => _subscribers.where((s) => s.canTakeReading && !_hasReadingInCurrentMonth(s)).length;
  int get debtorsCount => _subscribers.where((s) => s.isDebtor).length;
  int get blockedCount => _subscribers.where((s) => !s.canTakeReading).length;

  bool _hasReadingInCurrentMonth(SubscriberModel subscriber) {
    if (subscriber.lastReadingDate == null) return false;
    final now = DateTime.now();
    return subscriber.lastReadingDate!.year == now.year &&
        subscriber.lastReadingDate!.month == now.month;
  }

  List<Map<String, dynamic>> get statusFilterOptions {
    return [
      {
        'value': 'all',
        'label': 'Все',
        'count': totalSubscribers,
        'color': Colors.blueAccent,
      },
      {
        'value': 'available',
        'label': 'Обход',
        'count': readingsAvailable,
        'color': Colors.green,
      },
      {
        'value': 'completed',
        'label': 'Пройдены',
        'count': readingsCollected,
        'color': Colors.blue,
      },
      {
        'value': 'debtors',
        'label': 'Должники',
        'count': debtorsCount,
        'color': Colors.red,
      },
    ];
  }

  @override
  void onInit() {
    super.onInit();

    // Получаем параметры
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    tpId = args['tpId'] ?? '';
    tpCode = args['tpCode'] ?? tpId; // Используем tpId как tpCode если не передан
    tpName = args['tpName'] ?? 'ТП';

    print('[SUBSCRIBERS CONTROLLER] Initialized for TP: $tpCode ($tpName)');

    // Загружаем абонентов
    loadSubscribers();
  }

  // ========================================
  // ОСНОВНЫЕ МЕТОДЫ ЗАГРУЗКИ
  // ========================================

  /// Загрузка списка абонентов
  Future<void> loadSubscribers({bool forceRefresh = false}) async {
    if (_isSyncing.value) return; // Не загружаем во время синхронизации

    try {
      _isLoading.value = true;
      print('[SUBSCRIBERS CONTROLLER] Loading subscribers for TP: $tpCode');

      final subscribersList = await _subscriberRepository.getSubscribersByTp(
        tpCode,
        forceRefresh: forceRefresh,
      );

      _subscribers.value = subscribersList;
      print('[SUBSCRIBERS CONTROLLER] Loaded ${subscribersList.length} subscribers');

      applyFiltersAndSort();
    } catch (e) {
      print('[SUBSCRIBERS CONTROLLER] Error loading subscribers: $e');
      Get.snackbar(
        'Ошибка',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Pull-to-refresh
  Future<void> refreshSubscribers() async {
    await loadSubscribers(forceRefresh: true);
  }

  // ========================================
  // СИНХРОНИЗАЦИЯ С ПРОГРЕССОМ
  // ========================================

  /// Запуск синхронизации абонентов с SyncService
  Future<void> syncSubscribers() async {
    if (_isSyncing.value || _isLoading.value) return;

    print('[SUBSCRIBERS CONTROLLER] Starting abonents sync for TP: $tpCode');

    await _subscriberRepository.syncAbonentsList(
      tpCode,
      onSyncStarted: _onSyncStarted,
      onProgress: _onSyncProgress,
      onSuccess: _onSyncSuccess,
      onError: _onSyncError,
    );
  }

  /// Колбэк: синхронизация запущена
  void _onSyncStarted() {
    _isSyncing.value = true;
    _syncProgress.value = 'Запуск синхронизации абонентов...';
    _syncElapsed.value = Duration.zero;

    print('[SUBSCRIBERS CONTROLLER] Abonents sync started for TP: $tpCode');

    Get.snackbar(
      'Синхронизация',
      'Запущена синхронизация абонентов для $tpName',
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.primary,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Колбэк: прогресс синхронизации с таймером
  void _onSyncProgress(String message, Duration elapsed) {
    _syncProgress.value = message;
    _syncElapsed.value = elapsed;
    print('[SUBSCRIBERS CONTROLLER] Abonents sync progress: $message (${elapsed.inSeconds}s)');
  }

  /// Колбэк: синхронизация завершена успешно
  void _onSyncSuccess() async {
    _isSyncing.value = false;
    _syncProgress.value = '';
    _syncElapsed.value = Duration.zero;

    print('[SUBSCRIBERS CONTROLLER] Abonents sync completed successfully for TP: $tpCode');

    Get.snackbar(
      'Успешно',
      'Синхронизация абонентов завершена',
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );

    // Автообновление списка после успешной синхронизации
    await loadSubscribers(forceRefresh: true);
  }

  /// Колбэк: ошибка синхронизации
  void _onSyncError(String error) {
    _isSyncing.value = false;
    _syncProgress.value = '';
    _syncElapsed.value = Duration.zero;

    print('[SUBSCRIBERS CONTROLLER] Abonents sync failed for TP $tpCode: $error');

    Get.snackbar(
      'Ошибка синхронизации',
      error,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
    );
  }

  // ========================================
  // ФИЛЬТРАЦИЯ И СОРТИРОВКА
  // ========================================

  /// Применение фильтров и сортировки
  void applyFiltersAndSort() {
    var filtered = List<SubscriberModel>.from(_subscribers);

    // Применяем фильтр по статусу
    switch (_selectedStatus.value) {
      case 'available':
      // Нужен обход: не заблокирован И нет показания в текущем месяце
        filtered = filtered.where((s) =>
        s.canTakeReading && !_hasReadingInCurrentMonth(s)
        ).toList();
        break;
      case 'completed':
      // Пройден: есть показание в текущем месяце (независимо от блокировки)
        filtered = filtered.where((s) => _hasReadingInCurrentMonth(s)).toList();
        break;
      case 'debtors':
        filtered = filtered.where((s) => s.isDebtor).toList();
        break;
      case 'all':
      default:
      // Показываем всех
        break;
    }

    // Применяем поиск
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((s) {
        return s.accountNumber.toLowerCase().contains(query) ||
            s.fullName.toLowerCase().contains(query) ||
            s.address.toLowerCase().contains(query);
      }).toList();
    }

    // Применяем сортировку
    switch (_sortBy.value) {
      case 'name':
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'address':
        filtered.sort((a, b) => a.address.compareTo(b.address));
        break;
      case 'debt':
        filtered.sort((a, b) => a.balance.compareTo(b.balance));
        break;
      case 'account':
        filtered.sort((a, b) => a.accountNumber.compareTo(b.accountNumber));
        break;
      case 'default':
      default:
      // Сортировка по статусу (сначала доступные для снятия показаний, потом по адресу)
        filtered.sort((a, b) {
          // Сначала сортируем по возможности снятия показаний
          if (a.canTakeReading && !b.canTakeReading) return -1;
          if (!a.canTakeReading && b.canTakeReading) return 1;

          // Затем по адресу
          return a.address.compareTo(b.address);
        });
        break;
    }

    _filteredSubscribers.value = filtered;
    print('[SUBSCRIBERS CONTROLLER] Applied filters: ${_selectedStatus.value}, '
        'search: "${_searchQuery.value}", sort: ${_sortBy.value}. '
        'Result: ${filtered.length}/${_subscribers.length}');
  }

  /// Установка фильтра по статусу
  void setStatusFilter(String status) {
    _selectedStatus.value = status;
    applyFiltersAndSort();
    print('[SUBSCRIBERS CONTROLLER] Status filter changed to: $status');
  }

  /// Поиск абонентов
  void searchSubscribers(String query) {
    _searchQuery.value = query;
    applyFiltersAndSort();
    print('[SUBSCRIBERS CONTROLLER] Search query changed to: "$query"');
  }

  /// Установка сортировки
  void setSorting(String sort) {
    _sortBy.value = sort;
    applyFiltersAndSort();
    print('[SUBSCRIBERS CONTROLLER] Sort changed to: $sort');
  }

  // ========================================
  // НАВИГАЦИЯ
  // ========================================

  /// Переход к детальной информации абонента
  void navigateToSubscriberDetail(SubscriberModel subscriber) {
    print('[SUBSCRIBERS CONTROLLER] Navigating to subscriber detail: ${subscriber.accountNumber}');

    Get.toNamed(
      Routes.SUBSCRIBER_DETAIL,
      arguments: {
        'subscriber': subscriber, // ИСПРАВЛЕНО: Передаем объект целиком
        'tpName': tpName,
        'tpCode': tpCode,
      },
    );
  }

  // ========================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ========================================

  /// Получение статистики для отображения в UI
  Map<String, dynamic> getStatistics() {
    return {
      'total': totalSubscribers,
      'available': readingsAvailable,
      'completed': readingsCollected,
      'debtors': debtorsCount,
      'progress': totalSubscribers > 0 ? (readingsCollected / totalSubscribers) * 100 : 0,
    };
  }
}
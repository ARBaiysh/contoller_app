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
  final _subscribers = <SubscriberModel>[].obs;
  final _filteredSubscribers = <SubscriberModel>[].obs;
  final _selectedStatus = 'all'.obs;
  final _searchQuery = ''.obs;
  final _sortBy = 'default'.obs;

  // Новые реактивные переменные для замены геттеров с логикой
  final _isEmpty = true.obs;
  final _hasData = false.obs;
  final _totalSubscribers = 0.obs;
  final _readingsCollected = 0.obs;
  final _readingsAvailable = 0.obs;
  final _debtorsCount = 0.obs;
  final _blockedCount = 0.obs;
  final _statusFilterOptions = <Map<String, dynamic>>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<SubscriberModel> get subscribers => _filteredSubscribers;
  String get selectedStatus => _selectedStatus.value;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;
  bool get isEmpty => _isEmpty.value;
  bool get hasData => _hasData.value;
  int get totalSubscribers => _totalSubscribers.value;
  int get readingsCollected => _readingsCollected.value;
  int get readingsAvailable => _readingsAvailable.value;
  int get debtorsCount => _debtorsCount.value;
  int get blockedCount => _blockedCount.value;
  List<Map<String, dynamic>> get statusFilterOptions => _statusFilterOptions;

  @override
  void onInit() {
    super.onInit();

    // Слушатели для обновления зависимых состояний
    _subscribers.listen((_) => _updateStatistics());
    _selectedStatus.listen((_) => _updateStatusFilterOptions());

    // Получаем параметры
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    tpId = args['tpId'] ?? '';
    tpCode = args['tpCode'] ?? tpId; // Используем tpId как tpCode если не передан
    tpName = args['tpName'] ?? 'ТП';

    print('[SUBSCRIBERS CONTROLLER] Initialized for TP: $tpCode ($tpName)');

    // Загружаем абонентов
    loadSubscribers();
  }

  // Вспомогательный метод для проверки показания в текущем месяце
  bool _hasReadingInCurrentMonth(SubscriberModel subscriber) {
    if (subscriber.lastReadingDate == null) return false;
    final now = DateTime.now();
    return subscriber.lastReadingDate!.year == now.year &&
        subscriber.lastReadingDate!.month == now.month;
  }

  // Обновление всех статистик
  void _updateStatistics() {
    _isEmpty.value = _subscribers.isEmpty;
    _hasData.value = _subscribers.isNotEmpty;
    _totalSubscribers.value = _subscribers.length;
    _readingsCollected.value = _subscribers.where((s) => _hasReadingInCurrentMonth(s)).length;
    _readingsAvailable.value = _subscribers.where((s) => s.canTakeReading && !_hasReadingInCurrentMonth(s)).length;
    _debtorsCount.value = _subscribers.where((s) => s.isDebtor).length;
    _blockedCount.value = _subscribers.where((s) => !s.canTakeReading).length;

    _updateStatusFilterOptions();
  }

  // Обновление опций фильтра статуса
  void _updateStatusFilterOptions() {
    _statusFilterOptions.value = [
      {
        'value': 'all',
        'label': 'Все',
        'count': _totalSubscribers.value,
        'color': Colors.blueAccent,
      },
      {
        'value': 'available',
        'label': 'Обход',
        'count': _readingsAvailable.value,
        'color': Colors.green,
      },
      {
        'value': 'completed',
        'label': 'Пройдены',
        'count': _readingsCollected.value,
        'color': Colors.blue,
      },
      {
        'value': 'debtors',
        'label': 'Должники',
        'count': _debtorsCount.value,
        'color': Colors.red,
      },
    ];
  }

  // ========================================
  // ОСНОВНЫЕ МЕТОДЫ ЗАГРУЗКИ
  // ========================================

  /// Загрузка списка абонентов
  Future<void> loadSubscribers({bool forceRefresh = false}) async {
    try {
      _isLoading.value = true;
      print('[SUBSCRIBERS CONTROLLER] Loading subscribers for TP: $tpCode');

      final subscribersList = await _subscriberRepository.getSubscribersByTp(
        tpCode,
        forceRefresh: forceRefresh,
      );

      _subscribers.value = subscribersList;
      _updateStatistics();
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
  // ФИЛЬТРАЦИЯ И СОРТИРОВКА
  // ========================================

  /// Применение фильтров и сортировки
  void applyFiltersAndSort() {
    var filtered = List<SubscriberModel>.from(_subscribers);

    // Применяем фильтр по статусу
    switch (_selectedStatus.value) {
      case 'available':
        filtered = filtered.where((s) =>
        s.canTakeReading && !_hasReadingInCurrentMonth(s)
        ).toList();
        break;
      case 'completed':
        filtered = filtered.where((s) => _hasReadingInCurrentMonth(s)).toList();
        break;
      case 'debtors':
        filtered = filtered.where((s) => s.isDebtor).toList();
        break;
      case 'all':
      default:
        break;
    }

    // ОБНОВЛЯЕМ ПОИСК - добавляем поиск по номеру счётчика
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((s) =>
      s.fullName.toLowerCase().contains(query) ||
          s.accountNumber.toLowerCase().contains(query) ||
          s.address.toLowerCase().contains(query) ||
          s.meterSerialNumber.toLowerCase().contains(query) // НОВОЕ: поиск по номеру счётчика
      ).toList();
    }

    // Применяем сортировку
    switch (_sortBy.value) {
      case 'name':
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'account':
        filtered.sort((a, b) => a.accountNumber.compareTo(b.accountNumber));
        break;
      case 'address':
        filtered.sort((a, b) => a.address.compareTo(b.address));
        break;
      case 'debt':
        filtered.sort((a, b) => b.debtAmount.compareTo(a.debtAmount));
        break;
      case 'default':
      default:
        filtered.sort((a, b) {
          final aAvailable = a.canTakeReading && !_hasReadingInCurrentMonth(a);
          final bAvailable = b.canTakeReading && !_hasReadingInCurrentMonth(b);
          if (aAvailable != bAvailable) {
            return aAvailable ? -1 : 1;
          }
          return a.fullName.compareTo(b.fullName);
        });
        break;
    }

    _filteredSubscribers.value = filtered;
    print('[SUBSCRIBERS CONTROLLER] Filters applied. Result: ${filtered.length}/${_subscribers.length}');
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
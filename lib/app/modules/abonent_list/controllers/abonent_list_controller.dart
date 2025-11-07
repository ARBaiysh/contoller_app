import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../routes/app_pages.dart';

enum AbonentListType {
  consumption, // Показания
  payments,    // Оплатившие
}

enum DateFilter {
  all,   // Все
  today, // За сегодня
}

class AbonentListController extends GetxController {
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();

  // Arguments
  late AbonentListType listType;

  // Text controller for search
  final TextEditingController searchTextController = TextEditingController();

  // Debounce timer
  Timer? _debounce;

  // Observable states
  final _isLoading = false.obs;
  final _abonents = <SubscriberModel>[].obs;
  final _filteredAbonents = <SubscriberModel>[].obs;
  final _searchQuery = ''.obs;
  final _dateFilter = DateFilter.all.obs;

  // Statistics
  final _totalCount = 0.obs;
  final _debtorsCount = 0.obs;
  final _totalConsumption = 0.0.obs;
  final _totalAmount = 0.0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<SubscriberModel> get abonents => _filteredAbonents;
  String get searchQuery => _searchQuery.value;
  DateFilter get dateFilter => _dateFilter.value;
  int get totalCount => _totalCount.value;
  int get debtorsCount => _debtorsCount.value;
  double get totalConsumption => _totalConsumption.value;
  double get totalAmount => _totalAmount.value;

  String get title {
    switch (listType) {
      case AbonentListType.consumption:
        return 'Показания этого месяца';
      case AbonentListType.payments:
        return 'Оплатившие этого месяца';
    }
  }

  String get emptyMessage {
    switch (listType) {
      case AbonentListType.consumption:
        return 'Нет абонентов с показаниями';
      case AbonentListType.payments:
        return 'Нет абонентов с оплатами';
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Get arguments
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final typeString = args['type'] as String? ?? 'consumption';
    listType = typeString == 'payments'
        ? AbonentListType.payments
        : AbonentListType.consumption;

    print('[ABONENT LIST] Initialized with type: $listType');

    // Load data
    loadAbonents();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  // ========================================
  // ЗАГРУЗКА ДАННЫХ
  // ========================================

  Future<void> loadAbonents() async {
    try {
      _isLoading.value = true;

      List<SubscriberModel> subscribers;
      switch (listType) {
        case AbonentListType.consumption:
          subscribers = await _subscriberRepository.getAbonentsWithConsumption();
          break;
        case AbonentListType.payments:
          subscribers = await _subscriberRepository.getAbonentsWithPayments();
          break;
      }

      _abonents.value = subscribers;
      applyFilters(); // _updateStatistics вызывается внутри applyFilters

      print('[ABONENT LIST] Loaded ${subscribers.length} abonents');
    } catch (e) {
      print('[ABONENT LIST] Error loading abonents: $e');
      Get.snackbar(
        'Ошибка',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ========================================
  // СТАТИСТИКА
  // ========================================

  void _updateStatistics() {
    // Считаем статистику только по отфильтрованным данным
    _totalCount.value = _filteredAbonents.length;
    _debtorsCount.value = _filteredAbonents.where((a) => a.isDebtor).length;

    // Подсчет суммы в зависимости от типа списка
    switch (listType) {
      case AbonentListType.consumption:
        // Суммарное потребление в кВт·ч
        _totalConsumption.value = _filteredAbonents.fold(
          0.0,
          (sum, a) => sum + (a.currentMonthConsumption ?? 0.0),
        );
        // Сумма начислений за текущий месяц
        _totalAmount.value = _filteredAbonents.fold(
          0.0,
          (sum, a) => sum + (a.currentMonthCharge ?? 0.0),
        );
        break;
      case AbonentListType.payments:
        // Для платежей потребление не показываем
        _totalConsumption.value = 0.0;
        // Сумма последних платежей
        _totalAmount.value = _filteredAbonents.fold(
          0.0,
          (sum, a) => sum + (a.lastPaymentAmount ?? 0.0),
        );
        break;
    }
  }

  // ========================================
  // ПОИСК И ФИЛЬТРАЦИЯ
  // ========================================

  void search(String query) {
    _searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      applyFilters();
      return;
    }

    if (query.length < 2) {
      applyFilters();
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => applyFilters(),
    );
  }

  void applyFilters() {
    var filtered = List<SubscriberModel>.from(_abonents);

    // Применяем фильтр по дате
    if (_dateFilter.value == DateFilter.today) {
      final today = DateTime.now();
      filtered = filtered.where((subscriber) {
        switch (listType) {
          case AbonentListType.consumption:
            if (subscriber.lastReadingDate == null) return false;
            return _isSameDay(subscriber.lastReadingDate!, today);
          case AbonentListType.payments:
            if (subscriber.lastPaymentDate == null) return false;
            return _isSameDay(subscriber.lastPaymentDate!, today);
        }
      }).toList();
    }

    // Применяем поиск
    if (_searchQuery.value.isNotEmpty && _searchQuery.value.length >= 2) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((subscriber) {
        return subscriber.fullName.toLowerCase().contains(query) ||
            subscriber.address.toLowerCase().contains(query) ||
            subscriber.accountNumber.toLowerCase().contains(query) ||
            subscriber.meterSerialNumber.toLowerCase().contains(query);
      }).toList();
    }

    _filteredAbonents.value = filtered;
    _updateStatistics();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void setDateFilter(DateFilter filter) {
    _dateFilter.value = filter;
    applyFilters();
  }

  void clearSearch() {
    searchTextController.clear();
    _searchQuery.value = '';
    applyFilters();
  }

  // ========================================
  // НАВИГАЦИЯ
  // ========================================

  void navigateToSubscriberDetail(SubscriberModel subscriber) {
    Get.toNamed(
      Routes.SUBSCRIBER_DETAIL,
      arguments: {
        'subscriber': subscriber,
        'tpName': subscriber.transformerPointName,
        'tpCode': subscriber.transformerPointCode,
      },
    );
  }
}

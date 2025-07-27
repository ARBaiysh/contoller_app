import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class SubscribersController extends GetxController {
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();

  // TP data from arguments
  late final String tpId;
  late final String tpName;

  // Observable states
  final _isLoading = false.obs;
  final _subscribers = <SubscriberModel>[].obs;
  final _filteredSubscribers = <SubscriberModel>[].obs;
  final _selectedStatus = 'all'.obs;
  final _searchQuery = ''.obs;
  final _sortBy = 'default'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<SubscriberModel> get subscribers => _filteredSubscribers;
  String get selectedStatus => _selectedStatus.value;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;

  // Statistics
  int get totalSubscribers => _subscribers.length;
  int get availableCount => _subscribers.where((s) => s.readingStatus == ReadingStatus.available).length;
  int get processingCount => _subscribers.where((s) => s.readingStatus == ReadingStatus.processing).length;
  int get completedCount => _subscribers.where((s) => s.readingStatus == ReadingStatus.completed).length;
  int get debtorsCount => _subscribers.where((s) => s.isDebtor).length;

  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments;
    if (args != null) {
      tpId = args['tpId'] ?? '';
      tpName = args['tpName'] ?? 'ТП';
    } else {
      tpId = '';
      tpName = 'ТП';
    }
    loadSubscribers();
  }

  // Load subscribers
  Future<void> loadSubscribers() async {
    _isLoading.value = true;
    try {
      final subs = await _subscriberRepository.getSubscribersByTp(tpId);
      _subscribers.value = subs;
      applyFiltersAndSort();
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить список абонентов',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh subscribers
  Future<void> refreshSubscribers() async {
    await loadSubscribers();
  }

  // Apply filters and sorting
  void applyFiltersAndSort() {
    List<SubscriberModel> filtered = List.from(_subscribers);

    // Apply status filter
    switch (_selectedStatus.value) {
      case 'available':
        filtered = filtered.where((s) => s.readingStatus == ReadingStatus.available).toList();
        break;
      case 'processing':
        filtered = filtered.where((s) => s.readingStatus == ReadingStatus.processing).toList();
        break;
      case 'completed':
        filtered = filtered.where((s) => s.readingStatus == ReadingStatus.completed).toList();
        break;
      case 'debtors':
        filtered = filtered.where((s) => s.isDebtor).toList();
        break;
      case 'all':
      default:
      // No filtering needed
        break;
    }

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((s) {
        return s.accountNumber.toLowerCase().contains(query) ||
            s.fullName.toLowerCase().contains(query) ||
            s.address.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy.value) {
      case 'name':
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'address':
        filtered.sort((a, b) => a.address.compareTo(b.address));
        break;
      case 'debt':
        filtered.sort((a, b) => b.debtAmount.compareTo(a.debtAmount));
        break;
      case 'default':
      default:
      // Sort by status (available first) and then by address
        filtered.sort((a, b) {
          if (a.readingStatus == ReadingStatus.available && b.readingStatus != ReadingStatus.available) return -1;
          if (a.readingStatus != ReadingStatus.available && b.readingStatus == ReadingStatus.available) return 1;
          return a.address.compareTo(b.address);
        });
        break;
    }

    _filteredSubscribers.value = filtered;
  }

  // Set status filter
  void setStatusFilter(String status) {
    _selectedStatus.value = status;
    applyFiltersAndSort();
  }

  // Search subscribers
  void searchSubscribers(String query) {
    _searchQuery.value = query;
    applyFiltersAndSort();
  }

  // Set sorting
  void setSorting(String sort) {
    _sortBy.value = sort;
    applyFiltersAndSort();
  }

  // Navigate to subscriber detail
  void navigateToSubscriberDetail(SubscriberModel subscriber) {
    Get.toNamed(
      Routes.SUBSCRIBER_DETAIL,
      arguments: {
        'subscriberId': subscriber.id,
        'tpName': tpName,
      },
    );
  }

  // Get status filter options
  List<StatusFilterOption> get statusFilterOptions => [
    StatusFilterOption(
      value: 'all',
      label: 'Все абоненты',
      count: totalSubscribers,
      icon: Icons.people,
      color: Constants.info,
    ),
    StatusFilterOption(
      value: 'available',
      label: 'Можно брать',
      count: availableCount,
      icon: Icons.check_circle_outline,
      color: Constants.success,
    ),
    StatusFilterOption(
      value: 'processing',
      label: 'Обрабатывается',
      count: processingCount,
      icon: Icons.pending,
      color: Constants.warning,
    ),
    StatusFilterOption(
      value: 'completed',
      label: 'Обработан',
      count: completedCount,
      icon: Icons.check_circle,
      color: Colors.grey,
    ),
    StatusFilterOption(
      value: 'debtors',
      label: 'Должники',
      count: debtorsCount,
      icon: Icons.warning_amber_outlined,
      color: Constants.error,
    ),
  ];

  // Get sort options
  List<SortOption> get sortOptions => [
    SortOption(value: 'default', label: 'По умолчанию'),
    SortOption(value: 'name', label: 'По имени'),
    SortOption(value: 'address', label: 'По адресу'),
    SortOption(value: 'debt', label: 'По долгу'),
  ];
}

// Status filter option model
class StatusFilterOption {
  final String value;
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  StatusFilterOption({
    required this.value,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
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
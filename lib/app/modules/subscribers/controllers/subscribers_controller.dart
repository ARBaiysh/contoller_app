import 'package:get/get.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../data/repositories/tp_repository.dart';
import '../../../routes/app_pages.dart';

class SubscribersController extends GetxController {
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();
  final TpRepository _tpRepository = Get.find<TpRepository>();

  // Arguments
  late String tpId;
  late String tpCode;
  late String tpName;

  // Observable states
  final _isLoading = false.obs;
  final _isSyncing = false.obs;
  final _subscribers = <SubscriberModel>[].obs;
  final _filteredSubscribers = <SubscriberModel>[].obs;
  final _selectedStatus = 'all'.obs;
  final _searchQuery = ''.obs;
  final _sortBy = 'default'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSyncing => _isSyncing.value;
  List<SubscriberModel> get subscribers => _filteredSubscribers;
  String get selectedStatus => _selectedStatus.value;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;

  // Statistics
  int get totalSubscribers => _subscribers.length;
  int get readingsCollected => _subscribers.where((s) => !s.canTakeReading).length;
  int get readingsAvailable => _subscribers.where((s) => s.canTakeReading).length;
  int get debtorsCount => _subscribers.where((s) => s.isDebtor).length;

  @override
  void onInit() {
    super.onInit();

    // Получаем параметры
    final args = Get.arguments as Map<String, dynamic>;
    tpId = args['tpId'] ?? '';
    tpCode = args['tpCode'] ?? tpId; // Используем tpId как tpCode если не передан
    tpName = args['tpName'] ?? 'ТП';

    // Загружаем абонентов
    loadSubscribers();
  }

  // Load subscribers
  Future<void> loadSubscribers({bool forceRefresh = false}) async {
    _isLoading.value = true;
    try {
      final subscribersList = await _subscriberRepository.getSubscribersByTp(
        tpCode,
        forceRefresh: forceRefresh,
      );
      _subscribers.value = subscribersList;
      applyFiltersAndSort();
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Sync subscribers with 1C
  Future<void> syncSubscribers() async {
    _isSyncing.value = true;
    try {
      final result = await _tpRepository.syncTpAbonents(tpCode);

      Get.snackbar(
        'Синхронизация завершена',
        'Синхронизировано: ${result['synced'] ?? 0}, '
            'Создано: ${result['created'] ?? 0}, '
            'Обновлено: ${result['updated'] ?? 0}',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
      );

      // Перезагружаем список
      await loadSubscribers(forceRefresh: true);
    } catch (e) {
      Get.snackbar(
        'Ошибка синхронизации',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.cardColor,
      );
    } finally {
      _isSyncing.value = false;
    }
  }

  // Refresh
  Future<void> refreshSubscribers() async {
    await loadSubscribers(forceRefresh: true);
  }

  // Apply filters and sorting
  void applyFiltersAndSort() {
    var filtered = List<SubscriberModel>.from(_subscribers);

    // Apply status filter
    switch (_selectedStatus.value) {
      case 'available':
        filtered = filtered.where((s) => s.canTakeReading).toList();
        break;
      case 'completed':
        filtered = filtered.where((s) => !s.canTakeReading).toList();
        break;
      case 'debtors':
        filtered = filtered.where((s) => s.isDebtor).toList();
        break;
    }

    // Apply search
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
        filtered.sort((a, b) => a.balance.compareTo(b.balance));
        break;
      case 'default':
      default:
      // Сортировка по статусу и адресу
        filtered.sort((a, b) {
          if (a.canTakeReading && !b.canTakeReading) return -1;
          if (!a.canTakeReading && b.canTakeReading) return 1;
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
        'subscriber': subscriber,
        'tpName': tpName,
      },
    );
  }

  // Get status filter options
  List<FilterOption> get filterOptions => [
    FilterOption(
      value: 'all',
      label: 'Все',
      count: _subscribers.length,
    ),
    FilterOption(
      value: 'available',
      label: 'Можно брать',
      count: _subscribers.where((s) => s.canTakeReading).length,
    ),
    FilterOption(
      value: 'completed',
      label: 'Обработаны',
      count: _subscribers.where((s) => !s.canTakeReading).length,
    ),
    FilterOption(
      value: 'debtors',
      label: 'Должники',
      count: _subscribers.where((s) => s.isDebtor).length,
    ),
  ];

  // Get sort options
  List<SortOption> get sortOptions => [
    SortOption(value: 'default', label: 'По умолчанию'),
    SortOption(value: 'name', label: 'По ФИО'),
    SortOption(value: 'address', label: 'По адресу'),
    SortOption(value: 'debt', label: 'По балансу'),
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
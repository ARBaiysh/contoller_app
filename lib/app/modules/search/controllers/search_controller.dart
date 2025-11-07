import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class GlobalSearchController extends GetxController {
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();
  final GetStorage _storage = GetStorage();

  // Storage key for recent searches
  static const String _recentSearchesKey = 'recent_searches';

  // Text controller
  final TextEditingController searchTextController = TextEditingController();

  // Debounce timer
  Timer? _debounce;

  // Observable states
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;
  final _searchResults = <SubscriberModel>[].obs;
  final _showRecent = true.obs;
  final _recentSearches = <String>[].obs;

  // Filter states
  final _filterByDebtor = false.obs;
  final _filterByStatus = 'all'.obs;

  final _totalResults = 0.obs;
  final _debtorResults = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  List<SubscriberModel> get searchResults => _searchResults;
  bool get showRecent => _showRecent.value;
  List<String> get recentSearches => _recentSearches;
  bool get filterByDebtor => _filterByDebtor.value;
  String get filterByStatus => _filterByStatus.value;

  // Statistics
  int get totalResults => _totalResults.value;
  int get debtorResults => _debtorResults.value;

  @override
  void onInit() {
    super.onInit();

    // Слушатель для обновления статистики
    _searchResults.listen((_) => _updateStatistics());

    // Загружаем историю поиска
    loadRecentSearches();
  }

  void _updateStatistics() {
    _totalResults.value = _searchResults.length;
    _debtorResults.value = _searchResults.where((s) => s.isDebtor).length;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  // Load recent searches from storage
  void loadRecentSearches() {
    try {
      final List<dynamic>? storedSearches = _storage.read(_recentSearchesKey);
      if (storedSearches != null) {
        _recentSearches.value = storedSearches.cast<String>();
      }
    } catch (e) {
      print('Error loading recent searches: $e');
      _recentSearches.value = [];
    }
  }

  // Save recent searches to storage
  void _saveRecentSearches() {
    try {
      _storage.write(_recentSearchesKey, _recentSearches.toList());
    } catch (e) {
      print('Error saving recent searches: $e');
    }
  }

  // Search with debounce
  void search(String query) {
    _searchQuery.value = query;
    searchTextController.text = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      _searchResults.clear();
      _showRecent.value = true;
      return;
    }

    _showRecent.value = false;

    // Если меньше 3 символов - очищаем результаты, но не показываем snackbar при вводе
    if (query.length < 3) {
      _searchResults.clear();
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: Constants.searchDebounceMs),
          () => performSearch(query),
    );
  }

  // Perform actual search
  Future<void> performSearch(String query) async {
    if (query.length < 3) return;

    _isLoading.value = true;

    try {
      // Используем новый API endpoint
      final results = await _subscriberRepository.searchSubscribers(query);

      // Применяем локальные фильтры
      List<SubscriberModel> filtered = results;

      if (_filterByDebtor.value) {
        filtered = filtered.where((s) => s.isDebtor).toList();
      }

      if (_filterByStatus.value != 'all') {
        switch (_filterByStatus.value) {
          case 'available':
          // Можно снимать показания
            filtered = filtered.where((s) => s.canTakeReading).toList();
            break;
          case 'completed':
          // Показания уже сняты (нельзя снимать)
            filtered = filtered.where((s) => !s.canTakeReading).toList();
            break;
        }
      }

      _searchResults.value = filtered;
      _updateStatistics();

      // Добавляем в историю поиска только если есть результаты
      if (results.isNotEmpty) {
        addToRecentSearches(query);
      }
    } catch (e) {
      print('Search error: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось выполнить поиск',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Add to recent searches with persistence
  void addToRecentSearches(String query) {
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      // Keep only last 10 searches
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
      // Save to storage
      _saveRecentSearches();
    }
  }

  // Clear search
  void clearSearch() {
    searchTextController.clear();
    _searchQuery.value = '';
    _searchResults.clear();
    _showRecent.value = true;
  }

  // Remove from recent searches
  void removeFromRecent(String query) {
    _recentSearches.remove(query);
    _saveRecentSearches();
  }

  // Clear all recent searches
  void clearRecentSearches() {
    _recentSearches.clear();
    _saveRecentSearches();
  }

  // Toggle debtor filter
  void toggleDebtorFilter() {
    _filterByDebtor.value = !_filterByDebtor.value;
    if (_searchQuery.value.isNotEmpty && _searchQuery.value.length >= 3) {
      performSearch(_searchQuery.value);
    }
  }

  // Set status filter
  void setStatusFilter(String status) {
    _filterByStatus.value = status;
    if (_searchQuery.value.isNotEmpty && _searchQuery.value.length >= 3) {
      performSearch(_searchQuery.value);
    }
  }

  // Navigate to subscriber detail
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

  // Search suggestions
  List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];

    final suggestions = <String>[];

    // Add matching recent searches
    suggestions.addAll(
      _recentSearches.where((s) => s.toLowerCase().contains(query.toLowerCase())),
    );

    // Add common search patterns
    if (query.startsWith('0900')) {
      suggestions.add('Поиск по лицевому счету');
    }

    return suggestions.take(5).toList();
  }

  // Опции фильтра по статусу
  List<Map<String, dynamic>> get statusFilterOptions {
    return [
      {
        'value': 'all',
        'label': 'Все',
        'count': _searchResults.length,
      },
      {
        'value': 'available',
        'label': 'Нужен обход',
        'count': _searchResults.where((s) => s.canTakeReading).length,
      },
      {
        'value': 'completed',
        'label': 'Обойдены',
        'count': _searchResults.where((s) => !s.canTakeReading).length,
      },
    ];
  }

}
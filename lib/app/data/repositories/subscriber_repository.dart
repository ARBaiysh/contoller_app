import 'package:get/get.dart';
import '../models/subscriber_model.dart';
import '../providers/api_provider.dart';
import '../../core/values/constants.dart';

class SubscriberRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // Cache for subscribers
  final Map<String, List<SubscriberModel>> _subscribersCache = {};
  final Map<String, SubscriberModel> _subscriberDetailsCache = {};

  // Get subscribers by TP ID
  Future<List<SubscriberModel>> getSubscribersByTp(String tpId) async {
    try {
      // Check cache first
      if (_subscribersCache.containsKey(tpId)) {
        return _subscribersCache[tpId]!;
      }

      // Fetch from API
      final subscribers = await _apiProvider.getSubscribersByTp(tpId);

      // Cache the result
      _subscribersCache[tpId] = subscribers;

      return subscribers;
    } catch (e) {
      print('Error fetching subscribers: $e');
      throw Exception('Не удалось загрузить список абонентов');
    }
  }

  // Get subscriber by ID
  Future<SubscriberModel> getSubscriberById(String subscriberId) async {
    try {
      // Check cache first
      if (_subscriberDetailsCache.containsKey(subscriberId)) {
        return _subscriberDetailsCache[subscriberId]!;
      }

      // Fetch from API
      final subscriber = await _apiProvider.getSubscriberById(subscriberId);

      // Cache the result
      _subscriberDetailsCache[subscriberId] = subscriber;

      return subscriber;
    } catch (e) {
      print('Error fetching subscriber details: $e');
      throw Exception('Не удалось загрузить данные абонента');
    }
  }

  // Search subscribers across all TPs
  Future<List<SubscriberModel>> searchSubscribers(String query) async {
    try {
      if (query.isEmpty) return [];

      // For search, always fetch fresh data
      final results = await _apiProvider.searchSubscribers(query);

      return results;
    } catch (e) {
      print('Error searching subscribers: $e');
      throw Exception('Ошибка поиска');
    }
  }

  // Submit reading for subscriber
  Future<SubscriberModel> submitReading({
    required String subscriberId,
    required int reading,
    String? comment,
  }) async {
    try {
      // Validate reading
      if (reading < Constants.minReadingValue || reading > Constants.maxReadingValue) {
        throw Exception('Показание должно быть от ${Constants.minReadingValue} до ${Constants.maxReadingValue}');
      }

      // Get current subscriber data
      final subscriber = await getSubscriberById(subscriberId);

      // Check if reading can be submitted
      if (!subscriber.canTakeReading) {
        throw Exception('Показание для данного абонента уже обрабатывается или завершено');
      }

      // Validate reading is greater than last reading
      if (subscriber.lastReading != null && reading <= subscriber.lastReading!) {
        throw Exception('Новое показание должно быть больше предыдущего (${subscriber.lastReading})');
      }

      // Submit to API
      final updatedSubscriber = await _apiProvider.submitReading(
        subscriberId: subscriberId,
        reading: reading,
        comment: comment,
      );

      // Update caches
      _subscriberDetailsCache[subscriberId] = updatedSubscriber;

      // Update in list cache if exists
      final tpId = updatedSubscriber.tpId;
      if (_subscribersCache.containsKey(tpId)) {
        final subscribers = _subscribersCache[tpId]!;
        final index = subscribers.indexWhere((s) => s.id == subscriberId);
        if (index != -1) {
          subscribers[index] = updatedSubscriber;
        }
      }

      return updatedSubscriber;
    } catch (e) {
      print('Error submitting reading: $e');
      throw Exception(e.toString());
    }
  }

  // Get subscribers by status
  Future<List<SubscriberModel>> getSubscribersByStatus({
    required String tpId,
    required ReadingStatus status,
  }) async {
    try {
      final allSubscribers = await getSubscribersByTp(tpId);
      return allSubscribers.where((s) => s.readingStatus == status).toList();
    } catch (e) {
      print('Error filtering subscribers by status: $e');
      throw Exception('Ошибка фильтрации');
    }
  }

  // Get debtors list
  Future<List<SubscriberModel>> getDebtors({String? tpId}) async {
    try {
      List<SubscriberModel> subscribers;

      if (tpId != null) {
        subscribers = await getSubscribersByTp(tpId);
      } else {
        // Get all subscribers
        subscribers = await _apiProvider.getAllSubscribers();
      }

      // Filter debtors
      return subscribers.where((s) => s.isDebtor).toList()
        ..sort((a, b) => b.debtAmount.compareTo(a.debtAmount));
    } catch (e) {
      print('Error fetching debtors: $e');
      throw Exception('Не удалось загрузить список должников');
    }
  }

  // Clear cache
  void clearCache() {
    _subscribersCache.clear();
    _subscriberDetailsCache.clear();
  }

  // Refresh subscribers for TP
  Future<List<SubscriberModel>> refreshSubscribers(String tpId) async {
    // Remove from cache to force refresh
    _subscribersCache.remove(tpId);
    return getSubscribersByTp(tpId);
  }
}
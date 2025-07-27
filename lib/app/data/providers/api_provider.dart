import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/tp_model.dart';
import '../models/subscriber_model.dart';
import '../models/statistics_model.dart';
import '../../core/values/constants.dart';

class ApiProvider extends GetxService {
  static const bool _useMockData = Constants.useMockData;
  static const String _mockDataPath = Constants.mockDataPath;
  static const String _baseUrl = Constants.baseUrl;

  // Mock data cache
  Map<String, dynamic>? _mockData;

  @override
  void onInit() {
    super.onInit();
    if (_useMockData) {
      _loadMockData();
    }
  }

  // Load mock data from JSON file
  Future<void> _loadMockData() async {
    try {
      final String jsonString = await rootBundle.loadString(_mockDataPath);
      _mockData = json.decode(jsonString);
    } catch (e) {
      print('Error loading mock data: $e');
    }
  }

  // Generic method to handle API calls
  Future<T> _handleApiCall<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) mockHandler,
    Map<String, dynamic>? params,
  }) async {
    if (_useMockData) {
      // Simulate network delay
      await Future.delayed(Constants.networkDelay);

      if (_mockData == null) {
        await _loadMockData();
      }

      return mockHandler(_mockData ?? {});
    } else {
      // Real API implementation
      // TODO: Implement real API calls using Dio
      throw UnimplementedError('Real API not implemented yet');
    }
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String username, String pin) async {
    return _handleApiCall(
      endpoint: '/auth/login',
      mockHandler: (data) {
        final user = data['user'] as Map<String, dynamic>;
        if (user['username'] == username && user['pin'] == pin) {
          return {
            'success': true,
            'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
            'user': user,
          };
        }
        throw Exception('Invalid credentials');
      },
    );
  }

  // Statistics endpoints
  Future<StatisticsModel> getStatistics() async {
    return _handleApiCall(
      endpoint: '/statistics',
      mockHandler: (data) {
        return StatisticsModel.fromJson(data['statistics']);
      },
    );
  }

  // TP endpoints
  Future<List<TpModel>> getTpList() async {
    return _handleApiCall(
      endpoint: '/tps',
      mockHandler: (data) {
        final tpList = data['tps'] as List;
        return tpList.map((tp) => TpModel.fromJson(tp)).toList();
      },
    );
  }

  Future<TpModel> getTpById(String tpId) async {
    return _handleApiCall(
      endpoint: '/tps/$tpId',
      mockHandler: (data) {
        final tpList = data['tps'] as List;
        final tp = tpList.firstWhere(
              (item) => item['id'] == tpId,
          orElse: () => throw Exception('TP not found'),
        );
        return TpModel.fromJson(tp);
      },
    );
  }

  // Subscriber endpoints
  Future<List<SubscriberModel>> getSubscribersByTp(String tpId) async {
    return _handleApiCall(
      endpoint: '/subscribers',
      params: {'tp_id': tpId},
      mockHandler: (data) {
        final subscribers = data['subscribers'] as List;
        return subscribers
            .where((sub) => sub['tp_id'] == tpId)
            .map((sub) => SubscriberModel.fromJson(sub))
            .toList();
      },
    );
  }

  Future<SubscriberModel> getSubscriberById(String subscriberId) async {
    return _handleApiCall(
      endpoint: '/subscribers/$subscriberId',
      mockHandler: (data) {
        final subscribers = data['subscribers'] as List;
        final subscriber = subscribers.firstWhere(
              (item) => item['id'] == subscriberId,
          orElse: () => throw Exception('Subscriber not found'),
        );
        return SubscriberModel.fromJson(subscriber);
      },
    );
  }

  // Search subscribers
  Future<List<SubscriberModel>> searchSubscribers(String query) async {
    return _handleApiCall(
      endpoint: '/subscribers/search',
      params: {'query': query},
      mockHandler: (data) {
        final subscribers = data['subscribers'] as List;
        final lowerQuery = query.toLowerCase();

        return subscribers
            .where((sub) {
          final accountNumber = sub['account_number']?.toString().toLowerCase() ?? '';
          final fullName = sub['full_name']?.toString().toLowerCase() ?? '';
          final address = sub['address']?.toString().toLowerCase() ?? '';

          return accountNumber.contains(lowerQuery) ||
              fullName.contains(lowerQuery) ||
              address.contains(lowerQuery);
        })
            .map((sub) => SubscriberModel.fromJson(sub))
            .toList();
      },
    );
  }

  // Submit reading
  Future<SubscriberModel> submitReading({
    required String subscriberId,
    required int reading,
    String? comment,
  }) async {
    return _handleApiCall(
      endpoint: '/readings',
      mockHandler: (data) {
        // Simulate reading submission
        final subscribers = data['subscribers'] as List;
        final subscriberIndex = subscribers.indexWhere(
              (item) => item['id'] == subscriberId,
        );

        if (subscriberIndex == -1) {
          throw Exception('Subscriber not found');
        }

        final subscriber = subscribers[subscriberIndex];
        final lastReading = subscriber['last_reading'] ?? 0;

        // Update subscriber data
        subscriber['current_reading'] = reading;
        subscriber['consumption'] = (reading - lastReading).toDouble();
        subscriber['amount_due'] = (reading - lastReading) * 1.5; // Mock calculation
        subscriber['reading_status'] = 'processing';

        return SubscriberModel.fromJson(subscriber);
      },
    );
  }

  // Get all subscribers for global search
  Future<List<SubscriberModel>> getAllSubscribers() async {
    return _handleApiCall(
      endpoint: '/subscribers/all',
      mockHandler: (data) {
        final subscribers = data['subscribers'] as List;
        return subscribers
            .map((sub) => SubscriberModel.fromJson(sub))
            .toList();
      },
    );
  }
}
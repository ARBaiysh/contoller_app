// lib/app/data/repositories/notification_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/values/constants.dart';
import '../models/notification_item.dart';

class NotificationRepository extends GetxService {
  static const String _mockPath = 'assets/mock/notifications.json';

  Future<List<NotificationItem>> getNotifications() async {
    if (Constants.useMockData == true) {
      final jsonStr = await rootBundle.loadString(_mockPath);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data['items'] as List).cast<Map<String, dynamic>>();
      return list.map((e) => NotificationItem.fromJson(e)).toList();
    }
    // TODO: подключить реальный API позже
    return [];
  }
}

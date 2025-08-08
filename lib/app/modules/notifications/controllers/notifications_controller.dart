// lib/app/modules/notifications/controllers/notifications_controller.dart
import 'package:get/get.dart';
import '../../../data/models/notification_item.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repo = Get.find<NotificationRepository>();

  final items = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final filterUnreadOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final data = await _repo.getNotifications();
      items.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshList() async {
    isRefreshing.value = true;
    try {
      final data = await _repo.getNotifications();
      items.assignAll(data);
    } finally {
      isRefreshing.value = false;
    }
  }

  void markAllRead() {
    items.value = items.map((e) => e.copyWith(isRead: true)).toList();
  }

  void toggleFilterUnread() {
    filterUnreadOnly.value = !filterUnreadOnly.value;
  }

  List<NotificationItem> get visibleItems =>
      filterUnreadOnly.value ? items.where((e) => !e.isRead).toList() : items;
}

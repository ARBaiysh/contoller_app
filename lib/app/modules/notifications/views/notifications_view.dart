// lib/app/modules/notifications/views/notifications_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_skeleton.dart';


class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          Obx(() => IconButton(
            tooltip: controller.filterUnreadOnly.value ? 'Показать все' : 'Показать непрочитанные',
            onPressed: controller.toggleFilterUnread,
            icon: Icon(controller.filterUnreadOnly.value ? Icons.filter_alt : Icons.filter_alt_off),
          )),
          IconButton(
            tooltip: 'Отметить все прочитанными',
            onPressed: controller.markAllRead,
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 6,
              itemBuilder: (_, __) => const NotificationSkeleton(),
            );
          }

          final list = controller.visibleItems;
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_off_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text('Нет уведомлений', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Когда появятся задания по обходу ТП или статусы показаний, они будут здесь.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshList,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final item = list[i];
                return NotificationCard(
                  item: item,
                  onTap: () => Get.toNamed(Routes.NOTIFICATION_DETAIL, arguments: item),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

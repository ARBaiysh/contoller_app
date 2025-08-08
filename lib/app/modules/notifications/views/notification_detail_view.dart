// lib/app/modules/notifications/views/notification_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_item.dart';
import '../../../core/theme/app_colors.dart';

class NotificationDetailView extends StatelessWidget {
  const NotificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationItem item = Get.arguments as NotificationItem;

    final (Color badgeBg, Color badgeFg, IconData badgeIcon) =
    _styleForSeverity(item.severity, context);
    final String typeLabel = _typeLabel(item.type);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомление'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading icon with severity background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(badgeIcon, color: badgeFg, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            typeLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: badgeFg, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title
                        Text(
                          item.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (item.message != null && item.message!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              item.message!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chips section
            _chipsSection(context, item),

            const SizedBox(height: 16),

            // Actions
            _actionsSection(context, item),
          ],
        ),
      ),
    );
  }

  Widget _chipsSection(BuildContext context, NotificationItem item) {
    final chips = <Widget>[
      _chip(
        context,
        icon: Icons.schedule,
        label: 'Создано: ${_fmtDate(item.createdAt)}',
      ),
    ];

    if (item.deadline != null) {
      chips.add(_chip(
        context,
        icon: Icons.event,
        label: 'Дедлайн: ${_fmtDate(item.deadline!)}',
      ));
    }
    if (item.tpCode != null) {
      chips.add(_chip(
        context,
        icon: Icons.electric_bolt_outlined,
        label: 'ТП: ${item.tpCode!}',
      ));
    }
    if (item.tpNumber != null) {
      chips.add(_chip(
        context,
        icon: Icons.tag_outlined,
        label: 'Номер: ${item.tpNumber!}',
      ));
    }
    if (item.subscriberNumber != null) {
      chips.add(_chip(
        context,
        icon: Icons.person_outline,
        label: 'Абонент: ${item.subscriberNumber!}',
      ));
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: chips,
      ),
    );
  }

  Widget _chip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _actionsSection(BuildContext context, NotificationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            // TODO: route to a specific screen if needed (e.g., TP details)
            Get.snackbar('Действие', 'Открыть связанный экран',
                snackPosition: SnackPosition.TOP);
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Открыть связанный экран'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            Get.snackbar('Готово', 'Отмечено как прочитано',
                snackPosition: SnackPosition.TOP);
          },
          icon: const Icon(Icons.done_all),
          label: const Text('Отметить как прочитано'),
        ),
      ],
    );
  }

  (Color, Color, IconData) _styleForSeverity(
      NotificationSeverity severity, BuildContext context) {
    switch (severity) {
      case NotificationSeverity.success:
        return (
        AppColors.success.withOpacity(0.12),
        AppColors.success,
        Icons.check_circle
        );
      case NotificationSeverity.warning:
        return (
        AppColors.warning.withOpacity(0.12),
        AppColors.warning,
        Icons.warning_amber_rounded
        );
      case NotificationSeverity.info:
      default:
        final c = Theme.of(context).colorScheme.primary;
        return (c.withOpacity(0.12), c, Icons.notifications);
    }
  }

  String _typeLabel(NotificationType t) {
    switch (t) {
      case NotificationType.taskVisitTp:
        return 'Обход ТП';
      case NotificationType.readingRegistered:
        return 'Показание зарегистрировано';
    }
  }

  String _fmtDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y.$m.$d $hh:$mm';
  }
}

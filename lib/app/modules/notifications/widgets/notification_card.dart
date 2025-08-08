// lib/app/modules/notifications/widgets/notification_card.dart
import 'package:flutter/material.dart';
import '../../../data/models/notification_item.dart';
import '../../../core/theme/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForSeverity(context, item.severity);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            blurRadius: 14, offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.06),
          )],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: colors.$1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(colors.$2, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (item.message != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.message!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10, runSpacing: 4,
                    children: [
                      if (item.tpCode != null)
                        _chip(context, 'ТП: ${item.tpCode!}'),
                      if (item.tpNumber != null)
                        _chip(context, '№: ${item.tpNumber!}'),
                      if (item.subscriberNumber != null)
                        _chip(context, 'Абонент: ${item.subscriberNumber!}'),
                      _chip(context, _fmtDate(item.createdAt)),
                      if (item.deadline != null)
                        _chip(context, 'Дедлайн: ${_fmtDate(item.deadline!)}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, IconData) _colorsForSeverity(BuildContext context, NotificationSeverity s) {
    switch (s) {
      case NotificationSeverity.success:
        return (AppColors.success.withOpacity(0.12), Icons.check_circle);
      case NotificationSeverity.warning:
        return (AppColors.warning.withOpacity(0.12), Icons.warning_amber_rounded);
      case NotificationSeverity.info:
      default:
        return (Theme.of(context).colorScheme.primary.withOpacity(0.12), Icons.notifications);
    }
  }

  Widget _chip(BuildContext context, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium,
    ),
  );

  String _fmtDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2,'0');
    final d = dt.day.toString().padLeft(2,'0');
    final hh = dt.hour.toString().padLeft(2,'0');
    final mm = dt.minute.toString().padLeft(2,'0');
    return '$y.$m.$d $hh:$mm';
  }
}

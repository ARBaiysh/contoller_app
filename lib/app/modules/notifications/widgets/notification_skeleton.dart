// lib/app/modules/notifications/widgets/notification_skeleton.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10),
            )),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 14, width: 220, color: Colors.white),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  Container(height: 20, width: 80, color: Colors.white),
                  Container(height: 20, width: 100, color: Colors.white),
                  Container(height: 20, width: 120, color: Colors.white),
                ]),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

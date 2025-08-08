// lib/app/modules/news/widgets/news_skeleton.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NewsSkeleton extends StatelessWidget {
  const NewsSkeleton({super.key});

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
          children: [
            Container(width: 96, height: 72, decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
            )),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 14, width: 200, color: Colors.white),
                const SizedBox(height: 12),
                Container(height: 12, width: 120, color: Colors.white),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

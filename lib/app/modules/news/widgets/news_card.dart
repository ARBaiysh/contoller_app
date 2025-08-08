// lib/app/modules/news/widgets/news_card.dart
import 'package:flutter/material.dart';

import '../../../data/models/news_item.dart';


class NewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const NewsCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(item.publishedAt);
    final dateLabel =
        '${item.publishedAt.year}.${item.publishedAt.month.toString().padLeft(2,'0')}.${item.publishedAt.day.toString().padLeft(2,'0')} '
        '${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.06),
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 90, // 120 * 3/4 = 90, тот же аспект 4:3
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : Container(color: Theme.of(context).colorScheme.surfaceVariant),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(item.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.public, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('${item.source} • $dateLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: onBookmark,
                        icon: Icon(item.isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                        tooltip: 'В избранное',
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

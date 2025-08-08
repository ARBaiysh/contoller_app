// lib/app/modules/news/views/news_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/news_item.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final NewsItem item = Get.arguments as NewsItem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новость'),
        actions: [
          IconButton(
            onPressed: () {
              // можно пробросить callback через arguments при желании
              Get.snackbar('Поделиться', 'Функция будет добавлена', snackPosition: SnackPosition.TOP);
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(item.imageUrl!, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          Text(item.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('${item.source} • ${item.publishedAt}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 12),
            Text(item.subtitle!, style: Theme.of(context).textTheme.bodyLarge),
          ],
          if (item.content != null) ...[
            const SizedBox(height: 16),
            Text(item.content!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (item.externalUrl != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse(item.externalUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Открыть источник'),
            ),
          ],
        ],
      ),
    );
  }
}

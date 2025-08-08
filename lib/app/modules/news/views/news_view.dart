// lib/app/modules/news/views/news_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/news_controller.dart';
import '../widgets/news_card.dart';
import '../widgets/news_skeleton.dart';

class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.news.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 6,
              itemBuilder: (_, __) => const NewsSkeleton(),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                controller.loadMore();
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: controller.refreshList,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.news.length + (controller.isLoading.value ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= controller.news.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: NewsSkeleton(),
                    );
                  }
                  final item = controller.news[i];
                  return NewsCard(
                    item: item,
                    onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: item),
                    onBookmark: () => controller.toggleBookmark(item),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

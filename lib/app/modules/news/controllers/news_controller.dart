// lib/app/modules/news/controllers/news_controller.dart
import 'package:get/get.dart';
import '../../../data/models/news_item.dart';
import '../../../data/repositories/news_repository.dart';

class NewsController extends GetxController {
  final NewsRepository _repo = Get.find<NewsRepository>();

  final news = <NewsItem>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final page = 1.obs;
  final hasMore = true.obs;
  final query = ''.obs; // for future search/filter

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  Future<void> loadInitial() async {
    isLoading.value = true;
    try {
      page.value = 1;
      final items = await _repo.getNews(page: page.value);
      news.assignAll(items);
      hasMore.value = items.length >= 10; // heuristic
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshList() async {
    isRefreshing.value = true;
    try {
      page.value = 1;
      final items = await _repo.getNews(page: page.value);
      news.assignAll(items);
      hasMore.value = items.length >= 10;
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;
    isLoading.value = true;
    try {
      page.value += 1;
      final items = await _repo.getNews(page: page.value);
      if (items.isEmpty) {
        hasMore.value = false;
      } else {
        news.addAll(items);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBookmark(NewsItem item) {
    final idx = news.indexWhere((n) => n.id == item.id);
    if (idx == -1) return;
    news[idx] = news[idx].copyWith(isBookmarked: !news[idx].isBookmarked);
  }
}

// lib/app/data/repositories/news_repository.dart
import 'package:get/get.dart';
import '../models/news_item.dart';
import '../providers/news_api_provider.dart';

class NewsRepository {
  final NewsApiProvider _api = Get.find<NewsApiProvider>();

  Future<List<NewsItem>> getNews({int page = 1}) => _api.fetchNews(page: page);
}

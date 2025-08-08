// lib/app/data/providers/news_api_provider.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/values/constants.dart';
import '../models/news_item.dart';

class NewsApiProvider extends GetxService {
  static const bool _useMockData = Constants.useMockData;
  static const String _mockPath = 'assets/mock/news.json';
  static const String _baseUrl = Constants.baseUrl; // e.g. https://api.example.com

  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));
  }

  Future<List<NewsItem>> fetchNews({int page = 1}) async {
    if (_useMockData) {
      final jsonStr = await rootBundle.loadString(_mockPath);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data['items'] as List).cast<Map<String, dynamic>>();
      return list.map(NewsItem.fromJson).toList();
    }

    // Real API example:
    final resp = await _dio.get('/news', queryParameters: {'page': page});
    final list = (resp.data['items'] as List).cast<Map<String, dynamic>>();
    return list.map(NewsItem.fromJson).toList();
  }
}

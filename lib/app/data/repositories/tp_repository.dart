// lib/app/data/repositories/tp_repository.dart

import 'package:get/get.dart';
import '../models/tp_model.dart';
import '../providers/api_provider.dart';

class TpRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // Кеш для предотвращения дублирующихся запросов
  List<TpModel>? _cachedTpList;
  DateTime? _cacheTime;
  Future<List<TpModel>>? _ongoingRequest;
  static const _cacheDuration = Duration(seconds: 2);

  /// Получение списка ТП с сервера
  /// forceRefresh - принудительное обновление из 1С (игнорирует кеш)
  Future<List<TpModel>> getTpList({bool forceRefresh = false}) async {
    // forceRefresh игнорирует весь кеш
    if (forceRefresh) {
      print('[TP REPO] Force refresh - clearing cache');
      _cachedTpList = null;
      _cacheTime = null;
      _ongoingRequest = null;
    }

    // Если есть активный запрос - возвращаем его
    if (_ongoingRequest != null) {
      print('[TP REPO] Returning ongoing TP list request...');
      return _ongoingRequest!;
    }

    // Если данные в кеше и они свежие - возвращаем из кеша
    if (_cachedTpList != null && _cacheTime != null) {
      final age = DateTime.now().difference(_cacheTime!);
      if (age < _cacheDuration) {
        print('[TP REPO] Returning cached TP list (age: ${age.inMilliseconds}ms)');
        return _cachedTpList!;
      }
    }

    // Создаем новый запрос
    print('[TP REPO] Fetching TP list (forceRefresh: $forceRefresh)');
    _ongoingRequest = _fetchTpList(forceRefresh);

    try {
      final result = await _ongoingRequest!;
      _cachedTpList = result;
      _cacheTime = DateTime.now();
      return result;
    } finally {
      _ongoingRequest = null;
    }
  }

  Future<List<TpModel>> _fetchTpList(bool forceRefresh) async {
    try {
      final responseData = await _apiProvider.getTransformerPoints(
        forceRefresh: forceRefresh,
      );

      final tpList = responseData.map((json) => TpModel.fromJson(json)).toList();

      print('[TP REPO] Loaded ${tpList.length} TPs');
      return tpList;
    } catch (e) {
      print('[TP REPO] Error fetching TP list: $e');
      throw Exception('Не удалось загрузить список ТП');
    }
  }

  /// Принудительное обновление списка ТП из 1С
  Future<List<TpModel>> refreshTpList() async {
    return getTpList(forceRefresh: true);
  }

  /// Поиск ТП по запросу (локально)
  List<TpModel> searchTp(List<TpModel> tpList, String query) {
    if (query.isEmpty) return tpList;

    final lowerQuery = query.toLowerCase();

    return tpList.where((tp) {
      return tp.code.toLowerCase().contains(lowerQuery) ||
          tp.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Получить ТП по коду
  TpModel? getTpByCode(List<TpModel> tpList, String code) {
    try {
      return tpList.firstWhereOrNull((tp) => tp.code == code);
    } catch (e) {
      print('[TP REPO] Error getting TP by code: $e');
      return null;
    }
  }
}
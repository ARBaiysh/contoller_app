import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/values/constants.dart';
import '../models/abonents_response_model.dart';
import '../models/auth_response_model.dart';
import '../models/region_model.dart';
import '../models/tp_list_response_model.dart';

class ApiProvider extends GetxService {
  static const String baseUrl = 'http://212.42.113.48:8269/api';
  late Dio _dio;
  final GetStorage _storage = GetStorage();

  Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptor for token management
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add token to header if available
        final token = _storage.read(Constants.tokenKey);
        if (token != null && !options.path.contains('/auth/')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 403 - token expired
        if (error.response?.statusCode == 403 && !error.requestOptions.path.contains('/auth/')) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request
            final opts = Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            );
            opts.headers!['Authorization'] = 'Bearer ${_storage.read(Constants.tokenKey)}';

            try {
              final response = await _dio.request(
                error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } catch (e) {
              return handler.reject(error);
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  // Refresh token by re-authenticating
  Future<bool> _refreshToken() async {
    try {
      final username = _storage.read(Constants.usernameKey);
      final password = _storage.read(Constants.passwordKey);
      final regionCode = _storage.read(Constants.regionCodeKey);

      if (username == null || password == null || regionCode == null) {
        return false;
      }

      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'regionCode': regionCode,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.status == 'SUCCESS' && authResponse.token != null) {
        await _storage.write(Constants.tokenKey, authResponse.token);
        return true;
      }

      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Auth endpoints
  Future<List<RegionModel>> getRegions() async {
    try {
      final response = await _dio.get('/auth/regions');
      final List<dynamic> data = response.data;
      return data.map((json) => RegionModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponseModel> login({
    required String username,
    required String password,
    required String regionCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'regionCode': regionCode,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponseModel> checkSyncStatus(int messageId) async {
    try {
      final response = await _dio.get('/auth/sync-status/$messageId');
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Время ожидания истекло. Проверьте соединение.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Неизвестная ошибка';
          return Exception('Ошибка $statusCode: $message');
        case DioExceptionType.connectionError:
          return Exception('Ошибка соединения. Проверьте интернет.');
        default:
          return Exception('Произошла ошибка: ${error.message}');
      }
    }
    return Exception('Неизвестная ошибка');
  }

  Future<TpListResponseModel> getTransformerPoints() async {
    try {
      print('[API] Getting transformer points...');
      final response = await _dio.get('/mobile/transformer-points');
      print('[API] TP list response: ${response.data}');

      return TpListResponseModel.fromJson(response.data);
    } catch (e) {
      print('[API] Error getting transformer points: $e');
      throw _handleError(e);
    }
  }

// Sync TP abonents
  Future<Map<String, dynamic>> syncTpAbonents(String tpCode) async {
    try {
      print('[API] Syncing abonents for TP: $tpCode');
      final response = await _dio.post('/internal/tp/$tpCode/abonents/sync');
      print('[API] Sync response: ${response.data}');

      return response.data;
    } catch (e) {
      print('[API] Error syncing TP abonents: $e');
      throw _handleError(e);
    }
  }

// Get abonents by TP (добавим позже, но объявим сейчас)
  Future<AbonentsResponseModel> getAbonentsByTp(String tpCode) async {
    try {
      print('[API] Getting abonents for TP: $tpCode');
      final response = await _dio.get('/mobile/transformer-points/$tpCode/abonents');
      print('[API] Abonents response: ${response.data}');

      return AbonentsResponseModel.fromJson(response.data);
    } catch (e) {
      print('[API] Error getting abonents: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitMeterReading({
    required String accountNumber,
    required int currentReading,
  }) async {
    try {
      print('[API] Submitting meter reading for: $accountNumber, reading: $currentReading');
      final response = await _dio.post(
        '/mobile/meter-readings',
        data: {
          'accountNumber': accountNumber,
          'currentReading': currentReading,
        },
      );
      print('[API] Submit reading response: ${response.data}');

      return response.data;
    } catch (e) {
      print('[API] Error submitting reading: $e');
      throw _handleError(e);
    }
  }
}
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/values/constants.dart';
import '../models/abonent_sync_response_model.dart';
import '../models/auth_response_model.dart';
import '../models/region_model.dart';
import '../models/sync_status_model.dart';
import '../models/tp_sync_response_model.dart';

class ApiProvider extends GetxService {
  static const String baseUrl = 'https://ca.asdf.kg/api';
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
          print('[API] Got 403 - attempting to refresh token...');

          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request with new token
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
          } else {
            // Refresh failed - user will be redirected to login by _handleAuthFailure()
            return handler.reject(error);
          }
        }
        handler.next(error);
      },
    ));
  }

  // Refresh token by re-authenticating
  // Refresh token by re-authenticating
  Future<bool> _refreshToken() async {
    try {
      final username = _storage.read(Constants.usernameKey);
      final password = _storage.read(Constants.passwordKey);
      final regionCode = _storage.read(Constants.regionCodeKey);

      if (username == null || password == null || regionCode == null) {
        print('[API] No saved credentials for refresh token');
        _handleAuthFailure();
        return false;
      }

      print('[API] Attempting to refresh token...');
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
        print('[API] Token refreshed successfully');
        return true;
      }

      // Если логин не прошел - очищаем данные и выкидываем на авторизацию
      print('[API] Refresh token failed - invalid credentials');
      _handleAuthFailure();
      return false;

    } catch (e) {
      print('[API] Error refreshing token: $e');
      _handleAuthFailure();
      return false;
    }
  }
// Обработка неудачной авторизации
  void _handleAuthFailure() {
    // Очищаем все сохраненные данные
    _storage.remove(Constants.tokenKey);
    _storage.remove(Constants.usernameKey);
    _storage.remove(Constants.passwordKey);
    _storage.remove(Constants.regionCodeKey);
    _storage.remove(Constants.userKey);
    _storage.remove(Constants.biometricKey);
    _storage.remove('saved_username');
    _storage.remove('saved_password');
    _storage.remove('saved_region_code');
    _storage.remove('remember_me');

    // Редирект на авторизацию
    Get.offAllNamed('/auth');

    // Показываем сообщение
    Get.snackbar(
      'Сессия истекла',
      'Войдите в систему заново',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // ========================================
  // AUTH ENDPOINTS
  // ========================================

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

  Future<SyncStatusModel> checkSyncStatus(int messageId) async {
    try {
      print('[API] Checking sync status for messageId: $messageId');
      final response = await _dio.get('/auth/sync-status/$messageId');
      print('[API] Sync status response (${response.statusCode}): ${response.data}');

      return SyncStatusModel.fromJson(response.data);
    } on DioException catch (e) {
      // Обработка HTTP 202 для SYNCING статуса
      if (e.response?.statusCode == 202 && e.requestOptions.path.contains('/auth/sync-status/')) {
        print('[API] Got 202 (Accepted) for sync-status - process is still running');
        if (e.response?.data != null) {
          try {
            return SyncStatusModel.fromJson(e.response!.data);
          } catch (parseError) {
            print('[API] Failed to parse 202 response: $parseError');
            throw Exception('Ошибка обработки ответа сервера');
          }
        }
      }

      print('[API] Error checking sync status: $e');
      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error checking sync status: $e');
      throw _handleError(e);
    }
  }

  Future<AuthResponseModel> retryLogin({
    required String username,
    required String password,
    required String regionCode,
  }) async {
    try {
      print('[API] Retrying login after sync...');
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'regionCode': regionCode,
        },
      );
      print('[API] Retry login response: ${response.data}');

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      print('[API] Error in retry login: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // TRANSFORMER POINTS ENDPOINTS
  // ========================================

  Future<List<Map<String, dynamic>>> getTransformerPoints() async {
    try {
      print('[API] Getting transformer points...');
      final response = await _dio.get('/mobile/transformer-points');
      print('[API] TP list response: ${response.data}');

      // Теперь ожидаем прямой список без обертки
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('[API] Error getting transformer points: $e');
      throw _handleError(e);
    }
  }

  Future<TpSyncResponseModel> syncTransformerPoints() async {
    try {
      print('[API] Starting TP sync...');
      final response = await _dio.post('/mobile/transformer-points/sync');
      print('[API] TP sync response (${response.statusCode}): ${response.data}');

      return TpSyncResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // СПЕЦИАЛЬНАЯ ОБРАБОТКА для 409 Conflict
      if (e.response?.statusCode == 409) {
        print('[API] Got 409 - TP sync already in progress');
        // Возвращаем модель с ошибкой для корректной обработки
        return TpSyncResponseModel(
          syncMessageId: null,
          status: 'ALREADY_RUNNING',
          message: 'Синхронизация ТП уже выполняется',
        );
      }

      print('[API] Error syncing TP: $e');
      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error syncing TP: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // ABONENTS ENDPOINTS (ОБНОВЛЕНО)
  // ========================================

  /// Получение списка абонентов по ТП
  /// GET /api/mobile/transformer-points/{tpCode}/abonents
  /// Возвращает прямой список абонентов (новая структура API)
  Future<List<Map<String, dynamic>>> getAbonentsByTp(String tpCode) async {
    try {
      print('[API] Getting abonents for TP: $tpCode');
      final response = await _dio.get('/mobile/transformer-points/$tpCode/abonents');
      print('[API] Abonents response: ${response.data}');

      // Новая структура API - ожидаем прямой список абонентов
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('[API] Error getting abonents: $e');
      throw _handleError(e);
    }
  }

  /// Синхронизация абонентов по ТП
  /// POST /api/mobile/transformer-points/{tpCode}/abonents/sync
  /// Возвращает AbonentSyncResponseModel с messageId для мониторинга
  Future<AbonentSyncResponseModel> syncAbonentsByTp(String tpCode) async {
    try {
      print('[API] Starting abonents sync for TP: $tpCode');
      final response = await _dio.post('/mobile/transformer-points/$tpCode/abonents/sync');
      print('[API] Abonents sync response (${response.statusCode}): ${response.data}');

      return AbonentSyncResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // СПЕЦИАЛЬНАЯ ОБРАБОТКА для 409 Conflict
      if (e.response?.statusCode == 409) {
        print('[API] Got 409 - abonents sync already in progress for TP: $tpCode');
        // Возвращаем модель с ошибкой для корректной обработки
        return AbonentSyncResponseModel(
          syncMessageId: null,
          status: 'ALREADY_RUNNING',
          message: 'Синхронизация абонентов уже выполняется',
        );
      }

      print('[API] Error syncing abonents for TP $tpCode: $e');
      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error syncing abonents for TP $tpCode: $e');
      throw _handleError(e);
    }
  }

  /// Синхронизация одного абонента
  /// POST /api/mobile/abonents/{accountNumber}/sync
  Future<Map<String, dynamic>> syncSingleAbonent(String accountNumber) async {
    try {
      print('[API] Starting sync for single abonent: $accountNumber');
      final response = await _dio.post('/mobile/abonents/$accountNumber/sync');
      print('[API] Single abonent sync response (${response.statusCode}): ${response.data}');

      return response.data;
    } on DioException catch (e) {
      // Обработка 409 Conflict
      if (e.response?.statusCode == 409) {
        print('[API] Got 409 - single abonent sync already in progress');
        return {
          'syncMessageId': null,
          'status': 'ALREADY_RUNNING',
          'message': 'Синхронизация абонента уже выполняется',
        };
      }

      print('[API] Error syncing single abonent: $e');
      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error syncing single abonent: $e');
      throw _handleError(e);
    }
  }

  /// Получение данных одного абонента
  /// GET /api/mobile/abonents/{accountNumber}
  Future<Map<String, dynamic>> getAbonentByAccount(String accountNumber) async {
    try {
      print('[API] Getting abonent data for: $accountNumber');
      final response = await _dio.get('/mobile/abonents/$accountNumber');
      print('[API] Abonent data response: ${response.data}');

      return response.data;
    } catch (e) {
      print('[API] Error getting abonent data: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // METER READINGS ENDPOINTS
  // ========================================

  Future<Map<String, dynamic>> submitMeterReading({
    required String accountNumber,
    required String meterSerialNumber,
    required int currentReading,
  }) async {
    try {
      print('[API] Submitting meter reading for: $accountNumber, reading: $currentReading');
      final response = await _dio.post(
        '/mobile/meter-readings',
        data: {
          'accountNumber': accountNumber,
          'meterSerialNumber': meterSerialNumber,
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

  // ========================================
  // ERROR HANDLING
  // ========================================

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
}
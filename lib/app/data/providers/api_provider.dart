import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/values/constants.dart';
import '../models/abonent_sync_response_model.dart';
import '../models/app_version_model.dart';
import '../models/auth_response_model.dart';
import '../models/full_sync_response_model.dart';
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

      final response = await _dio.get('/mobile/transformer-points');

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
  // DASHBOARD ENDPOINT
  // ========================================

  /// GET /api/mobile/dashboard
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {

      final response = await _dio.get('/mobile/dashboard');

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('[API] Error getting dashboard statistics: $e');
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

  /// Запуск полной синхронизации всех данных
  Future<FullSyncResponse> startFullSync() async {
    try {
      print('[API] Starting full sync...');
      final response = await _dio.post('/mobile/full-sync');
      print('[API] Full sync response (${response.statusCode}): ${response.data}');

      return FullSyncResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Обработка специальных статусов
      if (e.response?.statusCode == 409) {
        print('[API] Got 409 - full sync already running');
        return FullSyncResponse(
          status: 'ALREADY_RUNNING',
          message: 'Полная синхронизация уже выполняется',
        );
      }

      if (e.response?.statusCode == 500) {
        print('[API] Got 500 - server error during full sync');
        return FullSyncResponse(
          status: 'ERROR',
          message: 'Ошибка сервера при запуске синхронизации',
        );
      }

      print('[API] Error starting full sync: $e');
      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error starting full sync: $e');
      throw _handleError(e);
    }
  }

  /// Поиск абонентов (живой поиск)
  Future<List<dynamic>> searchAbonents(String query) async {
    try {
      print('[API] Searching abonents with query: $query');

      final response = await _dio.get(
        '/mobile/abonents/search',
        queryParameters: {'query': query},
      );

      print('[API] Search returned ${response.data.length} results');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      print('[API] Search error: ${e.message}');
      if (e.response?.statusCode == 400) {
        // При запросе меньше 3 символов возвращаем пустой массив
        return [];
      }
      throw _handleError(e);
    }
  }

  // Добавь этот метод в lib/app/data/providers/api_provider.dart
// В конец класса ApiProvider, перед закрывающей скобкой }

// Не забудь добавить импорт в начале файла:
// import '../models/app_version_model.dart';

// ========================================
// APP VERSION CHECK ENDPOINT
// ========================================

  /// Проверка версии приложения
  /// GET /api/mobile/app-version
  Future<AppVersionModel> checkAppVersion() async {
    try {
      final response = await _dio.get('/auth/app-version');
      return AppVersionModel.fromJson(response.data);
    } catch (e) {
      print('[API] Error checking app version: $e');
      throw _handleError(e);
    }
  }

  /// Скачивание APK файла с прогрессом
  /// GET /api/mobile/download-apk
  Future<void> downloadApk({
    required String savePath,
    required Function(int received, int total) onProgress,
  }) async {
    try {
      await _dio.download(
        '/auth/download-apk',
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('[API] Download progress: $progress% ($received/$total bytes)');
            onProgress(received, total);
          }
        },
      );

      print('[API] APK download completed: $savePath');
    } catch (e) {
      print('[API] Error downloading APK: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // PHONE MANAGEMENT ENDPOINTS
  // ========================================

  /// Добавить или обновить телефон абонента
  /// POST /api/mobile/phones
  /// Body: { "accountNumber": "12345", "phoneNumber": "+996700123456" }
  /// Returns: 200 - успешно, 400 - неверный формат, 403 - нет доступа, 404 - абонент не найден
  Future<Map<String, dynamic>> addOrUpdatePhone({
    required String accountNumber,
    required String phoneNumber,
  }) async {
    try {
      print('[API] Adding/updating phone for account: $accountNumber, phone: $phoneNumber');
      final response = await _dio.post(
        '/mobile/phones',
        data: {
          'accountNumber': accountNumber,
          'phoneNumber': phoneNumber,
        },
      );
      print('[API] Add/update phone response (${response.statusCode}): ${response.data}');

      return response.data;
    } on DioException catch (e) {
      print('[API] Error adding/updating phone: $e');

      // Специальная обработка различных статусов
      if (e.response?.statusCode == 400) {
        throw Exception('Неверный формат номера телефона');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Нет доступа к данному абоненту');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Абонент не найден');
      }

      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error adding/updating phone: $e');
      throw _handleError(e);
    }
  }

  /// Удалить телефон абонента
  /// DELETE /api/mobile/phones/{accountNumber}
  /// Returns: 200 - успешно, 403 - нет доступа, 404 - телефон не найден
  Future<void> deletePhone(String accountNumber) async {
    try {
      print('[API] Deleting phone for account: $accountNumber');
      final response = await _dio.delete('/mobile/phones/$accountNumber');
      print('[API] Delete phone response (${response.statusCode}): ${response.data}');
    } on DioException catch (e) {
      print('[API] Error deleting phone: $e');

      // Специальная обработка различных статусов
      if (e.response?.statusCode == 403) {
        throw Exception('Нет доступа к данному абоненту');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Телефон не найден или уже удален');
      }

      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error deleting phone: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // REPORTS ENDPOINTS
  // ========================================

  /// Получить статистику отчетов
  /// GET /api/mobile/reports/statistics
  /// Returns: Статистика по отчетам контролера
  Future<Map<String, dynamic>> getReportsStatistics() async {
    try {
      print('[API] Getting reports statistics...');
      final response = await _dio.get('/mobile/reports/statistics');
      print('[API] Reports statistics response (${response.statusCode}): ${response.data}');

      // Ожидаем структуру: { "success": true, "data": { ... } }
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'];
      }

      throw Exception('Неверный формат ответа сервера');
    } on DioException catch (e) {
      print('[API] Error getting reports statistics: $e');
      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error getting reports statistics: $e');
      throw _handleError(e);
    }
  }

  /// Сформировать отчет
  /// POST /api/mobile/reports/generate
  /// Body: { "reportType": "disconnections", "tpId": "ТП-001" }
  /// Returns: Данные отчета с массивом абонентов
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    String? tpId,
  }) async {
    try {
      print('[API] Generating report - type: $reportType, tpId: $tpId');

      final requestData = <String, dynamic>{
        'reportType': reportType,
      };

      if (tpId != null && tpId.isNotEmpty) {
        requestData['tpId'] = tpId;
      }

      final response = await _dio.post(
        '/mobile/reports/generate',
        data: requestData,
      );

      print('[API] Generate report response (${response.statusCode})');
      print('[API] Response data keys: ${response.data?.keys}');

      // Ожидаем структуру: { "success": true, "data": { ... } }
      if (response.data['success'] == true && response.data['data'] != null) {
        final reportData = response.data['data'];
        print('[API] Report data keys: ${reportData.keys}');
        print('[API] Subscribers count: ${reportData['subscribers']?.length ?? 0}');
        print('[API] Total count: ${reportData['count']}');
        return reportData;
      }

      throw Exception('Неверный формат ответа сервера');
    } on DioException catch (e) {
      print('[API] Error generating report: $e');

      // Специальная обработка различных статусов
      if (e.response?.statusCode == 400) {
        final errorCode = e.response?.data['error']?['code'];
        final errorMessage = e.response?.data['error']?['message'] ?? 'Неверный запрос';

        if (errorCode == 'INVALID_REPORT_TYPE') {
          throw Exception('Неверный тип отчета');
        } else if (errorCode == 'INVALID_TP_ID') {
          throw Exception('Указанная ТП не существует или не доступна');
        }

        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Нет доступа к данной трансформаторной подстанции');
      } else if (e.response?.statusCode == 404) {
        final errorMessage = e.response?.data['error']?['message'] ??
                            'По указанным критериям не найдено ни одного абонента';
        throw Exception(errorMessage);
      }

      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error generating report: $e');
      throw _handleError(e);
    }
  }

}
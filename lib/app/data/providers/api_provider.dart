import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/values/constants.dart';
import '../models/app_version_model.dart';
import '../models/auth_response_model.dart';
import '../models/meter_detail_model.dart';
import '../models/region_model.dart';

class ApiProvider extends GetxService {
  static const String baseUrl = 'http://192.168.120.10:8269/api';
  //static const String baseUrl = 'https://ca.asdf.kg/api';
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
      await _storage.write(Constants.tokenKey, authResponse.token);
      print('[API] Token refreshed successfully');
      return true;
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

  /// Получить профиль текущего инспектора
  /// GET /api/mobile/profile
  Future<InspectorData> getProfile() async {
    try {
      final response = await _dio.get('/mobile/profile');
      return InspectorData.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========================================
  // TRANSFORMER POINTS ENDPOINTS
  // ========================================

  /// Получить список ТП (с опциональным forceRefresh)
  /// GET /api/mobile/transformer-points?forceRefresh=true
  Future<List<Map<String, dynamic>>> getTransformerPoints({bool forceRefresh = false}) async {
    try {
      final response = await _dio.get(
        '/mobile/transformer-points',
        queryParameters: forceRefresh ? {'forceRefresh': true} : null,
      );

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('[API] Error getting transformer points: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // ABONENTS ENDPOINTS
  // ========================================

  /// Получить всех абонентов инспектора
  /// GET /api/mobile/abonents?forceRefresh=true
  Future<List<Map<String, dynamic>>> getAllAbonents({bool forceRefresh = false}) async {
    try {
      print('[API] Getting all abonents');
      final response = await _dio.get(
        '/mobile/abonents',
        queryParameters: forceRefresh ? {'forceRefresh': true} : null,
      );

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('[API] Error getting all abonents: $e');
      throw _handleError(e);
    }
  }

  /// Получение списка абонентов по ТП
  /// GET /api/mobile/transformer-points/{tpCode}/abonents?forceRefresh=true
  Future<List<Map<String, dynamic>>> getAbonentsByTp(String tpCode, {bool forceRefresh = false}) async {
    try {
      print('[API] Getting abonents for TP: $tpCode');
      final response = await _dio.get(
        '/mobile/transformer-points/$tpCode/abonents',
        queryParameters: forceRefresh ? {'forceRefresh': true} : null,
      );

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('[API] Error getting abonents for TP: $e');
      throw _handleError(e);
    }
  }

  /// Получение детальной информации об абоненте
  /// GET /api/mobile/abonents/{accountNumber}?forceRefresh=true
  Future<Map<String, dynamic>> getAbonentByAccount(String accountNumber, {bool forceRefresh = false}) async {
    try {
      print('[API] Getting abonent data for: $accountNumber');
      final response = await _dio.get(
        '/mobile/abonents/$accountNumber',
        queryParameters: forceRefresh ? {'forceRefresh': true} : null,
      );

      return response.data;
    } catch (e) {
      print('[API] Error getting abonent data: $e');
      throw _handleError(e);
    }
  }

  /// Поиск абонентов (живой поиск)
  /// GET /api/mobile/abonents/search?query=...
  Future<List<dynamic>> searchAbonents(String query) async {
    try {
      print('[API] Searching abonents with query: $query');

      final response = await _dio.get(
        '/mobile/abonents/search',
        queryParameters: {'query': query},
      );

      print('[API] Search returned ${response.data.length} results');
      return response.data as List<dynamic>;
    } catch (e) {
      print('[API] Search error: $e');
      throw _handleError(e);
    }
  }

  /// Получить абонентов с показаниями за текущий месяц
  /// GET /api/mobile/abonents/consumption-current-month
  Future<List<dynamic>> getAbonentsWithConsumption() async {
    try {
      print('[API] Fetching abonents with consumption for current month');

      final response = await _dio.get('/mobile/abonents/consumption-current-month');

      print('[API] Consumption list returned ${response.data.length} results');
      return response.data as List<dynamic>;
    } catch (e) {
      print('[API] Get consumption error: $e');
      throw _handleError(e);
    }
  }

  /// Получить абонентов которые оплатили в текущем месяце
  /// GET /api/mobile/abonents/paid-current-month
  Future<List<dynamic>> getAbonentsWithPayments() async {
    try {
      print('[API] Fetching abonents with payments for current month');

      final response = await _dio.get('/mobile/abonents/paid-current-month');

      print('[API] Payments list returned ${response.data.length} results');
      return response.data as List<dynamic>;
    } catch (e) {
      print('[API] Get payments error: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // METER READINGS ENDPOINTS
  // ========================================

  /// Отправить показание счетчика
  /// POST /api/mobile/meter-readings
  Future<Map<String, dynamic>> submitMeterReading({
    required String accountNumber,
    required int currentReading,
    String? meterSerialNumber,
  }) async {
    try {
      print('[API] Submitting meter reading for: $accountNumber, reading: $currentReading');

      final data = {
        'accountNumber': accountNumber,
        'currentReading': currentReading,
      };

      if (meterSerialNumber != null) {
        data['meterSerialNumber'] = meterSerialNumber;
      }

      final response = await _dio.post('/mobile/meter-readings', data: data);
      print('[API] Submit reading response: ${response.data}');

      return response.data;
    } catch (e) {
      print('[API] Error submitting reading: $e');
      throw _handleError(e);
    }
  }

  /// Проверить статус показания
  /// GET /api/mobile/meter-readings/{readingId}/status
  Future<Map<String, dynamic>> checkReadingStatus(int readingId) async {
    try {
      print('[API] Checking reading status for: $readingId');
      final response = await _dio.get('/mobile/meter-readings/$readingId/status');
      return response.data;
    } catch (e) {
      print('[API] Error checking reading status: $e');
      throw _handleError(e);
    }
  }

  /// Получить историю показаний по лицевому счету
  /// GET /api/mobile/meter-readings/by-account/{accountNumber}
  Future<List<dynamic>> getReadingHistory(String accountNumber) async {
    try {
      print('[API] Getting reading history for: $accountNumber');
      final response = await _dio.get('/mobile/meter-readings/by-account/$accountNumber');
      print('[API] Reading history response: ${response.data}');
      return List<dynamic>.from(response.data);
    } catch (e) {
      print('[API] Error getting reading history: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // DASHBOARD ENDPOINT
  // ========================================

  /// GET /api/mobile/dashboard/stats
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final response = await _dio.get('/mobile/dashboard/stats');
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


  // Добавь этот метод в lib/app/data/providers/api_provider.dart
// В конец класса ApiProvider, перед закрывающей скобкой }

// Не забудь добавить импорт в начале файла:
// import '../models/app_version_model.dart';

// ========================================
// APP VERSION CHECK ENDPOINT
// ========================================

  /// Проверка версии приложения
  /// GET /api/auth/app-version
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
  /// GET /api/auth/download-apk
  Future<void> downloadApk({
    required String savePath,
    required Function(int received, int total) onProgress,
  }) async {
    try {
      // Создаем отдельный экземпляр Dio с увеличенными таймаутами для скачивания большого файла
      final downloadDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(minutes: 10), // 10 минут для скачивания
        sendTimeout: const Duration(minutes: 10),
      ));

      // Добавляем токен для авторизации
      final token = _storage.read(Constants.tokenKey);
      if (token != null) {
        downloadDio.options.headers['Authorization'] = 'Bearer $token';
      }

      await downloadDio.download(
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

  /// Обновить номер телефона абонента
  /// POST /api/mobile/abonents/phone
  /// Body: { "accountNumber": "12345", "phoneNumber": "+996700123456" }
  Future<Map<String, dynamic>> updatePhone({
    required String accountNumber,
    required String phoneNumber,
  }) async {
    try {
      print('[API] Updating phone for account: $accountNumber, phone: $phoneNumber');
      final response = await _dio.post(
        '/mobile/abonents/phone',
        data: {
          'accountNumber': accountNumber,
          'phoneNumber': phoneNumber,
        },
      );
      print('[API] Update phone response (${response.statusCode}): ${response.data}');

      return response.data;
    } on DioException catch (e) {
      print('[API] Error updating phone: $e');

      if (e.response?.statusCode == 400) {
        throw Exception('Неверный формат номера телефона');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Нет доступа к данному абоненту');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Абонент не найден');
      }

      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error updating phone: $e');
      throw _handleError(e);
    }
  }

  // ========================================
  // REPORTS ENDPOINTS
  // ========================================

  // УДАЛЕНО: getReportsStatistics() - в новом API нет этого эндпоинта
  // Теперь используется getDashboardStatistics() в StatisticsRepository

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

  // ========================================
  // METER DATA ENDPOINTS
  // ========================================

  /// Получить детальные данные счётчика
  /// GET /api/mobile/abonents/{accountNumber}/meter-data/{meterNumber}
  Future<MeterDetailModel> getMeterData({
    required String accountNumber,
    required String meterNumber,
  }) async {
    try {
      print('[API] Getting meter data for account: $accountNumber, meter: $meterNumber');
      final response = await _dio.get(
        '/mobile/abonents/$accountNumber/meter-data/$meterNumber',
      );
      print('[API] Meter data response: ${response.data}');
      return MeterDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      print('[API] Error getting meter data: $e');

      if (e.response?.statusCode == 404) {
        throw Exception('Данные счётчика не найдены');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Нет доступа к данному абоненту');
      }

      throw _handleError(e);
    } catch (e) {
      print('[API] Unexpected error getting meter data: $e');
      throw _handleError(e);
    }
  }

}
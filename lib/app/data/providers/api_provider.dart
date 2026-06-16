import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/errors/app_exception.dart';
import '../../core/services/auth_events.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/token_storage.dart';
import '../../core/utils/app_logger.dart';
import '../../core/values/constants.dart';
import '../models/app_version_model.dart';
import '../models/auth_response_model.dart';
import '../models/dashboard_model.dart';
import '../models/meter_detail_model.dart';
import '../models/region_model.dart';
import '../models/subscriber_model.dart';
import '../models/tp_model.dart';

class ApiProvider extends GetxService {
  // Базовый URL можно переопределить при сборке: --dart-define=API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
   // defaultValue: 'https://ca.asdf.kg/api',
    defaultValue: 'http://192.168.120.10:8269/api',
  );
  late Dio _dio;
  final GetStorage _storage = GetStorage();
  final TokenStorage _tokenStorage = Get.find<TokenStorage>();

  /// Один общий Future обновления токена (single-flight): пока он не завершён,
  /// все параллельные 401-запросы ждут его, а не запускают свой refresh.
  Future<bool>? _refreshing;

  /// Защита от множественной обработки провала сессии.
  bool _authFailureHandled = false;

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
        // Подставляем access-токен из защищённого хранилища (in-memory копия)
        final token = _tokenStorage.accessToken;
        if (token != null && !options.path.contains('/auth/')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Успешный ответ — сбрасываем оверлей «нет связи / тех. работы»
        _reportConnectivitySuccess();
        handler.next(response);
      },
      onError: (error, handler) async {
        // Оверлей показываем только на сетевых сбоях/5xx, не на обычных 4xx
        _reportConnectivityError(error);

        // 401 на защищённом эндпоинте = истёк/отсутствует access-токен
        // (бэкенд отдаёт 401 через RestAuthenticationEntryPoint). 403 теперь —
        // это бизнес-ошибка «нет доступа», её рефрешить НЕ нужно.
        if (error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/')) {
          AppLogger.d('[API] Got 401 - attempting to refresh token...');

          final refreshed = await refreshSession();
          if (refreshed) {
            // Повторяем исходный запрос уже с новым access-токеном
            final opts = Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            );
            opts.headers!['Authorization'] = 'Bearer ${_tokenStorage.accessToken}';

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
            // refresh не удался — _handleAuthFailure уже увёл на экран входа
            return handler.reject(error);
          }
        }
        handler.next(error);
      },
    ));
  }

  /// Обновление сессии по refresh-токену (single-flight).
  /// Используется и интерцептором (на 401), и при входе по биометрии.
  Future<bool> refreshSession() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      AppLogger.d('[API] No refresh token available');
      _handleAuthFailure();
      return false;
    }

    try {
      AppLogger.d('[API] Refreshing session via /auth/refresh...');
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      if (authResponse.token.isEmpty || authResponse.refreshToken == null) {
        _handleAuthFailure();
        return false;
      }

      await _tokenStorage.saveTokens(
        accessToken: authResponse.token,
        refreshToken: authResponse.refreshToken!,
      );
      AppLogger.d('[API] Session refreshed successfully');
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        // refresh-токен недействителен/истёк — завершаем сессию
        AppLogger.d('[API] Refresh rejected ($status) - logging out');
        _handleAuthFailure();
      } else {
        // Сетевая ошибка — НЕ разлогиниваем, токены сохраняем, дадим повторить
        AppLogger.e('[API] Refresh network error (session kept)', e);
      }
      return false;
    } catch (e) {
      AppLogger.e('[API] Unexpected error refreshing session (session kept)', e);
      return false;
    }
  }

  // Обработка неудачной авторизации (истёкший/отозванный refresh-токен).
  // Данные чистим здесь (дата-слой), UI-реакцию делегируем AuthEvents (UI-слой).
  void _handleAuthFailure() {
    if (_authFailureHandled) return;
    _authFailureHandled = true;

    // Чистим токены из защищённого хранилища
    _tokenStorage.clear();

    // Чистим прочие пользовательские данные и устаревшие ключи
    _storage.remove(Constants.userKey);
    _storage.remove(Constants.biometricKey);
    // Устаревшие ключи (на случай миграции со старых версий)
    _storage.remove(Constants.tokenKey);
    _storage.remove(Constants.usernameKey);
    _storage.remove(Constants.passwordKey);
    _storage.remove(Constants.regionCodeKey);
    _storage.remove('saved_username');
    _storage.remove('saved_password');
    _storage.remove('saved_region_code');
    _storage.remove('remember_me');

    // UI-реакция (редирект + сообщение) — в отдельном сервисе
    Get.find<AuthEvents>().onSessionExpired();
  }

  /// Сбросить флаг обработки провала сессии (после успешного входа).
  void resetAuthFailureFlag() {
    _authFailureHandled = false;
    Get.find<AuthEvents>().reset();
  }

  /// Выход с устройства — отзыв refresh-токена на сервере (best-effort).
  Future<void> revokeRefreshToken() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      AppLogger.e('[API] Error revoking refresh token', e);
    }
  }

  // ========================================
  // CONNECTIVITY OVERLAY (нет связи / технические работы)
  // ========================================

  void _reportConnectivitySuccess() {
    if (Get.isRegistered<ConnectivityService>()) {
      Get.find<ConnectivityService>().reportSuccess();
    }
  }

  /// Сообщаем монитору только о сетевых сбоях (нет связи / сервер не отвечает /
  /// 5xx). Обычные 4xx (валидация, 401, 403, 404 и т.п.) оверлей не показывают.
  void _reportConnectivityError(DioException error) {
    final statusCode = error.response?.statusCode;
    final isConnectionLevel = error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
    final isServerError =
        statusCode != null && statusCode >= 500 && statusCode <= 599;

    if ((isConnectionLevel || isServerError) &&
        Get.isRegistered<ConnectivityService>()) {
      Get.find<ConnectivityService>().reportConnectionFailure();
    }
  }

  // ========================================
  // ВСПОМОГАТЕЛЬНОЕ
  // ========================================

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    return (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ========================================
  // AUTH ENDPOINTS
  // ========================================

  Future<List<RegionModel>> getRegions() async {
    try {
      final response = await _dio.get('/auth/regions');
      return _asMapList(response.data).map(RegionModel.fromJson).toList();
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
      return InspectorData.fromJson(Map<String, dynamic>.from(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========================================
  // TRANSFORMER POINTS ENDPOINTS
  // ========================================

  /// Получить список ТП (с опциональным forceRefresh)
  /// GET /api/mobile/transformer-points?forceRefresh=true
  Future<List<TpModel>> getTransformerPoints({bool forceRefresh = false}) async {
    try {
      final response = await _dio.get(
        '/mobile/transformer-points',
        queryParameters: forceRefresh ? {'forceRefresh': true} : null,
      );
      return _asMapList(response.data).map(TpModel.fromJson).toList();
    } catch (e) {
      AppLogger.e('[API] Error getting transformer points', e);
      throw _handleError(e);
    }
  }

  // ========================================
  // ABONENTS ENDPOINTS
  // ========================================

  /// Получить всех абонентов инспектора
  /// GET /api/mobile/abonents?forceRefresh=true
  Future<List<SubscriberModel>> getAllAbonents({bool forceRefresh = false}) async {
    try {
      AppLogger.d('[API] Getting all abonents');
      final response = await _dio.get(
        '/mobile/abonents',
        queryParameters: forceRefresh ? {'forceRefresh': true} : null,
      );
      return _asMapList(response.data).map(SubscriberModel.fromJson).toList();
    } catch (e) {
      AppLogger.e('[API] Error getting all abonents', e);
      throw _handleError(e);
    }
  }

  /// Получение списка абонентов по ТП
  /// GET /api/mobile/transformer-points/{tpCode}/abonents?forceRefresh=true
  Future<List<SubscriberModel>> getAbonentsByTp(String tpCode, {bool forceRefresh = false}) async {
    try {
      AppLogger.d('[API] Getting abonents for TP: $tpCode');
      final response = await _dio.get(
        '/mobile/transformer-points/$tpCode/abonents',
        queryParameters: forceRefresh ? {'forceRefresh': true} : null,
      );
      return _asMapList(response.data).map(SubscriberModel.fromJson).toList();
    } catch (e) {
      AppLogger.e('[API] Error getting abonents for TP', e);
      throw _handleError(e);
    }
  }

  /// Получение детальной информации об абоненте
  /// GET /api/mobile/abonents/{accountNumber}?forceRefresh=true
  Future<SubscriberModel> getAbonentByAccount(String accountNumber, {bool forceRefresh = false}) async {
    try {
      AppLogger.d('[API] Getting abonent data for: $accountNumber');
      final response = await _dio.get(
        '/mobile/abonents/$accountNumber',
        queryParameters: forceRefresh ? {'forceRefresh': true} : null,
      );
      return SubscriberModel.fromJson(Map<String, dynamic>.from(response.data));
    } catch (e) {
      AppLogger.e('[API] Error getting abonent data', e);
      throw _handleError(e);
    }
  }

  /// Поиск абонентов (живой поиск)
  /// GET /api/mobile/abonents/search?query=...
  Future<List<SubscriberModel>> searchAbonents(String query) async {
    try {
      AppLogger.d('[API] Searching abonents with query: $query');
      final response = await _dio.get(
        '/mobile/abonents/search',
        queryParameters: {'query': query},
      );
      return _asMapList(response.data).map(SubscriberModel.fromJson).toList();
    } catch (e) {
      AppLogger.e('[API] Search error', e);
      throw _handleError(e);
    }
  }

  /// Получить абонентов с показаниями за текущий месяц
  /// GET /api/mobile/abonents/consumption-current-month
  Future<List<SubscriberModel>> getAbonentsWithConsumption() async {
    try {
      AppLogger.d('[API] Fetching abonents with consumption for current month');
      final response = await _dio.get('/mobile/abonents/consumption-current-month');
      return _asMapList(response.data).map(SubscriberModel.fromJson).toList();
    } catch (e) {
      AppLogger.e('[API] Get consumption error', e);
      throw _handleError(e);
    }
  }

  /// Получить абонентов которые оплатили в текущем месяце
  /// GET /api/mobile/abonents/paid-current-month
  Future<List<SubscriberModel>> getAbonentsWithPayments() async {
    try {
      AppLogger.d('[API] Fetching abonents with payments for current month');
      final response = await _dio.get('/mobile/abonents/paid-current-month');
      return _asMapList(response.data).map(SubscriberModel.fromJson).toList();
    } catch (e) {
      AppLogger.e('[API] Get payments error', e);
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
      AppLogger.d('[API] Submitting meter reading for: $accountNumber, reading: $currentReading');

      final data = {
        'accountNumber': accountNumber,
        'currentReading': currentReading,
      };

      if (meterSerialNumber != null) {
        data['meterSerialNumber'] = meterSerialNumber;
      }

      final response = await _dio.post('/mobile/meter-readings', data: data);
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      AppLogger.e('[API] Error submitting reading', e);
      throw _handleError(e);
    }
  }

  /// Проверить статус показания
  /// GET /api/mobile/meter-readings/{readingId}/status
  Future<Map<String, dynamic>> checkReadingStatus(int readingId) async {
    try {
      AppLogger.d('[API] Checking reading status for: $readingId');
      final response = await _dio.get('/mobile/meter-readings/$readingId/status');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      AppLogger.e('[API] Error checking reading status', e);
      throw _handleError(e);
    }
  }

  /// Получить историю показаний по лицевому счету
  /// GET /api/mobile/meter-readings/by-account/{accountNumber}
  Future<List<Map<String, dynamic>>> getReadingHistory(String accountNumber) async {
    try {
      AppLogger.d('[API] Getting reading history for: $accountNumber');
      final response = await _dio.get('/mobile/meter-readings/by-account/$accountNumber');
      return _asMapList(response.data);
    } catch (e) {
      AppLogger.e('[API] Error getting reading history', e);
      throw _handleError(e);
    }
  }

  // ========================================
  // DASHBOARD ENDPOINT
  // ========================================

  /// GET /api/mobile/dashboard/stats
  Future<DashboardModel> getDashboardStatistics() async {
    try {
      final response = await _dio.get('/mobile/dashboard/stats');
      return DashboardModel.fromJson(Map<String, dynamic>.from(response.data));
    } catch (e) {
      AppLogger.e('[API] Error getting dashboard statistics', e);
      throw _handleError(e);
    }
  }

  // ========================================
  // APP VERSION CHECK ENDPOINT
  // ========================================

  /// Проверка версии приложения
  /// GET /api/auth/app-version
  Future<AppVersionModel> checkAppVersion() async {
    try {
      final response = await _dio.get('/auth/app-version');
      return AppVersionModel.fromJson(Map<String, dynamic>.from(response.data));
    } catch (e) {
      AppLogger.e('[API] Error checking app version', e);
      throw _handleError(e);
    }
  }

  // ========================================
  // PHONE MANAGEMENT ENDPOINTS
  // ========================================

  /// Обновить номер телефона абонента
  /// POST /api/mobile/abonents/phone
  Future<Map<String, dynamic>> updatePhone({
    required String accountNumber,
    required String phoneNumber,
  }) async {
    try {
      AppLogger.d('[API] Updating phone for account: $accountNumber');
      final response = await _dio.post(
        '/mobile/abonents/phone',
        data: {
          'accountNumber': accountNumber,
          'phoneNumber': phoneNumber,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      AppLogger.e('[API] Error updating phone', e);
      throw _handleError(e);
    }
  }

  // ========================================
  // COORDINATES MANAGEMENT ENDPOINTS
  // ========================================

  /// Обновить координаты абонента
  /// POST /api/mobile/abonents/coordinates
  Future<Map<String, dynamic>> updateCoordinates({
    required String accountNumber,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      AppLogger.d('[API] Updating coordinates for account: $accountNumber');
      final response = await _dio.post(
        '/mobile/abonents/coordinates',
        data: {
          'accountNumber': accountNumber,
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      AppLogger.e('[API] Error updating coordinates', e);
      throw _handleError(e);
    }
  }

  // ========================================
  // REPORTS ENDPOINTS
  // ========================================

  /// Сформировать отчет
  /// POST /api/mobile/reports/generate
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    String? tpId,
  }) async {
    try {
      AppLogger.d('[API] Generating report - type: $reportType, tpId: $tpId');

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

      // Ожидаем структуру: { "success": true, "data": { ... } }
      if (response.data['success'] == true && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data']);
      }

      throw AppException('Неверный формат ответа сервера');
    } catch (e) {
      AppLogger.e('[API] Error generating report', e);
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
      AppLogger.d('[API] Getting meter data for account: $accountNumber, meter: $meterNumber');
      final response = await _dio.get(
        '/mobile/abonents/$accountNumber/meter-data/$meterNumber',
      );
      return MeterDetailModel.fromJson(Map<String, dynamic>.from(response.data));
    } catch (e) {
      AppLogger.e('[API] Error getting meter data', e);
      throw _handleError(e);
    }
  }

  // ========================================
  // АСКУЭ ENDPOINTS
  // ========================================

  /// Статус АСКУЭ абонента (есть ли свежее показание)
  /// GET /api/mobile/abonents/{accountNumber}/askue
  Future<Map<String, dynamic>> getAskueStatus(String accountNumber) async {
    try {
      final response = await _dio.get('/mobile/abonents/$accountNumber/askue');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      AppLogger.e('[API] Error getting askue status', e);
      throw _handleError(e);
    }
  }

  /// История показаний АСКУЭ за период
  /// GET /api/mobile/abonents/{accountNumber}/askue/readings?dateFrom=&dateTo=
  Future<List<dynamic>> getAskueReadings(
    String accountNumber, {
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final qp = <String, dynamic>{};
      if (dateFrom != null) qp['dateFrom'] = dateFrom;
      if (dateTo != null) qp['dateTo'] = dateTo;

      final response = await _dio.get(
        '/mobile/abonents/$accountNumber/askue/readings',
        queryParameters: qp.isEmpty ? null : qp,
      );
      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('[API] Error getting askue readings', e);
      throw _handleError(e);
    }
  }

  // ========================================
  // ERROR HANDLING
  // ========================================

  /// Единый разбор ошибки в [AppException].
  /// Сначала пытается достать единый формат бэкенда
  /// `{ "error": { "code": "...", "message": "..." } }`, затем — фолбэк по типу.
  AppException _handleError(dynamic error) {
    // Если ошибка уже разобрана выше по стеку — пробрасываем как есть
    if (error is AppException) return error;

    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      // Единый формат ошибки от бэкенда
      final data = error.response?.data;
      if (data is Map && data['error'] is Map) {
        final detail = data['error'] as Map;
        final message = detail['message']?.toString();
        final code = detail['code']?.toString();
        if (message != null && message.isNotEmpty) {
          return AppException(message, code: code, statusCode: statusCode);
        }
      }

      // Фолбэк по типу ошибки
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppException('Время ожидания истекло. Проверьте соединение.',
              statusCode: statusCode);
        case DioExceptionType.connectionError:
          return AppException('Ошибка соединения. Проверьте интернет.');
        case DioExceptionType.badResponse:
          return AppException('Ошибка сервера${statusCode != null ? ' ($statusCode)' : ''}',
              statusCode: statusCode);
        default:
          return AppException('Произошла ошибка. Попробуйте позже.');
      }
    }
    return AppException('Неизвестная ошибка');
  }
}

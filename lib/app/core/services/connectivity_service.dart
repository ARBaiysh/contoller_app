import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/providers/api_provider.dart';

/// Состояние связи для глобального оверлея.
enum NetStatus {
  /// Всё в порядке — связь с сервером есть.
  ok,

  /// На устройстве нет сети (Wi-Fi/мобильные выключены или вне зоны).
  noInternet,

  /// Сеть есть, но сервер не отвечает (технические работы / 5xx / таймаут).
  serverDown,
}

/// Глобальный мониторинг связи.
///
/// Совмещает два сигнала:
///  1) состояние сети устройства (connectivity_plus) — отличает «нет интернета»;
///  2) отчёты Dio-интерцептора об ошибках/успехах запросов — отличает
///     «сервер недоступен» при наличии сети.
///
/// При [serverDown] периодически пингует сервер и сам снимает оверлей,
/// когда сервер отвечает. При возврате сети после [noInternet] проверяет
/// сервер прежде чем вернуть [ok].
class ConnectivityService extends GetxService {
  final Rx<NetStatus> status = NetStatus.ok.obs;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _healthTimer;

  // Отдельный лёгкий Dio для health-проверки (короткие таймауты,
  // без интерцепторов и токена). /auth/app-version не требует авторизации.
  late final Dio _probe = Dio(BaseOptions(
    baseUrl: ApiProvider.baseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  @override
  void onInit() {
    super.onInit();
    _sub = _connectivity.onConnectivityChanged.listen(_handleConnectivity);
    _checkInitial();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _stopHealthPolling();
    super.onClose();
  }

  Future<void> _checkInitial() async {
    try {
      _handleConnectivity(await _connectivity.checkConnectivity());
    } catch (_) {
      // Игнорируем — статус останется ok до первого реального запроса
    }
  }

  bool _hasNet(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  void _handleConnectivity(List<ConnectivityResult> results) {
    if (!_hasNet(results)) {
      status.value = NetStatus.noInternet;
      _stopHealthPolling();
    } else if (status.value == NetStatus.noInternet) {
      // Сеть вернулась — проверяем, отвечает ли сервер
      _probeServer();
    }
  }

  // ========================================
  // ОТЧЁТЫ ИЗ DIO-ИНТЕРЦЕПТОРА
  // ========================================

  /// Любой успешный ответ сервера снимает оверлей.
  void reportSuccess() {
    if (status.value != NetStatus.ok) {
      status.value = NetStatus.ok;
    }
    _stopHealthPolling();
  }

  /// Запрос упал на уровне соединения (нет сети / сервер не отвечает / 5xx).
  Future<void> reportConnectionFailure() async {
    List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } catch (_) {
      results = const [ConnectivityResult.none];
    }

    if (!_hasNet(results)) {
      status.value = NetStatus.noInternet;
      _stopHealthPolling();
    } else {
      status.value = NetStatus.serverDown;
      _startHealthPolling();
    }
  }

  // ========================================
  // ПРОВЕРКА СЕРВЕРА / ВОССТАНОВЛЕНИЕ
  // ========================================

  void _startHealthPolling() {
    _healthTimer ??=
        Timer.periodic(const Duration(seconds: 6), (_) => _probeServer());
  }

  void _stopHealthPolling() {
    _healthTimer?.cancel();
    _healthTimer = null;
  }

  Future<void> _probeServer() async {
    try {
      await _probe.get('/auth/app-version');
      status.value = NetStatus.ok;
      _stopHealthPolling();
    } catch (_) {
      List<ConnectivityResult> results;
      try {
        results = await _connectivity.checkConnectivity();
      } catch (_) {
        results = const [ConnectivityResult.none];
      }
      status.value = _hasNet(results) ? NetStatus.serverDown : NetStatus.noInternet;
    }
  }

  /// Ручной повтор из оверлея (кнопка «Повторить»).
  Future<void> retry() => _probeServer();
}

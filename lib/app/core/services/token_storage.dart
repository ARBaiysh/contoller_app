import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Защищённое хранилище токенов (Keystore на Android / Keychain на iOS).
///
/// Access- и refresh-токены лежат ТОЛЬКО здесь, а не в GetStorage.
/// Пароль инспектора больше нигде не сохраняется.
///
/// В памяти держим копию токенов, чтобы интерцептор Dio мог читать access-токен
/// синхронно (flutter_secure_storage асинхронный). [load] нужно вызвать один раз
/// при старте приложения до первых сетевых запросов.
class TokenStorage extends GetxService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  /// Сессия считается активной, если есть refresh-токен.
  bool get hasSession => _refreshToken != null && _refreshToken!.isNotEmpty;

  /// Загрузить токены из защищённого хранилища в память. Вызывать при старте.
  Future<void> load() async {
    _accessToken = await _secure.read(key: _accessTokenKey);
    _refreshToken = await _secure.read(key: _refreshTokenKey);
  }

  /// Сохранить пару токенов (после login или refresh).
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _secure.write(key: _accessTokenKey, value: accessToken);
    await _secure.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Обновить только access-токен (на случай, если refresh не ротируется).
  Future<void> saveAccessToken(String accessToken) async {
    _accessToken = accessToken;
    await _secure.write(key: _accessTokenKey, value: accessToken);
  }

  /// Полностью очистить токены (logout / истёкшая сессия).
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _secure.delete(key: _accessTokenKey);
    await _secure.delete(key: _refreshTokenKey);
  }
}

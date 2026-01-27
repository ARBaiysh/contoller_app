// lib/app/core/services/app_update_service.dart

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/app_version_model.dart';
import '../../data/providers/api_provider.dart';

class AppUpdateService extends GetxService {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // Текущая версия приложения
  String? _currentVersion;
  int? _currentBuildNumber;

  // Информация о доступной версии
  AppVersionModel? _versionInfo;
  String? get currentVersion => _currentVersion;

  // Getters
  AppVersionModel? get versionInfo => _versionInfo;

  final _softUpdateAvailable = false.obs;

  bool get softUpdateAvailable => _softUpdateAvailable.value;
  set softUpdateAvailable(bool value) => _softUpdateAvailable.value = value;
  int? get currentBuildNumber => _currentBuildNumber;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentVersion();
  }

  // ========================================
  // ПОЛУЧЕНИЕ ТЕКУЩЕЙ ВЕРСИИ ПРИЛОЖЕНИЯ
  // ========================================

  Future<void> _loadCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;
      _currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

      print('[APP UPDATE] Current app version: $_currentVersion+$_currentBuildNumber');
    } catch (e) {
      print('[APP UPDATE] Error loading current version: $e');
      _currentVersion = '1.0.0';
      _currentBuildNumber = 1;
    }
  }

  // ========================================
  // ПРОВЕРКА ВЕРСИИ НА СЕРВЕРЕ
  // ========================================

  /// Проверить, доступна ли новая версия
  Future<bool> checkForUpdate() async {
    try {
      print('[APP UPDATE] Checking for updates...');

      // Убеждаемся, что текущая версия загружена
      if (_currentBuildNumber == null) {
        await _loadCurrentVersion();
      }

      // Запрашиваем информацию о версии с сервера
      _versionInfo = await _apiProvider.checkAppVersion();

      print('[APP UPDATE] Server version: ${_versionInfo!.currentVersion}+${_versionInfo!.currentBuildNumber}');
      print('[APP UPDATE] Min version: ${_versionInfo!.minVersion}+${_versionInfo!.minBuildNumber}');
      print('[APP UPDATE] Force update: ${_versionInfo!.forceUpdate}');

      // Проверяем, нужно ли обновление
      final needsUpdate = _versionInfo!.needsUpdate(_currentBuildNumber!);

      if (needsUpdate) {
        print('[APP UPDATE] ⚠️ Update required! Current: $_currentBuildNumber, Min: ${_versionInfo!.minBuildNumber}');
      } else {
        print('[APP UPDATE] ✅ App version is up to date');
      }

      return needsUpdate;
    } catch (e) {
      print('[APP UPDATE] Error checking for update: $e');
      // В случае ошибки возвращаем false, чтобы не блокировать пользователя
      return false;
    }
  }

  // ========================================
  // ОТКРЫТИЕ GOOGLE PLAY
  // ========================================

  /// Открывает страницу приложения в Google Play
  Future<void> openPlayStore() async {
    // URL для закрытого тестирования
    const playStoreUrl = 'https://play.google.com/apps/testing/kg.asdf.contoller_app';
    final uri = Uri.parse(playStoreUrl);

    print('[APP UPDATE] Opening Play Store: $playStoreUrl');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('[APP UPDATE] ✅ Play Store opened successfully');
      } else {
        print('[APP UPDATE] ❌ Cannot launch Play Store URL');
        // Пробуем открыть обычную ссылку на Play Store
        const fallbackUrl = 'https://play.google.com/store/apps/details?id=kg.asdf.contoller_app';
        final fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('[APP UPDATE] ❌ Error opening Play Store: $e');
    }
  }
}
// lib/app/core/services/app_update_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Состояние скачивания
  final _isDownloading = false.obs;
  final _downloadProgress = 0.0.obs;
  final _downloadedBytes = 0.obs;
  final _totalBytes = 0.obs;

  // Getters
  bool get isDownloading => _isDownloading.value;
  double get downloadProgress => _downloadProgress.value;
  int get downloadedBytes => _downloadedBytes.value;
  int get totalBytes => _totalBytes.value;
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
  // СКАЧИВАНИЕ APK
  // ========================================

  /// Скачать новую версию APK
  Future<String?> downloadUpdate() async {
    if (_versionInfo == null) {
      print('[APP UPDATE] No version info available');
      return null;
    }

    try {
      _isDownloading.value = true;
      _downloadProgress.value = 0.0;
      _downloadedBytes.value = 0;
      _totalBytes.value = _versionInfo!.apkSize;

      print('[APP UPDATE] Starting download...');
      print('[APP UPDATE] APK size: ${_versionInfo!.formattedSize}');

      // Получаем путь для сохранения
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Cannot access external storage');
      }

      // Создаем путь для APK файла
      final savePath = '${directory.path}/OshPES-Controller-${_versionInfo!.currentVersion}.apk';

      print('[APP UPDATE] Save path: $savePath');

      // Удаляем старый файл, если существует
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
        print('[APP UPDATE] Deleted old APK file');
      }

      // Скачиваем файл
      await _apiProvider.downloadApk(
        savePath: savePath,
        onProgress: (received, total) {
          _downloadedBytes.value = received;
          _totalBytes.value = total;
          _downloadProgress.value = received / total;
        },
      );

      print('[APP UPDATE] ✅ Download completed: $savePath');

      _isDownloading.value = false;
      return savePath;
    } catch (e) {
      print('[APP UPDATE] ❌ Download error: $e');
      _isDownloading.value = false;
      _downloadProgress.value = 0.0;
      throw Exception('Ошибка при скачивании: $e');
    }
  }

  // ========================================
  // УСТАНОВКА APK
  // ========================================

  /// Проверить разрешение на установку APK
  Future<bool> _checkInstallPermission() async {
    if (Platform.isAndroid) {
      // Для Android 8.0+ (API 26+) нужно разрешение REQUEST_INSTALL_PACKAGES
      if (await _getAndroidVersion() >= 26) {
        return await Permission.requestInstallPackages.isGranted;
      }
    }
    return true; // Для более старых версий разрешение не требуется
  }

  /// Запросить разрешение на установку APK
  Future<bool> _requestInstallPermission() async {
    if (Platform.isAndroid) {
      if (await _getAndroidVersion() >= 26) {
        final status = await Permission.requestInstallPackages.request();

        print('[APP UPDATE] Install permission status: $status');

        if (status.isDenied || status.isPermanentlyDenied) {
          // Показываем диалог с объяснением
          await _showPermissionDialog();

          // Если permanently denied, открываем настройки
          if (status.isPermanentlyDenied) {
            await openAppSettings();
            return false;
          }

          return false;
        }

        return status.isGranted;
      }
    }
    return true;
  }

  /// Показать диалог с объяснением необходимости разрешения
  Future<void> _showPermissionDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Требуется разрешение'),
        content: const Text(
          'Для установки обновления необходимо разрешение на установку приложений из неизвестных источников.\n\n'
          'Пожалуйста, разрешите установку в настройках.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Открыть настройки'),
          ),
        ],
      ),
    );
  }

  /// Получить версию Android
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Используем package_info или device_info для получения версии
      // Для упрощения возвращаем 30 (Android 11+)
      return 30; // Предполагаем современную версию Android
    }
    return 0;
  }

  /// Запустить установку APK
  Future<bool> installApk(String apkPath) async {
    try {
      print('[APP UPDATE] Starting APK installation: $apkPath');

      // 1. Проверяем, существует ли файл
      final file = File(apkPath);
      if (!await file.exists()) {
        throw Exception('APK файл не найден: $apkPath');
      }

      print('[APP UPDATE] APK file exists, size: ${await file.length()} bytes');

      // 2. Проверяем разрешение на установку
      bool hasPermission = await _checkInstallPermission();
      print('[APP UPDATE] Install permission: $hasPermission');

      if (!hasPermission) {
        print('[APP UPDATE] Requesting install permission...');
        hasPermission = await _requestInstallPermission();

        if (!hasPermission) {
          throw Exception('Не предоставлено разрешение на установку приложений');
        }
      }

      // 3. Открываем APK файл с правильным типом
      print('[APP UPDATE] Opening APK file...');

      final result = await OpenFilex.open(
        apkPath,
        type: 'application/vnd.android.package-archive',
      );

      print('[APP UPDATE] Open result type: ${result.type}');
      print('[APP UPDATE] Open result message: ${result.message}');

      // 4. Обрабатываем результат
      switch (result.type) {
        case ResultType.done:
          print('[APP UPDATE] ✅ APK opened successfully');
          return true;

        case ResultType.fileNotFound:
          throw Exception('Файл APK не найден');

        case ResultType.noAppToOpen:
          throw Exception('Нет приложения для установки APK');

        case ResultType.permissionDenied:
          throw Exception('Отказано в разрешении');

        case ResultType.error:
          throw Exception('Ошибка открытия APK: ${result.message}');
      }
    } catch (e) {
      print('[APP UPDATE] ❌ Installation error: $e');
      rethrow; // Пробрасываем исключение для обработки выше
    }
  }

  // ========================================
  // УТИЛИТЫ
  // ========================================

  /// Форматированный прогресс (например: "12.5 / 25.3 МБ")
  String get formattedProgress {
    final downloadedMB = downloadedBytes / (1024 * 1024);
    final totalMB = totalBytes / (1024 * 1024);
    return '${downloadedMB.toStringAsFixed(1)} / ${totalMB.toStringAsFixed(1)} МБ';
  }

  /// Процент загрузки (0-100)
  int get progressPercentage {
    return (downloadProgress * 100).round();
  }

  /// Сброс состояния скачивания
  void resetDownloadState() {
    _isDownloading.value = false;
    _downloadProgress.value = 0.0;
    _downloadedBytes.value = 0;
    _totalBytes.value = 0;
  }
}
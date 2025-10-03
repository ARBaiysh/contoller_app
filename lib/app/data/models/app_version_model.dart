// lib/app/data/models/app_version_model.dart

class AppVersionModel {
  final String currentVersion;
  final int currentBuildNumber;
  final String minVersion;
  final int minBuildNumber;
  final bool forceUpdate;
  final String updateMessage;
  final String apkUrl;
  final int apkSize; // в байтах
  final String? releaseNotes;

  AppVersionModel({
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.minVersion,
    required this.minBuildNumber,
    required this.forceUpdate,
    required this.updateMessage,
    required this.apkUrl,
    required this.apkSize,
    this.releaseNotes,
  });

  // Проверка, нужно ли обновление
  bool needsUpdate(int currentAppBuildNumber) {
    return currentAppBuildNumber < minBuildNumber;
  }

  // Проверка, доступна ли новая версия
  bool hasNewerVersion(int currentAppBuildNumber) {
    return currentAppBuildNumber < currentBuildNumber;
  }

  // Форматированный размер файла
  String get formattedSize {
    final sizeInMB = apkSize / (1024 * 1024);
    return '${sizeInMB.toStringAsFixed(1)} МБ';
  }

  // From JSON
  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      currentVersion: json['currentVersion'] ?? '1.0.0',
      currentBuildNumber: json['currentBuildNumber'] ?? 1,
      minVersion: json['minVersion'] ?? '1.0.0',
      minBuildNumber: json['minBuildNumber'] ?? 1,
      forceUpdate: json['forceUpdate'] ?? false,
      updateMessage: json['updateMessage'] ?? 'Доступно новое обновление',
      apkUrl: json['apkUrl'] ?? '',
      apkSize: json['apkSize'] ?? 0,
      releaseNotes: json['releaseNotes'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'currentVersion': currentVersion,
      'currentBuildNumber': currentBuildNumber,
      'minVersion': minVersion,
      'minBuildNumber': minBuildNumber,
      'forceUpdate': forceUpdate,
      'updateMessage': updateMessage,
      'apkUrl': apkUrl,
      'apkSize': apkSize,
      'releaseNotes': releaseNotes,
    };
  }

  @override
  String toString() {
    return 'AppVersionModel(current: $currentVersion+$currentBuildNumber, '
        'min: $minVersion+$minBuildNumber, forceUpdate: $forceUpdate)';
  }
}
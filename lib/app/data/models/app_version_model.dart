// lib/app/data/models/app_version_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'app_version_model.g.dart';

@JsonSerializable()
class AppVersionModel {
  @JsonKey(defaultValue: '1.0.0')
  final String currentVersion;
  @JsonKey(defaultValue: 1)
  final int currentBuildNumber;
  @JsonKey(defaultValue: '1.0.0')
  final String minVersion;
  @JsonKey(defaultValue: 1)
  final int minBuildNumber;
  @JsonKey(defaultValue: false)
  final bool forceUpdate;
  @JsonKey(defaultValue: 'Доступно новое обновление')
  final String updateMessage;
  @JsonKey(defaultValue: '')
  final String apkUrl;
  @JsonKey(defaultValue: 0)
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

  factory AppVersionModel.fromJson(Map<String, dynamic> json) =>
      _$AppVersionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionModelToJson(this);

  @override
  String toString() {
    return 'AppVersionModel(current: $currentVersion+$currentBuildNumber, '
        'min: $minVersion+$minBuildNumber, forceUpdate: $forceUpdate)';
  }
}

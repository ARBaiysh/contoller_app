// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionModel _$AppVersionModelFromJson(Map<String, dynamic> json) =>
    AppVersionModel(
      currentVersion: json['currentVersion'] as String? ?? '1.0.0',
      currentBuildNumber: (json['currentBuildNumber'] as num?)?.toInt() ?? 1,
      minVersion: json['minVersion'] as String? ?? '1.0.0',
      minBuildNumber: (json['minBuildNumber'] as num?)?.toInt() ?? 1,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      updateMessage:
          json['updateMessage'] as String? ?? 'Доступно новое обновление',
      apkUrl: json['apkUrl'] as String? ?? '',
      apkSize: (json['apkSize'] as num?)?.toInt() ?? 0,
      releaseNotes: json['releaseNotes'] as String?,
    );

Map<String, dynamic> _$AppVersionModelToJson(AppVersionModel instance) =>
    <String, dynamic>{
      'currentVersion': instance.currentVersion,
      'currentBuildNumber': instance.currentBuildNumber,
      'minVersion': instance.minVersion,
      'minBuildNumber': instance.minBuildNumber,
      'forceUpdate': instance.forceUpdate,
      'updateMessage': instance.updateMessage,
      'apkUrl': instance.apkUrl,
      'apkSize': instance.apkSize,
      'releaseNotes': instance.releaseNotes,
    };

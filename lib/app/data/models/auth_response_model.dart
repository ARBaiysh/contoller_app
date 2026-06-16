import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

class AuthResponseModel {
  final String token;
  final String? refreshToken;
  final InspectorData inspector;

  AuthResponseModel({
    required this.token,
    this.refreshToken,
    required this.inspector,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'],
      inspector: json['inspector'] != null
          ? InspectorData.fromJson(Map<String, dynamic>.from(json['inspector']))
          : InspectorData.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'inspector': inspector.toJson(),
    };
  }

  // Для обратной совместимости
  String get status => 'SUCCESS'; // В новом API всегда успех если пришел ответ
  String? get message => null;
  String? get fullName => inspector.fullName;
}

@JsonSerializable()
class InspectorData {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(defaultValue: '')
  final String fullName;
  @JsonKey(defaultValue: '')
  final String externalId;
  @JsonKey(defaultValue: '')
  final String regionCode;
  @JsonKey(defaultValue: '')
  final String regionName;

  InspectorData({
    required this.id,
    required this.username,
    required this.fullName,
    required this.externalId,
    required this.regionCode,
    required this.regionName,
  });

  factory InspectorData.fromJson(Map<String, dynamic> json) =>
      _$InspectorDataFromJson(json);

  Map<String, dynamic> toJson() => _$InspectorDataToJson(this);

  // Для обратной совместимости с кодом, который использует inspectorId
  int get inspectorId => id;

  static InspectorData empty() {
    return InspectorData(
      id: 0,
      username: '',
      fullName: '',
      externalId: '',
      regionCode: '',
      regionName: '',
    );
  }
}

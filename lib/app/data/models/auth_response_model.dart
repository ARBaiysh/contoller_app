class AuthResponseModel {
  final String token;
  final InspectorData inspector;

  AuthResponseModel({
    required this.token,
    required this.inspector,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      inspector: InspectorData.fromJson(json['inspector'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'inspector': inspector.toJson(),
    };
  }

  // Для обратной совместимости
  String get status => 'SUCCESS'; // В новом API всегда успех если пришел ответ
  String? get message => null;
  String? get fullName => inspector.fullName;
}

class InspectorData {
  final int id;
  final String username;
  final String fullName;
  final String externalId;
  final String regionCode;
  final String regionName;

  InspectorData({
    required this.id,
    required this.username,
    required this.fullName,
    required this.externalId,
    required this.regionCode,
    required this.regionName,
  });

  factory InspectorData.fromJson(Map<String, dynamic> json) {
    return InspectorData(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      externalId: json['externalId'] ?? '',
      regionCode: json['regionCode'] ?? '',
      regionName: json['regionName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'externalId': externalId,
      'regionCode': regionCode,
      'regionName': regionName,
    };
  }

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

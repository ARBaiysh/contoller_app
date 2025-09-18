class AuthResponseModel {
  final String status;
  final String? token;
  final String? message;
  final int? syncMessageId;
  final int? inspectorId;
  final String? username;
  final String? fullName;
  final String? regionCode;
  final String? regionName;
  final String? role;
  final int? expiresIn;

  AuthResponseModel({
    required this.status,
    this.token,
    this.message,
    this.syncMessageId,
    this.inspectorId,
    this.username,
    this.fullName,
    this.regionCode,
    this.regionName,
    this.role,
    this.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      status: json['status'] ?? 'ERROR',
      token: json['token'],
      message: json['message'],
      syncMessageId: json['syncMessageId'],
      inspectorId: json['inspectorId'],
      username: json['username'],
      fullName: json['fullName'],
      regionCode: json['regionCode'],
      regionName: json['regionName'],
      role: json['role'],
      expiresIn: json['expiresIn'],
    );
  }

  // Преобразуем в InspectorData для совместимости
  InspectorData? toInspectorData() {
    if (inspectorId != null && fullName != null && regionName != null && regionCode != null && username != null) {
      return InspectorData(
        inspectorId: inspectorId!,
        fullName: fullName!,
        regionName: regionName!,
        regionCode: regionCode!,
        username: username!,
      );
    }
    return null;
  }
}

// Оставляем для совместимости
class InspectorData {
  final int inspectorId;
  final String fullName;
  final String regionName;
  final String regionCode;
  final String username;

  InspectorData({
    required this.inspectorId,
    required this.fullName,
    required this.regionName,
    required this.regionCode,
    required this.username,
  });

  factory InspectorData.fromJson(Map<String, dynamic> json) {
    return InspectorData(
      inspectorId: json['inspectorId'],
      fullName: json['fullName'],
      regionName: json['regionName'],
      regionCode: json['regionCode'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspectorId': inspectorId,
      'fullName': fullName,
      'regionName': regionName,
      'regionCode': regionCode,
      'username': username,
    };
  }
}
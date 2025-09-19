class SyncStatusModel {
  final String messageType;
  final int messageId;
  final String status; // NEW/PROCESSING/DONE/ERROR
  final String? errorDetails;

  SyncStatusModel({
    required this.messageType,
    required this.messageId,
    required this.status,
    this.errorDetails,
  });

  factory SyncStatusModel.fromJson(Map<String, dynamic> json) {
    return SyncStatusModel(
      messageType: json['messageType'] ?? '',
      messageId: json['messageId'] ?? 0,
      status: json['status'] ?? 'ERROR',
      errorDetails: json['errorDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageType': messageType,
      'messageId': messageId,
      'status': status,
      'errorDetails': errorDetails,
    };
  }

  // Convenience getters
  bool get isSuccess => status == 'DONE';
  bool get isError => status == 'ERROR';
  bool get isSyncing => status == 'SYNCING' || status == 'NEW' || status == 'PROCESSING';

  String get displayMessage {
    switch (status) {
      case 'SUCCESS':
        return 'Синхронизация завершена успешно';
      case 'ERROR':
        return errorDetails ?? 'Ошибка синхронизации';
      case 'SYNCING':
      case 'NEW':
      case 'PROCESSING':
        return 'Выполняется синхронизация с 1С...';
      default:
        return 'Неизвестный статус: $status';
    }
  }
}
class SyncStatusModel {
  final String messageType;
  final int messageId;
  final String status; // NEW/PROCESSING/DONE/ERROR/SYNCING
  final String? result; // Заменили errorDetails на result

  SyncStatusModel({
    required this.messageType,
    required this.messageId,
    required this.status,
    this.result,
  });

  factory SyncStatusModel.fromJson(Map<String, dynamic> json) {
    return SyncStatusModel(
      messageType: json['messageType'] ?? 'UNKNOWN',
      messageId: json['messageId'] ?? 0,
      status: json['status'] ?? 'ERROR',
      result: json['result'], // Новое поле
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageType': messageType,
      'messageId': messageId,
      'status': status,
      'result': result,
    };
  }

  // Convenience getters (ОБНОВЛЕННЫЕ)
  bool get isSuccess => status == 'DONE';
  bool get isError => status == 'ERROR';
  bool get isSyncing => status == 'SYNCING' || status == 'NEW' || status == 'PROCESSING';

  // Обновленные сообщения
  String get displayMessage {
    switch (status) {
      case 'DONE':
        return result ?? 'Синхронизация завершена успешно';
      case 'ERROR':
        return result ?? 'Ошибка синхронизации';
      case 'SYNCING':
      case 'NEW':
      case 'PROCESSING':
        return 'Выполняется синхронизация...';
      default:
        return result ?? 'Неизвестный статус: $status';
    }
  }

  static SyncStatusModel empty() {
    return SyncStatusModel(
      messageType: '',
      messageId: 0,
      status: '',
      result: null,
    );
  }

  // Для ошибок - извлекаем детали из result
  String? get errorDetails => isError ? result : null;
}
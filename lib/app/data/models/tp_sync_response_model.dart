class TpSyncResponseModel {
  final int? syncMessageId;
  final String status;
  final String? message;

  TpSyncResponseModel({
    this.syncMessageId,
    required this.status,
    this.message,
  });

  factory TpSyncResponseModel.fromJson(Map<String, dynamic> json) {
    return TpSyncResponseModel(
      syncMessageId: json['syncMessageId'],
      status: json['status'] ?? 'ERROR',
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'syncMessageId': syncMessageId,
      'status': status,
      'message': message,
    };
  }

  // Convenience getters
  bool get isInitiated => status == 'INITIATED';
  bool get isAlreadyRunning => status == 'ALREADY_RUNNING';
  bool get isError => status == 'ERROR';

  String get displayMessage {
    switch (status) {
      case 'INITIATED':
        return 'Синхронизация запущена';
      case 'ALREADY_RUNNING':
        return message ?? 'Синхронизация уже выполняется';
      case 'ERROR':
        return message ?? 'Ошибка запуска синхронизации';
      default:
        return message ?? 'Неизвестный статус: $status';
    }
  }
}
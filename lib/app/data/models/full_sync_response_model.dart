class FullSyncResponse {
  final String status;
  final String? message;

  FullSyncResponse({
    required this.status,
    this.message,
  });

  factory FullSyncResponse.fromJson(Map<String, dynamic> json) {
    return FullSyncResponse(
      status: json['status'] ?? 'ERROR',
      message: json['message'],
    );
  }

  // Геттеры для удобной проверки статуса
  bool get isInitiated => status == 'INITIATED';
  bool get isAlreadyRunning => status == 'ALREADY_RUNNING';
  bool get isError => status == 'ERROR';

  String get displayMessage {
    switch (status) {
      case 'INITIATED':
        return message ?? 'Синхронизация запущена';
      case 'ALREADY_RUNNING':
        return message ?? 'Синхронизация уже выполняется';
      case 'ERROR':
        return message ?? 'Ошибка запуска синхронизации';
      default:
        return message ?? 'Неизвестный статус';
    }
  }

  @override
  String toString() {
    return 'FullSyncResponse(status: $status, message: $message)';
  }
}
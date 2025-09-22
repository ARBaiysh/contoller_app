class AbonentSyncResponseModel {
  final int? syncMessageId;
  final String status;
  final String? message;

  AbonentSyncResponseModel({
    this.syncMessageId,
    required this.status,
    this.message,
  });

  factory AbonentSyncResponseModel.fromJson(Map<String, dynamic> json) {
    return AbonentSyncResponseModel(
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

  // ========================================
  // CONVENIENCE GETTERS
  // ========================================

  /// Синхронизация успешно запущена
  bool get isInitiated => status == 'INITIATED';

  /// Синхронизация уже выполняется
  bool get isAlreadyRunning => status == 'ALREADY_RUNNING';

  /// Ошибка запуска синхронизации
  bool get isError => status == 'ERROR';

  /// Сообщение для отображения пользователю
  String get displayMessage {
    switch (status) {
      case 'INITIATED':
        return 'Синхронизация абонентов запущена';
      case 'ALREADY_RUNNING':
        return message ?? 'Синхронизация абонентов уже выполняется';
      case 'ERROR':
        return message ?? 'Ошибка запуска синхронизации абонентов';
      default:
        return message ?? 'Неизвестный статус: $status';
    }
  }

  /// Краткое описание статуса
  String get statusDescription {
    switch (status) {
      case 'INITIATED':
        return 'Запущена';
      case 'ALREADY_RUNNING':
        return 'Уже выполняется';
      case 'ERROR':
        return 'Ошибка';
      default:
        return 'Неизвестно';
    }
  }

  @override
  String toString() {
    return 'AbonentSyncResponseModel(status: $status, messageId: $syncMessageId, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AbonentSyncResponseModel &&
        other.syncMessageId == syncMessageId &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(syncMessageId, status, message);

  // Добавить в класс AbonentSyncResponseModel:
  static AbonentSyncResponseModel empty() {
    return AbonentSyncResponseModel(
      syncMessageId: null,
      status: '',
      message: null,
    );
  }
}
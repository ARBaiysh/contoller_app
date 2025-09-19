class SubscriberModel {
  final int id;
  final String accountNumber;
  final String fullName;
  final String address;
  final String? phone; // НОВОЕ ПОЛЕ
  final double balance;
  final int? lastReading;
  final DateTime? lastReadingDate;
  final bool canTakeReading; // ОБНОВЛЕНО: заменили ReadingStatus

  // Информация о счетчике (ОБНОВЛЕНО)
  final String meterType;
  final String meterSerialNumber;
  final String sealNumber;
  final String tariffName; // НОВОЕ ПОЛЕ

  // Информация о платежах
  final double lastPaymentAmount;
  final DateTime? lastPaymentDate;

  // Информация о ТП (НОВЫЕ ПОЛЯ)
  final String transformerPointCode;
  final String transformerPointName;

  SubscriberModel({
    required this.id,
    required this.accountNumber,
    required this.fullName,
    required this.address,
    this.phone,
    this.balance = 0.0,
    this.lastReading,
    this.lastReadingDate,
    this.canTakeReading = true,
    required this.meterType,
    required this.meterSerialNumber,
    this.sealNumber = '',
    required this.tariffName,
    this.lastPaymentAmount = 0.0,
    this.lastPaymentDate,
    required this.transformerPointCode,
    required this.transformerPointName,
  });

  // ========================================
  // COMPUTED PROPERTIES
  // ========================================

  /// Проверка, является ли абонент должником
  bool get isDebtor => balance < 0;

  /// Сумма долга (положительное значение)
  double get debtAmount => balance < 0 ? balance.abs() : 0;

  /// Можно ли снимать показания
  bool get canTakeReadings => canTakeReading;

  /// Краткая информация о счетчике
  String get meterInfo => '$meterType №$meterSerialNumber';

  /// Форматированный баланс с валютой
  String get formattedBalance {
    final absBalance = balance.abs();
    final formatted = absBalance.toStringAsFixed(2);
    return balance < 0 ? '-$formatted сом.' : '+$formatted сом.';
  }

  /// Статус для цветовой индикации
  SubscriberStatus get status {
    if (!canTakeReading) return SubscriberStatus.disabled;
    if (isDebtor) return SubscriberStatus.debtor;
    return SubscriberStatus.normal;
  }

  // ========================================
  // JSON SERIALIZATION
  // ========================================

  factory SubscriberModel.fromJson(Map<String, dynamic> json) {
    return SubscriberModel(
      id: json['id'] ?? 0,
      accountNumber: json['accountNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
      balance: (json['balance'] ?? 0).toDouble(),
      lastReading: json['lastReading'],
      lastReadingDate: json['lastReadingDate'] != null
          ? DateTime.tryParse(json['lastReadingDate'])
          : null,
      canTakeReading: json['canTakeReading'] ?? true,
      meterType: json['meterType'] ?? 'СОЭ',
      meterSerialNumber: json['meterSerialNumber'] ?? '',
      sealNumber: json['sealNumber'] ?? '',
      tariffName: json['tariffName'] ?? 'Обычный',
      lastPaymentAmount: (json['lastPaymentAmount'] ?? 0).toDouble(),
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.tryParse(json['lastPaymentDate'])
          : null,
      transformerPointCode: json['transformerPointCode'] ?? '',
      transformerPointName: json['transformerPointName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'fullName': fullName,
      'address': address,
      'phone': phone,
      'balance': balance,
      'lastReading': lastReading,
      'lastReadingDate': lastReadingDate?.toIso8601String(),
      'canTakeReading': canTakeReading,
      'meterType': meterType,
      'meterSerialNumber': meterSerialNumber,
      'sealNumber': sealNumber,
      'tariffName': tariffName,
      'lastPaymentAmount': lastPaymentAmount,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'transformerPointCode': transformerPointCode,
      'transformerPointName': transformerPointName,
    };
  }

  // ========================================
  // COPY WITH
  // ========================================

  SubscriberModel copyWith({
    int? id,
    String? accountNumber,
    String? fullName,
    String? address,
    String? phone,
    double? balance,
    int? lastReading,
    DateTime? lastReadingDate,
    bool? canTakeReading,
    String? meterType,
    String? meterSerialNumber,
    String? sealNumber,
    String? tariffName,
    double? lastPaymentAmount,
    DateTime? lastPaymentDate,
    String? transformerPointCode,
    String? transformerPointName,
  }) {
    return SubscriberModel(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      lastReading: lastReading ?? this.lastReading,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      canTakeReading: canTakeReading ?? this.canTakeReading,
      meterType: meterType ?? this.meterType,
      meterSerialNumber: meterSerialNumber ?? this.meterSerialNumber,
      sealNumber: sealNumber ?? this.sealNumber,
      tariffName: tariffName ?? this.tariffName,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      transformerPointCode: transformerPointCode ?? this.transformerPointCode,
      transformerPointName: transformerPointName ?? this.transformerPointName,
    );
  }

  @override
  String toString() {
    return 'SubscriberModel(id: $id, accountNumber: $accountNumber, fullName: $fullName, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriberModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ========================================
// ENUMS AND HELPERS
// ========================================

/// Статус абонента для цветовой индикации
enum SubscriberStatus {
  normal,    // Обычный (зеленый/нейтральный)
  debtor,    // Должник (красный)
  disabled,  // Нельзя снимать показания (серый)
}

extension SubscriberStatusExtension on SubscriberStatus {
  /// Цветовая индикация для UI
  String get displayName {
    switch (this) {
      case SubscriberStatus.normal:
        return 'Обычный';
      case SubscriberStatus.debtor:
        return 'Должник';
      case SubscriberStatus.disabled:
        return 'Заблокирован';
    }
  }

  /// Описание статуса
  String get description {
    switch (this) {
      case SubscriberStatus.normal:
        return 'Можно снимать показания';
      case SubscriberStatus.debtor:
        return 'Отрицательный баланс';
      case SubscriberStatus.disabled:
        return 'Показания заблокированы';
    }
  }
}
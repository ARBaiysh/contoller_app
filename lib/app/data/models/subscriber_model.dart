// lib/app/data/models/subscriber_model.dart

import 'package:intl/intl.dart';

class SubscriberModel {
  final String accountNumber;
  final String fullName;
  final String address;
  final String? phone;
  final double balance;
  final String meterSerialNumber;
  final String? meterType;
  final int currentReading;
  final int previousReading;
  final DateTime? lastReadingDate;
  final double currentMonthConsumption;
  final double currentMonthCharge;
  final DateTime? lastPaymentDate;
  final double lastPaymentAmount;
  final double tariff;
  final String? tariffName;
  final String transformerPointCode;
  final String transformerPointName;
  final String? contractDate;
  final String? notes;

  SubscriberModel({
    required this.accountNumber,
    required this.fullName,
    required this.address,
    this.phone,
    this.balance = 0.0,
    required this.meterSerialNumber,
    this.meterType,
    this.currentReading = 0,
    this.previousReading = 0,
    this.lastReadingDate,
    this.currentMonthConsumption = 0.0,
    this.currentMonthCharge = 0.0,
    this.lastPaymentDate,
    this.lastPaymentAmount = 0.0,
    this.tariff = 0.0,
    this.tariffName,
    required this.transformerPointCode,
    required this.transformerPointName,
    this.contractDate,
    this.notes,
  });

  // ========================================
  // COMPUTED PROPERTIES
  // ========================================

  /// Проверка, является ли абонент должником (положительный баланс = долг)
  bool get isDebtor => balance > 0;

  /// Сумма долга (положительное значение)
  double get debtAmount => balance > 0 ? balance : 0;

  /// Краткая информация о счетчике
  String get meterInfo => 'Счетчик №$meterSerialNumber';

  /// Форматированный баланс с валютой
  String get formattedBalance {
    final absBalance = balance.abs();
    final formatted = absBalance.toStringAsFixed(2);
    if (balance > 0) {
      return 'Долг: $formatted сом';
    } else if (balance < 0) {
      return 'Предоплата: $formatted сом';
    } else {
      return '0.00 сом';
    }
  }

  /// Форматированное потребление
  String get formattedConsumption {
    return '${NumberFormat('#,###.#', 'ru').format(currentMonthConsumption)} кВт·ч';
  }

  /// Форматированное начисление
  String get formattedCharge {
    return '${NumberFormat('#,###.##', 'ru').format(currentMonthCharge)} сом';
  }

  /// Статус для цветовой индикации
  SubscriberStatus get status {
    if (isDebtor) return SubscriberStatus.debtor;
    return SubscriberStatus.normal;
  }

  /// Проверка наличия валидного телефона
  bool get hasValidPhone {
    if (phone == null || phone!.isEmpty) return false;
    final digits = phone!.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 9;
  }

  /// Телефон для звонка (с +996)
  String? get phoneForCall {
    if (!hasValidPhone) return null;
    String clean = phone!.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.startsWith('0')) clean = '996${clean.substring(1)}';
    return '+$clean';
  }

  /// Отформатированный телефон для отображения
  String? get formattedPhone {
    if (!hasValidPhone) return null;
    return phone;
  }

  // ========================================
  // BACKWARD COMPATIBILITY GETTERS
  // ========================================

  /// Для обратной совместимости: можно ли снять показания
  bool get canTakeReading {
    // Можно снять показания, если еще не снимали в этом месяце
    if (lastReadingDate == null) return true;
    final now = DateTime.now();
    return !(lastReadingDate!.year == now.year && lastReadingDate!.month == now.month);
  }

  /// Для обратной совместимости: последнее показание
  int? get lastReading => currentReading;

  /// Для обратной совместимости: ID абонента (используем accountNumber)
  String get id => accountNumber;

  // ========================================
  // JSON SERIALIZATION
  // ========================================

  factory SubscriberModel.fromJson(Map<String, dynamic> json) {
    String? processPhone(dynamic phoneValue) {
      if (phoneValue == null) return null;

      final phoneStr = phoneValue.toString().trim();

      if (phoneStr.isEmpty) return null;

      final invalidPlaceholders = [
        'неопределено',
        'не указано',
        'не указан',
        'отсутствует',
        'нет данных',
        'нет',
        'n/a',
        'na',
        'none',
        'null',
        'undefined',
        'unknown',
        '-',
        '--',
        '---',
      ];

      if (invalidPlaceholders.contains(phoneStr.toLowerCase())) {
        return null;
      }

      final digitsOnly = phoneStr.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 9) {
        return null;
      }

      return phoneStr;
    }

    return SubscriberModel(
      accountNumber: json['accountNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      phone: processPhone(json['phone']),
      balance: (json['balance'] ?? 0).toDouble(),
      meterSerialNumber: json['meterSerialNumber'] ?? '',
      meterType: json['meterType'],
      currentReading: json['lastReading'] ?? json['currentReading'] ?? 0,
      previousReading: json['previousReading'] ?? 0,
      lastReadingDate: json['lastReadingDate'] != null
          ? DateTime.tryParse(json['lastReadingDate'])
          : null,
      currentMonthConsumption: (json['currentMonthConsumption'] ?? 0).toDouble(),
      currentMonthCharge: (json['currentMonthCharge'] ?? 0).toDouble(),
      lastPaymentAmount: (json['lastPaymentAmount'] ?? 0).toDouble(),
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.tryParse(json['lastPaymentDate'])
          : null,
      tariff: (json['tariff'] ?? 0).toDouble(),
      tariffName: json['tariffName'],
      transformerPointCode: json['transformerPointCode'] ?? '',
      transformerPointName: json['transformerPointName'] ?? '',
      contractDate: json['contractDate'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'fullName': fullName,
      'address': address,
      'phone': phone,
      'balance': balance,
      'meterSerialNumber': meterSerialNumber,
      'meterType': meterType,
      'currentReading': currentReading,
      'previousReading': previousReading,
      'lastReadingDate': lastReadingDate?.toIso8601String(),
      'currentMonthConsumption': currentMonthConsumption,
      'currentMonthCharge': currentMonthCharge,
      'lastPaymentAmount': lastPaymentAmount,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'tariff': tariff,
      'tariffName': tariffName,
      'transformerPointCode': transformerPointCode,
      'transformerPointName': transformerPointName,
      'contractDate': contractDate,
      'notes': notes,
    };
  }

  // ========================================
  // COPY WITH
  // ========================================

  SubscriberModel copyWith({
    String? accountNumber,
    String? fullName,
    String? address,
    String? phone,
    double? balance,
    String? meterSerialNumber,
    String? meterType,
    int? currentReading,
    int? previousReading,
    DateTime? lastReadingDate,
    double? currentMonthConsumption,
    double? currentMonthCharge,
    DateTime? lastPaymentDate,
    double? lastPaymentAmount,
    double? tariff,
    String? tariffName,
    String? transformerPointCode,
    String? transformerPointName,
    String? contractDate,
    String? notes,
  }) {
    return SubscriberModel(
      accountNumber: accountNumber ?? this.accountNumber,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      meterSerialNumber: meterSerialNumber ?? this.meterSerialNumber,
      meterType: meterType ?? this.meterType,
      currentReading: currentReading ?? this.currentReading,
      previousReading: previousReading ?? this.previousReading,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      currentMonthConsumption: currentMonthConsumption ?? this.currentMonthConsumption,
      currentMonthCharge: currentMonthCharge ?? this.currentMonthCharge,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      tariff: tariff ?? this.tariff,
      tariffName: tariffName ?? this.tariffName,
      transformerPointCode: transformerPointCode ?? this.transformerPointCode,
      transformerPointName: transformerPointName ?? this.transformerPointName,
      contractDate: contractDate ?? this.contractDate,
      notes: notes ?? this.notes,
    );
  }

  static SubscriberModel empty() {
    return SubscriberModel(
      accountNumber: '',
      fullName: '',
      address: '',
      phone: null,
      balance: 0.0,
      meterSerialNumber: '',
      currentReading: 0,
      previousReading: 0,
      lastReadingDate: null,
      currentMonthConsumption: 0.0,
      currentMonthCharge: 0.0,
      lastPaymentAmount: 0.0,
      lastPaymentDate: null,
      tariff: 0.0,
      transformerPointCode: '',
      transformerPointName: '',
      contractDate: null,
      notes: null,
    );
  }

  @override
  String toString() {
    return 'SubscriberModel(accountNumber: $accountNumber, fullName: $fullName, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriberModel && other.accountNumber == accountNumber;
  }

  @override
  int get hashCode => accountNumber.hashCode;
}

// ========================================
// ENUMS AND HELPERS
// ========================================

/// Статус абонента для цветовой индикации
enum SubscriberStatus {
  normal,    // Обычный (зеленый/нейтральный)
  debtor,    // Должник (красный)
}

extension SubscriberStatusExtension on SubscriberStatus {
  /// Цветовая индикация для UI
  String get displayName {
    switch (this) {
      case SubscriberStatus.normal:
        return 'Обычный';
      case SubscriberStatus.debtor:
        return 'Должник';
    }
  }

  /// Описание статуса
  String get description {
    switch (this) {
      case SubscriberStatus.normal:
        return 'Баланс в норме';
      case SubscriberStatus.debtor:
        return 'Есть задолженность';
    }
  }
}
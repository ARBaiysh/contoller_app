// lib/app/data/models/subscriber_model.dart

import 'package:intl/intl.dart';

class SubscriberModel {
  final int id;
  final String accountNumber;
  final String fullName;
  final String address;
  final String? phone;
  final double balance;
  final int? lastReading;
  final DateTime? lastReadingDate;

  // ✅ НОВЫЕ ПОЛЯ
  final int currentMonthConsumption;
  final double currentMonthCharge;

  final bool canTakeReading;

  // Информация о счетчике
  final String meterType;
  final String meterSerialNumber;
  final String sealNumber;
  final String tariffName;

  // Информация о платежах
  final double lastPaymentAmount;
  final DateTime? lastPaymentDate;

  // Информация о ТП
  final String transformerPointCode;
  final String transformerPointName;

  // Информация о синхронизации
  final DateTime? lastSync;

  SubscriberModel({
    required this.id,
    required this.accountNumber,
    required this.fullName,
    required this.address,
    this.phone,
    this.balance = 0.0,
    this.lastReading,
    this.lastReadingDate,
    // ✅ НОВЫЕ ПАРАМЕТРЫ
    this.currentMonthConsumption = 0,
    this.currentMonthCharge = 0.0,
    this.canTakeReading = true,
    required this.meterType,
    required this.meterSerialNumber,
    this.sealNumber = '',
    required this.tariffName,
    this.lastPaymentAmount = 0.0,
    this.lastPaymentDate,
    required this.transformerPointCode,
    required this.transformerPointName,
    this.lastSync,
  });

  // ========================================
  // COMPUTED PROPERTIES
  // ========================================

  /// Проверка, является ли абонент должником
  bool get isDebtor => balance > 0;

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
    return balance > 0 ? '$formatted сом.' : '$formatted сом.';
  }

  /// ✅ НОВОЕ: Форматированное потребление
  String get formattedConsumption {
    return '${NumberFormat('#,###', 'ru').format(currentMonthConsumption)} кВт·ч';
  }

  /// ✅ НОВОЕ: Форматированное начисление
  String get formattedCharge {
    return '${NumberFormat('#,###.##', 'ru').format(currentMonthCharge)} сом';
  }

  /// Статус для цветовой индикации
  SubscriberStatus get status {
    if (!canTakeReading) return SubscriberStatus.disabled;
    if (isDebtor) return SubscriberStatus.debtor;
    return SubscriberStatus.normal;
  }

  /// Форматированная дата последней синхронизации
  String get formattedLastSync {
    if (lastSync == null) return 'Не синхронизировано';

    final now = DateTime.now();
    final difference = now.difference(lastSync!);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин. назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      final formatter = DateFormat('dd.MM.yyyy HH:mm');
      return formatter.format(lastSync!);
    }
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
      id: json['id'] ?? 0,
      accountNumber: json['accountNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      phone: processPhone(json['phone']),
      balance: (json['balance'] ?? 0).toDouble(),
      lastReading: json['lastReading'],
      lastReadingDate: json['lastReadingDate'] != null
          ? DateTime.tryParse(json['lastReadingDate'])
          : null,
      // ✅ НОВЫЕ ПОЛЯ
      currentMonthConsumption: json['currentMonthConsumption'] ?? 0,
      currentMonthCharge: (json['currentMonthCharge'] ?? 0).toDouble(),
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
      lastSync: json['lastSync'] != null
          ? DateTime.tryParse(json['lastSync'])
          : null,
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
      // ✅ НОВЫЕ ПОЛЯ
      'currentMonthConsumption': currentMonthConsumption,
      'currentMonthCharge': currentMonthCharge,
      'canTakeReading': canTakeReading,
      'meterType': meterType,
      'meterSerialNumber': meterSerialNumber,
      'sealNumber': sealNumber,
      'tariffName': tariffName,
      'lastPaymentAmount': lastPaymentAmount,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'transformerPointCode': transformerPointCode,
      'transformerPointName': transformerPointName,
      'lastSync': lastSync?.toIso8601String(),
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
    // ✅ НОВЫЕ ПАРАМЕТРЫ
    int? currentMonthConsumption,
    double? currentMonthCharge,
    bool? canTakeReading,
    String? meterType,
    String? meterSerialNumber,
    String? sealNumber,
    String? tariffName,
    double? lastPaymentAmount,
    DateTime? lastPaymentDate,
    String? transformerPointCode,
    String? transformerPointName,
    DateTime? lastSync,
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
      // ✅ НОВЫЕ ПОЛЯ
      currentMonthConsumption: currentMonthConsumption ?? this.currentMonthConsumption,
      currentMonthCharge: currentMonthCharge ?? this.currentMonthCharge,
      canTakeReading: canTakeReading ?? this.canTakeReading,
      meterType: meterType ?? this.meterType,
      meterSerialNumber: meterSerialNumber ?? this.meterSerialNumber,
      sealNumber: sealNumber ?? this.sealNumber,
      tariffName: tariffName ?? this.tariffName,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      transformerPointCode: transformerPointCode ?? this.transformerPointCode,
      transformerPointName: transformerPointName ?? this.transformerPointName,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  static SubscriberModel empty() {
    return SubscriberModel(
      id: 0,
      accountNumber: '',
      fullName: '',
      address: '',
      phone: null,
      balance: 0.0,
      lastReading: null,
      lastReadingDate: null,
      currentMonthConsumption: 0,
      currentMonthCharge: 0.0,
      canTakeReading: false,
      meterType: '',
      meterSerialNumber: '',
      sealNumber: '',
      tariffName: '',
      lastPaymentAmount: 0.0,
      lastPaymentDate: null,
      transformerPointCode: '',
      transformerPointName: '',
      lastSync: null,
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
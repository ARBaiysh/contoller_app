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

  // НОВОЕ ПОЛЕ: Информация о синхронизации
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
    this.canTakeReading = true,
    required this.meterType,
    required this.meterSerialNumber,
    this.sealNumber = '',
    required this.tariffName,
    this.lastPaymentAmount = 0.0,
    this.lastPaymentDate,
    required this.transformerPointCode,
    required this.transformerPointName,
    this.lastSync, // НОВОЕ ПОЛЕ
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

  /// Статус для цветовой индикации
  SubscriberStatus get status {
    if (!canTakeReading) return SubscriberStatus.disabled;
    if (isDebtor) return SubscriberStatus.debtor;
    return SubscriberStatus.normal;
  }

  /// НОВОЕ: Форматированная дата последней синхронизации
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

  /// НОВОЕ: Полная форматированная дата синхронизации
  String get fullFormattedLastSync {
    if (lastSync == null) return 'Не синхронизировано';
    final formatter = DateFormat('dd.MM.yyyy в HH:mm');
    return formatter.format(lastSync!);
  }

  /// НОВОЕ: Форматированный телефон для звонка (формат Кыргызстана)
  /// Преобразует номер в международный формат +996XXXXXXXXX
  String? get phoneForCall {
    if (phone == null || phone!.isEmpty) return null;

    // Убираем все пробелы, скобки, дефисы
    String cleaned = phone!.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Если номер начинается с 0, заменяем на +996
    if (cleaned.startsWith('0')) {
      return '+996${cleaned.substring(1)}';
    }

    // Если начинается с 996 без +, добавляем +
    if (cleaned.startsWith('996')) {
      return '+$cleaned';
    }

    // Если уже с +996, возвращаем как есть
    if (cleaned.startsWith('+996')) {
      return cleaned;
    }

    // Если формат непонятен, добавляем +996 в начало
    return '+996$cleaned';
  }

  /// НОВОЕ: Красиво отформатированный телефон для отображения
  /// Формат: +996 (XXX) XX-XX-XX
  String? get formattedPhone {
    if (phone == null || phone!.isEmpty) return null;

    String? callPhone = phoneForCall;
    if (callPhone == null) return phone;

    // Убираем +996
    String digits = callPhone.replaceAll('+996', '');

    // Форматируем: (XXX) XX-XX-XX
    if (digits.length == 9) {
      return '+996 (${digits.substring(0, 3)}) ${digits.substring(3, 5)}-${digits.substring(5, 7)}-${digits.substring(7, 9)}';
    }

    return phone; // Если формат неожиданный, возвращаем оригинал
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
      // НОВОЕ: парсинг lastSync
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
      'canTakeReading': canTakeReading,
      'meterType': meterType,
      'meterSerialNumber': meterSerialNumber,
      'sealNumber': sealNumber,
      'tariffName': tariffName,
      'lastPaymentAmount': lastPaymentAmount,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'transformerPointCode': transformerPointCode,
      'transformerPointName': transformerPointName,
      'lastSync': lastSync?.toIso8601String(), // НОВОЕ
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
    DateTime? lastSync, // НОВОЕ
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
      lastSync: lastSync ?? this.lastSync, // НОВОЕ
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
      canTakeReading: false,
      meterType: '',
      meterSerialNumber: '',
      sealNumber: '',
      tariffName: '',
      lastPaymentAmount: 0.0,
      lastPaymentDate: null,
      transformerPointCode: '',
      transformerPointName: '',
      lastSync: null, // НОВОЕ
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
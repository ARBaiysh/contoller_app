// lib/app/data/models/subscriber_model.dart

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'subscriber_model.g.dart';

@JsonSerializable()
class SubscriberModel {
  @JsonKey(defaultValue: '')
  final String accountNumber;
  @JsonKey(defaultValue: '')
  final String fullName;
  @JsonKey(defaultValue: '')
  final String address;
  @JsonKey(fromJson: _phoneFromJson)
  final String? phone;
  @JsonKey(defaultValue: 0.0)
  final double balance;
  @JsonKey(defaultValue: '')
  final String meterSerialNumber;
  final String? meterType;
  final String? askueUuid; // UUID АСКУЭ-системы (если ПУ привязан к АСКУЭ)
  // Бэкенд присылает последнее показание в поле 'lastReading'
  @JsonKey(name: 'lastReading', defaultValue: 0)
  final int currentReading;
  @JsonKey(defaultValue: 0)
  final int previousReading;
  @JsonKey(fromJson: dateTimeOrNull)
  final DateTime? lastReadingDate;
  @JsonKey(defaultValue: 0.0)
  final double currentMonthConsumption;
  @JsonKey(defaultValue: 0.0)
  final double currentMonthCharge;
  @JsonKey(fromJson: dateTimeOrNull)
  final DateTime? lastPaymentDate;
  @JsonKey(defaultValue: 0.0)
  final double lastPaymentAmount;
  @JsonKey(defaultValue: 0.0)
  final double tariff;
  final String? tariffName;
  @JsonKey(defaultValue: '')
  final String transformerPointCode;
  @JsonKey(defaultValue: '')
  final String transformerPointName;
  final String? contractDate;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final double? accuracy;

  SubscriberModel({
    required this.accountNumber,
    required this.fullName,
    required this.address,
    this.phone,
    this.balance = 0.0,
    required this.meterSerialNumber,
    this.meterType,
    this.askueUuid,
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
    this.latitude,
    this.longitude,
    this.accuracy,
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

  /// Проверка наличия координат
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Привязан ли ПУ к системе АСКУЭ.
  /// Отсекаем пустую строку/пробелы и nil-UUID (все нули) — заглушки из 1С.
  bool get hasAskue {
    final u = askueUuid?.trim();
    if (u == null || u.isEmpty) return false;
    // только дефисы и нули → nil-UUID (00000000-0000-0000-0000-000000000000)
    if (u.replaceAll('-', '').replaceAll('0', '').isEmpty) return false;
    return true;
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

  factory SubscriberModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriberModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriberModelToJson(this);

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
    String? askueUuid,
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
    double? latitude,
    double? longitude,
    double? accuracy,
  }) {
    return SubscriberModel(
      accountNumber: accountNumber ?? this.accountNumber,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      meterSerialNumber: meterSerialNumber ?? this.meterSerialNumber,
      meterType: meterType ?? this.meterType,
      askueUuid: askueUuid ?? this.askueUuid,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
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
// JSON HELPERS
// ========================================

/// Очистка телефона: отбрасывает плейсхолдеры и слишком короткие номера.
String? _phoneFromJson(dynamic phoneValue) {
  if (phoneValue == null) return null;

  final phoneStr = phoneValue.toString().trim();
  if (phoneStr.isEmpty) return null;

  const invalidPlaceholders = [
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

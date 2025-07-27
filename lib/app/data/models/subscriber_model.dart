class SubscriberModel {
  final String id;
  final String accountNumber;
  final String fullName;
  final String address;
  final String tpId;
  final String tpNumber;
  final MeterInfo meterInfo;
  final double balance;
  final double lastPaymentAmount;
  final DateTime? lastPaymentDate;
  final ReadingStatus readingStatus;
  final int? lastReading;
  final int? currentReading;
  final DateTime? lastReadingDate;
  final double? consumption;
  final double? amountDue;

  SubscriberModel({
    required this.id,
    required this.accountNumber,
    required this.fullName,
    required this.address,
    required this.tpId,
    required this.tpNumber,
    required this.meterInfo,
    this.balance = 0.0,
    this.lastPaymentAmount = 0.0,
    this.lastPaymentDate,
    this.readingStatus = ReadingStatus.available,
    this.lastReading,
    this.currentReading,
    this.lastReadingDate,
    this.consumption,
    this.amountDue,
  });

  // Check if subscriber is debtor
  bool get isDebtor => balance < 0;

  // Get debt amount (positive value)
  double get debtAmount => balance < 0 ? balance.abs() : 0;

  // Check if reading can be taken
  bool get canTakeReading => readingStatus == ReadingStatus.available;

  // From JSON
  factory SubscriberModel.fromJson(Map<String, dynamic> json) {
    return SubscriberModel(
      id: json['id']?.toString() ?? '',
      accountNumber: json['account_number'] ?? '',
      fullName: json['full_name'] ?? '',
      address: json['address'] ?? '',
      tpId: json['tp_id']?.toString() ?? '',
      tpNumber: json['tp_number'] ?? '',
      meterInfo: MeterInfo.fromJson(json['meter_info'] ?? {}),
      balance: (json['balance'] ?? 0).toDouble(),
      lastPaymentAmount: (json['last_payment_amount'] ?? 0).toDouble(),
      lastPaymentDate: json['last_payment_date'] != null
          ? DateTime.tryParse(json['last_payment_date'])
          : null,
      readingStatus: ReadingStatus.fromString(json['reading_status'] ?? 'available'),
      lastReading: json['last_reading'],
      currentReading: json['current_reading'],
      lastReadingDate: json['last_reading_date'] != null
          ? DateTime.tryParse(json['last_reading_date'])
          : null,
      consumption: json['consumption']?.toDouble(),
      amountDue: json['amount_due']?.toDouble(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_number': accountNumber,
      'full_name': fullName,
      'address': address,
      'tp_id': tpId,
      'tp_number': tpNumber,
      'meter_info': meterInfo.toJson(),
      'balance': balance,
      'last_payment_amount': lastPaymentAmount,
      'last_payment_date': lastPaymentDate?.toIso8601String(),
      'reading_status': readingStatus.value,
      'last_reading': lastReading,
      'current_reading': currentReading,
      'last_reading_date': lastReadingDate?.toIso8601String(),
      'consumption': consumption,
      'amount_due': amountDue,
    };
  }

  // Copy with
  SubscriberModel copyWith({
    String? id,
    String? accountNumber,
    String? fullName,
    String? address,
    String? tpId,
    String? tpNumber,
    MeterInfo? meterInfo,
    double? balance,
    double? lastPaymentAmount,
    DateTime? lastPaymentDate,
    ReadingStatus? readingStatus,
    int? lastReading,
    int? currentReading,
    DateTime? lastReadingDate,
    double? consumption,
    double? amountDue,
  }) {
    return SubscriberModel(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      tpId: tpId ?? this.tpId,
      tpNumber: tpNumber ?? this.tpNumber,
      meterInfo: meterInfo ?? this.meterInfo,
      balance: balance ?? this.balance,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      readingStatus: readingStatus ?? this.readingStatus,
      lastReading: lastReading ?? this.lastReading,
      currentReading: currentReading ?? this.currentReading,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      consumption: consumption ?? this.consumption,
      amountDue: amountDue ?? this.amountDue,
    );
  }
}

// Meter Information
class MeterInfo {
  final String type;
  final String serialNumber;
  final String sealNumber;
  final int tariffCode;

  MeterInfo({
    required this.type,
    required this.serialNumber,
    this.sealNumber = '',
    this.tariffCode = 1,
  });

  factory MeterInfo.fromJson(Map<String, dynamic> json) {
    return MeterInfo(
      type: json['type'] ?? 'СОЭ',
      serialNumber: json['serial_number'] ?? '',
      sealNumber: json['seal_number'] ?? '',
      tariffCode: json['tariff_code'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'serial_number': serialNumber,
      'seal_number': sealNumber,
      'tariff_code': tariffCode,
    };
  }
}

// Reading Status Enum
enum ReadingStatus {
  available('available', 'Можно брать'),
  processing('processing', 'Обрабатывается'),
  completed('completed', 'Обработан');

  final String value;
  final String displayName;

  const ReadingStatus(this.value, this.displayName);

  static ReadingStatus fromString(String value) {
    return ReadingStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => ReadingStatus.available,
    );
  }
}
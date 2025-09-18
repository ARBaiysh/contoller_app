
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
  final String? meterType;
  final String? meterSerialNumber;
  final String? sealNumber;
  final String? tariffName;
  final double? lastPaymentAmount;
  final DateTime? lastPaymentDate;
  final String? transformerPointCode;
  final String? transformerPointName;
  final String? syncStatus;
  final DateTime? lastSync;
  final bool syncAvailable;

  // Дополнительные поля для UI
  int? currentReading;
  double? consumption;
  double? amountDue;

  // Вычисляемые поля
  bool get isDebtor => balance < 0;
  double get debtAmount => balance < 0 ? balance.abs() : 0;

  // Для совместимости со старым кодом
  String? get tpId => transformerPointCode;
  String? get tpNumber {
    if (transformerPointCode != null && transformerPointCode!.startsWith('TP')) {
      return '№${transformerPointCode!.substring(2)}';
    }
    return null;
  }

  // MeterInfo для совместимости
  MeterInfo get meterInfo => MeterInfo(
    type: meterType ?? 'нет ПУ',
    serialNumber: meterSerialNumber ?? '',
    sealNumber: sealNumber ?? '',
    tariffCode: 1,
  );

  // Reading status based on sync status and canTakeReading
  ReadingStatus get readingStatus {
    if (!canTakeReading) return ReadingStatus.completed;
    if (syncStatus == 'SYNCING') return ReadingStatus.processing;
    return ReadingStatus.available;
  }

  SubscriberModel({
    required this.id,
    required this.accountNumber,
    required this.fullName,
    required this.address,
    this.phone,
    required this.balance,
    this.lastReading,
    this.lastReadingDate,
    required this.canTakeReading,
    this.meterType,
    this.meterSerialNumber,
    this.sealNumber,
    this.tariffName,
    this.lastPaymentAmount,
    this.lastPaymentDate,
    this.transformerPointCode,
    this.transformerPointName,
    this.syncStatus,
    this.lastSync,
    required this.syncAvailable,
    this.currentReading,
    this.consumption,
    this.amountDue,
  });

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
      canTakeReading: json['canTakeReading'] ?? false,
      meterType: json['meterType'],
      meterSerialNumber: json['meterSerialNumber'],
      sealNumber: json['sealNumber'],
      tariffName: json['tariffName'],
      lastPaymentAmount: json['lastPaymentAmount'] != null
          ? (json['lastPaymentAmount']).toDouble()
          : null,
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.tryParse(json['lastPaymentDate'])
          : null,
      transformerPointCode: json['transformerPointCode'],
      transformerPointName: json['transformerPointName'],
      syncStatus: json['syncStatus'],
      lastSync: json['lastSync'] != null
          ? DateTime.tryParse(json['lastSync'])
          : null,
      syncAvailable: json['syncAvailable'] ?? true,
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
      'syncStatus': syncStatus,
      'lastSync': lastSync?.toIso8601String(),
      'syncAvailable': syncAvailable,
      'currentReading': currentReading,
      'consumption': consumption,
      'amountDue': amountDue,
    };
  }

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
    String? syncStatus,
    DateTime? lastSync,
    bool? syncAvailable,
    int? currentReading,
    double? consumption,
    double? amountDue,
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
      syncStatus: syncStatus ?? this.syncStatus,
      lastSync: lastSync ?? this.lastSync,
      syncAvailable: syncAvailable ?? this.syncAvailable,
      currentReading: currentReading ?? this.currentReading,
      consumption: consumption ?? this.consumption,
      amountDue: amountDue ?? this.amountDue,
    );
  }
}

// MeterInfo class для совместимости
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
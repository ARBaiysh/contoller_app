/// Показание из АСКУЭ (minimdm): дата + значение.
class AskueReading {
  final DateTime date;
  final double reading;

  AskueReading({required this.date, required this.reading});

  factory AskueReading.fromJson(Map<String, dynamic> json) {
    return AskueReading(
      date: DateTime.parse(json['date'] as String),
      reading: (json['reading'] as num).toDouble(),
    );
  }
}

/// Статус АСКУЭ для абонента (управляет полем ввода показания).
class AskueStatus {
  /// У абонента привязан АСКУЭ-ПУ
  final bool hasAskue;

  /// Есть свежее показание (≤ freshnessDays) — ручной ввод не нужен
  final bool fresh;

  /// Последнее показание из АСКУЭ (null, если не свежее)
  final AskueReading? latest;

  /// Порог свежести в днях (с сервера)
  final int freshnessDays;

  AskueStatus({
    required this.hasAskue,
    required this.fresh,
    this.latest,
    this.freshnessDays = 5,
  });

  factory AskueStatus.fromJson(Map<String, dynamic> json) {
    return AskueStatus(
      hasAskue: json['hasAskue'] ?? false,
      fresh: json['fresh'] ?? false,
      latest: json['latest'] != null
          ? AskueReading.fromJson(Map<String, dynamic>.from(json['latest']))
          : null,
      freshnessDays: json['freshnessDays'] ?? 5,
    );
  }

  /// Состояние «АСКУЭ нет» — ручной ввод как обычно.
  factory AskueStatus.none() => AskueStatus(hasAskue: false, fresh: false);
}

// lib/app/data/models/notification_item.dart
enum NotificationType { taskVisitTp, readingRegistered }
enum NotificationSeverity { info, success, warning }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String? message;
  final String? tpCode;
  final String? tpNumber;
  final String? subscriberNumber;
  final DateTime? deadline;
  final DateTime createdAt;
  final NotificationSeverity severity;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    this.tpCode,
    this.tpNumber,
    this.subscriberNumber,
    this.deadline,
    required this.createdAt,
    this.severity = NotificationSeverity.info,
    this.isRead = false,
  });

  NotificationItem copyWith({
    bool? isRead,
  }) => NotificationItem(
    id: id,
    type: type,
    title: title,
    message: message,
    tpCode: tpCode,
    tpNumber: tpNumber,
    subscriberNumber: subscriberNumber,
    deadline: deadline,
    createdAt: createdAt,
    severity: severity,
    isRead: isRead ?? this.isRead,
  );

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(String s) {
      switch (s) {
        case 'task_visit_tp': return NotificationType.taskVisitTp;
        case 'reading_registered': return NotificationType.readingRegistered;
        default: return NotificationType.taskVisitTp;
      }
    }

    NotificationSeverity parseSeverity(String s) {
      switch (s) {
        case 'success': return NotificationSeverity.success;
        case 'warning': return NotificationSeverity.warning;
        default: return NotificationSeverity.info;
      }
    }

    return NotificationItem(
      id: json['id'] as String,
      type: parseType(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String?,
      tpCode: json['tpCode'] as String?,
      tpNumber: json['tpNumber'] as String?,
      subscriberNumber: json['subscriberNumber'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      severity: parseSeverity((json['severity'] as String?) ?? 'info'),
      isRead: (json['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': switch (type) {
      NotificationType.taskVisitTp => 'task_visit_tp',
      NotificationType.readingRegistered => 'reading_registered',
    },
    'title': title,
    'message': message,
    'tpCode': tpCode,
    'tpNumber': tpNumber,
    'subscriberNumber': subscriberNumber,
    'deadline': deadline?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'severity': switch (severity) {
      NotificationSeverity.success => 'success',
      NotificationSeverity.warning => 'warning',
      NotificationSeverity.info => 'info',
    },
    'isRead': isRead,
  };
}

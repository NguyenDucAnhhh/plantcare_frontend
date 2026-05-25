import 'package:timeago/timeago.dart' as timeago;

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final int? targetId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.targetId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'SYSTEM',
      targetId: json['targetId'],
      isRead: json['read'] ?? false, // Check if the backend sends 'read' or 'isRead'. Spring typically serializes boolean `isRead` to `read`!
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  String get timeAgo {
    return timeago.format(createdAt, locale: 'vi');
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      targetId: targetId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

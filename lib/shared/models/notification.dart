import 'package:social_chat_app/shared/models/user.dart';

/// Notification type enum
enum NotificationType {
  friendRequest,
  friendAccepted,
  like,
  comment,
  message,
  mention,
  system,
}

/// Notification model matching backend NotificationResponse DTO
class AppNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final UserSummary? actor;
  final int? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.actor,
    this.referenceId,
    this.referenceType,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      type: _parseType(json['type']),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      actor: json['actor'] != null 
          ? UserSummary.fromJson(json['actor']) 
          : null,
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      isRead: json['read'] ?? json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static NotificationType _parseType(String? type) {
    if (type == null) return NotificationType.system;
    switch (type.toLowerCase()) {
      case 'friend_request':
        return NotificationType.friendRequest;
      case 'friend_accepted':
        return NotificationType.friendAccepted;
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'message':
        return NotificationType.message;
      case 'mention':
        return NotificationType.mention;
      default:
        return NotificationType.system;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name.toUpperCase(),
      'title': title,
      'message': message,
      'actor': actor?.toJson(),
      'referenceId': referenceId,
      'referenceType': referenceType,
      'read': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    int? id,
    NotificationType? type,
    String? title,
    String? message,
    UserSummary? actor,
    int? referenceId,
    String? referenceType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actor: actor ?? this.actor,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
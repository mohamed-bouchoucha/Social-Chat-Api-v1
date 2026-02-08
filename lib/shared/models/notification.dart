import 'package:social_chat_app/shared/models/user.dart';

enum NotificationType {
  like,
  comment,
  friendRequest,
  message,
  postMention,
  commentMention,
}

class AppNotification {
  final String id;
  final User sender;
  final String? receiverId;
  final NotificationType type;
  final String content;
  final String? relatedPostId;
  final String? relatedCommentId;
  final String? relatedChatId;
  final bool isRead;
  final DateTime createdAt;
  
  AppNotification({
    required this.id,
    required this.sender,
    this.receiverId,
    required this.type,
    required this.content,
    this.relatedPostId,
    this.relatedCommentId,
    this.relatedChatId,
    required this.isRead,
    required this.createdAt,
  });
  
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      receiverId: json['receiverId'],
      type: _parseNotificationType(json['type']),
      content: json['content'] ?? '',
      relatedPostId: json['relatedPostId'],
      relatedCommentId: json['relatedCommentId'],
      relatedChatId: json['relatedChatId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
  
  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'friendrequest':
        return NotificationType.friendRequest;
      case 'message':
        return NotificationType.message;
      case 'postmention':
        return NotificationType.postMention;
      case 'commentmention':
        return NotificationType.commentMention;
      default:
        return NotificationType.like;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'receiverId': receiverId,
      'type': type.name,
      'content': content,
      'relatedPostId': relatedPostId,
      'relatedCommentId': relatedCommentId,
      'relatedChatId': relatedChatId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  AppNotification copyWith({
    String? id,
    User? sender,
    String? receiverId,
    NotificationType? type,
    String? content,
    String? relatedPostId,
    String? relatedCommentId,
    String? relatedChatId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      content: content ?? this.content,
      relatedPostId: relatedPostId ?? this.relatedPostId,
      relatedCommentId: relatedCommentId ?? this.relatedCommentId,
      relatedChatId: relatedChatId ?? this.relatedChatId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  String get notificationTitle {
    switch (type) {
      case NotificationType.like:
        return '${sender.username} liked your post';
      case NotificationType.comment:
        return '${sender.username} commented on your post';
      case NotificationType.friendRequest:
        return '${sender.username} sent you a friend request';
      case NotificationType.message:
        return 'New message from ${sender.username}';
      case NotificationType.postMention:
        return '${sender.username} mentioned you in a post';
      case NotificationType.commentMention:
        return '${sender.username} mentioned you in a comment';
    }
  }
}
  
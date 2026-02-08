import 'package:social_chat_app/shared/models/user.dart';

/// Message type enum
enum MessageType {
  text,
  image,
  video,
  file,
  system,
}

/// Message status enum
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Message model matching backend MessageResponse DTO
class Message {
  final int id;
  final int conversationId;
  final UserSummary sender;
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    this.type = MessageType.text,
    this.mediaUrl,
    this.status = MessageStatus.sent,
    required this.createdAt,
    this.readAt,
  });

  /// Check if this message is from a specific user
  bool isFromUser(int userId) => sender.id == userId;

  /// Check if this message has been read
  bool get isRead => status == MessageStatus.read || readAt != null;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      conversationId: json['conversationId'] ?? 0,
      sender: UserSummary.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      type: _parseMessageType(json['type']),
      mediaUrl: json['mediaUrl'],
      status: _parseMessageStatus(json['status']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'])
          : null,
    );
  }

  static MessageType _parseMessageType(String? type) {
    if (type == null) return MessageType.text;
    switch (type.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    if (status == null) return MessageStatus.sent;
    switch (status.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'sender': sender.toJson(),
      'content': content,
      'type': type.name.toUpperCase(),
      'mediaUrl': mediaUrl,
      'status': status.name.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  Message copyWith({
    int? id,
    int? conversationId,
    UserSummary? sender,
    String? content,
    MessageType? type,
    String? mediaUrl,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Format time for display in chat
  String get timeString {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
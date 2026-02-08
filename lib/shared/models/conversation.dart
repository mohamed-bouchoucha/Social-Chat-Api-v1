import 'package:social_chat_app/shared/models/user.dart';
import 'package:social_chat_app/shared/models/message.dart';

/// Conversation type enum
enum ConversationType {
  direct,
  group,
}

/// Conversation model matching backend ConversationResponse DTO
class Conversation {
  final int id;
  final String? name;
  final String? imageUrl;
  final ConversationType type;
  final List<UserSummary> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    this.name,
    this.imageUrl,
    required this.type,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get display name for the conversation
  /// For direct chats, returns the other participant's name
  /// For groups, returns the group name
  String getDisplayName(int currentUserId) {
    if (type == ConversationType.group && name != null) {
      return name!;
    }
    // For direct chats, find the other participant
    final otherUser = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.first,
    );
    return otherUser.name;
  }

  /// Get avatar URL for the conversation
  /// For direct chats, returns the other participant's avatar
  /// For groups, returns the group image
  String? getAvatarUrl(int currentUserId) {
    if (type == ConversationType.group) {
      return imageUrl;
    }
    final otherUser = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.first,
    );
    return otherUser.avatarUrl;
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? 0,
      name: json['name'],
      imageUrl: json['imageUrl'],
      type: json['type'] == 'GROUP' 
          ? ConversationType.group 
          : ConversationType.direct,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((e) => UserSummary.fromJson(e))
              .toList()
          : [],
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'type': type == ConversationType.group ? 'GROUP' : 'DIRECT',
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Conversation copyWith({
    int? id,
    String? name,
    String? imageUrl,
    ConversationType? type,
    List<UserSummary>? participants,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isGroup => type == ConversationType.group;
  bool get hasUnread => unreadCount > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

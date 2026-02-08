import 'package:social_chat_app/shared/models/message_type.dart';
import 'package:social_chat_app/shared/models/user.dart';

class Message {
  final String id;
  final String chatId;
  final User sender;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  
  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.type = MessageType.text,
  });
  
  // Factory constructor for JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      type: _parseMessageType(json['type']),
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
      default:
        return MessageType.text;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'sender': sender.toJson(),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last, // Convert enum to string
    };
  }
  
  Message copyWith({
    String? id,
    String? chatId,
    User? sender,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
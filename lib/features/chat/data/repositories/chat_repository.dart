
import 'package:dio/dio.dart';
import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/shared/models/message.dart';
import 'package:social_chat_app/shared/models/user.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<Chat>> getChats({int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.get('/chats', queryParameters: {
        'page': page,
        'size': size,
      });

      final data = response.data as Map<String, dynamic>;
      final chatsData = data['content'] as List<dynamic>;
      
      return chatsData.map((chat) => Chat.fromJson(chat)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to load chats');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Chat> getChatById(String chatId) async {
    try {
      final response = await _apiClient.get('/chats/$chatId');
      return Chat.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to load chat');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Chat> getOrCreateChat(String userId) async {
    try {
      final response = await _apiClient.post('/chats/create', data: {
        'userId': userId,
      });
      return Chat.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to create chat');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<Message>> getMessages(
    String chatId, {
    int page = 0,
    int size = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/chats/$chatId/messages',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final messagesData = data['content'] as List<dynamic>;
      
      return messagesData.map((msg) => Message.fromJson(msg)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to load messages');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Message> sendMessage(String chatId, String content) async {
    try {
      final response = await _apiClient.post(
        '/chats/$chatId/messages',
        data: {
          'content': content,
          'type': 'TEXT',
        },
      );
      return Message.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to send message');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      await _apiClient.put('/chats/$chatId/messages/read');
    } on DioException catch (e) {
      if (e.response != null) {
        print('Failed to mark messages as read: ${e.response!.data}');
      }
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _apiClient.delete('/messages/$messageId');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to delete message');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _apiClient.delete('/chats/$chatId');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to delete chat');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<User>> getChatParticipants(String chatId) async {
    try {
      final response = await _apiClient.get('/chats/$chatId/participants');
      final data = response.data as List<dynamic>;
      return data.map((user) => User.fromJson(user as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to load participants');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> addParticipant(String chatId, String userId) async {
    try {
      await _apiClient.post('/chats/$chatId/participants', data: {
        'userId': userId,
      });
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to add participant');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> removeParticipant(String chatId, String userId) async {
    try {
      await _apiClient.delete('/chats/$chatId/participants/$userId');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to remove participant');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}

// Chat model for the repository
class Chat {
  final String id;
  final String name;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final List<User> participants;
  final bool isGroup;
  final String? groupImage;

  Chat({
    required this.id,
    required this.name,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.participants,
    this.isGroup = false,
    this.groupImage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      participants: (json['participants'] as List<dynamic>)
          .map((p) => User.fromJson(p as Map<String, dynamic>))
          .toList(),
      isGroup: json['isGroup'] ?? false,
      groupImage: json['groupImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'participants': participants.map((p) => p.toJson()).toList(),
      'isGroup': isGroup,
      'groupImage': groupImage,
    };
  }
}
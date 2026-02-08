import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/network/api_response.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/constants/api_endpoints.dart';
import 'package:social_chat_app/shared/models/conversation.dart';
import 'package:social_chat_app/shared/models/message.dart';

/// Repository for chat operations
/// 
/// Connects to backend chat endpoints:
/// - GET /api/chat/conversations
/// - POST /api/chat/conversations
/// - GET /api/chat/conversations/{id}
/// - GET /api/chat/conversations/{id}/messages
/// - POST /api/chat/conversations/{id}/messages
/// - POST /api/chat/conversations/{id}/read
/// - DELETE /api/chat/conversations/{id}
class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all conversations with pagination
  Future<PageResponse<Conversation>> getConversations({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      AppConstants.chatConversations,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<Conversation>.fromJson(
        data as Map<String, dynamic>,
        (json) => Conversation.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get conversations');
    }

    return apiResponse.data!;
  }

  /// Get single conversation by ID
  Future<Conversation> getConversation(int id) async {
    final response = await _apiClient.get(ApiEndpoints.conversation(id));

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => Conversation.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Conversation not found');
    }

    return apiResponse.data!;
  }

  /// Create or get existing conversation
  /// For direct chats, pass a single participantId
  /// For group chats, pass multiple participantIds and a name
  Future<Conversation> createOrGetConversation({
    required List<int> participantIds,
    String? name,
  }) async {
    final response = await _apiClient.post(
      AppConstants.chatConversations,
      data: {
        'participantIds': participantIds,
        if (name != null) 'name': name,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => Conversation.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to create conversation');
    }

    return apiResponse.data!;
  }

  /// Get messages for a conversation with pagination
  Future<PageResponse<Message>> getMessages(int conversationId, {int page = 0, int size = 50}) async {
    final response = await _apiClient.get(
      ApiEndpoints.conversationMessages(conversationId),
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<Message>.fromJson(
        data as Map<String, dynamic>,
        (json) => Message.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get messages');
    }

    return apiResponse.data!;
  }

  /// Send a message (via REST API, not WebSocket)
  /// This is used as a fallback when WebSocket is not available
  Future<Message> sendMessage({
    required int conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.conversationMessages(conversationId),
      data: {
        'content': content,
        'type': type.name.toUpperCase(),
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => Message.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to send message');
    }

    return apiResponse.data!;
  }

  /// Mark conversation as read
  Future<void> markAsRead(int conversationId) async {
    final response = await _apiClient.post(
      ApiEndpoints.markConversationRead(conversationId),
    );

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to mark as read');
    }
  }

  /// Leave/delete a conversation
  Future<void> leaveConversation(int conversationId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.conversation(conversationId),
    );

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to leave conversation');
    }
  }
}

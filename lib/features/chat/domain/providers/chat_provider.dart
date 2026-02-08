import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/core/network/web_socket_service.dart';
import 'package:social_chat_app/features/chat/data/repositories/chat_repository.dart';
import 'package:social_chat_app/shared/models/message.dart';

import 'package:social_chat_app/features/chat/domain/providers/chat_repository_provider.dart';
import 'package:social_chat_app/core/network/web_socket_service_provider.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(chatRepositoryProvider),
    ref.watch(webSocketServiceProvider),
  );
});

final activeChatProvider = StateProvider<String?>((ref) => null);
final typingStatusProvider = StateProvider<Map<String, bool>>((ref) => {});

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final WebSocketService _webSocketService;
  
  ChatNotifier(this._chatRepository, this._webSocketService)
      : super(ChatInitial()) {
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    _webSocketService.subscribe('NEW_MESSAGE', (data) {
      if (data is Map<String, dynamic>) {
        final message = Message.fromJson(data);
        addMessageToChat(message);
      }
    });
  }

  Future<void> loadChats() async {
    try {
      state = ChatLoading();
      final chats = await _chatRepository.getChats();
      state = ChatLoaded(chats: chats, messages: {});
    } catch (e) {
      state = ChatError(e.toString());
    }
  }

  Future<void> loadMessages(String chatId) async {
    try {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        final messages = await _chatRepository.getMessages(chatId);
        
        state = currentState.copyWith(
          messages: {
            ...currentState.messages,
            chatId: messages,
          },
        );
      }
    } catch (e) {
      print('Failed to load messages: $e');
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    try {
      final message = await _chatRepository.sendMessage(chatId, content);
      addMessageToChat(message);
      _webSocketService.sendMessage(chatId, content);
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  void addMessageToChat(Message message) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final chatId = message.chatId;
      final currentMessages = currentState.messages[chatId] ?? [];
      
      if (!currentMessages.any((m) => m.id == message.id)) {
        state = currentState.copyWith(
          messages: {
            ...currentState.messages,
            chatId: [...currentMessages, message],
          },
        );
      }
    }
  }

  void updateTypingStatus(String chatId, bool isTyping) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      state = currentState.copyWith(
        typingStatus: {
          ...currentState.typingStatus,
          chatId: isTyping,
        },
      );
    }
  }
}

// Chat State classes
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Chat> chats;
  final Map<String, List<Message>> messages;
  final Map<String, bool> typingStatus;
  
  ChatLoaded({
    required this.chats,
    required this.messages,
    this.typingStatus = const {},
  });
  
  ChatLoaded copyWith({
    List<Chat>? chats,
    Map<String, List<Message>>? messages,
    Map<String, bool>? typingStatus,
  }) {
    return ChatLoaded(
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      typingStatus: typingStatus ?? this.typingStatus,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/shared/repositories/chat_repository.dart';
import 'package:social_chat_app/shared/models/conversation.dart';
import 'package:social_chat_app/shared/models/message.dart';
import 'package:social_chat_app/core/network/stomp_service.dart';
import 'package:social_chat_app/core/network/web_socket_service_provider.dart';

/// Conversations list state
class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
  
  int get totalUnreadCount => 
      conversations.fold(0, (sum, c) => sum + c.unreadCount);
}

/// Conversations notifier
class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ChatRepository _chatRepository;
  final StompWebSocketService _wsService;
  StreamSubscription? _messagesSubscription;

  ConversationsNotifier(this._chatRepository, this._wsService) 
      : super(const ConversationsState()) {
    _setupMessageListener();
  }

  void _setupMessageListener() {
    _messagesSubscription = _wsService.messages.listen((messageData) {
      _handleNewMessage(messageData);
    });
  }

  void _handleNewMessage(Map<String, dynamic> messageData) {
    final message = Message.fromJson(messageData);
    final conversationId = message.conversationId;
    
    // Update conversation with new message
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == conversationId) {
        return conv.copyWith(
          lastMessage: message,
          unreadCount: conv.unreadCount + 1,
        );
      }
      return conv;
    }).toList();
    
    // Sort by last message time
    updatedConversations.sort((a, b) {
      final aTime = a.lastMessage?.createdAt ?? a.createdAt;
      final bTime = b.lastMessage?.createdAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    
    state = state.copyWith(conversations: updatedConversations);
  }

  /// Load conversations
  Future<void> loadConversations() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final pageResponse = await _chatRepository.getConversations();
      state = state.copyWith(
        conversations: pageResponse.content,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create or get conversation with user
  Future<Conversation> createOrGetConversation(List<int> participantIds, {String? name}) async {
    final conversation = await _chatRepository.createOrGetConversation(
      participantIds: participantIds,
      name: name,
    );
    
    // Add to list if not exists
    if (!state.conversations.any((c) => c.id == conversation.id)) {
      state = state.copyWith(
        conversations: [conversation, ...state.conversations],
      );
    }
    
    return conversation;
  }

  /// Mark conversation as read
  void markAsRead(int conversationId) {
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == conversationId) {
        return conv.copyWith(unreadCount: 0);
      }
      return conv;
    }).toList();
    state = state.copyWith(conversations: updatedConversations);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}

/// Chat room state  
class ChatRoomState {
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Map<int, bool> typingUsers;
  final String? error;

  const ChatRoomState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.typingUsers = const {},
    this.error,
  });

  ChatRoomState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Map<int, bool>? typingUsers,
    String? error,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      typingUsers: typingUsers ?? this.typingUsers,
      error: error,
    );
  }
}

/// Chat room notifier for a specific conversation
class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  final int conversationId;
  final ChatRepository _chatRepository;
  final StompWebSocketService _wsService;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;

  ChatRoomNotifier({
    required this.conversationId,
    required ChatRepository chatRepository,
    required StompWebSocketService wsService,
  })  : _chatRepository = chatRepository,
        _wsService = wsService,
        super(const ChatRoomState()) {
    _setupListeners();
    _wsService.subscribeToConversation(conversationId);
  }

  void _setupListeners() {
    // Listen for new messages
    _messagesSubscription = _wsService.messages.listen((messageData) {
      final message = Message.fromJson(messageData);
      if (message.conversationId == conversationId) {
        _addMessage(message);
      }
    });
    
    // Listen for typing indicators
    _typingSubscription = _wsService.typingIndicators.listen((data) {
      if (data['conversationId'] == conversationId) {
        final userId = data['userId'] as int;
        final isTyping = data['typing'] as bool;
        state = state.copyWith(
          typingUsers: {...state.typingUsers, userId: isTyping},
        );
      }
    });
  }

  void _addMessage(Message message) {
    // Add to beginning (newest first)
    state = state.copyWith(
      messages: [message, ...state.messages],
    );
  }

  /// Load messages
  Future<void> loadMessages() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final pageResponse = await _chatRepository.getMessages(conversationId);
      state = state.copyWith(
        messages: pageResponse.content.reversed.toList(),
        isLoading: false,
        hasMore: pageResponse.hasMore,
      );
      
      // Mark as read
      await _chatRepository.markAsRead(conversationId);
      _wsService.sendReadReceipt(conversationId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Send a message via WebSocket
  void sendMessage(String content) {
    _wsService.sendMessage(conversationId, content);
  }

  /// Send typing indicator
  void sendTyping(bool isTyping) {
    _wsService.sendTypingIndicator(conversationId, isTyping);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _wsService.unsubscribeFromConversation(conversationId);
    super.dispose();
  }
}

/// Chat repository provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Conversations provider
final conversationsProvider = 
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final wsService = ref.watch(stompServiceProvider);
  return ConversationsNotifier(repo, wsService);
});

/// Chat room provider (family by conversation ID)
final chatRoomProvider = StateNotifierProvider.family<ChatRoomNotifier, ChatRoomState, int>(
  (ref, conversationId) {
    final repo = ref.watch(chatRepositoryProvider);
    final wsService = ref.watch(stompServiceProvider);
    return ChatRoomNotifier(
      conversationId: conversationId,
      chatRepository: repo,
      wsService: wsService,
    );
  },
);

/// Total unread messages count
final unreadMessagesCountProvider = Provider<int>((ref) {
  return ref.watch(conversationsProvider).totalUnreadCount;
});

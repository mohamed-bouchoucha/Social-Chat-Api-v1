import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/core/network/web_socket_service.dart';
import 'package:social_chat_app/core/network/web_socket_service_provider.dart';
import 'package:social_chat_app/features/chat/domain/providers/chat_provider.dart';
import 'package:social_chat_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:social_chat_app/shared/models/message.dart';
import 'package:social_chat_app/shared/models/user.dart';
import 'package:social_chat_app/shared/models/message_type.dart';
class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String friendName;
  
  const ChatScreen({super.key, required this.chatId, required this.friendName});
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late WebSocketService _webSocketService;
  late String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _webSocketService = ref.read(webSocketServiceProvider);
    _connectWebSocket();
    
    // Get current user ID (you'll need to get this from your auth provider)
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    // Get current user from auth provider or local storage
    // For now, we'll use a placeholder
    _currentUserId = 'current_user_id';
  }

  void _connectWebSocket() {
    _webSocketService.connect().then((_) {
      _webSocketService.subscribe('NEW_MESSAGE', (data) {
        // Handle incoming message
        if (data is Map<String, dynamic>) {
          final message = Message.fromJson(data);
          if (message.chatId == widget.chatId) {
            final chatNotifier = ref.read(chatProvider.notifier);
            chatNotifier.addMessageToChat(message); // Changed from _addMessageToChat to addMessageToChat
            _scrollToBottom();
          }
        }
      });

      _webSocketService.subscribe('TYPING', (data) {
        if (data is Map<String, dynamic>) {
          final chatId = data['chatId'] as String?;
          final isTyping = data['isTyping'] as bool?;
          if (chatId == widget.chatId && isTyping != null) {
            final chatNotifier = ref.read(chatProvider.notifier);
            chatNotifier.updateTypingStatus(chatId!, isTyping); // Changed from _updateTypingStatus to updateTypingStatus
          }
        }
      });
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _webSocketService.sendMessage(
        widget.chatId,
        _messageController.text,
      );
      
      // Also update local state immediately (optimistic update)
      final message = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        chatId: widget.chatId,
        sender: User(
          id: _currentUserId,
          username: 'You',
          email: '',
          createdAt: DateTime.now(),
          isOnline: true,
        ),
        content: _messageController.text,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.text,
      );
      
      final chatNotifier = ref.read(chatProvider.notifier);
      chatNotifier.addMessageToChat(message); // Changed from _addMessageToChat to addMessageToChat
      
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.friendName),
                Consumer(
                  builder: (context, ref, child) {
                    final chatState = ref.watch(chatProvider);
                    final isOnline = chatState is ChatLoaded && 
                        chatState.typingStatus[widget.chatId] == true;
                    return Text(
                      isOnline ? 'Typing...' : 'Online',
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final chatState = ref.watch(chatProvider);
                
                if (chatState is ChatLoaded) {
                  final messages = chatState.messages[widget.chatId] ?? [];
                  
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isOwnMessage = message.sender.id == _currentUserId;
                      
                      return MessageBubble(
                        message: message,
                        isOwnMessage: isOwnMessage,
                        showAvatar: index == 0 || 
                            messages[index - 1].sender.id != message.sender.id,
                      );
                    },
                  );
                } else if (chatState is ChatError) {
                  return Center(
                    child: Text('Error: ${chatState.message}'),
                  );
                } else if (chatState is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Open media picker
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      onPressed: () {
                        // Open emoji picker
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: () {
                        // Open camera
                      },
                    ),
                  ],
                ),
              ),
              onChanged: (text) {
                // Send typing indicator
                if (text.isNotEmpty) {
                  _webSocketService.typing(widget.chatId, true);
                }
              },
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
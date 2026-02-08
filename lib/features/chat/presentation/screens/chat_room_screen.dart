import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/shared/providers/chat_provider.dart';
import 'package:social_chat_app/shared/providers/auth_provider.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';
import 'package:social_chat_app/shared/models/message.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ChatRoomScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomProvider(widget.conversationId).notifier).loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatRoomProvider(widget.conversationId).notifier).sendMessage(content);
    _messageController.clear();
    _updateTypingStatus(false);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateTypingStatus(bool isTyping) {
    if (_isTyping != isTyping) {
      _isTyping = isTyping;
      ref.read(chatRoomProvider(widget.conversationId).notifier).sendTyping(isTyping);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatRoomProvider(widget.conversationId));
    final currentUser = ref.watch(currentUserProvider);
    final conversationsState = ref.watch(conversationsProvider);
    
    final conversation = conversationsState.conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => throw StateError('Conversation not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AvatarWidget(
              imageUrl: conversation.getAvatarUrl(currentUser?.id ?? 0),
              name: conversation.getDisplayName(currentUser?.id ?? 0),
              size: 36,
              showOnlineIndicator: !conversation.isGroup,
              isOnline: true, // Would be from presence
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.getDisplayName(currentUser?.id ?? 0),
                  style: const TextStyle(fontSize: 16),
                ),
                if (_hasTypingUsers(chatState))
                  const Text(
                    'typing...',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.error != null
                    ? ErrorView(
                        message: chatState.error!,
                        onRetry: () => ref
                            .read(chatRoomProvider(widget.conversationId).notifier)
                            .loadMessages(),
                      )
                    : chatState.messages.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.chat_bubble_outline,
                            title: 'No messages yet',
                            subtitle: 'Start the conversation!',
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: chatState.messages.length,
                            itemBuilder: (context, index) {
                              final message = chatState.messages[index];
                              final isMe = message.sender.id == currentUser?.id;
                              final showAvatar = !isMe && (
                                index == chatState.messages.length - 1 ||
                                chatState.messages[index + 1].sender.id != message.sender.id
                              );

                              return _MessageBubble(
                                message: message,
                                isMe: isMe,
                                showAvatar: showAvatar,
                              );
                            },
                          ),
          ),

          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  bool _hasTypingUsers(ChatRoomState state) {
    return state.typingUsers.values.any((v) => v);
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  _updateTypingStatus(value.isNotEmpty);
                },
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar)
            AvatarWidget(
              imageUrl: message.sender.avatarUrl,
              name: message.sender.name,
              size: 32,
            )
          else if (!isMe)
            const SizedBox(width: 32),
          
          if (!isMe) const SizedBox(width: 8),
          
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.timeString,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? Colors.white70
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isRead ? Colors.blue.shade300 : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:social_chat_app/shared/models/conversation.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';

/// Conversation tile for chat list
class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final int currentUserId;
  final VoidCallback? onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = conversation.getDisplayName(currentUserId);
    final avatarUrl = conversation.getAvatarUrl(currentUserId);
    final lastMessage = conversation.lastMessage;

    return ListTile(
      onTap: onTap,
      leading: AvatarWidget(
        imageUrl: avatarUrl,
        name: displayName,
        size: 52,
        showOnlineIndicator: !conversation.isGroup,
        isOnline: conversation.participants
            .where((p) => p.id != currentUserId)
            .any((p) => p.isOnline),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontWeight: conversation.hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessage != null)
            Text(
              lastMessage.timeString,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: conversation.hasUnread
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              lastMessage != null
                  ? '${lastMessage.sender.id == currentUserId ? "You: " : ""}${lastMessage.content}'
                  : 'Start a conversation',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: conversation.hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

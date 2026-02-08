import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_chat_app/features/chat/data/repositories/chat_repository.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final bool isSelected;

  const ChatListItem({
    required this.chat,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: theme.primaryColor.withOpacity(0.1),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: chat.isGroup && chat.groupImage != null
            ? NetworkImage(chat.groupImage!)
            : chat.participants.isNotEmpty
                ? chat.participants[0].avatarUrl != null
                    ? NetworkImage(chat.participants[0].avatarUrl!)
                    : null
                : null,
        child: chat.isGroup && chat.groupImage == null
            ? Icon(Icons.group, size: 30)
            : chat.participants.isNotEmpty && chat.participants[0].avatarUrl == null
                ? Text(chat.participants[0].username[0].toUpperCase())
                : null,
      ),
      title: Text(
        chat.name,
        style: TextStyle(
          fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chat.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat.unreadCount > 0 
              ? theme.primaryColor 
              : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chat.lastMessageAt != null)
            Text(
              _formatTime(chat.lastMessageAt!),
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          if (chat.unreadCount > 0)
            Container(
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }
}
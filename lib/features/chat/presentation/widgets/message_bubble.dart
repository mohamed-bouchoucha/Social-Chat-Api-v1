import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_chat_app/shared/models/message.dart';
import 'package:social_chat_app/shared/models/user.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final bool showAvatar;
  final User? currentUser;

  const MessageBubble({
    required this.message,
    this.isOwnMessage = false,
    this.showAvatar = true,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isOwnMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isOwnMessage && showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: message.sender.avatarUrl != null
                    ? NetworkImage(message.sender.avatarUrl!)
                    : null,
                child: message.sender.avatarUrl == null
                    ? Text(message.sender.username[0].toUpperCase())
                    : null,
              ),
            ),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isOwnMessage 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                if (!isOwnMessage && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.sender.username,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isOwnMessage
                        ? theme.primaryColor
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isOwnMessage ? Colors.white : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      if (isOwnMessage)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            message.isRead 
                                ? Icons.done_all 
                                : Icons.done,
                            size: 12,
                            color: message.isRead 
                                ? theme.primaryColor 
                                : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (isOwnMessage && showAvatar)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: currentUser?.avatarUrl != null
                    ? NetworkImage(currentUser!.avatarUrl!)
                    : null,
                child: currentUser?.avatarUrl == null
                    ? Text(currentUser?.username[0].toUpperCase() ?? 'Y')
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:social_chat_app/shared/models/friend_request.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';

/// Friend tile for friends list
class FriendTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;

  const FriendTile({
    super.key,
    required this.friend,
    this.onTap,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: AvatarWidget(
        imageUrl: friend.user.avatarUrl,
        name: friend.user.name,
        size: 48,
        showOnlineIndicator: true,
        isOnline: friend.user.isOnline,
      ),
      title: Text(
        friend.user.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        friend.user.isOnline ? 'Online' : '@${friend.user.username}',
        style: TextStyle(
          color: friend.user.isOnline
              ? Colors.green
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.message_outlined),
        onPressed: onMessage,
      ),
    );
  }
}

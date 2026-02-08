import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_chat_app/shared/providers/notifications_provider.dart';
import 'package:social_chat_app/shared/models/notification.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationsState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notificationsState.isLoading && notificationsState.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notificationsState.error != null && notificationsState.notifications.isEmpty
              ? ErrorView(
                  message: notificationsState.error!,
                  onRetry: () => ref.read(notificationsProvider.notifier).loadNotifications(),
                )
              : notificationsState.notifications.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.notifications_none,
                      title: 'No notifications',
                      subtitle: "You're all caught up!",
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
                      child: ListView.builder(
                        itemCount: notificationsState.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notificationsState.notifications[index];
                          return _NotificationTile(
                            notification: notification,
                            onTap: () {
                              // Mark as read
                              if (!notification.isRead) {
                                ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                              }
                              // Navigate based on type
                              _handleNotificationTap(context, notification);
                            },
                            onDismiss: () {
                              ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    switch (notification.type) {
      case NotificationType.friendRequest:
        context.push('/friend-requests');
        break;
      case NotificationType.friendAccepted:
        if (notification.actor != null) {
          context.push('/profile/${notification.actor!.id}');
        }
        break;
      case NotificationType.like:
      case NotificationType.comment:
        if (notification.referenceId != null) {
          context.push('/post/${notification.referenceId}');
        }
        break;
      case NotificationType.message:
        if (notification.referenceId != null) {
          context.push('/chat/${notification.referenceId}');
        }
        break;
      default:
        break;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: AvatarWidget(
          imageUrl: notification.actor?.avatarUrl,
          name: notification.actor?.name ?? '?',
          size: 48,
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification.timeAgo,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}

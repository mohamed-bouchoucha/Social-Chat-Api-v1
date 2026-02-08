import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/shared/repositories/notification_repository.dart';
import 'package:social_chat_app/shared/models/notification.dart';
import 'package:social_chat_app/core/network/stomp_service.dart';
import 'package:social_chat_app/core/network/web_socket_service_provider.dart';

/// Notifications state
class NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifications notifier
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationRepository _notificationRepository;
  final StompWebSocketService _wsService;
  StreamSubscription? _notificationsSubscription;

  NotificationsNotifier(this._notificationRepository, this._wsService)
      : super(const NotificationsState()) {
    _setupListener();
  }

  void _setupListener() {
    _notificationsSubscription = _wsService.notifications.listen((data) {
      final notification = AppNotification.fromJson(data);
      state = state.copyWith(
        notifications: [notification, ...state.notifications],
        unreadCount: state.unreadCount + 1,
      );
    });
  }

  /// Load notifications
  Future<void> loadNotifications() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final notificationsResponse = await _notificationRepository.getNotifications();
      final unreadCount = await _notificationRepository.getUnreadCount();
      
      state = state.copyWith(
        notifications: notificationsResponse.content,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh unread count
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _notificationRepository.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      // Silently fail
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    await _notificationRepository.markAsRead(notificationId);
    
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    
    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    );
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await _notificationRepository.markAllAsRead();
    
    final updatedNotifications = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();
    
    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    );
  }

  /// Delete notification
  Future<void> deleteNotification(int notificationId) async {
    final notification = state.notifications.firstWhere((n) => n.id == notificationId);
    await _notificationRepository.deleteNotification(notificationId);
    
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != notificationId).toList(),
      unreadCount: notification.isRead ? state.unreadCount : state.unreadCount - 1,
    );
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}

/// Notification repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Notifications provider
final notificationsProvider = 
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final wsService = ref.watch(stompServiceProvider);
  return NotificationsNotifier(repo, wsService);
});

/// Unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

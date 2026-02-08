import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/core/network/stomp_service.dart';

/// Provider for the STOMP WebSocket service
/// 
/// This is a singleton service that manages the WebSocket connection
/// for real-time features like chat, notifications, and presence.
final stompServiceProvider = Provider<StompWebSocketService>((ref) {
  final service = StompWebSocketService();
  
  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Stream provider for WebSocket connection events
final wsEventsProvider = StreamProvider<WsEvent>((ref) {
  final service = ref.watch(stompServiceProvider);
  return service.events;
});

/// Stream provider for incoming chat messages
final wsMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(stompServiceProvider);
  return service.messages;
});

/// Stream provider for typing indicators
final wsTypingProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(stompServiceProvider);
  return service.typingIndicators;
});

/// Stream provider for notifications
final wsNotificationsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(stompServiceProvider);
  return service.notifications;
});

/// Stream provider for presence updates
final wsPresenceProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(stompServiceProvider);
  return service.presenceUpdates;
});

/// Provider for WebSocket connection status
final wsConnectionStatusProvider = Provider<bool>((ref) {
  final service = ref.watch(stompServiceProvider);
  return service.isConnected;
});
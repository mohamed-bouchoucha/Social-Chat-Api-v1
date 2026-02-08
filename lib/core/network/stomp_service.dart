import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/constants/api_endpoints.dart';
import 'package:social_chat_app/core/storage/local_storage.dart';

/// WebSocket event types
enum WsEventType {
  message,
  typing,
  readReceipt,
  notification,
  presence,
  connected,
  disconnected,
  error,
}

/// WebSocket event wrapper
class WsEvent {
  final WsEventType type;
  final dynamic data;
  final DateTime timestamp;

  WsEvent({
    required this.type,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// STOMP WebSocket Service (SockJS compatible)
class StompWebSocketService {
  StompClient? _client;

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _shouldReconnect = true;

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  // Streams
  final _eventController = StreamController<WsEvent>.broadcast();
  final _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// conversationId → unsubscribe()
  final Map<int, void Function()> _conversationSubscriptions = {};

  // Public streams
  Stream<WsEvent> get events => _eventController.stream;
  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<Map<String, dynamic>> get typingIndicators =>
      _typingController.stream;
  Stream<Map<String, dynamic>> get notifications =>
      _notificationController.stream;
  Stream<Map<String, dynamic>> get presenceUpdates =>
      _presenceController.stream;

  bool get isConnected => _isConnected;

  // =========================================================
  // CONNECTION
  // =========================================================

  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    _isConnecting = true;
    _shouldReconnect = true;

    try {
      final token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        _isConnecting = false;
        return;
      }

      if (kDebugMode) {
        print('🔌 Connecting to WebSocket ${AppConstants.wsUrl}');
      }

      _client = StompClient(
        config: StompConfig(
          url: AppConstants.wsUrl,
          useSockJS: true, // ✅ REQUIRED for Spring Boot SockJS
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          reconnectDelay: AppConstants.wsReconnectDelay,
        ),
      );

      _client!.activate();
    } catch (e) {
      _isConnecting = false;
      _eventController.add(
        WsEvent(type: WsEventType.error, data: e.toString()),
      );
      _scheduleReconnect();
    }
  }

  void _onConnect(StompFrame frame) {
    if (kDebugMode) print('✅ WebSocket connected');

    _isConnected = true;
    _isConnecting = false;
    _reconnectAttempts = 0;

    _eventController.add(WsEvent(type: WsEventType.connected));
    _subscribeToUserQueues();
  }

  // =========================================================
  // SUBSCRIPTIONS
  // =========================================================

  void _subscribeToUserQueues() {
    if (_client == null) return;

    // Messages
    _client!.subscribe(
      destination: AppConstants.wsSubscribeMessages,
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          _messageController.add(data);
          _eventController.add(
            WsEvent(type: WsEventType.message, data: data),
          );
        }
      },
    );

    // Notifications
    _client!.subscribe(
      destination: AppConstants.wsSubscribeNotifications,
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          _notificationController.add(data);
          _eventController.add(
            WsEvent(type: WsEventType.notification, data: data),
          );
        }
      },
    );

    // Presence
    _client!.subscribe(
      destination: AppConstants.wsSubscribePresence,
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          _presenceController.add(data);
          _eventController.add(
            WsEvent(type: WsEventType.presence, data: data),
          );
        }
      },
    );

    // Typing
    _client!.subscribe(
      destination: AppConstants.wsSubscribeTyping,
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          _typingController.add(data);
          _eventController.add(
            WsEvent(type: WsEventType.typing, data: data),
          );
        }
      },
    );
  }

  /// Subscribe to a specific conversation
  void subscribeToConversation(int conversationId) {
    if (_client == null || !_isConnected) return;
    if (_conversationSubscriptions.containsKey(conversationId)) return;

    final unsubscribe = _client!.subscribe(
      destination: ApiEndpoints.wsTopicConversation(conversationId),
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          _messageController.add(data);
          _eventController.add(
            WsEvent(type: WsEventType.message, data: data),
          );
        }
      },
    );

    _conversationSubscriptions[conversationId] = unsubscribe;

    if (kDebugMode) {
      print('📡 Subscribed to conversation $conversationId');
    }
  }

  void unsubscribeFromConversation(int conversationId) {
    _conversationSubscriptions.remove(conversationId)?.call();
    if (kDebugMode) {
      print('📡 Unsubscribed from conversation $conversationId');
    }
  }

  // =========================================================
  // SEND EVENTS
  // =========================================================

  void sendMessage(int conversationId, String content) {
    if (_client == null || !_isConnected) return;

    _client!.send(
      destination: ApiEndpoints.wsChatMessage(conversationId),
      body: jsonEncode({'content': content}),
    );
  }

  void sendTypingIndicator(int conversationId, bool isTyping) {
    if (_client == null || !_isConnected) return;

    _client!.send(
      destination: ApiEndpoints.wsChatTyping(conversationId),
      body: jsonEncode({'typing': isTyping}),
    );
  }

  void sendReadReceipt(int conversationId) {
    if (_client == null || !_isConnected) return;

    _client!.send(
      destination: ApiEndpoints.wsChatRead(conversationId),
      body: jsonEncode({'conversationId': conversationId}),
    );
  }

  // =========================================================
  // ERRORS & RECONNECT
  // =========================================================

  void _onDisconnect(StompFrame frame) {
    if (kDebugMode) print('❌ WebSocket disconnected');

    _isConnected = false;
    _isConnecting = false;
    _conversationSubscriptions.clear();

    _eventController.add(WsEvent(type: WsEventType.disconnected));

    if (_shouldReconnect) _scheduleReconnect();
  }

  void _onStompError(StompFrame frame) {
    _eventController.add(
      WsEvent(type: WsEventType.error, data: frame.body),
    );
  }

  void _onWebSocketError(dynamic error) {
    _eventController.add(
      WsEvent(type: WsEventType.error, data: error.toString()),
    );
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect ||
        _reconnectAttempts >= _maxReconnectAttempts) return;

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);

    if (kDebugMode) {
      print('🔁 Reconnecting in ${delay.inSeconds}s...');
    }

    Future.delayed(delay, () {
      if (!_isConnected) connect();
    });
  }

  // =========================================================
  // CLEANUP
  // =========================================================

  void disconnect() {
    _shouldReconnect = false;
    _conversationSubscriptions.clear();
    _client?.deactivate();
    _client = null;
    _isConnected = false;
    _isConnecting = false;
  }

  void dispose() {
    disconnect();
    _eventController.close();
    _messageController.close();
    _typingController.close();
    _notificationController.close();
    _presenceController.close();
  }

  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    _shouldReconnect = true;
    _reconnectAttempts = 0;
    await connect();
  }
}

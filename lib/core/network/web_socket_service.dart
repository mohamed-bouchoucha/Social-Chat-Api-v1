import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/storage/local_storage.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final Map<String, Function(dynamic)> _handlers = {};

  Future<void> connect() async {
    try {
      final token = await LocalStorage.getToken();
      final url = '${AppConstants.webSocketUrl}?token=${token ?? ''}';
      
      _channel = IOWebSocketChannel.connect(url);
      
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );
      
      print('WebSocket connected to $url');
    } catch (e) {
      print('WebSocket connection error: $e');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message) as Map<String, dynamic>;
      final type = data['type'] as String;
      
      if (_handlers.containsKey(type)) {
        _handlers[type]!(data['data']);
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    // Attempt reconnect after delay
    Future.delayed(const Duration(seconds: 3), () => connect());
  }

  void _handleDisconnect() {
    print('WebSocket disconnected');
  }

  void subscribe(String event, Function(dynamic) handler) {
    _handlers[event] = handler;
  }

  void send(String type, dynamic data) {
    if (_channel != null) {
      try {
        _channel!.sink.add(json.encode({
          'type': type,
          'data': data,
        }));
      } catch (e) {
        print('Error sending WebSocket message: $e');
      }
    }
  }

  void sendMessage(String chatId, String content) {
    send('SEND_MESSAGE', {
      'chatId': chatId,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void typing(String chatId, bool isTyping) {
    send('TYPING', {
      'chatId': chatId,
      'isTyping': isTyping,
    });
  }

  void markAsRead(String messageId) {
    send('MARK_AS_READ', {
      'messageId': messageId,
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
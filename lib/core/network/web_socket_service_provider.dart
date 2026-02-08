import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/core/network/web_socket_service.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

final webSocketConnectionProvider = FutureProvider<void>((ref) async {
  final webSocketService = ref.watch(webSocketServiceProvider);
  await webSocketService.connect();
  
  // Clean up when provider is disposed
  ref.onDispose(() {
    webSocketService.disconnect();
  });
});
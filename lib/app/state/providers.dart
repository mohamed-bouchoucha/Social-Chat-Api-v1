import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/core/network/web_socket_service.dart';
import 'package:social_chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:social_chat_app/features/chat/data/repositories/chat_repository.dart';

import 'package:social_chat_app/features/auth/domain/providers/auth_provider.dart';
import 'package:social_chat_app/features/chat/domain/providers/chat_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRepository());
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ChatRepository(),WebSocketService());
});

/*final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier(PostsRepository());
});*/

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  
  AuthNotifier(this._repository) : super(AuthInitial());
  
  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _repository.login(email, password);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}
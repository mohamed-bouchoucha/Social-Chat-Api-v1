import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:social_chat_app/shared/models/user.dart';
import 'package:social_chat_app/features/auth/domain/providers/auth_repository_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

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
  
  Future<void> register(String username, String email, String password, String? s) async {
    state = AuthLoading();
    try {
      final user = await _repository.register(username, email, password, null);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
  
  Future<void> logout() async {
    await _repository.logout();
    state = AuthUnauthenticated();
  }
  
  Future<void> checkAuthStatus() async {
    state = AuthLoading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthUnauthenticated();
    }
  }
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/shared/repositories/auth_repository.dart';
import 'package:social_chat_app/shared/repositories/user_repository.dart';
import 'package:social_chat_app/shared/models/user.dart';
import 'package:social_chat_app/core/storage/local_storage.dart';
import 'package:social_chat_app/core/network/stomp_service.dart';
import 'package:social_chat_app/core/network/web_socket_service_provider.dart';

/// Auth state
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final StompWebSocketService _wsService;

  AuthNotifier(this._authRepository, this._userRepository, this._wsService)
      : super(const AuthState());

  /// Check if user is logged in on app start
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getStoredUser();
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          // Connect WebSocket after auth
          await _wsService.connect();
          return;
        }
      }
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Login with email/username and password
  Future<void> login(String emailOrUsername, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final user = await _authRepository.login(emailOrUsername, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      // Connect WebSocket after login
      await _wsService.connect();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Register a new user
  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      // Connect WebSocket after registration
      await _wsService.connect();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    // Disconnect WebSocket
    _wsService.disconnect();
    
    await _authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Update user in state
  void updateUser(User user) {
    state = state.copyWith(user: user);
    LocalStorage.saveUser(user.toJson());
  }

  /// Refresh current user from API
  Future<void> refreshUser() async {
    try {
      final user = await _userRepository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // Silently fail, keep existing user
    }
  }
}

/// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final wsService = ref.watch(stompServiceProvider);
  return AuthNotifier(authRepo, userRepo, wsService);
});

/// Current user provider (convenience accessor)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

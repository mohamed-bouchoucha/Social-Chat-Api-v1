import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/network/api_response.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/constants/api_endpoints.dart';
import 'package:social_chat_app/core/storage/local_storage.dart';
import 'package:social_chat_app/shared/models/user.dart';

/// Repository for authentication operations
/// 
/// Connects to backend auth endpoints:
/// - POST /api/auth/login
/// - POST /api/auth/register
/// - POST /api/auth/refresh
/// - POST /api/auth/logout
/// - POST /api/auth/change-password
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Login with email/username and password
  /// Returns the authenticated user and stores tokens
  Future<User> login(String emailOrUsername, String password) async {
    final response = await _apiClient.post(
      AppConstants.authLogin,
      data: {
        'username': emailOrUsername,
        'password': password,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Login failed');
    }

    final data = apiResponse.data!;
    final tokenResponse = TokenResponse.fromJson(data);
    
    // Store tokens
    await LocalStorage.saveToken(tokenResponse.accessToken);
    await LocalStorage.saveRefreshToken(tokenResponse.refreshToken);

    // Parse and store user
    final userData = data['user'] as Map<String, dynamic>;
    await LocalStorage.saveUser(userData);

    return User.fromJson(userData);
  }

  /// Register a new user
  Future<User> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _apiClient.post(
      AppConstants.authRegister,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'displayName': displayName,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Registration failed');
    }

    final data = apiResponse.data!;
    final tokenResponse = TokenResponse.fromJson(data);
    
    // Store tokens
    await LocalStorage.saveToken(tokenResponse.accessToken);
    await LocalStorage.saveRefreshToken(tokenResponse.refreshToken);

    // Parse and store user
    final userData = data['user'] as Map<String, dynamic>;
    await LocalStorage.saveUser(userData);

    return User.fromJson(userData);
  }

  /// Refresh access token using refresh token
  Future<void> refreshToken() async {
    final refreshToken = await LocalStorage.getRefreshToken();
    if (refreshToken == null) {
      throw UnauthorizedException('No refresh token available');
    }

    final response = await _apiClient.post(
      AppConstants.authRefresh,
      data: {'refreshToken': refreshToken},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw UnauthorizedException('Token refresh failed');
    }

    final tokenResponse = TokenResponse.fromJson(apiResponse.data!);
    await LocalStorage.saveToken(tokenResponse.accessToken);
    await LocalStorage.saveRefreshToken(tokenResponse.refreshToken);
  }

  /// Logout and revoke tokens
  Future<void> logout() async {
    try {
      final refreshToken = await LocalStorage.getRefreshToken();
      await _apiClient.post(
        AppConstants.authLogout,
        data: refreshToken != null ? {'refreshToken': refreshToken} : null,
      );
    } catch (e) {
      // Silently fail if server logout fails
      // We still want to clear local data
    } finally {
      await LocalStorage.clearAuthData();
    }
  }

  /// Change password for current user
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      AppConstants.authChangePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Password change failed');
    }
  }

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    return await LocalStorage.isLoggedIn();
  }

  /// Get stored user from local storage
  Future<User?> getStoredUser() async {
    final userData = await LocalStorage.getUser();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }
}

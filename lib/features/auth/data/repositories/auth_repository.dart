import 'package:dio/dio.dart';
import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/storage/local_storage.dart';
import 'package:social_chat_app/shared/models/user.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['token'];
      final refreshToken = data['refreshToken'];
      final userData = data['user'] as Map<String, dynamic>;

      // Save tokens
      await LocalStorage.saveToken(token);
      await LocalStorage.saveUser(userData);

      return User.fromJson(userData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User> register(
    String username,
    String email,
    String password,
    String? fullName,
  ) async {
    try {
      final response = await _apiClient.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['token'];
      final refreshToken = data['refreshToken'];
      final userData = data['user'] as Map<String, dynamic>;

      // Save tokens
      await LocalStorage.saveToken(token);
      await LocalStorage.saveUser(userData);

      return User.fromJson(userData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Registration failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Silently fail if server logout fails
      print('Logout error: $e');
    } finally {
      // Clear local storage
      await LocalStorage.clearAll();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // First check local storage
      final userData = await LocalStorage.getUser();
      if (userData != null) {
        return User.fromJson(userData);
      }

      // If not in storage, try to fetch from server
      final response = await _apiClient.get('/auth/me');
      final userDataFromServer = response.data as Map<String, dynamic>;
      
      await LocalStorage.saveUser(userDataFromServer);
      return User.fromJson(userDataFromServer);
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  Future<void> refreshToken() async {
    try {
      final response = await _apiClient.post('/auth/refresh-token');
      final data = response.data as Map<String, dynamic>;
      final token = data['token'];
      
      await LocalStorage.saveToken(token);
    } catch (e) {
      // If refresh fails, force logout
      await logout();
      throw Exception('Session expired. Please login again.');
    }
  }

  Future<void> updateProfile({
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final response = await _apiClient.put('/auth/profile', data: {
        'username': username,
        'bio': bio,
        'avatarUrl': avatarUrl,
      });

      final userData = response.data as Map<String, dynamic>;
      await LocalStorage.saveUser(userData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Profile update failed');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _apiClient.post('/auth/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Password change failed');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post('/auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Password reset failed');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiClient.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Password reset failed');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/network/api_response.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/constants/api_endpoints.dart';
import 'package:social_chat_app/core/storage/local_storage.dart';
import 'package:social_chat_app/shared/models/user.dart';

/// Repository for user operations
/// 
/// Connects to backend user endpoints:
/// - GET /api/users/me
/// - GET /api/users/{id}
/// - GET /api/users/username/{username}
/// - PATCH /api/users/me
/// - POST /api/users/me/photo
/// - DELETE /api/users/me
class UserRepository {
  final ApiClient _apiClient;

  UserRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get current authenticated user
  Future<User> getCurrentUser() async {
    final response = await _apiClient.get(AppConstants.usersMe);

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get user');
    }

    // Update stored user data
    await LocalStorage.saveUser(apiResponse.data!.toJson());

    return apiResponse.data!;
  }

  /// Get user by ID
  Future<User> getUserById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.userById(id));

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'User not found');
    }

    return apiResponse.data!;
  }

  /// Get user by username
  Future<User> getUserByUsername(String username) async {
    final response = await _apiClient.get(ApiEndpoints.userByUsername(username));

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'User not found');
    }

    return apiResponse.data!;
  }

  /// Update current user profile
  Future<User> updateProfile({
    String? displayName,
    String? bio,
  }) async {
    final response = await _apiClient.patch(
      AppConstants.usersMe,
      data: {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to update profile');
    }

    // Update stored user data
    await LocalStorage.saveUser(apiResponse.data!.toJson());

    return apiResponse.data!;
  }

  /// Upload profile photo
  Future<User> uploadPhoto(String filePath) async {
    final response = await _apiClient.uploadFile(
      AppConstants.usersPhoto,
      filePath,
      fieldName: 'file',
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to upload photo');
    }

    // Update stored user data
    await LocalStorage.saveUser(apiResponse.data!.toJson());

    return apiResponse.data!;
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    final response = await _apiClient.delete(AppConstants.usersMe);

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to delete account');
    }

    // Clear local data
    await LocalStorage.clearAll();
  }
}

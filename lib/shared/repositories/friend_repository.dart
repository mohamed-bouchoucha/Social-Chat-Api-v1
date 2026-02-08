import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/network/api_response.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/constants/api_endpoints.dart';
import 'package:social_chat_app/shared/models/user.dart';
import 'package:social_chat_app/shared/models/friend_request.dart';

/// Repository for friend operations
/// 
/// Connects to backend friend endpoints:
/// - GET /api/friends
/// - POST /api/friends/request/{userId}
/// - GET /api/friends/requests/received
/// - GET /api/friends/requests/sent
/// - POST /api/friends/requests/{requestId}/accept
/// - POST /api/friends/requests/{requestId}/reject
/// - DELETE /api/friends/{friendId}
/// - POST /api/friends/block/{userId}
/// - DELETE /api/friends/block/{userId}
/// - GET /api/friends/relationship/{userId}
class FriendRepository {
  final ApiClient _apiClient;

  FriendRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get friends list with pagination
  Future<PageResponse<Friend>> getFriends({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      AppConstants.friends,
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<Friend>.fromJson(
        data as Map<String, dynamic>,
        (json) => Friend.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get friends');
    }

    return apiResponse.data!;
  }

  /// Send friend request to a user
  Future<FriendRequest> sendRequest(int userId) async {
    final response = await _apiClient.post(ApiEndpoints.sendFriendRequest(userId));

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => FriendRequest.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to send friend request');
    }

    return apiResponse.data!;
  }

  /// Get received friend requests
  Future<PageResponse<FriendRequest>> getReceivedRequests({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      AppConstants.friendsRequestsReceived,
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<FriendRequest>.fromJson(
        data as Map<String, dynamic>,
        (json) => FriendRequest.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get requests');
    }

    return apiResponse.data!;
  }

  /// Get sent friend requests
  Future<PageResponse<FriendRequest>> getSentRequests({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      AppConstants.friendsRequestsSent,
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<FriendRequest>.fromJson(
        data as Map<String, dynamic>,
        (json) => FriendRequest.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get sent requests');
    }

    return apiResponse.data!;
  }

  /// Accept a friend request
  Future<void> acceptRequest(int requestId) async {
    final response = await _apiClient.post(ApiEndpoints.acceptFriendRequest(requestId));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to accept request');
    }
  }

  /// Reject a friend request
  Future<void> rejectRequest(int requestId) async {
    final response = await _apiClient.post(ApiEndpoints.rejectFriendRequest(requestId));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to reject request');
    }
  }

  /// Remove a friend
  Future<void> removeFriend(int friendId) async {
    final response = await _apiClient.delete(ApiEndpoints.removeFriend(friendId));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to remove friend');
    }
  }

  /// Block a user
  Future<void> blockUser(int userId) async {
    final response = await _apiClient.post(ApiEndpoints.blockUser(userId));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to block user');
    }
  }

  /// Unblock a user
  Future<void> unblockUser(int userId) async {
    final response = await _apiClient.delete(ApiEndpoints.blockUser(userId));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to unblock user');
    }
  }

  /// Get relationship status with a user
  Future<Relationship> getRelationship(int userId) async {
    final response = await _apiClient.get(ApiEndpoints.relationship(userId));

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => Relationship.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get relationship');
    }

    return apiResponse.data!;
  }
}

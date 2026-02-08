import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/network/api_response.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/constants/api_endpoints.dart';
import 'package:social_chat_app/shared/models/notification.dart';

/// Repository for notification operations
/// 
/// Connects to backend notification endpoints:
/// - GET /api/notifications
/// - GET /api/notifications/unread-count
/// - POST /api/notifications/{id}/read
/// - POST /api/notifications/read-all
/// - DELETE /api/notifications/{id}
class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get notifications with pagination
  Future<PageResponse<AppNotification>> getNotifications({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      AppConstants.notifications,
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<AppNotification>.fromJson(
        data as Map<String, dynamic>,
        (json) => AppNotification.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get notifications');
    }

    return apiResponse.data!;
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(AppConstants.notificationsUnreadCount);

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => data as int,
    );

    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to get unread count');
    }

    return apiResponse.data ?? 0;
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    final response = await _apiClient.post(ApiEndpoints.markNotificationRead(notificationId));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to mark as read');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final response = await _apiClient.post(AppConstants.notificationsReadAll);

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to mark all as read');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    final response = await _apiClient.delete(ApiEndpoints.deleteNotification(notificationId));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to delete notification');
    }
  }
}

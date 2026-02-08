import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/network/api_response.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/shared/models/user.dart';

/// Repository for search operations
/// 
/// Connects to backend search endpoint:
/// - GET /api/search/users?q={query}
class SearchRepository {
  final ApiClient _apiClient;

  SearchRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Search users by username or display name
  Future<PageResponse<User>> searchUsers(String query, {int page = 0, int size = 20}) async {
    if (query.trim().isEmpty) {
      return PageResponse(
        content: [],
        page: 0,
        size: size,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
      );
    }

    final response = await _apiClient.get(
      AppConstants.searchUsers,
      queryParameters: {
        'q': query.trim(),
        'page': page,
        'size': size,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<User>.fromJson(
        data as Map<String, dynamic>,
        (json) => User.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Search failed');
    }

    return apiResponse.data!;
  }
}

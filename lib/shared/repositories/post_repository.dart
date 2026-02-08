import 'package:dio/dio.dart';
import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/network/api_response.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/constants/api_endpoints.dart';
import 'package:social_chat_app/shared/models/post.dart';
import 'package:social_chat_app/shared/models/comment.dart';

/// Repository for post operations
/// 
/// Connects to backend post endpoints:
/// - GET /api/posts/feed
/// - POST /api/posts
/// - GET /api/posts/{id}
/// - PATCH /api/posts/{id}
/// - DELETE /api/posts/{id}
/// - POST /api/posts/{id}/like
/// - DELETE /api/posts/{id}/like
/// - GET /api/posts/{id}/comments
/// - POST /api/posts/{id}/comments
/// - DELETE /api/posts/{postId}/comments/{commentId}
class PostRepository {
  final ApiClient _apiClient;

  PostRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get posts feed with pagination
  Future<PageResponse<Post>> getFeed({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      AppConstants.postsFeed,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<Post>.fromJson(
        data as Map<String, dynamic>,
        (json) => Post.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get feed');
    }

    return apiResponse.data!;
  }

  /// Get posts by user ID
  Future<PageResponse<Post>> getUserPosts(int userId, {int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.userPosts(userId),
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<Post>.fromJson(
        data as Map<String, dynamic>,
        (json) => Post.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get user posts');
    }

    return apiResponse.data!;
  }

  /// Get single post by ID
  Future<Post> getPost(int id) async {
    final response = await _apiClient.get(ApiEndpoints.post(id));

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => Post.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Post not found');
    }

    return apiResponse.data!;
  }

  /// Create a new post
  Future<Post> createPost({
    required String content,
    List<String>? imagePaths,
  }) async {
    // Build multipart form data
    final fields = <String, dynamic>{
      'post': MultipartFile.fromString(
        '{"content": "$content"}',
        contentType: DioMediaType.parse('application/json'),
      ),
    };

    // Add images if provided
    final files = <MapEntry<String, MultipartFile>>[];
    if (imagePaths != null) {
      for (final path in imagePaths) {
        files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(path),
        ));
      }
    }

    final response = await _apiClient.uploadMultipart(
      AppConstants.posts,
      fields: fields,
      files: files.isNotEmpty ? files : null,
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => Post.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to create post');
    }

    return apiResponse.data!;
  }

  /// Update an existing post
  Future<Post> updatePost(int id, String content) async {
    final response = await _apiClient.patch(
      ApiEndpoints.post(id),
      data: {'content': content},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => Post.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to update post');
    }

    return apiResponse.data!;
  }

  /// Delete a post
  Future<void> deletePost(int id) async {
    final response = await _apiClient.delete(ApiEndpoints.post(id));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to delete post');
    }
  }

  /// Like a post
  Future<void> likePost(int id) async {
    final response = await _apiClient.post(ApiEndpoints.likePost(id));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to like post');
    }
  }

  /// Unlike a post
  Future<void> unlikePost(int id) async {
    final response = await _apiClient.delete(ApiEndpoints.likePost(id));

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to unlike post');
    }
  }

  /// Get comments for a post
  Future<PageResponse<Comment>> getComments(int postId, {int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.postComments(postId),
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => PageResponse<Comment>.fromJson(
        data as Map<String, dynamic>,
        (json) => Comment.fromJson(json),
      ),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to get comments');
    }

    return apiResponse.data!;
  }

  /// Add a comment to a post
  Future<Comment> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.postComments(postId),
      data: {
        'content': content,
        if (parentId != null) 'parentId': parentId,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => Comment.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw ApiException(apiResponse.message ?? 'Failed to add comment');
    }

    return apiResponse.data!;
  }

  /// Delete a comment
  Future<void> deleteComment(int postId, int commentId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.deleteComment(postId, commentId),
    );

    final apiResponse = ApiResponse.fromJson(response.data, null);
    if (!apiResponse.isSuccess) {
      throw ApiException(apiResponse.message ?? 'Failed to delete comment');
    }
  }
}

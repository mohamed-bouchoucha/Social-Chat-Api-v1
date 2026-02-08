import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/storage/local_storage.dart';

/// Custom exception types for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized']) : super(message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Forbidden']) : super(message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Not found']) : super(message, statusCode: 404);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;
  ValidationException(String message, {this.errors}) : super(message, statusCode: 400);
}

class ServerException extends ApiException {
  ServerException([String message = 'Server error']) : super(message, statusCode: 500);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Network error']) : super(message);
}

/// Callback type for handling unauthorized errors
typedef OnUnauthorized = Future<void> Function();

/// Singleton API client with JWT authentication and error handling
/// 
/// This client:
/// - Automatically attaches JWT tokens to requests
/// - Handles 401/403 errors globally
/// - Provides typed error exceptions
/// - Supports file uploads with multipart
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;
  OnUnauthorized? _onUnauthorized;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  /// Set callback for unauthorized errors (e.g., to navigate to login)
  void setOnUnauthorized(OnUnauthorized callback) {
    _onUnauthorized = callback;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token to headers if available
        final token = await LocalStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Log request in debug mode
        if (kDebugMode) {
          print('📤 ${options.method} ${options.path}');
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response in debug mode
        if (kDebugMode) {
          print('📥 ${response.statusCode} ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        // Log error in debug mode
        if (kDebugMode) {
          print('❌ ${error.response?.statusCode} ${error.requestOptions.path}');
          print('   ${error.message}');
        }
        
        // Handle specific error codes
        if (error.response?.statusCode == 401) {
          await _handleUnauthorized();
        }
        
        return handler.next(error);
      },
    ));
  }

  Future<void> _handleUnauthorized() async {
    // Clear stored tokens
    await LocalStorage.clearAll();
    
    // Notify the app to redirect to login
    if (_onUnauthorized != null) {
      await _onUnauthorized!();
    }
  }

  /// Get the Dio instance for advanced usage
  Dio get dio => _dio;

  /// Parse API errors into typed exceptions
  ApiException _parseError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Connection timeout. Please check your network.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException('Unable to connect. Please check your network.');
    }

    final response = error.response;
    if (response == null) {
      return NetworkException('Network error: ${error.message}');
    }

    final statusCode = response.statusCode;
    final data = response.data;
    String message = 'An error occurred';
    
    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message, errors: data is Map ? data['errors'] : null);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 500:
      case 502:
      case 503:
        return ServerException(message);
      default:
        return ApiException(message, statusCode: statusCode, data: data);
    }
  }

  // ============================================
  // HTTP METHODS
  // ============================================

  /// Perform a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Perform a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Perform a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Perform a PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Perform a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ============================================
  // FILE UPLOAD
  // ============================================

  /// Upload a single file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalFields,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Upload multiple files with additional JSON data
  Future<Response<T>> uploadMultipart<T>(
    String path, {
    required Map<String, dynamic> fields,
    List<MapEntry<String, MultipartFile>>? files,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap(fields);
      if (files != null) {
        for (final file in files) {
          formData.files.add(file);
        }
      }

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }
}
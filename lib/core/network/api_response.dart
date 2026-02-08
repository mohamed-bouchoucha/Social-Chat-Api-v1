/// Generic API response wrapper matching backend ApiResponse<T>
/// 
/// The backend returns responses in this format:
/// {
///   "success": true,
///   "data": {...},
///   "message": "Success message",
///   "timestamp": "2024-01-01T00:00:00"
/// }
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final DateTime? timestamp;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? true,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  bool get isSuccess => success;
  bool get hasData => data != null;
}

/// Paginated response wrapper matching backend PageResponse<T>
/// 
/// The backend returns paginated data in this format:
/// {
///   "content": [...],
///   "page": 0,
///   "size": 20,
///   "totalElements": 100,
///   "totalPages": 5,
///   "first": true,
///   "last": false
/// }
class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResponse(
      content: (json['content'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] ?? 0,
      size: json['size'] ?? 20,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }

  bool get isEmpty => content.isEmpty;
  bool get isNotEmpty => content.isNotEmpty;
  bool get hasMore => !last;
  int get nextPage => page + 1;
}

/// Token response from auth endpoints
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 3600,
    );
  }
}

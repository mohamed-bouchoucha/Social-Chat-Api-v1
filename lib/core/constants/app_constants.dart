/// Application constants and API endpoint definitions
/// 
/// This file contains all configuration constants for the app including:
/// - Base URLs for REST API and WebSocket
/// - All API endpoint paths organized by feature
/// - WebSocket destinations for STOMP protocol
/// - Storage keys and other app-wide constants
class AppConstants {
  // ============================================
  // APP INFO
  // ============================================
  static const String appName = 'Social Chat';
  static const String appVersion = '1.0.0';

  // ============================================
  // BASE URLS
  // ============================================
  // For Android Emulator use 10.0.2.2 (localhost alias)
  // For iOS Simulator or Web use localhost
  // For real device use your machine's IP address
  
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  static const String wsUrl = 'ws://10.0.2.2:8080/ws';
  
  // For web browser testing:
  // static const String baseUrl = 'http://localhost:8080/api';
  // static const String wsUrl = 'ws://localhost:8080/ws';

  // ============================================
  // AUTH ENDPOINTS
  // ============================================
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authChangePassword = '/auth/change-password';

  // ============================================
  // USER ENDPOINTS
  // ============================================
  static const String usersMe = '/users/me';
  static const String usersById = '/users'; // + /{id}
  static const String usersByUsername = '/users/username'; // + /{username}
  static const String usersPhoto = '/users/me/photo';

  // ============================================
  // POST ENDPOINTS
  // ============================================
  static const String posts = '/posts';
  static const String postsFeed = '/posts/feed';
  // Single post: /posts/{id}
  // User posts: /posts/user/{userId}
  // Like: POST /posts/{id}/like, DELETE /posts/{id}/like
  // Comments: GET/POST /posts/{id}/comments
  // Delete comment: DELETE /posts/{postId}/comments/{commentId}

  // ============================================
  // CHAT ENDPOINTS
  // ============================================
  static const String chatConversations = '/chat/conversations';
  // Single conversation: /chat/conversations/{id}
  // Messages: /chat/conversations/{id}/messages
  // Send message: POST /chat/conversations/{id}/messages
  // Mark as read: POST /chat/conversations/{id}/read
  // Leave: DELETE /chat/conversations/{id}

  // ============================================
  // FRIEND ENDPOINTS
  // ============================================
  static const String friends = '/friends';
  static const String friendsRequest = '/friends/request'; // + /{userId}
  static const String friendsRequestsReceived = '/friends/requests/received';
  static const String friendsRequestsSent = '/friends/requests/sent';
  // Accept: POST /friends/requests/{requestId}/accept
  // Reject: POST /friends/requests/{requestId}/reject
  // Remove: DELETE /friends/{friendId}
  // Block: POST /friends/block/{userId}
  // Unblock: DELETE /friends/block/{userId}
  // Relationship: GET /friends/relationship/{userId}

  // ============================================
  // NOTIFICATION ENDPOINTS
  // ============================================
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  // Mark as read: POST /notifications/{id}/read
  // Delete: DELETE /notifications/{id}

  // ============================================
  // SEARCH ENDPOINTS
  // ============================================
  static const String searchUsers = '/search/users';

  // ============================================
  // PRESENCE ENDPOINTS
  // ============================================
  static const String presenceFriends = '/presence/friends';
  static const String presenceUser = '/presence/user'; // + /{userId}

  // ============================================
  // WEBSOCKET STOMP DESTINATIONS
  // ============================================
  // Application destinations (send to these)
  static const String wsSendMessage = '/app/chat'; // + /{conversationId}/message
  static const String wsSendTyping = '/app/chat'; // + /{conversationId}/typing
  static const String wsSendRead = '/app/chat'; // + /{conversationId}/read

  // User-specific subscriptions (subscribe to these)
  static const String wsSubscribeMessages = '/user/queue/messages';
  static const String wsSubscribeNotifications = '/user/queue/notifications';
  static const String wsSubscribePresence = '/user/queue/presence';
  static const String wsSubscribeTyping = '/user/queue/typing';

  // Topic subscriptions (for conversation-specific updates)
  // /topic/conversation/{conversationId}
  static const String wsTopicConversation = '/topic/conversation';

  // ============================================
  // STORAGE KEYS
  // ============================================
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // ============================================
  // PAGINATION
  // ============================================
  static const int pageSize = 20;
  static const int messagesPageSize = 50;

  // ============================================
  // TIMEOUTS
  // ============================================
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration wsReconnectDelay = Duration(seconds: 3);

  // ============================================
  // VALIDATION
  // ============================================
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 100;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  static const int maxBioLength = 500;
  static const int maxMessageLength = 5000;
  static const int maxPostContentLength = 10000;

  // ============================================
  // CACHE
  // ============================================
  static const Duration cacheTimeout = Duration(minutes: 5);
}
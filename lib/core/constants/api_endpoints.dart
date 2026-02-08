/// API Endpoints helper for building dynamic URLs
/// 
/// This class provides helper methods for building API endpoint URLs
/// that require path parameters.
class ApiEndpoints {
  // Posts
  static String post(int id) => '/posts/$id';
  static String userPosts(int userId) => '/posts/user/$userId';
  static String likePost(int id) => '/posts/$id/like';
  static String postComments(int id) => '/posts/$id/comments';
  static String deleteComment(int postId, int commentId) => 
      '/posts/$postId/comments/$commentId';

  // Chat
  static String conversation(int id) => '/chat/conversations/$id';
  static String conversationMessages(int id) => '/chat/conversations/$id/messages';
  static String markConversationRead(int id) => '/chat/conversations/$id/read';

  // Friends
  static String sendFriendRequest(int userId) => '/friends/request/$userId';
  static String acceptFriendRequest(int requestId) => 
      '/friends/requests/$requestId/accept';
  static String rejectFriendRequest(int requestId) => 
      '/friends/requests/$requestId/reject';
  static String removeFriend(int friendId) => '/friends/$friendId';
  static String blockUser(int userId) => '/friends/block/$userId';
  static String relationship(int userId) => '/friends/relationship/$userId';

  // Users
  static String userById(int id) => '/users/$id';
  static String userByUsername(String username) => '/users/username/$username';

  // Notifications
  static String markNotificationRead(int id) => '/notifications/$id/read';
  static String deleteNotification(int id) => '/notifications/$id';

  // Presence
  static String userPresence(int userId) => '/presence/user/$userId';

  // WebSocket STOMP destinations
  static String wsChatMessage(int conversationId) => 
      '/app/chat/$conversationId/message';
  static String wsChatTyping(int conversationId) => 
      '/app/chat/$conversationId/typing';
  static String wsChatRead(int conversationId) => 
      '/app/chat/$conversationId/read';
  static String wsTopicConversation(int conversationId) => 
      '/topic/conversation/$conversationId';
}

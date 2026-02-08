import 'package:social_chat_app/core/network/api_client.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';
import 'package:social_chat_app/core/constants/api_endpoints.dart';

/// Presence info
class PresenceInfo {
  final int userId;
  final bool isOnline;
  final DateTime? lastSeen;

  PresenceInfo({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
  });

  factory PresenceInfo.fromJson(Map<String, dynamic> json) {
    return PresenceInfo(
      userId: json['userId'] ?? 0,
      isOnline: json['online'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    );
  }
}

/// Repository for presence/online status operations
/// 
/// Connects to backend presence endpoints:
/// - GET /api/presence/friends
/// - GET /api/presence/user/{userId}
class PresenceRepository {
  final ApiClient _apiClient;

  PresenceRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get list of online friend IDs
  Future<Set<int>> getOnlineFriends() async {
    final response = await _apiClient.get(AppConstants.presenceFriends);
    final data = response.data;
    
    if (data is List) {
      return data.map<int>((e) => e as int).toSet();
    }
    
    return {};
  }

  /// Get presence info for a specific user (must be friends)
  Future<PresenceInfo> getUserPresence(int userId) async {
    final response = await _apiClient.get(ApiEndpoints.userPresence(userId));
    return PresenceInfo.fromJson(response.data);
  }
}

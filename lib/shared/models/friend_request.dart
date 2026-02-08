import 'package:social_chat_app/shared/models/user.dart';

/// Friend request status enum
enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
}

/// Friend request model matching backend FriendRequestResponse DTO
class FriendRequest {
  final int id;
  final UserSummary sender;
  final UserSummary receiver;
  final FriendRequestStatus status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] ?? 0,
      sender: UserSummary.fromJson(json['sender'] ?? {}),
      receiver: UserSummary.fromJson(json['receiver'] ?? {}),
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static FriendRequestStatus _parseStatus(String? status) {
    if (status == null) return FriendRequestStatus.pending;
    switch (status.toLowerCase()) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'status': status.name.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == FriendRequestStatus.pending;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }
}

/// Relationship status between two users
enum RelationshipStatus {
  none,
  pending,
  friends,
  blocked,
  blockedBy,
}

/// Relationship response from backend
class Relationship {
  final int userId;
  final RelationshipStatus status;
  final int? requestId;

  Relationship({
    required this.userId,
    required this.status,
    this.requestId,
  });

  factory Relationship.fromJson(Map<String, dynamic> json) {
    return Relationship(
      userId: json['userId'] ?? 0,
      status: _parseStatus(json['status']),
      requestId: json['requestId'],
    );
  }

  static RelationshipStatus _parseStatus(String? status) {
    if (status == null) return RelationshipStatus.none;
    switch (status.toLowerCase()) {
      case 'pending':
        return RelationshipStatus.pending;
      case 'friends':
        return RelationshipStatus.friends;
      case 'blocked':
        return RelationshipStatus.blocked;
      case 'blocked_by':
        return RelationshipStatus.blockedBy;
      default:
        return RelationshipStatus.none;
    }
  }

  bool get isFriends => status == RelationshipStatus.friends;
  bool get isPending => status == RelationshipStatus.pending;
  bool get isBlocked => status == RelationshipStatus.blocked;
  // For pending requests, backend indicates direction via additional fields
  // These are simplified - actual implementation depends on backend response
  bool get requestSent => status == RelationshipStatus.pending && requestId != null;
  bool get requestReceived => status == RelationshipStatus.pending && requestId != null;
}

/// Friend model (user who is a friend)
class Friend {
  final int id;
  final UserSummary user;
  final DateTime friendsSince;

  Friend({
    required this.id,
    required this.user,
    required this.friendsSince,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? 0,
      user: UserSummary.fromJson(json['user'] ?? json),
      friendsSince: json['friendsSince'] != null
          ? DateTime.parse(json['friendsSince'])
          : DateTime.now(),
    );
  }
}

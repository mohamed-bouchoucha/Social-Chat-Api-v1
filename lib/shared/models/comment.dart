import 'package:social_chat_app/shared/models/user.dart';

/// Comment model matching backend CommentResponse DTO
class Comment {
  final int id;
  final int postId;
  final UserSummary author;
  final String content;
  final int? parentId;
  final List<Comment> replies;
  final int repliesCount;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    this.parentId,
    this.replies = const [],
    this.repliesCount = 0,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      author: UserSummary.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      parentId: json['parentId'],
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => Comment.fromJson(e))
              .toList()
          : [],
      repliesCount: json['repliesCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'author': author.toJson(),
      'content': content,
      'parentId': parentId,
      'repliesCount': repliesCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isReply => parentId != null;
  bool get hasReplies => repliesCount > 0 || replies.isNotEmpty;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

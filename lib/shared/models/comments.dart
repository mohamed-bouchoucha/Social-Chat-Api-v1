import 'package:social_chat_app/shared/models/user.dart';

class Comment {
  final String id;
  final User author;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String postId;
  final String? parentCommentId;
  final int likesCount;
  final bool isLiked;
  
  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.postId,
    this.parentCommentId,
    required this.likesCount,
    required this.isLiked,
  });
  
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      postId: json['postId'] ?? '',
      parentCommentId: json['parentCommentId'],
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'postId': postId,
      'parentCommentId': parentCommentId,
      'likesCount': likesCount,
      'isLiked': isLiked,
    };
  }
  
  Comment copyWith({
    String? id,
    User? author,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? postId,
    String? parentCommentId,
    int? likesCount,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      postId: postId ?? this.postId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
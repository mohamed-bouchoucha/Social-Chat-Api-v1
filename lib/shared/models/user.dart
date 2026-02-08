/// User model matching backend UserResponse DTO
/// 
/// This model represents a user in the application with all fields
/// returned by the backend API.
class User {
  final int id;
  final String username;
  final String email;
  final String? displayName;
  final String? bio;
  final String? profilePhotoUrl;
  final String? coverPhotoUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.bio,
    this.profilePhotoUrl,
    this.coverPhotoUrl,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
  });

  /// Get display name or fallback to username
  String get name => displayName ?? username;

  /// Get avatar URL or null for placeholder
  String? get avatarUrl => profilePhotoUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      bio: json['bio'],
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['avatarUrl'],
      coverPhotoUrl: json['coverPhotoUrl'],
      isOnline: json['online'] ?? json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'online': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? displayName,
    String? bio,
    String? profilePhotoUrl,
    String? coverPhotoUrl,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Simplified user for embedded data (e.g., post author, message sender)
class UserSummary {
  final int id;
  final String username;
  final String? displayName;
  final String? profilePhotoUrl;
  final bool isOnline;

  UserSummary({
    required this.id,
    required this.username,
    this.displayName,
    this.profilePhotoUrl,
    this.isOnline = false,
  });

  String get name => displayName ?? username;
  String? get avatarUrl => profilePhotoUrl;

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      displayName: json['displayName'],
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['avatarUrl'],
      isOnline: json['online'] ?? json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'profilePhotoUrl': profilePhotoUrl,
      'online': isOnline,
    };
  }
}
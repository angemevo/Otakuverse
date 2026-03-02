// models/story_model.dart

class StoryModel {
  final String id;
  final String userId;
  final String mediaUrl;
  final String mediaType; // 'image' ou 'video'
  final int viewsCount;
  final DateTime createdAt;
  final DateTime expiresAt;
  
  // Relations
  final Map<String, dynamic>? user;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    required this.viewsCount,
    required this.createdAt,
    required this.expiresAt,
    this.user,
  });

  // Getters
  String get username => user?['username'] ?? 'Utilisateur';
  String get displayName => user?['display_name'] ?? '';
  String? get avatarUrl => user?['avatar_url'];
  
  String get displayNameOrUsername {
    final name = displayName.trim();
    return name.isNotEmpty ? name : username;
  }
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isImage => mediaType == 'image';
  bool get isVideo => mediaType == 'video';
  
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  // From JSON
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mediaUrl: json['media_url'] as String,
      mediaType: json['media_type'] as String,
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      user: json['user'] as Map<String, dynamic>?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'views_count': viewsCount,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

// ============================================
// STORY VIEWER MODEL
// ============================================
class StoryViewerModel {
  final String id;
  final String storyId;
  final String userId;
  final DateTime viewedAt;
  final Map<String, dynamic>? user;

  const StoryViewerModel({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.viewedAt,
    this.user,
  });

  String get username => user?['username'] ?? 'Utilisateur';
  String get displayName => user?['display_name'] ?? '';
  String? get avatarUrl => user?['avatar_url'];
  
  String get displayNameOrUsername {
    final name = displayName.trim();
    return name.isNotEmpty ? name : username;
  }

  factory StoryViewerModel.fromJson(Map<String, dynamic> json) {
    return StoryViewerModel(
      id: json['id'] as String,
      storyId: json['story_id'] as String,
      userId: json['user_id'] as String,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
      user: json['user'] as Map<String, dynamic>?,
    );
  }
}
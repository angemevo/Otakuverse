// models/post_model.dart

class PostModel {
  final String id;
  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String caption;
  final List<String> mediaUrls;
  final String? location;
  final int likesCount;
  final int commentsCount;
  final int? sharesCount;
  final int? viewsCount;
  final int? savesCount;
  final List<String>? hashtags;
  final List<dynamic>? likedByUsers;
  final bool isPinned;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime? editedAt;

  // Getters
  String get displayNameOrUsername => displayName ?? username ?? 'Utilisateur';
  bool get hasLocation => location != null && location!.isNotEmpty;
  bool get isCarousel => mediaUrls.length > 1;
  int get mediaCount => mediaUrls.length;

  PostModel({
    required this.id,
    required this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    required this.caption,
    required this.mediaUrls,
    this.location,
    required this.likesCount,
    required this.commentsCount,
    this.sharesCount,
    this.viewsCount,
    this.savesCount,
    this.hashtags,
    this.likedByUsers,
    this.isPinned = false,
    this.isEdited = false,
    required this.createdAt,
    this.editedAt,
  });

  // ✅ MÉTHODE copyWith
  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? caption,
    List<String>? mediaUrls,
    String? location,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    int? savesCount,
    List<String>? hashtags,
    List<dynamic>? likedByUsers,
    bool? isPinned,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      caption: caption ?? this.caption,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      location: location ?? this.location,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      savesCount: savesCount ?? this.savesCount,
      hashtags: hashtags ?? this.hashtags,
      likedByUsers: likedByUsers ?? this.likedByUsers,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  // ✅ MÉTHODE fromJson
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['user']?['username']?.toString(),
      displayName: json['user']?['display_name']?.toString(),
      avatarUrl: json['user']?['avatar_url']?.toString(),
      caption: json['caption']?.toString() ?? '',
      mediaUrls: (json['media_urls'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location']?.toString(),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'],
      viewsCount: json['views_count'],
      savesCount: json['saves_count'],
      hashtags: (json['hashtags'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      likedByUsers: json['liked_by_users'] as List?,
      isPinned: json['is_pinned'] ?? false,
      isEdited: json['is_edited'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : null,
    );
  }

  // ✅ MÉTHODE toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'media_urls': mediaUrls,
      'location': location,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'views_count': viewsCount,
      'saves_count': savesCount,
      'hashtags': hashtags,
      'is_pinned': isPinned,
      'is_edited': isEdited,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
    };
  }

  // ✅ MÉTHODE toString (pour debug)
  @override
  String toString() {
    return 'PostModel(id: $id, userId: $userId, caption: $caption, likesCount: $likesCount)';
  }

  // ✅ MÉTHODE equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
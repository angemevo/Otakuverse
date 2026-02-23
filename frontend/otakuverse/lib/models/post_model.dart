class PostModel {
  final String id;
  final String userId;
  final String caption;
  final List<String> mediaUrls;
  final int mediaCount;
  final String? location;
  final bool isPinned;
  final bool allowComments;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations optionnelles (jointures)
  final Map<String, dynamic>? user;

  const PostModel({
    required this.id,
    required this.userId,
    required this.caption,
    required this.mediaUrls,
    required this.mediaCount,
    this.location,
    required this.isPinned,
    required this.allowComments,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  // ============================================
  // FROM JSON
  // ============================================
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      caption: json['caption'] as String,
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      mediaCount: json['media_count'] as int,
      location: json['location'] as String?,
      isPinned: json['is_pinned'] ?? false,
      allowComments: json['allow_comments'] ?? true,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['user'] as Map<String, dynamic>?,
    );
  }

  // ============================================
  // TO JSON
  // ============================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'media_urls': mediaUrls,
      'media_count': mediaCount,
      'location': location,
      'is_pinned': isPinned,
      'allow_comments': allowComments,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'views_count': viewsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ============================================
  // COPY WITH
  // ============================================
  PostModel copyWith({
    String? caption,
    String? location,
    bool? isPinned,
    bool? allowComments,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      caption: caption ?? this.caption,
      mediaUrls: mediaUrls,
      mediaCount: mediaCount,
      location: location ?? this.location,
      isPinned: isPinned ?? this.isPinned,
      allowComments: allowComments ?? this.allowComments,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      user: user,
    );
  }

  // ============================================
  // HELPERS
  // ============================================
  bool get isCarousel => mediaCount > 1;
  bool get hasLocation => location != null && location!.isNotEmpty;
  String get username => user?['username'] ?? '';
  String? get avatarUrl => user?['avatar_url'];
}
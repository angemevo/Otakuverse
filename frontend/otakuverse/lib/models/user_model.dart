class User {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  final List<String> favoriteAnimes;
  final List<String> favoriteGames;
  final bool emailVerified;
  final bool phoneVerified;
  final bool isActive;
  final bool isBanned;
  final DateTime? bannedUntil;
  final String? banReason;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.location,
    required this.favoriteAnimes,
    required this.favoriteGames,
    required this.emailVerified,
    required this.phoneVerified,
    required this.isActive,
    required this.isBanned,
    this.bannedUntil,
    this.banReason,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      location: json['location'],
      favoriteAnimes: List<String>.from(json['favorite_animes'] ?? []),
      favoriteGames: List<String>.from(json['favorite_games'] ?? []),
      emailVerified: json['email_verified'] ?? false,
      phoneVerified: json['phone_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      isBanned: json['is_banned'] ?? false,
      bannedUntil: json['banned_until'] != null
          ? DateTime.tryParse(json['banned_until'])
          : null,
      banReason: json['ban_reason'],
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'location': location,
      'favorite_animes': favoriteAnimes,
      'favorite_games': favoriteGames,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'is_active': isActive,
      'is_banned': isBanned,
      'banned_until': bannedUntil?.toIso8601String(),
      'ban_reason': banReason,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
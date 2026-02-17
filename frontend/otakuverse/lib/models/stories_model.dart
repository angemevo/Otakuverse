class Story {
  final String username;
  final String avatarUrl;
  final List<String> imageUrls;
  bool seen;

  Story({
    required this.username,
    required this.avatarUrl,
    required this.imageUrls,
    this.seen = false,
  });
}


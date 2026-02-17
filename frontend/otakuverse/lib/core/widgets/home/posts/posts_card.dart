import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/home/posts/expandable_text.dart';
import 'package:otakuverse/core/widgets/home/posts/heart_animation.dart';
import 'package:otakuverse/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) widget.onLike?.call();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 6),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        color: AppColors.darkGray,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildMedia(),
          _buildActions(),
          _buildLikesCount(),
          _buildCaption(),
          if (widget.post.commentsCount > 0) _buildCommentsPreview(),
          _buildTimestamp(),
          // const SizedBox(height: 8),
          // Divider(color: Colors.grey[900], thickness: 1),
        ],
      ),
    );
  }

  // ============================================
  // HEADER (avatar + username + menu)
  // ============================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[800],
            backgroundImage: widget.post.avatarUrl != null
                ? NetworkImage(widget.post.avatarUrl!)
                : null,
            child: widget.post.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 18)
                : null,
          ),

          const SizedBox(width: 10),

          // Username + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (widget.post.isPinned) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.push_pin,
                        color: Color(0xFF6C63FF),
                        size: 14,
                      ),
                    ],
                  ],
                ),
                if (widget.post.hasLocation)
                  Text(
                    widget.post.location!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Menu
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () => _showPostMenu(context),
          ),
        ],
      ),
    );
  }

  // ============================================
  // MEDIA (image simple ou carrousel)
  // ============================================

  Widget _buildMedia() {
    return GestureDetector(
      onDoubleTap: _toggleLike,
      child: Stack(
        children: [
          // Images
          AspectRatio(
            aspectRatio: 1,
            child: widget.post.isCarousel
                ? _buildCarousel()
                : _buildSingleImage(widget.post.mediaUrls.first),
          ),

          // Indicateur carrousel (position)
          if (widget.post.isCarousel)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1}/${widget.post.mediaCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

          // Animation coeur sur double tap
          if (_isLiked)
            const Positioned.fill(
              child: HeartAnimation(),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey[900],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildCarousel() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.post.mediaUrls.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (_, i) => _buildSingleImage(widget.post.mediaUrls[i]),
        ),

        // Dots en bas
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.post.mediaUrls.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == i ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? AppColors.crimsonRed
                      : Colors.white54,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // ACTIONS (like, comment, share, save)
  // ============================================

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Like
          IconButton(
            onPressed: _toggleLike,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(_isLiked),
                color: _isLiked ? Colors.red : Colors.white,
                size: 26,
              ),
            ),
          ),

          // Commentaire
          IconButton(
            onPressed: widget.onComment,
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
          ),

          // Partage
          IconButton(
            onPressed: widget.onShare,
            icon: const Icon(Icons.send_outlined, color: Colors.white, size: 24),
          ),

          const Spacer(),

          // Sauvegarder
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  // ============================================
  // COMPTEUR DE LIKES
  // ============================================

  Widget _buildLikesCount() {
    final count = widget.post.likesCount + (_isLiked ? 1 : 0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Text(
        '$count j\'aime',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================
  // CAPTION
  // ============================================

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpandableText(
        username: widget.post.username,
        caption: widget.post.caption,
      ),
    );
  }

  // ============================================
  // APERÇU COMMENTAIRES
  // ============================================

  Widget _buildCommentsPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: GestureDetector(
        onTap: widget.onComment,
        child: Text(
          'Voir les ${widget.post.commentsCount} commentaires',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    );
  }

  // ============================================
  // TIMESTAMP
  // ============================================

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        _formatDate(widget.post.createdAt),
        style: TextStyle(color: Colors.grey[600], fontSize: 11),
      ),
    );
  }

  // ============================================
  // MENU CONTEXTUEL
  // ============================================

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _menuItem(Icons.bookmark_border, 'Sauvegarder', () {}),
          _menuItem(Icons.person_outline, 'Voir le profil', () {}),
          _menuItem(Icons.flag_outlined, 'Signaler', () {}, color: Colors.red),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(label, style: TextStyle(color: color ?? Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return '${date.day}/${date.month}/${date.year}';
  }
}
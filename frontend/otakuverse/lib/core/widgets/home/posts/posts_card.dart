// core/widgets/home/posts/posts_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/home/posts/expandable_text.dart';
import 'package:otakuverse/core/widgets/home/posts/heart_animation.dart';
import 'package:otakuverse/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onProfileTap;

  const PostCard({
    super.key,
    required this.post,
    this.isLiked = false,
    this.isSaved = false,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onDelete,
    this.onReport,
    this.onProfileTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late bool _isLiked;
  late bool _isSaved;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  bool _showHeartAnimation = false;
  
  // Dimensions adaptatives
  double? _imageAspectRatio;
  bool _isLoadingImage = true;
  
  // Vidéo
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;
  bool _isVideoMuted = true;
  
  // Animations
  late AnimationController _likeAnimationController;
  late AnimationController _saveAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _saveScaleAnimation;
  
  // Visibilité
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _isSaved = widget.isSaved;
    
    // Animations
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _saveScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _saveAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _loadImageDimensions();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      setState(() => _isLiked = widget.isLiked);
    }
    if (oldWidget.isSaved != widget.isSaved) {
      setState(() => _isSaved = widget.isSaved);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    _likeAnimationController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGER DIMENSIONS IMAGE
  // ============================================
  Future<void> _loadImageDimensions() async {
    if (widget.post.mediaUrls.isEmpty) {
      setState(() => _isLoadingImage = false);
      return;
    }

    try {
      final imageUrl = widget.post.mediaUrls.first;
      
      // Vérifier si c'est une vidéo
      if (_isVideoUrl(imageUrl)) {
        await _initializeVideo(imageUrl);
        return;
      }
      
      final imageProvider = CachedNetworkImageProvider(imageUrl);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      
      imageStream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          final width = info.image.width.toDouble();
          final height = info.image.height.toDouble();
          
          if (mounted) {
            setState(() {
              _imageAspectRatio = width / height;
              _isLoadingImage = false;
            });
          }
        }, onError: (exception, stackTrace) {
          if (mounted) {
            setState(() {
              _imageAspectRatio = 1.0;
              _isLoadingImage = false;
            });
          }
        }),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageAspectRatio = 1.0;
          _isLoadingImage = false;
        });
      }
    }
  }

  // ============================================
  // INITIALISER VIDÉO
  // ============================================
  bool _isVideoUrl(String url) {
    return url.toLowerCase().endsWith('.mp4') ||
           url.toLowerCase().endsWith('.mov') ||
           url.toLowerCase().endsWith('.avi');
  }

  Future<void> _initializeVideo(String url) async {
    _videoController = VideoPlayerController.network(url);
    
    try {
      await _videoController!.initialize();
      
      if (mounted) {
        setState(() {
          _imageAspectRatio = _videoController!.value.aspectRatio;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageAspectRatio = 1.0;
          _isLoadingImage = false;
        });
      }
    }
  }

  void _toggleVideoPlayback() {
    if (_videoController == null) return;
    
    setState(() {
      if (_isVideoPlaying) {
        _videoController!.pause();
        _isVideoPlaying = false;
      } else {
        _videoController!.play();
        _isVideoPlaying = true;
      }
    });
  }

  void _toggleMute() {
    if (_videoController == null) return;
    
    setState(() {
      _isVideoMuted = !_isVideoMuted;
      _videoController!.setVolume(_isVideoMuted ? 0 : 1);
    });
  }

  // ============================================
  // INTERACTIONS
  // ============================================
  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    
    widget.onLike?.call();
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    
    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });
    
    widget.onSave?.call();
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _showHeartAnimation = true;
      });
      
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
      
      widget.onLike?.call();
      
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() => _showHeartAnimation = false);
        }
      });
    }
  }

  void _handleShare() async {
    final result = await Share.share(
      'Regarde ce post de ${widget.post.displayNameOrUsername} sur Otakuverse !\n\n${widget.post.caption}',
      subject: 'Post Otakuverse',
    );
    
    if (result.status == ShareResultStatus.success) {
      widget.onShare?.call();
    }
  }

  void _openImageFullscreen(String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullscreenImageViewer(
              imageUrl: imageUrl,
              postId: widget.post.id,
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // BUILD
  // ============================================
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('post-${widget.post.id}'),
      onVisibilityChanged: (info) {
        _isVisible = info.visibleFraction > 0.5;
        
        // Auto-play vidéo si visible
        if (_videoController != null && _videoController!.value.isInitialized) {
          if (_isVisible && !_isVideoPlaying) {
            _videoController!.play();
            setState(() => _isVideoPlaying = true);
          } else if (!_isVisible && _isVideoPlaying) {
            _videoController!.pause();
            setState(() => _isVideoPlaying = false);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.darkGray,
          border: Border.all(
            color: AppColors.mediumGray.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
             if (widget.post.mediaUrls.isNotEmpty) _buildMedia(),
          
            // ✅ Si pas de media, ajouter un peu d'espace
            if (widget.post.mediaUrls.isEmpty) const SizedBox(height: 8),
            _buildActions(),
            _buildLikesCount(),
            if (widget.post.caption.isNotEmpty) 
              _buildCaption()
            else
              const SizedBox(height: 8),
            
            if (widget.post.commentsCount > 0) _buildCommentsPreview(),
            _buildTimestamp(),
            const SizedBox(height: 12),
            ],
        ),
      ),
    );
  }

  // ============================================
  // HEADER
  // ============================================
  Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        // ✅ Avatar SANS Hero animation
        GestureDetector(
          onTap: widget.onProfileTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.crimsonRed.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: widget.post.avatarUrl != null && 
                     widget.post.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.post.avatarUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildAvatarShimmer(),
                      errorWidget: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        ),

        const SizedBox(width: 12),

          // Nom + location
          Expanded(
            child: GestureDetector(
              onTap: widget.onProfileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.post.displayNameOrUsername,
                          style: GoogleFonts.inter(
                            color: AppColors.pureWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.post.isPinned) ...[
                        const SizedBox(width: 6),
                        const HeroIcon(
                          HeroIcons.mapPin,
                          size: 14,
                          color: AppColors.crimsonRed,
                          style: HeroIconStyle.solid,
                        ),
                      ],
                    ],
                  ),
                  if (widget.post.hasLocation)
                    Row(
                      children: [
                        const HeroIcon(
                          HeroIcons.mapPin,
                          size: 12,
                          color: AppColors.mediumGray,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.post.location!,
                            style: GoogleFonts.inter(
                              color: AppColors.mediumGray,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Menu
          IconButton(
            icon: const HeroIcon(
              HeroIcons.ellipsisHorizontal,
              color: AppColors.pureWhite,
            ),
            onPressed: () => _showPostMenu(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.mediumGray,
      highlightColor: AppColors.lightGray,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.mediumGray,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.mediumGray,
        shape: BoxShape.circle,
      ),
      child: const HeroIcon(
        HeroIcons.user,
        color: AppColors.pureWhite,
        size: 24,
      ),
    );
  }

  // ============================================
  // MEDIA
  // ============================================
  Widget _buildMedia() {
    return GestureDetector(
      // ✅ CHANGÉ : Tap simple pour fullscreen au lieu de long-press
      onTap: () {
        // Si c'est une image simple (pas carrousel, pas vidéo)
        if (!widget.post.isCarousel && 
            widget.post.mediaUrls.isNotEmpty &&
            !_isVideoUrl(widget.post.mediaUrls.first)) {
          _openImageFullscreen(widget.post.mediaUrls.first);
        }
      },
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        children: [
          _isLoadingImage
              ? _buildLoadingPlaceholder()
              : _buildAdaptiveMedia(),
          
          // Indicateur carrousel
          if (widget.post.isCarousel)
            Positioned(
              top: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HeroIcon(
                          HeroIcons.photo,
                          size: 14,
                          color: AppColors.pureWhite,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentPage + 1}/${widget.post.mediaCount}',
                          style: GoogleFonts.inter(
                            color: AppColors.pureWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Contrôles vidéo
          if (_videoController != null && _videoController!.value.isInitialized)
            _buildVideoControls(),
          
          // Animation cœur
          if (_showHeartAnimation)
            const Positioned.fill(
              child: HeartAnimation(),
            ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveMedia() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final maxHeight = screenHeight * 0.7;
    final minHeight = screenWidth * 0.6;

    if (_imageAspectRatio != null) {
      final idealHeight = screenWidth / _imageAspectRatio!;
      final clampedHeight = idealHeight.clamp(minHeight, maxHeight);
      
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(0),
          bottom: Radius.circular(0),
        ),
        child: SizedBox(
          width: screenWidth,
          height: clampedHeight,
          child: widget.post.isCarousel
              ? _buildCarousel()
              : _videoController != null
                  ? _buildVideoPlayer()
                  : _buildSingleImage(widget.post.mediaUrls.first),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(0),
        bottom: Radius.circular(0),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: widget.post.isCarousel
            ? _buildCarousel()
            : _videoController != null
                ? _buildVideoPlayer()
                : _buildSingleImage(widget.post.mediaUrls.first),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return AspectRatio(
      aspectRatio: 1,
      child: Shimmer.fromColors(
        baseColor: AppColors.darkGray,
        highlightColor: AppColors.mediumGray,
        child: Container(
          color: AppColors.darkGray,
        ),
      ),
    );
  }

  Widget _buildSingleImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.darkGray,
        highlightColor: AppColors.mediumGray,
        child: Container(color: AppColors.darkGray),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.darkGray,
        child: const Center(
          child: HeroIcon(
            HeroIcons.exclamationTriangle,
            color: AppColors.mediumGray,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayer(_videoController!),
        
        // Overlay play/pause
        if (!_isVideoPlaying)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: HeroIcon(
                HeroIcons.play,
                size: 64,
                color: AppColors.pureWhite,
                style: HeroIconStyle.solid,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoControls() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Play/Pause
          GestureDetector(
            onTap: _toggleVideoPlayback,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: HeroIcon(
                    _isVideoPlaying ? HeroIcons.pause : HeroIcons.play,
                    size: 20,
                    color: AppColors.pureWhite,
                    style: HeroIconStyle.solid,
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Mute/Unmute
          GestureDetector(
            onTap: _toggleMute,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: HeroIcon(
                    _isVideoMuted 
                        ? HeroIcons.speakerXMark 
                        : HeroIcons.speakerWave,
                    size: 20,
                    color: AppColors.pureWhite,
                    style: HeroIconStyle.solid,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.post.mediaUrls.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (_, i) {
            final url = widget.post.mediaUrls[i];
            
            // ✅ AJOUT : Tap sur chaque image du carrousel
            return GestureDetector(
              onTap: () {
                if (!_isVideoUrl(url)) {
                  _openImageFullscreen(url);
                }
              },
              child: _isVideoUrl(url)
                  ? _buildVideoPlayer()
                  : _buildSingleImage(url),
            );
          },
        ),
        
        // Indicateurs
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.post.mediaUrls.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? AppColors.crimsonRed
                      : AppColors.pureWhite.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // ============================================
  // ACTIONS
  // ============================================
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Like avec animation
          ScaleTransition(
            scale: _likeScaleAnimation,
            child: IconButton(
              onPressed: _toggleLike,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: HeroIcon(
                  _isLiked ? HeroIcons.heart : HeroIcons.heart,
                  key: ValueKey(_isLiked),
                  color: _isLiked ? AppColors.crimsonRed : AppColors.pureWhite,
                  size: 28,
                  style: _isLiked ? HeroIconStyle.solid : HeroIconStyle.outline,
                ),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: _isLiked ? 'Ne plus aimer' : 'J\'aime',
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Comment
          IconButton(
            onPressed: widget.onComment,
            icon: const HeroIcon(
              HeroIcons.chatBubbleOvalLeft,
              color: AppColors.pureWhite,
              size: 28,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Commenter',
          ),
          
          const SizedBox(width: 16),
          
          // Share
          IconButton(
            onPressed: _handleShare,
            icon: const HeroIcon(
              HeroIcons.paperAirplane,
              color: AppColors.pureWhite,
              size: 28,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Partager',
          ),
          
          const Spacer(),
          
          // Stats
          _buildStatsButton(),
          
          const SizedBox(width: 8),
          
          // Save avec animation
          ScaleTransition(
            scale: _saveScaleAnimation,
            child: IconButton(
              onPressed: _toggleSave,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: HeroIcon(
                  _isSaved ? HeroIcons.bookmark : HeroIcons.bookmark,
                  key: ValueKey(_isSaved),
                  color: _isSaved ? AppColors.crimsonRed : AppColors.pureWhite,
                  size: 28,
                  style: _isSaved ? HeroIconStyle.solid : HeroIconStyle.outline,
                ),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: _isSaved ? 'Retirer des favoris' : 'Sauvegarder',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON STATISTIQUES
  // ============================================
  Widget _buildStatsButton() {
    final totalEngagement = widget.post.likesCount + 
                           widget.post.commentsCount + 
                           (widget.post.sharesCount ?? 0);
    
    if (totalEngagement == 0) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: () => _showStatsBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.mediumGray.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.mediumGray.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeroIcon(
              HeroIcons.chartBar,
              size: 16,
              color: AppColors.lightGray,
            ),
            const SizedBox(width: 6),
            Text(
              _formatNumber(totalEngagement),
              style: GoogleFonts.inter(
                color: AppColors.lightGray,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // COMPTEUR DE LIKES AMÉLIORÉ
  // ============================================
  Widget _buildLikesCount() {
    final count = widget.post.likesCount;
    if (count == 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () => _showLikesBottomSheet(),
        child: Row(
          children: [
            // Avatars empilés (si disponibles)
            if (widget.post.likedByUsers != null && 
                widget.post.likedByUsers!.isNotEmpty)
              _buildLikersAvatars(),
            
            const SizedBox(width: 8),
            
            // Texte
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _formatNumber(count),
                      style: GoogleFonts.inter(
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: count == 1 ? ' j\'aime' : ' j\'aimes',
                      style: GoogleFonts.inter(
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 4),
            
            const HeroIcon(
              HeroIcons.chevronRight,
              size: 14,
              color: AppColors.mediumGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikersAvatars() {
    final likers = widget.post.likedByUsers!.take(3).toList();
    
    return SizedBox(
      height: 24,
      width: (likers.length * 16.0) + 8,
      child: Stack(
        children: List.generate(
          likers.length,
          (i) => Positioned(
            left: i * 16.0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.darkGray,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: likers[i].avatarUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.mediumGray,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.mediumGray,
                    child: const HeroIcon(
                      HeroIcons.user,
                      size: 12,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // CAPTION AMÉLIORÉE
  // ============================================
  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpandableText(
            username: widget.post.displayNameOrUsername,
            caption: widget.post.caption,
          ),
          
          // Hashtags
          if (widget.post.hashtags != null && widget.post.hashtags!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: widget.post.hashtags!.map((tag) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to hashtag page
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.crimsonRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.crimsonRed.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.inter(
                          color: AppColors.crimsonRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // APERÇU COMMENTAIRES AMÉLIORÉ
  // ============================================
  Widget _buildCommentsPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: widget.onComment,
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.post.commentsCount == 1
                    ? 'Voir le commentaire'
                    : 'Voir les ${_formatNumber(widget.post.commentsCount)} commentaires',
                style: GoogleFonts.inter(
                  color: AppColors.mediumGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const HeroIcon(
              HeroIcons.chevronRight,
              size: 14,
              color: AppColors.mediumGray,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // TIMESTAMP AMÉLIORÉ
  // ============================================
  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const HeroIcon(
            HeroIcons.clock,
            size: 12,
            color: AppColors.mediumGray,
          ),
          const SizedBox(width: 6),
          Text(
            _formatDate(widget.post.createdAt),
            style: GoogleFonts.inter(
              color: AppColors.mediumGray,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          // Modifié
          if (widget.post.isEdited) ...[
            const SizedBox(width: 8),
            Text(
              '• modifié',
              style: GoogleFonts.inter(
                color: AppColors.mediumGray,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================
  // MENU CONTEXTUEL AMÉLIORÉ
  // ============================================
  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkGray.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: AppColors.mediumGray.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Actions
                _menuItem(
                  HeroIcons.bookmark,
                  _isSaved ? 'Retirer des favoris' : 'Sauvegarder',
                  _toggleSave,
                ),
                
                _menuItem(
                  HeroIcons.userCircle,
                  'Voir le profil',
                  widget.onProfileTap ?? () {},
                ),
                
                _menuItem(
                  HeroIcons.link,
                  'Copier le lien',
                  _copyLink,
                ),
                
                _menuItem(
                  HeroIcons.share,
                  'Partager vers...',
                  _handleShare,
                ),
                
                _menuItem(
                  HeroIcons.qrCode,
                  'Afficher le QR Code',
                  _showQRCode,
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: AppColors.mediumGray, height: 1),
                ),
                
                _menuItem(
                  HeroIcons.eyeSlash,
                  'Masquer ce post',
                  () {},
                ),
                
                if (widget.onDelete != null)
                  _menuItem(
                    HeroIcons.trash,
                    'Supprimer',
                    widget.onDelete!,
                    color: AppColors.errorRed,
                  ),
                
                if (widget.onReport != null)
                  _menuItem(
                    HeroIcons.flag,
                    'Signaler',
                    widget.onReport!,
                    color: AppColors.errorRed,
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    HeroIcons icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: HeroIcon(
        icon,
        color: color ?? AppColors.pureWhite,
        size: 24,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: color ?? AppColors.pureWhite,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const HeroIcon(
        HeroIcons.chevronRight,
        size: 16,
        color: AppColors.mediumGray,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  // ============================================
  // BOTTOM SHEET STATISTIQUES
  // ============================================
  void _showStatsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: AppColors.darkGray.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Titre
                Text(
                  'Statistiques du post',
                  style: GoogleFonts.poppins(
                    color: AppColors.pureWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats cards
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildStatCard(
                        HeroIcons.heart,
                        'J\'aimes',
                        widget.post.likesCount,
                        AppColors.crimsonRed,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        HeroIcons.chatBubbleOvalLeft,
                        'Commentaires',
                        widget.post.commentsCount,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        HeroIcons.paperAirplane,
                        'Partages',
                        widget.post.sharesCount ?? 0,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        HeroIcons.eye,
                        'Vues',
                        widget.post.viewsCount ?? 0,
                        Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        HeroIcons.bookmark,
                        'Sauvegardes',
                        widget.post.savesCount ?? 0,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    HeroIcons icon,
    String label,
    int count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HeroIcon(
              icon,
              color: color,
              size: 24,
              style: HeroIconStyle.solid,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.mediumGray,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatNumber(count),
                  style: GoogleFonts.inter(
                    color: AppColors.pureWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const HeroIcon(
            HeroIcons.chevronRight,
            size: 20,
            color: AppColors.mediumGray,
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOTTOM SHEET LIKES
  // ============================================
  void _showLikesBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: AppColors.darkGray.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  '${_formatNumber(widget.post.likesCount)} j\'aime${widget.post.likesCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    color: AppColors.pureWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.post.likedByUsers?.length ?? 0,
                    itemBuilder: (_, index) {
                      final user = widget.post.likedByUsers![index];
                      return _buildUserListTile(user);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserListTile(dynamic user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: ClipOval(
        child: CachedNetworkImage(
          imageUrl: user.avatarUrl ?? '',
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildAvatarShimmer(),
          errorWidget: (_, __, ___) => _buildDefaultAvatar(),
        ),
      ),
      title: Text(
        user.displayName ?? user.username,
        style: GoogleFonts.inter(
          color: AppColors.pureWhite,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: user.bio != null
          ? Text(
              user.bio,
              style: GoogleFonts.inter(
                color: AppColors.mediumGray,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: _buildFollowButton(user),
    );
  }

  Widget _buildFollowButton(dynamic user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.crimsonRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Suivre',
        style: GoogleFonts.inter(
          color: AppColors.pureWhite,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS SUPPLÉMENTAIRES
  // ============================================
  void _copyLink() {
    // Copy link to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const HeroIcon(
              HeroIcons.check,
              color: AppColors.pureWhite,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text('Lien copié dans le presse-papier'),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showQRCode() {
    // Show QR Code dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'QR Code du post',
          style: GoogleFonts.poppins(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('QR Code here'),
          ),
        ),
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inSeconds < 60) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    if (diff.inDays < 30) return 'il y a ${(diff.inDays / 7).floor()} sem';
    if (diff.inDays < 365) return 'il y a ${(diff.inDays / 30).floor()} mois';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}

// ============================================
// FULLSCREEN IMAGE VIEWER (CORRIGÉ)
// ============================================
class _FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String postId;

  const _FullscreenImageViewer({
    required this.imageUrl,
    required this.postId,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> 
    with SingleTickerProviderStateMixin {
  
  late PhotoViewController _photoViewController;
  late AnimationController _overlayController;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );

    // Auto-hide overlay après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showOverlay) {
        _toggleOverlay();
      }
    });
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
    
    if (_showOverlay) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }
  }

  Future<void> _downloadImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            HeroIcon(
              HeroIcons.arrowDownTray,
              color: AppColors.pureWhite,
              size: 20,
            ),
            SizedBox(width: 12),
            Text('Téléchargement en cours...'),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            // Image zoomable
            PhotoView(
              imageProvider: CachedNetworkImageProvider(widget.imageUrl),
              controller: _photoViewController,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              loadingBuilder: (context, event) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                      color: AppColors.crimsonRed,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event == null
                          ? 'Chargement...'
                          : '${((event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1)) * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        color: AppColors.pureWhite,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              errorBuilder: (context, error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HeroIcon(
                      HeroIcons.exclamationTriangle,
                      color: AppColors.errorRed,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: GoogleFonts.inter(
                        color: AppColors.pureWhite,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ CORRECTION : Positioned AVANT FadeTransition
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _overlayController,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const HeroIcon(
                              HeroIcons.xMark,
                              color: AppColors.pureWhite,
                              size: 20,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const HeroIcon(
                              HeroIcons.share,
                              color: AppColors.pureWhite,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            Share.share('Regarde cette image sur Otakuverse!');
                          },
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const HeroIcon(
                              HeroIcons.arrowDownTray,
                              color: AppColors.pureWhite,
                              size: 20,
                            ),
                          ),
                          onPressed: _downloadImage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ✅ CORRECTION : Positioned AVANT FadeTransition
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _overlayController,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const HeroIcon(
                        HeroIcons.informationCircle,
                        color: AppColors.pureWhite,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pincez pour zoomer • Tap pour masquer',
                          style: GoogleFonts.inter(
                            color: AppColors.pureWhite,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
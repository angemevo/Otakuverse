// screens/stories/story_viewer_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/smart_image.dart';
import 'package:otakuverse/models/stories/stories_model.dart';
import 'package:otakuverse/services/stories_service.dart';
import 'package:video_player/video_player.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final bool isMyStory;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.isMyStory = false,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;
  late AnimationController _sheetAnimationController;
  late Animation<Offset> _sheetSlideAnimation;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _isPaused = false;

  // Viewers sheet
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  List<StoryViewerModel> _viewers = [];
  bool _showViewers = false;

  // Reply
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();

  // Like
  bool _isLiked = false;
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Progress controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Sheet animation controller
    _sheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _sheetSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sheetAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _loadStory();
    _progressController.addStatusListener(_onProgressComplete);
    
    // Pause when keyboard appears
    _replyFocus.addListener(() {
      if (_replyFocus.hasFocus) {
        _pause();
      } else {
        _resume();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _sheetAnimationController.dispose();
    _videoController?.dispose();
    _replyController.dispose();
    _replyFocus.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isPaused) {
      _nextStory();
    }
  }

  Future<void> _loadStory() async {
    setState(() => _isLoading = true);

    final story = widget.stories[_currentIndex];

    if (!widget.isMyStory) {
      await StoriesService().viewStory(story.id);
    }

    if (widget.isMyStory) {
      _loadViewers(story.id);
    }

    if (story.isVideo) {
      await _loadVideo(story.mediaUrl);
    } else {
      setState(() => _isLoading = false);
      _progressController.forward(from: 0);
    }
  }

  Future<void> _loadVideo(String url) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url);

    try {
      await _videoController!.initialize();
      await _videoController!.play();

      _progressController.duration = _videoController!.value.duration;
      _progressController.forward(from: 0);

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading video: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadViewers(String storyId) async {
    final result = await StoriesService().getStoryViewers(storyId);
    if (result['success'] != null) {
      setState(() {
        _viewers = result['success'] as List<StoryViewerModel>;
      });
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _closeViewers();
      });
      _progressController.reset();
      _loadStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _closeViewers();
      });
      _progressController.reset();
      _loadStory();
    }
  }

  void _pause() {
    if (!_isPaused) {
      setState(() => _isPaused = true);
      _progressController.stop();
      _videoController?.pause();
    }
  }

  void _resume() {
    if (_isPaused) {
      setState(() => _isPaused = false);
      _progressController.forward();
      _videoController?.play();
    }
  }

  void _togglePause() {
    if (_isPaused) {
      _resume();
    } else {
      _pause();
    }
  }

  void _openViewers() {
    setState(() => _showViewers = true);
    _sheetAnimationController.forward();
    _pause();
  }

  void _closeViewers() {
    _sheetAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() => _showViewers = false);
        _resume();
      }
    });
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _showHeartAnimation = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _showHeartAnimation = false);
        });
      }
    });

    final story = widget.stories[_currentIndex];
    await StoriesService().toggleLikeStory(story.id);
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      _toggleLike();
    }
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final story = widget.stories[_currentIndex];
    
    _replyController.clear();
    _replyFocus.unfocus();

    final result = await StoriesService().replyToStory(story.id, text);

    if (!mounted) return;

    if (result['success'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Réponse envoyée'),
          backgroundColor: AppColors.successGreen,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['error']}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _repostStory() async {
    _pause();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'Partager cette story ?',
          style: GoogleFonts.poppins(color: AppColors.pureWhite),
        ),
        content: Text(
          'Elle sera ajoutée à vos stories',
          style: GoogleFonts.inter(color: AppColors.lightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(color: AppColors.mediumGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Partager',
              style: GoogleFonts.inter(color: AppColors.crimsonRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final story = widget.stories[_currentIndex];
      final result = await StoriesService().repostStory(story.id);

      if (!mounted) return;

      if (result['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Story partagée'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error']}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }

    _resume();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          final tapX = details.globalPosition.dx;

          if (tapX < width / 3) {
            _previousStory();
          } else if (tapX > width * 2 / 3) {
            _nextStory();
          } else {
            _togglePause();
          }
        },
        onDoubleTap: _handleDoubleTap,
        onVerticalDragEnd: widget.isMyStory
            ? (details) {
                if (details.primaryVelocity! < -500) {
                  _openViewers();
                }
              }
            : null,
        child: Stack(
          children: [
            // Fond noir
            Container(color: AppColors.deepBlack),

            // Média
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: AppColors.crimsonRed,
                    )
                  : story.isVideo && _videoController != null
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : SmartImage(
                          imageUrl: story.mediaUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
            ),

            // Animation coeur
            if (_showHeartAnimation)
              Center(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.5, end: 1.2),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, double scale, __) {
                    return Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.crimsonRed,
                        size: 120,
                      ),
                    );
                  },
                ),
              ),

            // UI par-dessus
            SafeArea(
              child: Column(
                children: [
                  _buildProgressBars(),

                  // Header
                  _buildHeader(story),

                  const Spacer(),

                  // Compteur de vues
                  if (widget.isMyStory) _buildViewsCounter(story),

                  // Bottom bar
                  if (!widget.isMyStory) _buildBottomBar(),
                ],
              ),
            ),

            // Bouton fermer
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.pureWhite, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Sheet des viewers
            if (_showViewers) _buildViewersSheet(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BARRES DE PROGRESSION STYLÉES
  // ============================================
  Widget _buildProgressBars() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: List.generate(
          widget.stories.length,
          (index) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    final progress = index == _currentIndex
                        ? _progressController.value
                        : index < _currentIndex
                            ? 1.0
                            : 0.0;

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.crimsonRed,
                                AppColors.lightCrimson,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.crimsonRed.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ============================================
  // HEADER
  // ============================================
  Widget _buildHeader(StoryModel story) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ClipOval(
            child: story.avatarUrl != null && story.avatarUrl!.isNotEmpty
                ? SmartImage(
                    imageUrl: story.avatarUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 36,
                    height: 36,
                    color: AppColors.mediumGray,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.pureWhite,
                      size: 20,
                    ),
                  ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isMyStory ? 'Ma story' : story.displayNameOrUsername,
                  style: GoogleFonts.inter(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatTime(story.createdAt),
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // COMPTEUR DE VUES
  // ============================================
  Widget _buildViewsCounter(StoryModel story) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: _openViewers,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility,
                color: AppColors.pureWhite,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${story.viewsCount}',
                style: GoogleFonts.inter(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'vue${story.viewsCount > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  color: AppColors.pureWhite,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.pureWhite,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // BOTTOM BAR
  // ============================================
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _replyController,
                focusNode: _replyFocus,
                style: GoogleFonts.inter(
                  color: AppColors.pureWhite,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Envoyer un message...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _replyController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: AppColors.crimsonRed,
                            size: 20,
                          ),
                          onPressed: _sendReply,
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
                onSubmitted: (_) => _sendReply(),
              ),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: _toggleLike,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? AppColors.crimsonRed : AppColors.pureWhite,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: _repostStory,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.send_outlined,
                color: AppColors.pureWhite,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // VIEWERS SHEET
  // ============================================
  Widget _buildViewersSheet() {
    return SlideTransition(
      position: _sheetSlideAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        controller: _sheetController,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: AppColors.pureWhite,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_viewers.length} vue${_viewers.length > 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.pureWhite,
                        ),
                        onPressed: _closeViewers,
                      ),
                    ],
                  ),
                ),

                const Divider(color: AppColors.mediumGray, height: 1),

                Expanded(
                  child: _viewers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.visibility_off,
                                color: AppColors.mediumGray,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune vue pour le moment',
                                style: GoogleFonts.inter(
                                  color: AppColors.mediumGray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _viewers.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (_, index) {
                            final viewer = _viewers[index];
                            return ListTile(
                              leading: ClipOval(
                                child: viewer.avatarUrl != null &&
                                        viewer.avatarUrl!.isNotEmpty
                                    ? SmartImage(
                                        imageUrl: viewer.avatarUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 40,
                                        height: 40,
                                        color: AppColors.mediumGray,
                                        child: const Icon(
                                          Icons.person,
                                          color: AppColors.pureWhite,
                                          size: 20,
                                        ),
                                      ),
                              ),
                              title: Text(
                                viewer.displayNameOrUsername,
                                style: GoogleFonts.inter(
                                  color: AppColors.pureWhite,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                _formatTime(viewer.viewedAt),
                                style: GoogleFonts.inter(
                                  color: AppColors.mediumGray,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'maintenant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }
}
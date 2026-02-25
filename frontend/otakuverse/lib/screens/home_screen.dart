import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/constants/text_styles.dart';
import 'package:otakuverse/core/widgets/home/posts/posts_card.dart';
import 'package:otakuverse/core/widgets/home/stories/story_avatar.dart';
import 'package:otakuverse/models/post_model.dart';
import 'package:otakuverse/models/stories_model.dart';
import 'package:otakuverse/services/post_service.dart';
import 'package:otakuverse/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================
  // STATE
  // ============================================
  List<PostModel> _posts = [];
  Map<String, bool> _likedPosts = {};
  bool _isLoading = true;
  String? _errorMessage;
  List<StoryModel> _stories = [];

  // final List<Story> stories = [
  //   Story(
  //     username: 'Sh4dx',
  //     avatarUrl: 'https://i.pravatar.cc/150?img=1',
  //     imageUrls: [
  //       'https://picsum.photos/400/700?random=1',
  //       'https://picsum.photos/400/700?random=2',
  //     ],
  //   ),
  //   Story(
  //     username: 'Naruto_fan',
  //     avatarUrl: 'https://i.pravatar.cc/150?img=2',
  //     imageUrls: ['https://picsum.photos/400/700?random=3'],
  //   ),
  //   Story(
  //     username: 'OtakuKing',
  //     avatarUrl: 'https://i.pravatar.cc/150?img=3',
  //     imageUrls: [
  //       'https://picsum.photos/400/700?random=4',
  //       'https://picsum.photos/400/700?random=5',
  //       'https://picsum.photos/400/700?random=6',
  //     ],
  //     seen: true,
  //   ),
  // ];

  // ============================================
  // INIT
  // ============================================
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await StorageService().getUserData();
      final userId = userData?['id'];

      if (userId == null) {
        setState(() {
          _errorMessage = 'Utilisateur non connecté';
          _isLoading = false;
        });
        return;
      }

      final result = await PostsService().getPostsByUser(userId);

      if (result['success'] != null) {
        final posts = result['success'] as List<PostModel>;

        // Vérifie lesquels sont likés
        final Map<String, bool> likedMap = {};
        for (final post in posts) {
          final liked = await PostsService().hasLiked(post.id);
          likedMap[post.id] = liked['success'] ?? false;
        }

        setState(() {
          _posts = posts;
          _likedPosts = likedMap;
        });
      } else {
        setState(() => _errorMessage = result['error']);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================
  // LIKE
  // ============================================
  Future<void> _handleLike(String postId) async {
    final result = await PostsService().toggleLike(postId);

    if (result['success'] != null) {
      final isNowLiked = result['success']['liked'] as bool;
      setState(() {
        _likedPosts[postId] = isNowLiked;

        // Mise à jour optimiste du compteur
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = _posts[index].copyWith(
            likesCount: _posts[index].likesCount + (isNowLiked ? 1 : -1),
          );
        }
      });
    }
  }

  // ============================================
  // BUILD
  // ============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack,
        leading: Image.asset("assets/logo/otakuverse_logo.png"),
        title: Text('Otakuverse', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.crimsonRed,
          backgroundColor: AppColors.deepBlack,
          onRefresh: _loadPosts,
          child: CustomScrollView(
            slivers: [
              // Stories
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      return StoryAvatar(
                        story: _stories[index],
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // États
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.crimsonRed),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.mediumGray, size: 48),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, style: const TextStyle(color: AppColors.mediumGray)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadPosts,
                          child: const Text(
                            'Réessayer',
                            style: TextStyle(color: AppColors.crimsonRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add, color: AppColors.mediumGray, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Aucun post pour le moment',
                          style: TextStyle(color: AppColors.mediumGray),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PostCard(
                      post: _posts[index],
                      isLiked: _likedPosts[_posts[index].id] ?? false,
                      onLike: () => _handleLike(_posts[index].id),
                      onComment: () async {
                        await PostsService().incrementComment(_posts[index].id);
                      },
                    ),
                    childCount: _posts.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
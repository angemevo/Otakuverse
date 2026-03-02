import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/home/stories/stories_bar.dart';
import 'package:otakuverse/core/widgets/home/posts/posts_card.dart';
import 'package:otakuverse/models/post_model.dart';
import 'package:otakuverse/models/stories/stories_model.dart';
import 'package:otakuverse/screens/posts/create_post_screen.dart';
import 'package:otakuverse/services/post_service.dart';
import 'package:otakuverse/services/stories_service.dart';
import 'package:otakuverse/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true; 

  // Posts
  List<PostModel> _posts = [];
  Map<String, bool> _likedPosts = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  // Stories
  List<StoryModel> _myStories = [];
  Map<String, List<StoryModel>> _storiesByUser = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================
  // CHARGEMENT DES DONNÉES
  // ============================================
  Future<void> _loadData() async {
    await Future.wait([
      _loadUserData(),
      _loadPosts(),
      _loadStories(),
    ]);
  }

  Future<void> _loadUserData() async {
    final userData = await StorageService().getUserData();
    if (mounted) {
      setState(() => _currentUserId = userData?['id']);
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔵 === LOADING POSTS ===');
      
      final result = await PostsService().getAllPosts(limit: 20, page: 1);

      if (result['success'] != null) {
        final posts = result['success'] as List<PostModel>;
        
        print('✅ Loaded ${posts.length} posts');

        // Vérifier lesquels sont likés
        final Map<String, bool> likedMap = {};
        
        for (final post in posts) {
          try {
            final likedResult = await PostsService().hasLiked(post.id);
            
            if (likedResult.containsKey('success')) {
              final isLiked = likedResult['success'];
              
              if (isLiked is bool) {
                likedMap[post.id] = isLiked;
              } else if (isLiked is int) {
                likedMap[post.id] = isLiked == 1;
              } else if (isLiked is String) {
                likedMap[post.id] = isLiked.toLowerCase() == 'true';
              } else {
                likedMap[post.id] = false;
              }
            } else {
              likedMap[post.id] = false;
            }
          } catch (e) {
            print('❌ Error checking like for post ${post.id}: $e');
            likedMap[post.id] = false;
          }
        }

        if (mounted) {
          setState(() {
            _posts = posts;
            _likedPosts = likedMap;
          });
        }
        
        print('✅ Posts loaded successfully');
      } else {
        print('❌ Error in result: ${result['error']}');
        if (mounted) {
          setState(() => _errorMessage = result['error']);
        }
      }
    } catch (e, stackTrace) {
      print('❌ Fatal error loading posts: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStories() async {
    try {
      print('🔵 Loading stories...');

      final result = await StoriesService().getAllStories();

      if (result['success'] != null) {
        final stories = result['success'] as List<StoryModel>;
        
        print('✅ Loaded ${stories.length} stories');

        // Séparer mes stories et celles des autres
        final myStories = <StoryModel>[];
        final storiesByUser = <String, List<StoryModel>>{};

        for (final story in stories) {
          if (story.userId == _currentUserId) {
            myStories.add(story);
          } else {
            if (!storiesByUser.containsKey(story.userId)) {
              storiesByUser[story.userId] = [];
            }
            storiesByUser[story.userId]!.add(story);
          }
        }

        if (mounted) {
          setState(() {
            _myStories = myStories;
            _storiesByUser = storiesByUser;
          });
        }
      } else {
        print('⚠️ Error loading stories: ${result['error']}');
        if (mounted) {
          setState(() {
            _myStories = [];
            _storiesByUser = {};
          });
        }
      }
    } catch (e, stackTrace) {
      print('❌ Fatal error loading stories: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _myStories = [];
          _storiesByUser = {};
        });
      }
    }
  }

  // ============================================
  // GESTION DES LIKES
  // ============================================
  Future<void> _handleLike(int index) async {
    final post = _posts[index];
    final wasLiked = _likedPosts[post.id] ?? false;

    // Optimistic update
    setState(() {
      _likedPosts[post.id] = !wasLiked;
      _posts[index] = post.copyWith(
        likesCount: post.likesCount + (!wasLiked ? 1 : -1),
      );
    });

    try {
      await PostsService().toggleLike(post.id);
    } catch (e) {
      // Rollback si erreur
      if (mounted) {
        setState(() {
          _likedPosts[post.id] = wasLiked;
          _posts[index] = post.copyWith(
            likesCount: post.likesCount + (wasLiked ? 1 : -1),
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors du like'),
            backgroundColor: AppColors.errorRed,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ============================================
  // BUILD
  // ============================================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.crimsonRed,
        backgroundColor: AppColors.darkGray,
        child: CustomScrollView(
          slivers: [
            // ============================================
            // APPBAR STICKY
            // ============================================
            SliverAppBar(
              backgroundColor: AppColors.deepBlack,
              elevation: 0,
              pinned: true,
              floating: false,
              snap: false,
              title: Text(
                'Otakuverse',
                style: GoogleFonts.poppins(
                  color: AppColors.crimsonRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.add_box_outlined,
                    color: AppColors.pureWhite,
                    size: 28,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePostScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadPosts();
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ============================================
            // BARRE DE STORIES (disparaît au scroll)
            // ============================================
            if (_currentUserId != null)
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StoriesBar(
                      currentUserId: _currentUserId!,
                      myStories: _myStories,
                      storiesByUser: _storiesByUser,
                      onRefresh: _loadStories,
                    ),
                    // const Divider(
                    //   height: 1,
                    //   color: AppColors.mediumGray,
                    //   thickness: 1,
                    // ),
                  ],
                ),
              ),

            // ============================================
            // LOADING STATE
            // ============================================
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.crimsonRed,
                    strokeWidth: 3,
                  ),
                ),
              ),

            // ============================================
            // ERROR STATE
            // ============================================
            if (!_isLoading && _errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur',
                          style: GoogleFonts.poppins(
                            color: AppColors.pureWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            color: AppColors.mediumGray,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.crimsonRed,
                            foregroundColor: AppColors.pureWhite,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ============================================
            // EMPTY STATE
            // ============================================
            if (!_isLoading && _errorMessage == null && _posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        color: AppColors.mediumGray,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun post pour le moment',
                        style: GoogleFonts.poppins(
                          color: AppColors.pureWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sois le premier à partager quelque chose !',
                        style: GoogleFonts.inter(
                          color: AppColors.mediumGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreatePostScreen(),
                            ),
                          );
                          if (result == true) {
                            _loadPosts();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Créer un post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crimsonRed,
                          foregroundColor: AppColors.pureWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ============================================
            // LISTE DES POSTS
            // ============================================
            if (!_isLoading && _errorMessage == null && _posts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(top: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = _posts[index];
                      final isLiked = _likedPosts[post.id] ?? false;

                      return PostCard(
                        post: post,
                        isLiked: isLiked,
                        onLike: () => _handleLike(index),
                        onComment: () {
                          // TODO: Ouvrir les commentaires
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Commentaires à venir !'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        onShare: () {
                          // TODO: Partager
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Partage à venir !'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _posts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
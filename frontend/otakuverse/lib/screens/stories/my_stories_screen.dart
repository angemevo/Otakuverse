import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/smart_image.dart';
import 'package:otakuverse/models/stories/stories_model.dart';
import 'package:otakuverse/services/stories_service.dart';
import 'package:otakuverse/screens/stories/story_viewer_screen.dart';
import 'package:otakuverse/screens/stories/create_story_screen.dart';  // ✅ AJOUTER

class MyStoriesScreen extends StatefulWidget {
  const MyStoriesScreen({super.key});

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  List<StoryModel> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() => _isLoading = true);

    final result = await StoriesService().getMyStories();

    if (result['success'] != null) {
      setState(() {
        _stories = result['success'] as List<StoryModel>;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStory(String storyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'Supprimer cette story ?',
          style: GoogleFonts.poppins(color: AppColors.pureWhite),
        ),
        content: Text(
          'Cette action est irréversible',
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
              'Supprimer',
              style: GoogleFonts.inter(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await StoriesService().deleteStory(storyId);

      if (!mounted) return;

      if (result['success'] != null) {
        _loadStories();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Story supprimée'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack,
        elevation: 0,
        title: Text(
          'Mes stories',
          style: GoogleFonts.poppins(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // ✅ NOUVEAU : FloatingActionButton pour ajouter une story
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateStoryScreen(),
            ),
          );
          
          if (result == true) {
            _loadStories();
          }
        },
        backgroundColor: AppColors.crimsonRed,
        icon: const Icon(Icons.add, color: AppColors.pureWhite),
        label: Text(
          'Nouvelle story',
          style: GoogleFonts.inter(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.crimsonRed),
            )
          : _stories.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    return _buildStoryCard(story, index);
                  },
                ),
    );
  }

  // ✅ NOUVEAU : Empty state amélioré
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.crimsonRed.withOpacity(0.2),
                    AppColors.lightCrimson.withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.crimsonRed,
                size: 60,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Titre
            Text(
              'Aucune story active',
              style: GoogleFonts.poppins(
                color: AppColors.pureWhite,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Partage ton quotidien avec tes amis.\nTa story sera visible pendant 24h.',
              style: GoogleFonts.inter(
                color: AppColors.mediumGray,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // ✅ Bouton alternatif dans l'empty state
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateStoryScreen(),
                  ),
                );
                
                if (result == true) {
                  _loadStories();
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Créer ma première story'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crimsonRed,
                foregroundColor: AppColors.pureWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(StoryModel story, int index) {
    // ✅ NOUVEAU : Calculer le temps restant
    final timeRemaining = story.timeRemaining;
    final hoursLeft = timeRemaining.inHours;
    final minutesLeft = timeRemaining.inMinutes % 60;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewerScreen(
              stories: _stories,
              initialIndex: index,
              isMyStory: true,
            ),
          ),
        ).then((_) => _loadStories());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mediumGray.withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            // Image/Vidéo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: story.isImage
                  ? SmartImage(
                      imageUrl: story.mediaUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Stack(
                      children: [
                        SmartImage(
                          imageUrl: story.mediaUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: AppColors.pureWhite,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
            ),

            // Overlay sombre
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // ✅ NOUVEAU : Badge expiration en haut
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hoursLeft < 3 
                        ? AppColors.errorRed.withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: hoursLeft < 3 
                          ? AppColors.errorRed 
                          : AppColors.pureWhite,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hoursLeft > 0 
                          ? '${hoursLeft}h${minutesLeft > 0 ? ' ${minutesLeft}m' : ''}' 
                          : '${minutesLeft}m',
                      style: GoogleFonts.inter(
                        color: hoursLeft < 3 
                            ? AppColors.errorRed 
                            : AppColors.pureWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vues
                    Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: AppColors.pureWhite,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${story.viewsCount}',
                          style: GoogleFonts.inter(
                            color: AppColors.pureWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'vue${story.viewsCount > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            color: AppColors.pureWhite,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Temps
                    Text(
                      _formatTime(story.createdAt),
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bouton supprimer
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: AppColors.errorRed,
                    size: 20,
                  ),
                ),
                onPressed: () => _deleteStory(story.id),
              ),
            ),
          ],
        ),
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
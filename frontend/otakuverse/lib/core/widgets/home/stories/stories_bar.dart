// core/widgets/stories/stories_bar.dart

import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/home/stories/story_circle.dart';
import 'package:otakuverse/models/stories/stories_model.dart';
import 'package:otakuverse/screens/stories/create_story_screen.dart';
import 'package:otakuverse/screens/stories/my_stories_screen.dart';
import 'package:otakuverse/screens/stories/story_viewer_screen.dart';

class StoriesBar extends StatelessWidget {
  final String currentUserId;
  final List<StoryModel> myStories;
  final Map<String, List<StoryModel>> storiesByUser;
  final VoidCallback onRefresh;

  const StoriesBar({
    super.key,
    required this.currentUserId,
    required this.myStories,
    required this.storiesByUser,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      color: AppColors.deepBlack,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        children: [
          // Ma story en premier
          StoryCircle(
            userId: currentUserId,
            displayName: 'Ma story',
            avatarUrl: null, // Sera récupéré depuis le profil
            stories: myStories,
            isMyStory: true,
            onTap: () {
              if (myStories.isEmpty) {
                // Créer une story
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateStoryScreen(),
                  ),
                ).then((_) => onRefresh());
              } else {
                // Voir mes stories
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyStoriesScreen(),
                  ),
                ).then((_) => onRefresh());
              }
            },
          ),

          // Stories des autres users
          ...storiesByUser.entries.map((entry) {
            final userId = entry.key;
            final userStories = entry.value;

            if (userStories.isEmpty) return const SizedBox.shrink();

            final firstStory = userStories.first;

            return StoryCircle(
              userId: userId,
              displayName: firstStory.displayNameOrUsername,
              avatarUrl: firstStory.avatarUrl,
              stories: userStories,
              isViewed: false, // TODO: Track viewed stories
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryViewerScreen(
                      stories: userStories,
                      initialIndex: 0,
                      isMyStory: false,
                    ),
                  ),
                ).then((_) => onRefresh());
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
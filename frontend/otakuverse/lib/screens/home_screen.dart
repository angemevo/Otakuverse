import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/constants/text_styles.dart';
import 'package:otakuverse/core/widgets/home/posts/fictive_data.dart';
import 'package:otakuverse/core/widgets/home/posts/posts_card.dart';
import 'package:otakuverse/core/widgets/home/stories/story_avatar.dart';
import 'package:otakuverse/models/stories_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================
  // DONNÉES FICTIVES
  // ============================================

  final List<Story> stories = [
    Story(
      username: 'Sh4dx',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      imageUrls: [
        'https://picsum.photos/400/700?random=1',
        'https://picsum.photos/400/700?random=2',
      ],
    ),
    Story(
      username: 'Naruto_fan',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      imageUrls: ['https://picsum.photos/400/700?random=3'],
    ),
    Story(
      username: 'OtakuKing',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      imageUrls: [
        'https://picsum.photos/400/700?random=4',
        'https://picsum.photos/400/700?random=5',
        'https://picsum.photos/400/700?random=6',
      ],
      seen: true,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack,
        leading: Image.asset("assets/logo/otakuverse_logo.png"),
        title: Text(
          'Otakuverse',
          style: AppTextStyles.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Stories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    return StoryAvatar(
                      story: stories[index],
                      onTap: () {},
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Posts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCard(
                  post: mockPosts[index],
                  onLike: () {},
                  onComment: () {},
                ),
                childCount: mockPosts.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
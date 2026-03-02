import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/smart_image.dart';
import 'package:otakuverse/models/stories/stories_model.dart';

class StoryCircle extends StatelessWidget {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final List<StoryModel> stories;
  final bool isViewed;
  final bool isMyStory;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.stories,
    this.isViewed = false,
    this.isMyStory = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(  // ✅ Taille fixe pour éviter overflow
          width: 75,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Avatar avec Stack pour le badge
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  children: [
                    // Avatar avec bordure
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isViewed
                            ? null
                            : const LinearGradient(
                                colors: [
                                  AppColors.crimsonRed,
                                  AppColors.lightCrimson,
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                        border: isViewed
                            ? Border.all(color: AppColors.mediumGray, width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.deepBlack,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: avatarUrl != null && avatarUrl!.isNotEmpty
                              ? SmartImage(
                                  imageUrl: avatarUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 64,
                                  height: 64,
                                  color: AppColors.mediumGray,
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.pureWhite,
                                    size: 32,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // ✅ Badge "+" DANS LE STACK
                    if (isMyStory && stories.isEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.crimsonRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.deepBlack,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.pureWhite,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Nom d'utilisateur
              Text(
                isMyStory ? 'Ma story' : displayName,
                style: GoogleFonts.inter(
                  color: AppColors.pureWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
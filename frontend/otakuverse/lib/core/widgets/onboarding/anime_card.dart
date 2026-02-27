import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';

class AnimeCard extends StatelessWidget {
  final String name;
  final String genre;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimeCard({
    super.key,
    required this.name,
    required this.genre,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.crimsonRed : AppColors.border,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.crimsonWithOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image (placeholder)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkGray,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      image: DecorationImage(
                        image: AssetImage('assets/images/animes/$imagePath'),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {
                          // Placeholder si image manquante
                        },
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.movie,
                        size: 48,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ),

                // Info
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? AppColors.crimsonRed : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        genre,
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Checkmark
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.crimsonRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
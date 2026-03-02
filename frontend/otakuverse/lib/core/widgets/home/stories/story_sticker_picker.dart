import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';

class StoryStickerPicker extends StatelessWidget {
  final Function(String) onStickerSelected;

  const StoryStickerPicker({
    super.key,
    required this.onStickerSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Catégories de stickers
    final categories = {
      'Émotions': [
        '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
        '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
        '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
        '🤪', '🤨', '🧐', '🤓', '😎', '🥳', '😏', '😒',
        '😞', '😔', '😟', '😕', '🙁', '😣', '😖', '😫',
        '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬',
      ],
      'Gestes': [
        '👍', '👎', '👊', '✊', '🤛', '🤜', '🤞', '✌️',
        '🤟', '🤘', '👌', '🤌', '🤏', '👈', '👉', '👆',
        '👇', '☝️', '✋', '🤚', '🖐', '🖖', '👋', '🤙',
        '💪', '🦾', '🖕', '✍️', '🙏', '🦶', '🦵', '🦿',
      ],
      'Cœurs': [
        '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
        '🤎', '💔', '❤️‍🔥', '❤️‍🩹', '💕', '💞', '💓', '💗',
        '💖', '💘', '💝', '💟', '☮️', '✝️', '☪️', '🕉',
      ],
      'Animaux': [
        '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
        '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔',
        '🐧', '🐦', '🐤', '🐣', '🐥', '🦆', '🦅', '🦉',
        '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛', '🦋',
      ],
      'Nature': [
        '🌸', '🌺', '🌻', '🌷', '🌹', '🥀', '🏵️', '💐',
        '🌼', '🌵', '🎄', '🎋', '🌲', '🌳', '🌴', '🌱',
        '🌿', '☘️', '🍀', '🍃', '🍂', '🍁', '🌾', '🌈',
        '⭐', '🌟', '✨', '⚡', '☄️', '💫', '🌙', '☀️',
      ],
      'Nourriture': [
        '🍎', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🍈',
        '🍒', '🍑', '🥭', '🍍', '🥥', '🥝', '🍅', '🥑',
        '🥦', '🥬', '🥒', '🌶️', '🌽', '🥕', '🧄', '🧅',
        '🍔', '🍟', '🍕', '🌭', '🥪', '🌮', '🌯', '🥙',
      ],
      'Activités': [
        '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉',
        '🥏', '🎱', '🪀', '🏓', '🏸', '🏒', '🏑', '🥍',
        '🎮', '🕹️', '🎯', '🪁', '🎪', '🎨', '🎬', '🎤',
        '🎧', '🎼', '🎹', '🥁', '🎷', '🎺', '🎸', '🪕',
      ],
      'Objets': [
        '💎', '🔮', '💰', '👑', '🎁', '🎀', '🎊', '🎉',
        '🎈', '🪅', '🎏', '🔔', '🎃', '🎄', '🎆', '🎇',
        '🧨', '✉️', '💌', '💝', '🎎', '🎐', '🧧', '🪔',
      ],
    };

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
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

          // Titre
          Text(
            'Ajouter un sticker',
            style: GoogleFonts.poppins(
              color: AppColors.pureWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Onglets par catégorie
          Expanded(
            child: DefaultTabController(
              length: categories.length,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    indicatorColor: AppColors.crimsonRed,
                    labelColor: AppColors.pureWhite,
                    unselectedLabelColor: AppColors.mediumGray,
                    tabs: categories.keys.map((category) {
                      return Tab(text: category);
                    }).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: categories.values.map((emojis) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: emojis.length,
                          itemBuilder: (_, index) {
                            return GestureDetector(
                              onTap: () {
                                onStickerSelected(emojis[index]);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.mediumGray.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    emojis[index],
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
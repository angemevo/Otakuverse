import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/onboarding/anime_card.dart';
import 'package:otakuverse/models/sign_up_data.dart';
import '../../../core/widgets/button/app_button.dart';
import 'onboarding_games_screen.dart';

class OnboardingAnimeScreen extends StatefulWidget {
  final SignupData signupData;

  const OnboardingAnimeScreen({super.key, required this.signupData});

  @override
  State<OnboardingAnimeScreen> createState() => _OnboardingAnimeScreenState();
}

class _OnboardingAnimeScreenState extends State<OnboardingAnimeScreen> {
  final List<Map<String, String>> _animeList = [
    {'name': 'One Piece', 'image': 'one_piece.jpg', 'genre': 'Shonen'},
    {'name': 'Naruto', 'image': 'naruto.jpg', 'genre': 'Shonen'},
    {'name': 'Attack on Titan', 'image': 'aot.jpg', 'genre': 'Action'},
    {'name': 'Demon Slayer', 'image': 'demon_slayer.jpg', 'genre': 'Shonen'},
    {'name': 'My Hero Academia', 'image': 'mha.jpg', 'genre': 'Shonen'},
    {'name': 'Jujutsu Kaisen', 'image': 'jjk.jpg', 'genre': 'Shonen'},
    {'name': 'Death Note', 'image': 'death_note.jpg', 'genre': 'Thriller'},
    {'name': 'Fullmetal Alchemist', 'image': 'fma.jpg', 'genre': 'Shonen'},
    {'name': 'Tokyo Ghoul', 'image': 'tokyo_ghoul.jpg', 'genre': 'Seinen'},
    {'name': 'Sword Art Online', 'image': 'sao.jpg', 'genre': 'Isekai'},
    {'name': 'Steins;Gate', 'image': 'steins_gate.jpg', 'genre': 'Sci-Fi'},
    {'name': 'Hunter x Hunter', 'image': 'hxh.jpg', 'genre': 'Shonen'},
    {'name': 'One Punch Man', 'image': 'opm.jpg', 'genre': 'Action'},
    {'name': 'Bleach', 'image': 'bleach.jpg', 'genre': 'Shonen'},
    {'name': 'Code Geass', 'image': 'code_geass.jpg', 'genre': 'Mecha'},
    {'name': 'Dragon Ball Z', 'image': 'dbz.jpg', 'genre': 'Shonen'},
    {'name': 'Cowboy Bebop', 'image': 'cowboy_bebop.jpg', 'genre': 'Sci-Fi'},
    {'name': 'Neon Genesis Evangelion', 'image': 'evangelion.jpg', 'genre': 'Mecha'},
    {'name': 'Your Name', 'image': 'your_name.jpg', 'genre': 'Romance'},
    {'name': 'Violet Evergarden', 'image': 'violet_evergarden.jpg', 'genre': 'Drama'},
  ];

  List<String> _selectedAnimes = [];

  @override
  void initState() {
    super.initState();
    _selectedAnimes = List.from(widget.signupData.favoriteAnimes);
  }

  void _toggleAnime(String animeName) {
    setState(() {
      if (_selectedAnimes.contains(animeName)) {
        _selectedAnimes.remove(animeName);
      } else {
        _selectedAnimes.add(animeName);
      }
    });
  }

  void _handleNext() {
    widget.signupData.favoriteAnimes = _selectedAnimes;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingGamesScreen(signupData: widget.signupData),
      ),
    );
  }

  void _handleSkip() {
    widget.signupData.favoriteAnimes = [];
    widget.signupData.favoriteGames = [];

    // Aller directement au Home
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Onboarding',
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: _handleSkip,
                        child: const Text(
                          'Passer',
                          style: TextStyle(
                            color: AppColors.crimsonRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Tes animés favoris',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sélectionne ${_selectedAnimes.length > 0 ? _selectedAnimes.length : 'au moins 3'} animés que tu aimes',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.lightGray,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Progress indicator
                  LinearProgressIndicator(
                    value: 0.5, // Page 1/2
                    backgroundColor: AppColors.darkGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.crimsonRed),
                    minHeight: 4,
                  ),
                ],
              ),
            ),

            // Liste d'animés
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: _animeList.length,
                itemBuilder: (context, index) {
                  final anime = _animeList[index];
                  final isSelected = _selectedAnimes.contains(anime['name']);

                  return AnimeCard(
                    name: anime['name']!,
                    genre: anime['genre']!,
                    imagePath: anime['image']!,
                    isSelected: isSelected,
                    onTap: () => _toggleAnime(anime['name']!),
                  );
                },
              ),
            ),

            // Bouton Suivant
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AppButton(
                label: 'Suivant (${_selectedAnimes.length} sélectionnés)',
                type: AppButtonType.primary,
                onPressed: _selectedAnimes.length >= 3 ? _handleNext : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
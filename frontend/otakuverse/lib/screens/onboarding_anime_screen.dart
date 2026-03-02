// screens/auth/onboarding_anime_screen.dart

import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/core/widgets/onboarding/anime_card.dart';
import 'package:otakuverse/models/sign_up_data.dart';
import 'package:otakuverse/screens/navigation_page.dart';
import '../../../core/widgets/button/app_button.dart';
import 'onboarding_games_screen.dart';

class OnboardingAnimeScreen extends StatefulWidget {
  final SignupData signupData;

  const OnboardingAnimeScreen({super.key, required this.signupData});

  @override
  State<OnboardingAnimeScreen> createState() => _OnboardingAnimeScreenState();
}

class _OnboardingAnimeScreenState extends State<OnboardingAnimeScreen> {
  // ✅ VRAIES IMAGES DEPUIS LE WEB
  final List<Map<String, String>> _animeList = [
    {
      'name': 'One Piece',
      'image': 'https://cdn.myanimelist.net/images/anime/6/73245.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'Naruto',
      'image': 'https://cdn.myanimelist.net/images/anime/13/17405.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'Attack on Titan',
      'image': 'https://cdn.myanimelist.net/images/anime/10/47347.jpg',
      'genre': 'Action'
    },
    {
      'name': 'Demon Slayer',
      'image': 'https://cdn.myanimelist.net/images/anime/1286/99889.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'My Hero Academia',
      'image': 'https://cdn.myanimelist.net/images/anime/10/78745.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'Jujutsu Kaisen',
      'image': 'https://cdn.myanimelist.net/images/anime/1171/109222.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'Death Note',
      'image': 'https://cdn.myanimelist.net/images/anime/9/9453.jpg',
      'genre': 'Thriller'
    },
    {
      'name': 'Fullmetal Alchemist',
      'image': 'https://cdn.myanimelist.net/images/anime/1208/94745.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'Tokyo Ghoul',
      'image': 'https://cdn.myanimelist.net/images/anime/5/64449.jpg',
      'genre': 'Seinen'
    },
    {
      'name': 'Sword Art Online',
      'image': 'https://cdn.myanimelist.net/images/anime/11/39717.jpg',
      'genre': 'Isekai'
    },
    {
      'name': 'Steins;Gate',
      'image': 'https://cdn.myanimelist.net/images/anime/5/73199.jpg',
      'genre': 'Sci-Fi'
    },
    {
      'name': 'Hunter x Hunter',
      'image': 'https://cdn.myanimelist.net/images/anime/11/33657.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'One Punch Man',
      'image': 'https://cdn.myanimelist.net/images/anime/12/76049.jpg',
      'genre': 'Action'
    },
    {
      'name': 'Bleach',
      'image': 'https://cdn.myanimelist.net/images/anime/3/40451.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'Code Geass',
      'image': 'https://cdn.myanimelist.net/images/anime/5/50331.jpg',
      'genre': 'Mecha'
    },
    {
      'name': 'Dragon Ball Z',
      'image': 'https://cdn.myanimelist.net/images/anime/1277/142022.jpg',
      'genre': 'Shonen'
    },
    {
      'name': 'Cowboy Bebop',
      'image': 'https://cdn.myanimelist.net/images/anime/4/19644.jpg',
      'genre': 'Sci-Fi'
    },
    {
      'name': 'Evangelion',
      'image': 'https://cdn.myanimelist.net/images/anime/1314/108941.jpg',
      'genre': 'Mecha'
    },
    {
      'name': 'Your Name',
      'image': 'https://cdn.myanimelist.net/images/anime/5/87048.jpg',
      'genre': 'Romance'
    },
    {
      'name': 'Violet Evergarden',
      'image': 'https://cdn.myanimelist.net/images/anime/1795/95088.jpg',
      'genre': 'Drama'
    },
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
    Helpers.navigateOffAll(const NavigationPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Column(
          children: [
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
                    'Sélectionne ${_selectedAnimes.isNotEmpty ? _selectedAnimes.length : 'au moins 3'} animés que tu aimes',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.lightGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: AppColors.darkGray,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.crimsonRed),
                    minHeight: 4,
                  ),
                ],
              ),
            ),
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
                    imagePath: anime['image']!,  // ✅ URL du web
                    isSelected: isSelected,
                    onTap: () => _toggleAnime(anime['name']!),
                  );
                },
              ),
            ),
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
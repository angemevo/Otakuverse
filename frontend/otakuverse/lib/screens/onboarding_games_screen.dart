import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/core/widgets/onboarding/game_card.dart';
import 'package:otakuverse/models/sign_up_data.dart';
import 'package:otakuverse/screens/navigation_page.dart';
import '../../../core/widgets/button/app_button.dart';
import '../../../services/auth_service.dart';

class OnboardingGamesScreen extends StatefulWidget {
  final SignupData signupData;

  const OnboardingGamesScreen({super.key, required this.signupData});

  @override
  State<OnboardingGamesScreen> createState() => _OnboardingGamesScreenState();
}

class _OnboardingGamesScreenState extends State<OnboardingGamesScreen> {
  final _authService = AuthService();

  final List<Map<String, String>> _gamesList = [
    {'name': 'Genshin Impact', 'image': 'genshin.jpg', 'genre': 'RPG'},
    {'name': 'Final Fantasy XIV', 'image': 'ffxiv.jpg', 'genre': 'MMORPG'},
    {'name': 'Persona 5', 'image': 'persona5.jpg', 'genre': 'JRPG'},
    {'name': 'Elden Ring', 'image': 'elden_ring.jpg', 'genre': 'Action'},
    {'name': 'The Legend of Zelda', 'image': 'zelda.jpg', 'genre': 'Adventure'},
    {'name': 'Dark Souls', 'image': 'dark_souls.jpg', 'genre': 'Action'},
    {'name': 'NieR: Automata', 'image': 'nier.jpg', 'genre': 'Action'},
    {'name': 'Monster Hunter', 'image': 'monster_hunter.jpg', 'genre': 'Action'},
    {'name': 'Pokémon', 'image': 'pokemon.jpg', 'genre': 'RPG'},
    {'name': 'Kingdom Hearts', 'image': 'kingdom_hearts.jpg', 'genre': 'Action'},
    {'name': 'Yakuza', 'image': 'yakuza.jpg', 'genre': 'Action'},
    {'name': 'Tales of', 'image': 'tales.jpg', 'genre': 'JRPG'},
    {'name': 'Dragon Quest', 'image': 'dq.jpg', 'genre': 'JRPG'},
    {'name': 'Fire Emblem', 'image': 'fire_emblem.jpg', 'genre': 'Strategy'},
    {'name': 'Xenoblade Chronicles', 'image': 'xenoblade.jpg', 'genre': 'JRPG'},
    {'name': 'Valorant', 'image': 'valorant.jpg', 'genre': 'FPS'},
    {'name': 'League of Legends', 'image': 'lol.jpg', 'genre': 'MOBA'},
    {'name': 'Overwatch', 'image': 'overwatch.jpg', 'genre': 'FPS'},
    {'name': 'Honkai Star Rail', 'image': 'honkai.jpg', 'genre': 'RPG'},
    {'name': 'Blue Archive', 'image': 'blue_archive.jpg', 'genre': 'RPG'},
  ];

  List<String> _selectedGames = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedGames = List.from(widget.signupData.favoriteGames);
  }

  void _toggleGame(String gameName) {
    setState(() {
      if (_selectedGames.contains(gameName)) {
        _selectedGames.remove(gameName);
      } else {
        _selectedGames.add(gameName);
      }
    });
  }

  Future<void> _handleFinish() async {
    setState(() => _isLoading = true);

    try {
      widget.signupData.favoriteGames = _selectedGames;

      // Envoyer les intérêts au backend
      final result = await _authService.updateOnboarding(
        favoriteAnimes: widget.signupData.favoriteAnimes,
        favoriteGames: widget.signupData.favoriteGames,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Succès → Home
        Helpers.navigateOffAll(NavigationPage());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Erreur')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSkip() {
    widget.signupData.favoriteGames = [];

    // Aller directement au Home sans envoyer les intérêts
    Helpers.navigateOffAll(NavigationPage());
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
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
                    'Tes jeux favoris',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sélectionne ${_selectedGames.length > 0 ? _selectedGames.length : 'au moins 3'} jeux que tu aimes',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.lightGray,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Progress indicator
                  LinearProgressIndicator(
                    value: 1.0, // Page 2/2
                    backgroundColor: AppColors.darkGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.crimsonRed),
                    minHeight: 4,
                  ),
                ],
              ),
            ),

            // Liste de jeux
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: _gamesList.length,
                itemBuilder: (context, index) {
                  final game = _gamesList[index];
                  final isSelected = _selectedGames.contains(game['name']);

                  return GameCard(
                    name: game['name']!,
                    genre: game['genre']!,
                    imagePath: game['image']!,
                    isSelected: isSelected,
                    onTap: () => _toggleGame(game['name']!),
                  );
                },
              ),
            ),

            // Bouton Terminer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AppButton(
                label: 'Terminer (${_selectedGames.length} sélectionnés)',
                type: AppButtonType.primary,
                isLoading: _isLoading,
                onPressed: _selectedGames.length >= 3 ? _handleFinish : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
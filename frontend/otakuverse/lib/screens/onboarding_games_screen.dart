// screens/auth/onboarding_games_screen.dart

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

  // ✅ VRAIES IMAGES DEPUIS LE WEB
  final List<Map<String, String>> _gamesList = [
    {
      'name': 'Genshin Impact',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202009/2821/HXt3jcfShVnUQ4Y9a3rNbMD0.png',
      'genre': 'RPG'
    },
    {
      'name': 'Final Fantasy XIV',
      'image': 'https://img.finalfantasyxiv.com/lds/promo/h/S/r7o_rTZaFQOpOHDYU5Bq2iWJvc.jpg',
      'genre': 'MMORPG'
    },
    {
      'name': 'Persona 5',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202008/1421/JV2xnptmKHSWiE0nQOVrXZ0h.png',
      'genre': 'JRPG'
    },
    {
      'name': 'Elden Ring',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202110/2000/aGhopp3MHppi7kooGE2Dtt8C.png',
      'genre': 'Action'
    },
    {
      'name': 'The Legend of Zelda',
      'image': 'https://assets.nintendo.com/image/upload/f_auto/q_auto/dpr_2.625/c_scale,w_400/ncom/software/switch/70010000000025/7137262b5a64d921e193653f8aa0b722925abc5680380ca0e18a5cfd91697f58',
      'genre': 'Adventure'
    },
    {
      'name': 'Dark Souls',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202207/1210/4uYLxzWQCB5YoNgRi4aS2OBh.jpg',
      'genre': 'Action'
    },
    {
      'name': 'NieR: Automata',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202010/2612/gQiJyXZIkNx8NLCkAvfNVXKA.png',
      'genre': 'Action'
    },
    {
      'name': 'Monster Hunter',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202010/0118/pCcPR9DZPB8rvGUZYzOG5kJJ.png',
      'genre': 'Action'
    },
    {
      'name': 'Pokémon',
      'image': 'https://assets.pokemon.com/assets/cms2/img/pokedex/full/025.png',
      'genre': 'RPG'
    },
    {
      'name': 'Kingdom Hearts',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202010/2817/xGc9XG53Q3wZSkz4wGJYYSCu.jpg',
      'genre': 'Action'
    },
    {
      'name': 'Yakuza',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202010/2612/Hb1hzmkvHJnDH9DmJu82btI1.png',
      'genre': 'Action'
    },
    {
      'name': 'Tales of',
      'image': 'https://image.api.playstation.com/vulcan/ap/rnd/202106/0300/3xJjwQCsqSE13I8pLbGSV5Od.jpg',
      'genre': 'JRPG'
    },
    {
      'name': 'Dragon Quest',
      'image': 'https://cdn2.steamgriddb.com/grid/48c5b3dd9b6bc71a6e62fb5c9e4dbee5.jpg',
      'genre': 'JRPG'
    },
    {
      'name': 'Fire Emblem',
      'image': 'https://assets.nintendo.com/image/upload/f_auto/q_auto/dpr_2.625/c_scale,w_400/ncom/software/switch/70010000012332/fc4a0d2d6efd1a13be8e66f5d05c91e27f56d1cbcbf28c3ad5c1b74e0b37fbee',
      'genre': 'Strategy'
    },
    {
      'name': 'Xenoblade Chronicles',
      'image': 'https://assets.nintendo.com/image/upload/f_auto/q_auto/dpr_2.625/c_scale,w_400/ncom/software/switch/70010000027619/9989957eae3a6b545194c42fec2071675c34aadacd65e6b33fdfe7b3b6a86c3a',
      'genre': 'JRPG'
    },
    {
      'name': 'Valorant',
      'image': 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt29d7c4f6bc077629/5eb26f7087e5796258443c86/V_AGENTS_587x900_ALL_V2.jpg',
      'genre': 'FPS'
    },
    {
      'name': 'League of Legends',
      'image': 'https://images.contentstack.io/v3/assets/blt731acb42bb3d1659/blt3c68c9e2fd6c9e84/6214e6b78fe16c6bf4c85d13/040422_Riotx_Arcane_Keyart_01.jpg',
      'genre': 'MOBA'
    },
    {
      'name': 'Overwatch',
      'image': 'https://images.blz-contentstack.com/v3/assets/blt9c12f249ac15c7ec/blt5a4b8b6f1c9a28a0/634f89d93e84f36d2ce6f61f/logo-ow2.png',
      'genre': 'FPS'
    },
    {
      'name': 'Honkai Star Rail',
      'image': 'https://webstatic-sea.hoyoverse.com/upload/event/2022/09/27/e3e5a2a4a72f09e7dd5d63e5c75a6b84_1774909166912854862.jpg',
      'genre': 'RPG'
    },
    {
      'name': 'Blue Archive',
      'image': 'https://static.wikia.nocookie.net/blue-archive/images/3/3e/Cover.png',
      'genre': 'RPG'
    },
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

      final result = await _authService.updateOnboardingPreferences(
        favoriteAnimes: widget.signupData.favoriteAnimes,
        favoriteGames: widget.signupData.favoriteGames,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Helpers.navigateOffAll(const NavigationPage());
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
                    'Sélectionne ${_selectedGames.isNotEmpty ? _selectedGames.length : 'au moins 3'} jeux que tu aimes',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.lightGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 1.0,
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
                itemCount: _gamesList.length,
                itemBuilder: (context, index) {
                  final game = _gamesList[index];
                  final isSelected = _selectedGames.contains(game['name']);

                  return GameCard(
                    name: game['name']!,
                    genre: game['genre']!,
                    imagePath: game['image']!,  // ✅ URL du web
                    isSelected: isSelected,
                    onTap: () => _toggleGame(game['name']!),
                  );
                },
              ),
            ),
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
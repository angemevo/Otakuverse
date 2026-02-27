import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/models/sign_up_data.dart';
import 'package:otakuverse/screens/navigation_page.dart';
import 'package:otakuverse/screens/onboarding_anime_screen.dart';


class SignupSuccessScreen extends StatelessWidget {
  final String username;
  final SignupData signupData;

  const SignupSuccessScreen({
    super.key,
    required this.username,
    required this.signupData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation check avec gradient rouge
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.successWithOpacity(0.2),
                      AppColors.crimsonWithOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.successGreen,
                ),
              ),

              const SizedBox(height: 40),

              // Titre
              const Text(
                'Bienvenue sur Otakuverse !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                'Votre compte @$username a été créé avec succès',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.lightGray,
                ),
              ),

              const SizedBox(height: 12),

              // Info onboarding
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.crimsonWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.crimsonWithOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.crimsonRed,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dis-nous ce que tu aimes pour personnaliser ton expérience !',
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Bouton vers onboarding
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Helpers.navigateReplace(OnboardingAnimeScreen(signupData: signupData));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.crimsonRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton passer
              TextButton(
                onPressed: () {
                  Helpers.navigateReplace(NavigationPage());
                },
                child: const Text(
                  'Passer pour le moment',
                  style: TextStyle(
                    color: AppColors.lightGray,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
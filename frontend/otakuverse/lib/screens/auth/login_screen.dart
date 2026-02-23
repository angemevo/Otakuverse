import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/text_styles.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/core/utils/validators.dart';
import 'package:otakuverse/core/widgets/button/app_button.dart';
import 'package:otakuverse/core/widgets/custom_text_field.dart';
import 'package:otakuverse/screens/home_screen.dart';
import 'package:otakuverse/screens/navigation_page.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/auth_service.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Services
  late final AuthService _authService;

  // État
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================
  // CONNEXION
  // ============================================

  Future<void> _handleSignIn() async {
    // Reset error
    setState(() {
      _errorMessage = null;
    });

    // Validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Connexion
      final result = await _authService.signin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final success = result['success'];
      if (success is Map<String, dynamic>) {
        Helpers.navigateOffAll(NavigationPage());
        return; 
      }

      setState(() {
        _errorMessage = result['error'] ?? AppConstants.genericErrorMessage;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================
  // ERROR HANDLING
  // ============================================

  String _getErrorMessage(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return AppConstants.networkErrorMessage;
    } else if (error.contains('401') || error.contains('Unauthorized')) {
      return 'Email ou mot de passe incorrect';
    } else if (error.contains('timeout')) {
      return 'Délai d\'attente dépassé. Réessayez.';
    } else {
      return AppConstants.genericErrorMessage;
    }
  }

  // ============================================
  // UI BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background dark
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo + Titre
                _buildHeader(),

                const SizedBox(height: 60),

                // Message d'erreur
                if (_errorMessage != null) _buildErrorBanner(),

                // Email
                CustomTextField(
                  controller: _emailController, 
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: 20),

                // Password
                CustomTextField(
                  controller: _passwordController, 
                  label: 'Mot de passe',
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.validatePassword,
                  isPassword: true,
                  helperText: 'Minimum ${AppConstants.minPasswordLength} caractères'
                ),

                const SizedBox(height: 12),

                // Mot de passe oublié
                _buildForgotPassword(),

                const SizedBox(height: 32),

                // Bouton Connexion
                AppButton(
                  label: 'S\'inscrire',
                  // labelStyle: AppTextStyles.button,
                  type: AppButtonType.primary,
                  isLoading: _isLoading,
                  onPressed: _handleSignIn,
                ),

                const SizedBox(height: 24),

                // Divider
                _buildDivider(),

                const SizedBox(height: 24),

                // Pas de compte ? S'inscrire
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS
  // ============================================

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo/Icône
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset("assets/logo/otakuverse_logo.png")
        ),

        const SizedBox(height: 24),

        // Titre
        const Text(
          'Bon retour !',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        // Sous-titre
        Text(
          'Connectez-vous pour continuer',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCF6679).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFCF6679),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFCF6679),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFCF6679),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Navigation vers forgot password
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonctionnalité à venir')),
          );
        },
        child: const Text(
          'Mot de passe oublié ?',
          style: TextStyle(
            color: Color(0xFF6C63FF),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[800])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SignUpScreen(),
              ),
            );
          },
          child: Text(
            'S\'inscrire',
            style: AppTextStyles.link
          ),
        ),
      ],
    );
  }
}
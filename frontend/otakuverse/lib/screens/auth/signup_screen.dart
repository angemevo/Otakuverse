import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/constants/text_styles.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/core/utils/validators.dart';
import 'package:otakuverse/core/widgets/button/app_button.dart';
import 'package:otakuverse/core/widgets/divider.dart' show buildDivider;
import 'package:otakuverse/core/widgets/signup/build_header_widget.dart';
import 'package:otakuverse/core/widgets/custom_text_field.dart';
import 'package:otakuverse/core/widgets/signup/signin_link.dart';
import 'package:otakuverse/screens/auth/signup_succes_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Services
  late final AuthService _authService;

  // État
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  // ============================================
  // INSCRIPTION
  // ============================================

  Future<void> _handleSignUp() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      setState(() {
        _errorMessage = 'Vous devez accepter les conditions d\'utilisation';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
      );

      if (!mounted) return;

      final success = result['success'];
      if (success is Map<String, dynamic>) {
        Helpers.navigateReplace(SignupSuccessScreen(username: _usernameController.text));
      }


      setState(() {
        _errorMessage = result['error'] ?? AppConstants.genericErrorMessage;
        print('SIGNUP RESULT => $result');
        print('success type => ${result['success'].runtimeType}');
        print('error => ${result['error']}');

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
    } else if (error.contains('email') && error.contains('already')) {
      return 'Cet email est déjà utilisé';
    } else if (error.contains('username') && error.contains('already')) {
      return 'Ce nom d\'utilisateur est déjà pris';
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
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                buildHeader(),

                const SizedBox(height: 40),

                // Message d'erreur
                if (_errorMessage != null) _buildErrorBanner(),

                // Email
                CustomTextField(
                  controller: _emailController, 
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: 16),

                // Username
                CustomTextField(
                  controller: _usernameController, 
                  label: 'Nom d\'utilisateur',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.validateUsername,
                ),

                const SizedBox(height: 16),

                // Display Name (optionnel)
                CustomTextField(
                  controller: _displayNameController, 
                  label: 'Nom d\'affichage (optionnel)',
                  prefixIcon: Icons.badge_outlined,
                  validator: Validators.validateDisplayName,
                  helperText: 'Le nom qui sera affiché sur votre profil',
                ),

                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: _passwordController, 
                  label: 'Mot de passe',
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.validatePassword,
                  isPassword: true,
                  helperText: 'Minimum ${AppConstants.minPasswordLength} caractères',
                  
                ),

                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  controller: _passwordController, 
                  label: 'Mot de passe',
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                  isPassword: true,
                  helperText: 'Minimum ${AppConstants.minPasswordLength} caractères',
                  
                ),

                const SizedBox(height: 20),

                // Conditions d'utilisation
                _buildTermsCheckbox(),

                const SizedBox(height: 32),

                // Bouton S'inscrire
                AppButton(
                  label: 'S\'inscrire',
                  // labelStyle: AppTextStyles.button,
                  type: AppButtonType.primary,
                  isLoading: _isLoading,
                  onPressed: _handleSignUp,
                ),

                const SizedBox(height: 24),

                // Divider
                buildDivider(),

                const SizedBox(height: 24),

                // Déjà un compte ? Se connecter
                buildSignInLink(),
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
 
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: const Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall,
                children: [
                  const TextSpan(text: 'J\'accepte les '),
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' et la '),
                  TextSpan(
                    text: 'politique de confidentialité',
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
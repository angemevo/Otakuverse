import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/core/widgets/button/google_sign_in_button.dart';
import 'package:otakuverse/screens/navigation_page.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/button/app_button.dart';
import '../../../services/auth_service.dart';
import '../../../services/google_auth_service.dart';
import '../../../services/location_service.dart';
import 'signup/signup_step1_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _authService = AuthService();
  final _googleAuthService = GoogleAuthService();
  final _locationService = LocationService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    await _locationService.requestPermission();
  }

  Future<void> _handleSignIn() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Helpers.navigateReplace(NavigationPage());
      } else {
        setState(() {
          _errorMessage = result['error'] ?? AppConstants.genericErrorMessage;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erreur de connexion');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _errorMessage = null;
      _isGoogleLoading = true;
    });

    try {
      final googleData = await _googleAuthService.signInWithGoogle();
      print("GOOGLE DATA => $googleData");

      if (googleData == null) {
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final location = await _locationService.getLocation();

      final result = await _authService.signinWithGoogle(
        sub: googleData['sub'],               // ✅ CORRIGÉ
        email: googleData['email'],
        displayName: googleData['displayName'],
        photoUrl: googleData['photoUrl'],
        location: location,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Helpers.navigateReplace(NavigationPage());
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur Google Sign-In';
          print('Erreur : ${_errorMessage}');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erreur Google Sign-In');
      print('Erreur : ${_errorMessage}');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 60),
                if (_errorMessage != null) _buildErrorBanner(),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.validatePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Se connecter',
                  type: AppButtonType.primary,
                  isLoading: _isLoading,
                  onPressed: _handleSignIn,
                ),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                GoogleSignInButton(
                  onPressed: _handleGoogleSignIn,
                  isLoading: _isGoogleLoading,
                ),
                const SizedBox(height: 24),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.public, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        const Text(
          'Bon retour !',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour continuer',
          style: TextStyle(fontSize: 16, color: AppColors.lightGray),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crimsonWithOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorRed),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.errorRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: AppColors.errorRed, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU',
            style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: TextStyle(color: AppColors.lightGray, fontSize: 14),
        ),
        TextButton(
          onPressed: () => Helpers.navigateTo(SignUpStep1Screen()),
          child: const Text(
            'S\'inscrire',
            style: TextStyle(
              color: AppColors.crimsonRed,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/button/google_sign_in_button.dart';
import 'package:otakuverse/models/sign_up_data.dart';
import 'package:otakuverse/screens/auth/signup/signup_step2_screen.dart';
import 'package:otakuverse/screens/navigation_page.dart';
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
    print('🔵🔵🔵 SIGNIN SCREEN INITIALISÉ 🔵🔵🔵');
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

  // ✅ MÉTHODE 1 : Connexion Email/Password
  Future<void> _handleSignIn() async {
    print('🔵 === DÉBUT SIGNIN ===');
    
    if (!_formKey.currentState!.validate()) {
      print('⚠️ Formulaire invalide');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      print('📤 Envoi requête signin...');
      print('Email: ${_emailController.text}');

      final result = await _authService.signin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('📥 Réponse signin: $result');

      if (!mounted) {
        print('⚠️ Widget démonté');
        return;
      }

      if (result['success'] == true) {
        print('✅ Signin réussi !');
        print('Token: ${result['token']}');
        print('User: ${result['user']}');

        // Navigation vers la page d'accueil
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const NavigationPage()),
          (route) => false,
        );

        print('✅ Navigation effectuée');
      } else {
        print('❌ Signin échoué: ${result['error']}');
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur de connexion';
        });
      }
    } catch (e, stackTrace) {
      print('❌ Exception signin: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
      });
    } finally {
      print('🔵 === FIN SIGNIN ===');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ MÉTHODE 2 : Connexion Google
  Future<void> _handleGoogleSignIn() async {
    print('🔵 === DÉBUT GOOGLE SIGNIN ===');
    
    setState(() {
      _errorMessage = null;
      _isGoogleLoading = true;
    });

    try {
      final googleData = await _googleAuthService.signInWithGoogle();
      print('📥 Google Data reçu: $googleData');

      if (googleData == null) {
        print('⚠️ Google Sign-In annulé');
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final location = await _locationService.getLocation();
      print('📍 Localisation: $location');

      final result = await _authService.signinWithGoogle(
        sub: googleData['sub'],
        email: googleData['email'],
        displayName: googleData['displayName'],
        photoUrl: googleData['photoUrl'],
        location: location,
      );

      print('📥 Réponse backend: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        print('✅ Google Sign-In réussi !');
        
        final isNewUser = result['is_new_user'] ?? false;
        final user = result['user'];
        
        print('Is New User: $isNewUser');

        if (isNewUser) {
          print('➡️ Nouveau user → Redirection vers Step 2');
          
          final signupData = SignupData(
            email: user['email'],
            username: user['username'],
            password: null,
          );
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => SignUpStep2Screen(signupData: signupData),
            ),
            (route) => false,
          );
        } else {
          print('➡️ User existant → Redirection vers Home');
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const NavigationPage()),
            (route) => false,
          );
        }
        
        print('✅ Navigation effectuée');
      } else {
        print('❌ Google Sign-In échoué: ${result['error']}');
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur Google Sign-In';
        });
      }
    } catch (e, stackTrace) {
      print('❌ Exception Google Sign-In: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() => _errorMessage = 'Erreur Google Sign-In: ${e.toString()}');
    } finally {
      print('🔵 === FIN GOOGLE SIGNIN ===');
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
          child: Image.asset("assets/logo/otakuverse_logo.png"),
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
          const Icon(Icons.error_outline, color: AppColors.errorRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SignUpStep1Screen()),
            );
          },
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
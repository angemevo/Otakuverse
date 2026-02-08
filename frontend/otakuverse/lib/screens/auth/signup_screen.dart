import 'package:flutter/material.dart';
import 'package:otakuverse/core/utils/validators.dart';
import 'package:otakuverse/core/widgets/signup/build_header_widget.dart';
import 'package:otakuverse/core/widgets/custom_text_field.dart';
import 'package:otakuverse/screens/home_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

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
    // Reset error
    setState(() {
      _errorMessage = null;
    });

    // Validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier les conditions
    if (!_acceptTerms) {
      setState(() {
        _errorMessage = 'Vous devez accepter les conditions d\'utilisation';
      });
      return;
    }

    // Loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Inscription
      final result = await _authService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Succès → Afficher message puis naviguer
        _showSuccessDialog();
      } else {
        // Erreur
        setState(() {
          _errorMessage = result['error'] ?? AppConstants.genericErrorMessage;
        });
      }
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
  // SUCCESS DIALOG
  // ============================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Inscription réussie !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenue sur Otakuverse, ${_usernameController.text} !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'C\'est parti !',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  validator: (value) {Validators.validateEmail(value);},
                ),

                const SizedBox(height: 16),

                // Username
                CustomTextField(
                  controller: _usernameController, 
                  label: 'Nom d\'utilisateur',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {Validators.validateUsername(value);},
                ),

                const SizedBox(height: 16),

                // Display Name (optionnel)
                _buildDisplayNameField(),

                const SizedBox(height: 16),

                // Password
                _buildPasswordField(),

                const SizedBox(height: 16),

                // Confirm Password
                _buildConfirmPasswordField(),

                const SizedBox(height: 20),

                // Conditions d'utilisation
                _buildTermsCheckbox(),

                const SizedBox(height: 32),

                // Bouton S'inscrire
                _buildSignUpButton(),

                const SizedBox(height: 24),

                // Divider
                _buildDivider(),

                const SizedBox(height: 24),

                // Déjà un compte ? Se connecter
                _buildSignInLink(),
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
 
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Nom d\'utilisateur',
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]),
        helperText: 'Entre ${AppConstants.minUsernameLength} et ${AppConstants.maxUsernameLength} caractères, lettres, chiffres et _',
        helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un nom d\'utilisateur';
        }
        if (value.length < AppConstants.minUsernameLength) {
          return 'Minimum ${AppConstants.minUsernameLength} caractères';
        }
        if (value.length > AppConstants.maxUsernameLength) {
          return 'Maximum ${AppConstants.maxUsernameLength} caractères';
        }
        if (!RegExp(AppConstants.usernamePattern).hasMatch(value)) {
          return 'Uniquement lettres, chiffres et _';
        }
        return null;
      },
    );
  }

  Widget _buildDisplayNameField() {
    return TextFormField(
      controller: _displayNameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Nom d\'affichage (optionnel)',
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.badge_outlined, color: Colors.grey[400]),
        helperText: 'Le nom qui sera affiché sur votre profil',
        helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey[400]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey[400],
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        helperText: 'Minimum ${AppConstants.minPasswordLength} caractères',
        helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un mot de passe';
        }
        if (value.length < AppConstants.minPasswordLength) {
          return 'Minimum ${AppConstants.minPasswordLength} caractères';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Confirmer le mot de passe',
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey[400]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey[400],
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez confirmer le mot de passe';
        }
        if (value != _passwordController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
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
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
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

  Widget _buildSignUpButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          disabledBackgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'S\'inscrire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Se connecter',
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/core/widgets/step_indicator.dart'; // ✅ AJOUTÉ
import 'package:otakuverse/models/sign_up_data.dart';
import 'package:otakuverse/screens/auth/signup/signup_step2_screen.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/button/app_button.dart';

class SignUpStep1Screen extends StatefulWidget {
  final SignupData? initialData;

  const SignUpStep1Screen({super.key, this.initialData});

  @override
  State<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends State<SignUpStep1Screen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final SignupData _signupData;

  @override
  void initState() {
    super.initState();
    _signupData = widget.initialData ?? SignupData();
    _emailController.text = _signupData.email ?? '';
    _usernameController.text = _signupData.username ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    _signupData.email = _emailController.text.trim();
    _signupData.username = _usernameController.text.trim();
    _signupData.password = _passwordController.text;

    Helpers.navigateTo(SignUpStep2Screen(signupData: _signupData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: StepIndicator(currentStep: 1, totalSteps: 3), // ✅ CORRIGÉ
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Étape 1 sur 3 : Informations de connexion',
                        style: TextStyle(fontSize: 16, color: AppColors.lightGray),
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _usernameController,
                        label: 'Nom d\'utilisateur',
                        prefixIcon: Icons.person_outline,
                        validator: Validators.validateUsername,
                        helperText: '3-30 caractères, lettres, chiffres et _',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        prefixIcon: Icons.lock_outlined,
                        validator: Validators.validatePassword,
                        isPassword: true,
                        helperText: 'Minimum ${AppConstants.minPasswordLength} caractères',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmer le mot de passe',
                        prefixIcon: Icons.lock_outlined,
                        validator: (value) => Validators.validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        isPassword: true,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: 'Suivant',
                        type: AppButtonType.primary,
                        onPressed: _handleNext,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
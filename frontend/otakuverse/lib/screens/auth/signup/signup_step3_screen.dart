import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/step_indicator.dart'; // ✅ AJOUTÉ
import 'package:otakuverse/models/sign_up_data.dart';
import 'package:otakuverse/screens/auth/signup_succes_screen.dart';
import '../../../../core/widgets/button/app_button.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/location_service.dart'; // ✅ AJOUTÉ

class SignUpStep3Screen extends StatefulWidget {
  final SignupData signupData;

  const SignUpStep3Screen({super.key, required this.signupData});

  @override
  State<SignUpStep3Screen> createState() => _SignUpStep3ScreenState();
}

class _SignUpStep3ScreenState extends State<SignUpStep3Screen> {
  final ImagePicker _picker = ImagePicker();
  final _authService = AuthService();
  final _locationService = LocationService(); // ✅ CORRIGÉ

  String? _avatarPath;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _avatarPath = widget.signupData.avatarPath;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) setState(() => _avatarPath = image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.crimsonRed),
                title: const Text('Prendre une photo',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.crimsonRed),
                title: const Text('Choisir depuis la galerie',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      widget.signupData.avatarPath = _avatarPath;

      final isGoogleSignIn = widget.signupData.password == null;

      if (isGoogleSignIn) {
        print('🔵 Google Sign-In : Complétion du profil');
        
        final result = await _authService.completeGoogleProfile(
          birthDate: widget.signupData.dateOfBirthString!,
          gender: widget.signupData.gender!,
          avatarUrl: _avatarPath,
        );

        if (!mounted) return;

        if (result['success'] == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => SignupSuccessScreen(
                username: widget.signupData.username!,
                signupData: widget.signupData,
              ),
            ),
            (route) => false,
          );
        } else {
          setState(() {
            _errorMessage = result['error'] ?? 'Erreur lors de la mise à jour';
          });
        }
      } else {
        print('🔵 Signup classique');
        
        final location = await _locationService.getLocation();
        widget.signupData.location = location;

        final result = await _authService.signup(
          email: widget.signupData.email!,
          password: widget.signupData.password!,
          username: widget.signupData.username!,
          dateOfBirth: widget.signupData.dateOfBirthString!,
          gender: widget.signupData.gender!,
          phone: widget.signupData.phone,
          location: widget.signupData.location,
          avatarUrl: _avatarPath,
        );

        if (!mounted) return;

        if (result['success'] == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => SignupSuccessScreen(
                username: widget.signupData.username!,
                signupData: widget.signupData,
              ),
            ),
            (route) => false,
          );
        } else {
          setState(() {
            _errorMessage = result['error'] ?? 'Erreur lors de l\'inscription';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          onPressed: _isLoading ? null : () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: StepIndicator(currentStep: 3, totalSteps: 3), // ✅ CORRIGÉ
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Photo de profil',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Étape 3 sur 3 : Avatar (optionnel)',
                      style: TextStyle(fontSize: 16, color: AppColors.lightGray),
                    ),
                    const SizedBox(height: 60),
                    if (_errorMessage != null) _buildErrorBanner(),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.darkGray,
                              border: Border.all(
                                color: AppColors.crimsonRed,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: _avatarPath != null
                                  ? Image.file(  // ✅ FileImage via Image.file
                                      File(_avatarPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: 80,
                                          color: AppColors.mediumGray,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 80,
                                      color: AppColors.mediumGray,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppColors.crimsonRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
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
                          const Icon(Icons.info_outline,
                              color: AppColors.crimsonRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Vous pourrez changer votre photo de profil plus tard',
                              style: TextStyle(
                                  color: AppColors.lightGray, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    AppButton(
                      label: 'Créer mon compte',
                      type: AppButtonType.primary,
                      isLoading: _isLoading,
                      onPressed: _handleSignUp,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Passer cette étape',
                      type: AppButtonType.ghost,
                      onPressed: _isLoading ? null : _handleSignUp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
}
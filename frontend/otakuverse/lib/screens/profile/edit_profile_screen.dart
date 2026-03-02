// screens/profile/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/models/profile_model.dart';
import 'package:otakuverse/services/profile_service.dart';
import 'package:otakuverse/services/storage_upload_service.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  // ❌ PAS de _locationController

  String? _selectedGender;
  bool _isLoading = false;
  File? _newAvatar;
  File? _newBanner;

  final List<String> _genders = ['male', 'female', 'other', 'prefer_not_to_say'];
  final Map<String, String> _genderLabels = {
    'male': 'Homme',
    'female': 'Femme',
    'other': 'Autre',
    'prefer_not_to_say': 'Préfère ne pas dire',
  };

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.profile.displayName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _websiteController = TextEditingController(text: widget.profile.website);
    _selectedGender = widget.profile.gender;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  // ============================================
  // SÉLECTION AVATAR
  // ============================================
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() => _newAvatar = File(image.path));
    }
  }

  // ============================================
  // SÉLECTION BANNIÈRE
  // ============================================
  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 400,
    );
    if (image != null) {
      setState(() => _newBanner = File(image.path));
    }
  }

  // ============================================
  // SAUVEGARDER
  // ============================================
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      String? avatarUrl = widget.profile.avatarUrl;
      String? bannerUrl = widget.profile.bannerUrl;

      // Upload avatar si nouveau
      if (_newAvatar != null) {
        print('📤 Uploading avatar...');
        avatarUrl = await StorageUploadService()
            .uploadAvatar(_newAvatar!, widget.profile.userId);
        print('✅ Avatar uploaded: $avatarUrl');
      }

      // Upload banner si nouveau
      if (_newBanner != null) {
        print('📤 Uploading banner...');
        bannerUrl = await StorageUploadService()
            .uploadBanner(_newBanner!, widget.profile.userId);
        print('✅ Banner uploaded: $bannerUrl');
      }

      // ✅ Mettre à jour le profil (sans location)
      final result = await ProfileService().updateProfile(
        displayName: _displayNameController.text.trim().isEmpty 
            ? null 
            : _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
        avatarUrl: avatarUrl,
        bannerUrl: bannerUrl,
        website: _websiteController.text.trim().isEmpty 
            ? null 
            : _websiteController.text.trim(),
        gender: _selectedGender,
        // ❌ PAS de location ici !
      );

      if (!mounted) return;

      if (result['success'] != null) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil mis à jour'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Erreur de mise à jour'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error saving profile: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack,
        elevation: 0,
        title: Text(
          'Modifier le profil',
          style: GoogleFonts.poppins(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.crimsonRed,
                      ),
                    )
                  : Text(
                      'Sauvegarder',
                      style: GoogleFonts.inter(
                        color: AppColors.crimsonRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPhotoSection(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                    'Nom affiché',
                    _displayNameController,
                    icon: Icons.person_outline,
                    hint: 'Ton nom visible publiquement',
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    'Bio',
                    _bioController,
                    maxLines: 4,
                    maxLength: 500,
                    icon: Icons.info_outline,
                    hint: 'Parle de toi en quelques mots...',
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    'Site web',
                    _websiteController,
                    icon: Icons.link,
                    hint: 'https://...',
                  ),
                  const SizedBox(height: 16),
                  _buildGenderPicker(),
                  
                  // ✅ Afficher la localisation actuelle (lecture seule)
                  if (widget.profile.location != null) ...[
                    const SizedBox(height: 16),
                    _buildLocationDisplay(),
                  ],
                  
                  const SizedBox(height: 32),
                  _buildFavoritesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SECTION PHOTOS (bannière + avatar)
  // ============================================
  Widget _buildPhotoSection() {
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bannière
          GestureDetector(
            onTap: _pickBanner,
            child: SizedBox(
              width: double.infinity,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _newBanner != null
                      ? Image.file(_newBanner!, fit: BoxFit.cover)
                      : widget.profile.hasBanner
                          ? Image.network(
                              widget.profile.bannerUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                ),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                              ),
                            ),
                  Container(color: AppColors.blackWithOpacity(0.4)),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          color: AppColors.pureWhite,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Modifier la bannière',
                          style: GoogleFonts.inter(
                            color: AppColors.pureWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar
          Positioned(
            bottom: 0,
            left: 16,
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.deepBlack,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.darkGray,
                      backgroundImage: _newAvatar != null
                          ? FileImage(_newAvatar!)
                          : widget.profile.hasAvatar
                              ? NetworkImage(widget.profile.avatarUrl!)
                              : null,
                      child: (_newAvatar == null && !widget.profile.hasAvatar)
                          ? const Icon(
                              Icons.person,
                              color: AppColors.pureWhite,
                              size: 36,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.crimsonRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.pureWhite,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 10,
            left: 104,
            child: Text(
              'Modifier la photo',
              style: GoogleFonts.inter(
                color: AppColors.mediumGray,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CHAMP TEXTE
  // ============================================
  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    int? maxLength,
    IconData? icon,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.mediumGray,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: GoogleFonts.inter(color: AppColors.pureWhite),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.mediumGray),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.crimsonRed, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.darkGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.crimsonRed,
                width: 1.5,
              ),
            ),
            counterStyle: GoogleFonts.inter(
              color: AppColors.mediumGray,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // GENRE
  // ============================================
  Widget _buildGenderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre',
          style: GoogleFonts.inter(
            color: AppColors.mediumGray,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedGender,
            isExpanded: true,
            dropdownColor: AppColors.darkGray,
            underline: const SizedBox(),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.mediumGray,
            ),
            hint: Text(
              'Sélectionner',
              style: GoogleFonts.inter(color: AppColors.mediumGray),
            ),
            style: GoogleFonts.inter(
              color: AppColors.pureWhite,
              fontSize: 15,
            ),
            items: _genders.map((g) {
              return DropdownMenuItem(
                value: g,
                child: Text(_genderLabels[g]!),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedGender = val),
          ),
        ),
      ],
    );
  }

  // ============================================
  // AFFICHAGE LOCALISATION (LECTURE SEULE)
  // ============================================
  Widget _buildLocationDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Localisation',
              style: GoogleFonts.inter(
                color: AppColors.mediumGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.gps_fixed,
                    color: AppColors.successGreen,
                    size: 10,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Auto',
                    style: GoogleFonts.inter(
                      color: AppColors.mediumGray,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.mediumGray.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.successGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.profile.location ?? 'Localisation non définie',
                  style: GoogleFonts.inter(
                    color: AppColors.lightGray,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.lock_outline,
                color: AppColors.mediumGray,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'La localisation est mise à jour automatiquement',
          style: GoogleFonts.inter(
            color: AppColors.mediumGray,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================
  // SECTION FAVORIS (lecture seule)
  // ============================================
  Widget _buildFavoritesSection() {
    final hasAnime = widget.profile.favoriteAnime.isNotEmpty;
    final hasManga = widget.profile.favoriteManga.isNotEmpty;
    final hasGames = widget.profile.favoriteGames.isNotEmpty;
    final hasGenres = widget.profile.favoriteGenres.isNotEmpty;

    if (!hasAnime && !hasManga && !hasGames && !hasGenres) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Préférences',
              style: GoogleFonts.poppins(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Lecture seule',
                style: GoogleFonts.inter(
                  color: AppColors.mediumGray,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (hasGenres) ...[
          Text(
            'Genres favoris',
            style: GoogleFonts.inter(
              color: AppColors.mediumGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.profile.favoriteGenres.map((g) => _chip(g)).toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (hasAnime) ...[
          Text(
            'Animés favoris',
            style: GoogleFonts.inter(
              color: AppColors.mediumGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.profile.favoriteAnime.map((a) => _chip(a)).toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (hasManga) ...[
          Text(
            'Mangas favoris',
            style: GoogleFonts.inter(
              color: AppColors.mediumGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.profile.favoriteManga.map((m) => _chip(m)).toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (hasGames) ...[
          Text(
            'Jeux favoris',
            style: GoogleFonts.inter(
              color: AppColors.mediumGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.profile.favoriteGames.map((g) => _chip(g)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.crimsonWithOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.crimsonWithOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.lightCrimson,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
// screens/home/create_post_screen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
import 'dart:io';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/services/post_service.dart';
import 'package:otakuverse/services/storage_upload_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> 
    with SingleTickerProviderStateMixin {
  
  final _captionController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _allowComments = true;
  bool _isPublishing = false; // ✅ AJOUTÉ
  String? _locationText;
  bool _isLoadingLocation = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================
  // GÉOLOCALISATION
  // ============================================
  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          _showSnackBar(
            'Permission de localisation refusée',
            isError: true,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        _showSnackBar(
          'Localisation bloquée dans les paramètres',
          isError: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          _locationText = '${place.locality}, ${place.country}';
        });
        _showSnackBar('Localisation ajoutée', isError: false);
      }
    } catch (e) {
      print('❌ Error getting location: $e');
      _showSnackBar(
        'Impossible de récupérer la localisation',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // ============================================
  // SÉLECTION D'IMAGES
  // ============================================
  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(
        limit: 10,
        imageQuality: 85,
      );

      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.clear();
          _selectedImages.addAll(images.map((e) => File(e.path)));
        });
        
        _showSnackBar(
          '${images.length} image${images.length > 1 ? 's' : ''} sélectionnée${images.length > 1 ? 's' : ''}',
          isError: false,
        );
      }
    } catch (e) {
      print('❌ Error picking images: $e');
      _showSnackBar('Erreur lors de la sélection', isError: true);
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        
        _showSnackBar('Photo ajoutée', isError: false);
      }
    } catch (e) {
      print('❌ Error taking photo: $e');
      _showSnackBar('Erreur lors de la capture', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
    _showSnackBar('Image retirée', isError: false);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mediumGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const HeroIcon(
                HeroIcons.photo,
                color: AppColors.pureWhite,
              ),
              title: Text(
                'Choisir depuis la galerie',
                style: GoogleFonts.inter(
                  color: AppColors.pureWhite,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            
            ListTile(
              leading: const HeroIcon(
                HeroIcons.camera,
                color: AppColors.pureWhite,
              ),
              title: Text(
                'Prendre une photo',
                style: GoogleFonts.inter(
                  color: AppColors.pureWhite,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PUBLIER
  // ============================================
  Future<void> _publishPost() async {
    if (_captionController.text.trim().isEmpty && _selectedImages.isEmpty) {
      _showSnackBar('Ajoutez au moins une légende ou des médias', isError: true);
      return;
    }

    setState(() => _isPublishing = true);

    try {
      List<String> mediaUrls = [];
      
      // ✅ SIMPLE : uploadImages retourne List<String>
      if (_selectedImages.isNotEmpty) {
        print('📤 Uploading ${_selectedImages.length} images...');
        mediaUrls = await StorageUploadService().uploadImages(_selectedImages, '');
        print('✅ ${mediaUrls.length} images uploaded');
      }

      // Créer le post
      print('📝 Creating post...');
      final result = await PostsService().createPost(
        caption: _captionController.text.trim(),
        mediaUrls: mediaUrls,
        location: _locationText,
      );

      if (result['success'] != null) {
        if (mounted) {
          Navigator.pop(context, true);
          _showSnackBar('Post publié avec succès !', isError: false);
        }
      } else {
        throw Exception(result['error'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        _showSnackBar('Erreur: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  // ============================================
  // HELPERS
  // ============================================
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            HeroIcon(
              isError ? HeroIcons.exclamationCircle : HeroIcons.checkCircle,
              color: AppColors.pureWhite,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: AppColors.lightGray,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                color: AppColors.mediumGray,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.crimsonRed,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            child: Text(
              'Publier',
              style: GoogleFonts.inter(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  Future<bool> _onWillPop() async {
    if (_captionController.text.isEmpty && _selectedImages.isEmpty) {
      return true;
    }
    
    return await _showConfirmDialog(
      'Quitter ?',
      'Vos modifications seront perdues.',
    );
  }

  // ============================================
  // BUILD
  // ============================================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.deepBlack,
        appBar: AppBar(
          backgroundColor: AppColors.deepBlack,
          elevation: 0,
          title: Text(
            'Nouveau post',
            style: GoogleFonts.poppins(
              color: AppColors.pureWhite,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const HeroIcon(
              HeroIcons.xMark,
              color: AppColors.pureWhite,
            ),
            onPressed: () async {
              if (await _onWillPop()) {
                if (mounted) Navigator.pop(context);
              }
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextButton(
                onPressed: _isPublishing ? null : _publishPost,
                style: TextButton.styleFrom(
                  backgroundColor: _isPublishing
                      ? AppColors.mediumGray.withOpacity(0.3)
                      : AppColors.crimsonRed,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: _isPublishing ? 0 : 2,
                ),
                child: _isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.pureWhite,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HeroIcon(
                            HeroIcons.paperAirplane,
                            color: AppColors.pureWhite,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Publier',
                            style: GoogleFonts.inter(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _animationController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCaptionField(),
                const SizedBox(height: 24),
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildLocationField(),
                const SizedBox(height: 20),
                _buildAllowComments(),
                const SizedBox(height: 20),
                _buildTips(),
                const SizedBox(height: 40),
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
  Widget _buildCaptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const HeroIcon(
              HeroIcons.pencil,
              color: AppColors.crimsonRed,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Légende',
              style: GoogleFonts.poppins(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _captionController,
          maxLength: 2200,
          maxLines: 6,
          style: GoogleFonts.inter(
            color: AppColors.pureWhite,
            fontSize: 15,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'Partagez vos pensées...',
            hintStyle: GoogleFonts.inter(
              color: AppColors.mediumGray,
            ),
            filled: true,
            fillColor: AppColors.darkGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.mediumGray.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.crimsonRed,
                width: 2,
              ),
            ),
            counterStyle: GoogleFonts.inter(
              color: AppColors.mediumGray,
              fontSize: 11,
            ),
          ),
          onChanged: (value) {
            // Auto-save draft (optionnel)
          },
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const HeroIcon(
                  HeroIcons.photo,
                  color: AppColors.crimsonRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Médias',
                  style: GoogleFonts.poppins(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'optionnel',
                    style: GoogleFonts.inter(
                      color: AppColors.mediumGray,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${_selectedImages.length}/10',
              style: GoogleFonts.inter(
                color: _selectedImages.length >= 10
                    ? AppColors.errorRed
                    : AppColors.mediumGray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_selectedImages.isEmpty)
          _buildEmptyMediaState()
        else
          _buildMediaGrid(),
      ],
    );
  }

  Widget _buildEmptyMediaState() {
    return GestureDetector(
      onTap: _showImageOptions,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.crimsonRed.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeroIcon(
              HeroIcons.photo,
              color: AppColors.crimsonRed,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Ajouter des photos ou vidéos',
              style: GoogleFonts.inter(
                color: AppColors.crimsonRed,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jusqu\'à 10 médias',
              style: GoogleFonts.inter(
                color: AppColors.mediumGray,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedImages.length) {
              return _buildAddMoreButton();
            }
            return _buildImageTile(index);
          },
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    if (_selectedImages.length >= 10) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: _showImageOptions,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.crimsonRed.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HeroIcon(
              HeroIcons.plus,
              color: AppColors.crimsonRed,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.crimsonRed.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        
        // Numéro de l'image
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}',
              style: GoogleFonts.inter(
                color: AppColors.pureWhite,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        // Bouton supprimer
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.errorRed,
                shape: BoxShape.circle,
              ),
              child: const HeroIcon(
                HeroIcons.trash,
                color: AppColors.pureWhite,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const HeroIcon(
              HeroIcons.mapPin,
              color: AppColors.crimsonRed,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Localisation',
              style: GoogleFonts.poppins(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isLoadingLocation ? null : _getLocation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _locationText != null
                    ? AppColors.crimsonRed.withOpacity(0.5)
                    : AppColors.mediumGray.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                HeroIcon(
                  HeroIcons.mapPin,
                  color: _locationText != null
                      ? AppColors.crimsonRed
                      : AppColors.mediumGray,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoadingLocation
                      ? Row(
                          children: [
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.crimsonRed,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Localisation en cours...',
                              style: GoogleFonts.inter(
                                color: AppColors.mediumGray,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _locationText ?? 'Ajouter ma position',
                          style: GoogleFonts.inter(
                            color: _locationText != null
                                ? AppColors.pureWhite
                                : AppColors.mediumGray,
                            fontSize: 15,
                            fontWeight: _locationText != null
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                ),
                if (_locationText != null)
                  GestureDetector(
                    onTap: () => setState(() => _locationText = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.mediumGray.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const HeroIcon(
                        HeroIcons.xMark,
                        color: AppColors.mediumGray,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllowComments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mediumGray.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const HeroIcon(
            HeroIcons.chatBubbleOvalLeft,
            color: AppColors.crimsonRed,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autoriser les commentaires',
                  style: GoogleFonts.inter(
                    color: AppColors.pureWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Les utilisateurs pourront commenter',
                  style: GoogleFonts.inter(
                    color: AppColors.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _allowComments,
            activeColor: AppColors.crimsonRed,
            onChanged: (val) => setState(() => _allowComments = val),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crimsonRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.crimsonRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HeroIcon(
                HeroIcons.lightBulb,
                color: AppColors.crimsonRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Conseils',
                style: GoogleFonts.poppins(
                  color: AppColors.crimsonRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('Ajoutez des hashtags pour plus de visibilité'),
          _buildTip('Utilisez des émojis pour plus d\'engagement'),
          _buildTip('Partagez du contenu original et de qualité'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: HeroIcon(
              HeroIcons.checkCircle,
              color: AppColors.crimsonRed,
              size: 16,
              style: HeroIconStyle.solid,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: AppColors.lightGray,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
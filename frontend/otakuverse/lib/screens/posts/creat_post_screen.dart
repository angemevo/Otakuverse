import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:otakuverse/services/post_service.dart';
import 'package:otakuverse/services/storage_service.dart';
import 'package:otakuverse/services/storage_upload_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _allowComments = true;
  bool _isLoading = false;
  String? _locationText;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _captionController.dispose();
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
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Localisation bloquée dans les paramètres')),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _locationText = '${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de récupérer la localisation')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // ============================================
  // SÉLECTION D'IMAGES
  // ============================================

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: 10);

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  // ============================================
  // PUBLIER
  // ============================================

  Future<void> _publishPost() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoute une légende')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Récupère l'userId depuis le storage local
      final userData = await StorageService().getUserData();
      final userId = userData?['id'] ?? '';

      // 2. Upload les images vers Supabase Storage
      List<String> mediaUrls = [];
      if (_selectedImages.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📤 Upload des images...')),
        );
        mediaUrls = await StorageUploadService().uploadImages(_selectedImages, userId);
      }

      // 3. Crée le post avec les URLs
      final result = await PostsService().createPost(
        caption: _captionController.text.trim(),
        mediaUrls: mediaUrls,
        location: _locationText,
        allowComments: _allowComments,
      );

      if (!mounted) return;

      if (result['success'] != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Post publié avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Erreur lors de la publication')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Nouveau post', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _publishPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Publier',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 20),
            _buildCaptionField(),
            const SizedBox(height: 16),
            _buildLocationField(),
            const SizedBox(height: 16),
            _buildAllowComments(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS
  // ============================================

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Médias', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('(optionnel)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6C63FF), width: 1.5),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF6C63FF), size: 32),
                      SizedBox(height: 6),
                      Text('Ajouter', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
                    ],
                  ),
                ),
              ),
              ..._selectedImages.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(entry.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4, right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImages.removeAt(entry.key)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_selectedImages.length}/10 images',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCaptionField() {
    return TextField(
      controller: _captionController,
      maxLength: 2200,
      maxLines: 5,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Écris ta légende...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterStyle: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildLocationField() {
    return GestureDetector(
      onTap: _isLoadingLocation ? null : _getLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            Expanded(
              child: _isLoadingLocation
                  ? const SizedBox(
                      height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C63FF)),
                    )
                  : Text(
                      _locationText ?? 'Récupérer ma position',
                      style: TextStyle(
                        color: _locationText != null ? Colors.white : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
            ),
            if (_locationText != null)
              GestureDetector(
                onTap: () => setState(() => _locationText = null),
                child: const Icon(Icons.close, color: Colors.grey, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllowComments() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Autoriser les commentaires', style: TextStyle(color: Colors.white)),
        value: _allowComments,
        activeColor: const Color(0xFF6C63FF),
        onChanged: (val) => setState(() => _allowComments = val),
      ),
    );
  }
}
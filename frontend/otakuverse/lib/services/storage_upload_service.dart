// services/storage_upload_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class StorageUploadService {
  final _supabase = Supabase.instance.client;
  final String _bucketName = 'posts';  // Nom de ton bucket Supabase

  // ============================================
  // UPLOAD AVATAR
  // ============================================
  Future<String> uploadAvatar(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = '${userId}_$timestamp$extension';
      final filePath = 'avatars/$fileName';

      print('📤 Uploading avatar to: $filePath');

      // Upload vers Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,  // Remplace si existe déjà
            ),
          );

      // Récupérer l'URL publique
      final url = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('✅ Avatar uploaded: $url');
      return url;
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      throw Exception('Erreur lors de l\'upload de l\'avatar: $e');
    }
  }

  // ============================================
  // UPLOAD BANNER
  // ============================================
  Future<String> uploadBanner(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = '${userId}_$timestamp$extension';
      final filePath = 'banners/$fileName';

      print('📤 Uploading banner to: $filePath');

      // Upload vers Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Récupérer l'URL publique
      final url = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('✅ Banner uploaded: $url');
      return url;
    } catch (e) {
      print('❌ Error uploading banner: $e');
      throw Exception('Erreur lors de l\'upload de la bannière: $e');
    }
  }

  // ============================================
  // UPLOAD IMAGES DE POST (multiple)
  // ============================================
  Future<List<String>> uploadImages(List<File> files, String userId) async {
    try {
      final List<String> uploadedUrls = [];

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = path.extension(file.path);
        final fileName = '${userId}_${timestamp}_$i$extension';
        final filePath = 'posts/$fileName';

        print('📤 Uploading image $i to: $filePath');

        // Upload vers Supabase Storage
        await _supabase.storage
            .from(_bucketName)
            .upload(
              filePath,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // Récupérer l'URL publique
        final url = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(filePath);

        uploadedUrls.add(url);
        print('✅ Image $i uploaded: $url');
      }

      print('✅ All images uploaded successfully (${uploadedUrls.length})');
      return uploadedUrls;
    } catch (e) {
      print('❌ Error uploading images: $e');
      throw Exception('Erreur lors de l\'upload des images: $e');
    }
  }

  // ============================================
  // SUPPRIMER UN FICHIER
  // ============================================
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Extraire le chemin depuis l'URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      // L'URL est du type: https://.../storage/v1/object/public/posts/avatars/file.jpg
      // On veut récupérer "avatars/file.jpg"
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw Exception('Invalid file URL');
      }
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      print('🗑️ Deleting file: $filePath');

      await _supabase.storage
          .from(_bucketName)
          .remove([filePath]);

      print('✅ File deleted successfully');
    } catch (e) {
      print('❌ Error deleting file: $e');
      // Ne pas throw pour éviter de bloquer l'app si la suppression échoue
    }
  }

  // ============================================
  // SUPPRIMER L'ANCIEN AVATAR (optionnel)
  // ============================================
  Future<void> deleteOldAvatar(String? oldAvatarUrl) async {
    if (oldAvatarUrl == null || oldAvatarUrl.isEmpty) return;
    
    // Ne supprimer que si c'est une URL Supabase (pas Google)
    if (oldAvatarUrl.contains('supabase.co/storage')) {
      await deleteFile(oldAvatarUrl);
    }
  }

  // ============================================
  // SUPPRIMER L'ANCIENNE BANNIÈRE (optionnel)
  // ============================================
  Future<void> deleteOldBanner(String? oldBannerUrl) async {
    if (oldBannerUrl == null || oldBannerUrl.isEmpty) return;
    
    if (oldBannerUrl.contains('supabase.co/storage')) {
      await deleteFile(oldBannerUrl);
    }
  }

  // ============================================
  // MISE A JOUR DES STORIES
  // ============================================
  Future<String> uploadStory(File file, String userId, String mediaType) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = '${userId}_$timestamp$extension';
      final filePath = 'stories/$fileName';

      print('📤 Uploading story to: $filePath');

      await _supabase.storage
          .from(_bucketName)
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final url = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('✅ Story uploaded: $url');
      return url;
    } catch (e) {
      print('❌ Error uploading story: $e');
      throw Exception('Erreur lors de l\'upload de la story: $e');
    }
  }
}
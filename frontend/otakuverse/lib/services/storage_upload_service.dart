import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // UPLOAD UNE IMAGE
  // ============================================
  Future<String?> uploadImage(File file, String userId, {String folder = 'posts'}) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folder/$fileName';

      await _supabase.storage
          .from('posts')
          .upload(path, file, fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ));

      return _supabase.storage.from('posts').getPublicUrl(path);
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }
  

  // ============================================
  // UPLOAD PLUSIEURS IMAGES
  // ============================================
  Future<List<String>> uploadImages(List<File> files, String userId) async {
    final List<String> urls = [];

    for (final file in files) {
      final url = await uploadImage(file, userId);
      if (url != null) urls.add(url);
    }

    return urls;
  }
}
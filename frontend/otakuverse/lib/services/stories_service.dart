// services/stories_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:otakuverse/config/api_config.dart';
import 'package:otakuverse/models/stories/stories_model.dart';
import 'package:otakuverse/services/storage_service.dart';
import 'package:otakuverse/services/storage_upload_service.dart';

class StoriesService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  // ============================================
  // AUTH HEADER
  // ============================================
  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ============================================
  // CRÉER UNE STORY
  // ============================================
  Future<Map<String, dynamic>> createStory({
    required File mediaFile,
    required String mediaType, // 'image' ou 'video'
  }) async {
    try {
      print('📤 Uploading story media...');

      // 1. Upload le fichier
      final userData = await _storage.getUserData();
      final userId = userData?['id'];

      if (userId == null) {
        return {'error': 'User not authenticated'};
      }

      // Upload vers Supabase Storage
      final mediaUrl = await StorageUploadService().uploadStory(
        mediaFile,
        userId,
        mediaType,
      );

      print('✅ Media uploaded: $mediaUrl');

      // 2. Créer la story
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/stories',
        data: {
          'media_url': mediaUrl,
          'media_type': mediaType,
        },
        options: await _authOptions(),
      );

      print('✅ Story created: ${response.data}');

      return {'success': StoryModel.fromJson(response.data)};
    } catch (e) {
      print('❌ Error creating story: $e');
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // RÉCUPÉRER TOUTES LES STORIES
  // ============================================
  Future<Map<String, dynamic>> getAllStories() async {
    try {
      print('🔵 Getting all stories...');

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/stories',
        options: await _authOptions(),
      );

      print('📥 Received ${response.data.length} stories');

      final stories = (response.data as List)
          .map((json) => StoryModel.fromJson(json))
          .toList();

      return {'success': stories};
    } catch (e) {
      print('❌ Error getting stories: $e');
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // RÉCUPÉRER MES STORIES
  // ============================================
  Future<Map<String, dynamic>> getMyStories() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/stories/me',
        options: await _authOptions(),
      );

      final stories = (response.data as List)
          .map((json) => StoryModel.fromJson(json))
          .toList();

      return {'success': stories};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // RÉCUPÉRER LES STORIES D'UN USER
  // ============================================
  Future<Map<String, dynamic>> getUserStories(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/stories/user/$userId',
        options: await _authOptions(),
      );

      final stories = (response.data as List)
          .map((json) => StoryModel.fromJson(json))
          .toList();

      return {'success': stories};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // MARQUER COMME VUE
  // ============================================
  Future<Map<String, dynamic>> viewStory(String storyId) async {
    try {
      await _dio.post(
        '${ApiConfig.baseUrl}/stories/$storyId/view',
        options: await _authOptions(),
      );

      return {'success': true};
    } catch (e) {
      print('❌ Error viewing story: $e');
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // RÉCUPÉRER LES VIEWERS
  // ============================================
  Future<Map<String, dynamic>> getStoryViewers(String storyId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/stories/$storyId/viewers',
        options: await _authOptions(),
      );

      final viewers = (response.data as List)
          .map((json) => StoryViewerModel.fromJson(json))
          .toList();

      return {'success': viewers};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // SUPPRIMER UNE STORY
  // ============================================
  Future<Map<String, dynamic>> deleteStory(String storyId) async {
    try {
      await _dio.delete(
        '${ApiConfig.baseUrl}/stories/$storyId',
        options: await _authOptions(),
      );

      return {'success': true};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // LIKER UNE STORY
  // ============================================
  Future<Map<String, dynamic>> toggleLikeStory(String storyId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/stories/$storyId/like',
        options: await _authOptions(),
      );

      return {'success': response.data['liked']};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // RÉPONDRE À UNE STORY
  // ============================================
  Future<Map<String, dynamic>> replyToStory(String storyId, String message) async {
    try {
      await _dio.post(
        '${ApiConfig.baseUrl}/stories/$storyId/reply',
        data: {'message': message},
        options: await _authOptions(),
      );

      return {'success': true};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // PARTAGER UNE STORY (REPOST)
  // ============================================
  Future<Map<String, dynamic>> repostStory(String storyId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/stories/$storyId/repost',
        options: await _authOptions(),
      );

      return {'success': StoryModel.fromJson(response.data)};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // ERROR HANDLING
  // ============================================
  String _handleError(dynamic e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return 'Non autorisé';
      if (statusCode == 403) return 'Action interdite';
      if (statusCode == 404) return 'Story introuvable';
      
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Erreur serveur';
    }
    return 'Erreur de connexion';
  }
}
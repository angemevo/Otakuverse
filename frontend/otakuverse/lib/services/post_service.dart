import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:otakuverse/config/api_config.dart';
import 'package:otakuverse/models/post_model.dart';
import 'package:otakuverse/services/storage_service.dart';

class PostsService {
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
  // CRÉER UN POST
  // ============================================
  Future<Map<String, dynamic>> createPost({
    required String caption,
    required List<String> mediaUrls,
    String? location,
    bool allowComments = true,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.posts}',
        data: {
          'caption': caption,
          if (mediaUrls.isNotEmpty) 'media_urls': mediaUrls,
          'location': location,
          'allow_comments': allowComments,
        },
        options: await _authOptions(),
      );

      return {'success': PostModel.fromJson(response.data)};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // FEED PRINCIPALE
  // ============================================
  Future<Map<String, dynamic>> getFeed({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.feed}',
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor' : cursor,
        },
        options: await _authOptions()
      );

      final posts = (response.data['data'] as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      return {
        'succes': posts,
        'nextCursor': response.data['next_cursor'],
      };
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // RÉCUPÉRER UN POST
  // ============================================
  Future<Map<String, dynamic>> getPostById(String postId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.getPost}',
        options: await _authOptions(),
      );

      return {'success': PostModel.fromJson(response.data)};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // RÉCUPÉRER LES POSTS D'UN USER
  // ============================================
  Future<Map<String, dynamic>> getPostsByUser(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.getPostUser}',
        options: await _authOptions(),
      );

      final posts = (response.data as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      return {'success': posts};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // TOGGLE LIKE
  // ============================================
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/posts/$postId/like',
        options: await _authOptions(),
      );
      return {'success': response.data};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // VÉRIFIER SI LIKÉ
  // ============================================
  Future<Map<String, dynamic>> hasLiked(String postId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/posts/$postId/liked',
        options: await _authOptions(),
      );
      return {'success': response.data['liked']};
    } catch (e) {
      return {'success': false};
    }
  }

  // ============================================
  // Récupérer les posts likés
  // ============================================
  Future<Map<String, dynamic>> getLikedPosts(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/posts/liked/$userId',
        options: await _authOptions(),
      );
      final posts = (response.data as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
      return {'success': posts};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // INCRÉMENTER COMMENTAIRES
  // ============================================
  Future<Map<String, dynamic>> incrementComment(String postId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/posts/$postId/comment',
        options: await _authOptions(),
      );
      return {'success': response.data};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // MODIFIER UN POST
  // ============================================
  Future<Map<String, dynamic>> updatePost({
    required String postId,
    String? caption,
    String? location,
    bool? allowComments,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/posts/$postId',
        data: {
          if (caption != null) 'caption': caption,
          if (location != null) 'location': location,
          if (allowComments != null) 'allow_comments': allowComments,
        },
        options: await _authOptions(),
      );

      return {'success': PostModel.fromJson(response.data)};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // SUPPRIMER UN POST
  // ============================================
  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      await _dio.delete(
        '${ApiConfig.baseUrl}/posts/$postId',
        options: await _authOptions(),
      );

      return {'success': true};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // ÉPINGLER UN POST
  // ============================================
  Future<Map<String, dynamic>> pinPost(String postId) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/posts/$postId/pin',
        options: await _authOptions(),
      );

      return {'success': response.data};
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
      if (statusCode == 404) return 'Post introuvable';
      final data = e.response?.data;
      if (data is Map) return data['message'] ?? 'Erreur serveur';
      return 'Erreur serveur';
    }
    return 'Erreur inconnue';
  }
}
// services/post_service.dart

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
      print('🔵 Creating post...');
      print('Caption: $caption');
      print('Media URLs: $mediaUrls');
      print('Location: $location');

      final response = await _dio.post(
        '${ApiConfig.baseUrl}/posts',  // ✅ URL correcte
        data: {
          'caption': caption,
          'media_urls': mediaUrls,  // ✅ Toujours envoyer (tableau vide si aucune image)
          'location': location,
          'allow_comments': allowComments,
        },
        options: await _authOptions(),
      );

      print('✅ Post created: ${response.data}');

      return {'success': PostModel.fromJson(response.data)};
    } catch (e) {
      print('❌ Error creating post: $e');
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // RÉCUPÉRER TOUS LES POSTS (FEED)
  // ============================================
  Future<Map<String, dynamic>> getAllPosts({
    int limit = 20,
    int page = 1,
  }) async {
    try {
      print('🔵 Getting all posts (limit: $limit, page: $page)');

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/posts',  // ✅ GET /posts
        queryParameters: {
          'limit': limit,
          'page': page,
        },
        options: await _authOptions(),
      );

      print('📥 Received ${response.data.length} posts');

      final posts = (response.data as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      return {'success': posts};  // ✅ CORRIGÉ (pas 'succes')
    } catch (e) {
      print('❌ Error getting posts: $e');
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // FEED PRINCIPALE (avec pagination cursor)
  // ============================================
  Future<Map<String, dynamic>> getFeed({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/feed',  // ✅ Endpoint feed si implémenté
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
        options: await _authOptions(),
      );

      final posts = (response.data['data'] as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      return {
        'success': posts,  // ✅ CORRIGÉ
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
        '${ApiConfig.baseUrl}/posts/$postId',  // ✅ URL correcte
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
        '${ApiConfig.baseUrl}/posts/user/$userId',  // ✅ URL correcte
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
      print('🔵 Checking if liked: $postId');
      
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/posts/$postId/liked',
        options: await _authOptions(),
      );
      
      print('📥 hasLiked response: ${response.data}');
      print('📥 hasLiked type: ${response.data.runtimeType}');
      
      // ✅ Le backend retourne directement un boolean
      bool isLiked = false;
      
      // ✅ CORRECTION : Gérer TOUS les cas possibles
      if (response.data is bool) {
        // Cas 1 : Boolean direct
        isLiked = response.data as bool;
      } else if (response.data is Map) {
        // Cas 2 : Objet avec propriété 'liked'
        isLiked = response.data['liked'] as bool? ?? false;
      } else if (response.data is String) {
        // Cas 3 : String 'true' ou 'false'
        isLiked = response.data.toString().toLowerCase() == 'true';
      } else if (response.data is int) {
        // Cas 4 : 0 ou 1
        isLiked = response.data == 1;
      } else {
        // Cas 5 : Autres types (null, etc.)
        print('⚠️ Unexpected response type: ${response.data.runtimeType}');
        isLiked = false;
      }
      
      print('✅ isLiked: $isLiked');
      
      return {'success': isLiked};
    } catch (e, stackTrace) {
      print('❌ Error checking like: $e');
      print('Stack trace: $stackTrace');
      return {'success': false};
    }
  }

  // ============================================
  // RÉCUPÉRER LES POSTS LIKÉS PAR MOI
  // ============================================
  Future<Map<String, dynamic>> getLikedPosts() async {  // ✅ Pas besoin de userId
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/posts/liked/me',  // ✅ Route correcte
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
        '${ApiConfig.baseUrl}/posts/$postId/comments',  // ✅ Endpoint correct
        data: {'content': ''},  // TODO: À implémenter correctement avec le contenu
        options: await _authOptions(),
      );
      return {'success': response.data};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // INCRÉMENTER VUES
  // ============================================
  Future<Map<String, dynamic>> incrementViews(String postId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/posts/$postId/views',
        options: await _authOptions(),
      );
      return {'success': response.data};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // ============================================
  // INCRÉMENTER PARTAGES
  // ============================================
  Future<Map<String, dynamic>> incrementShares(String postId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/posts/$postId/shares',
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
      final response = await _dio.post(  // ✅ POST, pas PATCH
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
      print('❌ DioException: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return 'Non autorisé. Reconnectez-vous.';
      if (statusCode == 403) return 'Action interdite';
      if (statusCode == 404) return 'Post introuvable';
      
      final data = e.response?.data;
      if (data is Map) {
        if (data['message'] != null) {
          // Si c'est un tableau de messages
          if (data['message'] is List) {
            return (data['message'] as List).join(', ');
          }
          return data['message'].toString();
        }
        if (data['error'] != null) return data['error'].toString();
      }
      return 'Erreur serveur (${statusCode ?? 'inconnu'})';
    }
    return 'Erreur de connexion';
  }
}
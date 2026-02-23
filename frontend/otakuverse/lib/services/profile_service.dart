import 'package:dio/dio.dart';
import 'package:otakuverse/config/api_config.dart';
import 'package:otakuverse/models/profile_model.dart';
import 'package:otakuverse/services/storage_service.dart';

class ProfileService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Mon profil
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/profiles/me',
        options: await _authOptions(),
      );
      return {'success': ProfileModel.fromJson(response.data)};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // Profil d'un autre user
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/profiles/$userId',
        options: await _authOptions(),
      );
      return {'success': ProfileModel.fromJson(response.data)};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // Modifier mon profil
  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
    String? birthDate,
    String? gender,
    String? location,
    String? website,
    List<String>? favoriteAnime,
    List<String>? favoriteManga,
    List<String>? favoriteGenres,
    bool? isPrivate,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/profiles/me',
        data: {
          if (displayName != null) 'display_name': displayName,
          if (bio != null) 'bio': bio,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (bannerUrl != null) 'banner_url': bannerUrl,
          if (birthDate != null) 'birth_date': birthDate,
          if (gender != null) 'gender': gender,
          if (location != null) 'location': location,
          if (website != null) 'website': website,
          if (favoriteAnime != null) 'favorite_anime': favoriteAnime,
          if (favoriteManga != null) 'favorite_manga': favoriteManga,
          if (favoriteGenres != null) 'favorite_genres': favoriteGenres,
          if (isPrivate != null) 'is_private': isPrivate,
        },
        options: await _authOptions(),
      );
      return {'success': ProfileModel.fromJson(response.data)};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  // Toggle privé/public
  Future<Map<String, dynamic>> togglePrivacy() async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/profiles/me/privacy',
        options: await _authOptions(),
      );
      return {'success': response.data};
    } catch (e) {
      return {'error': _handleError(e)};
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return 'Non autorisé';
      if (statusCode == 404) return 'Profil introuvable';
      final data = e.response?.data;
      if (data is Map) return data['message'] ?? 'Erreur serveur';
      return 'Erreur serveur';
    }
    return 'Erreur inconnue';
  }
}
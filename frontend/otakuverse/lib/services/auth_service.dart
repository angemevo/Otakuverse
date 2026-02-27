import 'package:dio/dio.dart';
import 'package:otakuverse/config/api_config.dart';
import 'package:otakuverse/services/storage_service.dart';

class AuthService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String username,
    required String dateOfBirth,
    required String gender,
    String? phone,
    String? location,
    String? avatarUrl
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/signup',
        data: {
          'email': email,
          'password': password,
          'username': username,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'phone': phone,
          'location': location,
          'avatar_url': avatarUrl,
        },
      );

      final token = response.data['token'] as String;
      final user = response.data['user'] as Map<String, dynamic>;

      await _storage.saveToken(token);
      await _storage.savedUserId(user['id']);
      await _storage.saveUserData(user);

      return {'success': true, 'token': token, 'user': user};
    } catch (e) {
      return {'success': false, 'error': _parseError(e)};
    }
  }

  Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/signin',
        data: {'email': email, 'password': password},
      );

      print(response.data);

      final token = response.data['token'] as String;
      final user = response.data['user'] as Map<String, dynamic>;

      await _storage.saveToken(token);
      await _storage.savedUserId(user['id']);
      await _storage.saveUserData(user);

      return {'success': true, 'token': token, 'user': user};
    } catch (e) {
      return {'success': false, 'error': _parseError(e)};
    }
  }

  Future<Map<String, dynamic>> signinWithGoogle({
    required String sub,
    required String email,
    String? displayName,
    String? photoUrl,
    String? location,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/google',
        data: {
          'sub': sub,
          'email': email,
          'displayName': displayName,
          'photoUrl': photoUrl,
          'location': location,
        },
      );

      final token = response.data['token'] as String;
      final user = response.data['user'] as Map<String, dynamic>;

      await _storage.saveToken(token);
      await _storage.savedUserId(user['id']);
      await _storage.saveUserData(user);

      return {'success': true, 'token': token, 'user': user};
    } catch (e) {
      return {'success': false, 'error': _parseError(e)};
    }
  }

  Future<Map<String, dynamic>> updateOnboarding({
    required List<String> favoriteAnimes,
    required List<String> favoriteGames,
  }) async {
    try {
      final token = await _storage.getToken();

      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/onboarding',
        data: {
          'favorite_animes': favoriteAnimes,
          'favorite_games': favoriteGames,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'error': _parseError(e)};
    }
  }

  Future<void> signout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  Future<String?> getCurrentToken() async {
    return await _storage.getToken();
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    return await _storage.getUserData();
  }

  // Extraire le message d'erreur lisible depuis DioException
  String _parseError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        return msg is List ? msg.join(', ') : msg.toString();
      }
    }
    return 'Une erreur est survenue';
  }
}
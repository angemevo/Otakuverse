import 'package:dio/dio.dart';
import 'package:otakuverse/config/api_config.dart';
import 'package:otakuverse/services/storage_service.dart';

class AuthService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  // Inscription
  Future<Map<String, dynamic>> signup ({
    required String email,
    required String password,
    required String username,
    String? displayName
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/signup',
        data: {
          'email': email,
          'password': password,
          'username': username,
          'display_name': displayName,
        },
      );

      // Récuperer le token et user
      final token = response.data['token'] as String;
      final user = response.data['user'] as Map<String, dynamic>;

      // Sauvegarder dans le stockage sécurisé
      await _storage.saveToken(token);
      await _storage.savedUserId(user['id']);
      await _storage.saveUserData(user);

      print('✅ Signup successful, data saved');

      return {
        'success' : user,
        'token' : token,
        'user': user,
      };
    } catch (e) {
      print('❌ Signup error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Connexion
  Future<Map<String, dynamic>> signin ({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/signin',
        data: {
          'email': email,
          'password': password,
        }
      );

      // Récuperer le token et user
      final token = response.data['token'] as String;
      final user = response.data['user'] as Map<String, dynamic>;

      // Sauvegarder dans le stockage sécurisé
      await _storage.saveToken(token);
      await _storage.savedUserId(user['id']);
      await _storage.saveUserData(user);

      print('✅ Signin successful, data saved');

      return {
        'success' : user,
        'token' : token,
        'user': user,
      };
    } catch (e) {
      print('❌ Signin error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Déconnexion
  Future<void> signout() async {
    await _storage.clearAll();
    print('✅ User signed out, data cleared');
  }

  // Vérifier si l'utilisateur est authentifié
  Future<bool> isloggedIn() async {
    return await _storage.hasToken();
  }

  // recupérer le token actuel
  Future<String?> getCurrentToken() async {
    return await _storage.getToken();
  }

  // recupérer les données utilisateur actuelles
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    return await _storage.getUserData();
  }
}
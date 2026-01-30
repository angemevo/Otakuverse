import 'package:dio/dio.dart';
import 'package:otakuverse/config/api_config.dart';
import 'package:otakuverse/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  // Initialisation avec interceptor
  Future<void> init() async {
    _dio.options.baseUrl = ApiConfig.baseUrl;

    // Interceptor pour récupérer le token automatiquement
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (option, handler) async {
          //Ajouter le token à chaque requête si disponible
          final token = await _storage.getToken();
          if (token != null) {
            option.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(option);
        },
        onError: (error, handler) async {
          // Si erreur 401 -> deconnexion
          if (error.response?.statusCode == 401) {
            await _storage.clearAll();
            print('❌ Unauthorized! User logged out.');

            // TODO: Naviguer vers l'écran de connexion
          }
          return handler.next(error);
        }
      )
    );
  }

  Dio get client => _dio;
}
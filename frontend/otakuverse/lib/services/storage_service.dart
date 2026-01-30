import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:otakuverse/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService.internal();
  factory StorageService() => _instance;
  StorageService.internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Initialser ShardedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ StorageService initialized');
  }

  // ============================================
  // AUTH - Token JWT (Sécurisé)
  // ============================================

  // Sauvegarder un token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
    print('Token saved securely');
  }

  // Récupérer un token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  // Vérifier si un token existe
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Supprimer un token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    print('Token deleted securely');
  }

  // ============================================
  // USER DATA (Sécurisé)
  // ============================================

  // Sauvegarder l'ID utilisateur
  Future<void> savedUserId(String userId) async {
    await _secureStorage.write(key: AppConstants.userIdKey, value: userId);
    print('User ID saved securely');
  } 

  // Récupérer l'ID utilisateur
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppConstants.userIdKey);
  }

  // Sauvegarder les données complètes de l'utilisateur
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _secureStorage.write(key: AppConstants.userDatakey, value: jsonString);
    print('User data saved securely');
  }

  // Récupérer les données complètes de l'utilisateur
  Future<Map<String,dynamic>?> getUserData() async {
    final jsonString = await _secureStorage.read(key: AppConstants.userDatakey);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding user data: $e');
      return null;
    }
  }

  // Supprimer les données utilisateur
  Future<void> deleteUserData() async {
    await _secureStorage.delete(key: AppConstants.userIdKey);
    await _secureStorage.delete(key: AppConstants.userDatakey);
    print('User data deleted securely');
  }

  // ============================================
  // PREFERENCES (Non sécurisé, mais rapide)
  // ============================================

  // Sauvegarder le thème 
  Future<void> saveThemeMode(String mode) async {
    await _prefs?.setString(AppConstants.themeModeKey, mode);
  }

  // Récupérer le thème
  String getThemeMode()  {
    return _prefs?.getString(AppConstants.themeModeKey) ?? 'system';
  }

  // Sauvegarder la langue
  Future<void> saveLanguage(String languageCode) async {
    await _prefs?.setString(AppConstants.languageKey, languageCode);
  }

  // Récupérer la langue
  String getLanguage() {
    return _prefs?.getString(AppConstants.languageKey) ?? 'fr';
  }

  // Vérifier si c'est la première ouverture 
  bool isFirstLaunch() {
    return _prefs?.getBool(AppConstants.onboardingCompletedKey) ?? true;
  }

  // Marquer commE deja ouvert
  Future<void> isNotFirstLaunch() async {
    await _prefs?.setBool(AppConstants.onboardingCompletedKey, false);
  }

  // ============================================
  // LOGOUT COMPLET
  // ============================================

  Future<void> clearAll() async {
    await deleteToken();
    await deleteUserData();

    // Clear SharedPreferences(optionnel)
    // await _prefs?.clear();
    print('All storage cleared');
  }

  // ============================================
  // DEBUG
  // ============================================

  // Afficher toutes les clés stockées (debug)
  Future<void> printAllData() async {
    print('\n🔍 === STORAGE DEBUG ===');
    
    final token = await getToken();
    print('Token: ${token?.substring(0, 20)}...');
    
    final userId = await getUserId();
    print('User ID: $userId');
    
    final userData = await getUserData();
    print('User data: $userData');
    
    print('Theme: ${getThemeMode()}');
    print('Language: ${getLanguage()}');
    print('First launch: ${isFirstLaunch()}');
    
    print('======================\n');
  }
}
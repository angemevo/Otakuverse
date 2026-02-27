// lib/config/api_config.dart
import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  // ============================================
  // ENVIRONNEMENT
  // ============================================
  
  static const bool isProduction = false; // ← Change en true pour prod
  
  // ============================================
  // BASE URL
  // ============================================
  
  static String get baseUrl {
    if (isProduction) {
      return 'https://api.otakuverse.com';
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid) {
      return 'http://192.168.1.3:3000'; // IP de ton PC
    }

    if (Platform.isIOS) {
      return 'http://192.168.1.3:3000';
    }

    return 'http://192.168.1.3:3000';
  }
  
  // ============================================
  // AUTH ENDPOINTS
  // ============================================
  
  static String get signup => '$baseUrl/auth/signup';
  static String get signin => '$baseUrl/auth/signin';
  static String get signout => '$baseUrl/auth/signout';
  static String get authMe => '$baseUrl/auth/me';
  
  // ============================================
  // USERS ENDPOINTS
  // ============================================
  
  static String getUser(String userId) => '$baseUrl/users/$userId';
  static String updateUser(String userId) => '$baseUrl/users/$userId';
  static String deleteUser(String userId) => '$baseUrl/users/$userId';
  
  // ============================================
  // POSTS ENDPOINTS
  // ============================================
  
  static String get posts => '$baseUrl/posts';
  static String get createPost => '$baseUrl/posts';
  static String getPost(String postId) => '$baseUrl/posts/$postId';
  static String updatePost(String postId) => '$baseUrl/posts/$postId';
  static String deletePost(String postId) => '$baseUrl/posts/$postId';
  static String get feed => '$baseUrl/posts/feed';
  
  // ============================================
  // LIKES ENDPOINTS
  // ============================================
  
  static String likePost(String postId) => '$baseUrl/posts/$postId/like';
  static String unlikePost(String postId) => '$baseUrl/posts/$postId/like';
  
  // ============================================
  // COMMENTS ENDPOINTS
  // ============================================
  
  static String getPostComments(String postId) => '$baseUrl/posts/$postId/comments';
  static String createComment(String postId) => '$baseUrl/posts/$postId/comments';
  static String updateComment(String commentId) => '$baseUrl/comments/$commentId';
  static String deleteComment(String commentId) => '$baseUrl/comments/$commentId';
  
  // ============================================
  // FOLLOWS ENDPOINTS
  // ============================================
  
  static String followUser(String userId) => '$baseUrl/users/$userId/follow';
  static String unfollowUser(String userId) => '$baseUrl/users/$userId/follow';
  
  // ============================================
  // SUPABASE (si utilisé côté Flutter)
  // ============================================
  
  static String get supabaseUrl => 'https://your-project.supabase.co';
  static String get supabaseAnonKey => 'your-anon-key';
}
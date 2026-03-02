import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseGoogleAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<User?> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.otakuverse://login-callback/',
      );

      // Après redirection, récupérer l'utilisateur
      return _client.auth.currentUser;
    } catch (e) {
      print("Erreur Google Sign-In Supabase : $e");
      return null;
    }
  }
}
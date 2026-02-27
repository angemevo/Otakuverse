import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseGoogleAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Retourne les données de l'utilisateur ou null si échec
  Future<User?> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithProvider(
        Provider.google,
        options: AuthOptions(
          redirectTo: 'io.supabase.otakuverse://login-callback/', // ton deep link
        ),
      );
      return response.user; // Supabase User
    } catch (e) {
      print("Erreur Google Sign-In Supabase : $e");
      return null;
    }
  }
}
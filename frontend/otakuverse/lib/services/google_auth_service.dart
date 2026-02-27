import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Lance le flow Google Sign-In et retourne les données utilisateur
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Déconnexion préalable si tu veux forcer le choix du compte
      // await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Annulé par l'utilisateur

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      return {
        'sub': googleUser.id,                     // Google user ID
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
        'idToken': googleAuth.idToken,           // Token JWT Google (optionnel)
        'accessToken': googleAuth.accessToken,   // Token OAuth (optionnel)
      };
    } catch (e) {
      debugPrint('Erreur Google Sign-In: $e');
      return null;
    }
  }

  /// Déconnexion Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Erreur déconnexion Google: $e');
    }
  }
}
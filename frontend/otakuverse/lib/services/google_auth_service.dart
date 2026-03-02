import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Se connecter avec Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔵 GoogleAuthService: Début sign in...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ GoogleAuthService: Sign in annulé');
        return null;
      }

      print('✅ GoogleAuthService: User obtenu');
      print('Email: ${googleUser.email}');
      print('DisplayName: ${googleUser.displayName}');
      print('ID: ${googleUser.id}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('✅ GoogleAuthService: Auth obtenue');
      print('ID Token présent: ${googleAuth.idToken != null}');
      print('Access Token présent: ${googleAuth.accessToken != null}');

      final result = {
        'sub': googleUser.id,  // ✅ ID Google
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
        'idToken': googleAuth.idToken,
        'accessToken': googleAuth.accessToken,
      };

      print('✅ GoogleAuthService: Retour data: $result');
      
      return result;
    } catch (e) {
      print('❌ GoogleAuthService erreur: $e');
      return null;
    }
  }
  
  /// Se déconnecter de Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Déconnexion Google réussie');
    } catch (e) {
      print('❌ Erreur déconnexion Google: $e');
    }
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Obtenir l'utilisateur actuel
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}

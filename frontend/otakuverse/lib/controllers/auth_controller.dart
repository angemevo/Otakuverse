import 'package:get/get.dart';
import 'package:otakuverse/services/auth_service.dart';
import 'package:otakuverse/services/google_auth_service.dart';
import 'package:otakuverse/services/location_service.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/screens/navigation_page.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final LocationService _locationService = LocationService();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final errorMessage = RxnString();

  /// Login avec email/password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await _authService.signin(
        email: email,
        password: password,
      );

      if (result['success'] == false) {
        errorMessage.value = result['error'];
        return false;
      }

      // Navigate to main page
      Helpers.navigateReplace(NavigationPage());
      return true;
    } catch (e) {
      errorMessage.value = 'Erreur de connexion: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login avec Google
  Future<bool> loginWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final googleData = await _googleAuthService.signInWithGoogle();
      if (googleData == null) {
        errorMessage.value = 'Connexion Google annulée';
        return false;
      }

      final location = await _locationService.getLocation();

      final result = await _authService.signinWithGoogle(
        sub: googleData['sub'],
        email: googleData['email'],
        displayName: googleData['displayName'],
        photoUrl: googleData['photoUrl'],
        location: location,
      );

      if (result['success'] == true) {
        return true;
      } else {
        errorMessage.value = result['error'] ?? 'Erreur Google Sign-In';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Erreur Google Sign-In: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
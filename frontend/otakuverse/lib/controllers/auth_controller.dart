import 'package:get/get.dart';
import 'package:otakuverse/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;
  final errorMessage = RxnString();

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

      return true;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
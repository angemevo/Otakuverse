import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:otakuverse/core/constants/assets.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/screens/auth/signup_screen.dart';
import 'package:otakuverse/screens/navigation_page.dart';
import 'package:otakuverse/services/api_service.dart';
import 'package:otakuverse/services/auth_service.dart';
import 'package:otakuverse/services/storage_service.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();

  await StorageService().init();
  await ApiService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Otakuverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Attendre 2 secondes pour simuler un écran de splash
    await Future.delayed(const Duration(seconds: 2));

    // Vérifier si l'utilisateur est authentifié
    final isLogged = await _authService.isloggedIn();

    if (!mounted) return;

    if (isLogged) {
      // Naviguer vers l'écran principal
      print('User is logged in, navigate to HomeScreen');
      Helpers.navigateReplace(NavigationPage());

    } else {
      // Naviguer vers l'écran de connexion
      print('User is not logged in, navigate to SignInScreen');
      Helpers.navigateReplace(SignUpScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Otakuverse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepBlack),),
            const SizedBox(height: 20),
            
            Image.asset(AppAssets.logo, scale: 3),
            const SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
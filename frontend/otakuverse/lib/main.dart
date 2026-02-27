import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:otakuverse/core/constants/assets.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/screens/auth/sign_in_screen.dart';
import 'package:otakuverse/screens/navigation_page.dart';
import 'package:otakuverse/services/api_service.dart';
import 'package:otakuverse/services/auth_service.dart';
import 'package:otakuverse/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();

  // ✅ Charger les variables d'environnement
  await dotenv.load(fileName: '.env');

  await initializeDateFormatting('fr_FR', null);
  await StorageService().init();
  await ApiService().init();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Otakuverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.crimsonRed),
        scaffoldBackgroundColor: AppColors.deepBlack,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    await Future.delayed(const Duration(seconds: 2));

    try {
      final isLogged = await _authService.isLoggedIn(); // ✅ camelCase corrigé

      if (!mounted) return;

      if (isLogged) {
        Helpers.navigateReplace(NavigationPage());
      } else {
        Helpers.navigateReplace(SignInScreen()); // ✅ vers SignIn, pas SignUp
      }
    } catch (e) {
      // En cas d'erreur on redirige vers SignIn par sécurité
      if (!mounted) return;
      Helpers.navigateReplace(SignInScreen());
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
            Image.asset(AppAssets.logo, scale: 3),
            const SizedBox(height: 32),
            const Text(
              'Otakuverse',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white, // ✅ CORRIGÉ — était deepBlack sur deepBlack
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.crimsonRed),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/web_config.dart';
import 'core/config/mobile_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/cache_service.dart';
import 'core/widgets/splash_screen.dart';
import 'modulo/pokemon/presentation/views/pokedex_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final cacheService = CacheService();
  await cacheService.init();
  await cacheService.clearExpiredCache();

  WebConfig.configure();
  MobileConfig.configure();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreenWrapper(),
    );
  }
}

/// Wrapper para manejar la navegación desde el splash screen
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _showSplash = true;

  void _navigateToHome() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onAnimationComplete: _navigateToHome);
    }
    return const PokedexView();
  }
}

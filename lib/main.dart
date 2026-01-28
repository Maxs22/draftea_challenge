import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/web_config.dart';
import 'core/config/mobile_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/cache_service.dart';
import 'modulo/pokemon/presentation/views/pokedex_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para caché local
  await Hive.initFlutter();
  
  // Inicializar servicio de caché
  final cacheService = CacheService();
  await cacheService.init();
  
  // Limpiar caché expirado al iniciar
  await cacheService.clearExpiredCache();
  
  // Configurar según la plataforma
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
      home: const PokedexView(),
    );
  }
}

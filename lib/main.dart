import 'package:flutter/material.dart';
import 'core/config/web_config.dart';
import 'core/config/mobile_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'modulo/pokemon/presentation/views/pokedex_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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

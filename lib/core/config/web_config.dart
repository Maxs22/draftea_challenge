import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Configuración específica para Flutter Web
class WebConfig {
  WebConfig._();

  /// Configuración inicial para la plataforma web
  static void configure() {
    if (kIsWeb) {
      // Configuraciones específicas para web
      debugPrint('Configuración Web inicializada');
    }
  }

  /// Obtiene el ancho de la pantalla para determinar el layout
  static bool isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Obtiene el ancho de la pantalla para determinar si es tablet
  static bool isTabletLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Obtiene el ancho de la pantalla para determinar si es desktop
  static bool isDesktopLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Verifica si está en modo landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Obtiene el número de columnas según el tamaño de pantalla
  static int getGridColumnCount(BuildContext context) {
    if (isDesktopLayout(context)) {
      return 4;
    } else if (isTabletLayout(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  /// Configuración de scrollbar para web
  static ScrollbarThemeData getScrollbarTheme() {
    return const ScrollbarThemeData(
      thickness: MaterialStatePropertyAll(8.0),
      radius: Radius.circular(4.0),
      crossAxisMargin: 2.0,
      mainAxisMargin: 2.0,
    );
  }
}

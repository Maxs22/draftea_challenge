import 'package:flutter/material.dart';

/// Configuración específica para plataformas móviles (iOS/Android)
class MobileConfig {
  MobileConfig._();

  /// Configuración inicial para plataformas móviles
  static void configure() {
    debugPrint('Configuración Mobile inicializada');
  }

  /// Verifica si está en modo landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Obtiene el ancho de la pantalla para determinar el layout
  static bool isTabletLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600;
  }

  /// Obtiene el número de columnas según el tamaño de pantalla
  static int getGridColumnCount(BuildContext context) {
    if (isTabletLayout(context)) {
      return isLandscape(context) ? 4 : 3;
    } else {
      return isLandscape(context) ? 3 : 2;
    }
  }

  /// Configuración de safe area para mobile
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Configuración de AppBar para mobile
  static PreferredSizeWidget getAppBar({
    required String title,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: Text(title),
      actions: actions,
      centerTitle: true,
      elevation: 0,
    );
  }
}

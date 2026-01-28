import 'package:flutter/material.dart';

/// Constantes de colores de la aplicación
/// Estilo DRAFTEA - Tema oscuro con acentos púrpura y gradientes verde-amarillo
class AppColors {
  AppColors._();

  // Colores primarios (tema DRAFTEA)
  static const Color primaryPurple = Color(0xFF6B46C1); // Púrpura oscuro del header
  static const Color primaryRed = Color(0xFFDC0A2D); // Rojo principal de Pokédex (mantener para compatibilidad)
  static const Color primaryBlue = Color(0xFF356ABC); // Azul de Pokémon
  static const Color primaryYellow = Color(0xFFFFCB05); // Amarillo de Pokémon

  // Colores secundarios
  static const Color secondaryRed = Color(0xFFEF4444);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color secondaryYellow = Color(0xFFFCD34D);

  // Colores de fondo (estilo DRAFTEA - oscuro)
  static const Color backgroundLight = Color(0xFF000000); // Negro profundo
  static const Color backgroundDark = Color(0xFF000000); // Negro profundo
  static const Color surfaceLight = Color(0xFF1A1A1A); // Gris muy oscuro para cards
  static const Color surfaceDark = Color(0xFF1A1A1A); // Gris muy oscuro para cards
  static const Color headerBackground = Color(0xFF6B46C1); // Púrpura oscuro del header

  // Colores de texto (estilo DRAFTEA)
  static const Color textPrimary = Color(0xFFFFFFFF); // Blanco para texto principal
  static const Color textSecondary = Color(0xFF9CA3AF); // Gris claro para texto secundario
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF111827);

  // Colores de estado
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color liveRed = Color(0xFFEF4444); // Rojo para indicadores LIVE

  // Colores de tipos de Pokémon (para uso futuro)
  static const Color typeNormal = Color(0xFFA8A878);
  static const Color typeFire = Color(0xFFF08030);
  static const Color typeWater = Color(0xFF6890F0);
  static const Color typeElectric = Color(0xFFF8D030);
  static const Color typeGrass = Color(0xFF78C850);
  static const Color typeIce = Color(0xFF98D8D8);
  static const Color typeFighting = Color(0xFFC03028);
  static const Color typePoison = Color(0xFFA040A0);
  static const Color typeGround = Color(0xFFE0C068);
  static const Color typeFlying = Color(0xFFA890F0);
  static const Color typePsychic = Color(0xFFF85888);
  static const Color typeBug = Color(0xFFA8B820);
  static const Color typeRock = Color(0xFFB8A038);
  static const Color typeGhost = Color(0xFF705898);
  static const Color typeDragon = Color(0xFF7038F8);
  static const Color typeDark = Color(0xFF705848);
  static const Color typeSteel = Color(0xFFB8B8D0);
  static const Color typeFairy = Color(0xFFEE99AC);

  // Colores de gradientes (estilo DRAFTEA)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryPurple,
      Color(0xFF8B5CF6),
    ],
  );

  // Gradiente del header: violeta a negro
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryPurple,
      Color(0xFF4C1D95), // Violeta más oscuro
      Color(0xFF1A1A1A), // Casi negro
      backgroundDark, // Negro profundo
    ],
  );

  // Gradiente verde-amarillo para odds/multiplicadores (estilo DRAFTEA)
  static const LinearGradient oddsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Verde
      Color(0xFFFFCB05), // Amarillo
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundDark,
      Color(0xFF0A0A0A),
    ],
  );

  // Colores de sombra
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  
  // Color para tabs seleccionados (estilo DRAFTEA)
  static const Color selectedTabBackground = primaryPurple;
  static const Color unselectedTabText = Color(0xFFFFFFFF);
}

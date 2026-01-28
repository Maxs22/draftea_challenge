/// Constantes generales de la aplicación Pokédex
class AppConstants {
  AppConstants._();

  // API Configuration
  static const String apiBaseUrl = 'https://pokeapi.co/api/v2';
  static const String pokemonEndpoint = '/pokemon';
  static const int defaultPageLimit = 20;
  static const int maxPokemonCount = 1302; // Total aproximado de Pokémon

  // Paginación
  static const int initialOffset = 0;
  static const int itemsPerPage = 20;

  // Cache Configuration
  static const String cacheBoxName = 'pokedex_cache';
  static const Duration cacheExpirationDuration = Duration(hours: 24);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double appBarHeight = 56.0;

  // Breakpoints para responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Image Configuration
  static const String pokemonImageBaseUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';
  static const String pokemonThumbnailBaseUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

  // Error Messages
  static const String errorNetworkMessage =
      'Error de conexión. Verifica tu internet.';
  static const String errorGenericMessage =
      'Ocurrió un error inesperado. Intenta nuevamente.';
  static const String errorEmptyMessage = 'No se encontraron Pokémon.';

  // App Info
  static const String appName = 'Pokédex';
  static const String appVersion = '1.0.0';
}

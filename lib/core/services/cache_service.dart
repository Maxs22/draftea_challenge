import 'package:hive_flutter/hive_flutter.dart';
import '../../modulo/pokemon/data/models/pokemon_model.dart';
import '../../modulo/pokemon/data/models/pokemon_list_response_model.dart';
import '../constants/app_constants.dart';

/// Servicio para manejar el caché local de datos
class CacheService {
  static const String _pokemonListBoxName = 'pokemon_list_cache';
  static const String _pokemonDetailBoxName = 'pokemon_detail_cache';
  static const String _cacheTimestampKey = 'cache_timestamp';

  static CacheService? _instance;
  Box? _pokemonListBox;
  Box? _pokemonDetailBox;
  bool _isInitialized = false;

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Constructor privado para singleton
  CacheService._();

  /// Obtiene la instancia singleton del servicio de caché
  factory CacheService() {
    _instance ??= CacheService._();
    return _instance!;
  }

  /// Inicializa las cajas de Hive para el caché
  Future<void> init() async {
    if (_isInitialized) return;
    
    _pokemonListBox = await Hive.openBox(_pokemonListBoxName);
    _pokemonDetailBox = await Hive.openBox(_pokemonDetailBoxName);
    _isInitialized = true;
  }

  /// Guarda la lista de Pokémon en caché
  Future<void> cachePokemonList(
    PokemonListResponseModel response,
    int offset,
  ) async {
    // Asegurar que esté inicializado
    if (!_isInitialized) {
      await init();
    }
    
    if (_pokemonListBox == null) return;

    // Guardar la lista con clave basada en offset
    await _pokemonListBox!.put(
      'list_$offset',
      {
        'results': response.results.map((p) => p.toJson()).toList(),
        'next': response.next,
        'previous': response.previous,
        'count': response.count,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Guardar timestamp de última actualización
    await _pokemonListBox!.put(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Obtiene la lista de Pokémon desde caché
  PokemonListResponseModel? getCachedPokemonList(int offset) {
    // Asegurar que esté inicializado
    if (!_isInitialized) {
      // Si no está inicializado, retornar null
      return null;
    }
    
    if (_pokemonListBox == null) return null;

    final cachedData = _pokemonListBox!.get('list_$offset');
    if (cachedData == null) return null;

    final data = cachedData as Map<dynamic, dynamic>;
    final timestamp = data['timestamp'] as int;
    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

    // Verificar si el caché no ha expirado (24 horas)
    if (cacheAge > AppConstants.cacheExpirationDuration.inMilliseconds) {
      return null;
    }

    try {
      final results = (data['results'] as List)
          .map((json) => PokemonModel.fromListJson(json as Map<String, dynamic>))
          .toList();

      return PokemonListResponseModel(
        results: results,
        next: data['next'] as String?,
        previous: data['previous'] as String?,
        count: data['count'] as int? ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  /// Guarda el detalle de un Pokémon en caché
  Future<void> cachePokemonDetail(PokemonModel pokemon) async {
    // Asegurar que esté inicializado
    if (!_isInitialized) {
      await init();
    }
    
    if (_pokemonDetailBox == null) return;

    await _pokemonDetailBox!.put(
      'detail_${pokemon.id}',
      {
        'pokemon': pokemon.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Obtiene el detalle de un Pokémon desde caché
  PokemonModel? getCachedPokemonDetail(String idOrName) {
    // Asegurar que esté inicializado (síncrono para no cambiar la firma)
    if (!_isInitialized) {
      // Si no está inicializado, intentar inicializar de forma síncrona
      // En este caso, retornar null ya que no podemos esperar
      return null;
    }
    
    if (_pokemonDetailBox == null) return null;

    // Intentar buscar por ID primero
    int? id = int.tryParse(idOrName);
    if (id != null) {
      final cachedData = _pokemonDetailBox!.get('detail_$id');
      if (cachedData != null) {
        return _parseCachedDetail(cachedData);
      }
    }

    // Si no se encuentra por ID, buscar por nombre (iterar todas las entradas)
    for (var key in _pokemonDetailBox!.keys) {
      if (key.toString().startsWith('detail_')) {
        final cachedData = _pokemonDetailBox!.get(key);
        if (cachedData != null) {
          final pokemon = _parseCachedDetail(cachedData);
          if (pokemon != null && pokemon.name.toLowerCase() == idOrName.toLowerCase()) {
            return pokemon;
          }
        }
      }
    }

    return null;
  }

  PokemonModel? _parseCachedDetail(dynamic cachedData) {
    try {
      final data = cachedData as Map<dynamic, dynamic>;
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      // Verificar si el caché no ha expirado (24 horas)
      if (cacheAge > AppConstants.cacheExpirationDuration.inMilliseconds) {
        return null;
      }

      final pokemonJson = data['pokemon'] as Map<String, dynamic>;
      
      // Reconstruir el modelo completo desde el JSON guardado
      return PokemonModel(
        id: pokemonJson['id'] as int,
        name: pokemonJson['name'] as String,
        imageUrl: pokemonJson['imageUrl'] as String,
        thumbnailUrl: pokemonJson['thumbnailUrl'] as String?,
        height: pokemonJson['height'] as int?,
        weight: pokemonJson['weight'] as int?,
        types: pokemonJson['types'] != null
            ? List<String>.from(pokemonJson['types'] as List)
            : null,
        abilities: pokemonJson['abilities'] != null
            ? List<String>.from(pokemonJson['abilities'] as List)
            : null,
        baseExperience: pokemonJson['baseExperience'] as int?,
      );
    } catch (e) {
      return null;
    }
  }

  /// Limpia todo el caché
  Future<void> clearCache() async {
    await _pokemonListBox?.clear();
    await _pokemonDetailBox?.clear();
  }

  /// Limpia el caché expirado
  Future<void> clearExpiredCache() async {
    if (_pokemonListBox == null || _pokemonDetailBox == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Limpiar listas expiradas
    for (var key in _pokemonListBox!.keys) {
      if (key.toString().startsWith('list_')) {
        final data = _pokemonListBox!.get(key) as Map<dynamic, dynamic>?;
        if (data != null) {
          final timestamp = data['timestamp'] as int;
          if (now - timestamp > AppConstants.cacheExpirationDuration.inMilliseconds) {
            await _pokemonListBox!.delete(key);
          }
        }
      }
    }

    // Limpiar detalles expirados
    for (var key in _pokemonDetailBox!.keys) {
      if (key.toString().startsWith('detail_')) {
        final data = _pokemonDetailBox!.get(key) as Map<dynamic, dynamic>?;
        if (data != null) {
          final timestamp = data['timestamp'] as int;
          if (now - timestamp > AppConstants.cacheExpirationDuration.inMilliseconds) {
            await _pokemonDetailBox!.delete(key);
          }
        }
      }
    }
  }
}

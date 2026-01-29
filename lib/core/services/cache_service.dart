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
    if (!_isInitialized) await init();
    if (_pokemonListBox == null) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dataToSave = {
      'results': response.results.map((p) => p.toJson()).toList(),
      'next': response.next,
      'previous': response.previous,
      'count': response.count,
      'timestamp': timestamp,
    };
    await _pokemonListBox!.put('list_$offset', dataToSave);
    await _pokemonListBox!.put(_cacheTimestampKey, timestamp);
  }

  /// Obtiene la lista de Pokémon desde caché
  PokemonListResponseModel? getCachedPokemonList(int offset) {
    if (!_isInitialized || _pokemonListBox == null) return null;

    try {
      final cachedData = _pokemonListBox!.get('list_$offset');
      if (cachedData == null) return null;

      final data = cachedData as Map<dynamic, dynamic>;
      if (!data.containsKey('timestamp') || !data.containsKey('results')) {
        return null;
      }

      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final expirationMs = AppConstants.cacheExpirationDuration.inMilliseconds;
      if (cacheAge > expirationMs) return null;

      final resultsList = data['results'] as List?;
      if (resultsList == null || resultsList.isEmpty) return null;

      final results = resultsList
          .map((json) {
            try {
              final jsonMap = json as Map<dynamic, dynamic>;
              final stringMap = Map<String, dynamic>.from(
                jsonMap.map((key, value) => MapEntry(key.toString(), value)),
              );
              return PokemonModel.fromJson(stringMap);
            } catch (_) {
              return null;
            }
          })
          .whereType<PokemonModel>()
          .toList();

      if (results.isEmpty) return null;

      return PokemonListResponseModel(
        results: results,
        next: data['next'] as String?,
        previous: data['previous'] as String?,
        count: data['count'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  /// Guarda el detalle de un Pokémon en caché
  Future<void> cachePokemonDetail(PokemonModel pokemon) async {
    if (!_isInitialized) await init();
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
    if (!_isInitialized || _pokemonDetailBox == null) return null;

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

      if (cacheAge > AppConstants.cacheExpirationDuration.inMilliseconds) {
        return null;
      }

      // Hive devuelve Map<dynamic, dynamic>, convertir a Map<String, dynamic>
      final pokemonRaw = data['pokemon'];
      if (pokemonRaw == null || pokemonRaw is! Map) return null;
      final pokemonJson = Map<String, dynamic>.from(
        Map.from(pokemonRaw).map((key, value) => MapEntry(key.toString(), value)),
      );

      return PokemonModel.fromJson(pokemonJson);
    } catch (_) {
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

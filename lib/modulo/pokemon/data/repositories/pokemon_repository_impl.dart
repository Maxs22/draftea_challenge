import '../../domain/repositories/pokemon_repository.dart';
import '../models/pokemon_list_response_model.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_api_service.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/connectivity_service.dart';

/// Implementación del repositorio de Pokémon con soporte online/offline
class PokemonRepositoryImpl implements PokemonRepository {
  PokemonRepositoryImpl({
    PokemonApiService? apiService,
    CacheService? cacheService,
    ConnectivityService? connectivityService,
  })  : _apiService = apiService ?? PokemonApiService(),
        _cacheService = cacheService ?? CacheService(),
        _connectivityService = connectivityService ?? ConnectivityService();

  final PokemonApiService _apiService;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;

  @override
  Future<PokemonListResponseModel> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final isOnline = await _connectivityService.isConnected();

    if (isOnline) {
      try {
        final response = await _apiService.getPokemonList(
          limit: limit,
          offset: offset,
        );
        await _cacheService.cachePokemonList(response, offset);
        return response;
      } catch (e) {
        final cachedData = await _getCachedData(offset);
        if (cachedData != null) return cachedData;
        throw Exception('Error al obtener la lista de Pokémon: $e');
      }
    } else {
      final cachedData = await _getCachedData(offset);
      if (cachedData != null) return cachedData;
      throw Exception('Sin conexión y no hay datos en caché');
    }
  }

  Future<PokemonListResponseModel?> _getCachedData(int offset) async {
    if (!_cacheService.isInitialized) {
      await _cacheService.init();
      await Future.delayed(const Duration(milliseconds: 50));
    }

    var cachedData = _cacheService.getCachedPokemonList(offset);
    if (cachedData != null && cachedData.results.isNotEmpty) return cachedData;

    if (offset == 0) {
      for (int tryOffset = 0; tryOffset <= 100; tryOffset += 20) {
        cachedData = _cacheService.getCachedPokemonList(tryOffset);
        if (cachedData != null && cachedData.results.isNotEmpty) return cachedData;
      }
    }

    return null;
  }

  @override
  Future<PokemonModel> getPokemonDetail(String idOrName) async {
    final isOnline = await _connectivityService.isConnected();

    if (isOnline) {
      try {
        final pokemon = await _apiService.getPokemonDetail(idOrName);
        await _cacheService.cachePokemonDetail(pokemon);
        return pokemon;
      } catch (e) {
        final cachedPokemon = await _getCachedDetail(idOrName);
        if (cachedPokemon != null) return cachedPokemon;
        throw Exception('Error al obtener el detalle del Pokémon: $e');
      }
    } else {
      final cachedPokemon = await _getCachedDetail(idOrName);
      if (cachedPokemon != null) return cachedPokemon;
      throw Exception('Sin conexión y no hay datos en caché');
    }
  }

  /// Asegura que el caché esté inicializado y obtiene el detalle desde caché.
  Future<PokemonModel?> _getCachedDetail(String idOrName) async {
    if (!_cacheService.isInitialized) {
      await _cacheService.init();
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return _cacheService.getCachedPokemonDetail(idOrName);
  }
}

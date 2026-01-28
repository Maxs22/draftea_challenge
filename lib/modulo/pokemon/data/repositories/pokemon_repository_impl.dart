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
        // Intentar obtener desde la API
        final response = await _apiService.getPokemonList(
          limit: limit,
          offset: offset,
        );
        
        // Guardar en caché después de obtener exitosamente
        await _cacheService.cachePokemonList(response, offset);
        
        return response;
      } catch (e) {
        // Si falla la API, intentar obtener del caché
        final cachedData = _cacheService.getCachedPokemonList(offset);
        if (cachedData != null) {
          return cachedData;
        }
        throw Exception('Error al obtener la lista de Pokémon: $e');
      }
    } else {
      // Modo offline: obtener del caché
      final cachedData = _cacheService.getCachedPokemonList(offset);
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Sin conexión y no hay datos en caché');
    }
  }

  @override
  Future<PokemonModel> getPokemonDetail(String idOrName) async {
    final isOnline = await _connectivityService.isConnected();

    if (isOnline) {
      try {
        // Intentar obtener desde la API
        final pokemon = await _apiService.getPokemonDetail(idOrName);
        
        // Guardar en caché después de obtener exitosamente
        await _cacheService.cachePokemonDetail(pokemon);
        
        return pokemon;
      } catch (e) {
        // Si falla la API, intentar obtener del caché
        final cachedPokemon = _cacheService.getCachedPokemonDetail(idOrName);
        if (cachedPokemon != null) {
          return cachedPokemon;
        }
        throw Exception('Error al obtener el detalle del Pokémon: $e');
      }
    } else {
      // Modo offline: obtener del caché
      final cachedPokemon = _cacheService.getCachedPokemonDetail(idOrName);
      if (cachedPokemon != null) {
        return cachedPokemon;
      }
      throw Exception('Sin conexión y no hay datos en caché');
    }
  }
}

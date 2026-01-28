import '../../domain/repositories/pokemon_repository.dart';
import '../models/pokemon_list_response_model.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_api_service.dart';

/// Implementación del repositorio de Pokémon
class PokemonRepositoryImpl implements PokemonRepository {
  PokemonRepositoryImpl({
    PokemonApiService? apiService,
  }) : _apiService = apiService ?? PokemonApiService();

  final PokemonApiService _apiService;

  @override
  Future<PokemonListResponseModel> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _apiService.getPokemonList(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw Exception('Error al obtener la lista de Pokémon: $e');
    }
  }

  @override
  Future<PokemonModel> getPokemonDetail(String idOrName) async {
    try {
      return await _apiService.getPokemonDetail(idOrName);
    } catch (e) {
      throw Exception('Error al obtener el detalle del Pokémon: $e');
    }
  }
}

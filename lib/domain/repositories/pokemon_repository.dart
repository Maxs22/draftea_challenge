import '../../data/models/pokemon_list_response_model.dart';
import '../../data/models/pokemon_model.dart';

/// Interfaz del repositorio de Pokémon
abstract class PokemonRepository {
  /// Obtiene la lista de Pokémon paginada
  Future<PokemonListResponseModel> getPokemonList({
    int limit,
    int offset,
  });

  /// Obtiene el detalle de un Pokémon por ID o nombre
  Future<PokemonModel> getPokemonDetail(String idOrName);
}

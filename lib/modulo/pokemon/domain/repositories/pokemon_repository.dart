import '../../data/models/pokemon_list_response_model.dart';
import '../../data/models/pokemon_model.dart';

abstract class PokemonRepository {
  Future<PokemonListResponseModel> getPokemonList({
    int limit,
    int offset,
  });

  Future<PokemonModel> getPokemonDetail(String idOrName);
}

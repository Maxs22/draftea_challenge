import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../data/models/pokemon_model.dart';

part 'pokedex_state.dart';

/// Cubit para manejar el estado del listado de Pokémon
class PokedexCubit extends Cubit<PokedexState> {
  PokedexCubit({
    required PokemonRepository repository,
  })  : _repository = repository,
        super(const PokedexState.initial());

  final PokemonRepository _repository;

  /// Carga la lista inicial de Pokémon
  Future<void> loadPokemonList() async {
    emit(const PokedexState.loading());

    try {
      final response = await _repository.getPokemonList(
        limit: AppConstants.defaultPageLimit,
        offset: AppConstants.initialOffset,
      );

      emit(PokedexState.loaded(
        pokemonList: response.results,
        hasMore: response.next != null,
      ));
    } catch (e) {
      emit(PokedexState.error(message: e.toString()));
    }
  }
}

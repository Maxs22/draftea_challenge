import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/repositories/pokemon_repository.dart';
import '../../../../data/models/pokemon_model.dart';

part 'pokemon_detail_state.dart';

/// Cubit para manejar el estado del detalle de un Pokémon
class PokemonDetailCubit extends Cubit<PokemonDetailState> {
  PokemonDetailCubit({
    required PokemonRepository repository,
  })  : _repository = repository,
        super(const PokemonDetailState.initial());

  final PokemonRepository _repository;

  /// Carga el detalle de un Pokémon por ID o nombre
  Future<void> loadPokemonDetail(String idOrName) async {
    emit(const PokemonDetailState.loading());

    try {
      final pokemon = await _repository.getPokemonDetail(idOrName);
      emit(PokemonDetailState.loaded(pokemon: pokemon));
    } catch (e) {
      emit(PokemonDetailState.error(message: e.toString()));
    }
  }
}

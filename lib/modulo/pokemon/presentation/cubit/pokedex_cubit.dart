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
        currentOffset: AppConstants.defaultPageLimit,
      ));
    } catch (e) {
      emit(PokedexState.error(message: e.toString()));
    }
  }

  /// Carga más Pokémon para scroll infinito
  Future<void> loadMorePokemon() async {
    final currentState = state;
    
    // Solo cargar más si hay más disponible y no está cargando
    if (currentState is! _Loaded || !currentState.hasMore) {
      return;
    }

    // Evitar múltiples llamadas simultáneas
    if (currentState is _LoadingMore) {
      return;
    }

    emit(PokedexState.loadingMore(
      pokemonList: currentState.pokemonList,
      hasMore: currentState.hasMore,
      currentOffset: currentState.currentOffset,
    ));

    try {
      final response = await _repository.getPokemonList(
        limit: AppConstants.defaultPageLimit,
        offset: currentState.currentOffset,
      );

      final updatedList = [
        ...currentState.pokemonList,
        ...response.results,
      ];

      emit(PokedexState.loaded(
        pokemonList: updatedList,
        hasMore: response.next != null,
        currentOffset: currentState.currentOffset + AppConstants.defaultPageLimit,
      ));
    } catch (e) {
      emit(PokedexState.errorLoadingMore(
        pokemonList: currentState.pokemonList,
        hasMore: currentState.hasMore,
        currentOffset: currentState.currentOffset,
        message: e.toString(),
      ));
    }
  }

  /// Limpia el error de "cargar más" (p. ej. al recuperar conexión).
  void clearLoadMoreError() {
    final currentState = state;
    if (currentState is _ErrorLoadingMore) {
      emit(PokedexState.loaded(
        pokemonList: currentState.pokemonList,
        hasMore: currentState.hasMore,
        currentOffset: currentState.currentOffset,
      ));
    }
  }
}

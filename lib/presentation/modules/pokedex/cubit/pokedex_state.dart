part of 'pokedex_cubit.dart';

/// Estados del Cubit de Pokédex
sealed class PokedexState extends Equatable {
  const PokedexState();

  const factory PokedexState.initial() = _Initial;
  const factory PokedexState.loading() = _Loading;
  const factory PokedexState.loaded({
    required List<PokemonModel> pokemonList,
    required bool hasMore,
  }) = _Loaded;
  const factory PokedexState.error({required String message}) = _Error;

  @override
  List<Object?> get props => [];
}

class _Initial extends PokedexState {
  const _Initial();
}

class _Loading extends PokedexState {
  const _Loading();
}

class _Loaded extends PokedexState {
  const _Loaded({
    required this.pokemonList,
    required this.hasMore,
  });

  final List<PokemonModel> pokemonList;
  final bool hasMore;

  @override
  List<Object?> get props => [pokemonList, hasMore];
}

class _Error extends PokedexState {
  const _Error({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Extensión para manejar los estados de forma más limpia
extension PokedexStateExtension on PokedexState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<PokemonModel> pokemonList, bool hasMore) loaded,
    required T Function(String message) error,
  }) {
    return switch (this) {
      _Initial() => initial(),
      _Loading() => loading(),
      _Loaded(:final pokemonList, :final hasMore) => loaded(pokemonList, hasMore),
      _Error(:final message) => error(message),
    };
  }
}

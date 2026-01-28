part of 'pokemon_detail_cubit.dart';

/// Estados del Cubit de detalle de Pokémon
sealed class PokemonDetailState extends Equatable {
  const PokemonDetailState();

  const factory PokemonDetailState.initial() = _Initial;
  const factory PokemonDetailState.loading() = _Loading;
  const factory PokemonDetailState.loaded({required PokemonModel pokemon}) =
      _Loaded;
  const factory PokemonDetailState.error({required String message}) = _Error;

  @override
  List<Object?> get props => [];
}

class _Initial extends PokemonDetailState {
  const _Initial();
}

class _Loading extends PokemonDetailState {
  const _Loading();
}

class _Loaded extends PokemonDetailState {
  const _Loaded({required this.pokemon});

  final PokemonModel pokemon;

  @override
  List<Object?> get props => [pokemon];
}

class _Error extends PokemonDetailState {
  const _Error({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Extensión para manejar los estados de forma más limpia
extension PokemonDetailStateExtension on PokemonDetailState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(PokemonModel pokemon) loaded,
    required T Function(String message) error,
  }) {
    return switch (this) {
      _Initial() => initial(),
      _Loading() => loading(),
      _Loaded(:final pokemon) => loaded(pokemon),
      _Error(:final message) => error(message),
    };
  }
}

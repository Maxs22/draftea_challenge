part of 'pokedex_cubit.dart';

/// Estados del Cubit de Pokédex
sealed class PokedexState extends Equatable {
  const PokedexState();

  const factory PokedexState.initial() = _Initial;
  const factory PokedexState.loading() = _Loading;
  const factory PokedexState.loaded({
    required List<PokemonModel> pokemonList,
    required bool hasMore,
    required int currentOffset,
  }) = _Loaded;
  const factory PokedexState.loadingMore({
    required List<PokemonModel> pokemonList,
    required bool hasMore,
    required int currentOffset,
  }) = _LoadingMore;
  const factory PokedexState.error({required String message}) = _Error;
  const factory PokedexState.errorLoadingMore({
    required List<PokemonModel> pokemonList,
    required bool hasMore,
    required int currentOffset,
    required String message,
  }) = _ErrorLoadingMore;

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
    required this.currentOffset,
  });

  final List<PokemonModel> pokemonList;
  final bool hasMore;
  final int currentOffset;

  @override
  List<Object?> get props => [pokemonList, hasMore, currentOffset];
}

class _LoadingMore extends PokedexState {
  const _LoadingMore({
    required this.pokemonList,
    required this.hasMore,
    required this.currentOffset,
  });

  final List<PokemonModel> pokemonList;
  final bool hasMore;
  final int currentOffset;

  @override
  List<Object?> get props => [pokemonList, hasMore, currentOffset];
}

class _Error extends PokedexState {
  const _Error({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class _ErrorLoadingMore extends PokedexState {
  const _ErrorLoadingMore({
    required this.pokemonList,
    required this.hasMore,
    required this.currentOffset,
    required this.message,
  });

  final List<PokemonModel> pokemonList;
  final bool hasMore;
  final int currentOffset;
  final String message;

  @override
  List<Object?> get props => [pokemonList, hasMore, currentOffset, message];
}

/// Extensión para manejar los estados de forma más limpia
extension PokedexStateExtension on PokedexState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(
      List<PokemonModel> pokemonList,
      bool hasMore,
      int currentOffset,
    ) loaded,
    T Function(
      List<PokemonModel> pokemonList,
      bool hasMore,
      int currentOffset,
    )? loadingMore,
    required T Function(String message) error,
    T Function(
      List<PokemonModel> pokemonList,
      bool hasMore,
      int currentOffset,
      String message,
    )? errorLoadingMore,
  }) {
    return switch (this) {
      _Initial() => initial(),
      _Loading() => loading(),
      _Loaded(:final pokemonList, :final hasMore, :final currentOffset) =>
        loaded(pokemonList, hasMore, currentOffset),
      _LoadingMore(:final pokemonList, :final hasMore, :final currentOffset) =>
        loadingMore?.call(pokemonList, hasMore, currentOffset) ??
        loaded(pokemonList, hasMore, currentOffset),
      _Error(:final message) => error(message),
      _ErrorLoadingMore(
        :final pokemonList,
        :final hasMore,
        :final currentOffset,
        :final message,
      ) =>
        errorLoadingMore?.call(pokemonList, hasMore, currentOffset, message) ??
        loaded(pokemonList, hasMore, currentOffset),
    };
  }

  /// Obtiene la lista de Pokémon actual si está disponible
  List<PokemonModel>? get pokemonList => switch (this) {
        _Loaded(:final pokemonList) => pokemonList,
        _LoadingMore(:final pokemonList) => pokemonList,
        _ErrorLoadingMore(:final pokemonList) => pokemonList,
        _ => null,
      };

  /// Indica si hay más páginas disponibles
  bool get hasMore => switch (this) {
        _Loaded(:final hasMore) => hasMore,
        _LoadingMore(:final hasMore) => hasMore,
        _ErrorLoadingMore(:final hasMore) => hasMore,
        _ => false,
      };

  /// Indica si está cargando más páginas
  bool get isLoadingMore => this is _LoadingMore;

  /// Indica si hay un error al cargar más páginas
  bool get isErrorLoadingMore => this is _ErrorLoadingMore;
}

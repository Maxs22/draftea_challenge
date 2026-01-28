import 'package:equatable/equatable.dart';
import 'pokemon_model.dart';

/// Modelo de respuesta del listado de Pokémon
class PokemonListResponseModel extends Equatable {
  const PokemonListResponseModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<PokemonModel> results;

  /// Factory constructor para crear desde JSON
  factory PokemonListResponseModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>;
    final pokemonList = results
        .map((item) => PokemonModel.fromListJson(item as Map<String, dynamic>))
        .toList();

    return PokemonListResponseModel(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: pokemonList,
    );
  }

  @override
  List<Object?> get props => [count, next, previous, results];
}

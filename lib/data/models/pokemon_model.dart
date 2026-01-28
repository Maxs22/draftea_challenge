import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

/// Modelo de datos para un Pokémon
class PokemonModel extends Equatable {
  const PokemonModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.thumbnailUrl,
  });

  final int id;
  final String name;
  final String imageUrl;
  final String? thumbnailUrl;

  /// Factory constructor para crear desde JSON del endpoint de listado
  factory PokemonModel.fromListJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = _extractIdFromUrl(url);
    final name = json['name'] as String;

    return PokemonModel(
      id: id,
      name: name,
      imageUrl: '${AppConstants.pokemonImageBaseUrl}/$id.png',
      thumbnailUrl: '${AppConstants.pokemonThumbnailBaseUrl}/$id.png',
    );
  }

  /// Factory constructor para crear desde JSON del endpoint de detalle
  factory PokemonModel.fromDetailJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final officialArtwork = other?['official-artwork'] as Map<String, dynamic>?;
    final frontDefault = officialArtwork?['front_default'] as String?;

    return PokemonModel(
      id: id,
      name: name,
      imageUrl: frontDefault ?? '${AppConstants.pokemonImageBaseUrl}/$id.png',
      thumbnailUrl: '${AppConstants.pokemonThumbnailBaseUrl}/$id.png',
    );
  }

  /// Extrae el ID del Pokémon desde la URL
  static int _extractIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final idString = segments[segments.length - 2];
    return int.tryParse(idString) ?? 0;
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
      };

  /// Crea una copia del modelo con campos modificados
  PokemonModel copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? thumbnailUrl,
  }) =>
      PokemonModel(
        id: id ?? this.id,
        name: name ?? this.name,
        imageUrl: imageUrl ?? this.imageUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      );

  @override
  List<Object?> get props => [id, name, imageUrl, thumbnailUrl];
}

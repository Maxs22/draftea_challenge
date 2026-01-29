import 'package:draftea_challenge/core/constants/app_constants.dart';
import 'package:equatable/equatable.dart';

/// Modelo de datos para un Pokémon
class PokemonModel extends Equatable {
  const PokemonModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.thumbnailUrl,
    this.height,
    this.weight,
    this.types,
    this.abilities,
    this.baseExperience,
  });

  final int id;
  final String name;
  final String imageUrl;
  final String? thumbnailUrl;
  final int? height; // en decímetros
  final int? weight; // en hectogramos
  final List<String>? types; // tipos del Pokémon
  final List<String>? abilities; // habilidades del Pokémon
  final int? baseExperience;

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
    final height = json['height'] as int?;
    final weight = json['weight'] as int?;
    final baseExperience = json['base_experience'] as int?;
    
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final officialArtwork = other?['official-artwork'] as Map<String, dynamic>?;
    final frontDefault = officialArtwork?['front_default'] as String?;

    // Extraer tipos
    final typesList = json['types'] as List<dynamic>?;
    final types = typesList
        ?.map((type) {
          final typeData = type as Map<String, dynamic>;
          final typeInfo = typeData['type'] as Map<String, dynamic>;
          return typeInfo['name'] as String;
        })
        .cast<String>()
        .toList();

    // Extraer habilidades
    final abilitiesList = json['abilities'] as List<dynamic>?;
    final abilities = abilitiesList
        ?.map((ability) {
          final abilityData = ability as Map<String, dynamic>;
          final abilityInfo = abilityData['ability'] as Map<String, dynamic>;
          return abilityInfo['name'] as String;
        })
        .cast<String>()
        .toList();

    return PokemonModel(
      id: id,
      name: name,
      imageUrl: frontDefault ?? '${AppConstants.pokemonImageBaseUrl}/$id.png',
      thumbnailUrl: '${AppConstants.pokemonThumbnailBaseUrl}/$id.png',
      height: height,
      weight: weight,
      types: types,
      abilities: abilities,
      baseExperience: baseExperience,
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
        'height': height,
        'weight': weight,
        'types': types,
        'abilities': abilities,
        'baseExperience': baseExperience,
      };

  /// Crea desde JSON guardado en caché (mismo formato que toJson)
  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      types: json['types'] != null
          ? List<String>.from(json['types'] as List)
          : null,
      abilities: json['abilities'] != null
          ? List<String>.from(json['abilities'] as List)
          : null,
      baseExperience: json['baseExperience'] as int?,
    );
  }

  /// Crea una copia del modelo con campos modificados
  PokemonModel copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? thumbnailUrl,
    int? height,
    int? weight,
    List<String>? types,
    List<String>? abilities,
    int? baseExperience,
  }) =>
      PokemonModel(
        id: id ?? this.id,
        name: name ?? this.name,
        imageUrl: imageUrl ?? this.imageUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        types: types ?? this.types,
        abilities: abilities ?? this.abilities,
        baseExperience: baseExperience ?? this.baseExperience,
      );

  /// Obtiene la altura en metros
  double get heightInMeters => (height ?? 0) / 10.0;

  /// Obtiene el peso en kilogramos
  double get weightInKg => (weight ?? 0) / 10.0;

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        thumbnailUrl,
        height,
        weight,
        types,
        abilities,
        baseExperience,
      ];
}

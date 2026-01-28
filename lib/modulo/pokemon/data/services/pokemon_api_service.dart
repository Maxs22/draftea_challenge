import 'dart:convert';
import 'package:draftea_challenge/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import '../models/pokemon_list_response_model.dart';
import '../models/pokemon_model.dart';

/// Servicio para interactuar con la PokéAPI
class PokemonApiService {
  PokemonApiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  /// Obtiene la lista de Pokémon paginada
  Future<PokemonListResponseModel> getPokemonList({
    int limit = AppConstants.defaultPageLimit,
    int offset = AppConstants.initialOffset,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.pokemonEndpoint}?limit=$limit&offset=$offset',
      );

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PokemonListResponseModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Error al obtener la lista de Pokémon: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene el detalle de un Pokémon por ID o nombre
  Future<PokemonModel> getPokemonDetail(String idOrName) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.pokemonEndpoint}/$idOrName/',
      );

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PokemonModel.fromDetailJson(jsonData);
      } else {
        throw Exception(
          'Error al obtener el detalle del Pokémon: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}

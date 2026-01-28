import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../data/models/pokemon_model.dart';
import '../../../../data/repositories/pokemon_repository_impl.dart';
import '../cubit/pokemon_detail_cubit.dart';

/// Vista de detalle de un Pokémon
class PokemonDetailView extends StatelessWidget {
  const PokemonDetailView({
    super.key,
    required this.pokemonId,
  });

  final String pokemonId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = PokemonRepositoryImpl();
        return PokemonDetailCubit(repository: repository)
          ..loadPokemonDetail(pokemonId);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textLight,
              elevation: 0,
            ),
          ),
        ),
        body: BlocBuilder<PokemonDetailCubit, PokemonDetailState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (pokemon) => _buildDetailContent(context, pokemon),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.errorNetworkMessage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.error,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<PokemonDetailCubit>()
                            .loadPokemonDetail(pokemonId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, PokemonModel pokemon) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen del Pokémon
          Container(
            height: 300,
            color: AppColors.backgroundDark,
            child: Center(
              child: Image.network(
                pokemon.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: AppColors.textSecondary,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ),
          // Información del Pokémon
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre e ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _capitalizeName(pokemon.name),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Tipos
                if (pokemon.types != null && pokemon.types!.isNotEmpty) ...[
                  Text(
                    'Tipos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pokemon.types!
                        .map(
                          (type) => Chip(
                            label: Text(
                              _capitalizeName(type),
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: _getTypeColor(type),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Estadísticas básicas
                if (pokemon.height != null || pokemon.weight != null)
                  Row(
                    children: [
                      if (pokemon.height != null) ...[
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Altura',
                            '${pokemon.heightInMeters.toStringAsFixed(1)} m',
                            Icons.height,
                          ),
                        ),
                        if (pokemon.weight != null) const SizedBox(width: 16),
                      ],
                      if (pokemon.weight != null)
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Peso',
                            '${pokemon.weightInKg.toStringAsFixed(1)} kg',
                            Icons.scale,
                          ),
                        ),
                    ],
                  ),
                if (pokemon.baseExperience != null) ...[
                  const SizedBox(height: 16),
                  _buildStatCard(
                    context,
                    'Experiencia Base',
                    '${pokemon.baseExperience}',
                    Icons.star,
                  ),
                ],
                // Habilidades
                if (pokemon.abilities != null && pokemon.abilities!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Habilidades',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...pokemon.abilities!.map(
                    (ability) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _capitalizeName(ability),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryRed),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeName(String name) {
    if (name.isEmpty) return name;
    try {
      return '${name[0].toUpperCase()}${name.substring(1)}';
    } catch (e) {
      return name;
    }
  }

  Color _getTypeColor(String type) {
    if (type.isEmpty) return AppColors.typeNormal;
    
    final typeColors = <String, Color>{
      'normal': AppColors.typeNormal,
      'fire': AppColors.typeFire,
      'water': AppColors.typeWater,
      'electric': AppColors.typeElectric,
      'grass': AppColors.typeGrass,
      'ice': AppColors.typeIce,
      'fighting': AppColors.typeFighting,
      'poison': AppColors.typePoison,
      'ground': AppColors.typeGround,
      'flying': AppColors.typeFlying,
      'psychic': AppColors.typePsychic,
      'bug': AppColors.typeBug,
      'rock': AppColors.typeRock,
      'ghost': AppColors.typeGhost,
      'dragon': AppColors.typeDragon,
      'dark': AppColors.typeDark,
      'steel': AppColors.typeSteel,
      'fairy': AppColors.typeFairy,
    };
    return typeColors[type.toLowerCase()] ?? AppColors.typeNormal;
  }
}

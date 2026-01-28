import 'package:draftea_challenge/modulo/pokemon/presentation/cubit/pokedex_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/web_config.dart';
import '../../../../core/config/mobile_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/pokemon_model.dart';
import '../../data/repositories/pokemon_repository_impl.dart';
import '../widgets/cards/pokemon_card_widget.dart';
import '../modules/pokemon_detail/views/pokemon_detail_view.dart';

/// Vista principal del listado de Pokémon en grid
class PokedexView extends StatelessWidget {
  const PokedexView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = PokemonRepositoryImpl();
        return PokedexCubit(repository: repository)..loadPokemonList();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.textLight,
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<PokedexCubit, PokedexState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (pokemonList, hasMore) {
                if (pokemonList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.errorEmptyMessage,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildGrid(context, pokemonList);
              },
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
                        context.read<PokedexCubit>().loadPokemonList();
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

  Widget _buildGrid(BuildContext context, List<PokemonModel> pokemonList) {
    final isWeb = Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux ||
        Theme.of(context).platform == TargetPlatform.macOS;

    final crossAxisCount = isWeb
        ? WebConfig.getGridColumnCount(context)
        : MobileConfig.getGridColumnCount(context);

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = pokemonList[index];
        return PokemonCardWidget(
          pokemon: pokemon,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokemonDetailView(
                  pokemonId: pokemon.id.toString(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

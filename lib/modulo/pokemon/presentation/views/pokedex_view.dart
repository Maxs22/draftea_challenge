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
class PokedexView extends StatefulWidget {
  const PokedexView({super.key});

  @override
  State<PokedexView> createState() => _PokedexViewState();
}

class _PokedexViewState extends State<PokedexView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PokedexCubit>().loadMorePokemon();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

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
              loaded: (pokemonList, hasMore, currentOffset) {
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

                return _buildGrid(context, pokemonList, hasMore);
              },
              loadingMore: (pokemonList, hasMore, currentOffset) {
                return _buildGrid(context, pokemonList, hasMore, isLoadingMore: true);
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
              errorLoadingMore: (pokemonList, hasMore, currentOffset, message) {
                return Column(
                  children: [
                    Expanded(
                      child: _buildGrid(context, pokemonList, hasMore),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.error.withValues(alpha: 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Error al cargar más Pokémon',
                            style: TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              context.read<PokedexCubit>().loadMorePokemon();
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<PokemonModel> pokemonList,
    bool hasMore, {
    bool isLoadingMore = false,
  }) {
    final isWeb = Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux ||
        Theme.of(context).platform == TargetPlatform.macOS;

    final crossAxisCount = isWeb
        ? WebConfig.getGridColumnCount(context)
        : MobileConfig.getGridColumnCount(context);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: pokemonList.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Mostrar indicador de carga al final si está cargando más
        if (index == pokemonList.length && isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si el índice es mayor que la lista, no debería pasar
        if (index >= pokemonList.length) {
          return const SizedBox.shrink();
        }

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

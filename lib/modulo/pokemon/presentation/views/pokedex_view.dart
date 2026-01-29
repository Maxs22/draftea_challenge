import 'package:draftea_challenge/modulo/pokemon/presentation/cubit/pokedex_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/web_config.dart';
import '../../../../core/config/mobile_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/draftea_logo.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/route_transitions.dart';
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
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;
  PokedexCubit? _pokedexCubit;

  bool get isWeb => Theme.of(context).platform == TargetPlatform.windows ||
                    Theme.of(context).platform == TargetPlatform.linux ||
                    Theme.of(context).platform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        if (isOnline) _pokedexCubit?.clearLoadMoreError();
        setState(() => _isOnline = isOnline);
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await _connectivityService.isConnected();
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return BlocProvider(
      create: (context) {
        final repository = PokemonRepositoryImpl(
          cacheService: CacheService(),
          connectivityService: _connectivityService,
        );
        final cubit = PokedexCubit(repository: repository)..loadPokemonList();
        _pokedexCubit = cubit;
        return cubit;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            isWeb ? kToolbarHeight * 1.3 : kToolbarHeight,
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
            child: AppBar(
              title: const DrafteaLogo(),
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textLight,
              centerTitle: false,
              elevation: 0,
              toolbarHeight: isWeb ? kToolbarHeight * 1.3 : kToolbarHeight,
              actions: [
                if (!_isOnline)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: isWeb ? 24 : 20,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: isWeb ? 14 : 12,
                            color: AppColors.textLight.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        body: BlocBuilder<PokedexCubit, PokedexState>(
            builder: (context, state) {
            Widget content = state.when(
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

                return _buildGrid(context, pokemonList, hasMore, isLoadingMore: false);
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

            if (isWeb) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxContentWidth,
                  ),
                  child: content,
                ),
              );
            }
            
            return content;
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
    final crossAxisCount = isWeb
        ? WebConfig.getGridColumnCount(context)
        : MobileConfig.getGridColumnCount(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollUpdateNotification) {
          final metrics = scrollInfo.metrics;

          if (metrics.maxScrollExtent > 0 && 
              metrics.pixels >= metrics.maxScrollExtent * 0.8) {
            final cubit = context.read<PokedexCubit>();
            final currentState = cubit.state;

            if (currentState.hasMore && !currentState.isLoadingMore) {
              cubit.loadMorePokemon();
            }
          }
        }
        return false;
      },
      child: Builder(
        builder: (context) {
          final aspectRatio = isWeb ? 0.95 : 0.75;

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: AppConstants.defaultPadding,
              mainAxisSpacing: AppConstants.defaultPadding,
            ),
        itemCount: pokemonList.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
        if (index == pokemonList.length && isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (index >= pokemonList.length) {
          return const SizedBox.shrink();
        }

        final pokemon = pokemonList[index];
        return PokemonCardWidget(
          pokemon: pokemon,
          onTap: () {
            Navigator.push(
              context,
              RouteTransitions.smoothRoute(
                PokemonDetailView(
                  pokemonId: pokemon.id.toString(),
                ),
              ),
            );
          },
        );
        },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/cached_pokemon_image.dart';
import '../../../data/models/pokemon_model.dart';

/// Widget de tarjeta para mostrar un Pokémon en el grid
class PokemonCardWidget extends StatelessWidget {
  const PokemonCardWidget({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  final PokemonModel pokemon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isWeb = Theme.of(context).platform == TargetPlatform.windows ||
                        Theme.of(context).platform == TargetPlatform.linux ||
                        Theme.of(context).platform == TargetPlatform.macOS;

                    final imageWidget = isWeb
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 160,
                              maxWidth: 160,
                            ),
                            child: CachedPokemonImage(
                              imageUrl: pokemon.imageUrl,
                              thumbnailUrl: pokemon.thumbnailUrl,
                              fit: BoxFit.contain,
                              placeholder: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                              errorWidget: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : CachedPokemonImage(
                            imageUrl: pokemon.imageUrl,
                            thumbnailUrl: pokemon.thumbnailUrl,
                            fit: BoxFit.contain,
                            placeholder: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                            errorWidget: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                          );

                    return Hero(
                      tag: 'pokemon_image_${pokemon.id}',
                      child: imageWidget,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _capitalizeName(pokemon.name),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Capitaliza la primera letra del nombre
  String _capitalizeName(String name) {
    if (name.isEmpty) return name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}

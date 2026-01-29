import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_cache_manager.dart';

/// Widget que muestra imágenes de Pokémon con caché compatible con web y mobile
class CachedPokemonImage extends StatelessWidget {
  const CachedPokemonImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.errorWidget,
    this.placeholder,
  });

  final String imageUrl;
  final String? thumbnailUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebImage();
    } else {
      return _buildMobileImage();
    }
  }

  Widget _buildWebImage() {
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        if (thumbnailUrl != null && thumbnailUrl != imageUrl) {
          return Image.network(
            thumbnailUrl!,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ??
                  const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  );
            },
          );
        }
        return errorWidget ??
            const Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
      },
    );
  }

  Widget _buildMobileImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      cacheManager: ImageCacheManager.instance,
      placeholder: placeholder != null
          ? (context, url) => placeholder!
          : (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
      errorWidget: (context, url, error) {
        if (thumbnailUrl != null && thumbnailUrl != imageUrl) {
          return CachedNetworkImage(
            imageUrl: thumbnailUrl!,
            fit: fit,
            width: width,
            height: height,
            cacheManager: ImageCacheManager.instance,
            errorWidget: (context, url, error) {
              return errorWidget ??
                  const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  );
            },
          );
        }
        return errorWidget ??
            const Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            );
      },
    );
  }
}

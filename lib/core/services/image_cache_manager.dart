import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// CacheManager personalizado que funciona en web y mobile
class ImageCacheManager {
  static CacheManager? _instance;

  static CacheManager get instance {
    _instance ??= _createCacheManager();
    return _instance!;
  }

  static CacheManager _createCacheManager() {
    if (kIsWeb) {
      return CacheManager(
        Config(
          'pokemon_images',
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 200,
          repo: JsonCacheInfoRepository(databaseName: 'pokemon_images'),
        ),
      );
    } else {
      return DefaultCacheManager();
    }
  }
}

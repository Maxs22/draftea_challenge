# Pokédex - DRAFTEA Challenge

Aplicación Flutter multiplataforma (iOS, Android y Web) para explorar el mundo de los Pokémon utilizando la PokéAPI.

## 🚀 Características

- ✅ Listado de Pokémon en grid con scroll infinito
- ✅ Pantalla de detalle con información completa
- ✅ Soporte online/offline con caché local
- ✅ Diseño responsive para mobile y web
- ✅ Tema oscuro estilo DRAFTEA
- ✅ Splash screen animado
- ✅ Transiciones suaves entre pantallas

## 📋 Requisitos Previos

- Flutter SDK 3.10.4 o superior
- Dart SDK incluido con Flutter
- Android Studio / Xcode (para desarrollo mobile)
- Chrome o navegador moderno (para desarrollo web)

## 🛠️ Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/Maxs22/draftea_challenge.git
   cd draftea_challenge
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Verificar configuración**
   ```bash
   flutter doctor
   ```

## 📱 Ejecutar en Mobile

### Android

1. **Conectar dispositivo Android o iniciar emulador**
   ```bash
   # Verificar dispositivos conectados
   flutter devices
   ```

2. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```
   
   O específicamente para Android:
   ```bash
   flutter run -d android
   ```

3. **Build de release (APK)**
   ```bash
   flutter build apk --release
   ```

### iOS

1. **Abrir proyecto en Xcode** (solo macOS)
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```
   
   O específicamente para iOS:
   ```bash
   flutter run -d ios
   ```

3. **Build de release (IPA)**
   ```bash
   flutter build ios --release
   ```

## 🌐 Ejecutar en Web

1. **Habilitar soporte web** (si es necesario)
   ```bash
   flutter config --enable-web
   ```

2. **Ejecutar en modo desarrollo**
   ```bash
   flutter run -d chrome
   ```

3. **Build para producción**
   ```bash
   flutter build web --release
   ```

4. **Servir la aplicación**
   ```bash
   # Los archivos estarán en build/web/
   # Puedes usar cualquier servidor HTTP, por ejemplo:
   cd build/web
   python -m http.server 8000
   # O con Node.js:
   npx serve
   ```

## 🏗️ Arquitectura y Escalabilidad

### Arquitectura: MVVM Adaptada con Cubit

Se utilizó una arquitectura basada en MVVM pero adaptada para usar **Cubit (flutter_bloc)** en lugar de ViewModels tradicionales. Esta arquitectura es adecuada para escalar porque:

- **Separación de responsabilidades**: Capas claramente definidas (Data, Domain, Presentation)
- **Testabilidad**: Cada capa puede ser testeada independientemente
- **Mantenibilidad**: Código organizado y fácil de entender
- **Escalabilidad**: Fácil agregar nuevos módulos siguiendo la misma estructura
- **Compatibilidad Web**: Cubit funciona perfectamente en Flutter Web sin problemas de contexto

**Estructura de carpetas:**
```
lib/
├── core/              # Configuraciones y utilidades compartidas
├── modulo/
│   └── pokemon/
│       ├── data/      # Modelos, servicios, repositorios
│       ├── domain/    # Interfaces y contratos
│       └── presentation/  # UI, Cubits, Widgets
```

### Trade-offs por Timebox de 1 Día

- **Caché simplificado**: Se usa Hive con expiración de 24 horas, sin versionado complejo
- **Sin tests automatizados**: Prioridad en funcionalidad, tests pendientes para producción
- **Manejo de errores básico**: Mensajes genéricos, sin categorización avanzada
- **Sin optimización de imágenes**: Se confía en el caché del navegador/Flutter
- **Responsive básico**: Breakpoints simples, sin diseño adaptativo complejo

## 🔄 Gestión de Estado y Side-Effects

### Flujo UI → Estado → Datos

1. **UI (Widget)**: El usuario interactúa (scroll, tap)
   - Ejemplo: `PokedexView` detecta scroll con `NotificationListener<ScrollNotification>`
2. **Cubit**: Recibe eventos y emite nuevos estados
   - Ejemplo: `PokedexCubit.loadMorePokemon()` se llama desde la UI
3. **Repository**: El Cubit llama al repositorio
   - Ejemplo: `pokemonRepository.getPokemonList(limit: 20, offset: currentOffset)`
4. **Service/Cache**: El repositorio decide entre API o caché según conectividad
   - `PokemonRepositoryImpl` verifica `ConnectivityService.isConnected()`
   - Si online: `PokemonApiService` → luego guarda en `CacheService`
   - Si offline: `CacheService` directamente
5. **Estado actualizado**: El Cubit emite nuevo estado
   - Ejemplo: `emit(PokedexState.loaded(pokemon: updatedList, ...))`
6. **UI re-renderiza**: `BlocBuilder` escucha cambios y actualiza la UI
   - `BlocBuilder<PokedexCubit, PokedexState>` reconstruye el grid

**Ejemplo práctico** (`lib/modulo/pokemon/presentation/views/pokedex_view.dart`):
```dart
// UI detecta scroll → llama al Cubit
_onScroll() {
  if (_shouldLoadMore()) {
    context.read<PokedexCubit>().loadMorePokemon();
  }
}
```

### Evitar Acoplamiento

- **Interfaces**: El dominio define contratos (`PokemonRepository` en `domain/repositories/`)
  - La UI y Cubit solo conocen la interfaz, no la implementación
- **Inversión de dependencias**: La UI depende de abstracciones, no implementaciones
  - `PokedexCubit` recibe `PokemonRepository` (interfaz), no `PokemonRepositoryImpl`
- **Cubit independiente**: No conoce detalles de UI, solo emite estados
  - `PokedexCubit` no importa widgets, solo modelos y repositorios
- **Servicios inyectables**: Permiten testing y mock fácil
  - `PokemonRepositoryImpl` recibe servicios opcionales en constructor (DI manual)
  - Ejemplo: `PokemonRepositoryImpl(cacheService: mockCacheService)` para tests

## 💾 Offline y Caché

### Estrategia de Persistencia

**Qué se guarda:**
- Listas de Pokémon paginadas (por offset) en `pokemon_list_cache` (Hive box)
- Detalles completos de Pokémon individuales en `pokemon_detail_cache` (Hive box)
- Timestamps (`DateTime.now().millisecondsSinceEpoch`) para cada entrada

**Cómo funciona:**
- **Online**: Obtiene de API → Guarda en caché automáticamente (`CacheService.cachePokemonList()` / `cachePokemonDetail()`)
- **Offline**: Lee del caché → Muestra datos guardados (`getCachedPokemonList()` / `getCachedPokemonDetail()`)
- **Expiración**: 24 horas (definido en `AppConstants.cacheExpirationDuration`)

**Versionado e Invalidación:**
- **Sistema basado en timestamps**: Cada entrada guarda su timestamp al momento de creación
- **Validación en lectura**: Al recuperar datos, se calcula la edad del caché comparando timestamps
- **Invalidación automática**: Si `cacheAge > cacheExpirationDuration`, se retorna `null` y se obtiene de la API
- **Limpieza proactiva**: `CacheService.clearExpiredCache()` se ejecuta al iniciar la app (`main.dart`) para eliminar entradas expiradas del almacenamiento

**Resolución de conflictos:**
- **Estrategia simple**: Los datos remotos siempre tienen prioridad cuando hay conexión
- **Fallback a caché**: Si la API falla estando online, se intenta obtener del caché como respaldo
- **Sin sincronización**: No hay conflictos porque es solo lectura (API de solo lectura)
- **Implementación**: Ver `lib/modulo/pokemon/data/repositories/pokemon_repository_impl.dart` líneas 27-56 (listas) y 60-87 (detalles)

## 🌐 Flutter Web

### Decisiones para Buena Experiencia Web

1. **Contenido centrado**: Ancho máximo de 1400px (`AppConstants.maxContentWidth`) con márgenes laterales
   - Implementado con `ConstrainedBox(maxWidth: AppConstants.maxContentWidth)` y `Center`
   - Aplicado en `PokedexView` y `PokemonDetailView`

2. **Tamaños ajustados**: Logo y AppBar más grandes, imágenes de Pokémon limitadas
   - `DrafteaLogo`: altura 32px en web vs 20px en mobile
   - `AppBar.toolbarHeight`: 80px en web vs 56px en mobile
   - Imágenes limitadas con `ConstrainedBox(maxHeight: 160, maxWidth: 160)` solo en web

3. **Responsive**: Grid adaptativo según tamaño de pantalla (2-4 columnas)
   - `WebConfig.getGridColumnCount()` y `MobileConfig.getGridColumnCount()`
   - Breakpoints: mobile (<600px), tablet (600-900px), desktop (>900px)

4. **Navegación optimizada**: Transiciones suaves con `RouteTransitions.smoothRoute()`
   - Combinación de fade + slide para mejor UX web
   - `Hero` widgets para transiciones compartidas entre listado y detalle
   - Ver `lib/core/utils/route_transitions.dart`

5. **Performance**: Scroll infinito con `NotificationListener<ScrollNotification>`
   - Evita problemas de contexto en web
   - Carga incremental sin bloquear UI
   - Lazy loading implícito al cargar solo lo visible

6. **Interacción tipo desktop**: 
   - Grid más espacioso (`childAspectRatio: 0.95` en web vs `0.85` en mobile)
   - Indicador de estado offline visible en AppBar
   - Hover states naturales de Material Design

### Limitaciones y Mitigaciones

**Limitaciones:**
- GIFs animados requieren paquetes adicionales (resuelto con imagen estática JPG)
- Caché de imágenes depende del navegador (no control total)
- Performance puede degradarse con muchos elementos visibles (100+ Pokémon)
- Scroll infinito puede acumular muchos widgets en memoria

**Mitigaciones:**
- Usar imágenes estáticas (`imagen_splash.jpg`) en lugar de GIFs pesados
- Limitar tamaño de imágenes en web con `ConstrainedBox`
- Implementar lazy loading (ya implementado con scroll infinito)
- Considerar virtualización (`ListView.builder` con `cacheExtent` limitado) para listas muy grandes
- Limpiar caché expirado al iniciar para liberar memoria

## 🧹 Calidad: Código Limpio

### 3 Decisiones Aplicadas

1. **Nombres descriptivos y autodocumentados**:
   ```dart
   // ❌ Mal (lib/modulo/pokemon/presentation/cubit/pokedex_cubit.dart)
   void load() { ... }
   
   // ✅ Bien
   Future<void> loadPokemonList() async { ... }
   Future<void> loadMorePokemon() async { ... }
   ```
   - Los nombres explican exactamente qué hace cada método
   - No requiere comentarios adicionales para entender la intención

2. **Funciones pequeñas y enfocadas (Single Responsibility)**:
   ```dart
   // lib/modulo/pokemon/presentation/cubit/pokedex_cubit.dart
   // Cada método tiene una responsabilidad única
   Future<void> loadPokemonList() async { ... }  // Solo carga inicial
   Future<void> loadMorePokemon() async { ... }  // Solo carga más
   ```
   - Separación clara entre carga inicial y paginación
   - Fácil de testear y mantener

3. **Eliminación de código duplicado (DRY - Don't Repeat Yourself)**:
   ```dart
   // lib/modulo/pokemon/presentation/views/pokedex_view.dart línea 30-32
   // Getter isWeb reutilizable en lugar de verificar múltiples veces
   bool get isWeb => Theme.of(context).platform == TargetPlatform.windows ||
                     Theme.of(context).platform == TargetPlatform.linux ||
                     Theme.of(context).platform == TargetPlatform.macOS;
   
   // Uso: isWeb ? valorWeb : valorMobile
   ```
   - Evita repetir la misma lógica de detección de plataforma
   - Un solo lugar para cambiar la lógica si es necesario
   - También aplicado en `DrafteaLogo` con `_getHeight()` para evitar duplicación

## 🧪 Testing

### Qué se Testearía (Prioridad)

1. **Cubits** (Alta prioridad):
   - `PokedexCubit` (`lib/modulo/pokemon/presentation/cubit/pokedex_cubit.dart`):
     - Verificar transición de estados: `_Initial` → `_Loading` → `_Loaded`
     - Verificar `loadMorePokemon()` incrementa `currentOffset` correctamente
     - Verificar manejo de errores emite `_Error`
   - `PokemonDetailCubit` (`lib/modulo/pokemon/presentation/modules/pokemon_detail/cubit/pokemon_detail_cubit.dart`):
     - Verificar carga de detalles desde API
     - Verificar carga desde caché cuando offline

2. **Repositorios** (Alta prioridad):
   - `PokemonRepositoryImpl` (`lib/modulo/pokemon/data/repositories/pokemon_repository_impl.dart`):
     - Mock `ConnectivityService` para simular online/offline
     - Verificar que cuando online, obtiene de API y guarda en caché
     - Verificar que cuando offline, obtiene de caché
     - Verificar fallback a caché si API falla estando online

3. **Widgets críticos** (Media prioridad):
   - `PokemonCardWidget`: Verificar renderizado con datos válidos
   - `SplashScreen`: Verificar navegación después de delay (3 segundos)
   - `PokedexView`: Verificar scroll infinito dispara `loadMorePokemon()`

4. **Servicios** (Media prioridad):
   - `CacheService` (`lib/core/services/cache_service.dart`):
     - Verificar `cachePokemonList()` guarda correctamente
     - Verificar `getCachedPokemonList()` retorna null si expiró
     - Verificar `clearExpiredCache()` elimina entradas vencidas
   - `ConnectivityService` (`lib/core/services/connectivity_service.dart`):
     - Mock `connectivity_plus` para verificar detección de red

**Qué asegurarían:**
- Estados correctos en diferentes escenarios (loading, loaded, error)
- Funcionamiento offline correcto (fallback a caché)
- Caché funcionando como se espera (expiración, guardado, recuperación)
- UI renderizando correctamente (widgets con datos mock)
- Lógica de negocio aislada y testeable (sin dependencias de UI)

## 📝 Git

### Estructura de Commits

**Granularidad**: Un commit por feature o fix lógico
**Mensajes**: Convención Conventional Commits
- `feat:` para nuevas funcionalidades
- `fix:` para correcciones
- `chore:` para tareas de mantenimiento
- `refactor:` para refactorizaciones

**Ejemplos:**
```
feat: implementar scroll infinito y configurar iconos de la app
fix: corregir ProviderNotFoundError en scroll infinito
chore: eliminar .cursorrules del repositorio
```

**Beneficios**:
- Facilita revisión de código
- Historial claro y navegable
- Fácil identificar cambios por tipo
- Compatible con herramientas de CI/CD

## 📋 Pendientes

### Top 5 Priorizados

1. **Tests automatizados** (Alta prioridad)
   - Implementación: Agregar `flutter_test` y `mockito`
   - Tests unitarios para Cubits y Repositorios
   - Tests widget para componentes críticos
   - Aseguraría: Confianza en refactorizaciones y nuevas features

2. **Optimización de imágenes** (Media prioridad)
   - Implementación: Usar `cached_network_image` o similar
   - Pre-carga de imágenes de siguiente página
   - Compresión de imágenes para web
   - Aseguraría: Mejor performance y menos consumo de datos

3. **Búsqueda y filtros** (Media prioridad)
   - Implementación: Campo de búsqueda en AppBar
   - Filtros por tipo de Pokémon
   - Búsqueda local en caché cuando offline
   - Aseguraría: Mejor UX para encontrar Pokémon específicos

4. **Manejo de errores avanzado** (Baja prioridad)
   - Implementación: Categorización de errores (red, servidor, caché)
   - Mensajes más específicos y útiles
   - Retry automático con backoff exponencial
   - Aseguraría: Mejor experiencia cuando hay problemas

5. **Tema oscuro completo** (Baja prioridad)
   - Implementación: Completar `AppTheme.darkTheme`
   - Toggle de tema en settings
   - Persistencia de preferencia de tema
   - Aseguraría: Mejor experiencia visual según preferencias

## 📄 Licencia

Este proyecto es parte de un challenge técnico.

## 👤 Autor

Desarrollado como parte del challenge técnico de DRAFTEA.

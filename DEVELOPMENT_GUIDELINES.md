# I-Mart Development Guidelines

> **Last Updated**: 2026-01-17
> **Project**: I-Mart Grocery Application
> **Architecture**: Clean Architecture + Riverpod State Management

---

## ⚠️ CRITICAL RULES - READ FIRST

### 🚫 NEVER MODIFY EXISTING UI OR COMPLETED LOGIC

**STRICT ENFORCEMENT:**

1. **DO NOT change any completed UI components** - If a screen, widget, or component is already implemented and working, DO NOT modify its:
   - Visual design (colors, spacing, sizes, fonts)
   - Layout structure (Stack, Column, Row arrangements)
   - Animations or transitions
   - Existing state management logic

2. **DO NOT alter done backend integration** - If an API integration is complete and working:
   - DO NOT change the endpoint structure
   - DO NOT modify the data flow (API → Repository → Provider → UI)
   - DO NOT change entity/model structures unless absolutely necessary
   - DO NOT refactor working provider logic

3. **ONLY add new features or fix bugs** - You may only:
   - Add new screens, components, or widgets
   - Implement new API endpoints following existing patterns
   - Fix actual bugs or errors
   - Add new providers for new features
   - Extend entities with new optional fields (backwards compatible)

4. **When in doubt, ASK FIRST** - Before making ANY changes to existing code:
   - Check if it's a new feature (allowed) or modification (restricted)
   - Verify with project lead if unsure
   - Document the reason for any exception

---

## 📁 Project Structure & Clean Architecture

### Folder Organization (Enforced by pre-commit hook)

```
lib/
├── app/                                    # Application-level configuration
│   ├── bootstrap/                          # App initialization (Hive, env)
│   ├── config/                             # AppConfig, constants, feature flags
│   ├── core/                               # DEPRECATED - use lib/core/
│   ├── router/                             # GoRouter setup, auth guards
│   └── theme/                              # Colors, typography, spacing
│
├── core/                                   # Shared utilities (cross-feature)
│   ├── application/providers/              # App-wide providers
│   ├── config/                             # Core configuration
│   ├── constants/                          # HiveBoxes, keys, app constants
│   ├── error/                              # Failure classes, error widgets
│   ├── extensions/                         # Dart/Flutter extensions
│   ├── network/                            # ApiClient, endpoints, exceptions
│   ├── providers/                          # Dio, CookieJar providers
│   ├── services/                           # Voice search, location services
│   ├── storage/hive/                       # Hive setup, boxes, adapters
│   ├── utils/                              # Validators, date utils, logger
│   └── widgets/                            # AppButton, AppText, AppError, etc.
│
└── features/                               # Feature modules (Clean Architecture)
    ├── auth/
    │   ├── domain/                         # Business logic (pure Dart)
    │   │   ├── entities/                   # UserEntity, AddressEntity, etc.
    │   │   └── repositories/               # Repository contracts (abstract)
    │   │
    │   ├── application/                    # Application layer
    │   │   ├── providers/                  # Riverpod providers (@riverpod)
    │   │   ├── states/                     # Sealed state classes
    │   │   └── usecases/                   # [Optional] Use case classes
    │   │
    │   ├── infrastructure/                 # Data layer (implementation)
    │   │   ├── data_sources/
    │   │   │   ├── remote/                 # AuthApi (Dio-based)
    │   │   │   └── local/                  # AuthLocalDs (Hive-based)
    │   │   ├── models/                     # [Optional] DTOs for serialization
    │   │   └── repositories/               # Repository implementations
    │   │
    │   └── presentation/                   # UI layer
    │       ├── screen/                     # Full screens (LoginScreen, etc.)
    │       ├── components/                 # Complex widgets (auth bottom sheet)
    │       └── widgets/                    # Small UI pieces (input fields, etc.)
    │
    ├── home/                               # Same structure as auth
    ├── cart/                               # Same structure as auth
    ├── profile/                            # Same structure as auth
    │
    ├── common/                             # [Optional] Shared feature code
    └── widgets/                            # [Optional] Cross-feature widgets
```

### File Naming Conventions

**REQUIRED PATTERNS (enforced by pre-commit hook):**

- **Snake case only**: `auth_repository.dart`, `home_screen.dart`, `user_entity.dart`
- **Generated files**: `*.g.dart`, `*.freezed.dart` (auto-generated, do not edit)
- **Providers**: `*_provider.dart` (e.g., `auth_provider.dart`, `home_data_provider.dart`)
- **Screens**: `*_screen.dart` or descriptive names (e.g., `home.dart`, `profile.dart`)
- **Components**: Descriptive names (e.g., `home_top_section_ui.dart`)

**RESTRICTED FILE NAMES (only allowed in specific folders):**

```bash
lib/app/bootstrap/       → app_bootstrap.dart, hive_init.dart, env_loader.dart
lib/app/config/          → env.dart, constants.dart, feature_flags.dart, app_config.dart
lib/app/router/          → app_router.dart, auth_guard.dart
lib/app/theme/           → colors.dart, typography.dart, theme.dart, app_spacing.dart
lib/core/network/        → api_client.dart, endpoints.dart, network_exceptions.dart
lib/core/storage/hive/   → boxes.dart, keys.dart
lib/core/utils/          → date_utils.dart, validators.dart, logger.dart
```

**❌ FORBIDDEN:**
- PascalCase filenames: `HomeScreen.dart` (use `home_screen.dart`)
- Camel case: `homeScreen.dart` (use `home_screen.dart`)
- Random files in `lib/` root (except `main.dart`, `globals.dart`)

---

## 🔄 State Management Patterns (Riverpod)

### Code Generation with @riverpod

**✅ ALWAYS use code generation** - Never use manual providers:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';  // Required for code generation

// ✅ CORRECT
@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    return const AuthChecking();
  }
}

// ❌ WRONG
final authProvider = NotifierProvider<Auth, AuthState>((ref) {
  return Auth();
});
```

### Provider Types & Patterns

#### 1. Notifier (Mutable State)

**Use for:** Stateful logic with multiple state transitions (auth, cart, checkout)

```dart
@Riverpod(keepAlive: true)  // keepAlive prevents auto-disposal
class Auth extends _$Auth {
  @override
  AuthState build() {
    _checkExistingSession();  // Initialize
    return const AuthChecking();
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();  // Update state

    final result = await _repository.login(email: email, password: password);

    result.fold(
      (failure) => state = AuthError(failure, state),
      (user) => state = Authenticated(user: user),
    );
  }
}

// Generated as:
// final authProvider = NotifierProvider<Auth, AuthState>
```

**CRITICAL RULES:**
- ✅ Use `state =` to update (only inside Notifier classes)
- ❌ NEVER use `ref.read(provider).state =` outside Notifier
- ✅ Use `keepAlive: true` for app-wide state (auth, cart)
- ✅ Use sealed classes for type-safe states

#### 2. FutureProvider (Async Data Fetching)

**Use for:** One-time async data fetching, auto-caching

```dart
@riverpod
Future<List<Category>> categories(Ref ref, {bool? isOffer}) async {
  debugPrint('🔄 Fetching categories (isOffer: $isOffer)');

  final repository = ref.watch(homeRepositoryProvider);
  final response = await repository.getCategories(isOffer: isOffer);

  debugPrint('✅ Categories fetched: ${response.categories.length}');
  return response.categories;
}

// Generated as:
// final categoriesProvider = FutureProvider.family<List<Category>, bool?>
```

**CRITICAL RULES:**
- ✅ Use `debugPrint` for logging (NOT `print`)
- ✅ Always watch repository provider: `ref.watch(repositoryProvider)`
- ✅ Handle errors with try-catch or let them propagate to UI
- ✅ Use `.future` accessor for async/await: `ref.watch(provider.future)`

#### 3. Simple Provider (Dependency Injection)

**Use for:** Factory providers, repository instances, API clients

```dart
@riverpod
HomeRepository homeRepository(Ref ref) {
  final api = ref.watch(homeApiProvider);
  return HomeRepositoryImpl(api);
}

@riverpod
HomeApi homeApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return HomeApi(dio);
}

// Generated as:
// final homeRepositoryProvider = Provider<HomeRepository>
// final homeApiProvider = Provider<HomeApi>
```

#### 4. Provider Composition (Dependencies)

**Use for:** Providers that depend on other providers

```dart
@riverpod
Future<List<ProductVariant>> offerCategoryProducts(Ref ref) async {
  // Watch another provider
  final categories = await ref.watch(offerCategoriesProvider.future);

  if (categories.isEmpty) {
    debugPrint('⚠️ No offer categories found');
    return [];
  }

  // Use data from first provider to fetch more data
  final firstCategory = categories.first;
  final repository = ref.watch(homeRepositoryProvider);
  final response = await repository.getCategoryProducts(
    categoryId: firstCategory.id,
  );

  return response.products;
}
```

**CRITICAL RULES:**
- ✅ Use `await ref.watch(provider.future)` for async dependencies
- ✅ Handle empty/null cases gracefully
- ✅ Chain providers to create composite data flows
- ❌ AVOID circular dependencies (provider A watches B, B watches A)

### Consuming Providers in UI

#### Pattern 1: AsyncValue.when() (Recommended)

```dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final discountedProductsAsync = ref.watch(discountedProductsProvider);

    return discountedProductsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Text('No products available');
        }
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(product: products[index]),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

#### Pattern 2: Listen for Side Effects

```dart
ref.listen<AuthState>(authProvider, (prev, next) {
  if (next is AuthError) {
    AppSnackbar.showError(context, message: next.failure.message);
  } else if (next is Authenticated) {
    context.go('/home');
  }
});
```

#### Pattern 3: Read (One-time Access)

```dart
void _handleLogin() async {
  // Use .notifier for Notifier methods
  await ref.read(authProvider.notifier).login(email, password);

  // Use .read() for one-time value access (avoid in build)
  final currentState = ref.read(authProvider);
}
```

**CRITICAL RULES:**
- ✅ Use `ref.watch()` in build method
- ✅ Use `ref.listen()` for side effects (navigation, snackbars)
- ✅ Use `ref.read()` in callbacks/event handlers
- ❌ NEVER use `ref.read()` in build method (won't rebuild)

---

## 🌐 Backend Integration Checklist

### API Configuration

**File:** `lib/app/core/config/app_config.dart`

The project uses centralized API configuration for all backend URLs and app settings:

```dart
class AppConfig {
  // ============================================================================
  // API BASE URLS
  // ============================================================================

  /// Main backend API server
  /// This is used for all API requests (auth, products, orders, cart, etc.)
  static const String apiBaseUrl = 'http://156.67.104.149:8012';

  /// API base URL with trailing slash (for some endpoints that need it)
  static const String apiBaseUrlWithSlash = '$apiBaseUrl/';

  /// WebSocket server URL (if different from API server)
  static const String webSocketUrl = apiBaseUrl;

  // ============================================================================
  // CDN / MEDIA URLS
  // ============================================================================

  /// CDN base URL for images and media files
  /// This is where product images, category images, etc. are hosted
  static const String cdnBaseUrl = 'https://grocery-application.b-cdn.net';

  /// Internal server base URL (used for image URL conversion)
  /// Images from this URL are converted to CDN URLs for better performance
  static const String internalServerBase = apiBaseUrl;

  // ============================================================================
  // API TIMEOUT CONFIGURATION
  // ============================================================================

  /// Connection timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Receive timeout duration
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Send timeout duration
  static const Duration sendTimeout = Duration(seconds: 30);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Convert internal server URLs to CDN URLs for images
  /// This improves performance by serving images from CDN instead of backend
  static String convertToCdnUrl(String url) {
    if (url.isEmpty) return url;

    // Already a CDN URL
    if (url.startsWith(cdnBaseUrl)) return url;

    // Already has HTTPS protocol (external URL)
    if (url.startsWith('https://') && !url.startsWith(internalServerBase)) {
      return url;
    }

    // Internal server URL - convert to CDN
    if (url.startsWith(internalServerBase)) {
      return url.replaceFirst(internalServerBase, cdnBaseUrl);
    }

    // Relative URL - add CDN base
    if (url.startsWith('/')) {
      return '$cdnBaseUrl$url';
    }

    // No protocol - add HTTPS and CDN base
    return '$cdnBaseUrl/$url';
  }

  /// Get full API URL by appending path to base URL
  static String getApiUrl(String path) {
    if (path.startsWith('/')) {
      return '$apiBaseUrl$path';
    }
    return '$apiBaseUrl/$path';
  }
}
```

**Usage in Dio Setup:**
```dart
// In main.dart or bootstrap
Dio(
  BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.sendTimeout,
  ),
)

// For CDN images
final cdnImageUrl = AppConfig.convertToCdnUrl(imageUrl);

// For API endpoints
final fullUrl = AppConfig.getApiUrl('/api/products/v1/');
```

**Rules:**
- ✅ Use `AppConfig.apiBaseUrl` for all API requests
- ✅ Use `AppConfig.cdnBaseUrl` for image CDN
- ✅ Use `AppConfig.convertToCdnUrl()` to convert image URLs
- ✅ Use `AppConfig.getApiUrl()` for constructing full URLs
- ❌ NEVER hardcode API URLs in code
- ❌ NEVER hardcode timeout values

**Important Notes:**
- All cart endpoints require authentication (session cookie + CSRF token)
- Guest mode uses `dev: 2` header instead of authentication
- Cookies are managed automatically by global `dioProvider`

### Step-by-Step Integration Flow

#### Step 1: Define Endpoint

**File:** `lib/app/core/network/endpoints.dart`

```dart
class HomeEndpoints {
  const HomeEndpoints._();

  // Static endpoint
  static const String discountedVariants = '/api/products/v1/variants/discounts/';

  // Dynamic endpoint (using query parameter)
  static String categoryProducts(String categoryId) =>
      'api/products/v1/?category_id=$categoryId';
}
```

**Rules:**
- ✅ Use descriptive names
- ✅ Group by feature (HomeEndpoints, AuthEndpoints, etc.)
- ✅ Use `const` for static endpoints
- ✅ Use functions for dynamic endpoints with parameters

#### Step 2: Create/Update Domain Entity

**File:** `lib/features/home/domain/entities/product_variant.dart`

```dart
import 'package:equatable/equatable.dart';

class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.discountedPrice,
    this.media = const [],
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    // Parse media list
    final mediaList = (map['media'] as List?)
        ?.map((item) => ProductMedia.fromMap(item as Map<String, dynamic>))
        .toList() ?? [];

    return ProductVariant(
      id: map['id'] as int,
      name: map['name'] as String,
      price: map['price'] as String,
      discountedPrice: map['discounted_price'] as String,
      media: mediaList,
    );
  }

  final int id;
  final String name;
  final String price;
  final String discountedPrice;
  final List<ProductMedia> media;

  // Helper getters
  double get priceValue => double.tryParse(price) ?? 0.0;
  double get discountedPriceValue => double.tryParse(discountedPrice) ?? 0.0;
  double get discountPercentage {
    if (priceValue == 0) return 0;
    return (priceValue - discountedPriceValue) / priceValue * 100;
  }
  bool get hasDiscount => discountedPriceValue < priceValue;
  String? get primaryImageUrl => media.isNotEmpty ? media.first.imageUrl : null;

  @override
  List<Object?> get props => [id, name, price, discountedPrice];
}
```

**Rules:**
- ✅ Use `Equatable` for value equality
- ✅ Use `const` constructor if all fields are final
- ✅ Use `fromMap` factory for JSON parsing
- ✅ Add helper getters for computed properties
- ✅ Use `??` for null safety
- ✅ Parse nested objects recursively
- ✅ Fix image URLs (prepend `https://` if missing)

**Image URL Fixing Pattern:**
```dart
factory ProductMedia.fromMap(Map<String, dynamic> map) {
  String? fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return url;
    if (url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('assets/')) {
      return url;
    }
    return 'https://$url';  // Prepend https://
  }

  return ProductMedia(
    id: map['id'] as int,
    imageUrl: fixImageUrl(map['image'] as String) ?? '',
  );
}
```

#### Step 3: Add API Method

**File:** `lib/features/home/infrastructure/data_sources/remote/home_api.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:imart/app/core/network/endpoints.dart';
import 'package:imart/app/core/network/network_exceptions.dart';

part 'home_api.g.dart';

@riverpod
HomeApi homeApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return HomeApi(dio);
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;
}

class HomeApi {
  HomeApi(this._dio);
  final Dio _dio;

  Future<PaginatedResponse<ProductVariant>> getDiscountedProducts({
    int? page,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) {
        queryParams['page'] = page;
      }

      debugPrint('🌐 [HomeApi] Fetching discounted products: $queryParams');
      final res = await _dio.get(
        HomeEndpoints.discountedVariants,
        queryParameters: queryParams,
      );

      debugPrint('✅ [HomeApi] Response: ${res.statusCode}');
      if (res.statusCode != 200) {
        throw Exception('Get discounted products failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final count = data['count'] as int;
      final next = data['next'] as String?;
      final previous = data['previous'] as String?;
      final results = (data['results'] as List)
          .map((item) => ProductVariant.fromMap(item as Map<String, dynamic>))
          .toList();

      debugPrint('📦 [HomeApi] Parsed ${results.length} products');
      return PaginatedResponse(
        count: count,
        next: next,
        previous: previous,
        results: results,
      );
    } catch (e) {
      debugPrint('❌ [HomeApi] Error: $e');
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }
}
```

**Rules:**
- ✅ Use `debugPrint` with emoji prefixes (`🌐`, `✅`, `❌`, `📦`)
- ✅ Check `statusCode` explicitly
- ✅ Parse `count`, `next`, `previous` for pagination
- ✅ Use `.map()` to parse list of entities
- ✅ Wrap in try-catch and use `mapDioError()`
- ✅ Use `PaginatedResponse<T>` wrapper for paginated endpoints

#### Step 4: Update Repository Interface

**File:** `lib/features/home/domain/repositories/home_repository.dart`

```dart
import '../entities/category.dart';
import '../entities/product_variant.dart';
import '../entities/promo_banner.dart';

abstract class HomeRepository {
  /// Get discounted product variants (Best Deals)
  /// Returns list of product variants with discounts and pagination info
  Future<({List<ProductVariant> products, int count, String? next})>
      getDiscountedProducts({
    int? page,
  });

  /// Get products by category ID (Mega Fresh offers)
  Future<({List<ProductVariant> products, int count, String? next})>
      getCategoryProducts({
    required int categoryId,
    int? page,
  });
}
```

**Rules:**
- ✅ Use abstract class
- ✅ Add documentation comments
- ✅ Use named records for return types: `({Type field1, Type field2})`
- ✅ Use named parameters for optional args: `{int? page}`
- ✅ Use required named params: `{required int categoryId}`

#### Step 5: Implement Repository

**File:** `lib/features/home/infrastructure/repositories/home_repository_impl.dart`

```dart
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_sources/remote/home_api.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._homeApi);

  final HomeApi _homeApi;

  @override
  Future<({List<ProductVariant> products, int count, String? next})>
      getDiscountedProducts({
    int? page,
  }) async {
    final response = await _homeApi.getDiscountedProducts(page: page);
    return (
      products: response.results,
      count: response.count,
      next: response.next,
    );
  }

  @override
  Future<({List<ProductVariant> products, int count, String? next})>
      getCategoryProducts({
    required int categoryId,
    int? page,
  }) async {
    final response = await _homeApi.getCategoryProducts(
      categoryId: categoryId,
      page: page,
    );
    return (
      products: response.results,
      count: response.count,
      next: response.next,
    );
  }
}
```

**Rules:**
- ✅ Implement all abstract methods
- ✅ Pass API response directly (no transformation here)
- ✅ Use named record syntax for returns
- ❌ DO NOT add business logic here (belongs in domain/usecases)

#### Step 6: Create Provider

**File:** `lib/features/home/application/providers/home_data_provider.dart`

```dart
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/product_variant.dart';
import 'home_repository_provider.dart';

part 'home_data_provider.g.dart';

/// Provider for fetching discounted products (Best Deals)
@riverpod
Future<List<ProductVariant>> discountedProducts(Ref ref) async {
  debugPrint('🔄 [Provider] Fetching discounted products');
  final repository = ref.watch(homeRepositoryProvider);
  final response = await repository.getDiscountedProducts();
  debugPrint('✨ [Provider] Discounted products fetched: ${response.products.length}');
  return response.products;
}

/// Provider for fetching products from first offer category (Mega Fresh offers)
@riverpod
Future<List<ProductVariant>> offerCategoryProducts(Ref ref) async {
  debugPrint('🔄 [Provider] Fetching offer category products');

  // First, get offer categories
  final categories = await ref.watch(offerCategoriesProvider.future);

  if (categories.isEmpty) {
    debugPrint('⚠️ [Provider] No offer categories found');
    return [];
  }

  // Get products from the first offer category
  final firstCategory = categories.first;
  debugPrint('🔄 [Provider] Fetching products from category: ${firstCategory.name} (ID: ${firstCategory.id})');

  final repository = ref.watch(homeRepositoryProvider);
  final response = await repository.getCategoryProducts(
    categoryId: firstCategory.id,
  );

  debugPrint('✨ [Provider] Offer category products fetched: ${response.products.length}');
  return response.products;
}
```

**Rules:**
- ✅ Add documentation comments above each provider
- ✅ Use `debugPrint` with emoji prefixes
- ✅ Watch repository provider: `ref.watch(repositoryProvider)`
- ✅ Return only the data needed by UI (not full response)
- ✅ Handle empty cases gracefully
- ✅ Use `.future` for async dependencies

#### Step 7: Generate Provider Code

**Run build_runner:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Rules:**
- ✅ Run after creating/modifying any `@riverpod` provider
- ✅ Commit generated `.g.dart` files to git
- ❌ NEVER manually edit `.g.dart` files

#### Step 8: Use in UI

**File:** `lib/features/home/presentation/home.dart`

```dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGoToItemsSection(),
            _buildOffersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoToItemsSection() {
    final discountedProductsAsync = ref.watch(discountedProductsProvider);

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Best Deals', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () {},
                child: Text('See All', style: TextStyle(fontSize: 14.sp, color: Color(0xFF25A63E))),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Product list
        SizedBox(
          height: 195.h,
          child: discountedProductsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Text('No products available', style: TextStyle(fontSize: 14.sp)),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: _ProductCard(
                      key: ValueKey('discounted_${product.id}'),
                      title: product.name,
                      price: '₹ ${product.discountedPrice}',
                      discount: '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                      imagePath: product.primaryImageUrl ?? '',
                      productVariant: product,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50)),
            ),
            error: (error, stack) => Center(
              child: Text('Failed to load products', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Rules:**
- ✅ Use `ref.watch(provider)` in build method
- ✅ Use `AsyncValue.when()` for handling data/loading/error states
- ✅ Add empty state handling
- ✅ Use `const` for loading/error widgets when possible
- ✅ Use `ValueKey` for list items with unique IDs
- ✅ Use ScreenUtil extensions (`.w`, `.h`, `.sp`, `.r`)
- ✅ Handle null safely (`??` operator)

---

## 🔐 Authentication & Session Management

### Auth State Machine (Sealed Classes)

**File:** `lib/features/auth/application/states/auth_state.dart`

```dart
sealed class AuthState {
  const AuthState();
}

class AuthChecking extends AuthState {
  const AuthChecking();
}

class GuestMode extends AuthState {
  const GuestMode();
}

class OtpSending extends AuthState {
  const OtpSending(this.mobileNumber);
  final String mobileNumber;
}

class OtpSent extends AuthState {
  const OtpSent({
    required this.mobileNumber,
    required this.isSuccess,
    required this.expiresInSeconds,
  });
  final String mobileNumber;
  final bool isSuccess;
  final int expiresInSeconds;
}

class Authenticated extends AuthState {
  const Authenticated({required this.user, this.isNewUser = false});
  final UserEntity user;
  final bool isNewUser;
}

class AuthError extends AuthState {
  const AuthError(this.failure, this.previousState);
  final Failure failure;
  final AuthState previousState;
}
```

**Rules:**
- ✅ Use `sealed` for exhaustive pattern matching
- ✅ Make all states const
- ✅ Store previous state in error for recovery
- ✅ Add contextual data (mobile number, user, etc.)

### Session Persistence Flow

#### On App Start (Check Existing Session)

```dart
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    _checkExistingSession();
    return const AuthChecking();
  }

  Future<void> _checkExistingSession() async {
    try {
      // Check for valid session cookie
      final session = await _repository.getCurrentSession();

      if (session != null) {
        // Retrieve saved user from Hive
        final user = await _repository.getSavedUser();

        if (user != null) {
          debugPrint('✅ [Auth] Session restored for user: ${user.email}');
          state = Authenticated(user: user, isNewUser: false);
          return;
        }
      }

      debugPrint('⚠️ [Auth] No valid session, entering guest mode');
      state = const GuestMode();
    } catch (e) {
      debugPrint('❌ [Auth] Session check failed: $e');
      await _repository.logout();  // Clear corrupted data
      state = const GuestMode();
    }
  }
}
```

#### Guest Mode vs Authenticated

**API Interceptor:**
```dart
// In ApiClient initialization (main.dart)
api.isGuestMode = () {
  final authState = _container.read(authProvider);
  return authState is GuestMode;
};

// In Dio interceptor (api_client.dart)
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final isGuest = isGuestMode?.call() ?? false;

    if (isGuest) {
      // Guest mode: special header
      options.headers['dev'] = '2';
      debugPrint('🔓 [API] Guest mode request to ${options.path}');
    } else {
      // Authenticated: add CSRF token
      final csrf = await _getCsrfToken();
      if (csrf != null) {
        options.headers['X-CSRFToken'] = csrf;
        debugPrint('🔐 [API] Authenticated request to ${options.path}');
      }
    }

    handler.next(options);
  },
));
```

**Rules:**
- ✅ Check auth state before every API request
- ✅ Add `dev: 2` header for guest mode
- ✅ Add CSRF token for authenticated users
- ✅ Log auth context in debug builds

### Cookie-Based Session Management

**Session Cookie Validation:**
```dart
Future<Cookie?> getValidSession(String url) async {
  final cookies = await getCookies(url);
  final now = DateTime.now();

  for (final c in cookies) {
    // Check if cookie name contains 'session'
    if (c.name.toLowerCase().contains('session') &&
        c.value.trim().isNotEmpty) {

      // Check expiry
      if (c.expires != null && c.expires!.isBefore(now)) {
        debugPrint('⚠️ [Session] Cookie expired: ${c.name}');
        continue;
      }

      debugPrint('✅ [Session] Valid session found: ${c.name}');
      return c;
    }
  }

  debugPrint('❌ [Session] No valid session cookie found');
  return null;
}
```

**CSRF Token Extraction:**
```dart
Future<String?> _getCsrfToken() async {
  final cookies = await cookieJar.loadForRequest(
    Uri.parse(dio.options.baseUrl),
  );

  final csrfCookie = cookies.firstWhere(
    (c) => c.name.toLowerCase() == 'csrftoken',
    orElse: () => Cookie('', ''),
  );

  if (csrfCookie.value.isEmpty) {
    debugPrint('⚠️ [CSRF] No CSRF token found');
    return null;
  }

  debugPrint('✅ [CSRF] Token extracted: ${csrfCookie.value.substring(0, 8)}...');
  return csrfCookie.value;
}
```

**Rules:**
- ✅ Validate session cookies on app start
- ✅ Check cookie expiry dates
- ✅ Extract CSRF token from cookies
- ✅ Clear cookies on logout
- ✅ Log session status in debug builds

### Login/Signup/Logout Flows

#### OTP Login Flow
```dart
// 1. Send OTP
await ref.read(authProvider.notifier).sendOtp(mobileNumber);
// State: GuestMode → OtpSending → OtpSent

// 2. Verify OTP
await ref.read(authProvider.notifier).verifyOtp(mobile, otp);
// State: OtpSent → OtpVerifying → Authenticated

// 3. Handle result in UI
ref.listen<AuthState>(authProvider, (prev, next) {
  if (next is Authenticated) {
    if (next.user.firstName.isEmpty) {
      context.go('/welcome-name');  // New user onboarding
    } else {
      context.go('/home');
    }
  } else if (next is AuthError) {
    AppSnackbar.showError(context, message: next.failure.message);
  }
});
```

#### Logout Flow
```dart
Future<void> logout() async {
  try {
    _otpExpiryTimer?.cancel();  // Cancel any timers

    // Clear all user data (cookies + Hive)
    await _repository.logout();

    debugPrint('✅ [Auth] Logout successful');
    state = const GuestMode();
  } catch (e) {
    debugPrint('❌ [Auth] Logout error: $e');
    state = const GuestMode();  // Always transition to guest
    rethrow;
  }
}

// In repository
@override
Future<void> logout() async {
  // Clear cookies
  await clearCookies();

  // Clear Hive boxes
  await Boxes.clearUserDataOnly();  // user, address, profile boxes
}
```

**Rules:**
- ✅ Cancel timers/streams on logout
- ✅ Clear both cookies AND local storage
- ✅ Always transition to GuestMode (even on error)
- ✅ Use `ref.listen()` for navigation after auth changes
- ✅ Handle new user onboarding (redirect to name screen)

---

## 🧪 Testing & Quality Assurance

### Pre-Commit Hook (7 Validation Steps)

**File:** `.git/hooks/pre-commit`

The project enforces the following checks BEFORE every commit:

1. **Dart Formatting** (`dart format`)
   - Checks for consistent code formatting
   - Auto-formats trailing commas

2. **Flutter Analyze** (`flutter analyze`)
   - Checks for static analysis issues
   - Must pass with 0 errors

3. **Custom Lint** (`dart run custom_lint`)
   - Additional linting rules (if enabled)
   - Skipped if not installed

4. **Debug Prints Check**
   - ✅ Allows `debugPrint()` for logging
   - ❌ Blocks `print()` statements (warns but doesn't block)

5. **Folder Structure Validation**
   - Enforces Clean Architecture folder rules
   - Blocks files in unauthorized locations

6. **Dart File Naming Validation**
   - Enforces snake_case naming
   - Restricts specific filenames to specific folders

7. **Riverpod State Mutation Check**
   - ❌ Blocks `.state =` outside Notifier/StateNotifier classes
   - ✅ Allows inside classes with `@riverpod` annotation

**To bypass (emergency only):**
```bash
git commit --no-verify -m "message"
```

### Testing Checklist (Before Commit)

#### 1. Code Quality
- [ ] Run `flutter analyze` → 0 issues
- [ ] Run `dart run custom_lint` (if applicable)
- [ ] Run `dart format .` for auto-formatting
- [ ] No `print()` statements (use `debugPrint`)

#### 2. Backend Integration
- [ ] Endpoint defined in `endpoints.dart`
- [ ] Entity has `fromMap` factory with null safety
- [ ] API method has try-catch and uses `mapDioError()`
- [ ] Repository interface and implementation added
- [ ] Provider created with `@riverpod` annotation
- [ ] `build_runner` executed successfully
- [ ] UI consumes provider with `AsyncValue.when()`

#### 3. State Management
- [ ] Sealed classes for type-safe states (if applicable)
- [ ] No direct `.state =` mutations outside Notifier
- [ ] Providers use `ref.watch()` for dependencies
- [ ] UI uses `ref.listen()` for side effects (navigation, snackbars)

#### 4. UI/UX
- [ ] Loading states handled (CircularProgressIndicator)
- [ ] Error states handled (error message or retry)
- [ ] Empty states handled (no data message)
- [ ] Network images have error fallbacks
- [ ] ScreenUtil used for responsive sizing (`.w`, `.h`, `.sp`, `.r`)

#### 5. Architecture Compliance
- [ ] Files in correct Clean Architecture layer
- [ ] File naming follows snake_case convention
- [ ] No business logic in UI layer
- [ ] No UI dependencies in domain layer
- [ ] Repository pattern followed (interface + implementation)

---

## 📝 Common Patterns & Best Practices

### Image Loading (Network Images)

```dart
Widget _buildProductImage() {
  final isNetworkImage = widget.imagePath.startsWith('http://') ||
      widget.imagePath.startsWith('https://');

  if (widget.imagePath.isEmpty) {
    return Icon(Icons.shopping_basket, size: 40.sp, color: Colors.grey);
  }

  if (isNetworkImage) {
    return Image.network(
      widget.imagePath,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: const Color(0xFF4CAF50),
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.shopping_basket, size: 40.sp, color: Colors.grey);
      },
    );
  }

  return Image.asset(widget.imagePath, fit: BoxFit.contain);
}
```

**Rules:**
- ✅ Always add `loadingBuilder` for network images
- ✅ Always add `errorBuilder` with fallback icon
- ✅ Handle empty image paths
- ✅ Use `fit: BoxFit.contain` for product images

### Responsive Design (ScreenUtil)

```dart
// Sizes
Container(
  width: 130.w,        // Width: 130 logical pixels
  height: 195.h,       // Height: 195 logical pixels
  padding: EdgeInsets.all(10.w),
  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
)

// Text
Text(
  'Product Name',
  style: TextStyle(
    fontSize: 14.sp,   // Font size: 14sp
    fontWeight: FontWeight.w600,
  ),
)

// Border Radius
BorderRadius.circular(16.r)  // Radius: 16r
```

**Design Size:** 390 x 835 (iPhone 12/13/14 Pro)

**Rules:**
- ✅ Always use `.w` for widths
- ✅ Always use `.h` for heights
- ✅ Always use `.sp` for font sizes
- ✅ Always use `.r` for border radius
- ❌ NEVER use raw numbers (e.g., `width: 130`)

### Error Handling (fpdart Either)

```dart
// In repository
@override
Future<Either<Failure, UserEntity>> login({
  required String email,
  required String password,
}) async {
  try {
    final user = await remote.login(email: email, password: password);
    await local.saveUser(user);

    // Validate session cookie
    final session = await local.getValidSession(ApiClient.baseUrl);
    if (session == null) {
      return const Left(AppFailure('No valid session cookie stored'));
    }

    return Right(user);
  } catch (e) {
    debugPrint('❌ [AuthRepo] Login error: $e');
    return Left(mapDioError(e));
  }
}

// In provider
Future<void> login(String email, String password) async {
  state = const AuthLoading();

  final result = await _repository.login(email: email, password: password);

  result.fold(
    (failure) {
      debugPrint('❌ [Auth] Login failed: ${failure.message}');
      state = AuthError(failure, state);
    },
    (user) {
      debugPrint('✅ [Auth] Login successful: ${user.email}');
      state = Authenticated(user: user);
    },
  );
}
```

**Rules:**
- ✅ Use `Either<Failure, T>` in repository methods
- ✅ Use `.fold()` to handle Left/Right cases
- ✅ Log errors with context
- ✅ Map DioException to domain Failures

### Navigation (GoRouter)

```dart
// Simple navigation
context.go('/home');
context.go('/profile');

// Navigation with parameters
context.go('/product/${productId}');

// Replace (no back)
context.replace('/home');

// Pop
context.pop();

// Check if can pop
if (context.canPop()) {
  context.pop();
} else {
  context.go('/home');
}
```

**Rules:**
- ✅ Use `context.go()` for navigation
- ✅ Use `context.replace()` for no-back navigation
- ✅ Always check `context.canPop()` before `pop()`
- ❌ NEVER use `Navigator.push` directly (use GoRouter)

---

## 🚀 Future Development Roadmap

### Upcoming Features (Backend Integration Required)

#### 1. Cart Feature
- **Endpoints needed:**
  - `GET /api/order/v1/checkout-lines/` - Get cart items
  - `POST /api/order/v1/checkout-lines/` - Add to cart
  - `PATCH /api/order/v1/checkout-lines/{id}/` - Update quantity
  - `DELETE /api/order/v1/checkout-lines/{id}/` - Remove from cart

- **Implementation checklist:**
  - [ ] Create `CheckoutLine` entity
  - [ ] Add endpoints to `endpoints.dart`
  - [ ] Create `CartApi` in `features/cart/infrastructure/data_sources/remote/`
  - [ ] Create `CartRepository` interface and implementation
  - [ ] Create `cartProvider` with Notifier pattern
  - [ ] Build cart UI with AsyncValue.when()
  - [ ] Add empty cart state
  - [ ] Add loading/error states

#### 2. Wishlist Feature
- **Endpoints needed:**
  - `GET /api/order/v1/wishlist/` - Get wishlist items
  - `POST /api/order/v1/wishlist/` - Add to wishlist
  - `DELETE /api/order/v1/wishlist/{id}/` - Remove from wishlist

#### 3. Orders Feature
- **Endpoints needed:**
  - `GET /api/order/v1/orders/` - Get order history
  - `GET /api/order/v1/orders/{id}/` - Get order details
  - `GET /api/order/v1/order-lines/?order={id}` - Get order items
  - `POST /api/order/v1/{orderId}/ratings/` - Rate order

#### 4. Checkout & Payment
- **Endpoints needed:**
  - `POST /api/order/v1/checkout/` - Initiate payment
  - `POST /api/order/v1/payment/verify/` - Verify payment
  - `PATCH /api/order/v1/checkouts/{id}/` - Apply coupon

#### 5. Address Management
- **Endpoints needed:**
  - `GET /api/auth/v1/address/` - Get addresses
  - `POST /api/auth/v1/address/` - Add address
  - `PATCH /api/auth/v1/address/{id}/` - Update address
  - `DELETE /api/auth/v1/address/{id}/` - Delete address

#### 6. Profile Management
- **Endpoints needed:**
  - `GET /api/auth/v1/profile/` - Get profile
  - `PATCH /api/auth/v1/profile/` - Update profile

---

## 🎯 Quick Reference

### File Creation Checklist

**New Backend Endpoint Integration:**
1. ✅ Define endpoint in `lib/app/core/network/endpoints.dart`
2. ✅ Create/update entity in `lib/features/{feature}/domain/entities/`
3. ✅ Add API method in `lib/features/{feature}/infrastructure/data_sources/remote/{feature}_api.dart`
4. ✅ Update repository interface in `lib/features/{feature}/domain/repositories/`
5. ✅ Implement repository in `lib/features/{feature}/infrastructure/repositories/`
6. ✅ Create provider in `lib/features/{feature}/application/providers/`
7. ✅ Run `dart run build_runner build --delete-conflicting-outputs`
8. ✅ Use provider in UI with `AsyncValue.when()`
9. ✅ Test: loading state, data state, error state, empty state
10. ✅ Run `flutter analyze` (must pass with 0 issues)

### Debug Logging Emoji Guide

- 🔄 - Starting operation / Fetching data
- ✅ - Success / Completed
- ❌ - Error / Failed
- ⚠️ - Warning / Edge case
- 📦 - Parsed data / Result
- 🌐 - Network request
- 🔐 - Authenticated request
- 🔓 - Guest mode request

### Common Commands

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Custom lint
dart run custom_lint

# Generate providers
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-generate)
dart run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs

# Run app (development)
flutter run

# Build release APK
flutter build apk --release
```

---

## 📞 Support & Questions

**Before modifying ANY existing code:**
1. Check this document for the pattern
2. Review similar implementations in the codebase
3. Ask the project lead if unsure
4. Document your decision in code comments

**Remember:**
- ✅ Follow existing patterns
- ✅ Add, don't modify
- ✅ Test before committing
- ✅ Document complex logic
- ❌ NEVER change working UI
- ❌ NEVER modify completed backend integration
- ❌ NEVER bypass pre-commit hooks (unless emergency)

---

**Document Version:** 1.0
**Last Review:** 2026-01-17
**Next Review:** After major feature completion

---

*This document is the single source of truth for I-Mart development. All team members must read and follow these guidelines.*

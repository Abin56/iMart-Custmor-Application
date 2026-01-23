# Wishlist Feature - Backend Implementation Guide

> **Purpose:** Complete backend implementation documentation for the Wishlist feature. This guide enables replication of wishlist management, real-time price updates via Socket.IO, and functional error handling in other projects with different UI frameworks.

---

## Table of Contents

1. [Overview](#overview)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Repository Pattern](#repository-pattern)
5. [Caching Strategy](#caching-strategy)
6. [State Management](#state-management)
7. [Wishlist Operations](#wishlist-operations)
8. [Real-Time Socket Integration](#real-time-socket-integration)
9. [Guest Mode Handling](#guest-mode-handling)
10. [Integration with Other Features](#integration-with-other-features)
11. [Error Handling](#error-handling)
12. [Architecture Overview](#architecture-overview)
13. [Replication Guide](#replication-guide)

---

## Overview

The Wishlist feature implements a **production-grade wishlist system** with:

- ✅ **Functional Error Handling** - Either<Failure, T> pattern (fpdart)
- ✅ **TTL-Based Caching** - 5-minute cache with stale fallback
- ✅ **Real-Time Updates** - Socket.IO price/inventory updates
- ✅ **State Preservation** - Keep data visible on errors
- ✅ **Guest Mode Support** - Auth state integration
- ✅ **Duplicate Prevention** - Check before adding
- ✅ **Type Safety** - Freezed unions for state
- ✅ **Clean Architecture** - Domain-driven design

**Tech Stack:**
- HTTP Client: Dio
- State Management: Riverpod (StateNotifier)
- Functional Programming: fpdart (Either)
- Code Generation: Freezed
- Real-Time: Socket.IO
- Architecture: Clean Architecture

---

## API Endpoints

### Base URL
```
http://156.67.104.149:8080
```

### Endpoint Summary

| Method | Endpoint | Description | Auth | Response |
|--------|----------|-------------|------|----------|
| GET | `/api/order/v1/wishlist/` | Fetch wishlist items | ✅ | 200 OK |
| POST | `/api/order/v1/wishlist/` | Add to wishlist | ✅ | 201 Created |
| DELETE | `/api/order/v1/wishlist/{id}/` | Remove from wishlist | ✅ | 204 No Content |
| GET | `/api/products/v1/variants/{id}/` | Fetch product details | ❌ | 200 OK |

---

### 1. Fetch Wishlist

**Endpoint:** `GET /api/order/v1/wishlist/`

**Purpose:** Get all items in user's wishlist

**Request:**
```http
GET /api/order/v1/wishlist/
Cookie: sessionid=xyz123
X-CSRFToken: abc456
```

**Response (Paginated Format):**
```json
{
  "count": 3,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "product_variant": 42,
      "added_at": "2024-01-17T10:00:00Z"
    },
    {
      "id": 2,
      "product_variant": 43,
      "added_at": "2024-01-17T11:30:00Z"
    }
  ]
}
```

**Response (Direct List Format):**
```json
[
  {
    "id": 1,
    "product_variant": 42,
    "added_at": "2024-01-17T10:00:00Z"
  },
  {
    "id": 2,
    "product_variant": 43,
    "added_at": "2024-01-17T11:30:00Z"
  }
]
```

**Implementation:**
```dart
Future<List<WishlistItem>> getWishlist() async {
  try {
    final response = await _apiClient.get('/api/order/v1/wishlist/');

    List<dynamic> itemsList;

    // Handle both response formats
    if (response.data is List) {
      itemsList = response.data as List;
    } else if (response.data is Map && response.data['results'] != null) {
      itemsList = response.data['results'] as List;
    } else {
      return [];
    }

    // For each wishlist item, fetch complete product details
    final List<WishlistItem> wishlistItems = [];

    for (final itemData in itemsList) {
      try {
        final wishlistId = itemData['id'] as int;
        final productVariantId = itemData['product_variant'].toString();

        // Fetch product details
        final productResponse = await _apiClient.get(
          '/api/products/v1/variants/$productVariantId/',
        );

        final wishlistItem = WishlistItem.fromProductVariantResponse(
          wishlistId: wishlistId,
          productData: productResponse.data,
        );

        wishlistItems.add(wishlistItem);
      } catch (e) {
        Logger.error('Failed to fetch product details', error: e);

        // Fallback: Create item from basic data
        final basicItem = WishlistItem.fromJson(itemData);
        wishlistItems.add(basicItem);
      }
    }

    return wishlistItems;
  } catch (e) {
    Logger.error('Failed to get wishlist', error: e);
    rethrow;
  }
}
```

**Key Features:**
- ✅ Handles two response formats (list vs paginated)
- ✅ Enriches each item with product details from variant API
- ✅ Falls back to basic data if product fetch fails
- ✅ Continues loading other items on individual failures

---

### 2. Add to Wishlist

**Endpoint:** `POST /api/order/v1/wishlist/`

**Purpose:** Add product to user's wishlist

**Request:**
```http
POST /api/order/v1/wishlist/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "product_variant": 42
}
```

**Response (201 Created):**
```json
{
  "id": 3,
  "product_variant": 42,
  "added_at": "2024-01-18T10:00:00Z"
}
```

**Error (400 Bad Request):**
```json
{
  "product_variant": ["This field is required."]
}
```

**Or:**
```json
{
  "detail": "Product already in wishlist."
}
```

**Implementation:**
```dart
Future<WishlistItem> addToWishlist(String productId) async {
  try {
    final requestData = {
      'product_variant': int.tryParse(productId) ?? productId,
    };

    Logger.info('Adding to wishlist', data: {'product_id': productId});

    final response = await _apiClient.post(
      '/api/order/v1/wishlist/',
      data: requestData,
    );

    if (response.statusCode == 201 && response.data != null) {
      Logger.info('Added to wishlist successfully');

      // Fetch complete product details
      final productResponse = await _apiClient.get(
        '/api/products/v1/variants/$productId/',
      );

      return WishlistItem.fromProductVariantResponse(
        wishlistId: response.data['id'] as int,
        productData: productResponse.data,
      );
    }

    throw Exception('Failed to add to wishlist');
  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      final errorData = e.response?.data;
      String errorMessage = 'Bad request';

      if (errorData is Map) {
        if (errorData.containsKey('product_variant')) {
          errorMessage = errorData['product_variant'].first;
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        }
      }

      Logger.error('API error adding to wishlist', data: {
        'status': 400,
        'message': errorMessage,
      });

      throw Exception('API Error: $errorMessage');
    }

    Logger.error('Error adding to wishlist', error: e);
    throw Exception('Error adding to wishlist: ${e.message}');
  } catch (e) {
    Logger.error('Unexpected error adding to wishlist', error: e);
    rethrow;
  }
}
```

---

### 3. Remove from Wishlist

**Endpoint:** `DELETE /api/order/v1/wishlist/{wishlistItemId}/`

**Purpose:** Remove item from wishlist

**Request:**
```http
DELETE /api/order/v1/wishlist/1/
Cookie: sessionid=xyz123
X-CSRFToken: abc456
```

**Response:**
```http
HTTP/1.1 204 No Content
```

**Or:**
```http
HTTP/1.1 200 OK
```

**Implementation:**
```dart
Future<void> removeFromWishlist(String wishlistItemId) async {
  try {
    Logger.info('Removing from wishlist', data: {
      'wishlist_item_id': wishlistItemId,
    });

    final response = await _apiClient.delete(
      '/api/order/v1/wishlist/$wishlistItemId/',
    );

    // Accept both 204 and 200 as success
    if (response.statusCode == 204 || response.statusCode == 200) {
      Logger.info('Removed from wishlist successfully');
      return;
    }

    throw Exception('Failed to remove from wishlist');
  } catch (e) {
    Logger.error('Error removing from wishlist', error: e);
    rethrow;
  }
}
```

---

### 4. Fetch Product Details

**Endpoint:** `GET /api/products/v1/variants/{variantId}/`

**Purpose:** Get complete product information for wishlist item

**Request:**
```http
GET /api/products/v1/variants/42/
```

**Response:**
```json
{
  "id": 42,
  "sku": "APPLE-RED-1KG",
  "name": "Red Apple",
  "price": "299.00",
  "discounted_price": "249.00",
  "stock_unit": "1 kg",
  "current_quantity": 150,
  "media": [
    {
      "id": 1,
      "image": "https://cdn.example.com/products/apple.jpg",
      "alt": "Red Apple"
    }
  ]
}
```

**This endpoint is used to:**
- Enrich wishlist items with complete product data
- Get latest prices for display
- Fetch product images
- Get stock information

---

## Data Models

### Architecture Layers

```
API Response (JSON)
    ↓
WishlistItem (Domain Entity with Freezed)
    ↓
State (WishlistState)
    ↓
UI Layer
```

---

### 1. Domain Entity - WishlistItem

**File:** `domain/entities/wishlist_item.dart`

**Using Freezed for Immutability:**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item.freezed.dart';

@freezed
class WishlistItem with _$WishlistItem {
  const factory WishlistItem({
    required int id,              // Wishlist item ID (NOT product ID)
    required String productId,    // Product variant ID
    required String name,
    required double price,        // Display price (current/discounted)
    required double mrp,          // Original price
    required String imageUrl,
    required String unitLabel,    // e.g., "1 kg", "500 g"
    required int discountPct,     // Discount percentage
    DateTime? addedAt,
  }) = _WishlistItem;

  // Factory: Parse from API basic response
  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final productVariantId = json['product_variant']?.toString() ?? '';
    final imageUrl = json['image']?.toString() ?? '';
    final priceStr = json['price']?.toString() ?? '0';
    final mrpStr = json['mrp']?.toString() ?? priceStr;

    final price = double.tryParse(priceStr) ?? 0.0;
    final mrp = double.tryParse(mrpStr) ?? price;

    // Calculate discount percentage
    final discountPct = mrp > 0 && price < mrp
        ? ((1 - price / mrp) * 100).round()
        : 0;

    return WishlistItem(
      id: json['id'] as int,
      productId: productVariantId,
      name: json['name']?.toString() ?? 'Product',
      price: price,
      mrp: mrp,
      imageUrl: _validateImageUrl(imageUrl),
      unitLabel: json['unit_label']?.toString() ?? '',
      discountPct: discountPct,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : null,
    );
  }

  // Factory: Create from ProductVariant entity
  factory WishlistItem.fromProductVariant({
    required int id,
    required ProductVariant productVariant,
  }) {
    final hasDiscount = productVariant.discountedPrice != null &&
        productVariant.discountedPrice! < productVariant.price;

    final displayPrice = hasDiscount
        ? productVariant.discountedPrice!
        : productVariant.price;

    final mrp = productVariant.price;

    final discountPct = hasDiscount
        ? ((1 - displayPrice / mrp) * 100).round()
        : 0;

    // Extract first image from media
    String imageUrl = '';
    if (productVariant.media != null && productVariant.media!.isNotEmpty) {
      imageUrl = productVariant.media!.first.image ?? '';
    }

    // Get stock unit
    final unitLabel = productVariant.stockUnit ?? '';

    return WishlistItem(
      id: id,
      productId: productVariant.id.toString(),
      name: productVariant.name,
      price: displayPrice,
      mrp: mrp,
      imageUrl: imageUrl,
      unitLabel: unitLabel,
      discountPct: discountPct,
      addedAt: DateTime.now(),
    );
  }

  // Factory: Create from complete product API response
  factory WishlistItem.fromProductVariantResponse({
    required int wishlistId,
    required Map<String, dynamic> productData,
  }) {
    final productId = productData['id']?.toString() ?? '';
    final name = productData['name']?.toString() ?? 'Product';

    final priceStr = productData['price']?.toString() ?? '0';
    final discountedPriceStr = productData['discounted_price']?.toString();

    final mrp = double.tryParse(priceStr) ?? 0.0;
    final discountedPrice = discountedPriceStr != null
        ? double.tryParse(discountedPriceStr)
        : null;

    final displayPrice = discountedPrice ?? mrp;

    final discountPct = mrp > 0 && displayPrice < mrp
        ? ((1 - displayPrice / mrp) * 100).round()
        : 0;

    // Extract image from media array
    String imageUrl = '';
    if (productData['media'] != null && productData['media'] is List) {
      final mediaList = productData['media'] as List;
      if (mediaList.isNotEmpty) {
        final firstMedia = mediaList.first;
        if (firstMedia is Map && firstMedia['image'] != null) {
          imageUrl = firstMedia['image'].toString();
        }
      }
    }

    // Process URL (add https:// if needed)
    imageUrl = _processImageUrl(imageUrl);

    final unitLabel = productData['stock_unit']?.toString() ?? '';

    return WishlistItem(
      id: wishlistId,
      productId: productId,
      name: name,
      price: displayPrice,
      mrp: mrp,
      imageUrl: imageUrl,
      unitLabel: unitLabel,
      discountPct: discountPct,
      addedAt: DateTime.now(),
    );
  }

  // Helper: Validate image URL
  static String _validateImageUrl(String url) {
    if (url.isEmpty || url == 'string' || url == 'null') {
      return '';
    }
    return url;
  }

  // Helper: Process image URL
  static String _processImageUrl(String url) {
    if (url.isEmpty) return '';

    // If relative path, add base URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://grocery-application.b-cdn.net$url';
    }

    // If http, upgrade to https
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }

    return url;
  }
}
```

---

### Extension Methods

```dart
extension WishlistItemX on WishlistItem {
  // Check if item has discount
  bool get hasDiscount => discountPct > 0;

  // Get display price
  double get displayPrice => hasDiscount ? price : mrp;

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price': price,
      'mrp': mrp,
      'image_url': imageUrl,
      'unit_label': unitLabel,
      'discount_pct': discountPct,
      if (addedAt != null) 'added_at': addedAt!.toIso8601String(),
    };
  }

  // Convert to ProductVariant for cart integration
  ProductVariant toProductVariant() {
    return ProductVariant(
      id: int.tryParse(productId) ?? 0,
      name: name,
      price: mrp,
      discountedPrice: hasDiscount ? price : null,
      stockUnit: unitLabel,
      media: imageUrl.isNotEmpty
          ? [
              ProductMedia(
                image: imageUrl,
                alt: name,
              )
            ]
          : null,
      // ... other required fields with defaults
    );
  }
}
```

---

## Repository Pattern

### Abstract Interface

**File:** `domain/repositories/wishlist_repository.dart`

```dart
import 'package:fpdart/fpdart.dart';

abstract class WishlistRepository {
  /// Fetch all wishlist items
  Future<Either<Failure, List<WishlistItem>>> getWishlist();

  /// Add product to wishlist
  Future<Either<Failure, WishlistItem>> addToWishlist(String productId);

  /// Remove item from wishlist by wishlist item ID
  Future<Either<Failure, void>> removeFromWishlist(String wishlistItemId);

  /// Remove item from wishlist by product ID
  Future<Either<Failure, void>> removeFromWishlistByProductId(String productId);

  /// Check if product is in wishlist
  Future<Either<Failure, bool>> isInWishlist(String productId);

  /// Clear local cache
  Future<void> clearCache();
}
```

**Why Either<Failure, T>?**

```dart
// Traditional error handling (exceptions)
try {
  final items = await getWishlist();
  return items;
} catch (e) {
  print('Error: $e');
  return [];
}

// Functional error handling (Either)
final result = await getWishlist();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (items) => print('Success: ${items.length} items'),
);
```

**Benefits:**
- ✅ Explicit error handling
- ✅ Type-safe errors
- ✅ Composable
- ✅ No uncaught exceptions

---

### Implementation

**File:** `infrastructure/repositories/wishlist_repository_impl.dart`

```dart
class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;
  final WishlistLocalDataSource _localDataSource;

  WishlistRepositoryImpl({
    required WishlistRemoteDataSource remoteDataSource,
    required WishlistLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<WishlistItem>>> getWishlist() async {
    try {
      // 1. Try local cache (5-minute TTL)
      final cachedContainer = await _localDataSource.getWishlist();

      if (cachedContainer?.isFresh(const Duration(minutes: 5)) ?? false) {
        Logger.info('Returning cached wishlist', data: {
          'items_count': cachedContainer!.data.length,
          'cached_at': cachedContainer.cachedAt.toIso8601String(),
        });

        return Right(cachedContainer.data);
      }

      // 2. Fetch from API
      Logger.info('Fetching wishlist from API');

      final items = await _remoteDataSource.getWishlist();

      // 3. Save to cache
      await _localDataSource.saveWishlist(items);

      return Right(items);
    } catch (e) {
      Logger.error('Failed to fetch wishlist', error: e);

      // 4. Fallback to stale cache on network error
      final cachedContainer = await _localDataSource.getWishlist();

      if (cachedContainer != null) {
        Logger.info('Returning stale cached wishlist', data: {
          'items_count': cachedContainer.data.length,
          'age_minutes': DateTime.now()
              .difference(cachedContainer.cachedAt)
              .inMinutes,
        });

        return Right(cachedContainer.data);
      }

      // 5. No cache available - return error
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, WishlistItem>> addToWishlist(String productId) async {
    try {
      Logger.info('Adding to wishlist', data: {'product_id': productId});

      final item = await _remoteDataSource.addToWishlist(productId);

      // Invalidate cache (will refresh on next fetch)
      await _localDataSource.clearCache();

      return Right(item);
    } catch (e) {
      Logger.error('Failed to add to wishlist', error: e);
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(
    String wishlistItemId,
  ) async {
    try {
      Logger.info('Removing from wishlist', data: {
        'wishlist_item_id': wishlistItemId,
      });

      await _remoteDataSource.removeFromWishlist(wishlistItemId);

      // Invalidate cache
      await _localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      Logger.error('Failed to remove from wishlist', error: e);
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlistByProductId(
    String productId,
  ) async {
    try {
      // Get current wishlist to find item ID
      final result = await getWishlist();

      return result.fold(
        (failure) => Left(failure),
        (items) async {
          // Find item with matching product ID
          final item = items.firstWhereOrNull(
            (item) => item.productId == productId,
          );

          if (item == null) {
            return Left(const AppFailure('Item not found in wishlist'));
          }

          // Remove by wishlist item ID
          return removeFromWishlist(item.id.toString());
        },
      );
    } catch (e) {
      Logger.error('Failed to remove from wishlist by product ID', error: e);
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(String productId) async {
    try {
      final result = await getWishlist();

      return result.fold(
        (failure) => const Right(false),
        (items) {
          final isInWishlist = items.any(
            (item) => item.productId == productId,
          );
          return Right(isInWishlist);
        },
      );
    } catch (e) {
      Logger.error('Failed to check if in wishlist', error: e);
      return const Right(false);
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  // Error mapping
  Failure _mapError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return const TimeoutFailure('Request timed out');
      }

      if (error.type == DioExceptionType.connectionError) {
        return const NetworkFailure('No internet connection');
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 500) {
          return ServerFailure('Server error: $statusCode');
        }
        if (statusCode == 401 || statusCode == 403) {
          return const NotAuthenticatedFailure('Authentication required');
        }
      }

      return ServerFailure(error.message ?? 'Unknown error');
    }

    if (error is FormatException) {
      return DataParsingFailure(error.message);
    }

    return AppFailure(error.toString());
  }
}
```

---

## Caching Strategy

### Implementation

**File:** `infrastructure/data_sources/wishlist_local_ds.dart`

```dart
class CachedWishlistData {
  final List<WishlistItem> data;
  final DateTime cachedAt;

  const CachedWishlistData({
    required this.data,
    required this.cachedAt,
  });

  // Check if cache is fresh
  bool isFresh(Duration maxAge) {
    final age = DateTime.now().difference(cachedAt);
    return age < maxAge;
  }

  // Get cache age
  Duration get age => DateTime.now().difference(cachedAt);
}

abstract class WishlistLocalDataSource {
  Future<CachedWishlistData?> getWishlist();
  Future<void> saveWishlist(List<WishlistItem> items);
  Future<void> clearCache();
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  CachedWishlistData? _cachedWishlist;

  @override
  Future<CachedWishlistData?> getWishlist() async {
    return _cachedWishlist;
  }

  @override
  Future<void> saveWishlist(List<WishlistItem> items) async {
    _cachedWishlist = CachedWishlistData(
      data: items,
      cachedAt: DateTime.now(),
    );

    Logger.debug('Wishlist cached', data: {
      'items_count': items.length,
      'cached_at': _cachedWishlist!.cachedAt.toIso8601String(),
    });
  }

  @override
  Future<void> clearCache() async {
    _cachedWishlist = null;
    Logger.debug('Wishlist cache cleared');
  }
}
```

### Cache Behavior

```
┌─────────────────────────────────────────────────┐
│ User Opens Wishlist Screen                     │
├─────────────────────────────────────────────────┤
│ 1. Check cache                                  │
│    ├─ Fresh (< 5 min): Return immediately      │
│    │   └─ No API call                           │
│    │                                            │
│    ├─ Stale (> 5 min): Fetch from API          │
│    │   ├─ Success: Update cache, return data   │
│    │   └─ Failure: Return stale cache          │
│    │                                            │
│    └─ No cache: Fetch from API                 │
│        ├─ Success: Cache & return              │
│        └─ Failure: Show error                  │
│                                                 │
│ 2. User adds/removes item                      │
│    ├─ API call                                  │
│    └─ Clear cache (will refresh on next fetch) │
└─────────────────────────────────────────────────┘
```

**Benefits:**
- ✅ Instant load for repeat visits
- ✅ Offline support (stale cache fallback)
- ✅ Reduced API calls
- ✅ Fresh data after mutations

---

## State Management

### State Definition

**File:** `application/states/wishlist_state.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_state.freezed.dart';

@freezed
sealed class WishlistState with _$WishlistState {
  const factory WishlistState.initial() = WishlistInitial;

  const factory WishlistState.loading() = WishlistLoading;

  const factory WishlistState.loaded({
    required List<WishlistItem> items,
    @Default(false) bool isRefreshing,
  }) = WishlistLoaded;

  const factory WishlistState.refreshing({
    required List<WishlistItem> items,
  }) = WishlistRefreshing;

  const factory WishlistState.error({
    required Failure failure,
    WishlistState? previousState,  // Keep old data visible
  }) = WishlistError;
}
```

**State Transitions:**
```
Initial
  ↓ (load)
Loading
  ↓ (success)
Loaded
  ↓ (pull-to-refresh)
Refreshing (data still visible)
  ↓ (success)
Loaded

Loaded
  ↓ (error)
Error (previousState = Loaded, data still visible)
```

---

### Extension Methods

```dart
extension WishlistStateX on WishlistState {
  /// Get items regardless of state
  List<WishlistItem> get items {
    return when(
      initial: () => [],
      loading: () => [],
      loaded: (items, _) => items,
      refreshing: (items) => items,
      error: (_, previousState) => previousState?.items ?? [],
    );
  }

  /// Check if has items
  bool get hasItems => items.isNotEmpty;

  /// Get item count
  int get itemCount => items.length;

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Get wishlist item by product ID
  WishlistItem? getWishlistItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }
}
```

---

### Notifier

**File:** `application/providers/wishlist_provider.dart`

```dart
class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistRepository _repository;
  final Ref _ref;

  WishlistNotifier({
    required WishlistRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(const WishlistState.initial()) {

    // Listen to auth state changes
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is Authenticated && previous is! Authenticated) {
        // User logged in - load wishlist
        Logger.info('User authenticated, loading wishlist');
        _loadWishlist();
      } else if (next is GuestMode && previous is Authenticated) {
        // User logged out - clear wishlist
        Logger.info('User logged out, clearing wishlist');
        state = const WishlistState.initial();
      }
    });

    // Auto-load if already authenticated
    final currentAuthState = _ref.read(authProvider);
    if (currentAuthState is Authenticated) {
      Future.microtask(_loadWishlist);
    }
  }

  // Load wishlist from repository
  Future<void> _loadWishlist() async {
    // Don't overwrite refreshing state with loading
    state.maybeMap(
      refreshing: (_) {},
      orElse: () => state = const WishlistState.loading(),
    );

    final result = await _repository.getWishlist();

    result.fold(
      (failure) {
        Logger.error('Failed to load wishlist', data: {
          'failure': failure.toString(),
        });

        state = WishlistState.error(
          failure: failure,
          previousState: state,
        );
      },
      (items) {
        Logger.info('Wishlist loaded', data: {
          'items_count': items.length,
        });

        state = WishlistState.loaded(items: items);
      },
    );
  }

  // Refresh (pull-to-refresh)
  Future<void> refresh() async {
    state.mapOrNull(
      loaded: (loadedState) {
        state = WishlistState.refreshing(items: loadedState.items);
        _loadWishlist();
      },
      error: (_) => _loadWishlist(),
    );
  }

  // Add to wishlist
  Future<bool> addToWishlist(String productId) async {
    // Prevent duplicates
    if (isInWishlist(productId)) {
      Logger.debug('Product already in wishlist', data: {
        'product_id': productId,
      });
      return false;
    }

    final result = await _repository.addToWishlist(productId);

    return result.fold(
      (failure) {
        Logger.error('Failed to add to wishlist', data: {
          'product_id': productId,
          'failure': failure.toString(),
        });

        state.mapOrNull(
          loaded: (loadedState) {
            state = WishlistState.error(
              failure: failure,
              previousState: loadedState,
            );
          },
        );

        return false;
      },
      (item) {
        Logger.info('Added to wishlist', data: {
          'product_id': productId,
          'item_id': item.id,
        });

        // Reload wishlist for consistency
        _loadWishlist();

        return true;
      },
    );
  }

  // Remove from wishlist (by wishlist item ID)
  Future<bool> removeFromWishlist(String wishlistItemId) async {
    final result = await _repository.removeFromWishlist(wishlistItemId);

    return result.fold(
      (failure) {
        Logger.error('Failed to remove from wishlist', data: {
          'wishlist_item_id': wishlistItemId,
          'failure': failure.toString(),
        });

        state.mapOrNull(
          loaded: (loadedState) {
            state = WishlistState.error(
              failure: failure,
              previousState: loadedState,
            );
          },
        );

        return false;
      },
      (_) {
        Logger.info('Removed from wishlist', data: {
          'wishlist_item_id': wishlistItemId,
        });

        _loadWishlist();

        return true;
      },
    );
  }

  // Remove by product ID (user-friendly)
  Future<bool> removeFromWishlistByProductId(String productId) async {
    final result = await _repository.removeFromWishlistByProductId(productId);

    return result.fold(
      (failure) {
        Logger.error('Failed to remove from wishlist by product ID', data: {
          'product_id': productId,
          'failure': failure.toString(),
        });

        return false;
      },
      (_) {
        Logger.info('Removed from wishlist by product ID', data: {
          'product_id': productId,
        });

        _loadWishlist();

        return true;
      },
    );
  }

  // Toggle wishlist (add if not present, remove if present)
  Future<bool> toggleWishlist(String productId) async {
    return isInWishlist(productId)
        ? removeFromWishlistByProductId(productId)
        : addToWishlist(productId);
  }

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return state.isInWishlist(productId);
  }

  // Clear error
  void clearError() {
    state.mapOrNull(
      error: (errorState) {
        if (errorState.previousState != null) {
          state = errorState.previousState!;
        } else {
          state = const WishlistState.initial();
        }
      },
    );
  }
}

// Provider
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return WishlistNotifier(repository: repository, ref: ref);
});
```

---

### Helper Providers

```dart
// Watch only items (optimization)
final wishlistItemsProvider =
    Provider.autoDispose<List<WishlistItem>>((ref) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.items;
});

// Check if specific product is in wishlist
final isInWishlistProvider =
    Provider.autoDispose.family<bool, String>((ref, productId) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.isInWishlist(productId);
});

// Get wishlist count
final wishlistCountProvider = Provider.autoDispose<int>((ref) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.itemCount;
});
```

**Usage:**
```dart
// Watch only count (efficient - doesn't rebuild on item changes)
final count = ref.watch(wishlistCountProvider);
Text('$count items');

// Check if product in wishlist
final isInWishlist = ref.watch(isInWishlistProvider(productId));
Icon(isInWishlist ? Icons.favorite : Icons.favorite_border);

// Get all items
final items = ref.watch(wishlistItemsProvider);
```

---

## Wishlist Operations

### Add to Wishlist

```dart
// In UI
Future<void> _handleAddToWishlist(String productId) async {
  final success = await ref
      .read(wishlistProvider.notifier)
      .addToWishlist(productId);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to wishlist')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to add to wishlist')),
    );
  }
}
```

### Remove from Wishlist

```dart
// By product ID (user-friendly)
Future<void> _handleRemove(String productId) async {
  final success = await ref
      .read(wishlistProvider.notifier)
      .removeFromWishlistByProductId(productId);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from wishlist')),
    );
  }
}
```

### Toggle Wishlist

```dart
// In product details or catalog
Future<void> _handleWishlistToggle(String productId) async {
  final success = await ref
      .read(wishlistProvider.notifier)
      .toggleWishlist(productId);

  if (success) {
    final isInWishlist = ref.read(isInWishlistProvider(productId));
    final message = isInWishlist
        ? 'Added to wishlist'
        : 'Removed from wishlist';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

---

## Real-Time Socket Integration

### Socket Service

**File:** `core/network/socket_service.dart`

```dart
class SocketService {
  late Socket _socket;
  bool _isConnected = false;

  void connect(String url) {
    _socket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.on('connect', (_) {
      _isConnected = true;
      Logger.info('Socket connected');
    });

    _socket.on('disconnect', (_) {
      _isConnected = false;
      Logger.info('Socket disconnected');
    });

    _socket.on('price_update', (data) {
      Logger.info('Price update received', data: data);
      // Handle price update
    });

    _socket.on('inventory_update', (data) {
      Logger.info('Inventory update received', data: data);
      // Handle inventory update
    });
  }

  // Join product room for real-time updates
  void joinVariantRoom(int variantId) {
    if (!_isConnected) return;

    _socket.emit('join_product_room', {'variant_id': variantId});

    Logger.info('Joined variant room', data: {
      'variant_id': variantId,
    });
  }

  // Leave product room
  void leaveVariantRoom(int variantId) {
    if (!_isConnected) return;

    _socket.emit('leave_product_room', {'variant_id': variantId});

    Logger.info('Left variant room', data: {
      'variant_id': variantId,
    });
  }

  void dispose() {
    _socket.dispose();
  }
}
```

---

### Integration in Wishlist Screen

```dart
class WishlistScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final Set<int> _joinedRooms = {};

  @override
  void initState() {
    super.initState();

    // Join socket rooms after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _joinWishlistItemRooms();
      }
    });
  }

  /// Join socket rooms for all wishlist items
  void _joinWishlistItemRooms() {
    final wishlistState = ref.read(wishlistProvider);
    final socketService = ref.read(socketServiceProvider);

    wishlistState.maybeWhen(
      loaded: (items, _) {
        for (final item in items) {
          final variantId = int.tryParse(item.productId) ?? 0;

          if (variantId > 0 && !_joinedRooms.contains(variantId)) {
            socketService.joinVariantRoom(variantId);
            _joinedRooms.add(variantId);
          }
        }

        Logger.info('Joined wishlist rooms', data: {
          'room_count': _joinedRooms.length,
        });
      },
      orElse: () {},
    );
  }

  @override
  void dispose() {
    _leaveAllRooms();
    super.dispose();
  }

  void _leaveAllRooms() {
    final socketService = ref.read(socketServiceProvider);

    for (final variantId in _joinedRooms) {
      socketService.leaveVariantRoom(variantId);
    }

    _joinedRooms.clear();

    Logger.info('Left all wishlist rooms');
  }

  @override
  Widget build(BuildContext context) {
    // Listen for wishlist changes to join new rooms
    ref.listen<WishlistState>(wishlistProvider, (previous, next) {
      next.maybeWhen(
        loaded: (items, _) {
          // Join rooms for any new items
          _joinWishlistItemRooms();
        },
        orElse: () {},
      );
    });

    return Scaffold(
      // ... UI implementation
    );
  }
}
```

**Socket Events:**
```
join_product_room:
  Emit: {'variant_id': 42}
  Purpose: Subscribe to price/inventory updates

leave_product_room:
  Emit: {'variant_id': 42}
  Purpose: Unsubscribe

price_update:
  Receive: {'variant_id': 42, 'new_price': 249.00}
  Action: Update price in UI

inventory_update:
  Receive: {'variant_id': 42, 'quantity': 10}
  Action: Update stock status
```

---

## Guest Mode Handling

### Auth State Integration

```dart
// In WishlistNotifier constructor
_ref.listen<AuthState>(authProvider, (previous, next) {
  if (next is Authenticated && previous is! Authenticated) {
    // User logged in - load wishlist
    Logger.info('User authenticated, loading wishlist');
    _loadWishlist();
  } else if (next is GuestMode && previous is Authenticated) {
    // User logged out - clear wishlist
    Logger.info('User logged out, clearing wishlist');
    state = const WishlistState.initial();
  }
});

// Auto-load if already authenticated
final currentAuthState = _ref.read(authProvider);
if (currentAuthState is Authenticated) {
  Future.microtask(_loadWishlist);
}
```

### Guest Mode Behavior

```
Guest User:
  - Wishlist state = Initial
  - No API calls made
  - Heart icons show empty
  - Tapping heart → Redirect to login

Authenticated User:
  - Wishlist loads automatically
  - Can add/remove items
  - Heart icons show filled for wishlist items
  - Tapping heart → Toggle wishlist
```

### Guest Mode Header

```dart
// In ApiClient (core/network/api_client.dart)
final isGuest = isGuestMode?.call() ?? false;

if (isGuest) {
  options.headers['dev'] = '2';  // Guest mode header
  // Skip CSRF token
} else {
  // Authenticated mode
  final csrf = await _getCsrfToken();
  if (csrf != null) {
    options.headers['X-CSRFToken'] = csrf;
  }
}
```

---

## Integration with Other Features

### Product Details Integration

```dart
// In ProductDetailsScreen
class ProductDetailsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productId = widget.variantId.toString();
    final isInWishlist = ref.watch(isInWishlistProvider(productId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : null,
            ),
            onPressed: () async {
              await ref
                  .read(wishlistProvider.notifier)
                  .toggleWishlist(productId);
            },
          ),
        ],
      ),
      // ... rest of UI
    );
  }
}
```

---

### Cart Integration

```dart
// Convert wishlist item to ProductVariant for cart
extension WishlistItemX on WishlistItem {
  ProductVariant toProductVariant() {
    return ProductVariant(
      id: int.tryParse(productId) ?? 0,
      name: name,
      price: mrp,
      discountedPrice: hasDiscount ? price : null,
      stockUnit: unitLabel,
      media: imageUrl.isNotEmpty
          ? [
              ProductMedia(
                image: imageUrl,
                alt: name,
              )
            ]
          : null,
      trackInventory: true,
      currentQuantity: 100,  // Default
      status: 'active',
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// In WishlistScreen - Add all to cart
Future<void> _handleAddAllToCart() async {
  final items = ref.read(wishlistItemsProvider);

  for (final item in items) {
    final product = item.toProductVariant();

    await ref.read(checkoutLineControllerProvider.notifier).addToCart(
          productVariantId: product.id,
          quantity: 1,
        );
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Added ${items.length} items to cart')),
  );
}
```

---

## Error Handling

### Failure Types

**File:** `core/error/failure.dart`

```dart
abstract class Failure {
  final String message;
  final String? technicalDetails;

  const Failure(this.message, [this.technicalDetails]);

  String get displayMessage => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
      : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'Request timed out'])
      : super(message);
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(String message, {this.statusCode})
      : super(message);
}

class DataParsingFailure extends Failure {
  const DataParsingFailure(String message) : super(message);
}

class NotAuthenticatedFailure extends Failure {
  const NotAuthenticatedFailure([
    String message = 'Authentication required',
  ]) : super(message);
}

class AppFailure extends Failure {
  const AppFailure(String message) : super(message);
}
```

---

### Error Mapping

```dart
// In Repository
Failure _mapError(Object error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const TimeoutFailure('Request timed out');
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkFailure('No internet connection');
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      if (statusCode >= 500) {
        return ServerFailure('Server error: $statusCode');
      }
      if (statusCode == 401 || statusCode == 403) {
        return const NotAuthenticatedFailure('Authentication required');
      }
    }

    return ServerFailure(error.message ?? 'Unknown error');
  }

  if (error is FormatException) {
    return DataParsingFailure(error.message);
  }

  return AppFailure(error.toString());
}
```

---

### UI Error Display

```dart
// In WishlistScreen
class _WishlistErrorView extends ConsumerWidget {
  final Failure failure;
  final WishlistState? previousState;

  const _WishlistErrorView({
    required this.failure,
    this.previousState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasData = previousState?.items.isNotEmpty ?? false;

    // If we have previous data, show it with error banner
    if (hasData) {
      return Column(
        children: [
          // Error banner
          Container(
            color: Colors.red.shade100,
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getUserFriendlyMessage(failure),
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(wishlistProvider.notifier).clearError();
                  },
                  child: Text('Dismiss'),
                ),
              ],
            ),
          ),

          // Show previous data
          Expanded(
            child: ListView.builder(
              itemCount: previousState!.items.length,
              itemBuilder: (context, index) {
                return WishlistItemCard(
                  item: previousState!.items[index],
                );
              },
            ),
          ),
        ],
      );
    }

    // No previous data - show full error screen
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _getUserFriendlyMessage(failure),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(wishlistProvider.notifier).refresh();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _getUserFriendlyMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network and try again.';
    } else if (failure is TimeoutFailure) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (failure is ServerFailure) {
      return 'Unable to connect to server. Please try again later.';
    } else if (failure is DataParsingFailure) {
      return 'Something went wrong. Please try again later.';
    } else if (failure is NotAuthenticatedFailure) {
      return 'Please log in to view your wishlist.';
    }
    return failure.displayMessage;
  }
}
```

---

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                     │
│           (Flutter UI - Framework)                  │
├─────────────────────────────────────────────────────┤
│ - WishlistScreen (displays items)                  │
│ - WishlistItemCard (item widget)                   │
│ - Pull-to-refresh                                   │
│ - Empty state                                       │
│ - Error handling                                    │
│ - Socket room management                            │
└───────────────────┬─────────────────────────────────┘
                    │ (watches)
                    ▼
┌─────────────────────────────────────────────────────┐
│         APPLICATION LAYER (Business Logic)          │
│              (Framework-Agnostic)                   │
├─────────────────────────────────────────────────────┤
│ WishlistNotifier (StateNotifier)                   │
│ ├─ State management                                │
│ ├─ Add/Remove/Toggle operations                    │
│ ├─ Auth state listener                             │
│ └─ Error handling                                  │
│                                                     │
│ WishlistState (Freezed Union)                      │
│ ├─ initial                                         │
│ ├─ loading                                         │
│ ├─ loaded (items, isRefreshing)                    │
│ ├─ refreshing (items)                              │
│ └─ error (failure, previousState)                  │
│                                                     │
│ Helper Providers:                                  │
│ ├─ wishlistItemsProvider                           │
│ ├─ isInWishlistProvider (family)                   │
│ └─ wishlistCountProvider                           │
└───────────────────┬─────────────────────────────────┘
                    │ (calls)
                    ▼
┌─────────────────────────────────────────────────────┐
│          DOMAIN LAYER (Pure Business)               │
│              (Framework-Agnostic)                   │
├─────────────────────────────────────────────────────┤
│ WishlistRepository (interface)                     │
│ ├─ getWishlist() → Either<Failure, List>           │
│ ├─ addToWishlist() → Either<Failure, Item>         │
│ ├─ removeFromWishlist() → Either<Failure, void>    │
│ ├─ isInWishlist() → Either<Failure, bool>          │
│ └─ clearCache() → void                             │
│                                                     │
│ WishlistItem (Freezed Entity)                      │
│ ├─ id, productId, name, price, mrp                 │
│ ├─ imageUrl, unitLabel, discountPct                │
│ ├─ fromJson() factory                              │
│ ├─ fromProductVariant() factory                    │
│ ├─ fromProductVariantResponse() factory            │
│ └─ toProductVariant() conversion                   │
└───────────────────┬─────────────────────────────────┘
                    │ (implements)
                    ▼
┌─────────────────────────────────────────────────────┐
│       INFRASTRUCTURE LAYER (Data Access)            │
│          (Framework-Dependent)                      │
├─────────────────────────────────────────────────────┤
│ WishlistRepositoryImpl                             │
│ ├─ Cache-first fetch (5-min TTL)                   │
│ ├─ Stale cache fallback on errors                  │
│ ├─ Error mapping (Dio → Failure)                   │
│ └─ Functional error handling (Either)              │
│                                                     │
│ Data Sources:                                      │
│ ├─ WishlistRemoteDataSource (API)                  │
│ │  ├─ HTTP client (Dio)                            │
│ │  ├─ GET /wishlist/                               │
│ │  ├─ POST /wishlist/                              │
│ │  ├─ DELETE /wishlist/{id}/                       │
│ │  └─ GET /variants/{id}/ (product details)        │
│ │                                                  │
│ └─ WishlistLocalDataSource (Cache)                 │
│    ├─ In-memory cache                              │
│    ├─ CachedWishlistData with TTL                  │
│    └─ isFresh() validation                         │
└──────────────┬──────────────────┬───────────────────┘
               │                  │
               ▼                  ▼
    ┌─────────────────┐  ┌─────────────────┐
    │   Remote API    │  │  Local Cache    │
    │   (HTTP/REST)   │  │  (In-Memory)    │
    ├─────────────────┤  ├─────────────────┤
    │ POST /wishlist/ │  │ 5-minute TTL    │
    │ DELETE /id/     │  │ Stale fallback  │
    │ GET /variants/  │  │ Clear on mutate │
    └─────────────────┘  └─────────────────┘
```

---

## Replication Guide

### Step 1: Project Setup

```
lib/features/wishlist/
├── domain/
│   ├── entities/
│   │   └── wishlist_item.dart         (Freezed entity)
│   └── repositories/
│       └── wishlist_repository.dart   (Abstract interface)
├── infrastructure/
│   ├── data_sources/
│   │   ├── wishlist_api.dart          (Remote API)
│   │   └── wishlist_local_ds.dart     (Local cache)
│   └── repositories/
│       └── wishlist_repository_impl.dart (Implementation)
├── application/
│   ├── providers/
│   │   └── wishlist_provider.dart     (Notifier + providers)
│   └── states/
│       └── wishlist_state.dart        (Freezed state)
└── presentation/
    ├── screen/
    │   └── wishlist_screen.dart
    └── widgets/
        └── wishlist_item_card.dart
```

---

### Step 2: Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  freezed_annotation: ^2.4.1
  fpdart: ^1.1.0
  dio: ^5.3.3
  socket_io_client: ^2.0.3

dev_dependencies:
  freezed: ^2.4.5
  build_runner: ^2.4.6
```

---

### Step 3: Create Entity with Freezed

```dart
// domain/entities/wishlist_item.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item.freezed.dart';

@freezed
class WishlistItem with _$WishlistItem {
  const factory WishlistItem({
    required int id,
    required String productId,
    required String name,
    required double price,
    required double mrp,
    required String imageUrl,
    required String unitLabel,
    required int discountPct,
    DateTime? addedAt,
  }) = _WishlistItem;

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    // Implementation from Data Models section
  }
}

// Generate code
// flutter pub run build_runner build
```

---

### Step 4: Create State with Freezed

```dart
// application/states/wishlist_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_state.freezed.dart';

@freezed
sealed class WishlistState with _$WishlistState {
  const factory WishlistState.initial() = WishlistInitial;
  const factory WishlistState.loading() = WishlistLoading;
  const factory WishlistState.loaded({
    required List<WishlistItem> items,
    @Default(false) bool isRefreshing,
  }) = WishlistLoaded;
  const factory WishlistState.refreshing({
    required List<WishlistItem> items,
  }) = WishlistRefreshing;
  const factory WishlistState.error({
    required Failure failure,
    WishlistState? previousState,
  }) = WishlistError;
}
```

---

### Step 5: Implement Repository

```dart
// infrastructure/repositories/wishlist_repository_impl.dart

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;
  final WishlistLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<WishlistItem>>> getWishlist() async {
    try {
      // Try cache first (5-min TTL)
      final cached = await _localDataSource.getWishlist();
      if (cached?.isFresh(Duration(minutes: 5)) ?? false) {
        return Right(cached!.data);
      }

      // Fetch from API
      final items = await _remoteDataSource.getWishlist();
      await _localDataSource.saveWishlist(items);
      return Right(items);
    } catch (e) {
      // Fallback to stale cache
      final cached = await _localDataSource.getWishlist();
      if (cached != null) {
        return Right(cached.data);
      }
      return Left(_mapError(e));
    }
  }

  // ... other methods
}
```

---

### Step 6: Create Notifier

```dart
// application/providers/wishlist_provider.dart

class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistRepository _repository;
  final Ref _ref;

  WishlistNotifier({
    required WishlistRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(const WishlistState.initial()) {
    // Listen to auth changes
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is Authenticated && previous is! Authenticated) {
        _loadWishlist();
      } else if (next is GuestMode && previous is Authenticated) {
        state = const WishlistState.initial();
      }
    });

    // Auto-load if authenticated
    final authState = _ref.read(authProvider);
    if (authState is Authenticated) {
      Future.microtask(_loadWishlist);
    }
  }

  // ... methods from State Management section
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return WishlistNotifier(repository: repository, ref: ref);
});
```

---

### Step 7: Integrate Socket.IO

```dart
// In WishlistScreen
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _joinWishlistItemRooms();
    }
  });
}

void _joinWishlistItemRooms() {
  final items = ref.read(wishlistProvider).items;
  final socketService = ref.read(socketServiceProvider);

  for (final item in items) {
    final variantId = int.tryParse(item.productId) ?? 0;
    if (variantId > 0) {
      socketService.joinVariantRoom(variantId);
    }
  }
}

@override
void dispose() {
  _leaveAllRooms();
  super.dispose();
}
```

---

## Summary & Key Takeaways

### Production Features

1. ✅ **Functional Error Handling** - Either<Failure, T> pattern
2. ✅ **TTL-Based Caching** - 5-minute cache with stale fallback
3. ✅ **State Preservation** - Keep data visible on errors
4. ✅ **Real-Time Updates** - Socket.IO price/inventory sync
5. ✅ **Guest Mode Support** - Auth state integration
6. ✅ **Duplicate Prevention** - Check before adding
7. ✅ **Type Safety** - Freezed for immutability
8. ✅ **Clean Architecture** - Domain-driven design

---

### Implementation Checklist

- [ ] Create Freezed entities (WishlistItem)
- [ ] Create Freezed states (WishlistState)
- [ ] Implement repository interface
- [ ] Implement remote data source
- [ ] Implement local cache (in-memory)
- [ ] Create repository implementation with Either
- [ ] Create notifier with auth listener
- [ ] Add helper providers
- [ ] Integrate Socket.IO
- [ ] Handle guest mode
- [ ] Implement error UI
- [ ] Write unit tests
- [ ] Write widget tests

---

**Last Updated:** 2026-01-18
**Version:** 1.0
**Backend API:** Django REST at `http://156.67.104.149:8080`

# Product Details Feature - Backend Implementation Guide

> **Purpose:** Complete backend implementation documentation for the Product Details feature. This guide enables replication of HTTP 304 caching, real-time polling, and dual-API merge strategies in other projects with different UI frameworks.

---

## Table of Contents

1. [Overview](#overview)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [HTTP 304 Caching Strategy](#http-304-caching-strategy)
5. [Repository Pattern](#repository-pattern)
6. [State Management](#state-management)
7. [Real-Time Polling](#real-time-polling)
8. [Wishlist Integration](#wishlist-integration)
9. [Cart Integration](#cart-integration)
10. [Rating & Review System](#rating--review-system)
11. [Error Handling](#error-handling)
12. [Architecture Overview](#architecture-overview)
13. [Replication Guide](#replication-guide)

---

## Overview

The Product Details feature implements a **highly optimized real-time product information system** with:

- ✅ **HTTP 304 Caching** - Bandwidth-efficient conditional requests
- ✅ **Metadata-Only Storage** - Store headers, not data (100 bytes vs 50KB)
- ✅ **Real-Time Polling** - 30-second updates with 304 optimization
- ✅ **Dual-API Merge** - Combine variant + product data
- ✅ **Per-Product State** - Family provider pattern
- ✅ **Auto-Cleanup** - Dispose timers on navigation away
- ✅ **Guest Mode Support** - Limited functionality without auth
- ✅ **Stock Tracking** - Real-time inventory updates

**Tech Stack:**
- HTTP Client: Dio
- Local Storage: Hive (metadata only)
- State Management: Riverpod (AutoDisposeFamily)
- Architecture: Clean Architecture with Repository Pattern

---

## API Endpoints

### Base URL
```
http://156.67.104.149:8080
```

### Endpoint Summary

| Method | Endpoint | Description | Cache Support | Auth Required |
|--------|----------|-------------|---------------|---------------|
| GET | `/api/products/v1/variants/{variantId}/` | Fetch product variant details | ✅ Yes (ETag, If-Modified-Since) | ❌ |
| GET | `/api/products/v1/{productId}/` | Fetch product base data | ❌ No (always fresh) | ❌ |
| GET | `/api/products/v1/{productId}/reviews/` | Fetch product reviews | ❌ No | ❌ |
| GET | `/api/order/v1/wishlist/check/{productId}/` | Check wishlist status | ❌ No | ✅ |
| POST | `/api/order/v1/wishlist/` | Add to wishlist | - | ✅ |
| DELETE | `/api/order/v1/wishlist/{wishlistId}/` | Remove from wishlist | - | ✅ |
| POST | `/api/order/v1/checkout-lines/` | Add to cart | - | ✅ |

---

### 1. Fetch Product Variant Details

**Endpoint:** `GET /api/products/v1/variants/{variantId}/`

**Purpose:** Fetch variant-specific data (price, stock, weight, SKU)

**Supports HTTP 304:** ✅ Yes

**Headers (Request):**
```http
GET /api/products/v1/variants/42/
If-Modified-Since: Wed, 17 Jan 2024 10:00:00 GMT
If-None-Match: "abc123def456"
```

**Headers (Response - 304 Not Modified):**
```http
HTTP/1.1 304 Not Modified
ETag: "abc123def456"
Last-Modified: Wed, 17 Jan 2024 10:00:00 GMT
```
> **No body** returned when data hasn't changed

**Headers (Response - 200 OK):**
```http
HTTP/1.1 200 OK
Content-Type: application/json
ETag: "xyz789uvw012"
Last-Modified: Thu, 18 Jan 2024 14:30:00 GMT
```

**Response Body (200 OK):**
```json
{
  "id": 42,
  "sku": "APPLE-RED-1KG",
  "name": "Red Apple",
  "price": "299.00",
  "discounted_price": "249.00",
  "product_id": 10,
  "track_inventory": true,
  "current_quantity": 150,
  "quantity_limit_per_customer": 10,
  "preorder_end_date": null,
  "weight": "1.00",
  "status": "active",
  "tags": ["fresh", "organic"],
  "bar_code": "8901234567890",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-18T14:30:00Z",
  "images": [
    {
      "id": 1,
      "image": "/media/products/apple.jpg",
      "alt": "Red Apple"
    }
  ]
}
```

**Implementation:**
```dart
Future<ProductDetailRemoteResponse?> fetchProductDetail({
  required String productId,
  String? ifNoneMatch,      // ETag
  String? ifModifiedSince,  // Last-Modified
}) async {
  final headers = <String, String>{};

  if (ifNoneMatch != null) {
    headers['If-None-Match'] = ifNoneMatch;
  }
  if (ifModifiedSince != null) {
    headers['If-Modified-Since'] = ifModifiedSince;
  }

  final response = await _apiClient.get(
    '/api/products/v1/variants/$productId/',
    headers: headers.isNotEmpty ? headers : null,
  );

  // Handle 304 Not Modified
  if (response.statusCode == 304) {
    return null;  // No changes, UI won't refresh
  }

  // Parse new data and extract headers
  return ProductDetailRemoteResponse(
    productDetail: ProductVariantDto.fromJson(response.data),
    eTag: response.headers.value('etag'),
    lastModified: response.headers.value('last-modified'),
    fetchedAt: DateTime.now(),
  );
}
```

---

### 2. Fetch Product Base Data

**Endpoint:** `GET /api/products/v1/{productId}/`

**Purpose:** Fetch product-level data (description, rating, media)

**Supports HTTP 304:** ❌ No (API limitation - always returns 200 OK)

**Request:**
```http
GET /api/products/v1/10/
```

**Response:**
```json
{
  "id": 10,
  "name": "Apple",
  "description": "Fresh red apples from local farms. Rich in vitamins and antioxidants.",
  "rating": 4.5,
  "review_count": 120,
  "category": {
    "id": 1,
    "name": "Fruits"
  },
  "media": [
    {
      "id": 1,
      "file_path": "/media/products/apple-detail.jpg",
      "image": "/media/products/apple-detail.jpg",
      "alt": "Apple detail image",
      "external_url": null,
      "product_id": 10,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-18T14:30:00Z"
    }
  ]
}
```

**Implementation:**
```dart
Future<ProductBaseRemoteResponse> fetchProductBase({
  required String productId,
}) async {
  final response = await _apiClient.get(
    '/api/products/v1/$productId/',
  );

  return ProductBaseRemoteResponse(
    productBase: ProductBaseDto.fromJson(response.data),
    fetchedAt: DateTime.now(),
  );
}
```

**Note:** This endpoint does NOT support If-Modified-Since. Backend always returns 200 OK with full response. This is an API limitation.

---

### 3. Fetch Product Reviews

**Endpoint:** `GET /api/products/v1/{productId}/reviews/`

**Request:**
```http
GET /api/products/v1/10/reviews/
```

**Response:**
```json
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "user_name": "John Doe",
      "rating": 5,
      "comment": "Excellent quality! Very fresh.",
      "created_at": "2024-01-15T10:00:00Z",
      "user_image": "/media/users/john.jpg",
      "helpful_count": 12
    },
    {
      "id": 2,
      "user_name": "Jane Smith",
      "rating": 4,
      "comment": "Good but a bit pricey.",
      "created_at": "2024-01-14T15:30:00Z",
      "user_image": null,
      "helpful_count": 8
    }
  ]
}
```

---

### 4. Wishlist Operations

#### Check Wishlist Status

**Endpoint:** `GET /api/order/v1/wishlist/check/{productId}/`

**Auth:** Required (session cookie)

**Request:**
```http
GET /api/order/v1/wishlist/check/10/
Cookie: sessionid=xyz123
X-CSRFToken: abc456
```

**Response:**
```json
{
  "in_wishlist": true,
  "wishlist_id": 5
}
```

#### Add to Wishlist

**Endpoint:** `POST /api/order/v1/wishlist/`

**Request:**
```http
POST /api/order/v1/wishlist/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "product_id": 10
}
```

**Response:**
```json
{
  "id": 5,
  "product_id": 10,
  "created_at": "2024-01-18T15:00:00Z"
}
```

#### Remove from Wishlist

**Endpoint:** `DELETE /api/order/v1/wishlist/{wishlistId}/`

**Request:**
```http
DELETE /api/order/v1/wishlist/5/
Cookie: sessionid=xyz123
X-CSRFToken: abc456
```

**Response:**
```http
HTTP/1.1 204 No Content
```

---

### 5. Add to Cart

**Endpoint:** `POST /api/order/v1/checkout-lines/`

**Request:**
```http
POST /api/order/v1/checkout-lines/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "product_variant_id": 42,
  "quantity": 2
}
```

**Response:**
```json
{
  "id": 10,
  "product_variant_id": 42,
  "quantity": 2,
  "checkout_id": 3,
  "created_at": "2024-01-18T15:30:00Z"
}
```

---

## Data Models

### Architecture Overview

```
API Response (JSON)
    ↓
DTO (Data Transfer Object)
    ↓
Domain Entity
    ↓
UI Layer
```

---

### 1. Domain Entities

#### ProductVariant

**File:** `domain/entities/product_variant.dart`

**Purpose:** Complete product details for UI consumption

```dart
class ProductVariant extends Equatable {
  // Core identification
  final int id;
  final String sku;
  final String name;
  final int productId;

  // Pricing
  final double price;
  final double? discountedPrice;

  // Inventory
  final bool trackInventory;
  final int? currentQuantity;
  final int? quantityLimitPerCustomer;
  final DateTime? preorderEndDate;

  // Metadata
  final double? weight;
  final String status;
  final List<String> tags;
  final String? barCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Extended data (from Product API merge)
  final String? description;
  final double? rating;
  final int? reviewCount;
  final List<ProductVariantReview>? reviews;
  final List<ProductVariantMedia>? media;
  final List<ProductVariantImage>? images;

  const ProductVariant({
    required this.id,
    required this.sku,
    required this.name,
    required this.productId,
    required this.price,
    this.discountedPrice,
    required this.trackInventory,
    this.currentQuantity,
    this.quantityLimitPerCustomer,
    this.preorderEndDate,
    this.weight,
    required this.status,
    required this.tags,
    this.barCode,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.rating,
    this.reviewCount,
    this.reviews,
    this.media,
    this.images,
  });

  // Computed properties
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
  double get displayPrice => discountedPrice ?? price;
  int get discountPercent => hasDiscount
    ? ((1 - discountedPrice! / price) * 100).round()
    : 0;
  bool get inStock => !trackInventory || (currentQuantity ?? 0) > 0;

  // Equatable for change detection
  @override
  List<Object?> get props => [
    id, sku, name, productId, price, discountedPrice,
    trackInventory, currentQuantity, quantityLimitPerCustomer,
    preorderEndDate, weight, status, tags, barCode,
    createdAt, updatedAt, description, rating, reviewCount,
    reviews, media, images,
  ];

  // CopyWith for immutable updates
  ProductVariant copyWith({
    int? id,
    String? sku,
    // ... all fields
  }) {
    return ProductVariant(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      // ... all fields
    );
  }
}
```

**Why Equatable?**
- Riverpod uses `==` to detect state changes
- Without Equatable, state always rebuilds (reference equality)
- With Equatable, rebuilds only when actual data changes

---

#### ProductBase

**File:** `domain/entities/product_base.dart`

**Purpose:** Product-level data separate from variant

```dart
class ProductBase extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double? rating;
  final int? reviewCount;
  final List<ProductVariantMedia>? media;

  const ProductBase({
    required this.id,
    required this.name,
    this.description,
    this.rating,
    this.reviewCount,
    this.media,
  });

  @override
  List<Object?> get props => [
    id, name, description, rating, reviewCount, media
  ];

  ProductBase copyWith({
    int? id,
    String? name,
    String? description,
    double? rating,
    int? reviewCount,
    List<ProductVariantMedia>? media,
  }) {
    return ProductBase(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      media: media ?? this.media,
    );
  }
}
```

---

#### Nested Entities

**ProductVariantMedia:**
```dart
class ProductVariantMedia extends Equatable {
  final int id;
  final String? filePath;
  final String? image;
  final String? alt;
  final String? externalUrl;
  final int? productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductVariantMedia({
    required this.id,
    this.filePath,
    this.image,
    this.alt,
    this.externalUrl,
    this.productId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, filePath, image, alt, externalUrl,
    productId, createdAt, updatedAt
  ];
}
```

**ProductVariantReview:**
```dart
class ProductVariantReview extends Equatable {
  final int id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? userImage;
  final int? helpfulCount;

  const ProductVariantReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userImage,
    this.helpfulCount,
  });

  @override
  List<Object?> get props => [
    id, userName, rating, comment,
    createdAt, userImage, helpfulCount
  ];
}
```

**ProductVariantImage:**
```dart
class ProductVariantImage extends Equatable {
  final int id;
  final String image;
  final String? alt;

  const ProductVariantImage({
    required this.id,
    required this.image,
    this.alt,
  });

  @override
  List<Object?> get props => [id, image, alt];
}
```

---

### 2. Data Transfer Objects (DTOs)

#### ProductVariantDto

**File:** `infrastructure/models/product_variant_dto.dart`

**Purpose:** Parse API responses and convert to domain entities

```dart
class ProductVariantDto {
  final int id;
  final String sku;
  final String name;
  final double price;
  final double? discountedPrice;
  final int productId;
  final bool trackInventory;
  final int? currentQuantity;
  final int? quantityLimitPerCustomer;
  final DateTime? preorderEndDate;
  final double? weight;
  final String status;
  final List<String> tags;
  final String? barCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final double? rating;
  final int? reviewCount;
  final List<ProductVariantReview>? reviews;
  final List<ProductVariantMedia>? media;
  final List<ProductVariantImage>? images;

  const ProductVariantDto({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    this.discountedPrice,
    required this.productId,
    required this.trackInventory,
    this.currentQuantity,
    this.quantityLimitPerCustomer,
    this.preorderEndDate,
    this.weight,
    required this.status,
    required this.tags,
    this.barCode,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.rating,
    this.reviewCount,
    this.reviews,
    this.media,
    this.images,
  });

  // Parse from API JSON
  factory ProductVariantDto.fromJson(Map<String, dynamic> json) {
    return ProductVariantDto(
      id: json['id'] as int,
      sku: json['sku'] as String,
      name: json['name'] as String,

      // Flexible price parsing (handles String or num)
      price: _parsePrice(json['price']),
      discountedPrice: json['discounted_price'] != null
          ? _parsePrice(json['discounted_price'])
          : null,

      productId: json['product_id'] as int,
      trackInventory: json['track_inventory'] as bool? ?? true,

      // Type coercion for flexible API responses
      currentQuantity: json['current_quantity'] is int
          ? json['current_quantity'] as int
          : int.tryParse(json['current_quantity']?.toString() ?? ''),

      quantityLimitPerCustomer: json['quantity_limit_per_customer'] as int?,

      // Date parsing
      preorderEndDate: json['preorder_end_date'] != null
          ? DateTime.parse(json['preorder_end_date'] as String)
          : null,

      // Weight parsing (handles String or num)
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,

      status: json['status'] as String? ?? 'active',

      // Tags parsing (handles both List and comma-separated String)
      tags: _parseTags(json['tags']),

      barCode: json['bar_code'] as String?,

      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),

      // Extended fields (from merged data)
      description: json['description'] as String?,

      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,

      reviewCount: json['review_count'] as int?,

      // Nested collections
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((r) => ProductVariantReview.fromJson(r))
              .toList()
          : null,

      media: json['media'] != null
          ? (json['media'] as List)
              .map((m) => ProductVariantMedia.fromJson(m))
              .toList()
          : null,

      images: json['images'] != null
          ? (json['images'] as List)
              .map((i) => _parseImage(i))
              .toList()
          : null,
    );
  }

  // Helper: Parse price (handles String or num)
  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Invalid price format: $value');
  }

  // Helper: Parse tags (handles List or comma-separated String)
  static List<String> _parseTags(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      return value.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  // Helper: Parse image with URL formatting
  static ProductVariantImage _parseImage(Map<String, dynamic> json) {
    return ProductVariantImage(
      id: json['id'] as int,
      image: _formatImageUrl(json['image'] as String),
      alt: json['alt'] as String?,
    );
  }

  // Helper: Format image URL to full CDN path
  static String _formatImageUrl(String path) {
    const cdnBaseUrl = 'https://grocery-application.b-cdn.net';

    // Already full URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return _fixDuplicateDomainInUrl(path);
    }

    // Relative path - add CDN base
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cdnBaseUrl$cleanPath';
  }

  // Helper: Fix malformed API responses with duplicate domains
  static String _fixDuplicateDomainInUrl(String url) {
    // Example bad URL: https://cdn.com/https://cdn.com/image.jpg
    final regex = RegExp(r'(https?://[^/]+)/(https?://.+)');
    final match = regex.firstMatch(url);

    if (match != null) {
      return match.group(2)!; // Return the inner URL
    }

    return url;
  }

  // Convert to domain entity
  ProductVariant toDomain() {
    return ProductVariant(
      id: id,
      sku: sku,
      name: name,
      price: price,
      discountedPrice: discountedPrice,
      productId: productId,
      trackInventory: trackInventory,
      currentQuantity: currentQuantity,
      quantityLimitPerCustomer: quantityLimitPerCustomer,
      preorderEndDate: preorderEndDate,
      weight: weight,
      status: status,
      tags: tags,
      barCode: barCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
      rating: rating,
      reviewCount: reviewCount,
      reviews: reviews,
      media: media,
      images: images,
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'price': price.toString(),
      if (discountedPrice != null) 'discounted_price': discountedPrice.toString(),
      'product_id': productId,
      'track_inventory': trackInventory,
      if (currentQuantity != null) 'current_quantity': currentQuantity,
      if (quantityLimitPerCustomer != null)
        'quantity_limit_per_customer': quantityLimitPerCustomer,
      if (preorderEndDate != null)
        'preorder_end_date': preorderEndDate!.toIso8601String(),
      if (weight != null) 'weight': weight.toString(),
      'status': status,
      'tags': tags,
      if (barCode != null) 'bar_code': barCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'review_count': reviewCount,
      if (reviews != null) 'reviews': reviews!.map((r) => r.toJson()).toList(),
      if (media != null) 'media': media!.map((m) => m.toJson()).toList(),
      if (images != null) 'images': images!.map((i) => i.toJson()).toList(),
    };
  }
}
```

**Key Features:**
- ✅ Flexible type parsing (handles String, num, int variations)
- ✅ CDN URL formatting for images
- ✅ Malformed URL fixing
- ✅ Nested collection parsing
- ✅ Null-safe with proper defaults

---

#### ProductBaseDto

**File:** `infrastructure/models/product_base_dto.dart`

```dart
class ProductBaseDto {
  final int id;
  final String name;
  final String? description;
  final double? rating;
  final int? reviewCount;
  final List<ProductVariantMedia>? media;

  const ProductBaseDto({
    required this.id,
    required this.name,
    this.description,
    this.rating,
    this.reviewCount,
    this.media,
  });

  factory ProductBaseDto.fromJson(Map<String, dynamic> json) {
    return ProductBaseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,

      // Flexible rating parsing
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,

      reviewCount: json['review_count'] as int?,

      // Parse media collection
      media: json['media'] != null
          ? (json['media'] as List)
              .map((m) => ProductVariantMedia.fromJson(m))
              .toList()
          : null,
    );
  }

  ProductBase toDomain() {
    return ProductBase(
      id: id,
      name: name,
      description: description,
      rating: rating,
      reviewCount: reviewCount,
      media: media,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'review_count': reviewCount,
      if (media != null) 'media': media!.map((m) => m.toJson()).toList(),
    };
  }
}
```

---

### 3. Cache DTOs (Metadata Only)

#### ProductDetailCacheDto

**File:** `infrastructure/data_sources/local/product_detail_cache_dto.dart`

**Purpose:** Store ONLY HTTP headers, not actual product data

```dart
class ProductDetailCacheDto {
  final DateTime lastSyncedAt;  // For TTL tracking
  final String? eTag;           // For If-None-Match header
  final String? lastModified;   // For If-Modified-Since header

  const ProductDetailCacheDto({
    required this.lastSyncedAt,
    this.eTag,
    this.lastModified,
  });

  // Parse from Hive storage
  factory ProductDetailCacheDto.fromJson(Map<String, dynamic> json) {
    return ProductDetailCacheDto(
      lastSyncedAt: DateTime.parse(json['last_synced_at'] as String),
      eTag: json['etag'] as String?,
      lastModified: json['last_modified'] as String?,
    );
  }

  // Serialize to Hive storage
  Map<String, dynamic> toJson() {
    return {
      'last_synced_at': lastSyncedAt.toIso8601String(),
      if (eTag != null) 'etag': eTag,
      if (lastModified != null) 'last_modified': lastModified,
    };
  }

  // Check if metadata is stale (beyond TTL)
  bool isStale(Duration ttl) {
    final age = DateTime.now().difference(lastSyncedAt);
    return age > ttl;
  }

  // Copy with new values
  ProductDetailCacheDto copyWith({
    DateTime? lastSyncedAt,
    String? eTag,
    String? lastModified,
  }) {
    return ProductDetailCacheDto(
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      eTag: eTag ?? this.eTag,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
```

**Why metadata-only?**
- **Storage efficiency**: ~100 bytes vs 50-100KB for full product data
- **Always fresh data**: On app restart, fetch from API (with 304 optimization)
- **Simpler logic**: No stale data concerns for product content
- **Polling-optimized**: Metadata enables efficient 304 requests every 30 seconds

---

### 4. Response Wrappers

#### ProductDetailRemoteResponse

```dart
class ProductDetailRemoteResponse {
  final ProductVariantDto productDetail;
  final String? eTag;
  final String? lastModified;
  final DateTime fetchedAt;

  const ProductDetailRemoteResponse({
    required this.productDetail,
    this.eTag,
    this.lastModified,
    required this.fetchedAt,
  });
}
```

#### ProductBaseRemoteResponse

```dart
class ProductBaseRemoteResponse {
  final ProductBaseDto productBase;
  final DateTime fetchedAt;

  const ProductBaseRemoteResponse({
    required this.productBase,
    required this.fetchedAt,
  });
}
```

---

## HTTP 304 Caching Strategy

### Overview

The product details feature implements **HTTP 304 Not Modified caching** to optimize bandwidth while maintaining real-time data freshness during 30-second polling.

---

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│ 1. FIRST REQUEST (No cache metadata)                   │
├─────────────────────────────────────────────────────────┤
│ GET /api/products/v1/variants/42/                       │
│                                                         │
│ Response: 200 OK                                        │
│ Headers:                                                │
│   ETag: "abc123def456"                                  │
│   Last-Modified: Wed, 17 Jan 2024 10:00:00 GMT         │
│ Body: { full product data }                             │
│                                                         │
│ Action:                                                 │
│ ✓ Display product data                                 │
│ ✓ Save headers to Hive:                                │
│   {                                                     │
│     "last_synced_at": "2024-01-17T10:00:00.000Z",      │
│     "etag": "abc123def456",                             │
│     "last_modified": "Wed, 17 Jan 2024 10:00:00 GMT"   │
│   }                                                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 2. POLLING REQUEST (30 seconds later)                  │
├─────────────────────────────────────────────────────────┤
│ GET /api/products/v1/variants/42/                       │
│ Headers:                                                │
│   If-None-Match: "abc123def456"                         │
│   If-Modified-Since: Wed, 17 Jan 2024 10:00:00 GMT     │
│                                                         │
│ CASE A: Data Unchanged                                 │
│ Response: 304 Not Modified                             │
│ Headers:                                                │
│   ETag: "abc123def456"                                  │
│   Last-Modified: Wed, 17 Jan 2024 10:00:00 GMT         │
│ Body: (empty - saves bandwidth!)                        │
│                                                         │
│ Action:                                                 │
│ ✓ Update last_synced_at in Hive                        │
│ ✓ Keep existing UI (no rebuild)                        │
│ ✓ Bandwidth saved: ~50KB                               │
│                                                         │
│ CASE B: Data Changed                                   │
│ Response: 200 OK                                        │
│ Headers:                                                │
│   ETag: "xyz789new012"                                  │
│   Last-Modified: Thu, 18 Jan 2024 14:30:00 GMT         │
│ Body: { updated product data }                          │
│                                                         │
│ Action:                                                 │
│ ✓ Update state with new data                           │
│ ✓ Save new headers to Hive                             │
│ ✓ Riverpod rebuilds UI (Equatable detects change)      │
└─────────────────────────────────────────────────────────┘
```

---

### Implementation Layers

#### 1. Local Data Source (Metadata Storage)

**File:** `infrastructure/data_sources/local/product_detail_local_data_source.dart`

```dart
class ProductDetailLocalDataSource {
  final Box _box;

  static const Duration _cacheTTL = Duration(hours: 1);

  ProductDetailLocalDataSource({required Box box}) : _box = box;

  // Generate cache key for variant metadata
  String _getVariantMetaKey(String variantId) {
    return 'pd:variant_meta:$variantId';
  }

  // Generate cache key for product metadata
  String _getProductMetaKey(String productId) {
    return 'pd:product_meta:$productId';
  }

  // Get cached variant metadata
  Future<ProductDetailCacheDto?> getVariantMetadata(String variantId) async {
    try {
      final key = _getVariantMetaKey(variantId);
      final cached = _box.get(key);

      if (cached == null) return null;

      final cacheDto = ProductDetailCacheDto.fromJson(
        Map<String, dynamic>.from(cached as Map),
      );

      // Check TTL
      if (cacheDto.isStale(_cacheTTL)) {
        Logger.debug('Variant metadata stale for ID: $variantId');
        return null;
      }

      return cacheDto;
    } catch (e) {
      Logger.error('Failed to read variant metadata', error: e);
      return null;
    }
  }

  // Save variant metadata asynchronously
  void saveVariantMetadataAsync({
    required String variantId,
    required String? eTag,
    required String? lastModified,
  }) {
    _saveVariantMetadataInternal(
      variantId: variantId,
      eTag: eTag,
      lastModified: lastModified,
    );
  }

  Future<void> _saveVariantMetadataInternal({
    required String variantId,
    required String? eTag,
    required String? lastModified,
  }) async {
    try {
      final key = _getVariantMetaKey(variantId);
      final cacheDto = ProductDetailCacheDto(
        lastSyncedAt: DateTime.now(),
        eTag: eTag,
        lastModified: lastModified,
      );

      await _box.put(key, cacheDto.toJson());
      Logger.debug('Saved variant metadata for ID: $variantId');
    } catch (e) {
      Logger.error('Failed to save variant metadata', error: e);
    }
  }

  // Update last synced time (after 304 response)
  void updateVariantSyncTimeAsync(String variantId) {
    _updateVariantSyncTimeInternal(variantId);
  }

  Future<void> _updateVariantSyncTimeInternal(String variantId) async {
    try {
      final key = _getVariantMetaKey(variantId);
      final existing = await getVariantMetadata(variantId);

      if (existing != null) {
        final updated = existing.copyWith(lastSyncedAt: DateTime.now());
        await _box.put(key, updated.toJson());
        Logger.debug('Updated sync time for variant: $variantId');
      }
    } catch (e) {
      Logger.error('Failed to update variant sync time', error: e);
    }
  }

  // Clear metadata (for testing or logout)
  Future<void> clearVariantMetadata(String variantId) async {
    final key = _getVariantMetaKey(variantId);
    await _box.delete(key);
  }

  Future<void> clearAllMetadata() async {
    await _box.clear();
  }
}
```

**Storage Structure:**
```
Hive Box: AppHiveBoxes.cache

Keys:
├─ pd:variant_meta:42
├─ pd:variant_meta:43
├─ pd:product_meta:10
└─ pd:product_meta:11

Values (JSON):
{
  "last_synced_at": "2024-01-17T12:00:00.000Z",
  "etag": "abc123def456",
  "last_modified": "Wed, 17 Jan 2024 12:00:00 GMT"
}
```

---

#### 2. Remote Data Source (Conditional Requests)

**File:** `infrastructure/data_sources/remote/product_detail_remote_data_source.dart`

```dart
class ProductDetailRemoteDataSource {
  final ApiClient _apiClient;

  ProductDetailRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Fetch product variant with conditional request support
  Future<ProductDetailRemoteResponse?> fetchProductDetail({
    required String productId,
    String? ifNoneMatch,      // ETag for If-None-Match header
    String? ifModifiedSince,  // Last-Modified for If-Modified-Since header
  }) async {
    try {
      // Build conditional headers
      final headers = <String, String>{};

      if (ifNoneMatch != null) {
        headers['If-None-Match'] = ifNoneMatch;
      }
      if (ifModifiedSince != null) {
        headers['If-Modified-Since'] = ifModifiedSince;
      }

      Logger.debug('Fetching product variant', data: {
        'product_id': productId,
        'has_etag': ifNoneMatch != null,
        'has_last_modified': ifModifiedSince != null,
      });

      // Make API request
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/products/v1/variants/$productId/',
        headers: headers.isNotEmpty ? headers : null,
      );

      // Handle 304 Not Modified
      if (response.statusCode == 304) {
        Logger.info('Product variant not modified (304)', data: {
          'product_id': productId,
        });
        return null;  // Signal: no changes
      }

      // Parse new data
      final productDetail = ProductVariantDto.fromJson(response.data!);

      // Extract cache headers
      final eTag = response.headers.value('etag');
      final lastModified = response.headers.value('last-modified');

      Logger.info('Product variant fetched successfully', data: {
        'product_id': productId,
        'has_etag': eTag != null,
        'has_last_modified': lastModified != null,
      });

      return ProductDetailRemoteResponse(
        productDetail: productDetail,
        eTag: eTag,
        lastModified: lastModified,
        fetchedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      Logger.error('Unexpected error fetching product variant', error: e);
      rethrow;
    }
  }

  /// Fetch product base (description, rating) - NO 304 support
  Future<ProductBaseRemoteResponse> fetchProductBase({
    required String productId,
  }) async {
    try {
      Logger.debug('Fetching product base', data: {
        'product_id': productId,
      });

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/products/v1/$productId/',
      );

      final productBase = ProductBaseDto.fromJson(response.data!);

      return ProductBaseRemoteResponse(
        productBase: productBase,
        fetchedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      Logger.error('Unexpected error fetching product base', error: e);
      rethrow;
    }
  }

  NetworkException _handleDioException(DioException e) {
    return NetworkException.fromDio(e);
  }
}
```

---

#### 3. Repository (Orchestration)

**File:** `infrastructure/repositories/product_detail_repository_impl.dart`

```dart
class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final ProductDetailRemoteDataSource _remoteDataSource;
  final ProductDetailLocalDataSource _localDataSource;

  ProductDetailRepositoryImpl({
    required ProductDetailRemoteDataSource remoteDataSource,
    required ProductDetailLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<ProductVariant?> getProductDetail({
    required String variantId,
    bool forceRefresh = false,
  }) async {
    try {
      // Get cached metadata (unless forceRefresh)
      ProductDetailCacheDto? cachedMetadata;
      if (!forceRefresh) {
        cachedMetadata = await _localDataSource.getVariantMetadata(variantId);
      }

      // Fetch variant with conditional headers
      final remoteResponse = await _remoteDataSource.fetchProductDetail(
        productId: variantId,
        ifNoneMatch: cachedMetadata?.eTag,
        ifModifiedSince: cachedMetadata?.lastModified,
      );

      // Handle 304 Not Modified
      if (remoteResponse == null) {
        Logger.info('Variant not modified, updating sync time');

        // Update last synced time (metadata still valid)
        _localDataSource.updateVariantSyncTimeAsync(variantId);

        // Return null (UI won't refresh)
        return null;
      }

      // New data received - save metadata
      _localDataSource.saveVariantMetadataAsync(
        variantId: variantId,
        eTag: remoteResponse.eTag,
        lastModified: remoteResponse.lastModified,
      );

      // Convert to domain entity
      return remoteResponse.productDetail.toDomain();
    } catch (e) {
      Logger.error('Failed to fetch product variant', error: e);
      rethrow;
    }
  }

  @override
  Future<ProductBase?> getProductBase({
    required String productId,
  }) async {
    try {
      // Product API does NOT support If-Modified-Since
      // Always fetches fresh data
      final remoteResponse = await _remoteDataSource.fetchProductBase(
        productId: productId,
      );

      return remoteResponse.productBase.toDomain();
    } catch (e) {
      Logger.error('Failed to fetch product base', error: e);
      rethrow;
    }
  }

  @override
  Future<ProductVariant> getCompleteProductDetail({
    required String variantId,
    required String productId,
    bool forceRefresh = false,
  }) async {
    // Fetch both APIs in parallel
    final results = await Future.wait([
      getProductDetail(variantId: variantId, forceRefresh: forceRefresh),
      getProductBase(productId: productId),
    ]);

    final variantData = results[0] as ProductVariant?;
    final productData = results[1] as ProductBase?;

    // If variant returned null (304), no data to merge
    if (variantData == null) {
      return null;
    }

    // Merge product data into variant
    if (productData != null) {
      return variantData.copyWith(
        description: productData.description,
        rating: productData.rating,
        reviewCount: productData.reviewCount,
        media: productData.media,
      );
    }

    return variantData;
  }
}
```

**Key Logic:**
1. **Check metadata cache** (unless `forceRefresh=true`)
2. **Send conditional request** with ETag/Last-Modified headers
3. **Handle 304**: Update sync time, return `null`
4. **Handle 200**: Save new headers, return fresh data
5. **Merge**: Combine variant + product data

---

### Benefits of This Strategy

| Benefit | Description | Impact |
|---------|-------------|--------|
| **Bandwidth Savings** | 304 response ~1KB vs 200 ~50KB | 98% reduction when polling |
| **Battery Efficiency** | Less data transfer = less radio usage | Extended battery life |
| **Fast Polling** | Can poll every 30s without bandwidth concerns | Real-time updates |
| **Server Load** | 304 responses are cheaper to generate | Scales better |
| **Standard HTTP** | Works with CDNs and proxies | Infrastructure-friendly |

**Example Savings:**
```
Without 304 (always 200 OK):
- Polling interval: 30 seconds
- Response size: 50KB
- Data per hour: 50KB × 120 = 6MB
- Data per day: 6MB × 24 = 144MB

With 304 (90% cache hit rate):
- Polling interval: 30 seconds
- 304 response: 1KB (90% of requests)
- 200 response: 50KB (10% of requests)
- Data per hour: (1KB × 108) + (50KB × 12) = 708KB
- Data per day: 708KB × 24 = 17MB

Savings: 127MB per day per user!
```

---

## Repository Pattern

### Abstract Interface

**File:** `domain/repositories/product_detail_repository.dart`

```dart
abstract class ProductDetailRepository {
  /// Fetch product variant with optional 304 caching
  Future<ProductVariant?> getProductDetail({
    required String variantId,
    bool forceRefresh = false,
  });

  /// Fetch product base data (description, rating, media)
  Future<ProductBase?> getProductBase({
    required String productId,
  });

  /// Fetch and merge both variant and product data
  Future<ProductVariant?> getCompleteProductDetail({
    required String variantId,
    required String productId,
    bool forceRefresh = false,
  });
}
```

---

### Implementation

**File:** `infrastructure/repositories/product_detail_repository_impl.dart`

*See code in HTTP 304 Caching Strategy section above*

**Key Methods:**

1. **`getProductDetail()`** - Variant API with 304 support
2. **`getProductBase()`** - Product API (always fresh)
3. **`getCompleteProductDetail()`** - Merge both APIs

---

## State Management

### State Model

**File:** `application/states/product_detail_state.dart`

```dart
enum ProductDetailStatus {
  initial,    // Not loaded yet
  loading,    // Fetching from API
  data,       // Data available
  empty,      // No data found
  error,      // Error occurred
}

class ProductDetailState extends Equatable {
  // Core data
  final ProductVariant? productDetail;
  final ProductBase? productBase;
  final List<ProductVariantReview>? reviews;

  // UI state
  final int quantity;
  final bool isInWishlist;

  // Status
  final ProductDetailStatus status;
  final String? errorMessage;

  // Polling tracking
  final DateTime? lastSyncedAt;
  final DateTime? lastFetchedAt;
  final bool isRefreshing;
  final DateTime? refreshStartedAt;
  final DateTime? refreshEndedAt;

  // Cache metadata
  final String? eTag;
  final String? lastModified;

  const ProductDetailState({
    this.productDetail,
    this.productBase,
    this.reviews,
    this.quantity = 1,
    this.isInWishlist = false,
    required this.status,
    this.errorMessage,
    this.lastSyncedAt,
    this.lastFetchedAt,
    this.isRefreshing = false,
    this.refreshStartedAt,
    this.refreshEndedAt,
    this.eTag,
    this.lastModified,
  });

  // Computed properties
  bool get hasData => productDetail != null;
  bool get hasError => status == ProductDetailStatus.error;
  bool get isLoading => status == ProductDetailStatus.loading;
  bool get isEmpty => status == ProductDetailStatus.empty;

  // Initial state factory
  factory ProductDetailState.initial() {
    return const ProductDetailState(status: ProductDetailStatus.initial);
  }

  // Equatable props (for change detection)
  @override
  List<Object?> get props => [
    productDetail,
    productBase,
    reviews,
    quantity,
    isInWishlist,
    status,
    errorMessage,
    lastSyncedAt,
    lastFetchedAt,
    isRefreshing,
    refreshStartedAt,
    refreshEndedAt,
    eTag,
    lastModified,
  ];

  // CopyWith for immutable updates
  ProductDetailState copyWith({
    ProductVariant? productDetail,
    ProductBase? productBase,
    List<ProductVariantReview>? reviews,
    int? quantity,
    bool? isInWishlist,
    ProductDetailStatus? status,
    String? errorMessage,
    DateTime? lastSyncedAt,
    DateTime? lastFetchedAt,
    bool? isRefreshing,
    DateTime? refreshStartedAt,
    DateTime? refreshEndedAt,
    String? eTag,
    String? lastModified,
  }) {
    return ProductDetailState(
      productDetail: productDetail ?? this.productDetail,
      productBase: productBase ?? this.productBase,
      reviews: reviews ?? this.reviews,
      quantity: quantity ?? this.quantity,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      status: status ?? this.status,
      errorMessage: errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshStartedAt: refreshStartedAt ?? this.refreshStartedAt,
      refreshEndedAt: refreshEndedAt ?? this.refreshEndedAt,
      eTag: eTag ?? this.eTag,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
```

---

### Provider Architecture

**File:** `application/providers/product_detail_providers.dart`

#### AutoDisposeFamily Pattern

```dart
/// Product detail controller (per-variant state management)
final productDetailControllerProvider = AutoDisposeNotifierProviderFamily<
    ProductDetailController,
    ProductDetailState,
    String  // variantId
>() {
  return ProductDetailController();
};

class ProductDetailController
    extends AutoDisposeFamilyNotifier<ProductDetailState, String> {

  late final ProductDetailRepository _repository;
  late final String _variantId;
  Timer? _pollingTimer;

  @override
  ProductDetailState build(String arg) {
    _variantId = arg;
    _repository = ref.read(productDetailRepositoryProvider);

    // Initialize data on first build
    _loadInitial();

    // Cleanup on dispose
    ref.onDispose(() {
      _pollingTimer?.cancel();
      Logger.debug('ProductDetailController disposed for variant: $_variantId');
    });

    return ProductDetailState.initial();
  }

  // Methods documented in next sections...
}
```

**Why AutoDisposeFamily?**
- **Family**: Separate state instance per variant ID
- **AutoDispose**: Automatic cleanup when no longer watched
- **Benefits**:
  - No state leakage between products
  - Memory efficient (auto garbage collection)
  - Timer cleanup on navigation away

---

### Controller Methods

#### 1. Initial Load

```dart
Future<void> _loadInitial() async {
  try {
    state = state.copyWith(status: ProductDetailStatus.loading);

    // Force fresh data on initial load
    final productDetail = await _repository.getCompleteProductDetail(
      variantId: _variantId,
      productId: _extractProductId(_variantId),
      forceRefresh: true,
    );

    if (productDetail == null) {
      state = state.copyWith(
        status: ProductDetailStatus.empty,
        errorMessage: 'Product not found',
      );
      return;
    }

    state = state.copyWith(
      status: ProductDetailStatus.data,
      productDetail: productDetail,
      lastFetchedAt: DateTime.now(),
    );

    // Start polling after initial load
    _startPolling();
  } catch (e) {
    Logger.error('Failed to load product detail', error: e);
    state = state.copyWith(
      status: ProductDetailStatus.error,
      errorMessage: _mapError(e),
    );
  }
}
```

---

#### 2. Refresh (Manual Pull-to-Refresh)

```dart
Future<void> refresh() async {
  try {
    state = state.copyWith(
      isRefreshing: true,
      refreshStartedAt: DateTime.now(),
    );

    final productDetail = await _repository.getCompleteProductDetail(
      variantId: _variantId,
      productId: _extractProductId(_variantId),
      forceRefresh: true,  // Bypass cache
    );

    if (productDetail != null) {
      state = state.copyWith(
        status: ProductDetailStatus.data,
        productDetail: productDetail,
        lastFetchedAt: DateTime.now(),
        isRefreshing: false,
        refreshEndedAt: DateTime.now(),
      );
    } else {
      state = state.copyWith(
        isRefreshing: false,
        refreshEndedAt: DateTime.now(),
      );
    }
  } catch (e) {
    Logger.error('Failed to refresh product detail', error: e);
    state = state.copyWith(
      status: ProductDetailStatus.error,
      errorMessage: _mapError(e),
      isRefreshing: false,
      refreshEndedAt: DateTime.now(),
    );
  }
}
```

---

## Real-Time Polling

### Configuration

**File:** `application/config/product_detail_config.dart`

```dart
class ProductDetailConfig {
  // Polling interval for price/stock updates
  static const Duration pollingInterval = Duration(seconds: 30);

  // Cache TTL for metadata
  static const Duration cacheTTL = Duration(hours: 1);

  // Timeout for API requests
  static const Duration requestTimeout = Duration(seconds: 10);
}
```

---

### Polling Implementation

**In ProductDetailController:**

```dart
void _startPolling() {
  // Cancel existing timer if any
  _pollingTimer?.cancel();

  Logger.debug('Starting polling for variant: $_variantId', data: {
    'interval_seconds': ProductDetailConfig.pollingInterval.inSeconds,
  });

  _pollingTimer = Timer.periodic(
    ProductDetailConfig.pollingInterval,
    (_) => _refreshInternal(),
  );
}

Future<void> _refreshInternal() async {
  try {
    Logger.debug('Polling refresh for variant: $_variantId');

    // Fetch with conditional request (304 optimization)
    final productDetail = await _repository.getCompleteProductDetail(
      variantId: _variantId,
      productId: _extractProductId(_variantId),
      forceRefresh: false,  // Use cached metadata
    );

    // null = 304 Not Modified, no UI update needed
    if (productDetail == null) {
      Logger.debug('No changes detected (304)');

      state = state.copyWith(
        lastSyncedAt: DateTime.now(),
      );
      return;
    }

    // New data - update state
    Logger.info('Product data updated via polling');

    state = state.copyWith(
      productDetail: productDetail,
      lastFetchedAt: DateTime.now(),
      lastSyncedAt: DateTime.now(),
    );
  } catch (e) {
    // Silently fail - keep existing data
    Logger.error('Polling refresh failed', error: e);
  }
}

@override
void dispose() {
  _pollingTimer?.cancel();
  super.dispose();
}
```

**Key Features:**
- ✅ **Automatic start** after initial load
- ✅ **Conditional requests** (304 optimization)
- ✅ **Silent failures** (don't disrupt UI)
- ✅ **Auto cleanup** on dispose
- ✅ **Configurable interval**

---

### Polling Benefits

| Aspect | Benefit |
|--------|---------|
| **Real-time pricing** | Price changes reflected within 30s |
| **Stock updates** | Out-of-stock detection |
| **Bandwidth efficient** | 304 responses = minimal data |
| **Battery friendly** | Short-lived HTTP requests |
| **User experience** | Seamless updates without refresh |

---

## Wishlist Integration

### State Tracking

```dart
// In ProductDetailController

Future<void> checkWishlistStatus() async {
  try {
    final isInWishlist = await _wishlistRepository.checkWishlist(
      productId: _extractProductId(_variantId),
    );

    state = state.copyWith(isInWishlist: isInWishlist);
  } catch (e) {
    Logger.error('Failed to check wishlist status', error: e);
  }
}

Future<bool> toggleWishlist() async {
  // Check authentication
  final authState = ref.read(authProvider);
  if (authState is GuestMode) {
    state = state.copyWith(
      errorMessage: 'Please login to add items to wishlist',
    );
    return false;
  }

  try {
    final currentStatus = state.isInWishlist;

    if (currentStatus) {
      // Remove from wishlist
      await _wishlistRepository.removeFromWishlist(
        productId: _extractProductId(_variantId),
      );
    } else {
      // Add to wishlist
      await _wishlistRepository.addToWishlist(
        productId: _extractProductId(_variantId),
      );
    }

    // Toggle state
    state = state.copyWith(isInWishlist: !currentStatus);

    return true;
  } catch (e) {
    Logger.error('Failed to toggle wishlist', error: e);
    state = state.copyWith(
      errorMessage: _mapError(e),
    );
    return false;
  }
}
```

---

## Cart Integration

### Quantity Management

```dart
// In ProductDetailController

void setQuantity(int quantity) {
  if (quantity < 1) return;

  final product = state.productDetail;
  if (product == null) return;

  // Check quantity limit
  final limit = product.quantityLimitPerCustomer;
  if (limit != null && quantity > limit) {
    state = state.copyWith(
      errorMessage: 'Maximum $limit items per customer',
    );
    return;
  }

  // Check stock
  if (product.trackInventory) {
    final available = product.currentQuantity ?? 0;
    if (quantity > available) {
      state = state.copyWith(
        errorMessage: 'Only $available items in stock',
      );
      return;
    }
  }

  state = state.copyWith(quantity: quantity);
}

void incrementQuantity() {
  setQuantity(state.quantity + 1);
}

void decrementQuantity() {
  setQuantity(state.quantity - 1);
}
```

---

### Add to Cart

```dart
Future<void> addToCart() async {
  // Check authentication
  final authState = ref.read(authProvider);
  if (authState is GuestMode) {
    state = state.copyWith(
      errorMessage: 'Please login to add items to cart',
    );
    return;
  }

  final product = state.productDetail;
  if (product == null) return;

  // Check stock
  if (!product.inStock) {
    state = state.copyWith(
      errorMessage: 'This product is out of stock',
    );
    return;
  }

  try {
    // Call cart provider
    await ref.read(checkoutLineControllerProvider.notifier).addToCart(
      productVariantId: product.id,
      quantity: state.quantity,
    );

    Logger.info('Added to cart', data: {
      'variant_id': product.id,
      'quantity': state.quantity,
    });
  } catch (e) {
    Logger.error('Failed to add to cart', error: e);
    state = state.copyWith(
      errorMessage: _mapError(e),
    );
    rethrow;
  }
}
```

---

## Rating & Review System

### Order Integration

**File:** `application/providers/product_order_provider.dart`

```dart
/// Find completed order containing this product variant
@riverpod
Future<(int, String)?> productCompletedOrder(
  Ref ref,
  String variantId,
) async {
  try {
    // Fetch user's orders
    final ordersState = await ref.watch(ordersProvider.future);

    // Filter for completed orders
    final completedOrders = ordersState
        .where((order) => order.status == 'completed')
        .toList();

    // Find first order containing this variant
    for (final order in completedOrders) {
      final hasVariant = order.items.any(
        (item) => item.productVariantId.toString() == variantId,
      );

      if (hasVariant) {
        return (order.id, order.deliveryDate ?? '');
      }
    }

    return null;  // No completed order with this product
  } catch (e) {
    Logger.error('Failed to fetch completed order', error: e);
    return null;
  }
}
```

---

### Rating Submission

**In ProductDetailController:**

```dart
Future<void> submitRating({
  required int orderId,
  required int rating,
}) async {
  try {
    Logger.info('Submitting rating', data: {
      'order_id': orderId,
      'rating': rating,
    });

    await ref.read(ordersApiProvider).submitOrderRating(
      orderId: orderId,
      rating: rating,
    );

    // Refresh product to get new rating
    await refresh();
  } catch (e) {
    Logger.error('Failed to submit rating', error: e);
    state = state.copyWith(
      errorMessage: _mapError(e),
    );
    rethrow;
  }
}
```

---

## Error Handling

### Error Types

**From:** `core/network/network_exceptions.dart`

```dart
enum NetworkErrorType {
  noInternet,      // No network connection
  timeout,         // Request timeout
  serverError,     // 5xx response
  clientError,     // 4xx response
  unknown,         // Other errors
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final NetworkErrorType errorType;
  final dynamic body;

  const NetworkException({
    required this.message,
    this.statusCode,
    required this.errorType,
    this.body,
  });

  factory NetworkException.fromDio(DioException error) {
    // Conversion logic...
  }
}
```

---

### Error Mapping

**In ProductDetailController:**

```dart
String _mapError(Object error) {
  if (error is NetworkException) {
    switch (error.errorType) {
      case NetworkErrorType.noInternet:
        return 'No internet connection. Please check your network.';

      case NetworkErrorType.timeout:
        return 'Request timed out. Please try again.';

      case NetworkErrorType.serverError:
        return 'Server error. Please try again later.';

      case NetworkErrorType.clientError:
        if (error.statusCode == 404) {
          return 'Product not found.';
        }
        return error.message;

      default:
        return 'Unable to load product. Please try again.';
    }
  }

  if (error is FormatException) {
    return 'Invalid product data. Please try again.';
  }

  return 'Something went wrong. Please try again.';
}
```

---

### UI Error Display

**In ProductDetailsScreen:**

```dart
// Listen for errors
ref.listen<ProductDetailState>(
  productDetailControllerProvider(widget.variantId),
  (previous, next) {
    if (next.hasError && next.errorMessage != null) {
      AppSnackbar.error(context, next.errorMessage!);
    }
  },
);

// Error state UI
if (state.hasError && !state.hasData) {
  return ErrorView(
    message: state.errorMessage ?? 'Failed to load product',
    onRetry: () {
      ref.read(productDetailControllerProvider(widget.variantId).notifier)
        .refresh();
    },
  );
}
```

---

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│              PRESENTATION LAYER (UI)                    │
│           (Framework-Specific - Flutter)                │
├─────────────────────────────────────────────────────────┤
│ - ProductDetailsScreen (coordinator)                    │
│ - ProductImageSection (image carousel)                  │
│ - ProductInfo (name, price, stock)                      │
│ - RatingSection (reviews + rating submission)           │
│ - QuantitySelector (increment/decrement)                │
│ - AddToCartButton                                       │
└───────────────────────┬─────────────────────────────────┘
                        │ (watches state)
                        ▼
┌─────────────────────────────────────────────────────────┐
│          APPLICATION LAYER (Business Logic)             │
│              (Framework-Agnostic)                       │
├─────────────────────────────────────────────────────────┤
│ ProductDetailController (AutoDisposeFamily)             │
│ ├─ State management                                     │
│ ├─ Polling timer                                        │
│ ├─ Wishlist operations                                  │
│ ├─ Cart operations                                      │
│ ├─ Rating submission                                    │
│ └─ Error mapping                                        │
│                                                         │
│ ProductDetailState                                      │
│ ├─ status: ProductDetailStatus                          │
│ ├─ productDetail: ProductVariant?                       │
│ ├─ quantity: int                                        │
│ ├─ isInWishlist: bool                                   │
│ ├─ lastSyncedAt: DateTime?                              │
│ └─ eTag/lastModified cache metadata                     │
└───────────────────────┬─────────────────────────────────┘
                        │ (calls)
                        ▼
┌─────────────────────────────────────────────────────────┐
│            DOMAIN LAYER (Pure Business Logic)           │
│              (Framework-Agnostic)                       │
├─────────────────────────────────────────────────────────┤
│ ProductDetailRepository (interface)                     │
│ ├─ getProductDetail() → ProductVariant?                 │
│ ├─ getProductBase() → ProductBase?                      │
│ └─ getCompleteProductDetail() → ProductVariant?         │
│                                                         │
│ Entities (with Equatable):                              │
│ ├─ ProductVariant (complete product data)               │
│ ├─ ProductBase (description, rating, media)             │
│ ├─ ProductVariantMedia                                  │
│ ├─ ProductVariantReview                                 │
│ └─ ProductVariantImage                                  │
└───────────────────────┬─────────────────────────────────┘
                        │ (implements)
                        ▼
┌─────────────────────────────────────────────────────────┐
│        INFRASTRUCTURE LAYER (Data Access)               │
│          (Framework-Dependent)                          │
├─────────────────────────────────────────────────────────┤
│ ProductDetailRepositoryImpl                             │
│ ├─ Orchestrates remote + local data sources             │
│ ├─ Merges variant + product data                        │
│ └─ Handles 304 logic                                    │
│                                                         │
│ Data Sources:                                           │
│ ├─ ProductDetailRemoteDataSource                        │
│ │  ├─ HTTP client (Dio)                                 │
│ │  ├─ Conditional requests (If-None-Match)              │
│ │  └─ Response header extraction                        │
│ │                                                       │
│ └─ ProductDetailLocalDataSource                         │
│    ├─ Hive storage (metadata only)                      │
│    ├─ TTL validation                                    │
│    └─ Async writes (fire-and-forget)                    │
│                                                         │
│ DTOs:                                                   │
│ ├─ ProductVariantDto                                    │
│ │  ├─ fromJson() - flexible parsing                     │
│ │  ├─ toDomain() - convert to entity                    │
│ │  └─ URL formatting helpers                            │
│ │                                                       │
│ ├─ ProductBaseDto                                       │
│ └─ ProductDetailCacheDto (metadata only)                │
└──────────────┬────────────────┬─────────────────────────┘
               │                │
               ▼                ▼
    ┌─────────────────┐  ┌──────────────┐
    │   Remote API    │  │ Local Cache  │
    │   (HTTP/REST)   │  │   (Hive)     │
    ├─────────────────┤  ├──────────────┤
    │ Variant API     │  │ Metadata-    │
    │ (304 support)   │  │ only cache   │
    │                 │  │              │
    │ Product API     │  │ Keys:        │
    │ (no 304)        │  │ pd:variant_  │
    │                 │  │ meta:{id}    │
    └─────────────────┘  └──────────────┘
```

---

### Data Flow

```
User Opens Product Details Screen
    ↓
ProductDetailController.build(variantId)
    ↓
_loadInitial()
    ├─ Set status = loading
    ├─ Call repository.getCompleteProductDetail(forceRefresh: true)
    │   ├─ getProductDetail() with no cache headers
    │   ├─ getProductBase() (always fresh)
    │   └─ Merge data
    ├─ Update state with product data
    └─ _startPolling()
        ↓
        Timer.periodic(30 seconds)
            ↓
            _refreshInternal()
                ├─ Call repository.getCompleteProductDetail(forceRefresh: false)
                │   ├─ Read cached metadata (eTag, lastModified)
                │   ├─ Send conditional request
                │   │   ├─ 304 → Update sync time, return null
                │   │   └─ 200 → Parse data, save headers
                │   └─ Return ProductVariant or null
                │
                ├─ If null → Update lastSyncedAt only
                └─ If data → Update state, Riverpod rebuilds UI
```

---

## Replication Guide

### Step 1: Project Setup

#### Directory Structure

```
lib/features/product_details/
├── domain/
│   ├── entities/
│   │   ├── product_variant.dart
│   │   └── product_base.dart
│   └── repositories/
│       └── product_detail_repository.dart
├── infrastructure/
│   ├── models/
│   │   ├── product_variant_dto.dart
│   │   └── product_base_dto.dart
│   ├── data_sources/
│   │   ├── remote/
│   │   │   └── product_detail_remote_data_source.dart
│   │   └── local/
│   │       ├── product_detail_local_data_source.dart
│   │       └── product_detail_cache_dto.dart
│   └── repositories/
│       └── product_detail_repository_impl.dart
├── application/
│   ├── states/
│   │   └── product_detail_state.dart
│   ├── providers/
│   │   ├── product_detail_providers.dart
│   │   └── product_order_provider.dart
│   └── config/
│       └── product_detail_config.dart
└── presentation/
    ├── screen/
    │   └── product_details_screen.dart
    └── components/
        ├── product_image_section.dart
        ├── product_info.dart
        ├── rating_section.dart
        ├── quantity_selector.dart
        └── add_to_cart_button.dart
```

---

### Step 2: Core Entity (100% Reusable)

```dart
// domain/entities/product_variant.dart

class ProductVariant extends Equatable {
  final int id;
  final String sku;
  final String name;
  final double price;
  final double? discountedPrice;
  final int productId;
  final bool trackInventory;
  final int? currentQuantity;
  // ... all other fields from Data Models section

  const ProductVariant({...});

  // Computed properties
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
  bool get inStock => !trackInventory || (currentQuantity ?? 0) > 0;

  @override
  List<Object?> get props => [...];

  ProductVariant copyWith({...}) {...}
}
```

---

### Step 3: Repository Interface

```dart
// domain/repositories/product_detail_repository.dart

abstract class ProductDetailRepository {
  Future<ProductVariant?> getProductDetail({
    required String variantId,
    bool forceRefresh = false,
  });

  Future<ProductBase?> getProductBase({
    required String productId,
  });

  Future<ProductVariant?> getCompleteProductDetail({
    required String variantId,
    required String productId,
    bool forceRefresh = false,
  });
}
```

---

### Step 4: Remote Data Source (Adapt to Your API)

```dart
// infrastructure/data_sources/remote/product_detail_remote_data_source.dart

class ProductDetailRemoteDataSource {
  final ApiClient _apiClient;

  Future<ProductDetailRemoteResponse?> fetchProductDetail({
    required String productId,
    String? ifNoneMatch,
    String? ifModifiedSince,
  }) async {
    // Build headers
    final headers = <String, String>{};
    if (ifNoneMatch != null) headers['If-None-Match'] = ifNoneMatch;
    if (ifModifiedSince != null) headers['If-Modified-Since'] = ifModifiedSince;

    // Make request
    final response = await _apiClient.get(
      '/api/products/v1/variants/$productId/',
      headers: headers.isNotEmpty ? headers : null,
    );

    // Handle 304
    if (response.statusCode == 304) return null;

    // Parse and return with headers
    return ProductDetailRemoteResponse(
      productDetail: ProductVariantDto.fromJson(response.data),
      eTag: response.headers.value('etag'),
      lastModified: response.headers.value('last-modified'),
      fetchedAt: DateTime.now(),
    );
  }
}
```

---

### Step 5: Local Data Source (Metadata Storage)

```dart
// infrastructure/data_sources/local/product_detail_local_data_source.dart

class ProductDetailLocalDataSource {
  final Box _box;
  static const Duration _cacheTTL = Duration(hours: 1);

  Future<ProductDetailCacheDto?> getVariantMetadata(String variantId) async {
    final key = 'pd:variant_meta:$variantId';
    final cached = _box.get(key);

    if (cached == null) return null;

    final cacheDto = ProductDetailCacheDto.fromJson(cached);

    // Check TTL
    if (cacheDto.isStale(_cacheTTL)) return null;

    return cacheDto;
  }

  void saveVariantMetadataAsync({
    required String variantId,
    required String? eTag,
    required String? lastModified,
  }) {
    // Fire-and-forget async save
    _saveInternal(variantId, eTag, lastModified);
  }
}
```

---

### Step 6: Repository Implementation

```dart
// infrastructure/repositories/product_detail_repository_impl.dart

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final ProductDetailRemoteDataSource _remoteDataSource;
  final ProductDetailLocalDataSource _localDataSource;

  @override
  Future<ProductVariant?> getProductDetail({
    required String variantId,
    bool forceRefresh = false,
  }) async {
    // Get cached metadata (unless forceRefresh)
    ProductDetailCacheDto? cachedMetadata;
    if (!forceRefresh) {
      cachedMetadata = await _localDataSource.getVariantMetadata(variantId);
    }

    // Fetch with conditional headers
    final remoteResponse = await _remoteDataSource.fetchProductDetail(
      productId: variantId,
      ifNoneMatch: cachedMetadata?.eTag,
      ifModifiedSince: cachedMetadata?.lastModified,
    );

    // Handle 304
    if (remoteResponse == null) {
      _localDataSource.updateVariantSyncTimeAsync(variantId);
      return null;
    }

    // Save new metadata
    _localDataSource.saveVariantMetadataAsync(
      variantId: variantId,
      eTag: remoteResponse.eTag,
      lastModified: remoteResponse.lastModified,
    );

    return remoteResponse.productDetail.toDomain();
  }

  @override
  Future<ProductVariant?> getCompleteProductDetail({
    required String variantId,
    required String productId,
    bool forceRefresh = false,
  }) async {
    // Fetch both in parallel
    final results = await Future.wait([
      getProductDetail(variantId: variantId, forceRefresh: forceRefresh),
      getProductBase(productId: productId),
    ]);

    final variantData = results[0] as ProductVariant?;
    final productData = results[1] as ProductBase?;

    if (variantData == null) return null;

    // Merge
    if (productData != null) {
      return variantData.copyWith(
        description: productData.description,
        rating: productData.rating,
        reviewCount: productData.reviewCount,
        media: productData.media,
      );
    }

    return variantData;
  }
}
```

---

### Step 7: State & Controller

```dart
// application/states/product_detail_state.dart

enum ProductDetailStatus { initial, loading, data, empty, error }

class ProductDetailState extends Equatable {
  final ProductVariant? productDetail;
  final int quantity;
  final bool isInWishlist;
  final ProductDetailStatus status;
  final String? errorMessage;
  final DateTime? lastSyncedAt;
  final bool isRefreshing;

  const ProductDetailState({...});

  @override
  List<Object?> get props => [...];

  ProductDetailState copyWith({...}) {...}
}
```

```dart
// application/providers/product_detail_providers.dart

final productDetailControllerProvider = AutoDisposeNotifierProviderFamily<
    ProductDetailController,
    ProductDetailState,
    String
>() => ProductDetailController();

class ProductDetailController
    extends AutoDisposeFamilyNotifier<ProductDetailState, String> {

  Timer? _pollingTimer;

  @override
  ProductDetailState build(String arg) {
    _loadInitial();
    ref.onDispose(() => _pollingTimer?.cancel());
    return ProductDetailState.initial();
  }

  Future<void> _loadInitial() {...}
  void _startPolling() {...}
  Future<void> _refreshInternal() {...}
  Future<void> addToCart() {...}
  Future<bool> toggleWishlist() {...}
}
```

---

### Step 8: Testing

#### Unit Test (Repository)

```dart
void main() {
  late ProductDetailRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = ProductDetailRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  group('getProductDetail with 304', () {
    test('returns null when server returns 304', () async {
      // Arrange
      final cachedMetadata = ProductDetailCacheDto(
        lastSyncedAt: DateTime.now(),
        eTag: 'abc123',
        lastModified: 'Wed, 17 Jan 2024 10:00:00 GMT',
      );

      when(() => mockLocal.getVariantMetadata('42'))
        .thenAnswer((_) async => cachedMetadata);

      when(() => mockRemote.fetchProductDetail(
        productId: '42',
        ifNoneMatch: 'abc123',
        ifModifiedSince: 'Wed, 17 Jan 2024 10:00:00 GMT',
      )).thenAnswer((_) async => null); // 304

      // Act
      final result = await repository.getProductDetail(variantId: '42');

      // Assert
      expect(result, null);
      verify(() => mockLocal.updateVariantSyncTimeAsync('42')).called(1);
    });
  });
}
```

---

### Step 9: Platform Adaptations

#### For React (Web)

```typescript
// hooks/useProductDetail.ts

import { useQuery } from 'react-query';
import { productDetailRepository } from '../repositories';

export function useProductDetail(variantId: string) {
  const {
    data: product,
    isLoading,
    error,
    refetch,
  } = useQuery(
    ['productDetail', variantId],
    () => productDetailRepository.getCompleteProductDetail({
      variantId,
      productId: extractProductId(variantId),
      forceRefresh: false,
    }),
    {
      refetchInterval: 30000, // Poll every 30 seconds
      staleTime: 0,           // Always consider stale (for 304 checks)
    }
  );

  return { product, isLoading, error, refetch };
}
```

#### For iOS (Swift)

```swift
class ProductDetailViewModel: ObservableObject {
    @Published var product: ProductVariant?
    @Published var isLoading = false

    private var pollingTimer: Timer?
    private let repository: ProductDetailRepository

    init(variantId: String, repository: ProductDetailRepository) {
        self.repository = repository
        loadInitial(variantId: variantId)
        startPolling(variantId: variantId)
    }

    func startPolling(variantId: String) {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.refresh(variantId: variantId)
        }
    }

    deinit {
        pollingTimer?.invalidate()
    }
}
```

---

## Summary & Key Takeaways

### Production-Ready Features

1. ✅ **HTTP 304 Caching** - 98% bandwidth reduction during polling
2. ✅ **Metadata-Only Storage** - 100 bytes vs 50KB
3. ✅ **Real-Time Polling** - 30-second updates with 304 optimization
4. ✅ **Dual-API Merge** - Combine variant + product data
5. ✅ **Per-Product State** - AutoDisposeFamily pattern
6. ✅ **Auto-Cleanup** - Timer disposal on navigation
7. ✅ **Guest Mode Support** - Limited functionality
8. ✅ **Stock Tracking** - Real-time inventory

---

### Replication Checklist

- [ ] Create domain entities with Equatable
- [ ] Define repository interface
- [ ] Implement remote data source with conditional requests
- [ ] Implement local data source (metadata-only)
- [ ] Create repository with merge logic
- [ ] Build state model with status enum
- [ ] Implement controller with polling
- [ ] Add wishlist integration
- [ ] Add cart integration
- [ ] Implement rating system
- [ ] Write unit tests
- [ ] Test 304 scenarios
- [ ] Test polling behavior
- [ ] Performance testing

---

**Last Updated:** 2026-01-17
**Version:** 1.0
**Backend API:** Django REST at `http://156.67.104.149:8080`

# Coupon Management Backend Documentation

## Table of Contents
1. [Overview](#overview)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Repository Implementation](#repository-implementation)
5. [State Management](#state-management)
6. [Coupon Validation Logic](#coupon-validation-logic)
7. [Discount Calculation](#discount-calculation)
8. [Integration with Cart/Checkout](#integration-with-cartcheckout)
9. [Payment Flow with Coupon](#payment-flow-with-coupon)
10. [HTTP 304 Optimization](#http-304-optimization)
11. [Complete Implementation Guide](#complete-implementation-guide)

---

## Overview

The coupon management system enables users to browse available discount coupons, apply them to their cart, and receive automatic discounts during checkout. The system uses HTTP 304 conditional requests to optimize bandwidth and implements 30-second polling for real-time coupon availability.

### Key Features
- ✅ Browse available coupons with real-time updates
- ✅ Client-side coupon validation (date range, usage limit)
- ✅ Automatic discount calculation
- ✅ Integration with Razorpay payment flow
- ✅ HTTP 304 optimization for bandwidth savings (85% reduction)
- ✅ 30-second polling with screen-aware pausing
- ✅ Metadata-only caching (stores ~100 bytes vs 5-10KB)

---

## API Endpoints

### Base URL
```
http://104.225.154.252:8001/api/order/v1/
```

### Endpoint Summary

| Operation | HTTP Method | Endpoint | Description |
|-----------|------------|----------|-------------|
| **List Coupons** | GET | `/api/order/v1/coupons/` | Fetch available coupons |
| **Apply Coupon** | PATCH | `/api/order/v1/checkouts/{id}/` | Apply coupon to checkout |
| **Initiate Payment** | POST | `/api/order/v1/checkout/` | Create order with coupon |
| **Verify Payment** | POST | `/api/order/v1/payment/verify/` | Verify Razorpay signature |

---

### 1. List Available Coupons

**Endpoint:** `GET /api/order/v1/coupons/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
If-Modified-Since: Mon, 20 Jan 2025 10:00:00 GMT  # Optional for 304 optimization
If-None-Match: "etag-value"                         # Optional for 304 optimization
```

**Query Parameters:** None

**Response (200 OK):**
```json
{
  "count": 3,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "WELCOME10",
      "description": "Get 10% off on your first order",
      "discount_percentage": "10.00",
      "limit": 100,
      "usage": 45,
      "start_date": "2025-01-01T00:00:00Z",
      "end_date": "2025-12-31T23:59:59Z",
      "created_at": "2024-12-15T10:00:00Z",
      "updated_at": "2025-01-20T15:30:00Z"
    },
    {
      "id": 2,
      "name": "SAVE20",
      "description": "Save 20% on orders above ₹500",
      "discount_percentage": "20.00",
      "limit": 50,
      "usage": 12,
      "start_date": "2025-01-15T00:00:00Z",
      "end_date": "2025-02-15T23:59:59Z",
      "created_at": "2025-01-10T08:00:00Z",
      "updated_at": "2025-01-20T12:00:00Z"
    },
    {
      "id": 3,
      "name": "FLASH30",
      "description": "Flash sale: 30% off for 24 hours!",
      "discount_percentage": "30.00",
      "limit": 20,
      "usage": 19,
      "start_date": "2025-01-20T00:00:00Z",
      "end_date": "2025-01-21T23:59:59Z",
      "created_at": "2025-01-19T22:00:00Z",
      "updated_at": "2025-01-20T16:00:00Z"
    }
  ]
}
```

**Response (304 Not Modified):**
```
Empty body - indicates cached data is still valid
```

**Response Headers:**
```http
Last-Modified: Mon, 20 Jan 2025 16:00:00 GMT
ETag: "abc123def456"
Content-Type: application/json
```

**Implementation:**
```dart
Future<CouponListRemoteResponse?> fetchCouponList({
  String? ifNoneMatch,
  String? ifModifiedSince,
}) async {
  try {
    final headers = <String, String>{};

    // Add conditional headers for 304 optimization
    if (ifNoneMatch != null) {
      headers['If-None-Match'] = ifNoneMatch;
    }
    if (ifModifiedSince != null) {
      headers['If-Modified-Since'] = ifModifiedSince;
    }

    final response = await _apiClient.get(
      '/api/order/v1/coupons/',
      headers: headers.isNotEmpty ? headers : null,
    );

    // Handle 304 Not Modified
    if (response.statusCode == 304) {
      return null;  // Data unchanged
    }

    // Extract cache headers
    final responseHeaders = response.headers;
    final eTag = responseHeaders.value('etag') ?? responseHeaders.value('ETag');
    final lastModified = responseHeaders.value('last-modified') ??
        responseHeaders.value('Last-Modified');

    return CouponListRemoteResponse(
      couponList: CouponListResponseDto.fromJson(response.data),
      fetchedAt: DateTime.now(),
      eTag: eTag,
      lastModified: lastModified,
    );
  } catch (e) {
    throw NetworkException.fromDio(e as DioException);
  }
}
```

---

### 2. Apply Coupon to Checkout

**Endpoint:** `PATCH /api/order/v1/checkouts/{checkout_id}/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
X-CSRFToken: <csrf_token>
```

**Request Body:**
```json
{
  "coupon": 1
}
```

**Path Parameters:**
- `checkout_id` (integer) - The ID of the checkout session

**Response (200 OK):**
```json
{
  "id": 5,
  "user": 10,
  "coupon": 1,
  "created_at": "2025-01-20T10:00:00Z",
  "updated_at": "2025-01-20T16:30:00Z"
}
```

**Error Response (400 Bad Request):**
```json
{
  "error": "Coupon has expired",
  "code": "COUPON_EXPIRED"
}
```

**Error Response (404 Not Found):**
```json
{
  "error": "Checkout not found",
  "code": "CHECKOUT_NOT_FOUND"
}
```

**Implementation:**
```dart
Future<void> applyCoupon({
  required int checkoutId,
  required int couponId,
}) async {
  try {
    await _apiClient.patch(
      '/api/order/v1/checkouts/$checkoutId/',
      data: {'coupon': couponId},
    );
  } catch (e) {
    throw NetworkException.fromDio(e as DioException);
  }
}
```

---

### 3. Initiate Payment (With Coupon Applied)

**Endpoint:** `POST /api/order/v1/checkout/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
X-CSRFToken: <csrf_token>
```

**Request Body:**
```json
{
  "address_id": 1
}
```

**Note:** The coupon is already applied to the checkout via the previous PATCH endpoint. The backend automatically calculates the discounted amount.

**Response (200 OK):**
```json
{
  "razorpay_order_id": "order_NJ8KVhMx3qZ4aB",
  "amount": 53100,
  "currency": "INR",
  "order_id": "ORD-2025-00123",
  "discount_applied": 5000,
  "coupon_code": "WELCOME10"
}
```

**Response Fields:**
- `razorpay_order_id` (string) - Razorpay order ID for payment
- `amount` (integer) - Final amount in paise (after coupon discount)
- `currency` (string) - Currency code
- `order_id` (string) - Backend order ID
- `discount_applied` (integer) - Discount amount in paise
- `coupon_code` (string) - Applied coupon code

**Implementation:**
```dart
Future<CheckoutResponse> initiatePayment({
  required int addressId,
}) async {
  final response = await _apiClient.post(
    '/api/order/v1/checkout/',
    data: {'address_id': addressId},
  );

  return CheckoutResponse.fromJson(response.data);
}
```

---

### 4. Verify Payment

**Endpoint:** `POST /api/order/v1/payment/verify/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
X-CSRFToken: <csrf_token>
```

**Request Body:**
```json
{
  "razorpay_payment_id": "pay_NJ8LqXr9QmK7Bc",
  "razorpay_order_id": "order_NJ8KVhMx3qZ4aB",
  "razorpay_signature": "9c8d7b6a5f4e3d2c1b0a9f8e7d6c5b4a"
}
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Payment verified successfully",
  "order_id": "ORD-2025-00123",
  "payment_id": "pay_NJ8LqXr9QmK7Bc",
  "amount": 53100,
  "coupon_discount": 5000
}
```

**Implementation:**
```dart
Future<PaymentVerifyResponse> verifyPayment({
  required String razorpayPaymentId,
  required String razorpayOrderId,
  required String razorpaySignature,
}) async {
  final response = await _apiClient.post(
    '/api/order/v1/payment/verify/',
    data: {
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
    },
  );

  return PaymentVerifyResponse.fromJson(response.data);
}
```

---

## Data Models

### 1. Domain Entity - Coupon

**File:** `lib/features/cart/domain/entities/coupon.dart`

```dart
import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  final int id;
  final String name;                      // Coupon code (e.g., "WELCOME10")
  final String description;               // Display text
  final String discountPercentage;        // "10.00" stored as string
  final int limit;                        // Max usage limit
  final int usage;                        // Current usage count
  final DateTime startDate;               // Validity start
  final DateTime endDate;                 // Validity end
  final DateTime createdAt;
  final DateTime updatedAt;

  const Coupon({
    required this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.limit,
    required this.usage,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties for validation
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isAtLimit => usage >= limit;

  bool get isAvailable => isActive && !isAtLimit;

  int get remainingUses => limit - usage;

  double get discountPercentageValue =>
      double.tryParse(discountPercentage) ?? 0.0;

  Coupon copyWith({
    int? id,
    String? name,
    String? description,
    String? discountPercentage,
    int? limit,
    int? usage,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      limit: limit ?? this.limit,
      usage: usage ?? this.usage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        discountPercentage,
        limit,
        usage,
        startDate,
        endDate,
        createdAt,
        updatedAt,
      ];
}
```

---

### 2. Coupon List Response

```dart
class CouponListResponse extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<Coupon> results;

  const CouponListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;

  @override
  List<Object?> get props => [count, next, previous, results];
}
```

---

### 3. Data Transfer Object - CouponDto

**File:** `lib/features/cart/infrastructure/models/coupon_dto.dart`

```dart
class CouponDto {
  final int id;
  final String name;
  final String description;
  final String discountPercentage;
  final int limit;
  final int usage;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CouponDto({
    required this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.limit,
    required this.usage,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CouponDto.fromJson(Map<String, dynamic> json) {
    return CouponDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      discountPercentage: json['discount_percentage'] as String,
      limit: json['limit'] as int,
      usage: json['usage'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount_percentage': discountPercentage,
      'limit': limit,
      'usage': usage,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Coupon toDomain() {
    return Coupon(
      id: id,
      name: name,
      description: description,
      discountPercentage: discountPercentage,
      limit: limit,
      usage: usage,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

---

### 4. Coupon List Response DTO

```dart
class CouponListResponseDto {
  final int count;
  final String? next;
  final String? previous;
  final List<CouponDto> results;

  const CouponListResponseDto({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory CouponListResponseDto.fromJson(Map<String, dynamic> json) {
    return CouponListResponseDto(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((item) => CouponDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  CouponListResponse toDomain() {
    return CouponListResponse(
      count: count,
      next: next,
      previous: previous,
      results: results.map((dto) => dto.toDomain()).toList(),
    );
  }
}
```

---

### 5. Cache Metadata DTO

**File:** `lib/features/cart/infrastructure/data_sources/local/coupon_cache_dto.dart`

```dart
class CouponCacheDto {
  final DateTime lastSyncedAt;
  final String? eTag;
  final String? lastModified;

  const CouponCacheDto({
    required this.lastSyncedAt,
    this.eTag,
    this.lastModified,
  });

  factory CouponCacheDto.fromJson(Map<String, dynamic> json) {
    return CouponCacheDto(
      lastSyncedAt: DateTime.parse(json['lastSyncedAt'] as String),
      eTag: json['eTag'] as String?,
      lastModified: json['lastModified'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastSyncedAt': lastSyncedAt.toIso8601String(),
      'eTag': eTag,
      'lastModified': lastModified,
    };
  }

  bool isFresh(Duration ttl) {
    return DateTime.now().difference(lastSyncedAt) < ttl;
  }

  CouponCacheDto copyWith({
    DateTime? lastSyncedAt,
    String? eTag,
    String? lastModified,
  }) {
    return CouponCacheDto(
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      eTag: eTag ?? this.eTag,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
```

---

### 6. Remote Response with Headers

```dart
class CouponListRemoteResponse {
  final CouponListResponseDto couponList;
  final DateTime fetchedAt;
  final String? eTag;
  final String? lastModified;

  const CouponListRemoteResponse({
    required this.couponList,
    required this.fetchedAt,
    this.eTag,
    this.lastModified,
  });
}
```

---

### 7. Applied Coupon State

```dart
class AppliedCouponState {
  final Coupon? appliedCoupon;
  final double discountAmount;

  const AppliedCouponState({
    this.appliedCoupon,
    this.discountAmount = 0.0,
  });

  bool get hasCoupon => appliedCoupon != null;

  String get couponCode => appliedCoupon?.name ?? '';

  double get discountPercentage {
    if (appliedCoupon == null) return 0.0;
    return double.tryParse(appliedCoupon!.discountPercentage) ?? 0.0;
  }

  AppliedCouponState copyWith({
    Coupon? appliedCoupon,
    double? discountAmount,
  }) {
    return AppliedCouponState(
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}
```

---

## Repository Implementation

### 1. Repository Interface

**File:** `lib/features/cart/domain/repositories/coupon_repository.dart`

```dart
abstract class CouponRepository {
  /// Fetch coupon list with HTTP conditional request optimization
  /// Returns null if server responds with 304 Not Modified
  Future<CouponListResponse?> getCouponList({bool forceRefresh = false});
}
```

---

### 2. Repository Implementation

**File:** `lib/features/cart/infrastructure/repositories/coupon_repository_impl.dart`

```dart
class CouponRepositoryImpl implements CouponRepository {
  final CouponLocalDataSource _localDataSource;
  final CouponRemoteDataSource _remoteDataSource;
  final Duration cacheTTL;

  CouponRepositoryImpl({
    required CouponLocalDataSource localDataSource,
    required CouponRemoteDataSource remoteDataSource,
    this.cacheTTL = const Duration(hours: 1),
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<CouponListResponse?> getCouponList({
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Get cached metadata (ETag, Last-Modified)
      final cachedMetadata = await _localDataSource.getCachedCouponList();

      String? ifNoneMatch;
      String? ifModifiedSince;

      if (!forceRefresh && cachedMetadata != null) {
        ifNoneMatch = cachedMetadata.eTag;
        ifModifiedSince = cachedMetadata.lastModified;
      }

      // 2. Fetch from API with conditional headers
      final remoteResponse = await _remoteDataSource.fetchCouponList(
        ifNoneMatch: ifNoneMatch,
        ifModifiedSince: ifModifiedSince,
      );

      // 3. Handle 304 Not Modified
      if (remoteResponse == null) {
        // Data unchanged - just update TTL
        if (cachedMetadata != null) {
          await _localDataSource.cacheCouponListWithMetadata(
            cachedMetadata.copyWith(lastSyncedAt: DateTime.now()),
          );
        }
        return null;  // Signal: no UI update needed
      }

      // 4. New data (200 OK) - save metadata and return
      final newCacheDto = CouponCacheDto(
        lastSyncedAt: DateTime.now(),
        eTag: remoteResponse.eTag,
        lastModified: remoteResponse.lastModified,
      );

      await _localDataSource.cacheCouponListWithMetadata(newCacheDto);

      return remoteResponse.couponList.toDomain();
    } catch (e) {
      developer.log('CouponList: Error - $e', name: 'CouponRepository');
      rethrow;
    }
  }
}
```

**Key Features:**
- ✅ HTTP 304 optimization with conditional headers
- ✅ Metadata-only caching (stores ~100 bytes)
- ✅ Force refresh option for mutations
- ✅ TTL-based freshness check (1 hour default)
- ✅ Graceful error handling with logging

---

### 3. Remote Data Source

**File:** `lib/features/cart/infrastructure/data_sources/remote/coupon_remote_data_source.dart`

```dart
abstract class CouponRemoteDataSource {
  Future<CouponListRemoteResponse?> fetchCouponList({
    String? ifNoneMatch,
    String? ifModifiedSince,
  });
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiClient _apiClient;

  CouponRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<CouponListRemoteResponse?> fetchCouponList({
    String? ifNoneMatch,
    String? ifModifiedSince,
  }) async {
    try {
      final headers = <String, String>{};

      // Add conditional headers for 304 optimization
      if (ifNoneMatch != null) {
        headers['If-None-Match'] = ifNoneMatch;
      }
      if (ifModifiedSince != null) {
        headers['If-Modified-Since'] = ifModifiedSince;
      }

      final response = await _apiClient.get(
        '/api/order/v1/coupons/',
        options: Options(
          headers: headers.isNotEmpty ? headers : null,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Handle 304 Not Modified
      if (response.statusCode == 304) {
        developer.log('Coupons: 304 Not Modified', name: 'RemoteDataSource');
        return null;
      }

      // Extract cache headers from response
      final responseHeaders = response.headers;
      final eTag = responseHeaders.value('etag') ??
          responseHeaders.value('ETag');
      final lastModified = responseHeaders.value('last-modified') ??
          responseHeaders.value('Last-Modified');

      developer.log(
        'Coupons: 200 OK (eTag: $eTag, lastModified: $lastModified)',
        name: 'RemoteDataSource',
      );

      return CouponListRemoteResponse(
        couponList: CouponListResponseDto.fromJson(response.data),
        fetchedAt: DateTime.now(),
        eTag: eTag,
        lastModified: lastModified,
      );
    } on DioException catch (e) {
      developer.log('Coupons: Error - $e', name: 'RemoteDataSource');
      throw NetworkException.fromDio(e);
    }
  }
}
```

---

### 4. Local Data Source

**File:** `lib/features/cart/infrastructure/data_sources/local/coupon_local_data_source.dart`

```dart
abstract class CouponLocalDataSource {
  Future<CouponCacheDto?> getCachedCouponList();
  Future<void> cacheCouponListWithMetadata(CouponCacheDto cacheDto);
  Future<void> clearCache();
}

class CouponLocalDataSourceImpl implements CouponLocalDataSource {
  static const String _couponListKey = 'coupon:list_meta';
  final Box<dynamic> _box;

  CouponLocalDataSourceImpl({required Box<dynamic> box}) : _box = box;

  @override
  Future<CouponCacheDto?> getCachedCouponList() async {
    try {
      final json = _box.get(_couponListKey);
      if (json == null) return null;
      return CouponCacheDto.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      developer.log('Cache read error: $e', name: 'CouponLocalDS');
      return null;
    }
  }

  @override
  Future<void> cacheCouponListWithMetadata(CouponCacheDto cacheDto) async {
    try {
      await _box.put(_couponListKey, cacheDto.toJson());
      developer.log('Cached coupon metadata', name: 'CouponLocalDS');
    } catch (e) {
      developer.log('Cache write error: $e', name: 'CouponLocalDS');
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _box.delete(_couponListKey);
      developer.log('Cleared coupon cache', name: 'CouponLocalDS');
    } catch (e) {
      developer.log('Cache clear error: $e', name: 'CouponLocalDS');
      rethrow;
    }
  }
}
```

---

## State Management

### 1. Coupon State

**File:** `lib/features/cart/application/states/coupon_state.dart`

```dart
enum CouponStatus {
  initial,
  loading,
  data,
  error,
  empty,
}

class CouponState extends Equatable {
  final CouponStatus status;
  final CouponListResponse? couponList;
  final String? errorMessage;
  final DateTime? lastSyncedAt;
  final bool isRefreshing;
  final DateTime? refreshStartedAt;
  final DateTime? refreshEndedAt;

  const CouponState({
    this.status = CouponStatus.initial,
    this.couponList,
    this.errorMessage,
    this.lastSyncedAt,
    this.isRefreshing = false,
    this.refreshStartedAt,
    this.refreshEndedAt,
  });

  // Computed properties
  bool get isLoading => status == CouponStatus.loading;
  bool get hasData => status == CouponStatus.data && couponList != null;
  bool get hasError => status == CouponStatus.error;
  bool get isEmpty => status == CouponStatus.empty;

  List<Coupon> get coupons => couponList?.results ?? [];

  /// Filter to show only available coupons (active + not at limit)
  List<Coupon> get activeCoupons =>
      coupons.where((c) => c.isAvailable).toList();

  CouponState copyWith({
    CouponStatus? status,
    CouponListResponse? couponList,
    String? errorMessage,
    DateTime? lastSyncedAt,
    bool? isRefreshing,
    DateTime? refreshStartedAt,
    DateTime? refreshEndedAt,
  }) {
    return CouponState(
      status: status ?? this.status,
      couponList: couponList ?? this.couponList,
      errorMessage: errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshStartedAt: refreshStartedAt,
      refreshEndedAt: refreshEndedAt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        couponList,
        errorMessage,
        lastSyncedAt,
        isRefreshing,
        refreshStartedAt,
        refreshEndedAt,
      ];
}
```

---

### 2. Coupon Controller (with 30-Second Polling)

**File:** `lib/features/cart/application/providers/coupon_providers.dart`

```dart
class CouponController extends Notifier<CouponState> {
  static const Duration _pollingInterval = Duration(seconds: 30);

  late CouponRepository _repository;
  bool _initialized = false;
  Timer? _pollingTimer;
  Timer? _indicatorTimer;

  @override
  CouponState build() {
    _repository = ref.watch(couponRepositoryProvider);

    ref.onDispose(_disposeController);
    Future.microtask(_initialize);

    return const CouponState();
  }

  /// Initialize and load data
  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _loadInitial();
    _startPolling();
  }

  /// Load initial data with forceRefresh=true
  Future<void> _loadInitial() async {
    try {
      state = state.copyWith(
        status: CouponStatus.loading,
        isRefreshing: true,
        refreshStartedAt: DateTime.now(),
      );

      final couponList = await _repository.getCouponList(forceRefresh: true);

      if (couponList == null) {
        state = state.copyWith(
          status: CouponStatus.error,
          errorMessage: 'No coupon data available',
          isRefreshing: false,
        );
      } else if (couponList.results.isEmpty) {
        state = state.copyWith(
          status: CouponStatus.empty,
          couponList: couponList,
          isRefreshing: false,
          refreshEndedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: CouponStatus.data,
          couponList: couponList,
          lastSyncedAt: DateTime.now(),
          isRefreshing: false,
          refreshEndedAt: DateTime.now(),
        );
      }
    } catch (e) {
      developer.log('Load initial failed: $e', name: 'CouponController');
      state = state.copyWith(
        status: CouponStatus.error,
        errorMessage: e.toString(),
        isRefreshing: false,
        refreshEndedAt: DateTime.now(),
      );
    }
  }

  /// Manual refresh (user-triggered)
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(
      isRefreshing: true,
      refreshStartedAt: DateTime.now(),
    );

    await _refreshInternal();
  }

  /// Internal refresh with 304 handling
  Future<void> _refreshInternal() async {
    try {
      final couponListResult = await _repository.getCouponList();

      // 304 Not Modified
      if (couponListResult == null) {
        developer.log('Polling: 304 Not Modified', name: 'CouponController');
        state = state.copyWith(
          isRefreshing: false,
          refreshEndedAt: DateTime.now(),
          lastSyncedAt: DateTime.now(),
        );
        _scheduleIndicatorReset();
        return;
      }

      // 200 OK with new data
      developer.log('Polling: 200 OK (UI updated)', name: 'CouponController');

      final newStatus = couponListResult.results.isEmpty
          ? CouponStatus.empty
          : CouponStatus.data;

      state = state.copyWith(
        status: newStatus,
        couponList: couponListResult,
        lastSyncedAt: DateTime.now(),
        isRefreshing: false,
        refreshEndedAt: DateTime.now(),
      );

      _scheduleIndicatorReset();
    } catch (e) {
      developer.log('Polling failed: $e', name: 'CouponController');
      state = state.copyWith(
        status: CouponStatus.error,
        errorMessage: e.toString(),
        isRefreshing: false,
        refreshEndedAt: DateTime.now(),
      );
      _scheduleIndicatorReset();
    }
  }

  /// Register with PollingManager for screen-aware polling
  void _startPolling() {
    PollingManager.instance.registerPoller(
      featureName: 'cart',
      resourceId: 'coupons',
      onResume: _resumePolling,
      onPause: _pausePolling,
    );
  }

  /// Start timer when cart screen becomes active
  void _startPollingTimer() {
    _pollingTimer ??= Timer.periodic(_pollingInterval, (_) async {
      if (state.isRefreshing) return;
      if (!state.hasData && state.status == CouponStatus.loading) return;
      await _refreshInternal();
    });
  }

  /// Resume polling when user navigates back to cart
  void _resumePolling() {
    if (_pollingTimer == null) {
      developer.log('Resuming polling', name: 'CouponController');
      _startPollingTimer();
    }
  }

  /// Pause polling when user navigates away
  void _pausePolling() {
    if (_pollingTimer != null) {
      developer.log('Pausing polling', name: 'CouponController');
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  /// Schedule hiding refresh indicator after 2 seconds
  void _scheduleIndicatorReset() {
    _indicatorTimer?.cancel();
    _indicatorTimer = Timer(const Duration(seconds: 2), () {
      if (state.refreshEndedAt != null) {
        state = state.copyWith(
          refreshStartedAt: null,
          refreshEndedAt: null,
        );
      }
    });
  }

  void _disposeController() {
    PollingManager.instance.unregisterPoller(
      featureName: 'cart',
      resourceId: 'coupons',
    );
    _pollingTimer?.cancel();
    _indicatorTimer?.cancel();
    _initialized = false;
  }
}

// Provider definition
final couponControllerProvider =
    NotifierProvider<CouponController, CouponState>(
  CouponController.new,
);
```

**Key Features:**
- ✅ 30-second automatic polling
- ✅ Screen-aware (pauses when user navigates away)
- ✅ HTTP 304 optimization
- ✅ Refresh indicators with 2-second auto-hide
- ✅ Proper cleanup on dispose

---

### 3. Applied Coupon Controller

**File:** `lib/features/cart/application/providers/applied_coupon_provider.dart`

```dart
class AppliedCouponController extends Notifier<AppliedCouponState> {
  @override
  AppliedCouponState build() => const AppliedCouponState();

  /// Apply a coupon and calculate discount based on item total
  void applyCoupon(Coupon coupon, double itemTotal) {
    final discountPercentage =
        double.tryParse(coupon.discountPercentage) ?? 0.0;
    final discountAmount = itemTotal * (discountPercentage / 100);

    state = AppliedCouponState(
      appliedCoupon: coupon,
      discountAmount: discountAmount,
    );

    developer.log(
      'Applied coupon: ${coupon.name} (${discountPercentage}% = ₹$discountAmount)',
      name: 'AppliedCouponController',
    );
  }

  /// Update discount amount when item total changes
  void updateDiscount(double itemTotal) {
    if (state.appliedCoupon == null) return;

    final discountPercentage =
        double.tryParse(state.appliedCoupon!.discountPercentage) ?? 0.0;
    final discountAmount = itemTotal * (discountPercentage / 100);

    state = state.copyWith(discountAmount: discountAmount);

    developer.log(
      'Updated discount: ₹$discountAmount for total ₹$itemTotal',
      name: 'AppliedCouponController',
    );
  }

  /// Remove applied coupon
  void removeCoupon() {
    developer.log('Removed coupon: ${state.couponCode}', name: 'AppliedCouponController');
    state = const AppliedCouponState();
  }

  /// Calculate discount for a given item total
  double calculateDiscount(double itemTotal) {
    if (state.appliedCoupon == null) return 0.0;
    final discountPercentage =
        double.tryParse(state.appliedCoupon!.discountPercentage) ?? 0.0;
    return itemTotal * (discountPercentage / 100);
  }
}

// Provider definition
final appliedCouponProvider =
    NotifierProvider<AppliedCouponController, AppliedCouponState>(
  AppliedCouponController.new,
);
```

---

### 4. Provider Dependencies

```dart
// Repository dependencies
final couponLocalDataSourceProvider = Provider<CouponLocalDataSource>((ref) {
  final box = Hive.box('cache');
  return CouponLocalDataSourceImpl(box: box);
});

final couponRemoteDataSourceProvider = Provider<CouponRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CouponRemoteDataSourceImpl(apiClient: apiClient);
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  final localDataSource = ref.watch(couponLocalDataSourceProvider);
  final remoteDataSource = ref.watch(couponRemoteDataSourceProvider);
  return CouponRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    cacheTTL: const Duration(hours: 1),
  );
});
```

---

## Coupon Validation Logic

### Client-Side Validation

```dart
class Coupon {
  // Date range validation
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Usage limit validation
  bool get isAtLimit => usage >= limit;

  // Combined availability check
  bool get isAvailable => isActive && !isAtLimit;

  // Remaining uses
  int get remainingUses => limit - usage;
}
```

**Validation Flow:**
```
1. Check startDate <= now < endDate
2. Check usage < limit
3. If both pass: coupon is available
4. Show only available coupons in UI
```

**Example:**
```dart
// Coupon: WELCOME10
// Start: 2025-01-01, End: 2025-12-31
// Limit: 100, Usage: 45

final coupon = Coupon(...);
coupon.isActive;       // true (within date range)
coupon.isAtLimit;      // false (45 < 100)
coupon.isAvailable;    // true
coupon.remainingUses;  // 55
```

---

## Discount Calculation

### Client-Side Calculation

```dart
class AppliedCouponController {
  void applyCoupon(Coupon coupon, double itemTotal) {
    final discountPercentage =
        double.tryParse(coupon.discountPercentage) ?? 0.0;
    final discountAmount = itemTotal * (discountPercentage / 100);

    state = AppliedCouponState(
      appliedCoupon: coupon,
      discountAmount: discountAmount,
    );
  }

  double calculateDiscount(double itemTotal) {
    if (state.appliedCoupon == null) return 0.0;
    final discountPercentage =
        double.tryParse(state.appliedCoupon!.discountPercentage) ?? 0.0;
    return itemTotal * (discountPercentage / 100);
  }
}
```

**Formula:**
```
Discount Amount = Item Total × (Discount Percentage / 100)
```

**Example:**
```dart
Item Total: ₹500
Coupon: WELCOME10 (10%)

Discount = 500 × (10 / 100) = ₹50
Final Amount = 500 - 50 = ₹450
```

---

### Order Total Calculation (with Coupon)

```dart
// In Checkout Screen
final itemTotal = _calculateTotalWithSocketPrices(cartItems, priceUpdates);
final discount = appliedCouponState.hasCoupon
    ? ref.read(appliedCouponProvider.notifier).calculateDiscount(itemTotal)
    : 0.0;

final subtotal = itemTotal - discount;
final gst = subtotal * 0.18;
const deliveryFee = 0.0;
final grandTotal = subtotal + gst + deliveryFee;
```

**Complete Formula:**
```
Item Total:        Sum of (quantity × price) for all items
Discount:          Item Total × (Coupon % / 100)
Subtotal:          Item Total - Discount
GST (18%):         Subtotal × 0.18
Delivery Fee:      Fixed amount (or 0)
Grand Total:       Subtotal + GST + Delivery Fee
```

**Example Breakdown:**
```
Item Total:        ₹500.00
Discount (-10%):   -₹50.00
─────────────────────────
Subtotal:          ₹450.00
GST (18%):         ₹81.00
Delivery Fee:      ₹0.00
─────────────────────────
Grand Total:       ₹531.00
```

---

## Integration with Cart/Checkout

### 1. Checkout Screen - Coupon Display

**File:** `lib/features/cart/presentation/screen/checkout_screen.dart`

```dart
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch applied coupon
    final appliedCouponState = ref.watch(appliedCouponProvider);

    // Watch cart items
    final checkoutState = ref.watch(checkoutLineControllerProvider);
    final cartItems = checkoutState.checkoutLines;

    // Watch real-time price updates
    final priceUpdates = ref.watch(priceUpdatesProvider);

    // Calculate totals
    final itemTotal = _calculateTotalWithSocketPrices(cartItems, priceUpdates);
    final discount = appliedCouponState.hasCoupon
        ? ref.read(appliedCouponProvider.notifier).calculateDiscount(itemTotal)
        : 0.0;
    final gst = (itemTotal - discount) * 0.18;
    const deliveryFee = 0.0;
    final grandTotal = itemTotal - discount + gst + deliveryFee;

    return Scaffold(
      body: Column(
        children: [
          // Order Summary with coupon
          CheckoutOrderSummary(
            itemTotal: itemTotal,
            discount: discount,
            gst: gst,
            deliveryFee: deliveryFee,
            grandTotal: grandTotal,
            appliedCoupon: appliedCouponState.appliedCoupon,
          ),

          // Place Order button
          ElevatedButton(
            onPressed: () => _handlePlaceOrder(
              addressId: selectedAddress.id,
              couponId: appliedCouponState.appliedCoupon?.id,
            ),
            child: Text('Place Order - ₹${grandTotal.toStringAsFixed(0)}'),
          ),
        ],
      ),
    );
  }

  double _calculateTotalWithSocketPrices(
    List<CheckoutLine> items,
    Map<int, double> priceUpdates,
  ) {
    double total = 0.0;
    for (final item in items) {
      final updatedPrice = priceUpdates[item.variant.id] ?? item.variant.price;
      total += item.quantity * updatedPrice;
    }
    return total;
  }

  Future<void> _handlePlaceOrder({
    required int addressId,
    int? couponId,
  }) async {
    final paymentController = ref.read(paymentControllerProvider.notifier);

    await paymentController.initiatePayment(
      addressId: addressId,
      checkoutId: _checkoutId,
      couponId: couponId,
    );
  }
}
```

---

### 2. Checkout Order Summary - Coupon Section

**File:** `lib/features/cart/presentation/components/checkout_order_summary.dart`

```dart
class CheckoutOrderSummary extends ConsumerWidget {
  final double itemTotal;
  final double discount;
  final double gst;
  final double deliveryFee;
  final double grandTotal;
  final Coupon? appliedCoupon;

  const CheckoutOrderSummary({
    required this.itemTotal,
    required this.discount,
    required this.gst,
    required this.deliveryFee,
    required this.grandTotal,
    this.appliedCoupon,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: Column(
        children: [
          // Item total
          _buildRow('Item Total', '₹${itemTotal.toStringAsFixed(0)}'),

          // Coupon section
          _buildApplyCouponSection(context, ref),

          // Discount (if applied)
          if (appliedCoupon != null)
            _buildRow(
              'Discount (${appliedCoupon!.discountPercentage}%)',
              '-₹${discount.toStringAsFixed(0)}',
              color: AppColors.couponGreen,
            ),

          // GST
          _buildRow('GST (18%)', '₹${gst.toStringAsFixed(0)}'),

          // Delivery fee
          _buildRow('Delivery Fee', deliveryFee > 0 ? '₹$deliveryFee' : 'Free'),

          Divider(),

          // Grand total
          _buildRow(
            'Grand Total',
            '₹${grandTotal.toStringAsFixed(0)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildApplyCouponSection(BuildContext context, WidgetRef ref) {
    final hasCoupon = appliedCoupon != null;

    return InkWell(
      onTap: hasCoupon ? null : () => _navigateToCoupons(context, ref),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasCoupon ? AppColors.couponGreen : AppColors.grey,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_offer,
              color: hasCoupon ? AppColors.couponGreen : AppColors.grey,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),

            if (hasCoupon) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                          text: appliedCoupon!.name,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.couponGreen,
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.couponGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: AppText(
                            text: 'APPLIED',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.couponGreen,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      text: 'You saved ₹${discount.toStringAsFixed(0)} on this order!',
                      fontSize: 12.sp,
                      color: AppColors.couponGreen,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(appliedCouponProvider.notifier).removeCoupon();
                },
                child: Icon(Icons.close, color: AppColors.grey, size: 20.sp),
              ),
            ] else ...[
              Expanded(
                child: AppText(
                  text: 'APPLY COUPON',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16.sp),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToCoupons(BuildContext context, WidgetRef ref) async {
    // Navigate to coupons screen
    final selectedCouponCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CouponsScreen()),
    );

    // Apply selected coupon
    if (selectedCouponCode != null) {
      final couponState = ref.read(couponControllerProvider);
      final selectedCoupon = couponState.coupons.firstWhere(
        (c) => c.name == selectedCouponCode,
      );

      final currentItemTotal = itemTotal;

      ref
          .read(appliedCouponProvider.notifier)
          .applyCoupon(selectedCoupon, currentItemTotal);
    }
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: label,
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
          AppText(
            text: value,
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ],
      ),
    );
  }
}
```

---

### 3. Coupons Screen - Browse & Select

**File:** `lib/features/cart/presentation/screen/coupons_screen.dart`

```dart
class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch coupon state (with 30-second polling)
    final couponState = ref.watch(couponControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Apply Coupon')),
      body: _buildBody(couponState),
    );
  }

  Widget _buildBody(CouponState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'Failed to load coupons'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                ref.read(couponControllerProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return const Center(child: Text('No coupons available'));
    }

    // Show only active/available coupons
    final availableCoupons = state.activeCoupons;

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: availableCoupons.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final coupon = availableCoupons[index];
        return CouponCard(
          coupon: coupon,
          onApply: () => _applyCoupon(coupon),
        );
      },
    );
  }

  Future<void> _applyCoupon(Coupon coupon) async {
    // Show applying animation
    await _showApplyingBottomSheet(coupon.name);

    if (mounted) {
      // Return selected coupon code to checkout screen
      Navigator.pop(context, coupon.name);
    }
  }

  Future<void> _showApplyingBottomSheet(String couponCode) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text('Applying $couponCode...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pop(context);
  }
}
```

---

### 4. Coupon Card Component

**File:** `lib/features/cart/presentation/components/coupen_card.dart`

```dart
class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback onApply;

  const CouponCard({
    required this.coupon,
    required this.onApply,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.couponGreen),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: AppColors.couponGreen),
              SizedBox(width: 8.w),
              AppText(
                text: coupon.name,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.couponGreen,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.couponGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: AppText(
                  text: '${coupon.discountPercentage}% OFF',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.couponGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AppText(
            text: coupon.description,
            fontSize: 14.sp,
            color: AppColors.grey,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 14.sp, color: AppColors.grey),
              SizedBox(width: 4.w),
              AppText(
                text: 'Valid till ${_formatDate(coupon.endDate)}',
                fontSize: 12.sp,
                color: AppColors.grey,
              ),
              Spacer(),
              AppText(
                text: '${coupon.remainingUses} left',
                fontSize: 12.sp,
                color: AppColors.grey,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.couponGreen,
              ),
              child: const Text('APPLY'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

---

## Payment Flow with Coupon

### Complete Flow Diagram

```
1. User adds items to cart
2. User navigates to checkout
3. User taps "APPLY COUPON"
4. Navigate to CouponsScreen
   └─> Shows list of available coupons (filtered by isAvailable)
5. User selects a coupon
6. Apply coupon to AppliedCouponController
   └─> Calculate discount amount
   └─> Update checkout order summary
7. User taps "Place Order"
8. PaymentController.initiatePayment() called
9. If coupon applied:
   └─> Call OrderDataSource.applyCoupon(checkoutId, couponId)
   └─> Server validates coupon and applies discount
10. Call OrderDataSource.initiatePayment(addressId)
    └─> Server creates order with discounted amount
    └─> Server creates Razorpay order
    └─> Returns CheckoutResponse with razorpayOrderId
11. Launch Razorpay SDK with order details
12. User completes payment
13. Razorpay returns payment signature
14. Call OrderDataSource.verifyPayment()
    └─> Server verifies signature
    └─> Order confirmed
15. Navigate to order confirmation screen
```

---

### Payment Controller Implementation

**File:** `lib/features/cart/application/providers/payment_provider.dart`

```dart
class PaymentController extends Notifier<PaymentState> {
  late final OrderDataSource _orderDataSource;

  @override
  PaymentState build() {
    _orderDataSource = ref.watch(orderDataSourceProvider);
    return const PaymentState.initial();
  }

  Future<void> initiatePayment({
    required int addressId,
    int? checkoutId,
    int? couponId,
  }) async {
    try {
      state = const PaymentState.loading();

      // Step 1: Apply coupon if provided
      if (couponId != null && checkoutId != null) {
        state = const PaymentState.applyingCoupon();

        await _orderDataSource.applyCoupon(
          checkoutId: checkoutId,
          couponId: couponId,
        );

        developer.log('Coupon applied: $couponId', name: 'PaymentController');
      }

      // Step 2: Initiate payment (server applies discount)
      final checkoutResponse = await _orderDataSource.initiatePayment(
        addressId: addressId,
      );

      developer.log(
        'Payment initiated: ${checkoutResponse.razorpayOrderId}, '
        'Amount: ₹${checkoutResponse.amount / 100}',
        name: 'PaymentController',
      );

      state = PaymentState.razorpayOrderCreated(
        razorpayOrderId: checkoutResponse.razorpayOrderId,
        amount: checkoutResponse.amount,
        currency: checkoutResponse.currency,
        orderId: checkoutResponse.orderId,
      );

      // Step 3: Launch Razorpay SDK
      await _launchRazorpay(checkoutResponse);
    } catch (e) {
      developer.log('Payment initiation failed: $e', name: 'PaymentController');
      state = PaymentState.error(e.toString());
    }
  }

  Future<void> _launchRazorpay(CheckoutResponse response) async {
    final razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    final options = {
      'key': AppConfig.razorpayKey,
      'amount': response.amount,
      'currency': response.currency,
      'name': 'Grocery App',
      'order_id': response.razorpayOrderId,
      'prefill': {'email': 'user@example.com'},
    };

    razorpay.open(options);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      state = const PaymentState.verifying();

      // Verify payment signature
      final verifyResponse = await _orderDataSource.verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
      );

      developer.log('Payment verified: ${verifyResponse.orderId}', name: 'PaymentController');

      state = PaymentState.success(verifyResponse.orderId);
    } catch (e) {
      developer.log('Payment verification failed: $e', name: 'PaymentController');
      state = PaymentState.error(e.toString());
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    developer.log('Payment failed: ${response.message}', name: 'PaymentController');
    state = PaymentState.error(response.message ?? 'Payment failed');
  }
}
```

---

## HTTP 304 Optimization

### Bandwidth Savings Analysis

**Traditional Approach (No Caching):**
```
Request: GET /api/order/v1/coupons/
Response: 200 OK (5-10KB)

Every 30 seconds:
- 120 requests/hour
- 120 × 7.5KB (average) = 900KB/hour
- 21.6MB/day of bandwidth
```

**Metadata-Only + HTTP 304 Optimization:**
```
Initial Request:
GET /api/order/v1/coupons/
Response: 200 OK (5-10KB)
Headers: ETag: "abc123", Last-Modified: Mon, 20 Jan 2025 10:00:00 GMT

Store metadata: ~100 bytes (eTag, lastModified, lastSyncedAt)

Subsequent Requests (if data unchanged):
GET /api/order/v1/coupons/
If-None-Match: "abc123"
If-Modified-Since: Mon, 20 Jan 2025 10:00:00 GMT
Response: 304 Not Modified (~1KB)

Every 30 seconds (assuming 1 change per hour):
- 119 × 1KB (304 responses) = 119KB
- 1 × 7.5KB (200 response) = 7.5KB
- Total: 126.5KB/hour
- 3MB/day of bandwidth

Savings: 86% bandwidth reduction
```

---

### Implementation Details

**1. Store Metadata (Not Data):**
```dart
// Cache only headers, not coupon list
class CouponCacheDto {
  final DateTime lastSyncedAt;  // ~20 bytes
  final String? eTag;            // ~40 bytes
  final String? lastModified;    // ~40 bytes
  // Total: ~100 bytes
}

// Coupon data stays in Riverpod state (in-memory)
```

**2. Conditional Request:**
```dart
final headers = <String, String>{};
if (cachedMetadata != null) {
  headers['If-None-Match'] = cachedMetadata.eTag;
  headers['If-Modified-Since'] = cachedMetadata.lastModified;
}

final response = await _apiClient.get(
  '/api/order/v1/coupons/',
  headers: headers,
);
```

**3. Handle 304 Response:**
```dart
if (response.statusCode == 304) {
  // Data unchanged - no UI update
  return null;
}

// 200 OK - new data
return CouponListRemoteResponse(...);
```

---

## Complete Implementation Guide

### Step 1: Set Up Domain Layer

**1.1 Create Coupon Entity**

```dart
// lib/features/cart/domain/entities/coupon.dart

import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  final int id;
  final String name;
  final String description;
  final String discountPercentage;
  final int limit;
  final int usage;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Coupon({
    required this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.limit,
    required this.usage,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isAtLimit => usage >= limit;
  bool get isAvailable => isActive && !isAtLimit;
  int get remainingUses => limit - usage;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        discountPercentage,
        limit,
        usage,
        startDate,
        endDate,
        createdAt,
        updatedAt,
      ];
}
```

**1.2 Create Repository Interface**

```dart
// lib/features/cart/domain/repositories/coupon_repository.dart

abstract class CouponRepository {
  Future<CouponListResponse?> getCouponList({bool forceRefresh = false});
}
```

---

### Step 2: Set Up Infrastructure Layer

**2.1 Create CouponDto**

```dart
// lib/features/cart/infrastructure/models/coupon_dto.dart

class CouponDto {
  final int id;
  final String name;
  final String description;
  final String discountPercentage;
  final int limit;
  final int usage;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CouponDto.fromJson(Map<String, dynamic> json) {
    return CouponDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      discountPercentage: json['discount_percentage'] as String,
      limit: json['limit'] as int,
      usage: json['usage'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Coupon toDomain() {
    return Coupon(
      id: id,
      name: name,
      description: description,
      discountPercentage: discountPercentage,
      limit: limit,
      usage: usage,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

**2.2 Implement Data Sources**

```dart
// Remote Data Source
class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiClient _apiClient;

  Future<CouponListRemoteResponse?> fetchCouponList({
    String? ifNoneMatch,
    String? ifModifiedSince,
  }) async {
    final headers = <String, String>{};
    if (ifNoneMatch != null) headers['If-None-Match'] = ifNoneMatch;
    if (ifModifiedSince != null) headers['If-Modified-Since'] = ifModifiedSince;

    final response = await _apiClient.get(
      '/api/order/v1/coupons/',
      headers: headers.isNotEmpty ? headers : null,
    );

    if (response.statusCode == 304) return null;

    return CouponListRemoteResponse(
      couponList: CouponListResponseDto.fromJson(response.data),
      fetchedAt: DateTime.now(),
      eTag: response.headers.value('etag'),
      lastModified: response.headers.value('last-modified'),
    );
  }
}

// Local Data Source
class CouponLocalDataSourceImpl implements CouponLocalDataSource {
  final Box<dynamic> _box;

  Future<CouponCacheDto?> getCachedCouponList() async {
    final json = _box.get('coupon:list_meta');
    if (json == null) return null;
    return CouponCacheDto.fromJson(json);
  }

  Future<void> cacheCouponListWithMetadata(CouponCacheDto dto) async {
    await _box.put('coupon:list_meta', dto.toJson());
  }
}
```

**2.3 Implement Repository**

```dart
class CouponRepositoryImpl implements CouponRepository {
  final CouponLocalDataSource _localDataSource;
  final CouponRemoteDataSource _remoteDataSource;

  Future<CouponListResponse?> getCouponList({bool forceRefresh = false}) async {
    final cachedMetadata = await _localDataSource.getCachedCouponList();

    final remoteResponse = await _remoteDataSource.fetchCouponList(
      ifNoneMatch: forceRefresh ? null : cachedMetadata?.eTag,
      ifModifiedSince: forceRefresh ? null : cachedMetadata?.lastModified,
    );

    if (remoteResponse == null) {
      // 304 Not Modified
      if (cachedMetadata != null) {
        await _localDataSource.cacheCouponListWithMetadata(
          cachedMetadata.copyWith(lastSyncedAt: DateTime.now()),
        );
      }
      return null;
    }

    // 200 OK - save metadata
    await _localDataSource.cacheCouponListWithMetadata(
      CouponCacheDto(
        lastSyncedAt: DateTime.now(),
        eTag: remoteResponse.eTag,
        lastModified: remoteResponse.lastModified,
      ),
    );

    return remoteResponse.couponList.toDomain();
  }
}
```

---

### Step 3: Set Up Application Layer

**3.1 Create States**

```dart
// Coupon State
enum CouponStatus { initial, loading, data, error, empty }

class CouponState {
  final CouponStatus status;
  final CouponListResponse? couponList;
  final String? errorMessage;
  final bool isRefreshing;

  List<Coupon> get coupons => couponList?.results ?? [];
  List<Coupon> get activeCoupons => coupons.where((c) => c.isAvailable).toList();
}

// Applied Coupon State
class AppliedCouponState {
  final Coupon? appliedCoupon;
  final double discountAmount;

  bool get hasCoupon => appliedCoupon != null;
}
```

**3.2 Create Controllers**

```dart
// Coupon Controller (with polling)
class CouponController extends Notifier<CouponState> {
  Timer? _pollingTimer;

  @override
  CouponState build() {
    _initialize();
    return const CouponState();
  }

  Future<void> _initialize() async {
    await _loadInitial();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _refreshInternal();
    });
  }

  Future<void> _refreshInternal() async {
    final result = await _repository.getCouponList();
    if (result == null) return; // 304 Not Modified
    state = state.copyWith(couponList: result);
  }
}

// Applied Coupon Controller
class AppliedCouponController extends Notifier<AppliedCouponState> {
  void applyCoupon(Coupon coupon, double itemTotal) {
    final discount = itemTotal * (double.parse(coupon.discountPercentage) / 100);
    state = AppliedCouponState(appliedCoupon: coupon, discountAmount: discount);
  }

  void removeCoupon() {
    state = const AppliedCouponState();
  }
}
```

---

### Step 4: Use in UI

**4.1 Checkout Screen**

```dart
class CheckoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appliedCoupon = ref.watch(appliedCouponProvider);
    final itemTotal = _calculateTotal();
    final discount = appliedCoupon.discountAmount;
    final grandTotal = itemTotal - discount + (itemTotal - discount) * 0.18;

    return Scaffold(
      body: Column(
        children: [
          CheckoutOrderSummary(
            itemTotal: itemTotal,
            discount: discount,
            grandTotal: grandTotal,
            appliedCoupon: appliedCoupon.appliedCoupon,
          ),
          ElevatedButton(
            onPressed: () => _placeOrder(appliedCoupon.appliedCoupon?.id),
            child: Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
```

**4.2 Coupons Screen**

```dart
class CouponsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponState = ref.watch(couponControllerProvider);
    final availableCoupons = couponState.activeCoupons;

    return ListView.builder(
      itemCount: availableCoupons.length,
      itemBuilder: (context, index) {
        final coupon = availableCoupons[index];
        return CouponCard(
          coupon: coupon,
          onApply: () {
            Navigator.pop(context, coupon.name);
          },
        );
      },
    );
  }
}
```

---

## Summary

This coupon management system provides:

1. **HTTP 304 Optimization**: 85% bandwidth savings with conditional requests
2. **Client-Side Validation**: Date range and usage limit checks
3. **Automatic Discount Calculation**: Real-time discount updates
4. **Screen-Aware Polling**: 30-second refresh that pauses when inactive
5. **Clean Architecture**: Separation of concerns across layers
6. **Integration with Payment**: Seamless Razorpay integration with coupon discount
7. **Metadata-Only Caching**: Stores ~100 bytes instead of 5-10KB

Follow this guide to implement the exact coupon logic in your new project while changing only the UI layer.

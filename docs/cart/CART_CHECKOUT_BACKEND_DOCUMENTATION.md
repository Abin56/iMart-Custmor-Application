# Cart & Checkout Feature - Backend Implementation Guide

> **Purpose:** Complete backend implementation documentation for the Cart & Checkout feature. This guide enables replication of debounced quantity updates, HTTP 304 polling, optimistic updates, and Razorpay payment integration in other projects with different UI frameworks.

---

## Table of Contents

1. [Overview](#overview)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Repository Pattern](#repository-pattern)
5. [State Management](#state-management)
6. [Cart Operations](#cart-operations)
7. [Debounced Quantity Updates](#debounced-quantity-updates)
8. [HTTP 304 Polling](#http-304-polling)
9. [Optimistic Updates](#optimistic-updates)
10. [Stock Validation](#stock-validation)
11. [Coupon System](#coupon-system)
12. [Address Management](#address-management)
13. [Payment Integration](#payment-integration)
14. [Guest Mode Handling](#guest-mode-handling)
15. [Error Handling](#error-handling)
16. [Replication Guide](#replication-guide)

---

## Overview

The Cart & Checkout feature implements a **production-grade e-commerce cart system** with:

- ✅ **Debounced Updates** - 150ms debounce for rapid quantity changes
- ✅ **HTTP 304 Polling** - 30-second updates with bandwidth optimization
- ✅ **Optimistic Updates** - Instant UI feedback with automatic rollback
- ✅ **Delta-Based API** - Send only quantity changes, not absolute values
- ✅ **Stock Validation** - Real-time inventory checks
- ✅ **Coupon System** - Percentage-based discounts
- ✅ **Address Management** - CRUD with conditional requests
- ✅ **Razorpay Integration** - Full payment flow with verification
- ✅ **Guest Mode Support** - Local state without persistence
- ✅ **Processing Indicators** - Prevent double-submission

**Tech Stack:**
- HTTP Client: Dio
- Local Storage: Hive (metadata only)
- State Management: Riverpod (Notifier)
- Payment Gateway: Razorpay Flutter SDK
- Architecture: Clean Architecture with Repository Pattern

---

## API Endpoints

### Base URL
```
http://156.67.104.149:8012
```

### Endpoint Summary

| Method | Endpoint | Description | Auth | Cache Support |
|--------|----------|-------------|------|---------------|
| GET | `/api/order/v1/checkout-lines/` | Fetch cart items | ✅ | ✅ (ETag, If-Modified-Since) |
| POST | `/api/order/v1/checkout-lines/` | Add item to cart | ✅ | - |
| PATCH | `/api/order/v1/checkout-lines/{id}/` | Update quantity (delta) | ✅ | - |
| DELETE | `/api/order/v1/checkout-lines/{id}/` | Remove item from cart | ✅ | - |
| GET | `/api/order/v1/coupons/` | List available coupons | ✅ | ✅ |
| GET | `/api/auth/v1/address/` | List addresses | ✅ | ✅ |
| POST | `/api/auth/v1/address/` | Create address | ✅ | - |
| PATCH | `/api/auth/v1/address/{id}/` | Update/Select address | ✅ | - |
| DELETE | `/api/auth/v1/address/{id}/` | Delete address | ✅ | - |
| POST | `/api/order/v1/checkouts/` | Create checkout | ✅ | - |
| PATCH | `/api/order/v1/checkouts/{id}/` | Apply coupon | ✅ | - |
| POST | `/api/order/v1/payment/initiate/` | Create Razorpay order | ✅ | - |
| POST | `/api/order/v1/payment/verify/` | Verify payment signature | ✅ | - |

---

### 1. Fetch Cart Items

**Endpoint:** `GET /api/order/v1/checkout-lines/`

**Purpose:** Get all cart items with product details

**Supports HTTP 304:** ✅ Yes

**Headers (Request):**
```http
GET /api/order/v1/checkout-lines/
Cookie: sessionid=xyz123
X-CSRFToken: abc456
If-Modified-Since: Wed, 17 Jan 2024 10:00:00 GMT
If-None-Match: "abc123def456"
```

**Response (304 Not Modified):**
```http
HTTP/1.1 304 Not Modified
ETag: "abc123def456"
Last-Modified: Wed, 17 Jan 2024 10:00:00 GMT
```
> No body when data unchanged

**Response (200 OK):**
```json
{
  "count": 3,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "checkout": 5,
      "product_variant_id": 42,
      "quantity": 2,
      "product_variant_details": {
        "id": 42,
        "sku": "APPLE-RED-1KG",
        "name": "Red Apple",
        "product_id": 10,
        "price": "299.00",
        "discounted_price": "249.00",
        "track_inventory": true,
        "current_quantity": 150,
        "quantity_limit_per_customer": 10,
        "is_preorder": false,
        "preorder_end_date": null,
        "preorder_global_threshold": 0,
        "images": [
          {
            "id": 1,
            "image": "/media/products/apple.jpg",
            "alt": "Red Apple"
          }
        ]
      }
    }
  ]
}
```

**Implementation:**
```dart
Future<CheckoutLinesRemoteResponse?> fetchCheckoutLines({
  String? ifNoneMatch,
  String? ifModifiedSince,
}) async {
  final headers = <String, String>{};

  if (ifNoneMatch != null) {
    headers['If-None-Match'] = ifNoneMatch;
  }
  if (ifModifiedSince != null) {
    headers['If-Modified-Since'] = ifModifiedSince;
  }

  final response = await _apiClient.get(
    '/api/order/v1/checkout-lines/',
    headers: headers.isNotEmpty ? headers : null,
  );

  // Handle 304 Not Modified
  if (response.statusCode == 304) {
    return null;
  }

  return CheckoutLinesRemoteResponse(
    checkoutLines: CheckoutLinesResponseDto.fromJson(response.data),
    eTag: response.headers.value('etag'),
    lastModified: response.headers.value('last-modified'),
    fetchedAt: DateTime.now(),
  );
}
```

---

### 2. Add Item to Cart

**Endpoint:** `POST /api/order/v1/checkout-lines/`

**Purpose:** Add new item or increase quantity if exists

**Request:**
```http
POST /api/order/v1/checkout-lines/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "product_variant_id": 42,
  "quantity": 1
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "checkout": 5,
  "product_variant_id": 42,
  "quantity": 1,
  "product_variant_details": {
    "id": 42,
    "sku": "APPLE-RED-1KG",
    "name": "Red Apple",
    "price": "299.00",
    "discounted_price": "249.00",
    "current_quantity": 150
  }
}
```

**Error (400 Bad Request - Insufficient Stock):**
```json
{
  "quantity": ["Insufficient stock. Only 5 items available."]
}
```

**Implementation:**
```dart
Future<CheckoutLineDto> addToCart({
  required int productVariantId,
  required int quantity,
}) async {
  try {
    final response = await _apiClient.post(
      '/api/order/v1/checkout-lines/',
      data: {
        'product_variant_id': productVariantId,
        'quantity': quantity,
      },
    );

    return CheckoutLineDto.fromJson(response.data);
  } on NetworkException catch (error) {
    // Handle stock validation error
    if (error.statusCode == 400 && error.body is Map) {
      final body = error.body as Map<String, dynamic>;
      if (body.containsKey('quantity')) {
        throw InsufficientStockException(body['quantity'].first);
      }
    }
    rethrow;
  }
}
```

---

### 3. Update Quantity (Delta-Based)

**Endpoint:** `PATCH /api/order/v1/checkout-lines/{lineId}/`

**Purpose:** Update cart item quantity using delta (increment/decrement)

**Important:** The API expects a **delta value**, not an absolute quantity!

**Request (Increment by 2):**
```http
PATCH /api/order/v1/checkout-lines/1/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "product_variant_id": 42,
  "quantity": 2
}
```
> This ADDS 2 to the current quantity

**Request (Decrement by 1):**
```http
PATCH /api/order/v1/checkout-lines/1/
Content-Type: application/json

{
  "product_variant_id": 42,
  "quantity": -1
}
```
> This REMOVES 1 from the current quantity

**Response (200 OK):**
```json
{
  "id": 1,
  "checkout": 5,
  "product_variant_id": 42,
  "quantity": 4,
  "product_variant_details": {
    "id": 42,
    "name": "Red Apple",
    "price": "299.00",
    "current_quantity": 148
  }
}
```

**Error (400 Bad Request - Exceeds Limit):**
```json
{
  "quantity": ["Cannot exceed limit of 10 items per customer."]
}
```

**Implementation:**
```dart
Future<CheckoutLineDto> updateQuantity({
  required int lineId,
  required int productVariantId,
  required int quantity,  // Delta value!
}) async {
  try {
    final response = await _apiClient.patch(
      '/api/order/v1/checkout-lines/$lineId/',
      data: {
        'product_variant_id': productVariantId,
        'quantity': quantity,  // Send delta
      },
    );

    return CheckoutLineDto.fromJson(response.data);
  } on NetworkException catch (error) {
    if (error.statusCode == 400 && error.body is Map) {
      final body = error.body as Map<String, dynamic>;
      if (body.containsKey('quantity')) {
        throw InsufficientStockException(body['quantity'].first);
      }
    }
    rethrow;
  }
}
```

---

### 4. Remove Item from Cart

**Endpoint:** `DELETE /api/order/v1/checkout-lines/{lineId}/`

**Request:**
```http
DELETE /api/order/v1/checkout-lines/1/
Cookie: sessionid=xyz123
X-CSRFToken: abc456
```

**Response:**
```http
HTTP/1.1 204 No Content
```

**Implementation:**
```dart
Future<void> deleteCheckoutLine(int lineId) async {
  await _apiClient.delete('/api/order/v1/checkout-lines/$lineId/');
}
```

---

### 5. List Coupons

**Endpoint:** `GET /api/order/v1/coupons/`

**Supports HTTP 304:** ✅ Yes

**Request:**
```http
GET /api/order/v1/coupons/
Cookie: sessionid=xyz123
If-Modified-Since: Wed, 17 Jan 2024 10:00:00 GMT
If-None-Match: "coupon123"
```

**Response:**
```json
{
  "count": 2,
  "results": [
    {
      "id": 1,
      "name": "WELCOME10",
      "description": "10% off on first order",
      "discount_percentage": "10.00",
      "limit": 100,
      "usage": 45,
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-12-31T23:59:59Z"
    },
    {
      "id": 2,
      "name": "SAVE20",
      "description": "20% off on orders above Rs 500",
      "discount_percentage": "20.00",
      "limit": 50,
      "usage": 12,
      "start_date": "2024-01-15T00:00:00Z",
      "end_date": "2024-03-31T23:59:59Z"
    }
  ]
}
```

---

### 6. Address Management

#### List Addresses

**Endpoint:** `GET /api/auth/v1/address/`

**Supports HTTP 304:** ✅ Yes

**Request:**
```http
GET /api/auth/v1/address/
Cookie: sessionid=xyz123
If-Modified-Since: Wed, 17 Jan 2024 10:00:00 GMT
```

**Response:**
```json
{
  "count": 2,
  "results": [
    {
      "id": 1,
      "first_name": "John",
      "last_name": "Doe",
      "street_address_1": "123 Main St",
      "street_address_2": "Apt 4B",
      "city": "Mumbai",
      "state": "Maharashtra",
      "postal_code": "400001",
      "country": "India",
      "latitude": 19.0760,
      "longitude": 72.8777,
      "address_type": "home",
      "selected": true
    },
    {
      "id": 2,
      "first_name": "John",
      "last_name": "Doe",
      "street_address_1": "456 Work Plaza",
      "city": "Mumbai",
      "state": "Maharashtra",
      "postal_code": "400020",
      "country": "India",
      "address_type": "work",
      "selected": false
    }
  ]
}
```

#### Create Address

**Endpoint:** `POST /api/auth/v1/address/`

**Request:**
```http
POST /api/auth/v1/address/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "first_name": "Jane",
  "last_name": "Smith",
  "street_address_1": "789 New St",
  "street_address_2": null,
  "city": "Delhi",
  "state": "Delhi",
  "postal_code": "110001",
  "country": "India",
  "latitude": 28.7041,
  "longitude": 77.1025,
  "address_type": "home"
}
```

**Response (201 Created):**
```json
{
  "id": 3,
  "first_name": "Jane",
  "last_name": "Smith",
  "street_address_1": "789 New St",
  "city": "Delhi",
  "state": "Delhi",
  "postal_code": "110001",
  "country": "India",
  "latitude": 28.7041,
  "longitude": 77.1025,
  "address_type": "home",
  "selected": false
}
```

#### Select Address

**Endpoint:** `PATCH /api/auth/v1/address/{id}/`

**Request:**
```http
PATCH /api/auth/v1/address/1/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "selected": true
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "first_name": "John",
  "last_name": "Doe",
  "street_address_1": "123 Main St",
  "selected": true
}
```

---

### 7. Payment Flow

#### Initiate Payment

**Endpoint:** `POST /api/order/v1/payment/initiate/`

**Purpose:** Create Razorpay order and get order ID

**Request:**
```http
POST /api/order/v1/payment/initiate/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "address_id": 1
}
```

**Response (200 OK):**
```json
{
  "razorpay_order_id": "order_MN2xPQR3S4T5UV",
  "amount": 50000,
  "currency": "INR",
  "order_id": 123
}
```
> Amount is in **paise** (Rs 500.00 = 50000 paise)

#### Verify Payment

**Endpoint:** `POST /api/order/v1/payment/verify/`

**Purpose:** Verify Razorpay signature after payment

**Request:**
```http
POST /api/order/v1/payment/verify/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "razorpay_payment_id": "pay_MN2xPQR3S4T5UV",
  "razorpay_order_id": "order_MN2xPQR3S4T5UV",
  "razorpay_signature": "abc123def456signature"
}
```

**Response (200 OK - Success):**
```json
{
  "success": true,
  "message": "Payment verified successfully",
  "order_id": 123
}
```

**Response (400 Bad Request - Failed):**
```json
{
  "success": false,
  "message": "Invalid signature"
}
```

#### Apply Coupon to Checkout

**Endpoint:** `PATCH /api/order/v1/checkouts/{checkoutId}/`

**Request:**
```http
PATCH /api/order/v1/checkouts/5/
Content-Type: application/json
Cookie: sessionid=xyz123
X-CSRFToken: abc456

{
  "coupon": 1
}
```

**Response (200 OK):**
```json
{
  "id": 5,
  "user": 10,
  "coupon": 1,
  "created_at": "2024-01-17T10:00:00Z"
}
```

---

## Data Models

### Architecture Layers

```
API Response (JSON)
    ↓
DTO (Data Transfer Object)
    ↓
Domain Entity
    ↓
State (Riverpod)
    ↓
UI Layer
```

---

### 1. Domain Entities

#### CheckoutLine (Cart Item)

**File:** `domain/entities/checkout_line.dart`

```dart
class CheckoutLine extends Equatable {
  final int id;
  final int checkout;
  final int productVariantId;
  final int quantity;
  final ProductVariantDetails productVariantDetails;

  const CheckoutLine({
    required this.id,
    required this.checkout,
    required this.productVariantId,
    required this.quantity,
    required this.productVariantDetails,
  });

  // Computed properties
  double get lineTotal =>
      quantity * productVariantDetails.effectivePrice;

  double get lineSavings {
    if (!productVariantDetails.hasDiscount) return 0.0;
    return quantity * (productVariantDetails.priceValue -
                       productVariantDetails.discountedPriceValue);
  }

  @override
  List<Object?> get props => [
    id, checkout, productVariantId, quantity, productVariantDetails
  ];

  CheckoutLine copyWith({
    int? id,
    int? checkout,
    int? productVariantId,
    int? quantity,
    ProductVariantDetails? productVariantDetails,
  }) {
    return CheckoutLine(
      id: id ?? this.id,
      checkout: checkout ?? this.checkout,
      productVariantId: productVariantId ?? this.productVariantId,
      quantity: quantity ?? this.quantity,
      productVariantDetails: productVariantDetails ?? this.productVariantDetails,
    );
  }
}
```

---

#### ProductVariantDetails

**File:** `domain/entities/product_variant_details.dart`

```dart
class ProductVariantDetails extends Equatable {
  final int id;
  final String sku;
  final String name;
  final int productId;

  // Pricing (stored as strings from API)
  final String price;
  final String discountedPrice;

  // Inventory
  final bool trackInventory;
  final int currentQuantity;
  final int quantityLimitPerCustomer;

  // Preorder
  final bool isPreorder;
  final DateTime? preorderEndDate;
  final int preorderGlobalThreshold;

  // Images
  final List<ProductImage> images;

  const ProductVariantDetails({
    required this.id,
    required this.sku,
    required this.name,
    required this.productId,
    required this.price,
    required this.discountedPrice,
    required this.trackInventory,
    required this.currentQuantity,
    required this.quantityLimitPerCustomer,
    required this.isPreorder,
    this.preorderEndDate,
    required this.preorderGlobalThreshold,
    required this.images,
  });

  // Computed properties
  double get priceValue => double.tryParse(price) ?? 0.0;
  double get discountedPriceValue => double.tryParse(discountedPrice) ?? 0.0;

  double get effectivePrice =>
      discountedPriceValue > 0 ? discountedPriceValue : priceValue;

  bool get hasDiscount =>
      discountedPriceValue > 0 && discountedPriceValue < priceValue;

  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((priceValue - discountedPriceValue) / priceValue) * 100;
  }

  bool get inStock => !trackInventory || currentQuantity > 0;

  String? get primaryImageUrl => images.isNotEmpty ? images.first.image : null;

  @override
  List<Object?> get props => [
    id, sku, name, productId, price, discountedPrice,
    trackInventory, currentQuantity, quantityLimitPerCustomer,
    isPreorder, preorderEndDate, preorderGlobalThreshold, images,
  ];
}
```

---

#### CheckoutLinesResponse

**File:** `domain/entities/checkout_lines_response.dart`

```dart
class CheckoutLinesResponse extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<CheckoutLine> results;

  const CheckoutLinesResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  // Aggregated calculations
  double get totalAmount =>
      results.fold(0.0, (sum, line) => sum + line.lineTotal);

  double get totalSavings =>
      results.fold(0.0, (sum, line) => sum + line.lineSavings);

  int get totalItems =>
      results.fold(0, (sum, line) => sum + line.quantity);

  bool get isEmpty => results.isEmpty;

  @override
  List<Object?> get props => [count, next, previous, results];

  CheckoutLinesResponse copyWith({
    int? count,
    String? next,
    String? previous,
    List<CheckoutLine>? results,
  }) {
    return CheckoutLinesResponse(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }
}
```

---

#### Coupon

**File:** `domain/entities/coupon.dart`

```dart
class Coupon extends Equatable {
  final int id;
  final String name;
  final String description;
  final String discountPercentage;  // Stored as string "10.50"
  final int limit;                  // Max usage limit
  final int usage;                  // Current usage count
  final DateTime startDate;
  final DateTime endDate;

  const Coupon({
    required this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.limit,
    required this.usage,
    required this.startDate,
    required this.endDate,
  });

  // Computed properties
  double get discountValue => double.tryParse(discountPercentage) ?? 0.0;

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isAtLimit => usage >= limit;

  bool get isAvailable => isActive && !isAtLimit;

  int get remainingUses => limit - usage;

  @override
  List<Object?> get props => [
    id, name, description, discountPercentage,
    limit, usage, startDate, endDate,
  ];
}
```

---

#### Address

**File:** `domain/entities/address.dart`

```dart
class Address extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String streetAddress1;
  final String? streetAddress2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String addressType;  // 'home', 'work', 'other'
  final bool selected;

  const Address({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.streetAddress1,
    this.streetAddress2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
    required this.addressType,
    required this.selected,
  });

  // Computed properties
  String get fullName => '$firstName $lastName';

  String get formattedAddress {
    final parts = <String>[
      streetAddress1,
      if (streetAddress2 != null && streetAddress2!.isNotEmpty) streetAddress2!,
      if (city != null && city!.isNotEmpty) city!,
      if (state != null && state!.isNotEmpty) state!,
      if (postalCode != null && postalCode!.isNotEmpty) postalCode!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
    id, firstName, lastName, streetAddress1, streetAddress2,
    city, state, postalCode, country, latitude, longitude,
    addressType, selected,
  ];

  Address copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? streetAddress1,
    String? streetAddress2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    String? addressType,
    bool? selected,
  }) {
    return Address(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      streetAddress1: streetAddress1 ?? this.streetAddress1,
      streetAddress2: streetAddress2 ?? this.streetAddress2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressType: addressType ?? this.addressType,
      selected: selected ?? this.selected,
    );
  }
}
```

---

### 2. Data Transfer Objects (DTOs)

#### CheckoutLineDto

**File:** `infrastructure/models/checkout_line_dto.dart`

```dart
class CheckoutLineDto {
  final int id;
  final int checkout;
  final int productVariantId;
  final int quantity;
  final ProductVariantDetailsDto productVariantDetails;

  const CheckoutLineDto({
    required this.id,
    required this.checkout,
    required this.productVariantId,
    required this.quantity,
    required this.productVariantDetails,
  });

  factory CheckoutLineDto.fromJson(Map<String, dynamic> json) {
    return CheckoutLineDto(
      id: json['id'] as int,
      checkout: json['checkout'] as int,
      productVariantId: json['product_variant_id'] as int,
      quantity: json['quantity'] as int,
      productVariantDetails: ProductVariantDetailsDto.fromJson(
        json['product_variant_details'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkout': checkout,
      'product_variant_id': productVariantId,
      'quantity': quantity,
      'product_variant_details': productVariantDetails.toJson(),
    };
  }

  CheckoutLine toEntity() {
    return CheckoutLine(
      id: id,
      checkout: checkout,
      productVariantId: productVariantId,
      quantity: quantity,
      productVariantDetails: productVariantDetails.toEntity(),
    );
  }
}
```

---

#### ProductVariantDetailsDto

```dart
class ProductVariantDetailsDto {
  final int id;
  final String sku;
  final String name;
  final int productId;
  final String price;
  final String discountedPrice;
  final bool trackInventory;
  final int currentQuantity;
  final int quantityLimitPerCustomer;
  final bool isPreorder;
  final DateTime? preorderEndDate;
  final int preorderGlobalThreshold;
  final List<ProductImageDto> images;

  const ProductVariantDetailsDto({
    required this.id,
    required this.sku,
    required this.name,
    required this.productId,
    required this.price,
    required this.discountedPrice,
    required this.trackInventory,
    required this.currentQuantity,
    required this.quantityLimitPerCustomer,
    required this.isPreorder,
    this.preorderEndDate,
    required this.preorderGlobalThreshold,
    required this.images,
  });

  factory ProductVariantDetailsDto.fromJson(Map<String, dynamic> json) {
    return ProductVariantDetailsDto(
      id: json['id'] as int,
      sku: json['sku'] as String,
      name: json['name'] as String,
      productId: json['product_id'] as int,

      // Handle both String and num types
      price: json['price'].toString(),
      discountedPrice: json['discounted_price']?.toString() ?? '0',

      trackInventory: json['track_inventory'] as bool? ?? true,

      // Type coercion for flexible API
      currentQuantity: json['current_quantity'] is int
          ? json['current_quantity'] as int
          : int.tryParse(json['current_quantity']?.toString() ?? '0') ?? 0,

      quantityLimitPerCustomer: json['quantity_limit_per_customer'] as int? ?? 999,

      isPreorder: json['is_preorder'] as bool? ?? false,

      preorderEndDate: json['preorder_end_date'] != null
          ? DateTime.parse(json['preorder_end_date'] as String)
          : null,

      preorderGlobalThreshold: json['preorder_global_threshold'] as int? ?? 0,

      images: (json['images'] as List?)
              ?.map((e) => ProductImageDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'product_id': productId,
      'price': price,
      'discounted_price': discountedPrice,
      'track_inventory': trackInventory,
      'current_quantity': currentQuantity,
      'quantity_limit_per_customer': quantityLimitPerCustomer,
      'is_preorder': isPreorder,
      if (preorderEndDate != null)
        'preorder_end_date': preorderEndDate!.toIso8601String(),
      'preorder_global_threshold': preorderGlobalThreshold,
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  ProductVariantDetails toEntity() {
    return ProductVariantDetails(
      id: id,
      sku: sku,
      name: name,
      productId: productId,
      price: price,
      discountedPrice: discountedPrice,
      trackInventory: trackInventory,
      currentQuantity: currentQuantity,
      quantityLimitPerCustomer: quantityLimitPerCustomer,
      isPreorder: isPreorder,
      preorderEndDate: preorderEndDate,
      preorderGlobalThreshold: preorderGlobalThreshold,
      images: images.map((e) => e.toEntity()).toList(),
    );
  }
}
```

---

### 3. Cache DTOs (Metadata Only)

#### AddressCacheDto

**File:** `infrastructure/data_sources/local/address_cache_dto.dart`

```dart
class AddressCacheDto {
  final DateTime lastSyncedAt;
  final String? eTag;
  final String? lastModified;

  const AddressCacheDto({
    required this.lastSyncedAt,
    this.eTag,
    this.lastModified,
  });

  factory AddressCacheDto.fromJson(Map<String, dynamic> json) {
    return AddressCacheDto(
      lastSyncedAt: DateTime.parse(json['last_synced_at'] as String),
      eTag: json['etag'] as String?,
      lastModified: json['last_modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_synced_at': lastSyncedAt.toIso8601String(),
      if (eTag != null) 'etag': eTag,
      if (lastModified != null) 'last_modified': lastModified,
    };
  }

  bool isStale(Duration ttl) {
    final age = DateTime.now().difference(lastSyncedAt);
    return age > ttl;
  }

  AddressCacheDto copyWith({
    DateTime? lastSyncedAt,
    String? eTag,
    String? lastModified,
  }) {
    return AddressCacheDto(
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      eTag: eTag ?? this.eTag,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
```

**Storage:**
```
Hive Box: AppHiveBoxes.cache
Key: 'address:list_meta'
Value: AddressCacheDto (JSON)
```

**CouponCacheDto** - Same structure with key: `'coupon:list_meta'`

---

## Repository Pattern

### Abstract Interfaces

**File:** `domain/repositories/`

```dart
abstract class CheckoutLineRepository {
  Future<CheckoutLinesResponse?> getCheckoutLines({
    bool forceRefresh = false,
  });

  Future<CheckoutLine> addToCart({
    required int productVariantId,
    required int quantity,
  });

  Future<CheckoutLine> updateQuantity({
    required int lineId,
    required int productVariantId,
    required int quantity,  // Delta value
  });

  Future<void> deleteCheckoutLine(int lineId);
}

abstract class AddressRepository {
  Future<AddressListResponse?> getAddressList({
    bool forceRefresh = false,
  });

  Future<Address> createAddress({...});
  Future<Address> updateAddress({...});
  Future<void> deleteAddress(int id);
  Future<Address> selectAddress(int id);
}

abstract class CouponRepository {
  Future<CouponListResponse?> getCouponList({
    bool forceRefresh = false,
  });
}
```

---

### Implementation

#### AddressRepositoryImpl

**File:** `infrastructure/repositories/address_repository_impl.dart`

```dart
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;
  final AddressLocalDataSource _localDataSource;

  static const Duration _cacheTTL = Duration(hours: 1);

  AddressRepositoryImpl({
    required AddressRemoteDataSource remoteDataSource,
    required AddressLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<AddressListResponse?> getAddressList({
    bool forceRefresh = false,
  }) async {
    try {
      // Get cached metadata (unless forceRefresh)
      AddressCacheDto? cachedMetadata;
      if (!forceRefresh) {
        cachedMetadata = await _localDataSource.getCachedAddressList();

        // Check TTL
        if (cachedMetadata != null && cachedMetadata.isStale(_cacheTTL)) {
          Logger.debug('Address cache metadata stale, clearing');
          cachedMetadata = null;
        }
      }

      // Fetch with conditional headers
      final remoteResponse = await _remoteDataSource.fetchAddressList(
        ifNoneMatch: cachedMetadata?.eTag,
        ifModifiedSince: cachedMetadata?.lastModified,
      );

      // Handle 304 Not Modified
      if (remoteResponse == null) {
        Logger.info('Address list not modified (304)');

        // Update TTL
        await _localDataSource.cacheAddressListWithMetadata(
          cachedMetadata!.copyWith(lastSyncedAt: DateTime.now()),
        );

        return null;  // Signal: no UI update needed
      }

      // New data - save metadata
      await _localDataSource.cacheAddressListWithMetadata(
        AddressCacheDto(
          lastSyncedAt: DateTime.now(),
          eTag: remoteResponse.eTag,
          lastModified: remoteResponse.lastModified,
        ),
      );

      return remoteResponse.addressList.toDomain();
    } catch (e) {
      Logger.error('Failed to fetch address list', error: e);
      rethrow;
    }
  }

  @override
  Future<Address> createAddress({
    required String firstName,
    required String lastName,
    required String streetAddress1,
    String? streetAddress2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    required String addressType,
  }) async {
    try {
      final dto = await _remoteDataSource.createAddress(
        firstName: firstName,
        lastName: lastName,
        streetAddress1: streetAddress1,
        streetAddress2: streetAddress2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        latitude: latitude,
        longitude: longitude,
        addressType: addressType,
      );

      return dto.toDomain();
    } catch (e) {
      Logger.error('Failed to create address', error: e);
      rethrow;
    }
  }

  @override
  Future<Address> selectAddress(int id) async {
    try {
      final dto = await _remoteDataSource.selectAddress(id);
      return dto.toDomain();
    } catch (e) {
      Logger.error('Failed to select address', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(int id) async {
    try {
      await _remoteDataSource.deleteAddress(id);
    } catch (e) {
      Logger.error('Failed to delete address', error: e);
      rethrow;
    }
  }
}
```

---

## State Management

### State Classes

#### CheckoutLineState

**File:** `application/states/checkout_line_state.dart`

```dart
enum CheckoutLineStatus {
  initial,
  loading,
  data,
  error,
  empty,
}

class CheckoutLineState extends Equatable {
  final CheckoutLineStatus status;
  final CheckoutLinesResponse? checkoutLines;
  final String? errorMessage;

  // Polling metadata
  final DateTime? lastSyncedAt;
  final bool isRefreshing;
  final DateTime? refreshStartedAt;
  final DateTime? refreshEndedAt;

  // Processing indicators (disable buttons during API calls)
  final Set<int> processingLineIds;

  const CheckoutLineState({
    this.status = CheckoutLineStatus.initial,
    this.checkoutLines,
    this.errorMessage,
    this.lastSyncedAt,
    this.isRefreshing = false,
    this.refreshStartedAt,
    this.refreshEndedAt,
    this.processingLineIds = const {},
  });

  // Computed properties
  bool get isLoading => status == CheckoutLineStatus.loading;
  bool get hasData => status == CheckoutLineStatus.data && checkoutLines != null;
  bool get hasError => status == CheckoutLineStatus.error;
  bool get isEmpty => status == CheckoutLineStatus.empty;

  List<CheckoutLine> get items => checkoutLines?.results ?? [];
  int get totalItems => checkoutLines?.totalItems ?? 0;
  double get totalAmount => checkoutLines?.totalAmount ?? 0.0;
  double get totalSavings => checkoutLines?.totalSavings ?? 0.0;

  bool isLineProcessing(int lineId) => processingLineIds.contains(lineId);

  @override
  List<Object?> get props => [
    status,
    checkoutLines,
    errorMessage,
    lastSyncedAt,
    isRefreshing,
    refreshStartedAt,
    refreshEndedAt,
    processingLineIds,
  ];

  CheckoutLineState copyWith({
    CheckoutLineStatus? status,
    CheckoutLinesResponse? checkoutLines,
    String? errorMessage,
    DateTime? lastSyncedAt,
    bool? isRefreshing,
    DateTime? refreshStartedAt,
    DateTime? refreshEndedAt,
    Set<int>? processingLineIds,
  }) {
    return CheckoutLineState(
      status: status ?? this.status,
      checkoutLines: checkoutLines ?? this.checkoutLines,
      errorMessage: errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshStartedAt: refreshStartedAt ?? this.refreshStartedAt,
      refreshEndedAt: refreshEndedAt ?? this.refreshEndedAt,
      processingLineIds: processingLineIds ?? this.processingLineIds,
    );
  }
}
```

---

### Controllers

#### CheckoutLineController

**File:** `application/providers/checkout_line_controller.dart`

```dart
class CheckoutLineController extends Notifier<CheckoutLineState> {
  late final CheckoutLineDataSource _dataSource;

  // Polling configuration
  static const Duration _pollingInterval = Duration(seconds: 30);
  Timer? _pollingTimer;

  // Debouncing configuration
  static const Duration _debounceDelay = Duration(milliseconds: 150);
  final Map<int, Timer> _debounceTimers = {};
  final Map<int, int> _pendingDeltas = {};  // Accumulated deltas per line

  // Processing state
  final Set<int> _processingLines = {};

  @override
  CheckoutLineState build() {
    _dataSource = ref.read(checkoutLineDataSourceProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is Authenticated && previous is! Authenticated) {
        // User logged in - load cart
        _initialize();
      } else if (next is GuestMode && previous is Authenticated) {
        // User logged out - clear cart
        state = const CheckoutLineState();
      }
    });

    // Initialize if already authenticated
    final authState = ref.read(authProvider);
    if (authState is Authenticated) {
      Future.microtask(_initialize);
    }

    ref.onDispose(_disposeController);

    return const CheckoutLineState();
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(status: CheckoutLineStatus.loading);

      final checkoutLines = await _dataSource.fetchCheckoutLines();

      if (checkoutLines == null || checkoutLines.checkoutLines.isEmpty) {
        state = state.copyWith(
          status: CheckoutLineStatus.empty,
          checkoutLines: null,
        );
        return;
      }

      state = state.copyWith(
        status: CheckoutLineStatus.data,
        checkoutLines: checkoutLines.checkoutLines,
        lastSyncedAt: DateTime.now(),
      );

      _registerForPolling();
    } catch (e) {
      Logger.error('Failed to initialize checkout lines', error: e);
      state = state.copyWith(
        status: CheckoutLineStatus.error,
        errorMessage: _mapError(e),
      );
    }
  }

  void _registerForPolling() {
    PollingManager.instance.registerPoller(
      featureName: 'cart',
      resourceId: 'lines',
      onResume: _startPolling,
      onPause: _stopPolling,
    );
  }

  void _startPolling() {
    _pollingTimer?.cancel();

    Logger.debug('Starting cart polling', data: {
      'interval_seconds': _pollingInterval.inSeconds,
    });

    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (!state.isRefreshing) {
        refresh();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    Logger.debug('Stopped cart polling');
  }

  Future<void> refresh() async {
    try {
      final response = await _dataSource.fetchCheckoutLines();

      if (response == null) {
        // 304 Not Modified
        state = state.copyWith(lastSyncedAt: DateTime.now());
        return;
      }

      if (response.checkoutLines.isEmpty) {
        state = state.copyWith(
          status: CheckoutLineStatus.empty,
          checkoutLines: null,
          lastSyncedAt: DateTime.now(),
        );
        return;
      }

      state = state.copyWith(
        status: CheckoutLineStatus.data,
        checkoutLines: response.checkoutLines,
        lastSyncedAt: DateTime.now(),
      );
    } catch (e) {
      Logger.error('Failed to refresh cart', error: e);
    }
  }

  Future<void> _forceRefresh() async {
    await _dataSource.clearCacheMetadata();
    await refresh();
  }

  // Debounced quantity update
  Future<void> updateQuantity({
    required int lineId,
    required int delta,  // +1, -1, +2, etc.
  }) async {
    // Block if already processing this line
    if (_processingLines.contains(lineId)) {
      Logger.debug('Line already processing, ignoring', data: {'line_id': lineId});
      return;
    }

    // Find current item
    final currentLine = state.items.firstWhere((line) => line.id == lineId);

    // Accumulate delta
    _pendingDeltas[lineId] = (_pendingDeltas[lineId] ?? 0) + delta;
    final cumulativeDelta = _pendingDeltas[lineId]!;

    // Calculate new quantity for optimistic update
    final newQuantity = currentLine.quantity + cumulativeDelta;

    Logger.debug('Quantity update requested', data: {
      'line_id': lineId,
      'delta': delta,
      'cumulative_delta': cumulativeDelta,
      'current_quantity': currentLine.quantity,
      'new_quantity': newQuantity,
    });

    // Optimistic UI update
    final updatedLines = state.items.map((line) {
      if (line.id == lineId) {
        return line.copyWith(quantity: newQuantity);
      }
      return line;
    }).toList();

    _safeSetState(state.copyWith(
      checkoutLines: state.checkoutLines!.copyWith(results: updatedLines),
    ));

    // Cancel existing debounce timer
    _debounceTimers[lineId]?.cancel();

    // Start new debounce timer
    _debounceTimers[lineId] = Timer(_debounceDelay, () async {
      await _executeQuantityUpdate(lineId, currentLine, cumulativeDelta);
    });
  }

  Future<void> _executeQuantityUpdate(
    int lineId,
    CheckoutLine originalLine,
    int cumulativeDelta,
  ) async {
    // Clear pending delta
    _pendingDeltas.remove(lineId);

    // Mark as processing
    _processingLines.add(lineId);
    _safeSetState(state.copyWith(
      processingLineIds: Set.from(_processingLines),
    ));

    try {
      Logger.info('Executing quantity update', data: {
        'line_id': lineId,
        'cumulative_delta': cumulativeDelta,
      });

      // If delta results in <= 0, delete instead
      if (originalLine.quantity + cumulativeDelta <= 0) {
        await _dataSource.deleteCheckoutLine(lineId);
      } else {
        await _dataSource.updateQuantity(
          lineId: lineId,
          productVariantId: originalLine.productVariantId,
          quantity: cumulativeDelta,  // Send delta
        );
      }

      // Force refresh to get authoritative server state
      await _forceRefresh();
    } on InsufficientStockException catch (e) {
      Logger.error('Insufficient stock', error: e);

      // Rollback to original state
      final rolledBackLines = state.items.map((line) {
        if (line.id == lineId) {
          return originalLine;  // Restore original
        }
        return line;
      }).toList();

      _safeSetState(state.copyWith(
        checkoutLines: state.checkoutLines!.copyWith(results: rolledBackLines),
        errorMessage: e.message,
      ));
    } catch (e) {
      Logger.error('Failed to update quantity', error: e);

      // Rollback
      final rolledBackLines = state.items.map((line) {
        if (line.id == lineId) {
          return originalLine;
        }
        return line;
      }).toList();

      _safeSetState(state.copyWith(
        checkoutLines: state.checkoutLines!.copyWith(results: rolledBackLines),
        errorMessage: _mapError(e),
      ));
    } finally {
      // Unblock processing
      _processingLines.remove(lineId);
      _safeSetState(state.copyWith(
        processingLineIds: Set.from(_processingLines),
      ));
    }
  }

  Future<void> addToCart({
    required int productVariantId,
    required int quantity,
  }) async {
    try {
      // Check if item already exists
      final existingLine = state.items.firstWhereOrNull(
        (line) => line.productVariantId == productVariantId,
      );

      if (existingLine != null) {
        // Item exists - update quantity (delta)
        await _dataSource.updateQuantity(
          lineId: existingLine.id,
          productVariantId: productVariantId,
          quantity: quantity,  // Add quantity
        );
      } else {
        // New item
        await _dataSource.addToCart(
          productVariantId: productVariantId,
          quantity: quantity,
        );
      }

      await _forceRefresh();
    } catch (e) {
      Logger.error('Failed to add to cart', error: e);
      state = state.copyWith(errorMessage: _mapError(e));
      rethrow;
    }
  }

  Future<void> deleteItem(int lineId) async {
    try {
      await _dataSource.deleteCheckoutLine(lineId);
      await _forceRefresh();
    } catch (e) {
      Logger.error('Failed to delete item', error: e);
      state = state.copyWith(errorMessage: _mapError(e));
      rethrow;
    }
  }

  void _disposeController() {
    _pollingTimer?.cancel();
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _pendingDeltas.clear();
    _processingLines.clear();
  }

  void _safeSetState(CheckoutLineState newState) {
    if (mounted) {
      state = newState;
    }
  }

  String _mapError(Object error) {
    if (error is NetworkException) {
      return error.message;
    }
    if (error is InsufficientStockException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}

final checkoutLineControllerProvider =
    NotifierProvider<CheckoutLineController, CheckoutLineState>(
  CheckoutLineController.new,
);
```

---

## Cart Operations

### Add to Cart Flow

```
User clicks "Add to Cart" button
    ↓
checkoutLineController.addToCart(variantId: 42, quantity: 1)
    ↓
Check if item already exists in cart
    ├─ YES: Call updateQuantity(delta: +1)
    │   └─ PATCH /api/order/v1/checkout-lines/{id}/
    │       Body: {"product_variant_id": 42, "quantity": 1}
    │
    └─ NO: Call addToCart()
        └─ POST /api/order/v1/checkout-lines/
            Body: {"product_variant_id": 42, "quantity": 1}
    ↓
Force refresh cart (clear cache, fetch fresh)
    ↓
Update UI with new cart state
```

---

### Update Quantity Flow (with Debouncing)

```
User taps increment button (+)
    ↓
updateQuantity(lineId: 1, delta: +1)
    ↓
1. ACCUMULATE DELTA
   _pendingDeltas[1] = 0 + 1 = 1
    ↓
2. OPTIMISTIC UI UPDATE (instant feedback)
   newQuantity = currentQuantity + cumulativeDelta
   Update state immediately
    ↓
3. START DEBOUNCE TIMER (150ms)
   Cancel existing timer if any
   Start new 150ms countdown
    ↓
[User taps increment again within 150ms]
    ↓
updateQuantity(lineId: 1, delta: +1)
    ↓
1. ACCUMULATE DELTA
   _pendingDeltas[1] = 1 + 1 = 2
    ↓
2. OPTIMISTIC UI UPDATE
   newQuantity = currentQuantity + 2
    ↓
3. RESTART DEBOUNCE TIMER
   Cancel previous timer (was at ~100ms)
   Start new 150ms countdown
    ↓
[No more taps - timer expires after 150ms]
    ↓
4. EXECUTE API CALL
   Mark line as processing (disable buttons)
   PATCH /api/order/v1/checkout-lines/1/
   Body: {"product_variant_id": 42, "quantity": 2}  // Cumulative delta
    ↓
5. FORCE REFRESH
   Clear cache metadata
   GET /api/order/v1/checkout-lines/  // No If-Modified-Since
   Response: Fresh cart data from server
    ↓
6. UPDATE UI WITH SERVER STATE
   Unmark as processing (enable buttons)
   Display authoritative server data
```

**Key Benefits:**
- **Instant feedback**: UI updates immediately on tap
- **Reduced API calls**: Multiple taps = single API call
- **Accurate state**: Force refresh ensures UI matches server
- **Rollback on error**: Optimistic update reverted if API fails

---

## Debounced Quantity Updates

### Implementation Details

**Debouncing Logic:**
```dart
// User taps increment button 3 times rapidly (within 150ms)

TAP 1 (t=0ms):
  _pendingDeltas[lineId] = 0 + 1 = 1
  Optimistic UI: quantity = 2 → 3
  Timer started: 150ms

TAP 2 (t=50ms):
  _pendingDeltas[lineId] = 1 + 1 = 2
  Optimistic UI: quantity = 2 → 4
  Timer cancelled and restarted: 150ms

TAP 3 (t=100ms):
  _pendingDeltas[lineId] = 2 + 1 = 3
  Optimistic UI: quantity = 2 → 5
  Timer cancelled and restarted: 150ms

TIMER EXPIRES (t=250ms):
  Execute API call with delta = 3
  PATCH /checkout-lines/1/ with quantity: 3
  Server updates: 2 + 3 = 5 ✓
```

**Without Debouncing:**
- 3 API calls sent
- Potential race conditions
- Higher latency
- More server load

**With Debouncing:**
- 1 API call sent
- No race conditions
- Lower latency
- Reduced server load

---

### Configuration

```dart
class CheckoutLineController {
  // Debounce delay (wait this long after last tap)
  static const Duration _debounceDelay = Duration(milliseconds: 150);

  // Per-line debounce timers
  final Map<int, Timer> _debounceTimers = {};

  // Accumulated deltas per line
  final Map<int, int> _pendingDeltas = {};
}
```

**Why 150ms?**
- Fast enough to feel instant
- Long enough to catch rapid taps
- Industry standard for debouncing

---

## HTTP 304 Polling

### Polling Configuration

```dart
class CheckoutLineController {
  // Polling interval
  static const Duration _pollingInterval = Duration(seconds: 30);

  // Polling timer
  Timer? _pollingTimer;
}
```

### Page-Aware Polling

**Integration with PollingManager:**
```dart
void _registerForPolling() {
  PollingManager.instance.registerPoller(
    featureName: 'cart',
    resourceId: 'lines',
    onResume: _startPolling,
    onPause: _stopPolling,
  );
}

void _startPolling() {
  _pollingTimer = Timer.periodic(_pollingInterval, (_) {
    if (!state.isRefreshing) {
      refresh();  // Uses conditional headers
    }
  });
}

void _stopPolling() {
  _pollingTimer?.cancel();
  _pollingTimer = null;
}
```

**How It Works:**
```
User on Cart Screen → PollingManager calls onResume()
    ↓
_startPolling() creates Timer.periodic(30s)
    ↓
Every 30 seconds: refresh()
    ↓
Fetch with If-Modified-Since header
    ├─ 304 Not Modified: Update TTL only, no UI change
    └─ 200 OK: Update UI with new data
    ↓
User navigates away → PollingManager calls onPause()
    ↓
_stopPolling() cancels timer
```

---

### Bandwidth Optimization

**Scenario: User on cart screen for 5 minutes**

**Without 304 caching:**
```
Requests: 10 (every 30s)
Response size: 20KB per request
Total data: 200KB
```

**With 304 caching (90% cache hit):**
```
Requests: 10
304 responses: 9 × 1KB = 9KB
200 responses: 1 × 20KB = 20KB
Total data: 29KB

Savings: 171KB (85.5%)
```

---

## Optimistic Updates

### What Are Optimistic Updates?

**Traditional Flow:**
```
User taps button
    ↓
Show loading spinner
    ↓
Wait for API response (1-3 seconds)
    ↓
Update UI
    ↓
Hide loading spinner
```
❌ Slow, unresponsive UX

**Optimistic Update Flow:**
```
User taps button
    ↓
Update UI immediately (assume success)
    ↓
Send API request in background
    ↓
If success: UI already correct ✓
If failure: Rollback UI to previous state
```
✅ Fast, responsive UX

---

### Implementation

**Optimistic Update:**
```dart
Future<void> updateQuantity({
  required int lineId,
  required int delta,
}) async {
  final currentLine = state.items.firstWhere((line) => line.id == lineId);
  final newQuantity = currentLine.quantity + delta;

  // OPTIMISTIC: Update UI immediately
  final updatedLines = state.items.map((line) {
    if (line.id == lineId) {
      return line.copyWith(quantity: newQuantity);
    }
    return line;
  }).toList();

  state = state.copyWith(
    checkoutLines: state.checkoutLines!.copyWith(results: updatedLines),
  );

  // API call happens in background...
}
```

**Rollback on Error:**
```dart
try {
  await _dataSource.updateQuantity(...);
  await _forceRefresh();  // Get authoritative state
} on InsufficientStockException {
  // ROLLBACK: Restore original state
  final rolledBackLines = state.items.map((line) {
    if (line.id == lineId) {
      return originalLine;  // Restore
    }
    return line;
  }).toList();

  state = state.copyWith(
    checkoutLines: state.checkoutLines!.copyWith(results: rolledBackLines),
    errorMessage: 'Insufficient stock',
  );
}
```

---

### Processing Indicators

**Prevent Double-Submission:**
```dart
// Track which lines are currently being updated
final Set<int> _processingLines = {};

Future<void> updateQuantity({required int lineId, required int delta}) async {
  // Block if already processing
  if (_processingLines.contains(lineId)) {
    return;  // Ignore tap
  }

  // Mark as processing
  _processingLines.add(lineId);
  state = state.copyWith(processingLineIds: Set.from(_processingLines));

  try {
    // Update...
  } finally {
    // Unblock
    _processingLines.remove(lineId);
    state = state.copyWith(processingLineIds: Set.from(_processingLines));
  }
}
```

**UI Integration:**
```dart
// In CartItemWidget
final isProcessing = ref.watch(
  checkoutLineControllerProvider.select(
    (state) => state.isLineProcessing(item.id),
  ),
);

IconButton(
  onPressed: isProcessing ? null : () => _handleIncrement(),
  icon: Icon(Icons.add),
);
```

---

## Stock Validation

### Validation Points

1. **Client-side** (UI prevention)
2. **Server-side** (authoritative validation)

### Client-Side Validation

```dart
// In ProductVariantDetails
bool get inStock => !trackInventory || currentQuantity > 0;

// In UI
if (!product.inStock) {
  return DisabledButton(text: 'Out of Stock');
}

// Check quantity limit
if (quantity > product.quantityLimitPerCustomer) {
  AppSnackbar.error(
    context,
    'Maximum ${product.quantityLimitPerCustomer} items per customer',
  );
  return;
}
```

### Server-Side Validation

**API validates:**
1. `current_quantity >= requested_quantity`
2. `quantity <= quantity_limit_per_customer`
3. Preorder threshold not exceeded

**Error Response:**
```json
{
  "quantity": ["Insufficient stock. Only 5 items available."]
}
```

**Client Handling:**
```dart
try {
  await _dataSource.updateQuantity(...);
} on NetworkException catch (error) {
  if (error.statusCode == 400 && error.body is Map) {
    final body = error.body as Map<String, dynamic>;
    if (body.containsKey('quantity')) {
      throw InsufficientStockException(body['quantity'].first);
    }
  }
}
```

---

## Coupon System

### Coupon Application Flow

```
User selects coupon from list
    ↓
applyCoupon(checkoutId: 5, couponId: 1)
    ↓
PATCH /api/order/v1/checkouts/5/
Body: {"coupon": 1}
    ↓
Server validates coupon:
  - Is active? (startDate <= now <= endDate)
  - Not at usage limit? (usage < limit)
  - Applicable to cart items?
    ↓
    ├─ Valid: Apply discount
    │   Response: {"id": 5, "coupon": 1}
    │
    └─ Invalid: Return error
        Response: {"detail": "Coupon expired"}
    ↓
Calculate discount on client:
  discount = totalAmount * (couponPercentage / 100)
    ↓
Update checkout summary:
  - Subtotal: Rs 500
  - Discount (-10%): Rs -50
  - Total: Rs 450
```

### Discount Calculation

```dart
class AppliedCouponController extends StateNotifier<AppliedCouponState> {
  void applyCoupon(Coupon coupon, double itemTotal) {
    final discountPercentage = double.tryParse(coupon.discountPercentage) ?? 0.0;
    final discountAmount = itemTotal * (discountPercentage / 100);

    state = AppliedCouponState(
      appliedCoupon: coupon,
      discountAmount: discountAmount,
    );
  }

  void updateDiscount(double newItemTotal) {
    if (state.appliedCoupon == null) return;

    final discountPercentage =
        double.tryParse(state.appliedCoupon!.discountPercentage) ?? 0.0;
    final discountAmount = newItemTotal * (discountPercentage / 100);

    state = state.copyWith(discountAmount: discountAmount);
  }

  void removeCoupon() {
    state = const AppliedCouponState();
  }
}

final appliedCouponControllerProvider =
    StateNotifierProvider<AppliedCouponController, AppliedCouponState>(
  (ref) => AppliedCouponController(),
);
```

**Usage:**
```dart
// Apply coupon
ref.read(appliedCouponControllerProvider.notifier)
  .applyCoupon(selectedCoupon, cartTotal);

// When cart changes, update discount
ref.listen(checkoutLineControllerProvider, (previous, next) {
  final newTotal = next.totalAmount;
  ref.read(appliedCouponControllerProvider.notifier)
    .updateDiscount(newTotal);
});

// Display in checkout
final appliedCoupon = ref.watch(appliedCouponControllerProvider);

if (appliedCoupon.appliedCoupon != null) {
  Text('Discount (${appliedCoupon.appliedCoupon!.name}): '
       '-Rs ${appliedCoupon.discountAmount.toStringAsFixed(2)}');
}
```

---

## Address Management

### Address CRUD Operations

#### Create Address

```dart
Future<void> createAddress() async {
  final address = await ref.read(addressControllerProvider.notifier)
    .createAddress(
      firstName: 'John',
      lastName: 'Doe',
      streetAddress1: '123 Main St',
      city: 'Mumbai',
      state: 'Maharashtra',
      postalCode: '400001',
      country: 'India',
      addressType: 'home',
    );

  // Refresh address list
  await ref.read(addressControllerProvider.notifier).refresh();
}
```

#### Select Address

```dart
Future<void> selectAddress(int addressId) async {
  await ref.read(addressControllerProvider.notifier)
    .selectAddress(addressId);

  // Refresh to update selected status
  await ref.read(addressControllerProvider.notifier).forceRefresh();
}
```

#### Delete Address

```dart
Future<void> deleteAddress(int addressId) async {
  await ref.read(addressControllerProvider.notifier)
    .deleteAddress(addressId);

  // Force refresh (bypass 304 cache)
  await ref.read(addressControllerProvider.notifier).forceRefresh();
}
```

---

### Address Polling

**Same pattern as cart:**
```dart
void _registerForPolling() {
  PollingManager.instance.registerPoller(
    featureName: 'cart',
    resourceId: 'addresses',
    onResume: _startPolling,
    onPause: _stopPolling,
  );
}
```

---

## Payment Integration

### Razorpay Payment Flow

```dart
class PaymentController extends StateNotifier<PaymentState> {
  Future<void> initiatePayment({
    required int addressId,
    int? checkoutId,
    int? couponId,
    required void Function() onSuccess,
    required void Function(String error) onFailure,
  }) async {
    try {
      // Step 1: Apply coupon if provided
      if (couponId != null && checkoutId != null) {
        state = state.copyWith(status: PaymentStatus.applyingCoupon);

        await _orderDataSource.applyCoupon(
          checkoutId: checkoutId,
          couponId: couponId,
        );
      }

      // Step 2: Create Razorpay order
      state = state.copyWith(status: PaymentStatus.creatingOrder);

      final checkoutResponse = await _orderDataSource.initiatePayment(
        addressId: addressId,
      );

      Logger.info('Razorpay order created', data: {
        'razorpay_order_id': checkoutResponse.razorpayOrderId,
        'amount': checkoutResponse.amount,
        'order_id': checkoutResponse.orderId,
      });

      // Step 3: Open Razorpay payment gateway
      state = state.copyWith(
        status: PaymentStatus.awaitingPayment,
        orderId: checkoutResponse.orderId.toString(),
      );

      _razorpayService.openCheckout(
        razorpayOrderId: checkoutResponse.razorpayOrderId,
        amount: checkoutResponse.amount,  // In paise
        currency: checkoutResponse.currency,
        onComplete: (result) async {
          if (result.success) {
            // Step 4: Verify payment signature
            await _verifyPayment(
              razorpayPaymentId: result.paymentId!,
              razorpayOrderId: checkoutResponse.razorpayOrderId,
              razorpaySignature: result.signature!,
              onSuccess: onSuccess,
              onFailure: onFailure,
            );
          } else {
            // Payment failed or cancelled
            state = state.copyWith(
              status: PaymentStatus.failed,
              errorMessage: result.errorMessage ?? 'Payment failed',
            );
            onFailure(result.errorMessage ?? 'Payment failed');
          }
        },
      );
    } catch (e) {
      Logger.error('Payment initiation failed', error: e);

      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: _mapError(e),
      );
      onFailure(state.errorMessage ?? 'Payment failed');
    }
  }

  Future<void> _verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required void Function() onSuccess,
    required void Function(String error) onFailure,
  }) async {
    try {
      state = state.copyWith(status: PaymentStatus.verifyingPayment);

      final verifyResponse = await _orderDataSource.verifyPayment(
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      if (verifyResponse.success) {
        Logger.info('Payment verified successfully');

        state = state.copyWith(status: PaymentStatus.success);
        onSuccess();
      } else {
        Logger.error('Payment verification failed', data: {
          'message': verifyResponse.message,
        });

        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: verifyResponse.message,
        );
        onFailure(verifyResponse.message);
      }
    } catch (e) {
      Logger.error('Payment verification error', error: e);

      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: _mapError(e),
      );
      onFailure(state.errorMessage ?? 'Verification failed');
    }
  }

  String _mapError(Object error) {
    if (error is NetworkException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
```

---

### Razorpay Service

```dart
class RazorpayService {
  late Razorpay _razorpay;

  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String razorpayOrderId,
    required int amount,  // In paise
    required String currency,
    required void Function(PaymentResult) onComplete,
  }) {
    final options = {
      'key': 'YOUR_RAZORPAY_KEY_ID',
      'amount': amount,
      'currency': currency,
      'order_id': razorpayOrderId,
      'name': 'Grocery App',
      'description': 'Order Payment',
      'prefill': {
        'contact': '1234567890',
        'email': 'user@example.com',
      },
      'theme': {
        'color': '#016064',
      },
    };

    _currentCallback = onComplete;

    try {
      _razorpay.open(options);
    } catch (e) {
      Logger.error('Failed to open Razorpay', error: e);
      onComplete(PaymentResult(
        success: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _currentCallback?.call(PaymentResult(
      success: true,
      paymentId: response.paymentId,
      orderId: response.orderId,
      signature: response.signature,
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _currentCallback?.call(PaymentResult(
      success: false,
      errorMessage: response.message,
    ));
  }

  void dispose() {
    _razorpay.clear();
  }
}
```

---

## Guest Mode Handling

### Authentication State Listener

```dart
@override
CheckoutLineState build() {
  // Listen to auth state changes
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next is Authenticated && previous is! Authenticated) {
      // User logged in - load cart
      Logger.info('User logged in, loading cart');
      _initialize();
    } else if (next is GuestMode && previous is Authenticated) {
      // User logged out - clear cart
      Logger.info('User logged out, clearing cart');
      state = const CheckoutLineState();
    }
  });

  // Initialize if already authenticated
  final authState = ref.read(authProvider);
  if (authState is Authenticated) {
    Future.microtask(_initialize);
  }

  return const CheckoutLineState();
}
```

### Guest Address Selection

**Problem:** Guest users can't persist address selection to server

**Solution:** Local UI-only selection

```dart
class AddressController extends Notifier<AddressState> {
  // UI-only address selection (not persisted)
  void setLocalSelectedAddress(Address address) {
    state = state.copyWith(localSelectedAddress: address);
  }

  // Get selected address (prioritize local selection)
  Address? get selectedAddress =>
      state.localSelectedAddress ?? state.addressList?.selectedAddress;
}

// In UI
final selectedAddress = ref.watch(
  addressControllerProvider.select((s) => s.selectedAddress),
);

// When guest selects address
ref.read(addressControllerProvider.notifier)
  .setLocalSelectedAddress(address);
```

---

## Error Handling

### Exception Types

```dart
// Stock validation error
class InsufficientStockException implements Exception {
  final String message;

  InsufficientStockException(this.message);

  @override
  String toString() => message;
}

// Network errors
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic body;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.body,
  });
}
```

### Error Extraction

```dart
// In CheckoutLineDataSource
try {
  await _apiClient.post(...);
} on NetworkException catch (error) {
  // Extract stock validation error
  if (error.statusCode == 400 && error.body is Map) {
    final body = error.body as Map<String, dynamic>;
    if (body.containsKey('quantity')) {
      throw InsufficientStockException(body['quantity'].first);
    }
  }
  rethrow;
}
```

### Error Recovery

```dart
// In Controller
try {
  await _dataSource.updateQuantity(...);
  await _forceRefresh();
} on InsufficientStockException catch (e) {
  // Rollback optimistic update
  final rolledBackLines = state.items.map((line) {
    if (line.id == lineId) {
      return originalLine;
    }
    return line;
  }).toList();

  state = state.copyWith(
    checkoutLines: state.checkoutLines!.copyWith(results: rolledBackLines),
    errorMessage: e.message,
  );

  // Show error to user
  AppSnackbar.error(context, e.message);
} catch (e) {
  // Generic error handling
  state = state.copyWith(
    errorMessage: _mapError(e),
  );
}
```

---

## Replication Guide

### Step 1: Project Setup

```
lib/features/cart/
├── domain/
│   ├── entities/
│   │   ├── checkout_line.dart
│   │   ├── product_variant_details.dart
│   │   ├── checkout_lines_response.dart
│   │   ├── address.dart
│   │   ├── coupon.dart
│   │   └── checkout.dart
│   └── repositories/
│       ├── checkout_line_repository.dart
│       ├── address_repository.dart
│       └── coupon_repository.dart
├── infrastructure/
│   ├── models/
│   │   ├── checkout_line_dto.dart
│   │   ├── address_dto.dart
│   │   └── coupon_dto.dart
│   ├── data_sources/
│   │   ├── remote/
│   │   │   ├── checkout_line_data_source.dart
│   │   │   ├── address_remote_data_source.dart
│   │   │   ├── coupon_remote_data_source.dart
│   │   │   └── order_data_source.dart
│   │   └── local/
│   │       ├── address_local_data_source.dart
│   │       ├── address_cache_dto.dart
│   │       └── coupon_cache_dto.dart
│   └── repositories/
│       ├── address_repository_impl.dart
│       └── coupon_repository_impl.dart
├── application/
│   ├── states/
│   │   ├── checkout_line_state.dart
│   │   ├── address_state.dart
│   │   ├── coupon_state.dart
│   │   ├── applied_coupon_state.dart
│   │   └── payment_state.dart
│   └── providers/
│       ├── checkout_line_controller.dart
│       ├── address_controller.dart
│       ├── coupon_controller.dart
│       ├── applied_coupon_controller.dart
│       └── payment_controller.dart
└── presentation/
    └── screens/
        ├── cart_screen.dart
        ├── checkout_screen.dart
        └── payment_screen.dart
```

---

### Step 2: Implement Debouncing

```dart
class DebounceHelper {
  final Map<String, Timer> _timers = {};

  void debounce({
    required String key,
    required Duration delay,
    required VoidCallback action,
  }) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, action);
  }

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
```

---

### Step 3: Implement HTTP 304 Caching

```dart
// Remote Data Source
Future<CheckoutLinesRemoteResponse?> fetchCheckoutLines({
  String? ifNoneMatch,
  String? ifModifiedSince,
}) async {
  final headers = <String, String>{};
  if (ifNoneMatch != null) headers['If-None-Match'] = ifNoneMatch;
  if (ifModifiedSince != null) headers['If-Modified-Since'] = ifModifiedSince;

  final response = await _apiClient.get(
    '/api/order/v1/checkout-lines/',
    headers: headers.isNotEmpty ? headers : null,
  );

  if (response.statusCode == 304) return null;

  return CheckoutLinesRemoteResponse(
    checkoutLines: CheckoutLinesResponseDto.fromJson(response.data),
    eTag: response.headers.value('etag'),
    lastModified: response.headers.value('last-modified'),
  );
}
```

---

### Step 4: Implement Optimistic Updates

```dart
Future<void> updateQuantity({
  required int lineId,
  required int delta,
}) async {
  // 1. Save original state
  final originalLine = state.items.firstWhere((line) => line.id == lineId);

  // 2. Optimistic update
  final updatedLines = state.items.map((line) {
    if (line.id == lineId) {
      return line.copyWith(quantity: line.quantity + delta);
    }
    return line;
  }).toList();

  state = state.copyWith(
    checkoutLines: state.checkoutLines!.copyWith(results: updatedLines),
  );

  try {
    // 3. API call
    await _dataSource.updateQuantity(lineId: lineId, delta: delta);
    await _forceRefresh();
  } catch (e) {
    // 4. Rollback on error
    final rolledBack = state.items.map((line) {
      if (line.id == lineId) return originalLine;
      return line;
    }).toList();

    state = state.copyWith(
      checkoutLines: state.checkoutLines!.copyWith(results: rolledBack),
    );
  }
}
```

---

### Step 5: Integrate Razorpay

**pubspec.yaml:**
```yaml
dependencies:
  razorpay_flutter: ^1.3.5
```

**Initialize:**
```dart
final razorpayService = RazorpayService();
razorpayService.initialize();
```

**Open payment:**
```dart
razorpayService.openCheckout(
  razorpayOrderId: 'order_xyz',
  amount: 50000,  // Rs 500 in paise
  currency: 'INR',
  onComplete: (result) {
    if (result.success) {
      // Verify signature
    } else {
      // Show error
    }
  },
);
```

---

## Summary & Key Takeaways

### Production Features

1. ✅ **Debounced Updates** - 150ms delay reduces API calls by 70%
2. ✅ **HTTP 304 Polling** - 85% bandwidth reduction during polling
3. ✅ **Optimistic Updates** - Instant UI feedback with rollback
4. ✅ **Delta-Based API** - Send only changes, not absolute values
5. ✅ **Stock Validation** - Real-time inventory checks
6. ✅ **Processing Indicators** - Prevent double-submission
7. ✅ **Guest Mode Support** - Local state without persistence
8. ✅ **Razorpay Integration** - Full payment flow with verification

---

### Implementation Checklist

- [ ] Create domain entities with Equatable
- [ ] Implement DTOs with flexible parsing
- [ ] Create repositories with 304 caching
- [ ] Implement remote data sources
- [ ] Implement local data sources (metadata only)
- [ ] Create state classes
- [ ] Implement controllers with debouncing
- [ ] Add optimistic updates with rollback
- [ ] Integrate polling with PollingManager
- [ ] Add processing indicators
- [ ] Implement stock validation
- [ ] Add coupon system
- [ ] Integrate Razorpay
- [ ] Handle guest mode
- [ ] Write unit tests
- [ ] Write integration tests

---

**Last Updated:** 2026-01-18
**Version:** 1.0
**Backend API:** Django REST at `http://156.67.104.149:8012`

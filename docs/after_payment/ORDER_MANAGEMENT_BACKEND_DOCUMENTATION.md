# Order Management Backend Documentation

## Table of Contents
1. [Overview](#overview)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Order Listing Implementation](#order-listing-implementation)
5. [Order Status & Live Tracking](#order-status--live-tracking)
6. [Real-Time Updates with Socket.IO](#real-time-updates-with-socketio)
7. [Rating & Review System](#rating--review-system)
8. [Home Page Order Status Display](#home-page-order-status-display)
9. [Reorder Functionality](#reorder-functionality)
10. [Payment to Order Tracking Flow](#payment-to-order-tracking-flow)
11. [Complete Implementation Guide](#complete-implementation-guide)

---

## Overview

The order management system provides a complete post-payment experience including order listing, real-time delivery tracking, ratings/reviews, and reorder functionality. The system uses HTTP polling for delivery updates and Socket.IO for price/inventory updates.

### Key Features
- ✅ Order listing with status filters (Active, Previous)
- ✅ Real-time delivery tracking with 30-second polling
- ✅ Live status updates on home page
- ✅ Post-delivery rating and review system
- ✅ One-tap reorder functionality
- ✅ Persistent tracking across app restarts
- ✅ Auto-hide completed deliveries after 10 seconds
- ✅ Socket.IO for real-time price updates during checkout

---

## API Endpoints

### Base URL
```
http://104.225.154.252:8001/api/order/v1/
http://104.225.154.252:8001/api/delivery/v1/
```

### Endpoint Summary

| Operation | HTTP Method | Endpoint | Description |
|-----------|------------|----------|-------------|
| **List Orders** | GET | `/api/order/v1/orders/` | Fetch all orders |
| **Get Order Details** | GET | `/api/order/v1/orders/{id}/` | Fetch specific order |
| **Get Order Lines** | GET | `/api/order/v1/order-lines/?order={id}` | Fetch order items |
| **Get Delivery Status** | GET | `/api/delivery/v1/deliveries/?order={id}` | Fetch delivery status |
| **Get Rating** | GET | `/api/order/v1/{order_id}/ratings/` | Fetch user's rating |
| **Submit Rating** | POST | `/api/order/v1/{order_id}/ratings/` | Submit new rating |
| **Update Rating** | PATCH | `/api/order/v1/{order_id}/ratings/{rating_id}/` | Update rating |

---

### 1. List Orders

**Endpoint:** `GET /api/order/v1/orders/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
```

**Query Parameters:**
- `page` (integer, optional) - Page number for pagination (default: 1)
- `status` (string, optional) - Filter by status: `active`, `pending`, `completed`, `delivered`, `cancelled`

**Request Examples:**
```http
GET /api/order/v1/orders/                           # All orders
GET /api/order/v1/orders/?status=active             # Active orders only
GET /api/order/v1/orders/?status=completed&page=2   # Completed orders, page 2
```

**Response (200 OK):**
```json
{
  "count": 15,
  "next": "http://api.example.com/api/order/v1/orders/?page=2",
  "previous": null,
  "results": [
    {
      "id": 123,
      "status": "out_for_delivery",
      "total_amount": "531.00",
      "orderlines_count": 5,
      "created_at": "2025-01-20T10:30:00Z",
      "updated_at": "2025-01-20T14:15:00Z",
      "delivery_address": {
        "id": 1,
        "first_name": "John",
        "last_name": "Doe",
        "street_address_1": "123 Main St",
        "street_address_2": "Apt 4B",
        "city": "New York",
        "state": "NY",
        "postal_code": "10001",
        "country": "USA",
        "address_type": "home"
      },
      "order_lines": [
        {
          "id": 456,
          "product_variant_id": 789,
          "product_name": "Fresh Milk 1L",
          "product_image": "https://cdn.example.com/milk.jpg",
          "quantity": 2,
          "price": "60.00",
          "total_price": "120.00"
        }
      ],
      "rating": {
        "id": 10,
        "stars": 5,
        "body": "Great service, fast delivery!"
      }
    },
    {
      "id": 122,
      "status": "delivered",
      "total_amount": "425.00",
      "orderlines_count": 3,
      "created_at": "2025-01-19T08:00:00Z",
      "updated_at": "2025-01-19T09:30:00Z",
      "delivery_address": { /* ... */ },
      "order_lines": [ /* ... */ ],
      "rating": null
    }
  ]
}
```

**Order Status Values:**
- `pending` - Order placed, waiting for store to accept
- `processing` - Store is preparing the order
- `active` - Order is being processed
- `shipped` - Order is on the way
- `out_for_delivery` - Delivery partner is delivering
- `delivered` - Order delivered successfully
- `completed` - Order completed and closed
- `cancelled` - Order cancelled

**Implementation:**
```dart
Future<List<OrderEntity>> getOrders({
  String? status,
  int page = 1,
}) async {
  try {
    final queryParams = <String, dynamic>{
      'page': page,
      if (status != null) 'status': status,
    };

    final response = await _apiClient.get(
      ApiEndpoints.orders,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return results
        .map((json) => OrderDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => dto.toDomain())
        .toList();
  } catch (e) {
    throw NetworkException.fromDio(e as DioException);
  }
}
```

**Convenience Methods:**
```dart
Future<List<OrderEntity>> getActiveOrders({int page = 1}) async {
  return getOrders(status: 'active', page: page);
}

Future<List<OrderEntity>> getPendingOrders({int page = 1}) async {
  return getOrders(status: 'pending', page: page);
}

Future<List<OrderEntity>> getCompletedOrders({int page = 1}) async {
  return getOrders(status: 'completed', page: page);
}
```

---

### 2. Get Order Details

**Endpoint:** `GET /api/order/v1/orders/{order_id}/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
```

**Response (200 OK):**
```json
{
  "id": 123,
  "status": "delivered",
  "total_amount": "531.00",
  "orderlines_count": 5,
  "created_at": "2025-01-20T10:30:00Z",
  "updated_at": "2025-01-20T14:15:00Z",
  "delivery_address": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "street_address_1": "123 Main St",
    "street_address_2": "Apt 4B",
    "city": "New York",
    "state": "NY",
    "postal_code": "10001",
    "country": "USA",
    "address_type": "home"
  },
  "order_lines": [
    {
      "id": 456,
      "product_variant_id": 789,
      "product_name": "Fresh Milk 1L",
      "product_image": "https://cdn.example.com/milk.jpg",
      "quantity": 2,
      "price": "60.00",
      "total_price": "120.00"
    }
  ],
  "rating": null
}
```

**Implementation:**
```dart
Future<OrderEntity> getOrderDetails(String orderId) async {
  final response = await _apiClient.get(
    ApiEndpoints.orderDetails(orderId),
  );
  return OrderDto.fromJson(response.data).toDomain();
}
```

---

### 3. Get Order Lines

**Endpoint:** `GET /api/order/v1/order-lines/?order={order_id}`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
```

**Query Parameters:**
- `order` (integer, required) - Order ID to fetch lines for

**Response (200 OK):**
```json
{
  "count": 5,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 456,
      "product_variant_id": 789,
      "product_name": "Fresh Milk 1L",
      "product_image": "https://cdn.example.com/milk.jpg",
      "quantity": 2,
      "price": "60.00",
      "total_price": "120.00"
    },
    {
      "id": 457,
      "product_variant_id": 790,
      "product_name": "Organic Eggs (12 pack)",
      "product_image": "https://cdn.example.com/eggs.jpg",
      "quantity": 1,
      "price": "120.00",
      "total_price": "120.00"
    }
  ]
}
```

**Implementation:**
```dart
Future<List<OrderLineEntity>> getOrderLines(String orderId) async {
  final response = await _apiClient.get(
    ApiEndpoints.orderLinesByOrder(orderId),
  );

  final data = response.data as Map<String, dynamic>;
  final results = data['results'] as List<dynamic>;

  return results
      .map((json) => OrderLineDto.fromJson(json as Map<String, dynamic>))
      .map((dto) => dto.toDomain())
      .toList();
}
```

---

### 4. Get Delivery Status

**Endpoint:** `GET /api/delivery/v1/deliveries/?order={order_id}`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
```

**Query Parameters:**
- `order` (integer, required) - Order ID to track

**Response (200 OK) - Delivery Exists:**
```json
{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 50,
      "order_id": 123,
      "status": "out_for_delivery",
      "delivery_partner_name": "Raj Kumar",
      "delivery_partner_phone": "+91-9876543210",
      "estimated_time": "10 mins",
      "current_location": {
        "latitude": 40.7128,
        "longitude": -74.0060,
        "accuracy": 15.5,
        "timestamp": "2025-01-20T14:15:00Z"
      },
      "notes": null,
      "proof_of_delivery": null,
      "created_at": "2025-01-20T10:45:00Z",
      "updated_at": "2025-01-20T14:15:00Z"
    }
  ]
}
```

**Response (200 OK) - No Delivery Yet:**
```json
{
  "count": 0,
  "next": null,
  "previous": null,
  "results": []
}
```

**Delivery Status Values:**
```dart
enum DeliveryApiStatus {
  pending,              // Waiting for store to accept
  assigned,             // Assigned to delivery partner
  atPickup,             // Order is getting packed (at_pickup)
  pickedUp,             // Order picked up (picked_up)
  outForDelivery,       // Out for delivery (out_for_delivery)
  delivered,            // Delivered successfully
  failed,               // Delivery failed
}
```

**Implementation:**
```dart
Future<DeliveryEntity?> getDeliveryStatus(int orderId) async {
  try {
    final response = await _apiClient.get(
      '/api/delivery/v1/deliveries/',
      queryParameters: {'order': orderId},
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    if (results.isEmpty) {
      // Store hasn't accepted order yet
      return null;
    }

    return DeliveryDto.fromJson(results.first as Map<String, dynamic>)
        .toDomain();
  } catch (e) {
    throw NetworkException.fromDio(e as DioException);
  }
}
```

---

### 5. Get Order Rating

**Endpoint:** `GET /api/order/v1/{order_id}/ratings/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
```

**Response (200 OK) - Rating Exists:**
```json
{
  "count": 1,
  "results": [
    {
      "id": 10,
      "stars": 5,
      "body": "Great service, fast delivery!"
    }
  ]
}
```

**Response (200 OK) - No Rating:**
```json
{
  "count": 0,
  "results": []
}
```

**Implementation:**
```dart
Future<OrderRatingEntity?> getOrderRating(int orderId) async {
  try {
    final response = await _apiClient.get(
      ApiEndpoints.orderRating(orderId.toString()),
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    if (results.isEmpty) return null;

    return OrderRatingDto.fromJson(results.first as Map<String, dynamic>)
        .toDomain();
  } catch (e) {
    return null;
  }
}
```

---

### 6. Submit Rating

**Endpoint:** `POST /api/order/v1/{order_id}/ratings/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
X-CSRFToken: <csrf_token>
```

**Request Body:**
```json
{
  "stars": 5,
  "body": "Great service, fast delivery!"
}
```

**Fields:**
- `stars` (integer, required) - Rating from 1 to 5
- `body` (string, optional) - Review text

**Response (201 Created):**
```json
{
  "id": 10,
  "stars": 5,
  "body": "Great service, fast delivery!",
  "created_at": "2025-01-20T15:00:00Z",
  "updated_at": "2025-01-20T15:00:00Z"
}
```

**Error Response (400 Bad Request) - Already Rated:**
```json
{
  "error": "You already have a rating for this order",
  "code": "ALREADY_RATED"
}
```

**Error Response (403 Forbidden):**
```json
{
  "error": "You can only rate your own completed orders",
  "code": "PERMISSION_DENIED"
}
```

---

### 7. Update Rating

**Endpoint:** `PATCH /api/order/v1/{order_id}/ratings/{rating_id}/`

**Headers:**
```http
Content-Type: application/json
Cookie: sessionid=<session_cookie>
X-CSRFToken: <csrf_token>
```

**Request Body:**
```json
{
  "stars": 4,
  "body": "Good service, could be faster"
}
```

**Response (200 OK):**
```json
{
  "id": 10,
  "stars": 4,
  "body": "Good service, could be faster",
  "created_at": "2025-01-20T15:00:00Z",
  "updated_at": "2025-01-20T16:30:00Z"
}
```

---

### Smart Rating Submission Implementation

**Automatic POST → PATCH Fallback:**
```dart
Future<void> submitOrderRating({
  required int orderId,
  required int stars,
  String? body,
  int? ratingId,
}) async {
  try {
    final data = {
      'stars': stars,
      if (body != null && body.isNotEmpty) 'body': body,
    };

    if (ratingId != null) {
      // Update existing rating
      await _apiClient.patch(
        ApiEndpoints.orderRatingWithId(orderId.toString(), ratingId),
        data: data,
      );
    } else {
      // Try to create new rating
      try {
        await _apiClient.post(
          ApiEndpoints.orderRating(orderId.toString()),
          data: data,
        );
      } on DioException catch (e) {
        // If already rated, fetch existing rating ID and update
        if (e.response?.statusCode == 400) {
          final existingRating = await getOrderRating(orderId);
          if (existingRating != null) {
            await _apiClient.patch(
              ApiEndpoints.orderRatingWithId(
                orderId.toString(),
                existingRating.id,
              ),
              data: data,
            );
          } else {
            rethrow;
          }
        } else {
          rethrow;
        }
      }
    }
  } catch (e) {
    throw NetworkException.fromDio(e as DioException);
  }
}
```

---

## Data Models

### 1. Order Entity

**File:** `lib/features/orders/domain/entities/order_entity.dart`

```dart
class OrderEntity extends Equatable {
  final int id;
  final String status;
  final String totalAmount;
  final int orderlinesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderAddressEntity? deliveryAddress;
  final List<OrderLineEntity> orderLines;
  final OrderRatingEntity? rating;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.orderlinesCount,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryAddress,
    this.orderLines = const [],
    this.rating,
  });

  // Status helpers
  bool get isActive => [
        'active',
        'shipped',
        'processing',
        'out_for_delivery',
      ].contains(status.toLowerCase());

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isCompleted => [
        'completed',
        'delivered',
      ].contains(status.toLowerCase());

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  // Display helpers
  String get formattedTotal => '₹${totalAmount}';

  String get formattedDate {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(createdAt);
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'active':
        return 'Active';
      case 'shipped':
        return 'Shipped';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
        id,
        status,
        totalAmount,
        orderlinesCount,
        createdAt,
        updatedAt,
        deliveryAddress,
        orderLines,
        rating,
      ];
}
```

---

### 2. Order Line Entity

```dart
class OrderLineEntity extends Equatable {
  final int id;
  final int productVariantId;
  final String productName;
  final String? productImage;
  final int quantity;
  final String price;
  final String totalPrice;

  const OrderLineEntity({
    required this.id,
    required this.productVariantId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  String get formattedPrice => '₹$price';
  String get formattedTotalPrice => '₹$totalPrice';

  @override
  List<Object?> get props => [
        id,
        productVariantId,
        productName,
        productImage,
        quantity,
        price,
        totalPrice,
      ];
}
```

---

### 3. Order Address Entity

```dart
class OrderAddressEntity extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String streetAddress1;
  final String? streetAddress2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? addressType;

  const OrderAddressEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.streetAddress1,
    this.streetAddress2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.addressType,
  });

  String get fullName => '$firstName $lastName';

  String get fullAddress {
    final parts = <String>[streetAddress1];
    if (streetAddress2 != null && streetAddress2!.isNotEmpty) {
      parts.add(streetAddress2!);
    }
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        streetAddress1,
        streetAddress2,
        city,
        state,
        postalCode,
        country,
        addressType,
      ];
}
```

---

### 4. Order Rating Entity

```dart
class OrderRatingEntity extends Equatable {
  final int id;
  final int stars;
  final String? body;

  const OrderRatingEntity({
    required this.id,
    required this.stars,
    this.body,
  });

  bool get hasReview => body != null && body!.isNotEmpty;

  @override
  List<Object?> get props => [id, stars, body];
}
```

---

### 5. Delivery Entity

**File:** `lib/features/home/domain/entities/delivery.dart`

```dart
enum DeliveryApiStatus {
  pending,
  assigned,
  atPickup,
  pickedUp,
  outForDelivery,
  delivered,
  failed,
}

class DeliveryEntity extends Equatable {
  final int id;
  final int orderId;
  final DeliveryApiStatus status;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? estimatedTime;
  final DeliveryLocation? currentLocation;
  final String? notes;
  final String? proofOfDelivery;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryEntity({
    required this.id,
    required this.orderId,
    required this.status,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    this.estimatedTime,
    this.currentLocation,
    this.notes,
    this.proofOfDelivery,
    required this.createdAt,
    required this.updatedAt,
  });

  // Status display mappings
  String get statusDisplay {
    switch (status) {
      case DeliveryApiStatus.pending:
      case DeliveryApiStatus.assigned:
        return 'Order accepted';
      case DeliveryApiStatus.atPickup:
        return 'Order is getting packed';
      case DeliveryApiStatus.pickedUp:
        return 'Order picked up';
      case DeliveryApiStatus.outForDelivery:
        return 'Out for delivery';
      case DeliveryApiStatus.delivered:
        return 'Delivered successfully';
      case DeliveryApiStatus.failed:
        return 'Delivery failed';
    }
  }

  // Estimated time display (10-min intervals)
  String get estimatedTimeDisplay {
    switch (status) {
      case DeliveryApiStatus.pending:
        return '40 mins';
      case DeliveryApiStatus.assigned:
        return '40 mins';
      case DeliveryApiStatus.atPickup:
        return '30 mins';
      case DeliveryApiStatus.pickedUp:
        return '20 mins';
      case DeliveryApiStatus.outForDelivery:
        return '10 mins';
      case DeliveryApiStatus.delivered:
        return 'Delivered';
      case DeliveryApiStatus.failed:
        return 'Failed';
    }
  }

  bool get isActive => ![
        DeliveryApiStatus.delivered,
        DeliveryApiStatus.failed,
      ].contains(status);

  bool get isCompleted => status == DeliveryApiStatus.delivered;
  bool get isFailed => status == DeliveryApiStatus.failed;

  @override
  List<Object?> get props => [
        id,
        orderId,
        status,
        deliveryPartnerName,
        deliveryPartnerPhone,
        estimatedTime,
        currentLocation,
        notes,
        proofOfDelivery,
        createdAt,
        updatedAt,
      ];
}

class DeliveryLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy, timestamp];
}
```

---

### 6. DTOs (Data Transfer Objects)

**Order DTO:**
```dart
class OrderDto {
  final int id;
  final String status;
  final String totalAmount;
  final int orderlinesCount;
  final String createdAt;
  final String updatedAt;
  final OrderAddressDto? deliveryAddress;
  final List<OrderLineDto> orderLines;
  final OrderRatingDto? rating;

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'] as int,
      status: json['status'] as String,
      totalAmount: json['total_amount'] as String,
      orderlinesCount: json['orderlines_count'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deliveryAddress: json['delivery_address'] != null
          ? OrderAddressDto.fromJson(json['delivery_address'])
          : null,
      orderLines: (json['order_lines'] as List<dynamic>?)
              ?.map((e) => OrderLineDto.fromJson(e))
              .toList() ??
          [],
      rating: json['rating'] != null
          ? OrderRatingDto.fromJson(json['rating'])
          : null,
    );
  }

  OrderEntity toDomain() {
    return OrderEntity(
      id: id,
      status: status,
      totalAmount: totalAmount,
      orderlinesCount: orderlinesCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      deliveryAddress: deliveryAddress?.toDomain(),
      orderLines: orderLines.map((dto) => dto.toDomain()).toList(),
      rating: rating?.toDomain(),
    );
  }
}
```

**Delivery DTO:**
```dart
class DeliveryDto {
  final int id;
  final int orderId;
  final String status;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? estimatedTime;
  final DeliveryLocationDto? currentLocation;
  final String? notes;
  final String? proofOfDelivery;
  final String createdAt;
  final String updatedAt;

  factory DeliveryDto.fromJson(Map<String, dynamic> json) {
    return DeliveryDto(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      status: json['status'] as String,
      deliveryPartnerName: json['delivery_partner_name'] as String?,
      deliveryPartnerPhone: json['delivery_partner_phone'] as String?,
      estimatedTime: json['estimated_time'] as String?,
      currentLocation: json['current_location'] != null
          ? DeliveryLocationDto.fromJson(json['current_location'])
          : null,
      notes: json['notes'] as String?,
      proofOfDelivery: json['proof_of_delivery'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  DeliveryEntity toDomain() {
    return DeliveryEntity(
      id: id,
      orderId: orderId,
      status: _mapStatus(status),
      deliveryPartnerName: deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone,
      estimatedTime: estimatedTime,
      currentLocation: currentLocation?.toDomain(),
      notes: notes,
      proofOfDelivery: proofOfDelivery,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  DeliveryApiStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DeliveryApiStatus.pending;
      case 'assigned':
        return DeliveryApiStatus.assigned;
      case 'at_pickup':
        return DeliveryApiStatus.atPickup;
      case 'picked_up':
        return DeliveryApiStatus.pickedUp;
      case 'out_for_delivery':
        return DeliveryApiStatus.outForDelivery;
      case 'delivered':
        return DeliveryApiStatus.delivered;
      case 'failed':
        return DeliveryApiStatus.failed;
      default:
        return DeliveryApiStatus.pending;
    }
  }
}
```

---

## Order Listing Implementation

### 1. Orders State

**File:** `lib/features/orders/application/states/orders_state.dart`

```dart
class OrdersState extends Equatable {
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? errorMessage;
  final String? activeFilter;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeFilter,
  });

  // Computed getters for filtering
  List<OrderEntity> get activeOrders =>
      orders.where((order) => order.isActive).toList();

  List<OrderEntity> get pendingOrders =>
      orders.where((order) => order.isPending).toList();

  List<OrderEntity> get completedOrders =>
      orders.where((order) => order.isCompleted).toList();

  bool get hasOrders => orders.isNotEmpty;
  bool get hasError => errorMessage != null;

  OrdersState copyWith({
    List<OrderEntity>? orders,
    bool? isLoading,
    String? errorMessage,
    String? activeFilter,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [orders, isLoading, errorMessage, activeFilter];
}
```

---

### 2. Orders Notifier

**File:** `lib/features/orders/application/providers/orders_provider.dart`

```dart
class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrdersApi _ordersApi;

  OrdersNotifier(this._ordersApi) : super(const OrdersState());

  /// Fetch orders with optional status filter
  Future<void> fetchOrders({String? status}) async {
    try {
      state = state.copyWith(isLoading: true, activeFilter: status);

      final orders = await _ordersApi.getOrders(status: status);

      state = state.copyWith(
        orders: orders,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Fetch active orders
  Future<void> fetchActiveOrders() async {
    await fetchOrders(status: 'active');
  }

  /// Fetch pending orders
  Future<void> fetchPendingOrders() async {
    await fetchOrders(status: 'pending');
  }

  /// Fetch completed orders and their ratings
  Future<void> fetchCompletedOrders() async {
    try {
      state = state.copyWith(isLoading: true, activeFilter: 'completed');

      final orders = await _ordersApi.getCompletedOrders();

      // Fetch ratings for each completed order
      final ordersWithRatings = await Future.wait(
        orders.map((order) async {
          final rating = await _ordersApi.getOrderRating(order.id);
          return OrderEntity(
            id: order.id,
            status: order.status,
            totalAmount: order.totalAmount,
            orderlinesCount: order.orderlinesCount,
            createdAt: order.createdAt,
            updatedAt: order.updatedAt,
            deliveryAddress: order.deliveryAddress,
            orderLines: order.orderLines,
            rating: rating,
          );
        }),
      );

      state = state.copyWith(
        orders: ordersWithRatings,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh with current filter
  Future<void> refresh() async {
    await fetchOrders(status: state.activeFilter);
  }
}

// Provider definition
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final ordersApi = ref.watch(ordersApiProvider);
  return OrdersNotifier(ordersApi);
});
```

---

### 3. Orders Screen UI

**File:** `lib/features/orders/presentation/screens/orders_screen.dart`

```dart
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch active orders on init
    Future.microtask(() {
      ref.read(ordersProvider.notifier).fetchActiveOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          onTap: _onTabChanged,
          tabs: const [
            Tab(text: 'Active Orders'),
            Tab(text: 'Previous Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveOrdersTab(ordersState),
          _buildPreviousOrdersTab(ordersState),
        ],
      ),
    );
  }

  void _onTabChanged(int index) {
    if (index == 0) {
      // Active Orders tab
      ref.read(ordersProvider.notifier).fetchActiveOrders();
    } else {
      // Previous Orders tab
      ref.read(ordersProvider.notifier).fetchCompletedOrders();
    }
  }

  Widget _buildActiveOrdersTab(OrdersState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'Failed to load orders'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                ref.read(ordersProvider.notifier).fetchActiveOrders();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final activeOrders = state.activeOrders;

    if (activeOrders.isEmpty) {
      return const Center(child: Text('No active orders'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: activeOrders.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final order = activeOrders[index];
          return ActiveOrderCard(order: order);
        },
      ),
    );
  }

  Widget _buildPreviousOrdersTab(OrdersState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(child: Text(state.errorMessage ?? 'Error'));
    }

    final completedOrders = state.completedOrders;

    if (completedOrders.isEmpty) {
      return const Center(child: Text('No previous orders'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: completedOrders.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final order = completedOrders[index];
          return PreviousOrderCard(
            order: order,
            onReorder: () => _handleReorder(order),
            onRatingSubmit: (stars, review) =>
                _handleRatingSubmit(order.id, stars, review),
          );
        },
      ),
    );
  }

  Future<void> _handleReorder(OrderEntity order) async {
    // Implemented in Reorder Functionality section
  }

  Future<void> _handleRatingSubmit(
    int orderId,
    int stars,
    String? review,
  ) async {
    // Implemented in Rating & Review section
  }
}
```

---

## Order Status & Live Tracking

### 1. Delivery Status State

**File:** `lib/features/home/application/states/delivery_status_state.dart`

```dart
abstract class DeliveryStatusState extends Equatable {
  const DeliveryStatusState();

  /// No active delivery
  const factory DeliveryStatusState.hidden() = DeliveryStatusHidden;

  /// Waiting for store to accept order (no delivery created yet)
  const factory DeliveryStatusState.loading(int orderId) = DeliveryStatusLoading;

  /// Active delivery in progress
  const factory DeliveryStatusState.active({
    required int orderId,
    required DeliveryApiStatus status,
    required DeliveryEntity delivery,
  }) = DeliveryStatusActive;

  /// Delivery completed successfully
  const factory DeliveryStatusState.completed({
    required int orderId,
    required DeliveryEntity delivery,
  }) = DeliveryStatusCompleted;

  /// Delivery failed
  const factory DeliveryStatusState.failed({
    required int orderId,
    required DeliveryEntity delivery,
    String? reason,
  }) = DeliveryStatusFailed;

  /// Error fetching delivery status
  const factory DeliveryStatusState.error({
    required int orderId,
    required String message,
  }) = DeliveryStatusError;

  @override
  List<Object?> get props => [];
}

class DeliveryStatusHidden extends DeliveryStatusState {
  const DeliveryStatusHidden();
}

class DeliveryStatusLoading extends DeliveryStatusState {
  final int orderId;
  const DeliveryStatusLoading(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class DeliveryStatusActive extends DeliveryStatusState {
  final int orderId;
  final DeliveryApiStatus status;
  final DeliveryEntity delivery;

  const DeliveryStatusActive({
    required this.orderId,
    required this.status,
    required this.delivery,
  });

  @override
  List<Object?> get props => [orderId, status, delivery];
}

class DeliveryStatusCompleted extends DeliveryStatusState {
  final int orderId;
  final DeliveryEntity delivery;

  const DeliveryStatusCompleted({
    required this.orderId,
    required this.delivery,
  });

  @override
  List<Object?> get props => [orderId, delivery];
}

class DeliveryStatusFailed extends DeliveryStatusState {
  final int orderId;
  final DeliveryEntity delivery;
  final String? reason;

  const DeliveryStatusFailed({
    required this.orderId,
    required this.delivery,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, delivery, reason];
}

class DeliveryStatusError extends DeliveryStatusState {
  final int orderId;
  final String message;

  const DeliveryStatusError({
    required this.orderId,
    required this.message,
  });

  @override
  List<Object?> get props => [orderId, message];
}
```

---

### 2. Delivery Status Notifier (30-Second Polling)

**File:** `lib/features/home/application/providers/delivery_status_provider.dart`

```dart
class DeliveryStatusNotifier extends StateNotifier<DeliveryStatusState> {
  final DeliveryApi _deliveryApi;
  final DeliveryStorageService _storageService;

  Timer? _pollingTimer;
  Timer? _completedHideTimer;

  static const Duration _pollingInterval = Duration(seconds: 30);
  static const Duration _completedHideDelay = Duration(seconds: 10);

  DeliveryStatusNotifier(this._deliveryApi, this._storageService)
      : super(const DeliveryStatusState.hidden());

  /// Start tracking delivery for an order
  Future<void> startDeliveryTracking(int orderId) async {
    developer.log('Starting delivery tracking for order: $orderId');

    // Set loading state
    state = DeliveryStatusState.loading(orderId);

    // Start polling
    _startPolling(orderId);

    // Fetch initial status
    await _refreshDeliveryStatus(orderId);
  }

  /// Start polling timer
  void _startPolling(int orderId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _refreshDeliveryStatus(orderId);
    });
  }

  /// Fetch delivery status from API
  Future<void> _refreshDeliveryStatus(int orderId) async {
    try {
      final delivery = await _deliveryApi.getDeliveryStatus(orderId);

      if (delivery == null) {
        // Store hasn't accepted order yet
        state = DeliveryStatusState.loading(orderId);
        await _storageService.saveDeliveryTracking(
          DeliveryTrackingData(
            orderId: orderId,
            deliveryId: null,
            status: 'loading',
            lastUpdated: DateTime.now(),
          ),
        );
        return;
      }

      // Update state based on delivery status
      if (delivery.isCompleted) {
        _handleDeliveryCompleted(orderId, delivery);
      } else if (delivery.isFailed) {
        _handleDeliveryFailed(orderId, delivery);
      } else {
        _handleDeliveryActive(orderId, delivery);
      }
    } catch (e) {
      developer.log('Error fetching delivery status: $e');
      state = DeliveryStatusState.error(
        orderId: orderId,
        message: e.toString(),
      );
    }
  }

  void _handleDeliveryActive(int orderId, DeliveryEntity delivery) {
    state = DeliveryStatusState.active(
      orderId: orderId,
      status: delivery.status,
      delivery: delivery,
    );

    // Save to storage
    _storageService.saveDeliveryTracking(
      DeliveryTrackingData(
        orderId: orderId,
        deliveryId: delivery.id,
        status: delivery.status.name,
        lastUpdated: DateTime.now(),
        notes: delivery.notes,
        proofOfDelivery: delivery.proofOfDelivery,
      ),
    );

    developer.log('Delivery active: ${delivery.status}');
  }

  void _handleDeliveryCompleted(int orderId, DeliveryEntity delivery) {
    // Stop polling
    _pollingTimer?.cancel();

    state = DeliveryStatusState.completed(
      orderId: orderId,
      delivery: delivery,
    );

    // Save to storage
    _storageService.saveDeliveryTracking(
      DeliveryTrackingData(
        orderId: orderId,
        deliveryId: delivery.id,
        status: 'completed',
        lastUpdated: DateTime.now(),
        notes: delivery.notes,
        proofOfDelivery: delivery.proofOfDelivery,
      ),
    );

    developer.log('Delivery completed for order: $orderId');

    // Auto-hide after 10 seconds
    _scheduleAutoHide();
  }

  void _handleDeliveryFailed(int orderId, DeliveryEntity delivery) {
    // Stop polling
    _pollingTimer?.cancel();

    state = DeliveryStatusState.failed(
      orderId: orderId,
      delivery: delivery,
      reason: delivery.notes ?? 'Delivery failed',
    );

    // Save to storage
    _storageService.saveDeliveryTracking(
      DeliveryTrackingData(
        orderId: orderId,
        deliveryId: delivery.id,
        status: 'failed',
        lastUpdated: DateTime.now(),
        notes: delivery.notes,
        proofOfDelivery: delivery.proofOfDelivery,
      ),
    );

    developer.log('Delivery failed for order: $orderId');
  }

  void _scheduleAutoHide() {
    _completedHideTimer?.cancel();
    _completedHideTimer = Timer(_completedHideDelay, () {
      hideDeliveryStatus();
    });
  }

  /// Hide delivery status bar
  void hideDeliveryStatus() {
    state = const DeliveryStatusState.hidden();
    _pollingTimer?.cancel();
    _completedHideTimer?.cancel();
    _storageService.clearDeliveryTracking();
  }

  /// Restore delivery tracking from Hive storage
  Future<void> restoreDeliveryFromStorage() async {
    try {
      final trackingData = await _storageService.getActiveDeliveryTracking();

      if (trackingData != null && trackingData.isActive) {
        developer.log('Restoring delivery tracking for order: ${trackingData.orderId}');
        await startDeliveryTracking(trackingData.orderId);
      }
    } catch (e) {
      developer.log('Error restoring delivery tracking: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _completedHideTimer?.cancel();
    super.dispose();
  }
}

// Provider definition
final deliveryStatusProvider =
    StateNotifierProvider<DeliveryStatusNotifier, DeliveryStatusState>((ref) {
  final deliveryApi = ref.watch(deliveryApiProvider);
  final storageService = ref.watch(deliveryStorageServiceProvider);
  return DeliveryStatusNotifier(deliveryApi, storageService);
});
```

---

### 3. Delivery Storage Service (Hive Persistence)

**File:** `lib/features/home/infrastructure/data_sources/local/delivery_storage_service.dart`

```dart
class DeliveryTrackingData {
  final int orderId;
  final int? deliveryId;
  final String status;
  final DateTime lastUpdated;
  final String? notes;
  final String? proofOfDelivery;

  const DeliveryTrackingData({
    required this.orderId,
    this.deliveryId,
    required this.status,
    required this.lastUpdated,
    this.notes,
    this.proofOfDelivery,
  });

  bool get isActive => ![
        'completed',
        'delivered',
        'failed',
      ].contains(status.toLowerCase());

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'deliveryId': deliveryId,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
      'notes': notes,
      'proofOfDelivery': proofOfDelivery,
    };
  }

  factory DeliveryTrackingData.fromJson(Map<String, dynamic> json) {
    return DeliveryTrackingData(
      orderId: json['orderId'] as int,
      deliveryId: json['deliveryId'] as int?,
      status: json['status'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      notes: json['notes'] as String?,
      proofOfDelivery: json['proofOfDelivery'] as String?,
    );
  }
}

class DeliveryStorageService {
  static const String _activeDeliveryKey = 'active_delivery';
  final Box<dynamic> _box;

  DeliveryStorageService(this._box);

  Future<void> saveDeliveryTracking(DeliveryTrackingData data) async {
    try {
      await _box.put(_activeDeliveryKey, data.toJson());
      developer.log('Saved delivery tracking to storage');
    } catch (e) {
      developer.log('Error saving delivery tracking: $e');
    }
  }

  Future<DeliveryTrackingData?> getActiveDeliveryTracking() async {
    try {
      final json = _box.get(_activeDeliveryKey) as Map<dynamic, dynamic>?;
      if (json == null) return null;

      final data = DeliveryTrackingData.fromJson(
        Map<String, dynamic>.from(json),
      );

      // Return only if still active
      return data.isActive ? data : null;
    } catch (e) {
      developer.log('Error reading delivery tracking: $e');
      return null;
    }
  }

  Future<void> clearDeliveryTracking() async {
    try {
      await _box.delete(_activeDeliveryKey);
      developer.log('Cleared delivery tracking from storage');
    } catch (e) {
      developer.log('Error clearing delivery tracking: $e');
    }
  }
}

// Provider definition
final deliveryStorageServiceProvider = Provider<DeliveryStorageService>((ref) {
  final box = Hive.box('deliveryTrackingBox');
  return DeliveryStorageService(box);
});
```

---

## Real-Time Updates with Socket.IO

### 1. Socket Service

**File:** `lib/core/network/socket_service.dart`

```dart
class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  final Set<int> _joinedVariantRooms = {};
  final Set<int> _joinedDeliveryRooms = {};

  bool get isConnected => _isConnected;

  /// Connect to Socket.IO server
  void connect(String baseUrl) {
    try {
      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        developer.log('Socket.IO connected');
        _isConnected = true;
        _rejoinAllRooms();
      });

      _socket!.onDisconnect((_) {
        developer.log('Socket.IO disconnected');
        _isConnected = false;
      });

      _socket!.onConnectError((error) {
        developer.log('Socket.IO connection error: $error');
      });

      _socket!.connect();
    } catch (e) {
      developer.log('Error connecting to Socket.IO: $e');
    }
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    _joinedVariantRooms.clear();
    _joinedDeliveryRooms.clear();
  }

  /// Join variant room for price updates
  void joinVariantRoom(int variantId) {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('join_variant_room', {'variant_id': variantId});
    _joinedVariantRooms.add(variantId);

    developer.log('Joined variant room: $variantId');
  }

  /// Leave variant room
  void leaveVariantRoom(int variantId) {
    if (_socket == null) return;

    _socket!.emit('leave_variant_room', {'variant_id': variantId});
    _joinedVariantRooms.remove(variantId);

    developer.log('Left variant room: $variantId');
  }

  /// Join delivery room for live tracking
  void joinDeliveryRoom(int deliveryId) {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('join_delivery_room', {'delivery_id': deliveryId});
    _joinedDeliveryRooms.add(deliveryId);

    developer.log('Joined delivery room: $deliveryId');
  }

  /// Leave delivery room
  void leaveDeliveryRoom(int deliveryId) {
    if (_socket == null) return;

    _socket!.emit('leave_delivery_room', {'delivery_id': deliveryId});
    _joinedDeliveryRooms.remove(deliveryId);

    developer.log('Left delivery room: $deliveryId');
  }

  /// Re-join all rooms after reconnection
  void _rejoinAllRooms() {
    for (final variantId in _joinedVariantRooms) {
      _socket!.emit('join_variant_room', {'variant_id': variantId});
    }

    for (final deliveryId in _joinedDeliveryRooms) {
      _socket!.emit('join_delivery_room', {'delivery_id': deliveryId});
    }

    developer.log('Re-joined all rooms after reconnection');
  }

  /// Listen for price updates
  void onPriceUpdate(void Function(PriceUpdateEvent) callback) {
    _socket?.on('price_update', (data) {
      try {
        final event = PriceUpdateEvent.fromJson(data as Map<String, dynamic>);
        callback(event);
      } catch (e) {
        developer.log('Error parsing price update: $e');
      }
    });
  }

  /// Listen for inventory updates
  void onInventoryUpdate(void Function(InventoryUpdateEvent) callback) {
    _socket?.on('inventory_update', (data) {
      try {
        final event = InventoryUpdateEvent.fromJson(data as Map<String, dynamic>);
        callback(event);
      } catch (e) {
        developer.log('Error parsing inventory update: $e');
      }
    });
  }

  /// Listen for delivery location updates
  void onDeliveryLocationUpdate(void Function(DeliveryLocationEvent) callback) {
    _socket?.on('delivery_location_update', (data) {
      try {
        final event = DeliveryLocationEvent.fromJson(data as Map<String, dynamic>);
        callback(event);
      } catch (e) {
        developer.log('Error parsing delivery location update: $e');
      }
    });
  }
}
```

---

### 2. Socket Models

**File:** `lib/core/network/socket_models.dart`

```dart
class PriceUpdateEvent {
  final int variantId;
  final double newPrice;
  final double oldPrice;
  final double? discountedPrice;

  const PriceUpdateEvent({
    required this.variantId,
    required this.newPrice,
    required this.oldPrice,
    this.discountedPrice,
  });

  factory PriceUpdateEvent.fromJson(Map<String, dynamic> json) {
    return PriceUpdateEvent(
      variantId: json['variant_id'] as int,
      newPrice: (json['new_price'] as num).toDouble(),
      oldPrice: (json['old_price'] as num).toDouble(),
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
    );
  }
}

class InventoryUpdateEvent {
  final int variantId;
  final int currentQuantity;
  final int previousQuantity;
  final String stockUnit;
  final int warehouseId;

  const InventoryUpdateEvent({
    required this.variantId,
    required this.currentQuantity,
    required this.previousQuantity,
    required this.stockUnit,
    required this.warehouseId,
  });

  factory InventoryUpdateEvent.fromJson(Map<String, dynamic> json) {
    return InventoryUpdateEvent(
      variantId: json['variant_id'] as int,
      currentQuantity: json['current_quantity'] as int,
      previousQuantity: json['previous_quantity'] as int,
      stockUnit: json['stock_unit'] as String,
      warehouseId: json['warehouse_id'] as int,
    );
  }
}

class DeliveryLocationEvent {
  final int deliveryId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const DeliveryLocationEvent({
    required this.deliveryId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  factory DeliveryLocationEvent.fromJson(Map<String, dynamic> json) {
    return DeliveryLocationEvent(
      deliveryId: json['delivery_id'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
```

---

### 3. Socket Provider

**File:** `lib/core/network/socket_provider.dart`

```dart
final socketServiceProvider = Provider<SocketService>((ref) {
  final socketService = SocketService();

  // Connect on app startup
  socketService.connect(AppConfig.socketBaseUrl);

  // Disconnect on dispose
  ref.onDispose(() {
    socketService.disconnect();
  });

  return socketService;
});
```

---

## Rating & Review System

### 1. Review Bottom Sheet

**File:** `lib/features/category/presentation/components/widgets/review_bottom_sheet.dart`

```dart
class ReviewBottomSheet extends StatefulWidget {
  final String orderTitle;
  final DateTime deliveryDate;
  final Function(int stars, String? review) onSubmit;

  const ReviewBottomSheet({
    required this.orderTitle,
    required this.deliveryDate,
    required this.onSubmit,
    super.key,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int _selectedStars = 0;
  final _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.1),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          // Title
          AppText(
            text: 'Rate Your Order',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 8.h),
          AppText(
            text: widget.orderTitle,
            fontSize: 14.sp,
            color: AppColors.grey,
          ),
          AppText(
            text: 'Delivered on ${_formatDate(widget.deliveryDate)}',
            fontSize: 12.sp,
            color: AppColors.grey,
          ),
          SizedBox(height: 24.h),

          // Star rating selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStars = starNumber;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    starNumber <= _selectedStars
                        ? Icons.star
                        : Icons.star_border,
                    size: 40.sp,
                    color: starNumber <= _selectedStars
                        ? AppColors.ratingYellow
                        : AppColors.grey,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),

          // Review text input (optional)
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write a review (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedStars > 0
                  ? () {
                      widget.onSubmit(
                        _selectedStars,
                        _reviewController.text.isNotEmpty
                            ? _reviewController.text
                            : null,
                      );
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: AppText(
                text: 'Submit Rating',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
```

---

### 2. Rating Submission Integration

**Show Review Bottom Sheet After Delivery:**
```dart
void _handleDeliveryCompleted(int orderId, DeliveryEntity delivery) {
  // Stop polling
  _pollingTimer?.cancel();

  state = DeliveryStatusState.completed(
    orderId: orderId,
    delivery: delivery,
  );

  // Show rating feedback popup
  _showRatingFeedbackPopup(orderId, delivery);

  // Save to storage
  _storageService.saveDeliveryTracking(/* ... */);

  // Auto-hide after 10 seconds
  _scheduleAutoHide();
}

void _showRatingFeedbackPopup(int orderId, DeliveryEntity delivery) {
  // Show bottom sheet after a short delay
  Future.delayed(const Duration(milliseconds: 500), () {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isScrollControlled: true,
      builder: (context) => ReviewBottomSheet(
        orderTitle: 'Order #$orderId',
        deliveryDate: delivery.updatedAt,
        onSubmit: (stars, review) async {
          try {
            await ref.read(ordersApiProvider).submitOrderRating(
                  orderId: orderId,
                  stars: stars,
                  body: review,
                );

            // Refresh completed orders to show new rating
            ref.read(ordersProvider.notifier).fetchCompletedOrders();

            // Show success message
            AppSnackbar.success(
              navigatorKey.currentContext!,
              'Thank you for your feedback!',
            );
          } catch (e) {
            AppSnackbar.error(
              navigatorKey.currentContext!,
              'Failed to submit rating. Please try again.',
            );
          }
        },
      ),
    );
  });
}
```

---

### 3. Rating Display in Orders List

**Previous Order Card with Rating:**
```dart
class PreviousOrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onReorder;
  final Function(int stars, String? review) onRatingSubmit;

  const PreviousOrderCard({
    required this.order,
    required this.onReorder,
    required this.onRatingSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text('Order #${order.id}'),
        subtitle: Text(order.formattedDate),
        trailing: Text(order.formattedTotal),
        children: [
          // Order items
          ...order.orderLines.map((line) => OrderLineItem(line: line)),

          Divider(),

          // Rating section
          if (order.rating != null)
            _buildExistingRating(context)
          else
            _buildRatingPrompt(context),

          SizedBox(height: 8.h),

          // Reorder button
          ElevatedButton.icon(
            onPressed: onReorder,
            icon: Icon(Icons.replay),
            label: Text('Reorder'),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingRating(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < order.rating!.stars
                      ? Icons.star
                      : Icons.star_border,
                  color: AppColors.ratingYellow,
                  size: 20.sp,
                );
              }),
              SizedBox(width: 8.w),
              Text('${order.rating!.stars}/5'),
            ],
          ),
          if (order.rating!.hasReview) ...[
            SizedBox(height: 8.h),
            Text(
              order.rating!.body!,
              style: TextStyle(color: AppColors.grey),
            ),
          ],
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => _showEditRating(context),
            child: Text('Edit Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingPrompt(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text('How was your order?'),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: () => _showRatingDialog(context),
            icon: Icon(Icons.star_border),
            label: Text('Write a review'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReviewBottomSheet(
        orderTitle: 'Order #${order.id}',
        deliveryDate: order.updatedAt,
        onSubmit: onRatingSubmit,
      ),
    );
  }

  void _showEditRating(BuildContext context) {
    // Same as _showRatingDialog but pre-fill with existing rating
  }
}
```

---

## Home Page Order Status Display

### 1. Delivery Status Bar Component

**File:** `lib/features/home/presentation/components/delivery_status_bar.dart`

```dart
class DeliveryStatusBar extends ConsumerWidget {
  const DeliveryStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryStatusProvider);

    return deliveryState.when(
      hidden: () => const SizedBox.shrink(),
      loading: (orderId) => _buildLoadingState(orderId),
      active: (orderId, status, delivery) =>
          _buildActiveState(orderId, status, delivery, ref),
      completed: (orderId, delivery) =>
          _buildCompletedState(orderId, delivery, ref),
      failed: (orderId, delivery, reason) =>
          _buildFailedState(orderId, delivery, reason, ref),
      error: (orderId, message) => _buildErrorState(orderId, message),
    );
  }

  Widget _buildLoadingState(int orderId) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.1),
            AppColors.primaryGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              ),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 16.w,
              height: 16.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Waiting for store to accept your order',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 4.h),
                AppText(
                  text: 'Order #$orderId',
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveState(
    int orderId,
    DeliveryApiStatus status,
    DeliveryEntity delivery,
    WidgetRef ref,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.1),
            AppColors.primaryGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryGreen),
      ),
      child: Row(
        children: [
          // Status icon with badge
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: AppColors.white,
                  size: 24.sp,
                ),
              ),
              if (status == DeliveryApiStatus.outForDelivery)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: AppText(
                      text: delivery.estimatedTimeDisplay,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: delivery.statusDisplay,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 4.h),
                AppText(
                  text: 'Order #$orderId',
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
                if (delivery.deliveryPartnerName != null) ...[
                  SizedBox(height: 4.h),
                  AppText(
                    text: 'Delivery by ${delivery.deliveryPartnerName}',
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Refresh delivery status
              ref
                  .read(deliveryStatusProvider.notifier)
                  ._refreshDeliveryStatus(orderId);
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(
    int orderId,
    DeliveryEntity delivery,
    WidgetRef ref,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successGreen.withValues(alpha: 0.1),
            AppColors.successGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.successGreen),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: AppColors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Delivered successfully',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
                SizedBox(height: 4.h),
                AppText(
                  text: 'Order #$orderId',
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(deliveryStatusProvider.notifier).hideDeliveryStatus();
            },
            icon: Icon(
              Icons.close,
              size: 20.sp,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedState(
    int orderId,
    DeliveryEntity delivery,
    String? reason,
    WidgetRef ref,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.errorRed.withValues(alpha: 0.1),
            AppColors.errorRed.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.errorRed),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.errorRed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Delivery failed',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorRed,
                ),
                SizedBox(height: 4.h),
                AppText(
                  text: reason ?? 'Please contact support',
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(deliveryStatusProvider.notifier).hideDeliveryStatus();
            },
            icon: Icon(
              Icons.close,
              size: 20.sp,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(int orderId, String message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text('Error: $message'),
    );
  }

  IconData _getStatusIcon(DeliveryApiStatus status) {
    switch (status) {
      case DeliveryApiStatus.pending:
      case DeliveryApiStatus.assigned:
        return Icons.assignment_turned_in;
      case DeliveryApiStatus.atPickup:
        return Icons.inventory_2;
      case DeliveryApiStatus.pickedUp:
        return Icons.shopping_bag;
      case DeliveryApiStatus.outForDelivery:
        return Icons.local_shipping;
      case DeliveryApiStatus.delivered:
        return Icons.check_circle;
      case DeliveryApiStatus.failed:
        return Icons.error;
    }
  }
}
```

---

### 2. Home Screen Integration

**File:** `lib/features/home/presentation/screen/home_screen.dart`

```dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize location
    ref.read(locationProvider.notifier).initialize();

    // Restore delivery tracking from Hive storage
    Future.microtask(() {
      ref.read(deliveryStatusProvider.notifier).restoreDeliveryFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          _buildAppBar(),

          // Delivery status bar (at top)
          SliverToBoxAdapter(
            child: DeliveryStatusBar(),
          ),

          // Address selection
          SliverToBoxAdapter(
            child: AddressSelector(),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: SearchBar(),
          ),

          // Banners
          SliverToBoxAdapter(
            child: BannerCarousel(),
          ),

          // Rest of home screen content
          // ...
        ],
      ),
    );
  }
}
```

---

## Reorder Functionality

### Implementation

**File:** `lib/features/orders/presentation/screens/orders_screen.dart`

```dart
Future<void> _handleReorder(OrderEntity order) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Step 1: Fetch order lines from API
    final ordersApi = ref.read(ordersApiProvider);
    final orderLines = await ordersApi.getOrderLines(order.id.toString());

    // Step 2: Add each item to cart
    final checkoutLineNotifier = ref.read(checkoutLineControllerProvider.notifier);

    int successCount = 0;
    int failureCount = 0;

    for (final orderLine in orderLines) {
      try {
        if (orderLine.productVariantId > 0) {
          await checkoutLineNotifier.addToCart(
            productVariantId: orderLine.productVariantId,
            quantity: orderLine.quantity,
          );
          successCount++;
        }
      } catch (e) {
        developer.log('Failed to add item ${orderLine.productName}: $e');
        failureCount++;
      }
    }

    // Close loading dialog
    Navigator.pop(context);

    // Step 3: Show result
    if (successCount > 0) {
      AppSnackbar.success(
        context,
        '$successCount items added to cart',
      );

      if (failureCount > 0) {
        AppSnackbar.warning(
          context,
          '$failureCount items unavailable',
        );
      }

      // Step 4: Navigate to cart
      _navigateToCart();
    } else {
      AppSnackbar.error(
        context,
        'Failed to add items to cart',
      );
    }
  } catch (e) {
    // Close loading dialog
    Navigator.pop(context);

    AppSnackbar.error(
      context,
      'Failed to reorder: ${e.toString()}',
    );
  }
}

void _navigateToCart() {
  // Navigate to cart tab using bottom navigation
  ref.read(bottomNavIndexProvider.notifier).state = 1; // Cart tab index
}
```

---

## Payment to Order Tracking Flow

### Complete Flow Diagram

```
1. User completes payment in Razorpay
   ↓
2. PaymentController.verifyPayment()
   └─> POST /api/order/v1/payment/verify/
   └─> Backend validates signature
   └─> Order status changes to 'active'
   ↓
3. Navigate to ConfirmOrderScreen
   ↓
4. ConfirmOrderScreen.initState()
   └─> _fetchLatestOrderAndStartTracking()
   ↓
5. ordersProvider.fetchActiveOrders()
   └─> GET /api/order/v1/orders/?status=active
   └─> Get latest order (results[0])
   ↓
6. deliveryStatusProvider.startDeliveryTracking(orderId)
   └─> Save orderId to state
   └─> Start 30-second polling timer
   └─> Call _refreshDeliveryStatus()
   ↓
7. Polling: GET /api/delivery/v1/deliveries/?order={orderId}
   ↓
   ├─> Response: 0 results (store hasn't accepted)
   │   └─> State: DeliveryStatusState.loading(orderId)
   │   └─> Save to Hive: status='loading'
   │   └─> Continue polling every 30s
   ↓
   ├─> Response: 1 result (delivery created)
   │   ├─> Status: pending/assigned
   │   │   └─> State: DeliveryStatusState.active()
   │   │   └─> Save to Hive: status='assigned'
   │   │
   │   ├─> Status: at_pickup/picked_up/out_for_delivery
   │   │   └─> State: DeliveryStatusState.active()
   │   │   └─> Update DeliveryStatusBar on HomeScreen
   │   │   └─> Continue polling
   │   │
   │   ├─> Status: delivered
   │   │   └─> State: DeliveryStatusState.completed()
   │   │   └─> Stop polling
   │   │   └─> Show ReviewBottomSheet
   │   │   └─> Auto-hide after 10 seconds
   │   │   └─> Clear Hive storage
   │   │
   │   └─> Status: failed
   │       └─> State: DeliveryStatusState.failed()
   │       └─> Stop polling
   │       └─> Show failure message
   │       └─> Clear Hive storage
   ↓
8. Navigate to HomeScreen
   └─> DeliveryStatusBar watches deliveryStatusProvider
   └─> Displays live status updates
   └─> Polling continues in background
   ↓
9. On app restart:
   └─> HomeScreen.initState()
   └─> deliveryStatusProvider.restoreDeliveryFromStorage()
   └─> Read from Hive
   └─> If active delivery exists:
       └─> startDeliveryTracking(orderId)
       └─> Resume polling from last known state
```

---

## Complete Implementation Guide

### Step 1: Set Up Domain Layer

**1.1 Create Order Entities**

```dart
// lib/features/orders/domain/entities/order_entity.dart

class OrderEntity extends Equatable {
  final int id;
  final String status;
  final String totalAmount;
  final int orderlinesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderAddressEntity? deliveryAddress;
  final List<OrderLineEntity> orderLines;
  final OrderRatingEntity? rating;

  const OrderEntity({ /* ... */ });

  // Status helpers
  bool get isActive => [
        'active',
        'shipped',
        'processing',
        'out_for_delivery',
      ].contains(status.toLowerCase());

  bool get isCompleted => [
        'completed',
        'delivered',
      ].contains(status.toLowerCase());
}
```

**1.2 Create Delivery Entity**

```dart
// lib/features/home/domain/entities/delivery.dart

enum DeliveryApiStatus {
  pending,
  assigned,
  atPickup,
  pickedUp,
  outForDelivery,
  delivered,
  failed,
}

class DeliveryEntity extends Equatable {
  final int id;
  final int orderId;
  final DeliveryApiStatus status;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? estimatedTime;
  final DeliveryLocation? currentLocation;
  final String? notes;
  final String? proofOfDelivery;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryEntity({ /* ... */ });

  String get statusDisplay { /* ... */ }
  String get estimatedTimeDisplay { /* ... */ }
  bool get isActive { /* ... */ }
}
```

---

### Step 2: Set Up Infrastructure Layer

**2.1 Create API Clients**

```dart
// Orders API
class OrdersApi {
  final ApiClient _apiClient;

  Future<List<OrderEntity>> getOrders({String? status, int page = 1}) async {
    final response = await _apiClient.get(
      ApiEndpoints.orders,
      queryParameters: {
        'page': page,
        if (status != null) 'status': status,
      },
    );
    // Parse and return
  }

  Future<List<OrderLineEntity>> getOrderLines(String orderId) async {
    final response = await _apiClient.get(
      ApiEndpoints.orderLinesByOrder(orderId),
    );
    // Parse and return
  }

  Future<void> submitOrderRating({
    required int orderId,
    required int stars,
    String? body,
    int? ratingId,
  }) async {
    // Smart POST/PATCH logic
  }
}

// Delivery API
class DeliveryApi {
  final ApiClient _apiClient;

  Future<DeliveryEntity?> getDeliveryStatus(int orderId) async {
    final response = await _apiClient.get(
      '/api/delivery/v1/deliveries/',
      queryParameters: {'order': orderId},
    );

    final results = response.data['results'] as List;
    if (results.isEmpty) return null;

    return DeliveryDto.fromJson(results.first).toDomain();
  }
}
```

**2.2 Create Delivery Storage Service**

```dart
class DeliveryStorageService {
  final Box<dynamic> _box;

  Future<void> saveDeliveryTracking(DeliveryTrackingData data) async {
    await _box.put('active_delivery', data.toJson());
  }

  Future<DeliveryTrackingData?> getActiveDeliveryTracking() async {
    final json = _box.get('active_delivery');
    if (json == null) return null;
    final data = DeliveryTrackingData.fromJson(json);
    return data.isActive ? data : null;
  }

  Future<void> clearDeliveryTracking() async {
    await _box.delete('active_delivery');
  }
}
```

---

### Step 3: Set Up Application Layer

**3.1 Create Orders State & Notifier**

```dart
class OrdersState {
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? errorMessage;
  final String? activeFilter;

  List<OrderEntity> get activeOrders => /* filter */;
  List<OrderEntity> get completedOrders => /* filter */;
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  Future<void> fetchActiveOrders() async {
    await fetchOrders(status: 'active');
  }

  Future<void> fetchCompletedOrders() async {
    // Fetch orders + ratings
  }
}
```

**3.2 Create Delivery Status Notifier**

```dart
class DeliveryStatusNotifier extends StateNotifier<DeliveryStatusState> {
  Timer? _pollingTimer;

  Future<void> startDeliveryTracking(int orderId) async {
    state = DeliveryStatusState.loading(orderId);
    _startPolling(orderId);
    await _refreshDeliveryStatus(orderId);
  }

  void _startPolling(int orderId) {
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _refreshDeliveryStatus(orderId);
    });
  }

  Future<void> _refreshDeliveryStatus(int orderId) async {
    final delivery = await _deliveryApi.getDeliveryStatus(orderId);

    if (delivery == null) {
      state = DeliveryStatusState.loading(orderId);
    } else if (delivery.isCompleted) {
      _handleDeliveryCompleted(orderId, delivery);
    } else {
      _handleDeliveryActive(orderId, delivery);
    }
  }
}
```

---

### Step 4: Set Up Presentation Layer

**4.1 Orders Screen**

```dart
class OrdersScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(tabs: ['Active', 'Previous']),
      ),
      body: TabBarView(
        children: [
          _buildActiveOrdersTab(ordersState),
          _buildPreviousOrdersTab(ordersState),
        ],
      ),
    );
  }
}
```

**4.2 Delivery Status Bar**

```dart
class DeliveryStatusBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryStatusProvider);

    return deliveryState.when(
      hidden: () => SizedBox.shrink(),
      loading: (orderId) => _buildLoadingState(orderId),
      active: (orderId, status, delivery) => _buildActiveState(orderId, status, delivery),
      completed: (orderId, delivery) => _buildCompletedState(orderId, delivery),
      failed: (orderId, delivery, reason) => _buildFailedState(orderId, delivery, reason),
      error: (orderId, message) => _buildErrorState(orderId, message),
    );
  }
}
```

**4.3 Home Screen Integration**

```dart
class HomeScreen extends ConsumerStatefulWidget {
  @override
  void initState() {
    super.initState();

    // Restore delivery tracking
    Future.microtask(() {
      ref.read(deliveryStatusProvider.notifier).restoreDeliveryFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Delivery status bar at top
          SliverToBoxAdapter(child: DeliveryStatusBar()),

          // Rest of content
          // ...
        ],
      ),
    );
  }
}
```

---

## Summary

This comprehensive order management system provides:

1. **Order Listing**: Active and previous orders with status filtering
2. **Live Tracking**: 30-second polling with 10-minute intervals for estimated time
3. **Real-Time Updates**: Socket.IO for price/inventory (not delivery tracking)
4. **Rating & Review**: Post-delivery feedback with smart POST/PATCH fallback
5. **Home Page Display**: Live status bar with auto-hide on completion
6. **Reorder**: One-tap reorder with partial success handling
7. **Persistent Tracking**: Hive storage for app restart recovery
8. **Complete Flow**: Payment → Verification → Tracking → Rating

Follow this guide to implement the complete order management system in your new project with different UI.

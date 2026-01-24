# Grocery App - API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Base Configuration](#base-configuration)
3. [Authentication Flow](#authentication-flow)
4. [Guest Mode vs Authenticated Mode](#guest-mode-vs-authenticated-mode)
5. [Making API Calls](#making-api-calls)
6. [Available Endpoints](#available-endpoints)
7. [Error Handling](#error-handling)
8. [Code Examples](#code-examples)

---

## Overview

This Flutter grocery app uses a **session-based authentication system** with support for both **guest mode** (unauthenticated browsing) and **authenticated mode** (logged-in users). The backend is a Django REST API that uses cookies for session management and CSRF tokens for security.

### Key Technologies
- **HTTP Client:** Dio
- **State Management:** Riverpod
- **Session Storage:** PersistCookieJar (cookie_jar package)
- **Local Storage:** Hive
- **Architecture:** Clean Architecture with Repository Pattern

---

## Base Configuration

### API Configuration
**File:** [lib/core/config/app_config.dart](lib/core/config/app_config.dart)

```dart
class AppConfig {
  static const String apiBaseUrl = 'http://156.67.104.149:8012';
  static const String cdnBaseUrl = 'https://grocery-application.b-cdn.net';
  static const String websocketUrl = 'http://156.67.104.149:8012';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
```

### HTTP Client Setup
**File:** [lib/core/network/api_client.dart](lib/core/network/api_client.dart)

The `ApiClient` class wraps Dio and handles:
- Cookie-based session management
- CSRF token injection
- Guest mode detection
- Request/response interceptors
- Error handling

```dart
final apiClient = ApiClient(
  baseUrl: AppConfig.apiBaseUrl,
  cookieJar: cookieJar,
);
```

---

## Authentication Flow

### Session Management

The app uses **cookies** to maintain user sessions:

1. **Login/Signup** → Server sets `sessionid` cookie
2. **Subsequent requests** → Cookie automatically sent by cookie_jar
3. **CSRF Protection** → `X-CSRFToken` header extracted from cookies
4. **Logout** → All cookies cleared

### Cookie Storage Location
- **Android/iOS:** App documents directory
- **Web:** Browser cookies
- **Managed by:** `PersistCookieJar` package

### Authentication States
**File:** [lib/features/auth/application/states/auth_state.dart](lib/features/auth/application/states/auth_state.dart)

```dart
sealed class AuthState {}

class AuthChecking extends AuthState {}      // Initial session check
class GuestMode extends AuthState {}         // Browsing without login
class AuthLoading extends AuthState {}       // Login/signup in progress
class OtpSending extends AuthState {}        // OTP request sent
class OtpSent extends AuthState {}          // Waiting for OTP verification
class OtpVerifying extends AuthState {}     // Verifying OTP
class Authenticated extends AuthState {}    // Successfully logged in
class AuthError extends AuthState {}        // Error occurred
```

---

## Guest Mode vs Authenticated Mode

### Guest Mode (Unauthenticated)

**How to Enable:**
```dart
// In AuthProvider
ref.read(authProvider.notifier).continueAsGuest();
```

**Headers Sent:**
```http
Content-Type: application/json
dev: 2
```

**Capabilities:**
- ✅ Browse products
- ✅ View categories
- ✅ Search products
- ✅ View product details
- ❌ Add to cart
- ❌ Place orders
- ❌ Manage wishlist
- ❌ View profile

**Code Check:**
```dart
// ApiClient automatically detects guest mode
if (isGuest) {
  options.headers['dev'] = '2';  // Guest header
}
```

### Authenticated Mode (Logged-In User)

**How to Enable:**
```dart
// Login via username/password
await ref.read(authProvider.notifier).login(
  username: 'user123',
  password: 'secure_password',
);

// Or login via OTP
await ref.read(authProvider.notifier).sendOtp('+1234567890');
await ref.read(authProvider.notifier).verifyOtp('+1234567890', '123456');
```

**Headers Sent:**
```http
Content-Type: application/json
X-CSRFToken: <csrf_token_from_cookies>
Cookie: sessionid=<session_cookie>
```

**Capabilities:**
- ✅ All guest mode features
- ✅ Add to cart
- ✅ Place orders
- ✅ Manage wishlist
- ✅ View/edit profile
- ✅ Manage addresses
- ✅ Track deliveries

**How CSRF Token is Retrieved:**
```dart
Future<String?> getCsrfToken(String url) async {
  final cookies = await cookieJar.loadForRequest(Uri.parse(url));

  // Find cookie with 'csrf' in name (case-insensitive)
  final csrfCookie = cookies.firstWhereOrNull(
    (c) => c.name.toLowerCase().contains('csrf'),
  );

  return csrfCookie?.value;
}
```

---

## Making API Calls

### Basic Pattern

All API calls follow this flow:

```
UI → Provider → Repository → Remote Data Source → ApiClient → Backend
```

### 1. GET Request (Fetch Data)

**Example: Fetch Categories**

```dart
// Remote Data Source
class CategoryRemoteDataSource {
  final ApiClient _apiClient;

  Future<PaginatedResult<CategoryDto>> getCategories({int page = 1}) async {
    final response = await _apiClient.get(
      '/api/products/v1/category/',
      queryParameters: {'page': page},
    );

    return PaginatedResult.fromJson(
      response.data,
      (json) => CategoryDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
```

**HTTP Request:**
```http
GET http://156.67.104.149:8012/api/products/v1/category/?page=1
Content-Type: application/json
dev: 2  (if guest mode)
X-CSRFToken: <token>  (if authenticated)
```

**Response:**
```json
{
  "count": 10,
  "next": "/api/products/v1/category/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "Fruits",
      "description": "Fresh fruits",
      "image_url": "https://..."
    }
  ]
}
```

### 2. POST Request (Create Resource)

**Example: Add to Cart**

```dart
Future<CheckoutLineDto> addToCart({
  required int productVariantId,
  required int quantity,
}) async {
  final response = await _apiClient.post(
    '/api/order/v1/checkout-lines/',
    data: {
      'product_variant_id': productVariantId,
      'quantity': quantity,
    },
  );

  return CheckoutLineDto.fromJson(response.data);
}
```

**HTTP Request:**
```http
POST http://156.67.104.149:8012/api/order/v1/checkout-lines/
Content-Type: application/json
X-CSRFToken: <token>

{
  "product_variant_id": 42,
  "quantity": 2
}
```

**Response:**
```json
{
  "id": 1,
  "product_variant_id": 42,
  "quantity": 2,
  "checkout_id": 5
}
```

### 3. PATCH Request (Update Resource)

**Example: Update Cart Quantity**

```dart
Future<CheckoutLineDto> updateQuantity({
  required int lineId,
  required int productVariantId,
  required int quantity,
}) async {
  final response = await _apiClient.patch(
    '/api/order/v1/checkout-lines/$lineId/',
    data: {
      'product_variant_id': productVariantId,
      'quantity': quantity,
    },
  );

  return CheckoutLineDto.fromJson(response.data);
}
```

**HTTP Request:**
```http
PATCH http://156.67.104.149:8012/api/order/v1/checkout-lines/1/
Content-Type: application/json
X-CSRFToken: <token>

{
  "product_variant_id": 42,
  "quantity": 3
}
```

### 4. DELETE Request (Remove Resource)

**Example: Remove from Cart**

```dart
Future<void> deleteCheckoutLine(int lineId) async {
  await _apiClient.delete('/api/order/v1/checkout-lines/$lineId/');
}
```

**HTTP Request:**
```http
DELETE http://156.67.104.149:8012/api/order/v1/checkout-lines/1/
X-CSRFToken: <token>
```

### 5. Conditional Requests (Cache Optimization)

**Example: Fetch Product Details with Cache**

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

  // 304 Not Modified = data hasn't changed, use cache
  if (response.statusCode == 304) {
    return null;
  }

  // Return new data with cache headers
  return ProductDetailRemoteResponse(
    productDetail: ProductVariantDto.fromJson(response.data),
    eTag: response.headers.value('etag'),
    lastModified: response.headers.value('last-modified'),
  );
}
```

**HTTP Request:**
```http
GET http://156.67.104.149:8012/api/products/v1/variants/42/
If-None-Match: "abc123xyz"
If-Modified-Since: Wed, 15 Jan 2025 10:00:00 GMT
```

**Responses:**

**Case 1: Data unchanged (304 Not Modified)**
```http
HTTP/1.1 304 Not Modified
ETag: "abc123xyz"
Last-Modified: Wed, 15 Jan 2025 10:00:00 GMT
```

**Case 2: Data changed (200 OK)**
```http
HTTP/1.1 200 OK
ETag: "def456uvw"
Last-Modified: Thu, 16 Jan 2025 12:30:00 GMT

{
  "id": 42,
  "name": "Fresh Apple",
  "price": "2.99"
}
```

---

## Available Endpoints

### Authentication Endpoints
**Base:** `/api/auth/v1/`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/signin/` | Login with username/password | ❌ |
| POST | `/signup/` | Register new user | ❌ |
| POST | `/send-otp/` | Request OTP for phone | ❌ |
| POST | `/verify-otp/` | Verify OTP code | ❌ |
| POST | `/reset-password/` | Reset password | ✅ |
| GET | `/profile/` | Get user profile | ✅ |
| PATCH | `/profile/` | Update profile | ✅ |
| GET | `/address/` | List addresses | ✅ |
| POST | `/address/` | Add address | ✅ |
| PATCH | `/address/{id}/` | Update address | ✅ |
| DELETE | `/delete-account/` | Delete account | ✅ |

### Product Endpoints
**Base:** `/api/products/v1/`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/category/` | List categories | ❌ |
| GET | `/` | List products | ❌ |
| GET | `/variants/` | List product variants | ❌ |
| GET | `/variants/{id}/` | Get variant details | ❌ |
| GET | `/variants/discounts/` | Get discounted products | ❌ |
| GET | `/banners/` | Get promotional banners | ❌ |

### Order Endpoints
**Base:** `/api/order/v1/`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/checkouts/` | List checkouts | ✅ |
| POST | `/checkouts/` | Create checkout | ✅ |
| GET | `/checkout-lines/` | List cart items | ✅ |
| POST | `/checkout-lines/` | Add to cart | ✅ |
| PATCH | `/checkout-lines/{id}/` | Update cart item | ✅ |
| DELETE | `/checkout-lines/{id}/` | Remove from cart | ✅ |
| GET | `/orders/` | List orders | ✅ |
| POST | `/orders/` | Place order | ✅ |
| GET | `/orders/{id}/` | Get order details | ✅ |
| POST | `/payment/verify/` | Verify payment | ✅ |
| GET | `/wishlist/` | Get wishlist | ✅ |
| POST | `/wishlist/` | Add to wishlist | ✅ |
| DELETE | `/wishlist/{id}/` | Remove from wishlist | ✅ |

### Delivery Endpoints
**Base:** `/api/delivery/v1/`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/deliveries/` | List deliveries | ✅ |
| GET | `/deliveries/{id}/` | Get delivery details | ✅ |

---

## Error Handling

### Error Types
**File:** [lib/core/network/network_exceptions.dart](lib/core/network/network_exceptions.dart)

```dart
enum NetworkErrorType {
  noInternet,        // No connectivity
  timeout,           // Connection/receive timeout
  serverError,       // 5xx responses
  clientError,       // 4xx responses
  unknown,           // Other errors
}
```

### Exception Handling

```dart
try {
  final response = await _apiClient.post('/api/order/v1/checkout-lines/', data: {...});
  return CheckoutLineDto.fromJson(response.data);
} on NetworkException catch (error) {
  // Handle specific errors
  if (error.statusCode == 400 && error.body is Map) {
    if (error.body['quantity'] != null) {
      throw InsufficientStockException(error.body['quantity'].first);
    }
  }
  rethrow;
} catch (e) {
  throw NetworkException(
    message: 'Failed to add to cart',
    errorType: NetworkErrorType.unknown,
  );
}
```

### Common Error Responses

**400 Bad Request:**
```json
{
  "message": "Invalid input",
  "errors": {
    "quantity": ["Insufficient stock available"]
  }
}
```

**401 Unauthorized:**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**403 Forbidden:**
```json
{
  "detail": "You do not have permission to perform this action."
}
```

**404 Not Found:**
```json
{
  "detail": "Not found."
}
```

**500 Server Error:**
```json
{
  "detail": "Internal server error"
}
```

---

## Code Examples

### Example 1: Login Flow

```dart
// 1. UI calls provider
await ref.read(authProvider.notifier).login(
  username: 'john_doe',
  password: 'secure_pass123',
);

// 2. Provider calls repository
final result = await authRepository.login(
  username: username,
  password: password,
);

// 3. Repository calls remote API
Future<UserEntity> login({
  required String username,
  required String password,
}) async {
  final response = await _apiClient.post(
    '/api/auth/v1/signin/',
    data: {
      'username': username,
      'password': password,
    },
  );

  final user = UserEntity.fromJson(response.data['user']);

  // 4. Save session cookie (automatic via cookie_jar)
  // 5. Validate session exists
  final session = await _localDs.getValidSession(_apiClient.baseUrl);
  if (session == null) {
    throw Exception('Failed to establish session');
  }

  // 6. Save user locally
  await _localDs.saveUser(user);

  return user;
}
```

**HTTP Request:**
```http
POST http://156.67.104.149:8012/api/auth/v1/signin/
Content-Type: application/json

{
  "username": "john_doe",
  "password": "secure_pass123"
}
```

**Response:**
```http
HTTP/1.1 200 OK
Set-Cookie: sessionid=xyz123abc; Path=/; HttpOnly
Set-Cookie: csrftoken=abc456def; Path=/

{
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone_number": "+1234567890"
  }
}
```

### Example 2: OTP Login Flow

```dart
// Step 1: Send OTP
await ref.read(authProvider.notifier).sendOtp('+1234567890');

// Remote API call
Future<String> sendOtp({required String phoneNumber}) async {
  final response = await _apiClient.post(
    '/api/auth/v1/send-otp/',
    data: {'phone_number': phoneNumber},
  );
  return response.data['message'];
}

// Step 2: Verify OTP (within 5 minutes)
await ref.read(authProvider.notifier).verifyOtp('+1234567890', '123456');

// Remote API call
Future<UserEntity> verifyOTP({
  required String phoneNumber,
  required String otp,
}) async {
  final response = await _apiClient.post(
    '/api/auth/v1/verify-otp/',
    data: {
      'phone_number': phoneNumber,
      'otp_code': otp,
    },
  );

  final user = UserEntity.fromJson(response.data['user']);
  await _localDs.saveUser(user);
  return user;
}
```

### Example 3: Fetch Products with Pagination

```dart
// Provider setup
@riverpod
class ProductVariants extends _$ProductVariants {
  int _currentPage = 1;

  @override
  FutureOr<PaginatedResult<ProductVariant>> build() {
    return _fetchProducts(page: _currentPage);
  }

  Future<PaginatedResult<ProductVariant>> _fetchProducts({
    required int page,
  }) async {
    final repository = ref.read(productVariantRepositoryProvider);
    final result = await repository.getProductVariants(page: page);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) => data,
    );
  }

  Future<void> loadMore() async {
    _currentPage++;
    state = await AsyncValue.guard(() => _fetchProducts(page: _currentPage));
  }
}

// Repository
Future<Either<Failure, PaginatedResult<ProductVariant>>> getProductVariants({
  int page = 1,
}) async {
  try {
    final result = await _remoteDataSource.getProductVariants(page: page);
    return Right(result.toDomain());
  } catch (e) {
    return Left(mapDioError(e));
  }
}

// Remote Data Source
Future<PaginatedResult<ProductVariantDto>> getProductVariants({
  int page = 1,
}) async {
  final response = await _apiClient.get(
    '/api/products/v1/variants/',
    queryParameters: {'page': page},
  );

  return PaginatedResult.fromJson(
    response.data,
    (json) => ProductVariantDto.fromJson(json as Map<String, dynamic>),
  );
}
```

### Example 4: Add to Cart (Authenticated Only)

```dart
// UI
try {
  await ref.read(checkoutLineNotifierProvider.notifier).addToCart(
    productVariantId: 42,
    quantity: 2,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Added to cart')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}

// Provider
Future<void> addToCart({
  required int productVariantId,
  required int quantity,
}) async {
  state = const AsyncValue.loading();

  final result = await _repository.addToCart(
    productVariantId: productVariantId,
    quantity: quantity,
  );

  result.fold(
    (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
    (checkoutLine) {
      // Refresh cart
      ref.invalidate(checkoutLinesProvider);
      state = const AsyncValue.data(null);
    },
  );
}

// Remote API
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
    if (error.statusCode == 400 && error.body is Map) {
      if (error.body['quantity'] != null) {
        throw InsufficientStockException(error.body['quantity'].first);
      }
    }
    rethrow;
  }
}
```

**HTTP Request:**
```http
POST http://156.67.104.149:8012/api/order/v1/checkout-lines/
Content-Type: application/json
X-CSRFToken: abc456def
Cookie: sessionid=xyz123abc

{
  "product_variant_id": 42,
  "quantity": 2
}
```

### Example 5: Guest Mode to Authenticated Transition

```dart
// User browsing as guest
final authState = ref.watch(authProvider);
if (authState is GuestMode) {
  // Show limited UI
}

// User tries to add to cart
onPressed: () async {
  final authState = ref.read(authProvider);

  if (authState is! Authenticated) {
    // Redirect to login
    Navigator.pushNamed(context, '/login');
    return;
  }

  // Proceed with authenticated action
  await ref.read(checkoutLineNotifierProvider.notifier).addToCart(
    productVariantId: productVariantId,
    quantity: 1,
  );
}

// After login, session cookies are stored
// All subsequent requests automatically include:
// - Cookie: sessionid=xyz123abc
// - X-CSRFToken: abc456def
```

### Example 6: Logout Flow

```dart
// UI
await ref.read(authProvider.notifier).logout();
Navigator.pushReplacementNamed(context, '/login');

// Provider
Future<void> logout() async {
  state = const AuthLoading();

  // 1. Clear cookies
  await _authRepository.logout();

  // 2. Clear local user data
  await _clearUserData();

  // 3. Invalidate all cached data
  ref.invalidate(checkoutLinesProvider);
  ref.invalidate(ordersProvider);
  ref.invalidate(profileProvider);

  // 4. Return to initial state
  state = const AuthInitial();
}

// Repository
Future<void> logout() async {
  await _localDs.clearCookies();
  await _localDs.saveUser(null);
}
```

---

## Summary

### Guest Mode Workflow
```
1. App Launch
   ↓
2. User taps "Continue as Guest"
   ↓
3. All API calls include header: dev: 2
   ↓
4. User can browse products (read-only)
   ↓
5. To perform actions (cart, orders), must login
```

### Authenticated Workflow
```
1. User Login/Signup
   ↓
2. Server returns sessionid cookie
   ↓
3. Cookie stored in PersistCookieJar
   ↓
4. CSRF token extracted from cookies
   ↓
5. All API calls include:
   - Cookie: sessionid=...
   - X-CSRFToken: ...
   ↓
6. Full app functionality unlocked
   ↓
7. On logout, cookies cleared
```

### Key Points to Remember

1. **Always check auth state** before making authenticated API calls
2. **CSRF token is required** for POST/PATCH/DELETE in authenticated mode
3. **Guest mode uses `dev: 2` header** instead of CSRF token
4. **Cookies are managed automatically** by PersistCookieJar
5. **Session validation** happens on app launch via `_checkExistingSession()`
6. **Error handling** should map network errors to user-friendly messages
7. **Cache headers** (ETag, If-Modified-Since) reduce bandwidth usage
8. **Repository pattern** separates business logic from data sources
9. **Riverpod providers** manage state and dependency injection
10. **Clean Architecture** ensures testable, maintainable code

---

**Generated:** 2026-01-16
**App Version:** Based on codebase analysis
**Backend API:** Django REST Framework at `http://156.67.104.149:8012`

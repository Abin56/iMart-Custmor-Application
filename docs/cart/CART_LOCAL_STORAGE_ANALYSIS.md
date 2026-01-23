# Cart Local Storage Analysis

## Question: Is Cart Data Saved Locally?

**Short Answer**: ❌ **NO** - Cart quantities (add to cart, increment, decrement) are **NOT saved locally**.

**Current Implementation**: 🌐 **Server-First** - All cart data is stored on the backend server and fetched via API.

---

## Detailed Analysis

### What IS Saved Locally

The cart feature uses **SharedPreferences** (NOT Hive) to save only **HTTP cache metadata**:

**File**: `lib/features/cart/infrastructure/data_sources/checkout_line_local_data_source.dart`

```dart
class CheckoutLineLocalDataSource {
  final SharedPreferences _prefs;

  // Only stores HTTP 304 cache headers
  static const String _keyLastModified = 'checkout_lines_last_modified';
  static const String _keyETag = 'checkout_lines_etag';

  String? getLastModified() => _prefs.getString(_keyLastModified);
  String? getETag() => _prefs.getString(_keyETag);

  Future<void> saveLastModified(String value) async {
    await _prefs.setString(_keyLastModified, value);
  }

  Future<void> saveETag(String value) async {
    await _prefs.setString(_keyETag, value);
  }
}
```

**What This Means**:
- ✅ Saves: `Last-Modified` and `ETag` HTTP headers (for caching optimization)
- ❌ Does NOT save: Cart items, quantities, product details, or any cart data

### What Is NOT Saved Locally

❌ **Cart Items**: Not saved locally
❌ **Product Quantities**: Not saved locally
❌ **Product Details**: Not saved locally
❌ **Add to Cart Actions**: Not saved locally
❌ **Increment/Decrement**: Not saved locally

**All cart data lives on the server** and is fetched via API.

---

## How Cart Data Works (Current Implementation)

### 1. Add to Cart Flow

```
User taps "Add" button (Product Card)
    ↓
ProductCard._handleAddToCart()
    ↓
CartController.addToCart()
    ↓
CheckoutLineRepository.addToCart()
    ↓
POST /api/order/v1/checkout-lines/
    {
      "product_variant_id": 3058,
      "quantity": 1
    }
    ↓
Server saves to database
    ↓
Server responds with checkout line
    {
      "id": 387,
      "quantity": 1,
      "product_variant_details": {...}
    }
    ↓
CartController updates state
    ↓
localDataSource.clearCacheMetadata() ← Only clears cache headers
    ↓
Product card rebuilds via ref.watch()
```

### 2. Increment/Decrement Flow

```
User taps "+" button (Product Card)
    ↓
ProductCard._handleIncreaseQuantity()
    ↓
CartController.updateQuantity(delta: +1)
    ↓
Optimistic update (state updated immediately)
    ↓
After 150ms debounce:
    ↓
PATCH /api/order/v1/checkout-lines/387/
    {
      "product_variant_id": 3058,
      "quantity": 1  ← Delta value!
    }
    ↓
Server updates quantity in database
    ↓
Server responds with new quantity
    {
      "id": 387,
      "quantity": 2  ← Updated quantity
    }
    ↓
CartController refreshes from server
    ↓
localDataSource.clearCacheMetadata() ← Only clears cache headers
    ↓
Product card rebuilds with confirmed quantity
```

### 3. App Restart/Kill Flow

```
User adds items to cart
    ↓
User kills app
    ↓
All in-memory state (CartController) is lost
    ↓
User reopens app
    ↓
User navigates to category page
    ↓
CartController initializes
    ↓
Starts polling (30s interval)
    ↓
GET /api/order/v1/checkout-lines/
    ↓
Server returns cart items
    {
      "count": 1,
      "results": [
        {
          "id": 387,
          "quantity": 2,
          "product_variant_details": {...}
        }
      ]
    }
    ↓
CartController updates state
    ↓
Product cards rebuild with correct quantities
```

**Result**: ✅ Cart persists because it's stored on the server, not because of local storage.

---

## Why No Local Storage?

### Current Design Philosophy: Server-First

**Advantages**:
1. ✅ **Cross-Device Sync**: Cart accessible from any device (web, mobile, tablet)
2. ✅ **No Data Loss**: Server crash won't lose user's cart
3. ✅ **Authentication-Based**: Cart tied to user account
4. ✅ **Real-Time Inventory**: Server can validate stock availability
5. ✅ **Simpler Code**: No local-remote sync logic needed
6. ✅ **Multi-User**: Supports multiple users on same device

**Disadvantages**:
1. ❌ **Requires Internet**: Can't add to cart offline
2. ❌ **Slower**: Every operation needs API call (mitigated by optimistic updates)
3. ❌ **Server Dependency**: If server down, cart inaccessible

---

## HTTP 304 Caching (What IS Saved Locally)

### Purpose: Reduce Bandwidth & Server Load

The app saves only **cache metadata** (not actual data):

```dart
// Saved in SharedPreferences
{
  "checkout_lines_last_modified": "Wed, 17 Jan 2024 10:00:00 GMT",
  "checkout_lines_etag": "\"abc123xyz\""
}
```

### How HTTP 304 Works

#### First Request (Cache Miss)
```http
GET /api/order/v1/checkout-lines/
```

**Response** (200 OK):
```http
HTTP/1.1 200 OK
ETag: "abc123"
Last-Modified: Wed, 17 Jan 2024 10:00:00 GMT

{
  "count": 1,
  "results": [...]
}
```

**App Actions**:
- Saves ETag and Last-Modified to SharedPreferences
- Displays cart data to user

#### Subsequent Request (Cache Check)
```http
GET /api/order/v1/checkout-lines/
If-None-Match: "abc123"
If-Modified-Since: Wed, 17 Jan 2024 10:00:00 GMT
```

**Response if data unchanged** (304 Not Modified):
```http
HTTP/1.1 304 Not Modified
```

**App Actions**:
- Returns null (data hasn't changed)
- Keeps displaying previous cart data from memory (CartController state)

**Response if data changed** (200 OK):
```http
HTTP/1.1 200 OK
ETag: "xyz789"
Last-Modified: Wed, 17 Jan 2024 10:05:00 GMT

{
  "count": 2,
  "results": [...]
}
```

**App Actions**:
- Updates ETag and Last-Modified in SharedPreferences
- Updates cart data in memory
- Displays new cart data to user

### When Cache Metadata is Cleared

Cache headers are cleared (forcing fresh fetch) when:
1. ✅ User adds item to cart
2. ✅ User updates quantity (increment/decrement)
3. ✅ User removes item from cart

**Why**: These operations change server state, so we need fresh data.

---

## Memory-Only State (CartController)

### Where Cart Data Lives

Cart data is stored **only in memory** via Riverpod state:

**File**: `lib/features/cart/application/states/cart_state.dart`

```dart
class CartState {
  final CartStatus status;
  final CheckoutLinesResponse? data;  // ← Cart data lives here (in memory)
  final String? errorMessage;
  final bool isRefreshing;
}
```

**Lifecycle**:
```
App Launch
    ↓
CartController initializes (CartState.initial())
    ↓
state.data = null (no cart data yet)
    ↓
Polling starts (30s interval)
    ↓
First poll fetches cart from server
    ↓
state.data = CheckoutLinesResponse(results: [...])
    ↓
Cart data now in memory
    ↓
User adds/updates items
    ↓
state.data updates in memory
    ↓
App killed/closed
    ↓
All memory cleared (state.data lost)
    ↓
App reopens
    ↓
CartController re-initializes
    ↓
Fetch cart from server again
```

---

## Comparison: Current vs Local Storage

| Feature | Current (Server-First) | With Local Storage (Hive/SharedPreferences) |
|---------|------------------------|-------------------------------------------|
| **Cart Persistence** | ✅ Yes (server-side) | ✅ Yes (local + server) |
| **Cross-Device Sync** | ✅ Yes | ❌ No (unless complex sync logic) |
| **Offline Add to Cart** | ❌ No | ✅ Yes (queue for later sync) |
| **Internet Required** | ✅ Yes | ⚠️ Partial (for sync) |
| **Data Consistency** | ✅ Server is source of truth | ⚠️ Sync conflicts possible |
| **Implementation Complexity** | ✅ Simple | ❌ Complex (sync logic needed) |
| **Real-Time Inventory** | ✅ Yes | ⚠️ Only when online |
| **Multiple Users** | ✅ Supported | ⚠️ Needs account-based separation |

---

## Should Local Storage Be Added?

### Use Cases for Local Storage

#### ✅ Good Reasons to Add Local Storage:
1. **Offline Support**: Allow users to add items when offline, sync when online
2. **Faster Load**: Show cached cart immediately, update in background
3. **Reduce Server Load**: Fewer API calls during rapid operations
4. **Poor Network Areas**: Better UX in low-connectivity regions

#### ❌ Reasons NOT to Add Local Storage:
1. **Added Complexity**: Need to handle local-remote sync conflicts
2. **Security Risks**: Cart data on device could be tampered with
3. **Multi-Device Issues**: User adds item on phone, doesn't see on web
4. **Stale Data**: Local cache might show items that are out of stock
5. **Current Design Works**: Optimistic updates + HTTP 304 caching already fast

### Recommended Approach

**Current implementation is good for most use cases.**

If offline support is needed, implement a **"queue pending operations"** pattern:

```dart
// Pseudo-code for offline support
class CartRepository {
  Future<void> addToCart({required int productVariantId}) async {
    // Optimistic update (show in UI immediately)
    _updateLocalState(productVariantId, quantity: 1);

    try {
      // Try to sync with server
      await _api.addToCart(productVariantId: productVariantId);
    } catch (e) {
      if (isOfflineError(e)) {
        // Queue for later sync
        await _pendingOperationsQueue.add(
          PendingOperation.addToCart(productVariantId: productVariantId),
        );
      } else {
        // Other error - rollback optimistic update
        _rollbackLocalState(productVariantId);
        rethrow;
      }
    }
  }

  // Background sync when internet returns
  Future<void> syncPendingOperations() async {
    final pending = await _pendingOperationsQueue.getAll();
    for (final op in pending) {
      await op.execute(_api);
      await _pendingOperationsQueue.remove(op);
    }
  }
}
```

---

## Summary

### What IS Saved Locally
✅ **HTTP Cache Headers** (ETag, Last-Modified) in SharedPreferences
- Purpose: Optimize API calls with HTTP 304
- Size: ~100 bytes
- Cleared: After cart mutations (add/update/delete)

### What Is NOT Saved Locally
❌ **Cart Items** (product variants, quantities, details)
❌ **Add to Cart Actions**
❌ **Increment/Decrement Operations**
❌ **Any Product Data**

### Where Cart Data Lives
🧠 **In Memory** (CartController state via Riverpod)
🌐 **On Server** (Backend database)

### How Cart Persists Across App Restarts
1. User's cart stored in server database (tied to session cookie)
2. App closes → memory cleared
3. App reopens → fetches cart from server via GET API
4. CartController rebuilds state from server response
5. Product cards show correct quantities via `ref.watch()`

### Recommendation
✅ **Keep current server-first design** for simplicity and cross-device sync

⚠️ **Consider adding local storage** only if:
- Users frequently have poor internet connectivity
- Offline cart operations are a core requirement
- You're willing to handle sync conflict logic

---

## Related Files

### Local Data Source (Cache Metadata Only)
- `lib/features/cart/infrastructure/data_sources/checkout_line_local_data_source.dart`
- Uses: SharedPreferences
- Stores: ETag, Last-Modified headers

### Remote Data Source (Actual Cart Data)
- `lib/features/cart/infrastructure/data_sources/checkout_line_remote_data_source.dart`
- Uses: Dio HTTP client
- Fetches: All cart data from server

### Repository (Coordinates Local + Remote)
- `lib/features/cart/infrastructure/repositories/checkout_line_repository_impl.dart`
- Handles: HTTP 304 caching, error handling

### Controller (In-Memory State)
- `lib/features/cart/application/controllers/cart_controller.dart`
- Manages: Cart state in memory (Riverpod)
- Lifecycle: Lives only while app is running

---

**Status**: Current implementation is **server-first** with **HTTP 304 caching** for optimization. No local cart data storage.

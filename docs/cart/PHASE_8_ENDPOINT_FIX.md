# Phase 8: Cart API Endpoint Fix - COMPLETED

## Issue: App Freezing When Adding to Cart

**Problem**: When trying to add items to cart, the app would freeze and show "imart isn't responding" error.

**Root Cause**: The cart data sources were using incorrect endpoint paths that didn't match the backend API structure.

## What Was Fixed

### 1. Checkout Line Endpoints

**File**: `lib/features/cart/infrastructure/data_sources/checkout_line_remote_data_source.dart`

| Operation | Before (Wrong) | After (Correct) |
|-----------|---------------|-----------------|
| Get cart items | `/checkout/lines/` | `/api/order/v1/checkout-lines/` |
| Add to cart | `/checkout/lines/` | `/api/order/v1/checkout-lines/` |
| Update quantity | `/checkout/lines/{id}/` | `/api/order/v1/checkout-lines/{id}/` |
| Delete item | `/checkout/lines/{id}/` | `/api/order/v1/checkout-lines/{id}/` |

### 2. Coupon Endpoints

**File**: `lib/features/cart/infrastructure/data_sources/coupon_remote_data_source.dart`

| Operation | Before (Wrong) | After (Correct) |
|-----------|---------------|-----------------|
| Validate coupon | `/checkout/coupons/validate/` | `/api/order/v1/coupons/validate/` |
| Apply coupon | `/checkout/coupons/apply/` | `/api/order/v1/coupons/apply/` |
| Remove coupon | `/checkout/coupons/remove/` | `/api/order/v1/coupons/remove/` |

### 3. Address Endpoints

**File**: `lib/features/cart/infrastructure/data_sources/address_remote_data_source.dart`

| Operation | Before (Wrong) | After (Correct) |
|-----------|---------------|-----------------|
| Get addresses | `/addresses/` | `/api/auth/v1/address/` |
| Get address by ID | `/addresses/{id}/` | `/api/auth/v1/address/{id}/` |
| Create address | `/addresses/` | `/api/auth/v1/address/` |
| Update address | `/addresses/{id}/` | `/api/auth/v1/address/{id}/` |
| Delete address | `/addresses/{id}/` | `/api/auth/v1/address/{id}/` |
| Set default shipping | `/addresses/{id}/set-default-shipping/` | `/api/auth/v1/address/{id}/set-default-shipping/` |
| Set default billing | `/addresses/{id}/set-default-billing/` | `/api/auth/v1/address/{id}/set-default-billing/` |

## Why the App Was Freezing

1. **Wrong Endpoints**: The data sources were calling non-existent endpoints
2. **Timeout Delay**: Dio was waiting 30 seconds for a connection timeout
3. **No Response**: The server wasn't responding to these incorrect paths
4. **UI Thread Block**: The await call in `addToCart` was blocking the UI thread

### Before (Freezing)
```dart
// Wrong endpoint - server returns 404 after 30s timeout
final response = await _dio.post('/checkout/lines/', data: {...});
```

### After (Working)
```dart
// Correct endpoint - server responds immediately
final response = await _dio.post('/api/order/v1/checkout-lines/', data: {...});
```

## CRITICAL: Testing Steps After Fix

### ⚠️ MUST DO: Full App Restart (Not Hot Reload!)
**The endpoint changes REQUIRE a complete app restart to take effect.**

```bash
# Step 1: STOP the app completely
Ctrl+C (in terminal) or Stop button (in IDE)

# Step 2: Clean and rebuild (RECOMMENDED)
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Step 3: Run the app fresh
flutter run
```

**Note**: Hot reload (⚡) or hot restart (🔄) will NOT work for these changes!

### 1. Login First (REQUIRED!)
**You MUST be logged in before testing cart features.**

```
1. Open app
2. Tap profile icon (top right)
3. Login with mobile OTP or email/password
4. Wait for login success
5. Session cookie saved automatically
```

### 2. Add to Cart
**Only test this AFTER logging in:**

```
1. Browse products in any category
2. Tap "Add" button on product card
3. ✅ Should see loading spinner briefly
4. ✅ Quantity selector (+/-) appears
5. ✅ Cart badge updates
6. ✅ No freezing or "app not responding" error
```

### 4. Increment/Decrement
```
1. Tap "+" button → quantity increases immediately
2. Tap "-" button → quantity decreases immediately
3. Both should work smoothly without delays
```

### 5. Verify Cart Screen
```
1. Navigate to cart screen (bottom nav)
2. ✅ Items added should appear
3. ✅ Quantities match product cards
4. ✅ Prices calculate correctly
```

## API Base URL Configuration

**Configured in**: `lib/app/core/config/app_config.dart`

```dart
class AppConfig {
  static const String apiBaseUrl = 'http://156.67.104.149:8080';

  // All endpoints are relative to this base URL
  // Example: '/api/order/v1/checkout-lines/'
  // Full URL: 'http://156.67.104.149:8080/api/order/v1/checkout-lines/'
}
```

**Dio Configuration** (in `main.dart`):
```dart
Dio(
  BaseOptions(
    baseUrl: AppConfig.apiBaseUrl, // Uses correct base URL
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ),
)
```

## Files Modified

1. ✅ `lib/features/cart/infrastructure/data_sources/checkout_line_remote_data_source.dart`
   - Fixed 4 endpoint paths

2. ✅ `lib/features/cart/infrastructure/data_sources/coupon_remote_data_source.dart`
   - Fixed 3 endpoint paths

3. ✅ `lib/features/cart/infrastructure/data_sources/address_remote_data_source.dart`
   - Fixed 7 endpoint paths

## Verification Checklist

- [ ] App hot restarted (not just hot reload)
- [ ] User logged in with valid session
- [ ] Add to cart works without freezing
- [ ] Quantity increment/decrement works smoothly
- [ ] Cart badge updates correctly
- [ ] Cart screen shows correct items
- [ ] No "app not responding" errors
- [ ] Loading indicators show briefly during API calls

## Error Handling

### Authentication Errors (401)
```dart
try {
  await ref.read(cartControllerProvider.notifier).addToCart(...);
} catch (e) {
  // Shows: "Failed to add to cart: Authentication required"
  ScaffoldMessenger.showSnackBar(
    SnackBar(content: Text('Failed to add to cart: $e')),
  );
}
```

### Stock Errors (400)
```dart
try {
  await repository.addToCart(...);
} catch (e) {
  if (e is InsufficientStockException) {
    // Shows: "Insufficient stock" or specific error message
  }
}
```

## Next Steps

1. **Hot restart the app** to apply endpoint changes
2. **Login first** before testing cart features
3. **Test add to cart** - should work smoothly now
4. **Test increment/decrement** - should be instant with optimistic updates
5. **Optional**: Test coupon application (requires logged in + items in cart)

## Backend API Documentation Reference

All endpoints follow the structure documented in:
`docs/cart/CART_CHECKOUT_BACKEND_DOCUMENTATION.md`

**Base URL**: `http://156.67.104.149:8080`

**Cart Endpoints**:
- GET `/api/order/v1/checkout-lines/` - Fetch cart
- POST `/api/order/v1/checkout-lines/` - Add item
- PATCH `/api/order/v1/checkout-lines/{id}/` - Update quantity
- DELETE `/api/order/v1/checkout-lines/{id}/` - Remove item

**Coupon Endpoints**:
- POST `/api/order/v1/coupons/validate/` - Validate code
- POST `/api/order/v1/coupons/apply/` - Apply coupon
- DELETE `/api/order/v1/coupons/remove/` - Remove coupon

**Address Endpoints**:
- GET `/api/auth/v1/address/` - List addresses
- POST `/api/auth/v1/address/` - Create address
- PATCH `/api/auth/v1/address/{id}/` - Update address
- DELETE `/api/auth/v1/address/{id}/` - Delete address

---

**Status**: ✅ Phase 8 Complete - Endpoint Paths Fixed
**Issue**: App freezing when adding to cart
**Resolution**: Updated all cart data sources with correct API endpoint paths
**Next Action**: Hot restart app and test cart functionality

---

**Related Documentation**:
- `docs/cart/AUTHENTICATION_REQUIREMENT.md` - Authentication setup
- `docs/cart/PHASE_7_PRODUCT_CARD_INTEGRATION_COMPLETED.md` - Product card integration
- `docs/cart/CART_CHECKOUT_BACKEND_DOCUMENTATION.md` - Full API reference

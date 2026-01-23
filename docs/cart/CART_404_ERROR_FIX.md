# Cart 404 Error Fix - Improved Error Handling & Auto-Sync

## Issue Summary

**Problem:** Getting 404 errors when trying to update cart item quantities.

**Error Message:**
```
DioException [bad response]: This exception was thrown because the response has a status code of 404
The status code of 404 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
```

**Root Cause:** The cart line ID being used for the update request no longer exists on the backend. This can happen when:
1. Cart was cleared/modified from another device/session
2. Cart items expired or were removed by the system
3. User has stale cart data that's out of sync with backend

## Solution Implemented

### 1. Enhanced Debug Logging

Added detailed logging **before** making the API request to help diagnose 404 errors:

**File:** `checkout_line_remote_data_source.dart` (lines 86-91)

```dart
Future<CheckoutLineDto> updateQuantity({
  required int lineId,
  required int productVariantId,
  required int quantity,
}) async {
  // Debug logging BEFORE making the request
  debugPrint('🔄 UPDATE QUANTITY REQUEST:');
  debugPrint('   Line ID: $lineId');
  debugPrint('   Product Variant ID: $productVariantId');
  debugPrint('   Quantity Delta: $quantity');
  debugPrint('   URL: /api/order/v1/checkout-lines/$lineId/');

  final response = await _dio.patch<Map<String, dynamic>>(
    '/api/order/v1/checkout-lines/$lineId/',
    // ...
  );
  // ...
}
```

**What You'll See in Logs:**
```
🔄 UPDATE QUANTITY REQUEST:
   Line ID: 407
   Product Variant ID: 3058
   Quantity Delta: 1
   URL: /api/order/v1/checkout-lines/407/
```

### 2. Better 404 Error Handling in Repository

Added specific error handling for 404 responses:

**File:** `checkout_line_repository_impl.dart` (lines 128-135)

```dart
} on DioException catch (e) {
  if (e.response?.statusCode == 404) {
    debugPrint('❌ 404 ERROR - Cart item not found:');
    debugPrint('   Line ID: $lineId');
    debugPrint('   Product Variant ID: $productVariantId');
    debugPrint('   Quantity Delta: $quantity');
    debugPrint('   This usually means the cart item was deleted or the session changed');
    throw Exception('Cart item not found. Please refresh your cart.');
  }
  // ... other error handling
}
```

**What You'll See in Logs:**
```
❌ 404 ERROR - Cart item not found:
   Line ID: 407
   Product Variant ID: 3058
   Quantity Delta: 1
   This usually means the cart item was deleted or the session changed
```

### 3. Auto-Sync on 404 Errors

Modified cart controller to automatically refresh cart when 404 occurs (instead of showing error):

**File:** `cart_controller.dart` (lines 195-203)

```dart
} catch (e) {
  // Check if it's a 404 error (cart item not found)
  if (e.toString().contains('Cart item not found') ||
      e.toString().contains('404')) {
    debugPrint('⚠️ Cart item not found (404) - Force refreshing cart');
    // Force refresh to sync with backend state
    await loadCart(forceRefresh: true);
    // Don't show error to user - just silently sync
    return;
  }

  // For other errors, rollback optimistic update
  await loadCart(forceRefresh: true);
  state = state.copyWith(
    status: CartStatus.error,
    errorMessage: e.toString(),
  );
  rethrow;
}
```

**What You'll See in Logs:**
```
⚠️ Cart item not found (404) - Force refreshing cart
```

## How It Works Now

### Before Fix:
1. User tries to update quantity of cart item
2. Backend returns 404 (item doesn't exist)
3. App crashes with unhandled exception
4. User sees red error screen
5. Cart state is corrupted

### After Fix:
1. User tries to update quantity of cart item
2. Backend returns 404 (item doesn't exist)
3. App detects 404 error
4. **Automatically refreshes cart** from backend
5. ✅ Cart UI updates to show current backend state
6. ✅ No error message shown to user (silent recovery)
7. ✅ User can continue shopping normally

## Error Scenarios Handled

### Scenario 1: Cart Modified from Another Device
**Example:**
- User adds items on Phone A
- User clears cart on Phone B
- User tries to update quantity on Phone A

**Behavior:**
- Phone A detects 404
- Automatically syncs with backend
- Shows empty cart (matching Phone B)
- No error shown to user

### Scenario 2: Cart Items Expired
**Example:**
- User adds items to cart
- Items sit in cart for several days
- Backend removes expired items
- User tries to update quantity

**Behavior:**
- App detects 404
- Automatically refreshes cart
- Shows current cart state (expired items removed)
- No error shown to user

### Scenario 3: Network Issues During Add
**Example:**
- User adds item to cart
- Network fails during add request
- Item appears in UI (optimistic update) but not on backend
- User tries to update quantity

**Behavior:**
- App detects 404
- Automatically refreshes cart
- Shows correct backend state (item not added)
- No error shown to user

## Debug Information Flow

When a 404 error occurs, you'll see this sequence in logs:

```
🔄 UPDATE QUANTITY REQUEST:
   Line ID: 407
   Product Variant ID: 3058
   Quantity Delta: 1
   URL: /api/order/v1/checkout-lines/407/

❌ 404 ERROR - Cart item not found:
   Line ID: 407
   Product Variant ID: 3058
   Quantity Delta: 1
   This usually means the cart item was deleted or the session changed

⚠️ Cart item not found (404) - Force refreshing cart

[Then cart refresh logs...]
```

## Common Causes of 404 Errors

### 1. Stale Line IDs
- Frontend has cart item with ID 407
- Backend has different cart (different checkout session)
- Line ID 407 doesn't exist in current session

**Solution:** Auto-refresh syncs frontend with backend state

### 2. Multiple Checkout Sessions
- User has multiple checkouts (shouldn't happen but possible)
- Frontend is using wrong checkout ID
- Line IDs belong to different checkout

**Solution:** Auto-refresh loads current checkout's items

### 3. Cart Cleared by Admin/System
- Admin manually cleared cart
- System auto-cleared abandoned cart
- Frontend still shows old items

**Solution:** Auto-refresh shows empty cart

### 4. Race Conditions
- Two rapid updates to same item
- First update removes item (quantity → 0)
- Second update tries to update non-existent item

**Solution:** Auto-refresh shows correct final state

## Testing the Fix

### Test Case 1: Simulate 404 Error
1. Add item to cart
2. Note the line ID in logs
3. Manually delete the cart item via API or admin panel
4. Try to update quantity in app
5. **Verify:** App refreshes cart automatically without showing error

### Test Case 2: Multiple Devices
1. Add items to cart on Device A
2. Clear cart on Device B
3. Try to update quantity on Device A
4. **Verify:** Cart on Device A syncs and shows empty state

### Test Case 3: Invalid Line ID
1. Modify code to use invalid line ID (e.g., 99999)
2. Try to update quantity
3. **Verify:** App handles gracefully and refreshes cart

## Files Modified

1. **`checkout_line_remote_data_source.dart`**
   - Added debug logging before API request (lines 86-91)
   - Helps diagnose which line ID caused 404

2. **`checkout_line_repository_impl.dart`**
   - Added 404 error handling (lines 128-135)
   - Provides detailed error context in logs
   - Throws user-friendly error message

3. **`cart_controller.dart`**
   - Added auto-sync on 404 (lines 195-203)
   - Silent recovery without showing error to user
   - Maintains good UX even when backend state changes

## Benefits

1. **Better Debugging** - Detailed logs help identify root cause
2. **Auto-Recovery** - App syncs with backend automatically
3. **Better UX** - No error messages for sync issues
4. **Data Consistency** - Frontend always matches backend state
5. **Resilient** - Handles edge cases gracefully

## Next Steps

If 404 errors continue to occur, check the logs for:

1. **Frequent 404s** - May indicate session management issue
2. **Pattern in Line IDs** - Certain products causing problems?
3. **Timing Issues** - Happening during specific user flows?

The enhanced logging will help identify patterns and root causes.

---

**Implemented by:** Claude Sonnet 4.5
**Date:** January 20, 2026
**Issue:** 404 errors when updating cart quantity
**Solution:** Enhanced logging + auto-sync on 404
**Priority:** P1 - Critical (Cart functionality)
**Status:** ✅ Complete

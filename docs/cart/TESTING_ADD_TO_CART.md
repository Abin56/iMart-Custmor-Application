# Testing Add to Cart After Endpoint Fix

## Critical Steps to Follow (IN ORDER)

### Step 1: Completely Stop the App
**IMPORTANT**: The endpoint changes require a full app restart, NOT just hot reload or hot restart.

```bash
# Method 1: Stop from terminal
Ctrl+C (in the terminal where flutter run is running)

# Method 2: Stop from IDE
Click the red Stop button in VS Code/Android Studio

# Method 3: Kill app on device
Force close the app from device settings or recent apps
```

### Step 2: Rebuild and Run
```bash
# Clean build (recommended)
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Then run
flutter run
```

### Step 3: Login FIRST (Required!)
**The cart API requires authentication. You MUST login before adding to cart.**

1. Open the app
2. Tap the **profile icon** in the top right
3. Complete login:
   - **Mobile OTP**: Enter phone number → Receive OTP → Verify
   - **Email**: Enter email + password → Login
4. Wait for login success message
5. Session cookie is now stored automatically

### Step 4: Test Add to Cart
Only after logging in:

1. Navigate to any category (e.g., "Fruits & Vegetables")
2. Find any product card
3. Tap the green **"Add"** button
4. **Expected behavior**:
   - ✅ Brief loading spinner appears
   - ✅ Button changes to quantity selector with +/- buttons
   - ✅ Cart badge updates at bottom nav
   - ✅ No freezing
   - ✅ No "app not responding" error

5. Test increment/decrement:
   - Tap **+** button → quantity increases
   - Tap **-** button → quantity decreases
   - Both should work smoothly

### Step 5: Verify Cart Screen
1. Navigate to cart screen (bottom nav)
2. ✅ Added items should appear
3. ✅ Quantities should match product cards
4. ✅ Prices should calculate correctly

## Common Issues and Solutions

### Issue 1: App Still Freezing
**Symptom**: App shows "imart isn't responding" dialog

**Solution**:
1. Did you do a **full stop + restart**? (Not hot reload/hot restart)
2. Run `flutter clean` then `flutter run`
3. Check if the app is running in debug mode (not release mode)

### Issue 2: "Failed to add to cart: DioException"
**Symptom**: Red snackbar appears with Dio error

**Possible Causes**:
1. **Not logged in** → Login first (see Step 3)
2. **Session expired** → Logout and login again
3. **Network error** → Check device internet connection
4. **Backend down** → Verify API URL is accessible

**Verify Login Status**:
```dart
// Add this temporarily to check auth state
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In any widget:
final authState = ref.watch(authProvider);
print('Auth state: $authState');
// Should print: Authenticated(user: ..., isNewUser: false)
```

### Issue 3: Native Crash (Signal Catcher)
**Symptom**: Stack trace shows "Signal Catcher", "VRI", "tombstoned"

**This usually means**:
1. App is trying to call API before Dio is fully initialized
2. Authentication cookies are missing
3. Response parsing is failing

**Solution**:
1. Make sure you're logged in BEFORE adding to cart
2. Check that the app has internet permission in AndroidManifest.xml
3. Try on a physical device instead of emulator
4. Check logcat for actual error message:
   ```bash
   flutter logs | grep -i "error\|exception"
   ```

### Issue 4: Cart Badge Not Updating
**Symptom**: Item added but cart badge shows 0

**Solution**:
1. The badge should update automatically via CartController polling
2. Check if CartController is properly initialized in main.dart
3. Navigate away and back to refresh state

## Debugging Checklist

Before reporting the issue, verify:

- [ ] Full app stop + restart (NOT hot reload)
- [ ] User is logged in (session cookie present)
- [ ] Internet connection is working
- [ ] Running on debug mode
- [ ] API base URL is correct: `http://156.67.104.149:8012`
- [ ] All three data source files have correct endpoints:
  - [ ] `checkout_line_remote_data_source.dart` → `/api/order/v1/checkout-lines/`
  - [ ] `coupon_remote_data_source.dart` → `/api/order/v1/coupons/`
  - [ ] `address_remote_data_source.dart` → `/api/auth/v1/address/`

## Expected API Behavior

### Successful Add to Cart Request
```http
POST http://156.67.104.149:8012/api/order/v1/checkout-lines/
Content-Type: application/json
Cookie: sessionid=xyz123...
X-CSRFToken: abc456...

{
  "product_variant_id": 123,
  "quantity": 1
}
```

### Successful Response (200 OK)
```json
{
  "id": 456,
  "product_variant_id": 123,
  "quantity": 1,
  "product_name": "Fresh Apple",
  "price": "2.50",
  "total_price": "2.50"
}
```

### Authentication Error (401 Unauthorized)
**Cause**: User not logged in or session expired

**Solution**: Login first, then try again

### Stock Error (400 Bad Request)
**Cause**: Insufficient stock or product unavailable

**Response**:
```json
{
  "error": "Insufficient stock. Available: 5, Requested: 10"
}
```

## Testing on Different Scenarios

### Scenario 1: First Time User (Guest)
1. Open app (not logged in)
2. Try to add to cart
3. **Expected**: Error message "Authentication required" or similar
4. Login via profile icon
5. Try to add to cart again
6. **Expected**: Success

### Scenario 2: Logged In User
1. Already logged in from previous session
2. Add product to cart
3. **Expected**: Immediate success

### Scenario 3: Session Expired
1. Logged in but session cookie expired
2. Try to add to cart
3. **Expected**: 401 error
4. Login again
5. **Expected**: Success

### Scenario 4: Network Loss
1. Turn off internet
2. Try to add to cart
3. **Expected**: Connection error message
4. Turn on internet
5. **Expected**: Success

## Advanced Debugging

If the issue persists, add temporary logging:

### Add Logging to CartController
Edit `lib/features/cart/application/controllers/cart_controller.dart`:

```dart
Future<void> addToCart({
  required int productVariantId,
  required int quantity,
}) async {
  print('🛒 [CartController] Adding to cart: variantId=$productVariantId, qty=$quantity');

  try {
    final repository = await ref.read(checkoutLineRepositoryProvider.future);
    print('🛒 [CartController] Repository loaded, calling addToCart...');

    await repository.addToCart(
      productVariantId: productVariantId,
      quantity: quantity,
    );

    print('🛒 [CartController] Add to cart successful, refreshing cart...');
    await loadCart(forceRefresh: true);
    print('🛒 [CartController] Cart refreshed successfully');
  } catch (e, stackTrace) {
    print('❌ [CartController] Add to cart failed: $e');
    print('❌ [CartController] Stack trace: $stackTrace');

    state = state.copyWith(
      status: CartStatus.error,
      errorMessage: e.toString(),
    );
    rethrow;
  }
}
```

### Add Logging to ProductCard
Edit `lib/features/category/product_card.dart`:

```dart
Future<void> _handleAddToCart() async {
  print('🛒 [ProductCard] Add to cart button pressed');

  if (!widget.product.inStock) {
    print('❌ [ProductCard] Product out of stock');
    return;
  }

  final productVariantId = int.tryParse(widget.product.variantId);
  if (productVariantId == null) {
    print('❌ [ProductCard] Invalid variantId: ${widget.product.variantId}');
    return;
  }

  print('🛒 [ProductCard] variantId parsed: $productVariantId');

  setState(() {
    _isAddingToCart = true;
    _showIntroAnimation = false;
  });

  try {
    print('🛒 [ProductCard] Calling CartController.addToCart...');
    await ref.read(cartControllerProvider.notifier).addToCart(
      productVariantId: productVariantId,
      quantity: 1,
    );
    print('✅ [ProductCard] Add to cart succeeded');
    widget.onAddToCart?.call();
  } catch (e, stackTrace) {
    print('❌ [ProductCard] Add to cart failed: $e');
    print('❌ [ProductCard] Stack trace: $stackTrace');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }
}
```

### Check Flutter Logs
```bash
# In a separate terminal, run:
flutter logs

# Or filter for specific keywords:
flutter logs | grep -i "cart\|error\|exception\|dio"
```

## What Success Looks Like

When everything works correctly, you should see:

1. **In logs**:
```
🛒 [ProductCard] Add to cart button pressed
🛒 [ProductCard] variantId parsed: 123
🛒 [ProductCard] Calling CartController.addToCart...
🛒 [CartController] Adding to cart: variantId=123, qty=1
🛒 [CartController] Repository loaded, calling addToCart...
🛒 [CartController] Add to cart successful, refreshing cart...
🛒 [CartController] Cart refreshed successfully
✅ [ProductCard] Add to cart succeeded
```

2. **In UI**:
- Loading spinner briefly shows
- Button transforms into quantity selector
- Cart badge updates
- No freezing or errors

---

**Status**: Endpoint fixes applied in Phase 8
**Next Step**: Full app restart + login + test add to cart
**Documentation**: See [PHASE_8_ENDPOINT_FIX.md](PHASE_8_ENDPOINT_FIX.md) for details on what was fixed

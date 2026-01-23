# Cart Authentication Requirement

## Issue: Connection Error When Adding to Cart

**Error Message**: "Dio exception connection error"

**Root Cause**: The cart API requires authentication (session cookies) to add items to cart.

## Solution Applied

### 1. Updated Cart Providers to Use Shared Dio Instance

**File**: `lib/features/cart/application/providers/cart_providers.dart`

**Before**:
```dart
@riverpod
Dio dio(DioRef ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'http://156.67.104.149:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
```

**After**:
```dart
@riverpod
Dio dio(Ref ref) {
  // Use the global Dio instance that has cookie management
  return ref.watch(dioProvider);
}
```

### 2. Cookie Management

The global `dioProvider` is configured in `main.dart` with:
- Cookie jar for persistent session management
- CSRF token handling
- Automatic cookie injection in requests

**Configuration** (`main.dart:20-26`):
```dart
_container = ProviderContainer(
  overrides: [
    dioProvider.overrideWithValue(api.dio),
    cookieJarProvider.overrideWithValue(api.cookieJar),
    apiClientProvider.overrideWithValue(api),
  ],
);
```

## Authentication Flow

### Adding to Cart (Requires Auth)

1. **User must be logged in first**
   - Tap profile icon or any auth-required feature
   - Complete login via OTP or email/password
   - Session cookie is stored automatically

2. **Add to cart**
   - Tap "Add" button on product card
   - API call includes session cookie automatically
   - Cart item saved to backend

### API Endpoints Requiring Authentication

All cart endpoints require authentication:

| Endpoint | Method | Auth Required |
|----------|--------|---------------|
| `/api/order/v1/checkout-lines/` | GET | ✅ |
| `/api/order/v1/checkout-lines/` | POST | ✅ |
| `/api/order/v1/checkout-lines/{id}/` | PATCH | ✅ |
| `/api/order/v1/checkout-lines/{id}/` | DELETE | ✅ |
| `/api/order/v1/coupons/` | GET | ✅ |

## Testing Steps

### 1. Login First
```
1. Open app
2. Tap profile icon (opens auth bottom sheet)
3. Login with:
   - Mobile OTP: Enter phone → Receive OTP → Verify
   - Email: Enter email/password → Login
4. Session cookie stored automatically
```

### 2. Add to Cart
```
1. Browse products
2. Tap "Add" button on any product
3. ✅ Should work now (no connection error)
4. Quantity selector appears
5. Cart badge updates
```

### 3. Verify Cart Persistence
```
1. Add items to cart
2. Close app
3. Reopen app
4. Navigate to cart screen
5. ✅ Items should still be there (loaded from backend)
```

## Guest Mode Handling

**Current Behavior**:
- Guest users (not logged in) cannot add to cart
- Cart API returns 401 Unauthorized
- ProductCard shows "Failed to add to cart" error

**Future Enhancement** (if needed):
- Implement local cart storage for guest users
- Sync to backend when user logs in
- Show login prompt before adding to cart

## API Configuration

**Base URL**: `http://156.67.104.149:8080` (configured in `AppConfig.apiBaseUrl`)

**Required Headers** (automatically added by ApiClient):
```http
Cookie: sessionid=xyz123
X-CSRFToken: abc456
Content-Type: application/json
```

## Troubleshooting

### Still Getting Connection Error?

1. **Check if logged in**:
   ```dart
   final authState = ref.read(authProvider);
   print('Auth state: $authState');
   // Should be: Authenticated(user: ..., isNewUser: false)
   ```

2. **Check cookie jar**:
   ```dart
   final cookies = await cookieJar.loadForRequest(Uri.parse('http://156.67.104.149:8080'));
   print('Cookies: $cookies');
   // Should include sessionid cookie
   ```

3. **Check API base URL**:
   ```dart
   print('API URL: ${AppConfig.apiBaseUrl}');
   // Should be: http://156.67.104.149:8080
   ```

4. **Hot restart** (not just hot reload):
   - After changing Dio providers, do a full hot restart
   - Ctrl+Shift+F5 (VS Code) or "Hot Restart" button

### Cart Not Loading on App Restart?

1. Check if session cookie persists (PersistCookieJar should handle this)
2. Check if CartController.loadCart() is called in cart screen initState
3. Verify backend session hasn't expired

## Next Steps

1. ✅ **Login first** before testing cart features
2. ✅ **Hot restart** the app to apply Dio provider changes
3. ✅ **Test add to cart** - should work without connection errors
4. ⏳ **Optional**: Add login prompt UI before add to cart (for better UX)

## Code Changes Summary

**Modified Files**:
1. `lib/features/cart/application/providers/cart_providers.dart`
   - Changed to use shared `dioProvider`
   - Added import for `network_providers.dart`

**Generated Files** (auto-updated):
1. `lib/features/cart/application/providers/cart_providers.g.dart`

**No Changes Needed**:
- `lib/features/category/product_card.dart` (already integrated)
- `lib/main.dart` (already has cookie management)
- `lib/app/core/config/app_config.dart` (already has correct API URL)

---

**Status**: ✅ Fixed - Cart now uses authenticated Dio instance
**Requirement**: User must be logged in to add items to cart
**Next Action**: Login first, then test add to cart functionality

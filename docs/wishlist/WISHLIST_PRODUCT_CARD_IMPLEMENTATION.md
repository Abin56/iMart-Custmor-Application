# Wishlist Product Card Implementation - Complete Rebuild

## Issue Summary

The original approach of reusing `ProductCard` from the category feature was failing because:
1. Empty `productId` values were being cached from before the data source fix
2. The product card was tightly coupled to `CategoryProduct` model
3. Cache invalidation wasn't working properly on refresh

## Solution: Dedicated WishlistProductCard

Created a dedicated, self-contained product card specifically for the wishlist feature with:
- Direct `WishlistItem` integration (no model conversion needed)
- Full cart operations (add, increment, decrement)
- Wishlist remove functionality
- Hive persistent storage

## Files Created/Modified

### 1. New Component: WishlistProductCard
**File:** `lib/features/wishlist/presentation/components/wishlist_product_card.dart`

A dedicated product card component with:

#### Features
- ✅ Displays product image, name, price, discount badge
- ✅ Add to cart button (green gradient)
- ✅ Quantity controls (- / + buttons)
- ✅ Remove from wishlist (red heart icon)
- ✅ Real-time cart state sync via Riverpod
- ✅ Proper error handling with SnackBars

#### Cart Integration
```dart
int? get _cartQuantity {
  final cartState = ref.watch(cartControllerProvider);
  if (cartState.data == null) return null;

  final productVariantId = int.tryParse(widget.item.productId);
  if (productVariantId == null) return null;

  try {
    final line = cartState.data!.results.firstWhere(
      (line) => line.productVariantId == productVariantId,
    );
    return line.quantity;
  } catch (e) {
    return null;
  }
}
```

#### Key Methods
- `_handleAddToCart()` - Adds product to cart with quantity 1
- `_handleIncreaseQuantity()` - Increments cart quantity
- `_handleDecreaseQuantity()` - Decrements cart quantity (auto-removes at 0)
- `_handleRemoveFromWishlist()` - Removes from wishlist with confirmation

### 2. Enhanced Hive Storage
**File:** `lib/features/wishlist/infrastructure/data_sources/wishlist_local_data_source.dart`

Upgraded from in-memory cache to Hive persistent storage:

#### Before (In-Memory)
```dart
class WishlistLocalDataSourceImpl {
  CachedWishlistData? _cachedWishlist;  // Lost on app restart

  @override
  Future<CachedWishlistData?> getWishlist() async {
    return _cachedWishlist;
  }
}
```

#### After (Hive Persistent)
```dart
class WishlistLocalDataSourceImpl {
  static const String _wishlistKey = 'wishlist_items';
  static const String _timestampKey = 'wishlist_timestamp';

  @override
  Future<CachedWishlistData?> getWishlist() async {
    final box = Boxes.cacheBox;
    final jsonData = box.get(_wishlistKey) as String?;
    final timestamp = box.get(_timestampKey) as String?;

    if (jsonData == null || timestamp == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonData);
    final items = jsonList
        .map((json) => _wishlistItemFromJson(json))
        .toList();

    return CachedWishlistData(
      data: items,
      cachedAt: DateTime.parse(timestamp),
    );
  }
}
```

#### Benefits
- ✅ Data persists across app restarts
- ✅ Faster initial load (no API call needed)
- ✅ Works offline with stale data fallback
- ✅ 5-minute TTL for freshness

### 3. Enhanced Refresh with Cache Clear
**File:** `lib/features/wishlist/application/providers/wishlist_providers.dart`

Updated `refresh()` method to clear cache before fetching:

```dart
/// Refresh (pull-to-refresh)
Future<void> refresh() async {
  // Clear cache to force fresh data from API
  await _repository.clearCache();

  await state.mapOrNull(
    loaded: (loadedState) async {
      state = WishlistState.refreshing(items: loadedState.items);
      await _loadWishlist();
    },
    error: (_) => _loadWishlist(),
  );
}
```

This ensures that pull-to-refresh **always** fetches fresh data from the API.

### 4. Updated Wishlist Screen
**File:** `lib/features/wishlist/presentation/screen/wishlist_screen.dart`

Simplified to use `WishlistProductCard`:

#### Before (Complex Conversion)
```dart
Widget _buildWishlistContent(List items) {
  return GridView.builder(
    itemBuilder: (context, index) {
      final wishlistItem = items[index] as WishlistItem;

      // Convert WishlistItem to CategoryProduct
      final categoryProduct = CategoryProduct(
        variantId: wishlistItem.productId,
        // ... 15+ lines of mapping
      );

      return ProductCard(
        product: categoryProduct,
        // ...
      );
    },
  );
}
```

#### After (Direct Usage)
```dart
Widget _buildWishlistContent(List items) {
  return RefreshIndicator(
    onRefresh: () => ref.read(wishlistProvider.notifier).refresh(),
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        mainAxisExtent: 200.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final wishlistItem = items[index] as WishlistItem;

        return WishlistProductCard(
          item: wishlistItem,
          onTap: () {
            // TODO: Navigate to product detail
          },
        );
      },
    ),
  );
}
```

### 5. Fixed Data Source productId Issue
**File:** `lib/features/wishlist/infrastructure/data_sources/wishlist_remote_data_source.dart`

The original issue was that `productId` was empty because we were trying to extract it from the product details API response, which didn't have it.

#### The Fix (Already Applied)
```dart
WishlistItem _createWishlistItemFromProductResponse({
  required int wishlistId,
  required String productVariantId,  // ✅ Pass it explicitly
  required Map<String, dynamic> productData,
}) {
  // Use the productVariantId from wishlist response
  final productId = productVariantId;  // ✅ Guaranteed to exist
  // ... rest of mapping
}
```

**Called from:**
```dart
final wishlistItem = _createWishlistItemFromProductResponse(
  wishlistId: wishlistId,
  productVariantId: productVariantId,  // ✅ From wishlist API
  productData: productResponse.data,
);
```

## Testing Instructions

### 1. Hot Restart Required
```bash
# Stop the app completely
# Then run again
flutter run
```

### 2. Test Sequence

#### A. Pull-to-Refresh (Critical!)
1. Navigate to wishlist
2. **Pull down to refresh** (this clears cache and fetches fresh data)
3. Wait for refresh to complete
4. Now test cart operations

#### B. Add to Cart
1. Tap the green **+** button on any product
2. Should see quantity controls appear: `- 1 +`
3. Cart count badge should update

#### C. Quantity Controls
1. Tap **+** to increment quantity
2. Quantity should increase: `- 2 +`
3. Tap **-** to decrement quantity
4. Quantity should decrease: `- 1 +`
5. Tap **-** again to remove from cart
6. Should return to green **+** button

#### D. Remove from Wishlist
1. Tap the red **heart** icon
2. Should show "Removed from wishlist" snackbar
3. Product should disappear from grid
4. Wishlist count badge should decrease

#### E. Persistence Test
1. Add products to wishlist
2. Close the app completely
3. Reopen the app
4. Navigate to wishlist
5. Products should still be there (Hive persistence)

#### F. Offline Test
1. Enable Airplane mode
2. Navigate to wishlist
3. Should show cached products (stale fallback)
4. Pull-to-refresh should show error but keep displaying cached data

### 3. Expected Behavior

✅ **Cart Operations Work:**
- Add to cart button responds
- Quantity controls appear
- Quantity updates in real-time
- Changes reflect in cart screen
- Changes reflect in category/home screens

✅ **Wishlist Operations Work:**
- Remove from wishlist works
- Pull-to-refresh fetches new data
- Data persists after app restart
- Offline mode shows cached data

✅ **UI Consistent:**
- Same 3-column grid layout
- Product images display correctly
- Discount badges show when applicable
- Prices show current vs MRP

## Troubleshooting

### Issue: Cart buttons still not working

**Solution:** Did you pull-to-refresh?
```
1. Navigate to wishlist
2. Pull down on the screen to refresh
3. Wait for refresh to complete
4. Try cart operations again
```

### Issue: Old data still showing

**Solution:** Clear app data
```bash
# On device/emulator
flutter clean
flutter run
```

Or manually:
- Settings → Apps → I-Mart → Storage → Clear Data

### Issue: "Invalid product ID" error

**Diagnosis:** Check if `productId` is set
```dart
// Add temporary debug in WishlistProductCard._handleAddToCart():
print('Product ID: "${widget.item.productId}"');
print('Parsed: ${int.tryParse(widget.item.productId)}');
```

If productId is empty:
1. Pull-to-refresh didn't run
2. Or data source fix isn't applied

## Architecture Benefits

### 1. Separation of Concerns
- WishlistProductCard → Wishlist-specific UI
- ProductCard → Category/Home UI
- No shared state between features

### 2. Single Responsibility
- WishlistProductCard only handles wishlist display + cart operations
- No complex model conversions
- Direct entity usage

### 3. Maintainability
- Changes to CategoryProduct don't affect wishlist
- Changes to WishlistItem automatically propagate
- Easier to debug (single component)

### 4. Performance
- Hive cache = Instant load on app start
- No unnecessary model conversions
- Optimistic updates with Riverpod

## API Contracts

### Wishlist List
**Endpoint:** `GET /api/order/v1/wishlist/`
```json
[
  {
    "id": 123,
    "product_variant": "3052",
    "added_at": "2026-01-19T10:00:00Z"
  }
]
```

### Product Variant Details
**Endpoint:** `GET /api/products/v1/variants/3052/`
```json
{
  "name": "Product Name",
  "price": "120.00",
  "discounted_price": "99.00",
  "stock_unit": "1 kg",
  "media": [
    {
      "image": "http://example.com/image.jpg"
    }
  ]
}
```

### Add to Cart
**Endpoint:** `POST /api/order/v1/checkout-lines/`
```json
{
  "product_variant_id": 3052,
  "quantity": 1
}
```

### Update Cart Quantity
**Endpoint:** `PATCH /api/order/v1/checkout-lines/{line_id}/`
```json
{
  "product_variant_id": 3052,
  "quantity": -1  // Delta (can be negative)
}
```

## Status

✅ **WishlistProductCard created**
✅ **Hive persistent storage implemented**
✅ **Cache clear on refresh**
✅ **Cart operations integrated**
✅ **Wishlist screen updated**
✅ **Flutter analyze: 0 errors**
✅ **Ready for testing**

---

**Created by:** Claude Sonnet 4.5
**Date:** January 19, 2026
**Task:** Dedicated wishlist product card with cart integration and Hive storage
**Priority:** P0

# Home & Product Details Cart Integration Plan

## Overview

Currently, both the Home page and Product Details page use **local state** (`_isAddedToCart`, `_quantity`) instead of integrating with the CartController backend. This document outlines the integration plan.

## Current Issues

### Home Page (`lib/features/home/presentation/home.dart`)
- **Line 334-336**: Uses local state variables
```dart
bool _isAddedToCart = false;
bool _isFavorite = false;
int _quantity = 2;
```
- **Lines 490-493**: Shows quantity selector based on local `_isAddedToCart`
- **Lines 558-567**: Decrement button uses local state
- **Lines 600-604**: Increment button uses local state
- **Lines 630-633**: Add to cart only updates local state

**Problems**:
- ❌ Cart doesn't sync with server
- ❌ Quantities don't persist across app restarts
- ❌ No real-time updates when cart changes elsewhere
- ❌ Cart screen and home screen show different quantities

### Product Details Page (`lib/features/product_details/presentation/product_detail_screen.dart`)
- **Line 38**: Uses local quantity state
```dart
int _quantity = 1;
```
- **Lines 669-674**: Add to cart only updates local state
- **Lines 710-717**: Decrement uses local state
- **Lines 767-774**: Increment uses local state

**Problems**:
- ❌ Same issues as Home page
- ❌ Stock validation only happens on UI (should validate on server)

---

## Integration Strategy

### Approach 1: Convert to ConsumerStatefulWidget (Recommended)

**Same pattern as Category ProductCard** - Already proven to work!

#### Steps for Each Product Card:

1. **Convert StatefulWidget → ConsumerStatefulWidget**
2. **Remove local state variables**
3. **Add helper methods to read from CartController**
4. **Update button handlers to call CartController methods**
5. **Add loading states with throttling**

### Approach 2: Reuse Category ProductCard Component

**Even simpler** - Just use the existing ProductCard!

#### Steps:

1. **Convert data models** to `CategoryProduct` format
2. **Import and use** existing `ProductCard` component
3. **Done!** - No new code needed

**Pros**: Less code, consistent UI/UX, all features work immediately
**Cons**: Might need UI adjustments to match design

---

## Detailed Integration Plan

### Phase 1: Home Page Integration

#### File: `lib/features/home/presentation/home.dart`

#### 1.1 Add CartController Import

**Add to imports** (after line 20):
```dart
import 'package:imart/features/cart/application/controllers/cart_controller.dart';
```

#### 1.2 Convert _ProductCard to ConsumerStatefulWidget

**Change** (line 312):
```dart
// Before:
class _ProductCard extends StatefulWidget {

// After:
class _ProductCard extends ConsumerStatefulWidget {
```

**Change** (line 330):
```dart
// Before:
State<_ProductCard> createState() => _ProductCardState();

// After:
ConsumerState<_ProductCard> createState() => _ProductCardState();
```

**Change** (line 333):
```dart
// Before:
class _ProductCardState extends State<_ProductCard> {

// After:
class _ProductCardState extends ConsumerState<_ProductCard> {
```

#### 1.3 Add Loading State Variables

**Replace** (lines 334-336):
```dart
// Before:
bool _isAddedToCart = false;
bool _isFavorite = false;
int _quantity = 2;

// After:
bool _isFavorite = false;
bool _isAddingToCart = false;
bool _isUpdatingQuantity = false;
DateTime? _lastUpdateTime;
```

#### 1.4 Add Helper Methods

**Add after line 337** (before `build` method):
```dart
/// Get cart quantity for this product from cart state
int _getCartQuantity() {
  if (!mounted) return 0;

  final cartState = ref.watch(cartControllerProvider);
  if (cartState.data == null) return 0;

  // Get variant ID
  final variantId = widget.productVariant?.id ?? widget.variantId;
  if (variantId == null) return 0;

  try {
    final line = cartState.data!.results.firstWhere(
      (line) => line.productVariantId == variantId,
    );
    return line.quantity;
  } catch (e) {
    return 0; // Not in cart
  }
}

/// Get checkout line ID for this product
int? _getCheckoutLineId() {
  if (!mounted) return null;

  final cartState = ref.read(cartControllerProvider);
  if (cartState.data == null) return null;

  final variantId = widget.productVariant?.id ?? widget.variantId;
  if (variantId == null) return null;

  try {
    final line = cartState.data!.results.firstWhere(
      (line) => line.productVariantId == variantId,
    );
    return line.id;
  } catch (e) {
    return null;
  }
}
```

#### 1.5 Update Add to Cart Handler

**Replace** `_buildAddToCartButton` tap handler (lines 630-633):
```dart
// Before:
GestureDetector(
  onTap: () {
    setState(() {
      _isAddedToCart = true;
    });
  },

// After:
GestureDetector(
  onTap: _isAddingToCart ? null : _handleAddToCart,
```

**Add new method**:
```dart
Future<void> _handleAddToCart() async {
  final variantId = widget.productVariant?.id ?? widget.variantId;
  if (variantId == null) return;

  setState(() {
    _isAddingToCart = true;
  });

  try {
    await ref.read(cartControllerProvider.notifier).addToCart(
      productVariantId: variantId,
      quantity: 1,
    );
  } catch (e) {
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

#### 1.6 Update Increment/Decrement Handlers

**Replace** increment handler (lines 599-604):
```dart
// Before:
GestureDetector(
  onTap: () {
    setState(() {
      _quantity++;
    });
  },

// After:
GestureDetector(
  onTap: _isUpdatingQuantity ? null : _handleIncreaseQuantity,
```

**Replace** decrement handler (lines 558-567):
```dart
// Before:
GestureDetector(
  onTap: () {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      } else {
        _isAddedToCart = false;
        _quantity = 2;
      }
    });
  },

// After:
GestureDetector(
  onTap: _isUpdatingQuantity ? null : _handleDecreaseQuantity,
```

**Add new methods**:
```dart
Future<void> _handleIncreaseQuantity() async {
  final now = DateTime.now();
  if (_lastUpdateTime != null &&
      now.difference(_lastUpdateTime!) < const Duration(milliseconds: 300)) {
    return;
  }

  if (_isUpdatingQuantity) return;

  final lineId = _getCheckoutLineId();
  final variantId = widget.productVariant?.id ?? widget.variantId;
  if (lineId == null || variantId == null) return;

  setState(() {
    _isUpdatingQuantity = true;
    _lastUpdateTime = now;
  });

  try {
    ref.read(cartControllerProvider.notifier).updateQuantity(
      lineId: lineId,
      productVariantId: variantId,
      quantityDelta: 1,
    );

    await Future.delayed(const Duration(milliseconds: 150));
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isUpdatingQuantity = false;
      });
    }
  }
}

Future<void> _handleDecreaseQuantity() async {
  final now = DateTime.now();
  if (_lastUpdateTime != null &&
      now.difference(_lastUpdateTime!) < const Duration(milliseconds: 300)) {
    return;
  }

  if (_isUpdatingQuantity) return;

  final lineId = _getCheckoutLineId();
  final variantId = widget.productVariant?.id ?? widget.variantId;
  if (lineId == null || variantId == null) return;

  setState(() {
    _isUpdatingQuantity = true;
    _lastUpdateTime = now;
  });

  try {
    ref.read(cartControllerProvider.notifier).updateQuantity(
      lineId: lineId,
      productVariantId: variantId,
      quantityDelta: -1,
    );

    await Future.delayed(const Duration(milliseconds: 150));
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isUpdatingQuantity = false;
      });
    }
  }
}
```

#### 1.7 Update UI to Show Cart Quantity

**Replace** (line 490):
```dart
// Before:
if (_isAddedToCart)

// After:
if (_getCartQuantity() > 0)
```

**Replace** quantity display (line 590):
```dart
// Before:
Text('$_quantity', ...)

// After:
Text('${_getCartQuantity()}', ...)
```

#### 1.8 Add Loading State to Button

**Update Add to Cart button** (line 635-655):
```dart
child: _isAddingToCart
  ? SizedBox(
      width: 16.w,
      height: 16.h,
      child: CircularProgressIndicator(
        strokeWidth: 2.w,
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF25A63E)),
      ),
    )
  : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(...),
        SizedBox(width: 6.w),
        const AppText(text: 'Add to cart', fontSize: 12),
      ],
    ),
```

#### 1.9 Add Loading State to Quantity Selector

**Update quantity selector** (wrap in Opacity):
```dart
Widget _buildQuantitySelector() {
  return Opacity(
    opacity: _isUpdatingQuantity ? 0.6 : 1.0,
    child: Row(
      // ... existing content
    ),
  );
}
```

---

### Phase 2: Product Details Page Integration

#### File: `lib/features/product_details/presentation/product_detail_screen.dart`

#### 2.1 Same Steps as Home Page

Follow the same pattern:
1. ✅ Already a ConsumerStatefulWidget
2. Add CartController import
3. Add loading state variables
4. Add helper methods (`_getCartQuantity`, `_getCheckoutLineId`)
5. Update Add to Cart button handler
6. Update increment/decrement handlers
7. Replace `_quantity` with `_getCartQuantity()`
8. Add loading states to buttons

#### 2.2 Additional Considerations

**Stock Validation**:
- Keep local stock validation for better UX
- Server will validate anyway (catches race conditions)

**Quantity Initialization**:
```dart
// In initState or when product loads:
// Don't initialize _quantity to 1
// Instead, read from cart:
final cartQty = _getCartQuantity();
// Only show quantity selector if cartQty > 0
```

---

## Testing Plan

### Test Scenarios

#### Test 1: Home Page Add to Cart
1. Open home page
2. Tap "Add to cart" on a product
3. ✅ Button shows loading spinner
4. ✅ Button changes to quantity selector
5. ✅ Quantity shows "1"
6. ✅ Cart badge updates

#### Test 2: Home Page Increment/Decrement
1. Add product to cart
2. Tap "+"
3. ✅ Buttons turn grey with spinner
4. ✅ Quantity increases to 2
5. Tap "-"
6. ✅ Quantity decreases to 1

#### Test 3: Cross-Page Sync
1. Add product from home page (quantity: 2)
2. Navigate to product details for same product
3. ✅ Product details shows quantity: 2
4. Navigate to cart screen
5. ✅ Cart shows quantity: 2
6. Update quantity in cart to 5
7. Go back to home page
8. ✅ Home page shows quantity: 5

#### Test 4: App Restart
1. Add products from home page
2. Close/kill app
3. Reopen app
4. Navigate to home page
5. ✅ Products show correct quantities from server

#### Test 5: Rapid Taps
1. Add product to cart
2. Rapidly tap "+" 10 times
3. ✅ Only ~3 updates go through (throttled)
4. ✅ No crashes or out-of-sync issues

---

## Implementation Checklist

### Home Page
- [ ] Add CartController import
- [ ] Convert _ProductCard to ConsumerStatefulWidget
- [ ] Add loading state variables
- [ ] Add `_getCartQuantity()` helper method
- [ ] Add `_getCheckoutLineId()` helper method
- [ ] Implement `_handleAddToCart()` method
- [ ] Implement `_handleIncreaseQuantity()` method
- [ ] Implement `_handleDecreaseQuantity()` method
- [ ] Update button tap handlers
- [ ] Replace `_quantity` with `_getCartQuantity()`
- [ ] Replace `_isAddedToCart` check with `_getCartQuantity() > 0`
- [ ] Add loading spinner to Add to Cart button
- [ ] Add loading state to quantity selector
- [ ] Test all scenarios

### Product Details Page
- [ ] Add CartController import
- [ ] Add loading state variables
- [ ] Add `_getCartQuantity()` helper method
- [ ] Add `_getCheckoutLineId()` helper method
- [ ] Implement `_handleAddToCart()` method
- [ ] Implement `_handleIncreaseQuantity()` method
- [ ] Implement `_handleDecreaseQuantity()` method
- [ ] Update button tap handlers
- [ ] Replace `_quantity` with `_getCartQuantity()`
- [ ] Add loading spinners to buttons
- [ ] Test all scenarios

---

## Benefits After Integration

### For Users
- ✅ Cart syncs across all pages (home, details, cart, category)
- ✅ Cart persists across app restarts
- ✅ Real-time updates when cart changes
- ✅ Consistent quantity display everywhere
- ✅ Better error handling (server validation)

### For Developers
- ✅ Single source of truth (CartController)
- ✅ Consistent code patterns across all pages
- ✅ Easier to maintain and debug
- ✅ Server handles stock validation
- ✅ Built-in caching and optimization (HTTP 304)

---

## Alternative: Use Existing ProductCard Component

Instead of converting each card individually, we could:

1. **Create adapter functions** to convert data models:
```dart
CategoryProduct _toCategoryProduct(ProductVariant variant) {
  return CategoryProduct(
    variantId: variant.id.toString(),
    variantName: variant.name,
    name: variant.name,
    price: variant.price,
    originalPrice: variant.originalPrice,
    weight: variant.weight,
    imageUrl: variant.primaryImageUrl,
    inStock: variant.inStock,
  );
}
```

2. **Replace custom cards** with ProductCard:
```dart
// Instead of:
_ProductCard(title: product.name, ...)

// Use:
ProductCard(
  product: _toCategoryProduct(product),
  colorScheme: Theme.of(context).colorScheme,
)
```

**Pros**:
- ✅ Less code
- ✅ Consistent UI/UX
- ✅ All features work immediately (throttling, loading, etc.)

**Cons**:
- ⚠️ UI might not match exact design
- ⚠️ Need to adjust ProductCard if design differs

---

## Recommendation

**For Home Page**: Use Approach 1 (convert to ConsumerStatefulWidget) to maintain current design.

**For Product Details**: Use Approach 1 but consider simplifying the quantity selector to match other pages.

**Long-term**: Consider creating a reusable `ProductQuantitySelector` widget that all pages can use.

---

**Status**: ⏳ Plan Created - Ready for Implementation
**Next Action**: Implement Phase 1 (Home Page Integration)

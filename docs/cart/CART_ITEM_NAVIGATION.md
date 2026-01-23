# Cart Item Navigation to Product Detail

## Feature Summary

**Feature:** Make cart items clickable to navigate to product detail page

**User Request:** "set like that when press on product list in cart session navigate the product details page"

**Priority:** P2 - Medium (User experience improvement)

## Implementation

### 1. Made Cart Item Clickable

Wrapped the entire `CartItemWidget` with a `GestureDetector` to make it tappable.

**File:** `cart_item_widget.dart` (lines 33-34, 146-147)

```dart
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onInfoTap, // ✅ NEW: Triggers navigation callback
    child: Container(
      height: 90.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        // ... cart item content
      ),
    ),
  );
}
```

**Note:** The `onInfoTap` callback already existed in the widget but wasn't being used.

### 2. Added Navigation Logic in Cart Screen

Added `onInfoTap` callback to navigate to product detail page using GoRouter.

**File:** `cart_screen.dart` (lines 208-217)

```dart
final cartItem = CartItemWidget(
  productName: checkoutLine.productVariantDetails.name,
  unit: checkoutLine.productVariantDetails.sku,
  // ... other properties
  onInfoTap: () {
    // Navigate to product detail page
    final router = GoRouter.of(context);
    final imageUrl = checkoutLine.productVariantDetails.primaryImageUrl;
    final uri = Uri(
      path: '/product/${checkoutLine.productVariantId}',
      queryParameters: imageUrl != null ? {'imageUrl': imageUrl} : null,
    );
    router.push(uri.toString());
  },
);
```

### 3. Added GoRouter Import

**File:** `cart_screen.dart` (line 5)

```dart
import 'package:go_router/go_router.dart';
```

## How It Works

### User Flow:

1. ✅ User views cart with list of items
2. ✅ User taps anywhere on a cart item card
3. ✅ App navigates to product detail page for that item
4. ✅ Product detail shows with correct variant ID
5. ✅ User can view full product info, images, reviews, etc.
6. ✅ User can tap back to return to cart

### Navigation Details:

**Route Format:**
```
/product/{variantId}?imageUrl={imageUrl}
```

**Example:**
```
/product/19?imageUrl=https://grocery-application.b-cdn.net/products/media/abc123.webp
```

**Parameters:**
- `variantId` - The product variant ID from cart (required)
- `imageUrl` - Primary image URL for faster loading (optional)

### Preserves Cart State:

When navigating to product detail and back:
- ✅ Cart items remain unchanged
- ✅ Quantities preserved
- ✅ No data loss
- ✅ Smooth navigation experience

## Benefits

### 1. Better User Experience
- ✅ Quick access to product details from cart
- ✅ Can review product info before checkout
- ✅ Natural tap interaction (entire card is tappable)
- ✅ Consistent with other parts of app (category, home)

### 2. Increased User Confidence
- ✅ Can verify product details before purchasing
- ✅ Can check reviews and ratings
- ✅ Can see full product images
- ✅ Can compare with other variants

### 3. Reduces Cart Abandonment
- ✅ Users can quickly double-check items
- ✅ Reduces uncertainty about products
- ✅ Smooth shopping experience

## Interaction Areas

### Tappable Area:
The **entire cart item card** is now tappable, including:
- ✅ Product image
- ✅ Product name
- ✅ Unit/SKU
- ✅ Price area
- ✅ Empty space around content

### Non-Tappable Areas (Still Functional):
The quantity controls remain separate and functional:
- ➖ **Minus button** - Decreases quantity
- ➕ **Plus button** - Increases quantity
- These buttons have their own tap handlers and won't trigger navigation

## Testing

### Test Case 1: Navigate from Cart
1. Add items to cart
2. Navigate to cart screen
3. Tap on any cart item card
4. **Verify:** Navigates to product detail page
5. **Verify:** Shows correct product
6. **Verify:** Wishlist icon shows correct state
7. Tap back button
8. **Verify:** Returns to cart with items intact

### Test Case 2: Multiple Items
1. Add multiple different items to cart
2. Navigate to cart screen
3. Tap on first item
4. **Verify:** Shows first product details
5. Navigate back
6. Tap on second item
7. **Verify:** Shows second product details
8. Navigate back
9. **Verify:** Cart unchanged

### Test Case 3: Quantity Controls Still Work
1. Navigate to cart screen
2. Tap on minus button of an item
3. **Verify:** Quantity decreases (no navigation)
4. Tap on plus button
5. **Verify:** Quantity increases (no navigation)
6. Tap on the product name area
7. **Verify:** Navigates to product detail

### Test Case 4: Empty Image Fallback
1. Add item with no image to cart
2. Tap on cart item
3. **Verify:** Navigation works
4. **Verify:** Product detail loads correctly
5. **Verify:** No imageUrl query parameter in URL

## Edge Cases Handled

### 1. Missing Image URL
```dart
queryParameters: imageUrl != null ? {'imageUrl': imageUrl} : null,
```
- If no image URL, navigation still works
- Query parameter is omitted
- Product detail loads with default image

### 2. Invalid Variant ID
- GoRouter handles invalid routes
- Shows error page or 404
- User can navigate back

### 3. Network Issues
- Navigation happens immediately (no API call)
- Product detail page handles loading state
- User sees loading indicator if needed

## User Experience Flow

```
Cart Screen
     |
     | (User taps cart item)
     |
     v
Product Detail Page
     |
     | - Full product info
     | - All images
     | - Reviews & ratings
     | - Wishlist toggle
     | - Add to cart
     |
     | (User taps back)
     |
     v
Cart Screen (unchanged)
```

## Comparison with Other Screens

All product cards across the app now have consistent behavior:

| Screen | Tap Behavior | Status |
|--------|-------------|--------|
| Home Page | Navigate to detail | ✅ Already working |
| Category Page | Navigate to detail | ✅ Already working |
| Wishlist Page | Navigate to detail | ✅ Already working |
| **Cart Page** | Navigate to detail | ✅ **NEW - Now working** |

## Files Modified

### 1. `cart_item_widget.dart`
**Changes:**
- Wrapped Container with GestureDetector (line 33)
- Added onTap handler using onInfoTap callback (line 34)
- Added closing parentheses for GestureDetector (lines 146-147)

**Impact:** Cart items are now tappable

### 2. `cart_screen.dart`
**Changes:**
- Added GoRouter import (line 5)
- Added onInfoTap callback to CartItemWidget (lines 208-217)
- Navigation logic using variant ID and image URL

**Impact:** Tapping cart items navigates to product detail

## Additional Features to Consider (Future)

### 1. Visual Feedback on Tap
```dart
GestureDetector(
  onTap: onInfoTap,
  child: AnimatedContainer(
    // Add subtle scale or color change on tap
  ),
)
```

### 2. Long Press for Quick Actions
```dart
GestureDetector(
  onTap: onInfoTap,
  onLongPress: () {
    // Show bottom sheet with:
    // - Remove from cart
    // - Add to wishlist
    // - View details
  },
)
```

### 3. Swipe Actions
```dart
Dismissible(
  key: Key(item.id),
  direction: DismissDirection.endToStart,
  onDismissed: (direction) {
    // Remove from cart
  },
  background: Container(
    // Show delete icon
  ),
  child: CartItemWidget(...),
)
```

## Performance Considerations

### Navigation Performance:
- ✅ **Instant navigation** - No API calls needed
- ✅ **Route-based** - Uses GoRouter (efficient)
- ✅ **Preserves state** - Cart data cached

### Memory Considerations:
- ✅ **No memory leaks** - GestureDetector properly disposed
- ✅ **Efficient rebuilds** - Only affected widget rebuilds
- ✅ **Lazy loading** - Product detail loads on demand

## Accessibility

The GestureDetector makes the cart item:
- ✅ **Tappable** - Standard touch interaction
- ✅ **Semantically correct** - Wrapper doesn't affect child semantics
- ✅ **Screen reader friendly** - Maintains text hierarchy

For better accessibility, consider adding:
```dart
Semantics(
  button: true,
  label: 'View details for ${productName}',
  child: GestureDetector(
    // ...
  ),
)
```

---

**Implemented by:** Claude Sonnet 4.5
**Date:** January 20, 2026
**Feature:** Cart item navigation to product detail
**Type:** User experience improvement
**Priority:** P2 - Medium
**Status:** ✅ Complete

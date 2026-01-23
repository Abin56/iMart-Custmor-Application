# Cart Loading States Guide

## Overview

The cart screen already has comprehensive loading states implemented. This guide explains all the different states users will see.

---

## All Cart States

### 1. ⏳ Loading State (Initial Load)

**When**: First time opening cart screen or after app restart (before data arrives)

**Condition**: `cartState.status == CartStatus.loading && cartState.data == null`

**UI**:
```
┌────────────────────────┐
│  ← Cart                │ ← Green header
├────────────────────────┤
│                        │
│                        │
│         ⏳             │ ← CircularProgressIndicator
│                        │
│                        │
└────────────────────────┘
```

**Code** (`cart_screen.dart` lines 57-70):
```dart
if (cartState.status == CartStatus.loading && cartState.data == null) {
  return Scaffold(
    backgroundColor: AppColors.white,
    body: Column(
      children: [
        Container(height: 13.h, color: const Color(0xFF0D5C2E)),
        _buildHeader(),
        const Expanded(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    ),
  );
}
```

**Duration**: ~200ms (time for API to respond)

---

### 2. ❌ Error State (Load Failed)

**When**: API call fails (network error, server down, authentication issue)

**Condition**: `cartState.status == CartStatus.error && cartState.data == null`

**UI**:
```
┌────────────────────────┐
│  ← Cart                │ ← Green header
├────────────────────────┤
│                        │
│        ⚠️             │ ← Error icon
│                        │
│  Error loading cart    │ ← Error title
│  [error message]       │ ← Specific error
│                        │
│     [Retry Button]     │ ← Retry action
│                        │
└────────────────────────┘
```

**Code** (`cart_screen.dart` lines 73-111):
```dart
if (cartState.status == CartStatus.error && cartState.data == null) {
  return Scaffold(
    backgroundColor: AppColors.white,
    body: Column(
      children: [
        Container(height: 13.h, color: const Color(0xFF0D5C2E)),
        _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text('Error loading cart', ...),
                SizedBox(height: 8.h),
                Text(cartState.errorMessage ?? 'Unknown error', ...),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    ref.read(cartControllerProvider.notifier).loadCart(forceRefresh: true);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

**Error Examples**:
- "Authentication required" → User not logged in
- "Failed to load cart: Connection timeout" → Network issue
- "Failed to load cart: Server error" → Backend issue

**User Action**: Tap "Retry" button to reload cart

---

### 3. 🛒 Empty Cart State

**When**: Cart loaded successfully but has no items

**Condition**: `cartState.isEmpty` (cart loaded, but results array is empty)

**UI**:
```
┌────────────────────────┐
│  ← Cart                │ ← Green header
├────────────────────────┤
│                        │
│         🛒            │ ← Shopping cart icon (grey)
│                        │
│  Your cart is empty    │ ← Empty message
│  Add items to get      │
│      started           │
│                        │
└────────────────────────┘
```

**Code** (`cart_screen.dart` lines 114-155):
```dart
if (cartState.isEmpty) {
  return Scaffold(
    backgroundColor: AppColors.white,
    body: Column(
      children: [
        Container(height: 13.h, color: const Color(0xFF0D5C2E)),
        _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80.sp,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16.h),
                Text('Your cart is empty', ...),
                SizedBox(height: 8.h),
                Text('Add items to get started', ...),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

**User Action**: Go back to category/home and add items

---

### 4. ✅ Loaded State (Cart with Items)

**When**: Cart loaded successfully with items

**Condition**: `cartState.status == CartStatus.loaded && cartState.data != null && !cartState.isEmpty`

**UI**:
```
┌────────────────────────┐
│  ← Cart                │ ← Green header
├────────────────────────┤
│  ● ● ○                 │ ← Progress stepper
├────────────────────────┤
│  🍎 Premium Nuts       │ ← Cart items
│  ₹3.50    [-] 2 [+]    │
├────────────────────────┤
│  🍏 Fresh Apple        │
│  ₹2.00    [-] 1 [+]    │
├────────────────────────┤
│                        │
│  Subtotal:      ₹5.50  │ ← Bill summary
│  Tax:           ₹0.11  │
│  Delivery:      Free   │
│  Total:         ₹5.61  │
├────────────────────────┤
│ [Proceed to Checkout]  │ ← Checkout button
└────────────────────────┘
```

**Code** (`cart_screen.dart` lines 157-247):
```dart
final cartItems = cartState.data!.results;

return Scaffold(
  backgroundColor: AppColors.white,
  body: Column(
    children: [
      Container(height: 13.h, color: const Color(0xFF0D5C2E)),
      _buildHeader(),

      // Progress Stepper
      const CartStepper(),

      // Cart Items (scrollable)
      Expanded(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final checkoutLine = cartItems[index];
            return CartItemWidget(
              productName: checkoutLine.productVariantDetails.name,
              quantity: checkoutLine.quantity,
              onIncrement: () { ... },
              onDecrement: () { ... },
            );
          },
        ),
      ),

      // Bill Summary (fixed at bottom)
      BillSummary(...),

      // Checkout Button (fixed at bottom)
      _buildCheckoutButton(),
    ],
  ),
);
```

**Features**:
- ✅ Animated slide-in for first 5 items
- ✅ Scrollable item list
- ✅ Increment/decrement buttons per item
- ✅ Real-time price calculation
- ✅ Fixed bill summary and checkout button

---

## Loading Flow Timeline

### Scenario 1: App Start → Navigate to Cart

```
0ms   - App starts
0ms   - CartController.build() called
0ms   - Future.microtask(loadCart) scheduled
0ms   - Cart screen builds
0ms   - CartState.status = loading, data = null
        ↓
        Shows: ⏳ Loading spinner
        ↓
~10ms - loadCart() executes
~10ms - API call: GET /api/order/v1/checkout-lines/
        ↓
~200ms - Server responds with cart data
~200ms - CartState.status = loaded, data = CheckoutLinesResponse(...)
        ↓
        Shows: ✅ Cart items with bill summary
```

### Scenario 2: Empty Cart

```
0ms   - loadCart() executes
~200ms - Server responds: {"count": 0, "results": []}
~200ms - CartState.isEmpty = true
        ↓
        Shows: 🛒 Empty cart message
```

### Scenario 3: Network Error

```
0ms   - loadCart() executes
~30s  - Connection timeout
~30s  - CartState.status = error, errorMessage = "Connection timeout"
        ↓
        Shows: ❌ Error screen with Retry button
```

### Scenario 4: Not Logged In

```
0ms   - loadCart() executes
~200ms - Server responds: 401 Unauthorized
~200ms - CartState.status = error, errorMessage = "Authentication required"
        ↓
        Shows: ❌ Error screen with Retry button
```

---

## Refreshing Cart (Pull to Refresh)

**Current Implementation**: No pull-to-refresh yet (but can be added easily)

**Auto-Refresh**: Cart automatically refreshes every 30 seconds via polling

**Manual Refresh**:
- ✅ Error screen has "Retry" button
- ✅ CartController.loadCart(forceRefresh: true) can be called anytime

---

## Loading States in Product Cards

Product cards also show loading states during add/increment/decrement:

### Product Card Loading State

**When**: User taps +/- buttons

**UI Changes**:
```
Before tap:
[-] 2 [+]  ← Green buttons

During update (300ms):
[-] 2 [+]  ← Grey buttons with spinner
  ⏳ ⏳   ← Loading spinners in circles
Entire widget: 60% opacity

After update:
[-] 3 [+]  ← Green buttons, quantity updated
```

**Code** (from Phase 12):
```dart
Widget _buildQuantitySelector() {
  return Opacity(
    opacity: _isUpdatingQuantity ? 0.6 : 1.0,
    child: Container(
      child: Row(
        children: [
          GestureDetector(
            onTap: _isUpdatingQuantity ? null : _handleDecreaseQuantity,
            child: Container(
              decoration: BoxDecoration(
                color: _isUpdatingQuantity
                    ? Colors.grey.shade400  // Grey when loading
                    : const Color(0xFF25A63E),  // Green when ready
              ),
              child: _isUpdatingQuantity
                  ? CircularProgressIndicator(...)  // Spinner
                  : Icon(Icons.remove),  // Minus icon
            ),
          ),
          Text('${_getCartQuantity()}'),
          GestureDetector(
            onTap: _isUpdatingQuantity ? null : _handleIncreaseQuantity,
            child: Container(
              decoration: BoxDecoration(
                color: _isUpdatingQuantity
                    ? Colors.grey.shade400
                    : const Color(0xFF25A63E),
              ),
              child: _isUpdatingQuantity
                  ? CircularProgressIndicator(...)
                  : Icon(Icons.add),
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## State Transition Diagram

```
App Start
    ↓
CartController initializes
    ↓
CartState.initial() (loading, data=null)
    ↓
┌─────────────────────────────────────┐
│ loadCart() called automatically     │
└─────────────────────────────────────┘
    ↓
    ├─ Success → CartState(loaded, data=response)
    │              ↓
    │              ├─ Empty? → Show empty cart 🛒
    │              └─ Has items? → Show cart items ✅
    │
    └─ Error → CartState(error, errorMessage)
                   ↓
                   Show error screen with Retry ❌
```

---

## Testing All States

### Test 1: Loading State
1. Close app
2. Turn off internet briefly
3. Open app
4. Navigate to cart immediately
5. Turn on internet after 1 second
6. ✅ Should see loading spinner for 1 second
7. ✅ Then cart items appear

### Test 2: Error State
1. Turn off internet
2. Open app
3. Navigate to cart
4. ✅ Should see error screen after timeout
5. ✅ Error message: "Connection timeout" or similar
6. Turn on internet
7. Tap "Retry" button
8. ✅ Cart loads successfully

### Test 3: Empty Cart State
1. Open app (logged in)
2. Delete all items from cart (via API or another device)
3. Navigate to cart screen
4. ✅ Should see empty cart icon and message
5. ✅ No checkout button or bill summary

### Test 4: Cart with Items
1. Add 2-3 items to cart
2. Restart app
3. Navigate to cart
4. ✅ Brief loading (~200ms)
5. ✅ Cart items slide in with animation
6. ✅ Bill summary and checkout button appear

### Test 5: Product Card Loading
1. Open category page
2. Add item to cart
3. Rapidly tap + button 5 times
4. ✅ Buttons turn grey during updates
5. ✅ Spinner appears in button circles
6. ✅ Only ~3 updates go through (throttled)

---

## Summary

### Cart Screen States

| State | Icon | Message | Actions | Duration |
|-------|------|---------|---------|----------|
| **Loading** | ⏳ | CircularProgressIndicator | None | ~200ms |
| **Error** | ❌ | "Error loading cart" | Retry button | Until retry |
| **Empty** | 🛒 | "Your cart is empty" | Go back to shop | Until items added |
| **Loaded** | ✅ | Cart items list | Increment/Decrement | Persistent |

### Product Card States

| State | Button Color | Icon | Tap Enabled | Duration |
|-------|-------------|------|-------------|----------|
| **Ready** | Green | +/- | ✅ Yes | Persistent |
| **Updating** | Grey | ⏳ Spinner | ❌ No | ~300ms |

---

## Code Locations

### Cart Screen Loading States
- **File**: `lib/features/cart/presentation/screen/cart_screen.dart`
- **Loading**: Lines 57-70
- **Error**: Lines 73-111
- **Empty**: Lines 114-155
- **Loaded**: Lines 157-247

### Product Card Loading States
- **File**: `lib/features/category/product_card.dart`
- **State Variables**: Lines 48-49
- **Quantity Selector**: Lines 587-664
- **Increment/Decrement**: Lines 221-317

### Cart Controller
- **File**: `lib/features/cart/application/controllers/cart_controller.dart`
- **Initial Load**: Line 27
- **Polling**: Lines 42-45

---

**Status**: ✅ All loading states already implemented and working

**What Users See**:
- ⏳ Loading spinner when cart is fetching
- ❌ Error message with retry when load fails
- 🛒 Empty cart message when no items
- ✅ Cart items with smooth animations
- ⏳ Button loading states during quantity updates

**No Additional Changes Needed**: Loading states are comprehensive and working correctly!

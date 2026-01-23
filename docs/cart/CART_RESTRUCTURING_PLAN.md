# Cart Feature Restructuring Plan

> **Date**: 2026-01-18
> **Task**: Restructure cart feature to follow Clean Architecture + Integrate Backend
> **Important**: DO NOT change existing UI/UX - only refactor structure and add backend

---

## Current Structure Analysis

### Existing Files
```
lib/features/cart/
├── cart_screen.dart           (Main screen with dummy data)
├── cart_item_widget.dart       (Cart item UI component)
├── bill_summary.dart          (Bill calculation UI)
├── cart_stepper.dart          (Step indicator UI)
├── checkout_flow_screen.dart  (Multi-step checkout wrapper)
├── address_session_screen.dart (Address selection screen)
├── payment_session_screen.dart (Payment screen)
└── promo_bottom_sheet.dart    (Promo code bottom sheet)
```

### Issues
1. ❌ Models defined in presentation layer (`CartItem`, `PromoOffer` in UI files)
2. ❌ Hardcoded dummy data
3. ❌ No domain/application/infrastructure layers
4. ❌ No backend integration
5. ❌ No state management with Riverpod
6. ❌ Violates Clean Architecture

---

## Target Structure (Clean Architecture)

```
lib/features/cart/
├── domain/
│   ├── entities/
│   │   ├── checkout_line.dart              # Cart item entity
│   │   ├── product_variant_details.dart    # Product details in cart
│   │   ├── product_image.dart              # Product image entity
│   │   ├── checkout_lines_response.dart    # Cart response wrapper
│   │   ├── address.dart                    # Address entity
│   │   ├── address_list_response.dart      # Address list wrapper
│   │   ├── coupon.dart                     # Coupon/promo entity
│   │   ├── coupon_list_response.dart       # Coupon list wrapper
│   │   ├── checkout.dart                   # Checkout entity
│   │   └── payment_response.dart           # Payment response entity
│   │
│   └── repositories/
│       ├── checkout_line_repository.dart   # Abstract cart repo
│       ├── address_repository.dart         # Abstract address repo
│       ├── coupon_repository.dart          # Abstract coupon repo
│       └── order_repository.dart           # Abstract order/payment repo
│
├── infrastructure/
│   ├── models/                              # DTOs (Data Transfer Objects)
│   │   ├── checkout_line_dto.dart
│   │   ├── product_variant_details_dto.dart
│   │   ├── product_image_dto.dart
│   │   ├── checkout_lines_response_dto.dart
│   │   ├── address_dto.dart
│   │   ├── address_list_response_dto.dart
│   │   ├── coupon_dto.dart
│   │   ├── coupon_list_response_dto.dart
│   │   ├── checkout_dto.dart
│   │   └── payment_response_dto.dart
│   │
│   ├── data_sources/
│   │   ├── remote/
│   │   │   ├── checkout_line_remote_data_source.dart
│   │   │   ├── address_remote_data_source.dart
│   │   │   ├── coupon_remote_data_source.dart
│   │   │   └── order_remote_data_source.dart
│   │   │
│   │   └── local/
│   │       ├── address_local_data_source.dart
│   │       ├── address_cache_dto.dart
│   │       └── coupon_cache_dto.dart
│   │
│   └── repositories/
│       ├── checkout_line_repository_impl.dart
│       ├── address_repository_impl.dart
│       ├── coupon_repository_impl.dart
│       └── order_repository_impl.dart
│
├── application/
│   ├── states/
│   │   ├── checkout_line_state.dart        # Cart state
│   │   ├── address_state.dart              # Address state
│   │   ├── coupon_state.dart               # Coupon state
│   │   ├── applied_coupon_state.dart       # Selected coupon state
│   │   └── payment_state.dart              # Payment state
│   │
│   └── providers/
│       ├── checkout_line_controller.dart   # Cart controller (Notifier)
│       ├── address_controller.dart         # Address controller
│       ├── coupon_controller.dart          # Coupon controller
│       ├── applied_coupon_controller.dart  # Applied coupon controller
│       ├── payment_controller.dart         # Payment controller
│       ├── checkout_line_data_source_provider.dart
│       ├── address_data_source_provider.dart
│       ├── coupon_data_source_provider.dart
│       └── order_data_source_provider.dart
│
└── presentation/
    ├── screen/
    │   ├── cart_screen.dart                # REFACTORED - use providers
    │   ├── checkout_flow_screen.dart       # REFACTORED - use providers
    │   ├── address_session_screen.dart     # REFACTORED - use providers
    │   └── payment_session_screen.dart     # REFACTORED - use providers
    │
    ├── components/
    │   ├── cart_item_widget.dart           # MOVED from root
    │   ├── bill_summary.dart               # MOVED from root
    │   ├── cart_stepper.dart               # MOVED from root
    │   └── promo_bottom_sheet.dart         # MOVED & REFACTORED
    │
    └── widgets/
        ├── cart_empty_state.dart           # NEW - empty cart UI
        ├── cart_error_view.dart            # NEW - error state UI
        └── cart_loading_shimmer.dart       # NEW - loading state

```

---

## API Endpoints Integration

### Cart/Checkout Lines
- `GET /api/order/v1/checkout-lines/` - Fetch cart items
- `POST /api/order/v1/checkout-lines/` - Add to cart
- `PATCH /api/order/v1/checkout-lines/{id}/` - Update quantity (delta)
- `DELETE /api/order/v1/checkout-lines/{id}/` - Remove from cart

### Coupons
- `GET /api/order/v1/coupons/` - List available coupons

### Addresses
- `GET /api/auth/v1/address/` - List addresses
- `POST /api/auth/v1/address/` - Create address
- `PATCH /api/auth/v1/address/{id}/` - Update/Select address
- `DELETE /api/auth/v1/address/{id}/` - Delete address

### Orders & Payment
- `POST /api/order/v1/checkouts/` - Create checkout
- `PATCH /api/order/v1/checkouts/{id}/` - Apply coupon
- `POST /api/order/v1/payment/initiate/` - Create Razorpay order
- `POST /api/order/v1/payment/verify/` - Verify payment

---

## Implementation Steps

### Phase 1: Domain Layer (Pure Dart - No Flutter)
1. Create entities with Equatable
2. Add computed properties (line totals, discount percentages)
3. Add copyWith methods
4. Create repository interfaces (abstract classes)

### Phase 2: Infrastructure Layer
1. Create DTOs with fromJson/toJson
2. Create remote data sources (API calls)
3. Create local data sources (cache metadata only)
4. Implement repositories

### Phase 3: Application Layer
1. Create state classes with status enums
2. Create Riverpod controllers (Notifier pattern)
3. Implement debouncing for quantity updates
4. Implement HTTP 304 polling
5. Implement optimistic updates

### Phase 4: Presentation Layer
1. Move existing widgets to `presentation/components/`
2. Refactor screens to use Riverpod providers
3. Replace dummy data with API calls
4. Add loading/error/empty states
5. **IMPORTANT**: Keep exact same UI/UX

### Phase 5: Backend Integration Features
1. Debounced quantity updates (150ms)
2. HTTP 304 polling (30s interval)
3. Optimistic UI updates with rollback
4. Stock validation
5. Processing indicators
6. Guest mode handling
7. Razorpay payment integration

---

## File Migration Plan

### Files to Move
```
cart_item_widget.dart       → presentation/components/cart_item_widget.dart
bill_summary.dart          → presentation/components/bill_summary.dart
cart_stepper.dart          → presentation/components/cart_stepper.dart
promo_bottom_sheet.dart    → presentation/components/promo_bottom_sheet.dart
```

### Files to Refactor (Keep UI, Change Logic)
```
cart_screen.dart           → Replace dummy data with checkoutLineController
checkout_flow_screen.dart  → Integrate stepper state with backend
address_session_screen.dart → Use addressController for CRUD operations
payment_session_screen.dart → Integrate Razorpay payment flow
```

### Models to Extract to Domain
```
CartItem (in cart_screen.dart)       → domain/entities/checkout_line.dart
PromoOffer (in promo_bottom_sheet.dart) → domain/entities/coupon.dart
```

---

## Data Flow Example

### Before (Current)
```
UI (cart_screen.dart)
  ↓
Hardcoded dummy data (_cartItems list)
  ↓
Direct state manipulation (setState)
```

### After (Clean Architecture)
```
UI (cart_screen.dart)
  ↓
ref.watch(checkoutLineControllerProvider)
  ↓
CheckoutLineController (Notifier)
  ↓
CheckoutLineRepository (interface)
  ↓
CheckoutLineRepositoryImpl
  ↓
CheckoutLineRemoteDataSource (API calls)
  ↓
Backend API (Django REST)
```

---

## Key Features to Implement

### 1. Debounced Quantity Updates
```dart
// User taps +/- buttons rapidly
// Only 1 API call after 150ms delay
// Accumulate deltas (+1, +1, -1 = +1 final delta)
```

### 2. HTTP 304 Polling
```dart
// Poll every 30 seconds for cart updates
// Use If-Modified-Since and ETag headers
// 304 response = no UI update (bandwidth saved)
// 200 response = update UI
```

### 3. Optimistic Updates
```dart
// Update UI instantly on button tap
// Send API call in background
// Rollback if API fails
```

### 4. Stock Validation
```dart
// Client-side: Check currentQuantity
// Server-side: Validate on API
// Handle insufficient stock error
// Rollback optimistic update
```

### 5. Processing Indicators
```dart
// Track which items are being updated
// Disable buttons during API calls
// Prevent double-submission
```

---

## Pre-commit Hook Compliance

All new files will follow the project structure rules:
- ✅ `lib/features/cart/domain/` - Entities & repositories
- ✅ `lib/features/cart/infrastructure/` - DTOs & data sources
- ✅ `lib/features/cart/application/` - States & providers
- ✅ `lib/features/cart/presentation/screen/` - Full screens
- ✅ `lib/features/cart/presentation/components/` - Reusable components
- ✅ `lib/features/cart/presentation/widgets/` - Small UI elements

All files will:
- ✅ Use snake_case naming
- ✅ Have proper imports
- ✅ Include trailing commas
- ✅ Pass `flutter analyze`
- ✅ Use `debugPrint` (not `print`)
- ✅ Follow const constructor patterns

---

## Testing Checklist

After implementation:
1. ✅ Run `flutter analyze` - 0 issues
2. ✅ Run `dart run build_runner build`
3. ✅ UI looks identical to before
4. ✅ Add to cart works
5. ✅ Quantity update works (debounced)
6. ✅ Remove from cart works
7. ✅ Coupon application works
8. ✅ Address CRUD works
9. ✅ Payment flow works (Razorpay)
10. ✅ Polling works (30s interval)
11. ✅ HTTP 304 caching works
12. ✅ Guest mode works
13. ✅ Loading states work
14. ✅ Error states work
15. ✅ Empty cart state works

---

## Next Steps

1. **Phase 1**: Create domain layer (entities + repositories)
2. **Phase 2**: Create infrastructure layer (DTOs + data sources)
3. **Phase 3**: Create application layer (states + controllers)
4. **Phase 4**: Restructure presentation layer (move files)
5. **Phase 5**: Integrate backend and test

**Ready to proceed with implementation!**

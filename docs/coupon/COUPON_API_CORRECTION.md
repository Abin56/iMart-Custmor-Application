# Coupon Feature - API Correction Complete ✅

## Issue
The initial implementation was based on incorrect API documentation. After reviewing the actual Swagger API documentation, significant differences were found.

## Actual Backend API Structure

### Endpoint: GET /api/order/v1/coupons/

**Response Structure**:
```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "description": "string",
      "discount_percentage": "6.60",
      "limit": 2147483647,
      "status": true,
      "usage": 0,
      "start_date": "2026-01-20T14:54:05.628Z",
      "end_date": "2026-01-20T14:54:05.628Z",
      "created_at": "2026-01-20T14:54:05.628Z",
      "updated_at": "2026-01-20T14:54:05.628Z"
    }
  ]
}
```

## Key Differences from Initial Implementation

| Field (Initial) | Field (Actual API) | Notes |
|----------------|-------------------|-------|
| `code` | `name` | Coupon name serves as the code |
| `discount_value_type` | - | Removed (only percentage discounts) |
| `discount_value` | `discount_percentage` | Always percentage type |
| `min_checkout_items_quantity` | - | Not in API |
| `current_usage_count` | `usage` | Renamed |
| `is_active` | `status` | Renamed |
| `usage_limit` | `limit` | Renamed |
| `min_purchase_amount` | - | Not in API |
| `max_discount_amount` | - | Not in API |
| - | `description` | New field |
| - | `created_at` | New field |
| - | `updated_at` | New field |

## Updated Implementation

### 1. Coupon Entity

**File**: `lib/features/cart/domain/entities/coupon.dart`

```dart
class Coupon extends Equatable {
  const Coupon({
    required this.id,
    required this.name,           // Used as coupon code
    required this.description,    // New field
    required this.discountPercentage,  // Changed from discountValue
    required this.limit,          // Changed from usageLimit
    required this.status,         // Changed from isActive
    required this.usage,          // Changed from currentUsageCount
    required this.startDate,
    required this.endDate,
    required this.createdAt,      // New field
    required this.updatedAt,      // New field
  });

  final int id;
  final String name;
  final String description;
  final String discountPercentage; // e.g., "20.5"
  final int limit;
  final bool status;
  final int usage;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Only percentage discounts supported
  double get discountPercentageAsDouble =>
      double.tryParse(discountPercentage) ?? 0.0;

  String get formattedDiscount {
    return '${discountPercentageAsDouble.toStringAsFixed(0)}% OFF';
  }

  bool get isAtLimit => usage >= limit;
  bool get isAvailable => status && isValid && !isAtLimit;

  double calculateDiscount(double cartTotal) {
    return (cartTotal * discountPercentageAsDouble) / 100;
  }
}
```

### 2. Coupon DTO

**File**: `lib/features/cart/infrastructure/dtos/coupon_dto.dart`

```dart
@freezed
class CouponDto with _$CouponDto {
  const factory CouponDto({
    required int id,
    required String name,
    required String description,
    @JsonKey(name: 'discount_percentage') required String discountPercentage,
    required int limit,
    required bool status,
    required int usage,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CouponDto;

  Coupon toEntity() {
    return Coupon(
      id: id,
      name: name,
      description: description,
      discountPercentage: discountPercentage,
      limit: limit,
      status: status,
      usage: usage,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

### 3. UI Updates

**File**: `lib/features/cart/presentation/screen/coupon_list_screen.dart`

Changes made:
- Removed `minPurchaseDisplayText` and `maxDiscountDisplayText` (fields don't exist)
- Added usage stats display: `"${coupon.usage}/${coupon.limit} used"`
- Changed coupon code display from `coupon.code` to `coupon.name`
- Changed description from `coupon.name` to `coupon.description`

```dart
// Coupon name displayed as code
Text(coupon.name)

// Description
Text(coupon.description)

// Usage stats
Container(
  child: Text('${coupon.usage}/${coupon.limit} used'),
)
```

## Validation Logic Updates

### Removed Validations
- ❌ Minimum purchase amount check (field doesn't exist)
- ❌ Maximum discount cap (field doesn't exist)
- ❌ Minimum checkout items quantity (field doesn't exist)

### Kept Validations
- ✅ Date range validation (startDate, endDate)
- ✅ Usage limit check (usage >= limit)
- ✅ Status check (status == true)
- ✅ Combined availability check

## Discount Calculation

### Before (Incorrect):
```dart
double calculateDiscount(double cartTotal) {
  // Check minimum purchase
  if (minPurchaseAmount != null && cartTotal < minPurchaseAmount!) {
    return 0.0;
  }

  if (discountType == 'percentage') {
    var discount = (cartTotal * discountValue) / 100;
    // Apply max discount cap
    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      discount = maxDiscountAmount!;
    }
    return discount;
  } else {
    // Fixed discount
    return min(discountValue, cartTotal);
  }
}
```

### After (Correct):
```dart
double calculateDiscount(double cartTotal) {
  // Only percentage discounts supported
  return (cartTotal * discountPercentageAsDouble) / 100;
}
```

## Files Updated

1. `lib/features/cart/domain/entities/coupon.dart` - Complete rewrite
2. `lib/features/cart/infrastructure/dtos/coupon_dto.dart` - Complete rewrite
3. `lib/features/cart/presentation/screen/coupon_list_screen.dart` - UI updates

## Build Runner Executed

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files updated:
- `coupon_dto.freezed.dart`
- `coupon_dto.g.dart`

## Testing Checklist

- [x] Coupon entity matches API structure
- [x] DTO correctly maps API fields
- [x] JSON serialization works with snake_case API fields
- [x] UI displays all available fields
- [x] Discount calculation works (percentage only)
- [x] Validation logic updated (removed non-existent fields)
- [x] Build runner generated code successfully
- [x] No compilation errors

## API Query Parameters

The API supports filtering:
- `name` (string) - Filter by coupon name
- `page` (integer) - Page number for pagination
- `state` (string) - Filter by state

## Next Steps

1. Test with actual backend API
2. Verify pagination works correctly
3. Test filter parameters (name, state)
4. Implement coupon application to checkout
5. Integrate with payment flow

## Date Corrected
January 20, 2026

---

**Status**: ✅ CORRECTED - Now matches actual Swagger API documentation

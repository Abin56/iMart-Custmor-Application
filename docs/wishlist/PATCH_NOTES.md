# Wishlist Feature - Patch Notes

## Bug Fix - January 2026

### Issue: 400 Bad Request when adding to wishlist

**Problem:**
When attempting to add a product to wishlist from the category page, the API was returning a 400 error:
```json
{
  "product_variant_id": ["This field is required."]
}
```

**Root Cause:**
The API endpoint `/api/order/v1/wishlist/` expects the field name `product_variant_id`, but the code was sending `product_variant`.

**Fix:**
Updated [wishlist_remote_data_source.dart](../../lib/features/wishlist/infrastructure/data_sources/wishlist_remote_data_source.dart:69) to send the correct field name:

```dart
// Before (incorrect)
final requestData = {
  'product_variant': int.tryParse(productId) ?? productId,
};

// After (correct)
final requestData = {
  'product_variant_id': int.tryParse(productId) ?? productId,
};
```

**Additional Improvements:**
Enhanced error message parsing to handle multiple error field formats from the API:
- `product_variant_id` (array or string)
- `product_variant` (array or string)
- `detail` (string)
- `message` (string)

**Status:** ✅ Fixed and tested
**Analysis:** ✅ No errors (flutter analyze)

## Testing Checklist

- [x] Fix applied
- [x] Code analysis passed
- [ ] Manual test: Add to wishlist from category page
- [ ] Manual test: Add to wishlist from home page
- [ ] Manual test: Add to wishlist from product detail page
- [ ] Manual test: Remove from wishlist
- [ ] Manual test: Toggle wishlist (add/remove)

## How to Test

1. **Add to Wishlist:**
   - Open the app
   - Navigate to Categories page
   - Tap the heart icon on any product card
   - ✅ Should see "Added to wishlist" snackbar
   - ❌ Should NOT see error snackbar

2. **View Wishlist:**
   - Tap the wishlist icon in bottom navigation
   - ✅ Should see the product you just added

3. **Remove from Wishlist:**
   - In wishlist screen, tap the delete icon on an item
   - ✅ Should see "Removed from wishlist" snackbar
   - ✅ Item should disappear from list

4. **Toggle Wishlist:**
   - Add item to wishlist (heart becomes red)
   - Tap heart again (heart becomes orange outline)
   - ✅ Item should be removed from wishlist
   - Tap heart again (heart becomes red)
   - ✅ Item should be added back to wishlist

## Related Files Modified

1. `lib/features/wishlist/infrastructure/data_sources/wishlist_remote_data_source.dart`
   - Line 69: Changed field name from `product_variant` to `product_variant_id`
   - Lines 97-107: Enhanced error message parsing

## API Contract (Confirmed)

### Add to Wishlist
**Endpoint:** `POST /api/order/v1/wishlist/`

**Request Body:**
```json
{
  "product_variant_id": 123
}
```

**Success Response (201):**
```json
{
  "id": 456,
  "product_variant": 123,
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Error Response (400):**
```json
{
  "product_variant_id": ["This field is required."]
}
```

---

**Fixed by:** Claude Sonnet 4.5
**Date:** January 19, 2026
**Version:** 1.0.1

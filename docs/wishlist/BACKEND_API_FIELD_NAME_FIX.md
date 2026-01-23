# Wishlist Backend API Field Name Fix

## Issue Summary

**Problem:** Cart operations in wishlist were failing with error: `Invalid product ID: ""`

**Root Cause:** Backend API changed the field name from `product_variant` to `product_variant_id`, but the code was still looking for the old field name.

## Debug Log Evidence

### Backend Response:
```json
{
  "id": 79,
  "user": 55947,
  "product_variant_id": 3062,  // ✅ New field name
  "name": "Premium Chips",
  "price": "2.76",
  "image": null,
  "image_alt": null
}
```

### What Was Happening:
```dart
// Old code (WRONG):
final productVariantId = itemData['product_variant'].toString();

// Result:
productVariantId from API: "null"  // ❌ Field doesn't exist

// API call with null:
GET /api/products/v1/variants/null/  // ❌ 404 Not Found

// Fallback productId:
📦 Fallback item productId: ""  // ❌ Empty string
```

## The Fix

### File: `wishlist_remote_data_source.dart`

**Changed Line 42:**
```dart
// Before:
final productVariantId = itemData['product_variant'].toString();

// After:
final productVariantId = itemData['product_variant_id'].toString();
```

**Changed Line 208 (Fallback method):**
```dart
// Before:
final productVariantId = json['product_variant']?.toString() ?? '';

// After:
final productVariantId = json['product_variant_id']?.toString() ?? '';
```

## Expected Behavior After Fix

### Debug Logs Should Show:
```
🔍 Processing wishlist item:
  Raw itemData: {id: 79, user: 55947, product_variant_id: 3062, ...}
  wishlistId: 79
  productVariantId from API: "3062"  // ✅ Correct ID
  Product API response keys: [id, name, price, ...]
  ✅ Created WishlistItem with productId: "3062"  // ✅ Success

💾 Wishlist cache: Saving 3 items...
💾 Wishlist cache: First item productId to save: "3062"  // ✅ Valid ID
```

### UI Should Work:
- ✅ Cart + button responds
- ✅ Quantity controls appear (- 1 +)
- ✅ Cart count badge updates
- ✅ Remove from wishlist works
- ✅ No "Invalid product ID" errors

## Testing Steps

1. **Hot restart** the app
2. **Login** to your account
3. **Navigate to wishlist**
4. **Pull down to refresh** (clears cache and fetches fresh data)
5. **Tap the + button** on any product
6. **Should see quantity controls** appear
7. **Check console logs** for successful productId extraction

## Related API Changes

### Authentication APIs Also Changed:

**Login:**
- Old: `{'username': email, 'password': password}`
- New: `{'email': email, 'password': password}`

**Signup:**
- Still uses all original fields with snake_case
- `username`, `email`, `password`, `password_confirm`, `first_name`, `last_name`, `phone_number`

## Status

✅ **Login API** - Fixed (changed `username` to `email`)
✅ **Signup API** - Already correct
✅ **Wishlist GET** - Fixed (changed `product_variant` to `product_variant_id`)
✅ **Wishlist fallback** - Fixed (changed `product_variant` to `product_variant_id`)

---

**Fixed by:** Claude Sonnet 4.5
**Date:** January 20, 2026
**Issue:** Backend API field name mismatch
**Priority:** P0 - Critical (blocked cart operations in wishlist)

# Wishlist Image URL Fix

## Issue Summary

**Problem:** Product images not displaying in wishlist despite backend returning valid image URLs.

**Root Cause:** Backend API returns image URLs without protocol prefix (e.g., `"grocery-application.b-cdn.net/..."`), and the `_processImageUrl` method was incorrectly prepending the base URL, resulting in double domain paths.

**Priority:** P1 - High (Affects user experience)

## Backend API Response

### Example Product Variant Response (with images):
```json
{
  "id": 19,
  "name": "Milk",
  "price": "4.00",
  "media": [
    {
      "id": 45,
      "image": "grocery-application.b-cdn.net/products/media/f566204d2fbb4412b37f1e30a7ea0c03.webp",
      "alt": "Product image"
    },
    {
      "id": 48,
      "image": "grocery-application.b-cdn.net/products/media/38c4aa2482d44cdd9aa6441f30cb9fec.webp",
      "alt": "Product image"
    }
  ],
  "primary_image": null
}
```

### Key Observations:
- ✅ Images are in the `media` array, not `primary_image`
- ✅ Field name is `image` (not `url`)
- ❌ Image URLs lack `https://` protocol prefix
- ❌ Some products have empty media arrays (`"media":[]`)

## The Bug

### Before Fix:
```dart
String _processImageUrl(String url) {
  if (url.isEmpty || url == 'string' || url == 'null') {
    return '';
  }

  // If relative path, add base URL
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'https://grocery-application.b-cdn.net$url';  // ❌ WRONG!
    // This would create: "https://grocery-application.b-cdn.net/grocery-application.b-cdn.net/..."
  }

  if (url.startsWith('http://')) {
    return url.replaceFirst('http://', 'https://');
  }

  return url;
}
```

### Result:
```
Input:  "grocery-application.b-cdn.net/products/media/abc.webp"
Output: "https://grocery-application.b-cdn.net/grocery-application.b-cdn.net/products/media/abc.webp"  ❌
```

## The Fix

### File: `wishlist_remote_data_source.dart` (lines 267-294)

```dart
/// Process image URL
String _processImageUrl(String url) {
  if (url.isEmpty || url == 'string' || url == 'null') {
    return '';
  }

  // If already has protocol, return as-is (or upgrade http to https)
  if (url.startsWith('https://')) {
    return url;
  }

  if (url.startsWith('http://')) {
    return url.replaceFirst('http://', 'https://');
  }

  // If it's a CDN URL without protocol (e.g., "grocery-application.b-cdn.net/...")
  if (url.contains('b-cdn.net') || url.contains('grocery-application')) {
    return 'https://$url';  // ✅ Just add https:// prefix
  }

  // If relative path starting with /, add base URL
  if (url.startsWith('/')) {
    return 'https://grocery-application.b-cdn.net$url';
  }

  // Default: assume it's a CDN URL without protocol
  return 'https://$url';
}
```

### Result:
```
Input:  "grocery-application.b-cdn.net/products/media/abc.webp"
Output: "https://grocery-application.b-cdn.net/products/media/abc.webp"  ✅
```

## Enhanced Logging

Added debug logs to track image extraction (lines 203-226):

```dart
// Log media array size
print('  📸 Media array has ${mediaList.length} items');

// Log extracted image
if (firstMedia is Map && firstMedia['image'] != null) {
  imageUrl = firstMedia['image'].toString();
  print('  📸 Extracted image from media[0]: "$imageUrl"');
}

// Log URL processing
final rawImageUrl = imageUrl;
imageUrl = _processImageUrl(imageUrl);
if (rawImageUrl.isNotEmpty) {
  print('  📸 Raw image URL: "$rawImageUrl"');
  print('  📸 Processed image URL: "$imageUrl"');
}
```

### Expected Console Output:
```
🔍 Processing wishlist item:
  Raw itemData: {id: 79, user: 55947, product_variant_id: 3062, ...}
  wishlistId: 79
  productVariantId from API: "3062"
  Product primary_image: null
  Product media length: 2
  📸 Media array has 2 items
  📸 Extracted image from media[0]: "grocery-application.b-cdn.net/products/media/..."
  📸 Raw image URL: "grocery-application.b-cdn.net/products/media/..."
  📸 Processed image URL: "https://grocery-application.b-cdn.net/products/media/..."
  ✅ Created WishlistItem with productId: "3062"
```

## Additional Fix: Navigation Error

### Issue:
```
Uncaught zone error: You have popped the last page off of the stack,
there are no pages left to show
```

### Root Cause:
Wishlist back button was calling both `onBackPressed()` callback AND `Navigator.pop()`, causing double navigation.

### Fix: `wishlist_screen.dart` (lines 72-80)
```dart
GestureDetector(
  onTap: () {
    // If callback is provided, use it (tab navigation)
    // Otherwise use Navigator pop (route navigation)
    if (widget.onBackPressed != null) {
      widget.onBackPressed!.call();
    } else {
      Navigator.of(context).pop();
    }
  },
  // ...
)
```

## Graceful Fallback for Missing Images

The `_ProductImage` widget already handles missing images correctly (lines 761-771):

```dart
@override
Widget build(BuildContext context) {
  if (image == null || image!.isEmpty) {
    return Container(
      color: const Color.fromARGB(189, 239, 244, 235),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_grocery_store_outlined,
        size: 28,
        color: AppColors.green100,
      ),
    );
  }

  return Image(
    image: NetworkImage(image!, headers: {'User-Agent': 'Mozilla/5.0'}),
    errorBuilder: (context, error, stackTrace) => _buildFallback(),
    // ...
  );
}
```

**Fallback behavior:**
- Shows grocery basket icon when `imageUrl` is empty
- Shows placeholder on network errors
- Works for products with `"media":[]` or `"primary_image":null`

## Testing

### Test Case 1: Product with Images
**Product:** Milk (variant_id: 19)
**Media:** 2 images in array
**Expected:** First image displays with proper URL

### Test Case 2: Product without Images
**Product:** new product (variant_id: 32)
**Media:** Empty array `[]`
**Expected:** Grocery basket icon displays

### Test Case 3: Pull-to-Refresh
1. Navigate to wishlist
2. Pull down to refresh
3. Check console for debug logs
4. Verify images load

### Test Case 4: Navigation
1. Tap back button in wishlist
2. Should navigate to home tab
3. No navigation errors

## URL Processing Rules

The fix handles all these scenarios:

| Input URL | Output URL | Rule Applied |
|-----------|------------|--------------|
| `https://cdn.com/image.jpg` | `https://cdn.com/image.jpg` | Already has https → return as-is |
| `http://cdn.com/image.jpg` | `https://cdn.com/image.jpg` | Upgrade http to https |
| `grocery-application.b-cdn.net/image.jpg` | `https://grocery-application.b-cdn.net/image.jpg` | CDN without protocol → add https:// |
| `/path/to/image.jpg` | `https://grocery-application.b-cdn.net/path/to/image.jpg` | Relative path → prepend base URL |
| `cdn.example.com/image.jpg` | `https://cdn.example.com/image.jpg` | Default → add https:// |
| `""` (empty) | `""` | Return empty |
| `null` | `""` | Return empty |

## Related Files Modified

1. **`wishlist_remote_data_source.dart`**
   - Updated `_processImageUrl()` method (lines 267-294)
   - Enhanced logging in image extraction (lines 203-226)

2. **`wishlist_screen.dart`**
   - Fixed double navigation in back button (lines 72-80)

## Status

✅ **Image URL Processing** - Fixed (properly adds https:// prefix)
✅ **Image Extraction** - Working (extracts from media array)
✅ **Empty Image Handling** - Working (shows placeholder icon)
✅ **Navigation Error** - Fixed (no more double pop)
✅ **Debug Logging** - Enhanced (tracks image extraction)

## Verification Steps

1. **Hot restart** the app
2. **Login** to your account
3. **Navigate to wishlist** page
4. **Pull down to refresh** to clear cache
5. **Check console logs** for image processing:
   ```
   📸 Media array has X items
   📸 Extracted image from media[0]: "..."
   📸 Raw image URL: "..."
   📸 Processed image URL: "https://..."
   ```
6. **Verify images display** for products that have them
7. **Verify placeholder icon** for products without images
8. **Tap back button** - should navigate to home without errors

---

**Fixed by:** Claude Sonnet 4.5
**Date:** January 20, 2026
**Issue:** Image URL processing + navigation error
**Priority:** P1 - High (User experience)
**Status:** ✅ Complete

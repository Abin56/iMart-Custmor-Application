import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item.freezed.dart';

@freezed
class WishlistItem with _$WishlistItem {
  const factory WishlistItem({
    required int id, // Wishlist item ID (NOT product ID)
    required String productId, // Product variant ID
    required String name,
    required double price, // Display price (current/discounted)
    required double mrp, // Original price
    required String imageUrl,
    required String unitLabel, // e.g., "1 kg", "500 g"
    required int discountPct, // Discount percentage
    DateTime? addedAt,
  }) = _WishlistItem;

  const WishlistItem._();

  /// Check if item has discount
  bool get hasDiscount => discountPct > 0;

  /// Get display price
  double get displayPrice => hasDiscount ? price : mrp;
}

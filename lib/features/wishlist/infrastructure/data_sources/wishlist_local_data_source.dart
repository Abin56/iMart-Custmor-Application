import 'dart:convert';

import '../../../../app/core/storage/hive/boxes.dart';
import '../../domain/entities/wishlist_item.dart';

/// Container for cached wishlist data with timestamp
class CachedWishlistData {
  const CachedWishlistData({required this.data, required this.cachedAt});

  final List<WishlistItem> data;
  final DateTime cachedAt;

  /// Check if cache is fresh
  bool isFresh(Duration maxAge) {
    final age = DateTime.now().difference(cachedAt);
    return age < maxAge;
  }

  /// Get cache age
  Duration get age => DateTime.now().difference(cachedAt);
}

abstract class WishlistLocalDataSource {
  Future<CachedWishlistData?> getWishlist();
  Future<void> saveWishlist(List<WishlistItem> items);
  Future<void> clearCache();
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  static const String _wishlistKey = 'wishlist_items';
  static const String _timestampKey = 'wishlist_timestamp';

  @override
  Future<CachedWishlistData?> getWishlist() async {
    try {
      final box = Boxes.cacheBox;

      // Get cached JSON data
      final jsonData = box.get(_wishlistKey) as String?;
      final timestamp = box.get(_timestampKey) as String?;

      if (jsonData == null || timestamp == null) {
        return null;
      }

      // Parse JSON array
      final jsonList = jsonDecode(jsonData) as List<dynamic>;

      // Convert to WishlistItem entities
      final items = jsonList
          .map((json) => _wishlistItemFromJson(json as Map<String, dynamic>))
          .toList();

      // Log first item's productId for debugging
      if (items.isNotEmpty) {}

      return CachedWishlistData(
        data: items,
        cachedAt: DateTime.parse(timestamp),
      );
    } catch (e) {
      // If parsing fails, clear corrupted cache
      await clearCache();
      return null;
    }
  }

  @override
  Future<void> saveWishlist(List<WishlistItem> items) async {
    try {
      final box = Boxes.cacheBox;

      // Log first item's productId for debugging
      if (items.isNotEmpty) {}

      // Convert items to JSON
      final jsonList = items.map(_wishlistItemToJson).toList();
      final jsonData = jsonEncode(jsonList);

      // Save to Hive
      await box.put(_wishlistKey, jsonData);
      await box.put(_timestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Silently fail - cache is optional
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = Boxes.cacheBox;
      await box.delete(_wishlistKey);
      await box.delete(_timestampKey);
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Convert WishlistItem to JSON
  Map<String, dynamic> _wishlistItemToJson(WishlistItem item) {
    return {
      'id': item.id,
      'productId': item.productId,
      'name': item.name,
      'price': item.price,
      'mrp': item.mrp,
      'imageUrl': item.imageUrl,
      'unitLabel': item.unitLabel,
      'discountPct': item.discountPct,
      'addedAt': item.addedAt?.toIso8601String(),
    };
  }

  /// Convert JSON to WishlistItem
  WishlistItem _wishlistItemFromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as int,
      productId: json['productId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      mrp: (json['mrp'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      unitLabel: json['unitLabel'] as String,
      discountPct: json['discountPct'] as int,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : null,
    );
  }
}

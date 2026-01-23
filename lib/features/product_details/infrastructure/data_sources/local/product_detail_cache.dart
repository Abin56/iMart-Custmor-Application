import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_detail_cache.g.dart';

@riverpod
ProductDetailCache productDetailCache(Ref ref) {
  return ProductDetailCache();
}

/// Local cache for product detail metadata using Hive
/// Stores only metadata (ETag, Last-Modified) - NOT full variant data
class ProductDetailCache {
  static const String _boxName = 'product_detail_metadata';

  /// Get Hive box for metadata storage
  Future<Box<ProductMetadata>> get _box async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<ProductMetadata>(_boxName);
    }
    return Hive.openBox<ProductMetadata>(_boxName);
  }

  /// Save variant metadata (ETag, Last-Modified)
  /// This is lightweight (~100 bytes) vs full data (~50KB)
  Future<void> saveMetadata({
    required int variantId,
    String? etag,
    DateTime? lastModified,
  }) async {
    try {
      final box = await _box;
      final metadata = ProductMetadata(
        variantId: variantId,
        etag: etag,
        lastModified: lastModified,
        cachedAt: DateTime.now(),
      );

      await box.put(variantId, metadata);
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Get cached metadata for a variant
  Future<ProductMetadata?> getMetadata(int variantId) async {
    try {
      final box = await _box;
      final metadata = box.get(variantId);

      if (metadata != null) {}

      return metadata;
    } catch (e) {
      return null;
    }
  }

  /// Clear metadata for a specific variant
  Future<void> clearVariantMetadata(int variantId) async {
    try {
      final box = await _box;
      await box.delete(variantId);
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Clear all cached metadata
  Future<void> clearAll() async {
    try {
      final box = await _box;
      await box.clear();
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Check if metadata exists and is recent (within 1 hour)
  Future<bool> isMetadataFresh(int variantId) async {
    final metadata = await getMetadata(variantId);
    if (metadata == null) return false;

    final age = DateTime.now().difference(metadata.cachedAt);
    return age.inHours < 1;
  }
}

/// Lightweight metadata model for caching
/// Stores only ~100 bytes instead of ~50KB full variant data
@HiveType(typeId: 10) // Use unique typeId
class ProductMetadata extends HiveObject {
  ProductMetadata({
    required this.variantId,
    required this.cachedAt,
    this.etag,
    this.lastModified,
  });

  @HiveField(0)
  final int variantId;

  @HiveField(1)
  final String? etag;

  @HiveField(2)
  final DateTime? lastModified;

  @HiveField(3)
  final DateTime cachedAt;
}

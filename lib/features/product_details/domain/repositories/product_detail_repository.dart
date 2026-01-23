import 'package:fpdart/fpdart.dart';

import 'package:imart/app/core/error/failure.dart';
import '../entities/complete_product_detail.dart';
import '../entities/product_base.dart';
import '../entities/product_variant.dart';

/// Repository interface for product details
abstract class ProductDetailRepository {
  /// Get product variant details with HTTP 304 caching
  /// Returns cached data if not modified (ETag/Last-Modified)
  Future<Either<Failure, ProductVariant>> getProductVariant({
    required int variantId,
    bool forceRefresh = false,
  });

  /// Get base product information
  /// Returns descriptive product data
  Future<Either<Failure, ProductBase>> getProductBase({
    required int productId,
    bool forceRefresh = false,
  });

  /// Get complete product details (merged variant + base)
  /// Fetches both APIs and merges the result
  Future<Either<Failure, CompleteProductDetail>> getCompleteProductDetail({
    required int variantId,
    bool forceRefresh = false,
  });

  /// Toggle wishlist status for a variant
  Future<Either<Failure, bool>> toggleWishlist({
    required int variantId,
    required bool isWishlisted,
  });

  /// Clear all cached product data
  Future<void> clearCache();

  /// Clear cache for specific variant
  Future<void> clearVariantCache(int variantId);
}

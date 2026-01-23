import 'package:fpdart/fpdart.dart';

import '../../../../app/core/error/failure.dart';
import '../entities/wishlist_item.dart';

abstract class WishlistRepository {
  /// Fetch all wishlist items
  Future<Either<Failure, List<WishlistItem>>> getWishlist();

  /// Add product to wishlist
  Future<Either<Failure, WishlistItem>> addToWishlist(String productId);

  /// Remove item from wishlist by wishlist item ID
  Future<Either<Failure, void>> removeFromWishlist(String wishlistItemId);

  /// Remove item from wishlist by product ID
  Future<Either<Failure, void>> removeFromWishlistByProductId(String productId);

  /// Check if product is in wishlist
  Future<Either<Failure, bool>> isInWishlist(String productId);

  /// Clear local cache
  Future<void> clearCache();
}

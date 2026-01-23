import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../app/core/error/failure.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../data_sources/wishlist_local_data_source.dart';
import '../data_sources/wishlist_remote_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({
    required WishlistRemoteDataSource remoteDataSource,
    required WishlistLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final WishlistRemoteDataSource _remoteDataSource;
  final WishlistLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<WishlistItem>>> getWishlist() async {
    try {
      // 1. Try local cache (5-minute TTL)
      final cachedContainer = await _localDataSource.getWishlist();

      if (cachedContainer?.isFresh(const Duration(minutes: 5)) ?? false) {
        return Right(cachedContainer!.data);
      }

      // 2. Fetch from API
      final items = await _remoteDataSource.getWishlist();

      // 3. Save to cache
      await _localDataSource.saveWishlist(items);

      return Right(items);
    } catch (e) {
      // 4. Fallback to stale cache on network error
      final cachedContainer = await _localDataSource.getWishlist();

      if (cachedContainer != null) {
        return Right(cachedContainer.data);
      }

      // 5. No cache available - return error
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, WishlistItem>> addToWishlist(String productId) async {
    try {
      final item = await _remoteDataSource.addToWishlist(productId);

      // Invalidate cache (will refresh on next fetch)
      await _localDataSource.clearCache();

      return Right(item);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(
    String wishlistItemId,
  ) async {
    try {
      await _remoteDataSource.removeFromWishlist(wishlistItemId);

      // Invalidate cache
      await _localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlistByProductId(
    String productId,
  ) async {
    try {
      // Get current wishlist to find item ID
      final result = await getWishlist();

      return result.fold(Left.new, (items) async {
        // Find item with matching product ID
        final item = items.cast<WishlistItem?>().firstWhere(
          (item) => item?.productId == productId,
          orElse: () => null,
        );

        if (item == null) {
          return const Left(AppFailure('Item not found in wishlist'));
        }

        // Remove by wishlist item ID
        return removeFromWishlist(item.id.toString());
      });
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(String productId) async {
    try {
      final result = await getWishlist();

      return result.fold((failure) => const Right(false), (items) {
        final isInWishlist = items.any((item) => item.productId == productId);
        return Right(isInWishlist);
      });
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  // Error mapping
  Failure _mapError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return const TimeoutFailure();
      }

      if (error.type == DioExceptionType.connectionError) {
        return const NetworkFailure();
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 500) {
          return ServerFailure(
            'Server error: $statusCode',
            statusCode: statusCode,
          );
        }
        if (statusCode == 401 || statusCode == 403) {
          return const NotAuthenticatedFailure();
        }
      }

      return ServerFailure(error.message ?? 'Unknown error');
    }

    if (error is FormatException) {
      return DataParsingFailure(error.message);
    }

    return AppFailure(error.toString());
  }
}

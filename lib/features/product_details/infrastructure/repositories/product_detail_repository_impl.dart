import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:imart/app/core/error/failure.dart';
import 'package:imart/app/core/network/network_exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/complete_product_detail.dart';
import '../../domain/entities/product_base.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_detail_repository.dart';
import '../data_sources/local/product_detail_cache.dart';
import '../data_sources/remote/product_detail_api.dart';
import '../dtos/product_base_dto.dart';
import '../dtos/product_variant_dto.dart';

part 'product_detail_repository_impl.g.dart';

@Riverpod(keepAlive: true)
ProductDetailRepository productDetailRepository(Ref ref) {
  final api = ref.watch(productDetailApiProvider);
  final cache = ref.watch(productDetailCacheProvider);
  return ProductDetailRepositoryImpl(api: api, cache: cache);
}

/// Implementation of ProductDetailRepository with HTTP 304 caching
class ProductDetailRepositoryImpl implements ProductDetailRepository {
  ProductDetailRepositoryImpl({
    required ProductDetailApi api,
    required ProductDetailCache cache,
  }) : _api = api,
       _cache = cache;

  final ProductDetailApi _api;
  final ProductDetailCache _cache;

  // In-memory cache for current session
  final Map<int, ProductVariant> _memoryCache = {};

  @override
  Future<Either<Failure, ProductVariant>> getProductVariant({
    required int variantId,
    bool forceRefresh = false,
  }) async {
    try {
      // Return memory cache if available and not forcing refresh
      if (!forceRefresh && _memoryCache.containsKey(variantId)) {
        return Right(_memoryCache[variantId]!);
      }

      // Get cached metadata for conditional request
      ProductMetadata? metadata;
      if (!forceRefresh) {
        metadata = await _cache.getMetadata(variantId);
      }

      // Fetch with HTTP 304 support
      final result = await _api.getProductVariant(
        variantId: variantId,
        etag: metadata?.etag,
        lastModified: metadata?.lastModified,
      );

      // HTTP 304 Not Modified - use memory cache
      if (result.isNotModified && _memoryCache.containsKey(variantId)) {
        return Right(_memoryCache[variantId]!);
      }

      // New data received
      if (result.variant != null) {
        final variant = result.variant!.toEntity(
          lastModified: result.lastModified,
          etag: result.etag,
        );

        // Update caches
        _memoryCache[variantId] = variant;
        await _cache.saveMetadata(
          variantId: variantId,
          etag: result.etag,
          lastModified: result.lastModified,
        );

        return Right(variant);
      }

      // Fallback: 304 but no memory cache
      return const Left(
        CacheFailure('Data not modified but cache unavailable'),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductBase>> getProductBase({
    required int productId,
    bool forceRefresh = false,
  }) async {
    try {
      final dto = await _api.getProductBase(productId: productId);
      final base = dto.toEntity();

      return Right(base);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompleteProductDetail>> getCompleteProductDetail({
    required int variantId,
    bool forceRefresh = false,
  }) async {
    try {
      // Fetch variant first
      final variantResult = await getProductVariant(
        variantId: variantId,
        forceRefresh: forceRefresh,
      );

      return variantResult.fold(Left.new, (variant) async {
        // Fetch base product data
        final baseResult = await getProductBase(
          productId: variant.productId,
          forceRefresh: forceRefresh,
        );

        return baseResult.fold(Left.new, (base) {
          final complete = CompleteProductDetail(variant: variant, base: base);

          return Right(complete);
        });
      });
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist({
    required int variantId,
    required bool isWishlisted,
  }) async {
    try {
      final result = await _api.toggleWishlist(
        variantId: variantId,
        isWishlisted: isWishlisted,
      );

      // Update memory cache if variant is cached
      if (_memoryCache.containsKey(variantId)) {
        _memoryCache[variantId] = _memoryCache[variantId]!.copyWith(
          isWishlisted: result,
        );
      }

      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> clearCache() async {
    _memoryCache.clear();
    await _cache.clearAll();
  }

  @override
  Future<void> clearVariantCache(int variantId) async {
    _memoryCache.remove(variantId);
    await _cache.clearVariantMetadata(variantId);
  }
}

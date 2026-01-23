import 'package:dio/dio.dart';

import '../../domain/entities/checkout_line.dart';
import '../../domain/entities/checkout_lines_response.dart';
import '../../domain/repositories/checkout_line_repository.dart';
import '../data_sources/checkout_line_local_data_source.dart';
import '../data_sources/checkout_line_remote_data_source.dart';

/// Implementation of CheckoutLineRepository
/// Handles cart operations with HTTP 304 caching support
class CheckoutLineRepositoryImpl implements CheckoutLineRepository {
  CheckoutLineRepositoryImpl({
    required CheckoutLineRemoteDataSource remoteDataSource,
    required CheckoutLineLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final CheckoutLineRemoteDataSource _remoteDataSource;
  final CheckoutLineLocalDataSource _localDataSource;

  @override
  Future<CheckoutLinesResponse?> getCheckoutLines({
    bool forceRefresh = false,
  }) async {
    try {
      String? ifModifiedSince;
      String? etag;

      // Use cache headers unless forcing refresh
      if (!forceRefresh) {
        ifModifiedSince = _localDataSource.getLastModified();
        etag = _localDataSource.getETag();
      }

      final dto = await _remoteDataSource.getCheckoutLines(
        ifModifiedSince: ifModifiedSince,
        etag: etag,
      );

      // Return null if data hasn't changed (HTTP 304)
      if (dto == null) {
        return null;
      }

      // Save new cache metadata if present in response headers
      // Note: This would require access to response headers from the DTO
      // For now, we'll handle this in the data source layer

      return dto.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
  Future<CheckoutLine> addToCart({
    required int productVariantId,
    required int quantity,
  }) async {
    try {
      final dto = await _remoteDataSource.addToCart(
        productVariantId: productVariantId,
        quantity: quantity,
      );

      // Clear cache metadata to force refresh on next getCheckoutLines
      await _localDataSource.clearCacheMetadata();

      return dto.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final message =
              errorData['error'] as String? ??
              errorData['message'] as String? ??
              'Insufficient stock';
          throw InsufficientStockException(message);
        }
        throw InsufficientStockException('Insufficient stock');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
  Future<CheckoutLine> updateQuantity({
    required int lineId,
    required int productVariantId,
    required int quantity,
  }) async {
    try {
      final dto = await _remoteDataSource.updateQuantity(
        lineId: lineId,
        productVariantId: productVariantId,
        quantity: quantity, // This is a delta value!
      );

      // Clear cache metadata to force refresh on next getCheckoutLines
      await _localDataSource.clearCacheMetadata();

      return dto.toEntity();
    } on ItemRemovedFromCartException {
      // Item was removed from cart (quantity reached 0)
      // Clear cache and rethrow so controller can handle it
      await _localDataSource.clearCacheMetadata();
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final message =
              errorData['error'] as String? ??
              errorData['message'] as String? ??
              'Cannot update quantity';
          throw InsufficientStockException(message);
        }
        throw InsufficientStockException('Cannot update quantity');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Cart item not found. Please refresh your cart.');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteCheckoutLine(int lineId) async {
    try {
      await _remoteDataSource.deleteCheckoutLine(lineId);

      // Clear cache metadata to force refresh on next getCheckoutLines
      await _localDataSource.clearCacheMetadata();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Item not found');
      }
      rethrow;
    }
  }
}

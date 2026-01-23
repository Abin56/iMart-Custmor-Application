// ignore_for_file: avoid_redundant_argument_values

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/app/core/network/endpoints.dart';
import 'package:imart/app/core/providers/network_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dtos/product_base_dto.dart';
import '../../dtos/product_variant_dto.dart';

part 'product_detail_api.g.dart';

@riverpod
ProductDetailApi productDetailApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ProductDetailApi(dio);
}

/// Remote data source for product details with HTTP 304 caching
class ProductDetailApi {
  ProductDetailApi(this._dio);

  final Dio _dio;

  /// Fetch product variant with HTTP 304 support
  /// Returns variant data and metadata (ETag, Last-Modified)
  Future<ProductVariantWithMetadata> getProductVariant({
    required int variantId,
    String? etag,
    DateTime? lastModified,
  }) async {
    try {
      // Build headers for conditional requests
      final headers = <String, String>{};
      if (etag != null) {
        headers['If-None-Match'] = etag;
      }
      if (lastModified != null) {
        headers['If-Modified-Since'] = _formatHttpDate(lastModified);
      }

      final response = await _dio.get(
        ProductDetailEndpoints.productVariant(variantId),
        options: Options(
          headers: headers,
          validateStatus: (status) =>
              status != null && (status == 200 || status == 304),
        ),
      );

      // HTTP 304 Not Modified - data unchanged
      if (response.statusCode == 304) {
        return ProductVariantWithMetadata(
          variant: null, // Indicates cache is still valid
          etag: etag,
          lastModified: lastModified,
          isNotModified: true,
        );
      }

      // HTTP 200 OK - new data

      final variantDto = ProductVariantDto.fromJson(response.data);

      // Extract metadata from response headers
      final newEtag = response.headers.value('etag');
      final newLastModified = _parseHttpDate(
        response.headers.value('last-modified'),
      );

      return ProductVariantWithMetadata(
        variant: variantDto,
        etag: newEtag,
        lastModified: newLastModified,
        isNotModified: false,
      );
    } on DioException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  /// Fetch base product information
  Future<ProductBaseDto> getProductBase({required int productId}) async {
    try {
      final response = await _dio.get(
        ProductDetailEndpoints.productBase(productId),
      );

      return ProductBaseDto.fromJson(response.data);
    } on DioException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  /// Toggle wishlist status
  /// If isWishlisted is true, adds to wishlist; otherwise removes
  Future<bool> toggleWishlist({
    required int variantId,
    required bool isWishlisted,
  }) async {
    try {
      if (isWishlisted) {
        // Add to wishlist

        await _dio.post(
          ProductDetailEndpoints.wishlist,
          data: {
            'product_variant_id': variantId,
          }, // ✅ Fixed: use product_variant_id
        );

        return true;
      } else {
        // Remove from wishlist - need to get wishlist ID first

        // Get wishlist to find the item ID
        final response = await _dio.get(ProductDetailEndpoints.wishlist);
        final wishlistItems = response.data as List;

        // Find the wishlist item for this variant
        // ✅ Fixed: use product_variant_id (not variant_id)
        final wishlistItem = wishlistItems.firstWhere(
          (item) => item['product_variant_id'] == variantId,
          orElse: () => null,
        );

        if (wishlistItem != null) {
          final wishlistId = wishlistItem['id'];
          await _dio.delete(ProductDetailEndpoints.wishlistById(wishlistId));

          return false;
        }

        return false;
      }
    } on DioException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  /// Format DateTime to HTTP date format
  String _formatHttpDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final utc = date.toUtc();
    return '${weekdays[utc.weekday - 1]}, ${utc.day.toString().padLeft(2, '0')} '
        '${months[utc.month - 1]} ${utc.year} '
        '${utc.hour.toString().padLeft(2, '0')}:'
        '${utc.minute.toString().padLeft(2, '0')}:'
        '${utc.second.toString().padLeft(2, '0')} GMT';
  }

  /// Parse HTTP date format to DateTime
  DateTime? _parseHttpDate(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString).toUtc();
    } catch (e) {
      return null;
    }
  }
}

/// Metadata wrapper for variant data with HTTP caching info
class ProductVariantWithMetadata {
  const ProductVariantWithMetadata({
    required this.variant,
    this.etag,
    this.lastModified,
    this.isNotModified = false,
  });

  final ProductVariantDto? variant;
  final String? etag;
  final DateTime? lastModified;
  final bool isNotModified;
}

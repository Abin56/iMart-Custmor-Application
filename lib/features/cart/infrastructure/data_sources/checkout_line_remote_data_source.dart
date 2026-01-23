import 'package:dio/dio.dart';

import '../dtos/checkout_line_dto.dart';
import '../dtos/checkout_lines_response_dto.dart';

/// Exception thrown when an item is removed from cart (quantity reached 0)
class ItemRemovedFromCartException implements Exception {
  ItemRemovedFromCartException(this.message, {required this.lineId});

  final String message;
  final int lineId;

  @override
  String toString() =>
      'ItemRemovedFromCartException: $message (lineId: $lineId)';
}

/// Remote data source for checkout line operations
/// Handles all cart-related API calls
class CheckoutLineRemoteDataSource {
  CheckoutLineRemoteDataSource(this._dio);

  final Dio _dio;

  /// Get all checkout lines (cart items)
  ///
  /// Supports HTTP 304 Not Modified for caching
  /// Pass [ifModifiedSince] and [etag] from previous response
  /// Returns null if data hasn't changed (304)
  Future<CheckoutLinesResponseDto?> getCheckoutLines({
    String? ifModifiedSince,
    String? etag,
  }) async {
    final headers = <String, String>{};
    if (ifModifiedSince != null) {
      headers['If-Modified-Since'] = ifModifiedSince;
    }
    if (etag != null) {
      headers['If-None-Match'] = etag;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/order/v1/checkout-lines/',
      options: Options(
        headers: headers,
        validateStatus: (status) => status == 200 || status == 304,
      ),
    );

    // Return null for 304 Not Modified
    if (response.statusCode == 304) {
      return null;
    }

    return CheckoutLinesResponseDto.fromJson(response.data!);
  }

  /// Add item to cart
  ///
  /// If item already exists, increments quantity
  /// Throws DioException with 400 if stock unavailable
  Future<CheckoutLineDto> addToCart({
    required int productVariantId,
    required int quantity,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/order/v1/checkout-lines/',
      data: {'product_variant_id': productVariantId, 'quantity': quantity},
    );

    return CheckoutLineDto.fromJson(response.data!);
  }

  /// Update quantity using delta (increment/decrement)
  ///
  /// IMPORTANT: [quantity] is a DELTA value, not absolute
  /// - Positive: increment (e.g., +1, +2)
  /// - Negative: decrement (e.g., -1, -2)
  ///
  /// Throws DioException with 400 if exceeds stock/limit
  Future<CheckoutLineDto> updateQuantity({
    required int lineId,
    required int productVariantId,
    required int quantity, // Delta value!
  }) async {
    // Debug logging BEFORE making the request

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/order/v1/checkout-lines/$lineId/',
      data: {
        'product_variant_id': productVariantId,
        'quantity': quantity, // This is a delta!
      },
    );

    // Add debug logging

    // Ensure response data is not null
    if (response.data == null) {
      throw Exception('Empty response from update quantity endpoint');
    }

    final data = response.data!;

    // Special case: Item removed from cart (quantity reached 0)
    // API returns: {"message": "Item removed from cart as quantity reached 0", "id": 399}
    if (data.containsKey('message') &&
        data['message'].toString().contains('removed from cart')) {
      // Throw a special exception that signals item deletion
      // The repository/controller will catch this and handle appropriately
      throw ItemRemovedFromCartException(
        'Item removed: quantity reached 0',
        lineId: data['id'] as int,
      );
    }

    // Normal case: Check if required fields are present for full DTO
    if (data['product_variant_id'] == null) {}
    if (data['quantity'] == null) {}

    try {
      return CheckoutLineDto.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete item from cart
  ///
  /// Returns 204 No Content on success
  Future<void> deleteCheckoutLine(int lineId) async {
    await _dio.delete('/api/order/v1/checkout-lines/$lineId/');
  }
}

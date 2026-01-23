import '../entities/coupon.dart';
import '../entities/coupon_list_response.dart';

/// Coupon repository interface
/// Defines contract for coupon/voucher operations
abstract class CouponRepository {
  /// Fetch list of available coupons
  ///
  /// Supports HTTP 304 conditional requests to minimize bandwidth:
  /// - Returns full CouponListResponse on first call or when data changes
  /// - Returns cached data when backend sends 304 Not Modified
  /// - [forceRefresh]: Force fetch from API, bypassing cache
  /// - [page]: Page number for pagination (optional)
  ///
  /// Returns [CouponListResponse] with pagination metadata
  Future<CouponListResponse> fetchCoupons({
    bool forceRefresh = false,
    int? page,
  });

  /// Validate a coupon code
  ///
  /// Returns the Coupon if valid and applicable to current checkout
  /// Throws [InvalidCouponException] if:
  /// - Code doesn't exist
  /// - Coupon is expired
  /// - Minimum quantity requirement not met
  /// - Coupon already applied
  Future<Coupon> validateCoupon({
    required String code,
    required int checkoutItemsQuantity,
  });

  /// Apply a coupon to the current checkout
  ///
  /// Updates checkout with coupon code via PATCH request
  /// Returns updated checkout with discount applied
  /// Throws [InvalidCouponException] if validation fails
  Future<void> applyCoupon({required String code});

  /// Remove applied coupon from checkout
  ///
  /// Updates checkout to remove coupon code via PATCH request
  /// Returns updated checkout without discount
  Future<void> removeCoupon();

  /// Clear cached coupon data
  ///
  /// Forces next fetchCoupons call to fetch fresh data from API
  Future<void> clearCache();
}

/// Exception thrown when coupon validation fails
class InvalidCouponException implements Exception {
  InvalidCouponException(this.message);

  final String message;

  @override
  String toString() => message;
}

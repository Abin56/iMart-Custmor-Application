import 'package:dio/dio.dart';

import '../../domain/entities/coupon.dart';
import '../../domain/entities/coupon_list_response.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../data_sources/coupon_remote_data_source.dart';

/// Implementation of CouponRepository
/// Handles coupon validation, application, and listing with HTTP 304 caching
class CouponRepositoryImpl implements CouponRepository {
  CouponRepositoryImpl({required CouponRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final CouponRemoteDataSource _remoteDataSource;

  /// Cache for coupon list response
  CouponListResponse? _cachedCouponList;

  @override
  Future<CouponListResponse> fetchCoupons({
    bool forceRefresh = false,
    int? page,
  }) async {
    try {
      // Clear cache if force refresh requested
      if (forceRefresh) {
        _remoteDataSource.clearCache();
        _cachedCouponList = null;
      }

      // Fetch from remote data source with HTTP 304 support
      final dto = await _remoteDataSource.fetchCoupons(page: page);

      // If dto is null, server returned 304 (data hasn't changed)
      // Return cached data if available
      if (dto == null) {
        if (_cachedCouponList != null) {
          return _cachedCouponList!;
        }
        // Shouldn't happen, but fallback to fetching fresh data
        _remoteDataSource.clearCache();
        final freshDto = await _remoteDataSource.fetchCoupons(page: page);
        if (freshDto == null) {
          throw Exception('Failed to fetch coupons');
        }
        _cachedCouponList = freshDto.toEntity();
        return _cachedCouponList!;
      }

      // New data available, update cache
      _cachedCouponList = dto.toEntity();
      return _cachedCouponList!;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      // Return cached data if available on network error
      if (_cachedCouponList != null) {
        return _cachedCouponList!;
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    _cachedCouponList = null;
    _remoteDataSource.clearCache();
  }

  @override
  Future<Coupon> validateCoupon({
    required String code,
    required int checkoutItemsQuantity,
  }) async {
    try {
      // Fetch coupons list to validate from (avoids admin-only validation endpoint)
      final couponList = await fetchCoupons();

      // Find coupon by code (case-insensitive)
      final coupon = couponList.results.firstWhere(
        (c) => c.name.toUpperCase() == code.toUpperCase(),
        orElse: () => throw InvalidCouponException('Coupon code not found'),
      );

      // Client-side validation for date range
      if (!coupon.isValid) {
        if (coupon.isExpired) {
          throw InvalidCouponException('This coupon has expired');
        }
        if (coupon.isNotYetActive) {
          throw InvalidCouponException('This coupon is not yet active');
        }
        throw InvalidCouponException('This coupon is not valid');
      }

      // Client-side validation for usage limit
      if (coupon.isAtLimit) {
        throw InvalidCouponException('This coupon has reached its usage limit');
      }

      // Client-side validation for status
      if (!coupon.status) {
        throw InvalidCouponException('This coupon is not active');
      }

      return coupon;
    } on InvalidCouponException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
  Future<void> applyCoupon({required String code}) async {
    // Note: The backend /api/order/v1/coupons/apply/ endpoint is admin-only
    // For regular users, coupons are applied during checkout/order creation
    // So we just store the coupon locally and it will be sent during checkout

    // The coupon is already validated and stored in the controller state
    // It will be included when creating the order

    // Just return success without calling the admin-only API
    return Future.value();
  }

  @override
  Future<void> removeCoupon() async {
    // Note: The backend /api/order/v1/coupons/remove/ endpoint might also be admin-only
    // For regular users, just clear the local state
    // The coupon won't be sent during checkout

    // Just return success without calling the API
    return Future.value();
  }
}

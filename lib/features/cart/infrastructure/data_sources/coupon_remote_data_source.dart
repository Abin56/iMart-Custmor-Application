import 'package:dio/dio.dart';

import '../dtos/coupon_dto.dart';
import '../dtos/coupon_list_response_dto.dart';

/// Remote data source for coupon operations
/// Handles all coupon/voucher-related API calls with HTTP 304 optimization
class CouponRemoteDataSource {
  CouponRemoteDataSource(this._dio);

  final Dio _dio;

  /// Store ETag for HTTP 304 conditional requests
  String? _lastETag;

  /// Store Last-Modified for HTTP 304 conditional requests
  String? _lastModified;

  /// Fetch list of available coupons with HTTP 304 optimization
  ///
  /// Returns null if server responds with 304 Not Modified (cached data is still valid)
  /// Returns [CouponListResponseDto] if new data is available
  /// Throws [DioException] on network errors
  ///
  /// HTTP 304 Optimization:
  /// - Sends If-None-Match header with ETag from previous response
  /// - Sends If-Modified-Since header with Last-Modified from previous response
  /// - Server returns 304 if data hasn't changed (saves bandwidth)
  /// - Server returns 200 with new data if changed
  Future<CouponListResponseDto?> fetchCoupons({int? page}) async {
    try {
      // Build request headers with conditional request headers
      final headers = <String, dynamic>{};

      // Add ETag for conditional request (If-None-Match)
      if (_lastETag != null) {
        headers['If-None-Match'] = _lastETag;
      }

      // Add Last-Modified for conditional request (If-Modified-Since)
      if (_lastModified != null) {
        headers['If-Modified-Since'] = _lastModified;
      }

      // Build query parameters
      final queryParameters = <String, dynamic>{};
      if (page != null) {
        queryParameters['page'] = page;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        '/api/order/v1/coupons/',
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            // Accept both 200 OK and 304 Not Modified
            return status == 200 || status == 304;
          },
        ),
      );

      // Handle 304 Not Modified - data hasn't changed, use cached version
      if (response.statusCode == 304) {
        return null;
      }

      // Handle 200 OK - new data available
      // Store ETag and Last-Modified for next request
      _lastETag = response.headers.value('etag');
      _lastModified = response.headers.value('last-modified');

      return CouponListResponseDto.fromJson(response.data!);
    } on DioException {
      // Let DioException propagate for error handling in repository
      rethrow;
    }
  }

  /// Clear cached HTTP headers (ETag, Last-Modified)
  ///
  /// Forces next fetchCoupons call to fetch fresh data from API
  void clearCache() {
    _lastETag = null;
    _lastModified = null;
  }

  /// Validate a coupon code
  ///
  /// Returns the Coupon if valid and applicable to current checkout
  /// Throws DioException with 400 if:
  /// - Code doesn't exist
  /// - Coupon is expired
  /// - Minimum quantity requirement not met
  /// - Coupon already applied
  Future<CouponDto> validateCoupon({required String code}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/order/v1/coupons/validate/',
      data: {'code': code},
    );

    return CouponDto.fromJson(response.data!);
  }

  /// Apply a coupon to the current checkout
  ///
  /// Returns updated coupon data
  /// Throws DioException with 400 if validation fails
  Future<CouponDto> applyCoupon({required String code}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/order/v1/coupons/apply/',
      data: {'code': code},
    );

    return CouponDto.fromJson(response.data!);
  }

  /// Remove applied coupon from checkout
  ///
  /// Returns 204 No Content on success
  Future<void> removeCoupon() async {
    await _dio.delete('/api/order/v1/coupons/remove/');
  }
}

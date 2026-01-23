import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/coupon.dart';
import '../../domain/entities/coupon_list_response.dart';

part 'coupon_list_state.freezed.dart';

/// Coupon list state for displaying available coupons
///
/// Union type with 4 states:
/// - [initial]: No data loaded yet
/// - [loading]: Fetching coupons from API
/// - [loaded]: Coupons successfully loaded
/// - [error]: Failed to load coupons
@freezed
class CouponListState with _$CouponListState {
  const factory CouponListState.initial() = CouponListInitial;

  const factory CouponListState.loading() = CouponListLoading;

  const factory CouponListState.loaded({
    required CouponListResponse response,
    required DateTime lastUpdated,
  }) = CouponListLoaded;

  const factory CouponListState.error({
    required String message,
    CouponListResponse? cachedResponse,
  }) = CouponListError;

  const CouponListState._();

  /// Check if state is loaded
  bool get isLoaded => this is CouponListLoaded;

  /// Check if state is loading
  bool get isLoading => this is CouponListLoading;

  /// Check if state is error
  bool get isError => this is CouponListError;

  /// Get available coupons from current state
  List<Coupon> get availableCoupons {
    return when(
      initial: () => [],
      loading: () => [],
      loaded: (response, _) => response.availableCoupons,
      error: (_, cachedResponse) => cachedResponse?.availableCoupons ?? [],
    );
  }

  /// Get all coupons from current state
  List<Coupon> get allCoupons {
    return when(
      initial: () => [],
      loading: () => [],
      loaded: (response, _) => response.results,
      error: (_, cachedResponse) => cachedResponse?.results ?? [],
    );
  }

  /// Check if there are any coupons
  bool get hasCoupons => allCoupons.isNotEmpty;

  /// Get coupon count
  int get couponCount {
    return when(
      initial: () => 0,
      loading: () => 0,
      loaded: (response, _) => response.count,
      error: (_, cachedResponse) => cachedResponse?.count ?? 0,
    );
  }
}

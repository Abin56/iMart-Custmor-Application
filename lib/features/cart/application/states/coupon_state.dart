import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/coupon.dart';

part 'coupon_state.freezed.dart';

/// Coupon state
@freezed
class CouponState with _$CouponState {
  const factory CouponState({
    required CouponStatus status,
    Coupon? appliedCoupon,
    String? errorMessage,
  }) = _CouponState;

  const CouponState._();

  /// Initial state
  factory CouponState.initial() =>
      const CouponState(status: CouponStatus.initial);

  /// Check if coupon is applied
  bool get hasCoupon => appliedCoupon != null;

  /// Get discount amount for a given cart total
  double getDiscountAmount(double cartTotal) {
    if (appliedCoupon == null) return 0.0;
    return appliedCoupon!.calculateDiscount(cartTotal);
  }

  /// Get formatted discount text
  String? get formattedDiscount => appliedCoupon?.formattedDiscount;
}

/// Coupon status enum
enum CouponStatus {
  /// Initial state, no coupon
  initial,

  /// Validating coupon
  validating,

  /// Coupon validated successfully
  validated,

  /// Applying coupon
  applying,

  /// Coupon applied successfully
  applied,

  /// Removing coupon
  removing,

  /// Error validating or applying coupon
  error,
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/cart_providers.dart';
import '../states/coupon_state.dart';

part 'coupon_controller.g.dart';

/// Coupon controller for validation and application
/// Keep alive to preserve coupon state across navigation
@Riverpod(keepAlive: true)
class CouponController extends _$CouponController {
  @override
  CouponState build() {
    return CouponState.initial();
  }

  /// Validate a coupon code
  ///
  /// Checks if the coupon is valid and applicable to the current cart
  /// Returns the validated coupon if successful
  Future<void> validateCoupon({
    required String code,
    required int checkoutItemsQuantity,
  }) async {
    state = state.copyWith(status: CouponStatus.validating, errorMessage: null);

    try {
      final repository = ref.read(couponRepositoryProvider);
      final coupon = await repository.validateCoupon(
        code: code,
        checkoutItemsQuantity: checkoutItemsQuantity,
      );

      state = state.copyWith(
        status: CouponStatus.validated,
        appliedCoupon: coupon,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CouponStatus.error,
        errorMessage: e.toString(),
        appliedCoupon: null,
      );
      rethrow;
    }
  }

  /// Apply a validated coupon to the checkout
  Future<void> applyCoupon(String code) async {
    state = state.copyWith(status: CouponStatus.applying, errorMessage: null);

    try {
      final repository = ref.read(couponRepositoryProvider);
      await repository.applyCoupon(code: code);

      // Keep the validated coupon in state after applying
      state = state.copyWith(
        status: CouponStatus.applied,
        errorMessage: null,
        // appliedCoupon is already set from validateCoupon, keep it
      );
    } catch (e) {
      state = state.copyWith(
        status: CouponStatus.error,
        errorMessage: e.toString(),
        appliedCoupon: null, // Clear coupon on error
      );
      rethrow;
    }
  }

  /// Remove the applied coupon
  Future<void> removeCoupon() async {
    state = state.copyWith(status: CouponStatus.removing, errorMessage: null);

    try {
      final repository = ref.read(couponRepositoryProvider);
      await repository.removeCoupon();

      state = state.copyWith(
        status: CouponStatus.initial,
        appliedCoupon: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CouponStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear coupon state (without making API call)
  void clearCoupon() {
    state = CouponState.initial();
  }
}

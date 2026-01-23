import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/coupon.dart';
import '../providers/cart_providers.dart';
import '../states/coupon_list_state.dart';

part 'coupon_list_controller.g.dart';

/// Coupon list controller with 30-second polling
///
/// Features:
/// - Fetches available coupons from API
/// - Auto-refreshes every 30 seconds when screen is active
/// - Pauses polling when screen is inactive to save resources
/// - HTTP 304 optimization to minimize bandwidth usage
/// - Caching for offline support
///
/// Usage:
/// ```dart
/// final couponListState = ref.watch(couponListControllerProvider);
/// ```
@riverpod
class CouponListController extends _$CouponListController {
  Timer? _pollingTimer;
  bool _isActive = false;

  @override
  CouponListState build() {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    });

    return const CouponListState.initial();
  }

  /// Start polling for coupon updates
  ///
  /// Fetches coupons every 30 seconds while screen is active
  /// Call this when screen becomes visible
  void startPolling() {
    if (_isActive) return; // Already polling

    _isActive = true;

    // Fetch immediately
    fetchCoupons();

    // Set up periodic polling every 30 seconds
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isActive) {
        fetchCoupons();
      }
    });
  }

  /// Stop polling for coupon updates
  ///
  /// Call this when screen becomes invisible to save resources
  void stopPolling() {
    _isActive = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Fetch coupons from repository
  ///
  /// Uses HTTP 304 conditional requests to minimize bandwidth:
  /// - First call fetches full data from API
  /// - Subsequent calls only fetch if data has changed
  /// - Returns cached data if server responds with 304 Not Modified
  Future<void> fetchCoupons({bool forceRefresh = false}) async {
    try {
      // Don't show loading on background refreshes (polling)
      if (state is! CouponListLoaded || forceRefresh) {
        state = const CouponListState.loading();
      }

      final repository = ref.read(couponRepositoryProvider);
      final response = await repository.fetchCoupons(
        forceRefresh: forceRefresh,
      );

      state = CouponListState.loaded(
        response: response,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // Keep cached data if available, but show error
      final currentState = state;
      if (currentState is CouponListLoaded) {
        state = CouponListState.error(
          message: e.toString(),
          cachedResponse: currentState.response,
        );
      } else {
        state = CouponListState.error(message: e.toString());
      }
    }
  }

  /// Refresh coupons (pull-to-refresh)
  ///
  /// Forces a fresh fetch from API, bypassing cache
  Future<void> refresh() async {
    await fetchCoupons(forceRefresh: true);
  }

  /// Clear cache and reload
  Future<void> clearCacheAndReload() async {
    final repository = ref.read(couponRepositoryProvider);
    await repository.clearCache();
    await fetchCoupons(forceRefresh: true);
  }
}

/// Provider for accessing current coupon list
///
/// Returns list of available coupons from current state
@riverpod
List<Coupon> availableCoupons(Ref ref) {
  final state = ref.watch(couponListControllerProvider);
  return state.availableCoupons;
}

/// Provider for checking if coupons are loading
@riverpod
bool areCouponsLoading(Ref ref) {
  final state = ref.watch(couponListControllerProvider);
  return state.isLoading;
}

/// Provider for getting coupon count
@riverpod
int couponCount(Ref ref) {
  final state = ref.watch(couponListControllerProvider);
  return state.couponCount;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableCouponsHash() => r'b919aa12719294de581904d65cf06071ade68fd3';

/// Provider for accessing current coupon list
///
/// Returns list of available coupons from current state
///
/// Copied from [availableCoupons].
@ProviderFor(availableCoupons)
final availableCouponsProvider = AutoDisposeProvider<List<Coupon>>.internal(
  availableCoupons,
  name: r'availableCouponsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableCouponsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableCouponsRef = AutoDisposeProviderRef<List<Coupon>>;
String _$areCouponsLoadingHash() => r'28f35d4eabf7abd9500a41c6ae24cb2b30256afa';

/// Provider for checking if coupons are loading
///
/// Copied from [areCouponsLoading].
@ProviderFor(areCouponsLoading)
final areCouponsLoadingProvider = AutoDisposeProvider<bool>.internal(
  areCouponsLoading,
  name: r'areCouponsLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$areCouponsLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AreCouponsLoadingRef = AutoDisposeProviderRef<bool>;
String _$couponCountHash() => r'1e926d671d8d6c383834953e6d765973a506455f';

/// Provider for getting coupon count
///
/// Copied from [couponCount].
@ProviderFor(couponCount)
final couponCountProvider = AutoDisposeProvider<int>.internal(
  couponCount,
  name: r'couponCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$couponCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CouponCountRef = AutoDisposeProviderRef<int>;
String _$couponListControllerHash() =>
    r'fc08be4893cb953888d3ab02bc9b42e38d962d10';

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
///
/// Copied from [CouponListController].
@ProviderFor(CouponListController)
final couponListControllerProvider =
    AutoDisposeNotifierProvider<CouponListController, CouponListState>.internal(
      CouponListController.new,
      name: r'couponListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$couponListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CouponListController = AutoDisposeNotifier<CouponListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

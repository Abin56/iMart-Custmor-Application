import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/core/providers/network_providers.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/repositories/checkout_line_repository.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../infrastructure/data_sources/address_remote_data_source.dart';
import '../../infrastructure/data_sources/checkout_line_local_data_source.dart';
import '../../infrastructure/data_sources/checkout_line_remote_data_source.dart';
import '../../infrastructure/data_sources/coupon_remote_data_source.dart';
import '../../infrastructure/repositories/address_repository_impl.dart';
import '../../infrastructure/repositories/checkout_line_repository_impl.dart';
import '../../infrastructure/repositories/coupon_repository_impl.dart';

part 'cart_providers.g.dart';

/// SharedPreferences instance provider
/// Note: In a real app, this should come from a core module
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

// ============================================================================
// Data Sources
// ============================================================================

/// Checkout line remote data source provider
@riverpod
CheckoutLineRemoteDataSource checkoutLineRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CheckoutLineRemoteDataSource(dio);
}

/// Checkout line local data source provider
@riverpod
Future<CheckoutLineLocalDataSource> checkoutLineLocalDataSource(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return CheckoutLineLocalDataSource(prefs);
}

/// Address remote data source provider
@riverpod
AddressRemoteDataSource addressRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AddressRemoteDataSource(dio);
}

/// Coupon remote data source provider
@riverpod
CouponRemoteDataSource couponRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CouponRemoteDataSource(dio);
}

// ============================================================================
// Repositories
// ============================================================================

/// Checkout line repository provider
@riverpod
Future<CheckoutLineRepository> checkoutLineRepository(Ref ref) async {
  final remoteDataSource = ref.watch(checkoutLineRemoteDataSourceProvider);
  final localDataSource = await ref.watch(
    checkoutLineLocalDataSourceProvider.future,
  );

  return CheckoutLineRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
}

/// Address repository provider
@riverpod
AddressRepository addressRepository(Ref ref) {
  final remoteDataSource = ref.watch(addressRemoteDataSourceProvider);

  return AddressRepositoryImpl(remoteDataSource: remoteDataSource);
}

/// Coupon repository provider
@riverpod
CouponRepository couponRepository(Ref ref) {
  final remoteDataSource = ref.watch(couponRemoteDataSourceProvider);

  return CouponRepositoryImpl(remoteDataSource: remoteDataSource);
}

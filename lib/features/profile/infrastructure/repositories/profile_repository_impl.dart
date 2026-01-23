// ignore_for_file: unawaited_futures

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:imart/app/core/error/failure.dart';
import 'package:imart/app/core/network/network_exceptions.dart';
import 'package:imart/features/auth/domain/entities/address.dart';
import 'package:imart/features/auth/domain/entities/user.dart';
import 'package:imart/features/profile/domain/entities/order.dart';
import 'package:imart/features/profile/domain/entities/order_item.dart';
import 'package:imart/features/profile/domain/entities/order_rating.dart';
import 'package:imart/features/profile/domain/repositories/profile_repository.dart';
import 'package:imart/features/profile/infrastructure/data_sources/local/profile_local_ds.dart';
import 'package:imart/features/profile/infrastructure/data_sources/remote/profile_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository_impl.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final api = ref.watch(profileApiProvider);
  final localDs = ref.watch(profileLocalDsProvider);
  return ProfileRepositoryImpl(api, localDs, ref);
}

/// Implementation of ProfileRepository following cache-first strategy
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api, this._localDs, this._ref);

  final ProfileApi _api;
  final ProfileLocalDs _localDs;
  // ignore: unused_field
  final Ref _ref;

  /// Callback to notify when orders are refreshed in background
  void Function(List<OrderEntity>)? onOrdersRefreshed;

  // ==================== Profile Management ====================

  @override
  Future<Either<Failure, UserEntity>> getProfile({
    bool forceRefresh = false,
  }) async {
    try {
      // Cache-first strategy: return cached data immediately if available
      if (!forceRefresh) {
        final cachedProfile = await _localDs.getCachedProfile();
        if (cachedProfile != null) {
          // Fetch fresh data in background
          _refreshProfileInBackground();
          return Right(cachedProfile);
        }
      }

      // Fetch from API

      final profile = await _api.getProfile();

      // Save to cache
      await _localDs.saveProfile(profile);

      return Right(profile);
    } catch (e) {
      // Try to return stale cache on error
      final cachedProfile = await _localDs.getCachedProfile();
      if (cachedProfile != null) {
        return Right(cachedProfile);
      }

      return Left(mapDioError(e));
    }
  }

  /// Refresh profile data in background (non-blocking)
  Future<void> _refreshProfileInBackground() async {
    try {
      final profile = await _api.getProfile();
      await _localDs.saveProfile(profile);
    } catch (e) {
      // Silently ignore background profile refresh errors
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final updatedProfile = await _api.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      // Update cache
      await _localDs.saveProfile(updatedProfile);

      return Right(updatedProfile);
    } catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<UserEntity?> getCachedProfile() async {
    return _localDs.getCachedProfile();
  }

  // ==================== Address Management ====================

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses({
    bool forceRefresh = false,
  }) async {
    try {
      // Cache-first strategy
      if (!forceRefresh) {
        final cachedAddresses = await _localDs.getCachedAddresses();
        if (cachedAddresses.isNotEmpty) {
          // Refresh in background
          _refreshAddressesInBackground();
          return Right(cachedAddresses);
        }
      }

      // Fetch from API

      final addresses = await _api.getAddresses();

      // Save to cache
      await _localDs.saveAddresses(addresses);

      return Right(addresses);
    } catch (e) {
      // Try to return stale cache on error
      final cachedAddresses = await _localDs.getCachedAddresses();
      if (cachedAddresses.isNotEmpty) {
        return Right(cachedAddresses);
      }

      return Left(mapDioError(e));
    }
  }

  /// Refresh addresses in background
  Future<void> _refreshAddressesInBackground() async {
    try {
      final addresses = await _api.getAddresses();
      await _localDs.saveAddresses(addresses);
    } catch (e) {
      // Silently ignore background address refresh errors
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> addAddress({
    required String firstName,
    required String lastName,
    required String streetAddress1,
    required String city,
    required String state,
    required String addressType,
    String? streetAddress2,
    bool selected = false,
  }) async {
    try {
      final address = await _api.addAddress(
        firstName: firstName,
        lastName: lastName,
        streetAddress1: streetAddress1,
        city: city,
        state: state,
        addressType: addressType,
        streetAddress2: streetAddress2,
        selected: selected,
      );

      // Refresh addresses cache
      final addresses = await _api.getAddresses();
      await _localDs.saveAddresses(addresses);

      return Right(address);
    } catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress({
    required int id,
    required String firstName,
    required String lastName,
    required String streetAddress1,
    required String city,
    required String state,
    required String addressType,
    String? streetAddress2,
    bool selected = false,
  }) async {
    try {
      final address = await _api.updateAddress(
        id: id,
        firstName: firstName,
        lastName: lastName,
        streetAddress1: streetAddress1,
        city: city,
        state: state,
        addressType: addressType,
        streetAddress2: streetAddress2,
        selected: selected,
      );

      // Refresh addresses cache
      final addresses = await _api.getAddresses();
      await _localDs.saveAddresses(addresses);

      return Right(address);
    } catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress({required int id}) async {
    try {
      await _api.deleteAddress(id: id);

      // Refresh addresses cache
      final addresses = await _api.getAddresses();
      await _localDs.saveAddresses(addresses);

      return const Right(null);
    } catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<List<AddressEntity>> getCachedAddresses() async {
    return _localDs.getCachedAddresses();
  }

  // ==================== Order Management ====================

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    bool? isActive,
    bool forceRefresh = false,
  }) async {
    try {
      // Cache-first strategy
      if (!forceRefresh) {
        final cachedOrders = await _localDs.getCachedOrders();
        if (cachedOrders.isNotEmpty) {
          // Filter by isActive if specified
          final filteredOrders = isActive != null
              ? cachedOrders.where((o) => o.isActive == isActive).toList()
              : cachedOrders;
          // Refresh in background
          _refreshOrdersInBackground();
          return Right(filteredOrders);
        }
      }

      // Fetch from API with delivery statuses

      final orders = await _api.getOrdersWithDeliveryStatus();

      // Save to cache
      await _localDs.saveOrders(orders);

      // Filter by isActive if specified
      final filteredOrders = isActive != null
          ? orders.where((o) => o.isActive == isActive).toList()
          : orders;

      return Right(filteredOrders);
    } catch (e) {
      // Try to return stale cache on error
      final cachedOrders = await _localDs.getCachedOrders();
      if (cachedOrders.isNotEmpty) {
        final filteredOrders = isActive != null
            ? cachedOrders.where((o) => o.isActive == isActive).toList()
            : cachedOrders;
        return Right(filteredOrders);
      }

      return Left(mapDioError(e));
    }
  }

  /// Refresh orders in background and notify listeners
  Future<void> _refreshOrdersInBackground() async {
    try {
      final orders = await _api.getOrdersWithDeliveryStatus();

      await _localDs.saveOrders(orders);

      // Notify callback if registered
      onOrdersRefreshed?.call(orders);
    } catch (e) {
      // Silently fail background refresh
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails({
    required int orderId,
  }) async {
    try {
      final order = await _api.getOrderDetails(orderId: orderId);

      return Right(order);
    } catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, List<OrderItemEntity>>> getOrderItems({
    required int orderId,
  }) async {
    try {
      final items = await _api.getOrderItems(orderId: orderId);

      return Right(items);
    } catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, void>> rateOrder({
    required OrderRatingEntity rating,
  }) async {
    try {
      await _api.rateOrder(rating: rating);

      // Refresh orders cache to update rating (use full method to get delivery status + ratings)
      final orders = await _api.getOrdersWithDeliveryStatus();
      await _localDs.saveOrders(orders);

      return const Right(null);
    } on AlreadyRatedException {
      // Refresh orders cache anyway to ensure rating status is up-to-date
      try {
        final orders = await _api.getOrdersWithDeliveryStatus();
        await _localDs.saveOrders(orders);
      } catch (_) {}
      return const Left(AlreadyRatedFailure());
    } catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, void>> reorder({required int orderId}) async {
    try {
      await _api.reorder(orderId: orderId);

      return const Right(null);
    } catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<List<OrderEntity>> getCachedOrders() async {
    return _localDs.getCachedOrders();
  }

  // ==================== Cache Management ====================

  @override
  Future<void> clearCache() async {
    await _localDs.clearAllCache();
  }
}

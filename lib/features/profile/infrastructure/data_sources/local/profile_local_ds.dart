import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/app/core/storage/hive/boxes.dart';
import 'package:imart/app/core/storage/hive/keys.dart';
import 'package:imart/features/auth/domain/entities/address.dart';
import 'package:imart/features/auth/domain/entities/user.dart';
import 'package:imart/features/profile/domain/entities/order.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_local_ds.g.dart';

@riverpod
ProfileLocalDs profileLocalDs(Ref ref) {
  return ProfileLocalDs();
}

/// Local data source for caching profile-related data using Hive
class ProfileLocalDs {
  // ==================== Profile Caching ====================

  /// Save user profile to cache
  Future<void> saveProfile(UserEntity? user) async {
    final box = Boxes.userBox;

    if (user == null) {
      await box.delete(HiveKeys.userbox);
    } else {
      // Reuse UserModel from auth feature
      final userModel = user.toMap();
      await box.put(HiveKeys.userbox, userModel);
    }
  }

  /// Get cached user profile
  Future<UserEntity?> getCachedProfile() async {
    final box = Boxes.userBox;
    final userData = box.get(HiveKeys.userbox);

    if (userData == null) return null;

    // Parse from map
    if (userData is Map) {
      return UserEntity.fromMap(Map<String, dynamic>.from(userData));
    }

    return null;
  }

  /// Delete cached profile
  Future<void> deleteProfile() async {
    final box = Boxes.userBox;
    await box.delete(HiveKeys.userbox);
  }

  // ==================== Address Caching ====================

  /// Save addresses to cache
  Future<void> saveAddresses(List<AddressEntity> addresses) async {
    final box = Boxes.addressBox;

    // Clear existing addresses
    await box.clear();

    // Save each address with its ID as key
    for (final address in addresses) {
      await box.put('address_${address.id}', address.toMap());
    }

    // Save the list of address IDs for quick retrieval
    final addressIds = addresses.map((a) => a.id).toList();
    await box.put('address_ids', addressIds);
  }

  /// Get cached addresses
  Future<List<AddressEntity>> getCachedAddresses() async {
    final box = Boxes.addressBox;

    // Get the list of address IDs
    final addressIds = box.get('address_ids') as List?;

    if (addressIds == null || addressIds.isEmpty) {
      return [];
    }

    final addresses = <AddressEntity>[];

    for (final id in addressIds) {
      final addressData = box.get('address_$id');
      if (addressData != null && addressData is Map) {
        try {
          final address = AddressEntity.fromMap(
            Map<String, dynamic>.from(addressData),
          );
          addresses.add(address);
        } catch (e) {
          // Skip invalid address data
          continue;
        }
      }
    }

    return addresses;
  }

  /// Delete all cached addresses
  Future<void> deleteAddresses() async {
    final box = Boxes.addressBox;
    await box.clear();
  }

  // ==================== Order Caching ====================

  /// Save orders to cache
  Future<void> saveOrders(List<OrderEntity> orders) async {
    final box = Boxes.userBox; // Reusing user box for orders

    // Save each order with its ID as key
    for (final order in orders) {
      await box.put('order_${order.id}', order.toMap());
    }

    // Save the list of order IDs for quick retrieval
    final orderIds = orders.map((o) => o.id).toList();
    await box.put('order_ids', orderIds);
  }

  /// Get cached orders
  Future<List<OrderEntity>> getCachedOrders() async {
    final box = Boxes.userBox; // Reusing user box for orders

    // Get the list of order IDs
    final orderIds = box.get('order_ids') as List?;

    if (orderIds == null || orderIds.isEmpty) {
      return [];
    }

    final orders = <OrderEntity>[];

    for (final id in orderIds) {
      final orderData = box.get('order_$id');
      if (orderData != null && orderData is Map) {
        try {
          final order = OrderEntity.fromMap(
            Map<String, dynamic>.from(orderData),
          );
          orders.add(order);
        } catch (e) {
          // Skip invalid order data
          continue;
        }
      }
    }

    return orders;
  }

  /// Delete all cached orders
  Future<void> deleteOrders() async {
    final box = Boxes.userBox;

    // Get order IDs and delete each order
    final orderIds = box.get('order_ids') as List?;
    if (orderIds != null) {
      for (final id in orderIds) {
        await box.delete('order_$id');
      }
    }

    // Delete the order IDs list
    await box.delete('order_ids');
  }

  // ==================== Cache Management ====================

  /// Clear all profile-related cache
  Future<void> clearAllCache() async {
    await Future.wait([deleteProfile(), deleteAddresses(), deleteOrders()]);
  }
}

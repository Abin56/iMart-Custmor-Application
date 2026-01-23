import 'package:fpdart/fpdart.dart';

import 'package:imart/app/core/error/failure.dart';
import 'package:imart/features/auth/domain/entities/address.dart';
import 'package:imart/features/auth/domain/entities/user.dart';
import 'package:imart/features/profile/domain/entities/order.dart';
import 'package:imart/features/profile/domain/entities/order_item.dart';
import 'package:imart/features/profile/domain/entities/order_rating.dart';

/// Profile repository interface following Clean Architecture
abstract class ProfileRepository {
  // ==================== Profile Management ====================

  /// Get user profile data with caching support
  /// Returns cached data first, then fetches fresh data in background
  Future<Either<Failure, UserEntity>> getProfile({bool forceRefresh = false});

  /// Update user profile information
  /// [firstName] - User's first name
  /// [lastName] - User's last name (optional)
  /// [email] - User's email address
  /// [phoneNumber] - User's phone number (optional)
  Future<Either<Failure, UserEntity>> updateProfile({
    required String firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  });

  /// Get cached profile data (instant, offline-first)
  Future<UserEntity?> getCachedProfile();

  // ==================== Address Management ====================

  /// Get all user addresses
  /// Returns cached data first, then fetches fresh data
  Future<Either<Failure, List<AddressEntity>>> getAddresses({
    bool forceRefresh = false,
  });

  /// Add a new delivery address
  /// [firstName] - Recipient's first name
  /// [lastName] - Recipient's last name
  /// [streetAddress1] - Primary street address
  /// [streetAddress2] - Secondary street address (optional)
  /// [city] - City name
  /// [state] - State name
  /// [addressType] - Type of address (home, work, other)
  /// [selected] - Set as default address
  Future<Either<Failure, AddressEntity>> addAddress({
    required String firstName,
    required String lastName,
    required String streetAddress1,
    required String city,
    required String state,
    required String addressType,
    String? streetAddress2,
    bool selected = false,
  });

  /// Update an existing address
  /// [id] - Address ID to update
  /// Other parameters same as addAddress
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
  });

  /// Delete an address
  /// [id] - Address ID to delete
  Future<Either<Failure, void>> deleteAddress({required int id});

  /// Get cached addresses (instant, offline-first)
  Future<List<AddressEntity>> getCachedAddresses();

  // ==================== Order Management ====================

  /// Get all user orders with optional filtering
  /// [isActive] - Filter active orders (true) or completed/cancelled (false)
  /// Returns cached data first, then fetches fresh data
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    bool? isActive,
    bool forceRefresh = false,
  });

  /// Get order details by ID
  /// [orderId] - Order ID to fetch
  Future<Either<Failure, OrderEntity>> getOrderDetails({required int orderId});

  /// Get order items (line items) for a specific order
  /// [orderId] - Order ID to fetch items for
  Future<Either<Failure, List<OrderItemEntity>>> getOrderItems({
    required int orderId,
  });

  /// Submit rating and review for an order
  /// [rating] - OrderRatingEntity containing order ID, rating (1-5), and optional review
  Future<Either<Failure, void>> rateOrder({required OrderRatingEntity rating});

  /// Reorder - creates new order with same items
  /// [orderId] - Order ID to reorder
  Future<Either<Failure, void>> reorder({required int orderId});

  /// Get cached orders (instant, offline-first)
  Future<List<OrderEntity>> getCachedOrders();

  // ==================== Cache Management ====================

  /// Clear all profile-related cache
  Future<void> clearCache();
}

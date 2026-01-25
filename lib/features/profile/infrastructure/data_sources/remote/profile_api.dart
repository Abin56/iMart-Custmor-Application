import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/app/core/network/endpoints.dart';
import 'package:imart/app/core/network/network_exceptions.dart';
import 'package:imart/app/core/providers/network_providers.dart';
import 'package:imart/features/auth/domain/entities/address.dart';
import 'package:imart/features/auth/domain/entities/user.dart';
import 'package:imart/features/profile/domain/entities/order.dart';
import 'package:imart/features/profile/domain/entities/order_item.dart';
import 'package:imart/features/profile/domain/entities/order_rating.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_api.g.dart';

/// Exception thrown when user tries to rate an order that's already been rated
class AlreadyRatedException implements Exception {
  AlreadyRatedException([this.message = 'You have already rated this order']);
  final String message;

  @override
  String toString() => message;
}

@riverpod
ProfileApi profileApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ProfileApi(dio);
}

/// Profile API client for handling all profile-related HTTP requests
class ProfileApi {
  ProfileApi(this._dio);
  final Dio _dio;

  // ==================== Profile Management ====================

  /// Get user profile data
  Future<UserEntity> getProfile() async {
    try {
      final res = await _dio.get(ProfileEndpoints.getProfile);

      if (res.statusCode != 200) {
        throw Exception('Get profile failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final user = UserEntity.fromMap(data);

      return user;
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Update user profile
  Future<UserEntity> updateProfile({
    required String firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    dynamic profilePhoto,
  }) async {
    try {
      dynamic requestData;

      // If profile photo is provided, use FormData for multipart upload
      if (profilePhoto != null) {
        final formData = FormData();
        formData.fields.add(MapEntry('first_name', firstName));
        if (lastName != null && lastName.isNotEmpty) {
          formData.fields.add(MapEntry('last_name', lastName));
        }
        if (email != null && email.isNotEmpty) {
          formData.fields.add(MapEntry('email', email));
        }
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          formData.fields.add(MapEntry('phone_number', phoneNumber));
        }

        // Add profile photo file
        // Use platform-agnostic path separator
        final pathSegments = profilePhoto.path.split(RegExp(r'[/\\]'));
        final fileName = pathSegments.last;

        formData.files.add(
          MapEntry(
            'profile_photo_file',
            await MultipartFile.fromFile(
              profilePhoto.path,
              filename: fileName,
            ),
          ),
        );
        requestData = formData;
      } else {
        // Regular JSON request
        requestData = <String, dynamic>{
          'first_name': firstName,
          if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
          if (email != null && email.isNotEmpty) 'email': email,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phone_number': phoneNumber,
        };
      }

      final res = await _dio.patch(
        ProfileEndpoints.updateProfile,
        data: requestData,
        options: profilePhoto != null
            ? Options(
                headers: {
                  'Content-Type': 'multipart/form-data',
                },
              )
            : null,
      );

      if (res.statusCode != 200) {
        throw Exception('Update profile failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final user = UserEntity.fromMap(data);

      return user;
    } on DioException catch (e) {
      // Enhanced error handling for file upload errors
      if (e.response?.statusCode == 500 && profilePhoto != null) {
        throw Exception(
          'Server error while uploading photo. Please contact support or try updating without changing the photo.',
        );
      }
      final failure = mapDioError(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ==================== Address Management ====================

  /// Get all user addresses
  Future<List<AddressEntity>> getAddresses() async {
    try {
      final res = await _dio.get(ProfileEndpoints.addresses);

      if (res.statusCode != 200) {
        throw Exception('Get addresses failed: ${res.statusCode}');
      }

      final data = res.data as List;
      final addresses = data
          .map((item) => AddressEntity.fromMap(item as Map<String, dynamic>))
          .toList();

      return addresses;
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Add a new address
  Future<AddressEntity> addAddress({
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
      final body = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'street_address1': streetAddress1,
        if (streetAddress2 != null && streetAddress2.isNotEmpty)
          'street_address2': streetAddress2,
        'city': city,
        'state': state,
        'address_type': addressType,
        'selected': selected,
      };

      final res = await _dio.post(ProfileEndpoints.addresses, data: body);

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw Exception('Add address failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final address = AddressEntity.fromMap(data);

      return address;
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Update an existing address
  Future<AddressEntity> updateAddress({
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
      final body = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'street_address1': streetAddress1,
        if (streetAddress2 != null && streetAddress2.isNotEmpty)
          'street_address2': streetAddress2,
        'city': city,
        'state': state,
        'address_type': addressType,
        'selected': selected,
      };

      final res = await _dio.patch(
        ProfileEndpoints.addressById(id),
        data: body,
      );

      if (res.statusCode != 200) {
        throw Exception('Update address failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final address = AddressEntity.fromMap(data);

      return address;
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Delete an address
  Future<void> deleteAddress({required int id}) async {
    try {
      final res = await _dio.delete(ProfileEndpoints.addressById(id));

      if (res.statusCode != 204 && res.statusCode != 200) {
        throw Exception('Delete address failed: ${res.statusCode}');
      }
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  // ==================== Order Management ====================

  /// Get all user orders with their ratings
  Future<List<OrderEntity>> getOrders() async {
    try {
      final res = await _dio.get(ProfileEndpoints.orders);

      if (res.statusCode != 200) {
        throw Exception('Get orders failed: ${res.statusCode}');
      }

      // Handle paginated response: {"count": N, "results": [...]}
      final responseData = res.data;

      List<dynamic> data;

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('results')) {
        // Paginated response
        data = responseData['results'] as List<dynamic>;
      } else if (responseData is List) {
        // Direct list response

        data = responseData;
      } else {
        throw Exception('Unexpected response format');
      }

      final orders = data
          .map((item) => OrderEntity.fromMap(item as Map<String, dynamic>))
          .toList();

      // Note: Rating fetch moved to getOrdersWithDeliveryStatus() to ensure
      // we have deliveryStatus populated before checking if order is delivered

      return orders;
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Fetch ratings for orders that might have ratings
  Future<List<OrderEntity>> _fetchRatingsForOrders(
    List<OrderEntity> orders,
  ) async {
    final updatedOrders = <OrderEntity>[];

    for (final order in orders) {
      // Only fetch rating for delivered orders that don't have rating data
      final effectiveStatus = order.effectiveStatus.toLowerCase();

      if ((effectiveStatus == 'delivered' || effectiveStatus == 'completed') &&
          order.rating == null) {
        try {
          final ratingData = await _fetchOrderRating(order.id);
          if (ratingData != null) {
            updatedOrders.add(
              order.copyWith(
                rating: ratingData['stars'] as int?,
                ratingReview: ratingData['body'] as String?,
              ),
            );
            continue;
          }
        } catch (e) {
          // Ignore rating fetch errors for individual orders
        }
      }
      updatedOrders.add(order);
    }

    return updatedOrders;
  }

  /// Fetch rating for a specific order
  /// Returns null if no rating exists
  Future<Map<String, dynamic>?> _fetchOrderRating(int orderId) async {
    try {
      final endpoint = '/api/order/v1/$orderId/ratings/';

      final res = await _dio.get(endpoint);

      if (res.statusCode != 200) {
        return null;
      }

      final responseData = res.data;

      // Handle paginated response or direct response
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('results')) {
          final results = responseData['results'] as List<dynamic>;

          if (results.isNotEmpty) {
            // Return the first (most recent) rating
            final ratingData = results.first as Map<String, dynamic>;

            return ratingData;
          } else {}
        } else if (responseData.containsKey('stars')) {
          // Direct rating object

          return responseData;
        } else {}
      } else if (responseData is List) {
        if (responseData.isNotEmpty) {
          // Direct list response
          final ratingData = responseData.first as Map<String, dynamic>;

          return ratingData;
        } else {}
      } else {}

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get order details by ID
  Future<OrderEntity> getOrderDetails({required int orderId}) async {
    try {
      final res = await _dio.get(ProfileEndpoints.orderDetails(orderId));

      if (res.statusCode != 200) {
        throw Exception('Get order details failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final order = OrderEntity.fromMap(data);

      return order;
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Get order items (line items) for a specific order
  /// Uses the order details endpoint which includes order_lines directly
  Future<List<OrderItemEntity>> getOrderItems({required int orderId}) async {
    try {
      // Use order details endpoint instead of order-lines endpoint
      // This ensures we only get items for this specific order
      final endpoint = ProfileEndpoints.orderDetails(orderId);
      print('🔵 [ProfileAPI] Fetching order items from: $endpoint');

      final res = await _dio.get(endpoint);

      print('🔵 [ProfileAPI] Response status: ${res.statusCode}');

      if (res.statusCode != 200) {
        throw Exception('Get order items failed: ${res.statusCode}');
      }

      final responseData = res.data as Map<String, dynamic>;
      print('🔵 [ProfileAPI] Order ID from response: ${responseData['id']}');

      // Extract order_lines from the order details response
      final orderLines = responseData['order_lines'] as List<dynamic>?;

      if (orderLines == null || orderLines.isEmpty) {
        print('🟡 [ProfileAPI] No order_lines found in response');
        return [];
      }

      print('🟡 [ProfileAPI] Found ${orderLines.length} items in order_lines');

      final items = orderLines
          .map((item) => OrderItemEntity.fromMap(item as Map<String, dynamic>))
          .toList();

      print('🟢 [ProfileAPI] Successfully parsed ${items.length} items for order $orderId');
      for (var i = 0; i < items.length; i++) {
        print('   [${i + 1}] ${items[i].productName} (Qty: ${items[i].quantity}, Order: ${items[i].orderId})');
      }

      return items;
    } catch (e) {
      print('🔴 [ProfileAPI] Error fetching order items: $e');
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Submit rating and review for an order
  /// API: POST /api/order/v1/{order_id}/ratings/
  /// Body: { "stars": 5, "body": "string" }
  Future<void> rateOrder({required OrderRatingEntity rating}) async {
    try {
      final body = rating.toMap();
      final endpoint = ProfileEndpoints.submitRating(rating.orderId);

      final res = await _dio.post(endpoint, data: body);

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw Exception('Submit rating failed: ${res.statusCode}');
      }
    } on DioException catch (e) {
      // Check for "already rated" error (HTTP 400)
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          final detail = responseData['detail'] as String?;
          if (detail != null && detail.toLowerCase().contains('already')) {
            throw AlreadyRatedException(detail);
          }
        }
      }

      final failure = mapDioError(e);
      throw Exception(failure.message);
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Reorder - adds items from an existing order to the user's checkout
  /// Returns: {"message": "...", "checkout_id": 1}
  Future<Map<String, dynamic>> reorder({required int orderId}) async {
    try {
      final res = await _dio.post(ProfileEndpoints.reorder(orderId));

      if (res.statusCode != 200) {
        throw Exception('Reorder failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      return data;
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  // ==================== Delivery Management ====================

  /// Get all orders with their delivery statuses
  /// Fetches all deliveries once, builds order->delivery map, then fetches each delivery's current status
  Future<List<OrderEntity>> getOrdersWithDeliveryStatus() async {
    try {
      // Step 1: Get all orders
      final orders = await getOrders();

      // Step 2: Fetch ALL deliveries once

      final allDeliveriesRes = await _dio.get('/api/delivery/v1/deliveries/');

      if (allDeliveriesRes.statusCode != 200) {
        return orders;
      }

      final responseData = allDeliveriesRes.data;
      List<dynamic> allDeliveries;

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('results')) {
        allDeliveries = responseData['results'] as List<dynamic>;
      } else if (responseData is List) {
        allDeliveries = responseData;
      } else {
        return orders;
      }

      // Step 3: Build map of orderId -> deliveryId (most recently UPDATED delivery per order)
      // We need to find the delivery with the latest updated_at timestamp, NOT the highest ID
      final orderToDeliveryId = <int, int>{};
      final orderToUpdatedAt = <int, DateTime>{};

      for (final delivery in allDeliveries) {
        final deliveryMap = delivery as Map<String, dynamic>;
        final deliveryOrderId = deliveryMap['order'] as int?;
        final deliveryId = deliveryMap['id'] as int?;
        final updatedAtStr = deliveryMap['updated_at'] as String?;

        if (deliveryOrderId != null &&
            deliveryId != null &&
            updatedAtStr != null) {
          final updatedAt = DateTime.tryParse(updatedAtStr);
          if (updatedAt != null) {
            // Keep the delivery with the most recent updated_at timestamp
            if (!orderToDeliveryId.containsKey(deliveryOrderId) ||
                updatedAt.isAfter(orderToUpdatedAt[deliveryOrderId]!)) {
              orderToDeliveryId[deliveryOrderId] = deliveryId;
              orderToUpdatedAt[deliveryOrderId] = updatedAt;
            }
          }
        }
      }

      // Step 4: For each order, fetch its delivery's current status
      final ordersWithStatus = await Future.wait(
        orders.map((order) async {
          final deliveryId = orderToDeliveryId[order.id];

          if (deliveryId == null) {
            return order;
          }

          try {
            // Fetch specific delivery details
            final detailsRes = await _dio.get(
              '/api/delivery/v1/deliveries/$deliveryId/',
            );

            if (detailsRes.statusCode == 200) {
              final deliveryDetails = detailsRes.data as Map<String, dynamic>;
              final status = deliveryDetails['status'] as String?;
              final notes = deliveryDetails['notes'] as String?;

              if (status != null) {
                return order.copyWith(
                  deliveryStatus: status,
                  deliveryNotes: notes,
                );
              }
            }
          } catch (e) {
            // Ignore delivery fetch errors for individual orders
          }

          return order;
        }),
      );

      // Step 5: Now that we have delivery statuses, fetch ratings for delivered orders

      final ordersWithRatings = await _fetchRatingsForOrders(ordersWithStatus);

      return ordersWithRatings;
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Get delivery status for a single order (used for individual order tracking)
  Future<String?> getDeliveryStatusForOrder({required int orderId}) async {
    try {
      // Fetch all deliveries and find the one matching this order
      final res = await _dio.get('/api/delivery/v1/deliveries/');

      if (res.statusCode != 200) {
        return null;
      }

      final responseData = res.data;
      List<dynamic> deliveries;

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('results')) {
        deliveries = responseData['results'] as List<dynamic>;
      } else if (responseData is List) {
        deliveries = responseData;
      } else {
        return null;
      }

      // Find delivery matching this order ID with most recent updated_at
      int? deliveryId;
      DateTime? latestUpdatedAt;

      for (final delivery in deliveries) {
        final deliveryMap = delivery as Map<String, dynamic>;
        final deliveryOrderId = deliveryMap['order'] as int?;
        if (deliveryOrderId == orderId) {
          final currentId = deliveryMap['id'] as int?;
          final updatedAtStr = deliveryMap['updated_at'] as String?;

          if (currentId != null && updatedAtStr != null) {
            final updatedAt = DateTime.tryParse(updatedAtStr);
            if (updatedAt != null &&
                (latestUpdatedAt == null ||
                    updatedAt.isAfter(latestUpdatedAt))) {
              deliveryId = currentId;
              latestUpdatedAt = updatedAt;
            }
          }
        }
      }

      if (deliveryId == null) {
        return null;
      }

      // Fetch specific delivery details
      final detailsRes = await _dio.get(
        '/api/delivery/v1/deliveries/$deliveryId/',
      );

      if (detailsRes.statusCode != 200) {
        return null;
      }

      final deliveryDetails = detailsRes.data as Map<String, dynamic>;
      final status = deliveryDetails['status'] as String?;

      return status;
    } catch (e) {
      return null;
    }
  }
}

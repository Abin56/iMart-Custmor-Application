import 'package:imart/app/core/error/failure.dart';
import 'package:imart/features/profile/application/states/order_state.dart';
import 'package:imart/features/profile/domain/entities/order.dart';
import 'package:imart/features/profile/domain/entities/order_rating.dart';
import 'package:imart/features/profile/domain/repositories/profile_repository.dart';
import 'package:imart/features/profile/infrastructure/repositories/profile_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_provider.g.dart';

/// Order Notifier for managing orders state
@Riverpod(keepAlive: true)
class Order extends _$Order {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  OrderState build() {
    // Register callback for background refresh notifications
    _registerBackgroundRefreshCallback();

    // Initialize by loading cached orders
    _loadOrders();
    return const OrderInitial();
  }

  /// Register callback to be notified when orders are refreshed in background
  void _registerBackgroundRefreshCallback() {
    final repo = ref.read(profileRepositoryProvider);
    if (repo is ProfileRepositoryImpl) {
      repo.onOrdersRefreshed = (orders) {
        // Only update if we're in a loaded state (not loading items, etc.)
        final currentState = state;
        if (currentState is OrderLoaded ||
            currentState is OrderItemsLoading ||
            currentState is OrderItemsLoaded) {
          // Preserve the current state type but update orders
          if (currentState is OrderLoaded) {
            state = OrderLoaded(orders);
          } else if (currentState is OrderItemsLoading) {
            state = OrderItemsLoading(currentState.orderId, orders: orders);
          } else if (currentState is OrderItemsLoaded) {
            state = OrderItemsLoaded(
              currentState.orderId,
              currentState.items,
              orders: orders,
            );
          }
        }
      };
    }
  }

  /// Load orders (cache-first strategy)
  Future<void> _loadOrders() async {
    try {
      state = const OrderLoading();

      final result = await _repository.getOrders();

      result.fold(
        (failure) {
          state = OrderError(failure, state);
        },
        (orders) {
          state = OrderLoaded(orders);
        },
      );
      // ignore: empty_catches
    } catch (e) {}
  }

  /// Refresh orders (force fetch from API)
  Future<void> refreshOrders() async {
    try {
      state = const OrderLoading();

      final result = await _repository.getOrders(forceRefresh: true);

      result.fold(
        (failure) {
          state = OrderError(failure, state);
        },
        (orders) {
          state = OrderLoaded(orders);
        },
      );
      // ignore: empty_catches
    } catch (e) {}
  }

  /// Load order items for a specific order
  /// Preserves orders list so the orders screen doesn't disappear
  Future<void> loadOrderItems({required int orderId}) async {
    try {
      // Preserve orders list from current state
      final currentOrders = _getCurrentOrders();

      state = OrderItemsLoading(orderId, orders: currentOrders);

      final result = await _repository.getOrderItems(orderId: orderId);

      result.fold(
        (failure) {
          state = OrderError(failure, state);
        },
        (items) {
          state = OrderItemsLoaded(orderId, items, orders: currentOrders);
        },
      );
      // ignore: empty_catches
    } catch (e) {}
  }

  /// Helper to get current orders list from any state
  List<OrderEntity> _getCurrentOrders() {
    final currentState = state;
    if (currentState is OrderLoaded) {
      return currentState.orders;
    } else if (currentState is OrderItemsLoading) {
      return currentState.orders;
    } else if (currentState is OrderItemsLoaded) {
      return currentState.orders;
    }
    return [];
  }

  /// Submit rating for an order
  /// Returns: true if success, false if error, null if already rated
  Future<bool?> submitRating({
    required int orderId,
    required int rating,
    String? review,
  }) async {
    try {
      state = OrderRatingSubmitting(orderId);

      final ratingEntity = OrderRatingEntity(
        orderId: orderId,
        rating: rating,
        review: review,
      );

      final result = await _repository.rateOrder(rating: ratingEntity);

      return result.fold(
        (failure) {
          // Check if it's an "already rated" failure
          if (failure is AlreadyRatedFailure) {
            state = OrderAlreadyRated(orderId);
            // Reload orders to update rating status
            Future.delayed(const Duration(milliseconds: 500), _loadOrders);
            return null; // null indicates already rated
          }
          state = OrderError(failure, state);
          return false;
        },
        (_) {
          state = OrderRatingSuccess(orderId);
          // Reload orders to update rating status
          Future.delayed(const Duration(milliseconds: 500), _loadOrders);
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Reorder an order (add items to cart)
  Future<bool> reorder({required int orderId}) async {
    try {
      state = OrderReordering(orderId);

      final result = await _repository.reorder(orderId: orderId);

      return result.fold(
        (failure) {
          state = OrderError(failure, state);
          return false;
        },
        (_) {
          state = OrderReorderSuccess(orderId);
          // Return to loaded state
          Future.delayed(const Duration(milliseconds: 500), _loadOrders);
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }
}

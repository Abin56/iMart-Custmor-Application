import 'package:imart/app/core/error/failure.dart';
import 'package:imart/features/profile/domain/entities/order.dart';
import 'package:imart/features/profile/domain/entities/order_item.dart';

/// Sealed class for type-safe order state management
sealed class OrderState {
  const OrderState();
}

/// Initial state - checking for cached orders
class OrderInitial extends OrderState {
  const OrderInitial();
}

/// Loading state - fetching orders from API
class OrderLoading extends OrderState {
  const OrderLoading();
}

/// Orders loaded successfully
class OrderLoaded extends OrderState {
  const OrderLoaded(this.orders);

  final List<OrderEntity> orders;

  /// Get active orders (not delivered or cancelled)
  List<OrderEntity> get activeOrders {
    return orders.where((o) => o.isActive).toList();
  }

  /// Get completed/cancelled orders
  List<OrderEntity> get completedOrders {
    return orders.where((o) => !o.isActive).toList();
  }

  /// Check if orders list is empty
  bool get isEmpty => orders.isEmpty;

  /// Check if orders list is not empty
  bool get isNotEmpty => orders.isNotEmpty;
}

/// Loading order items for a specific order
/// Preserves the orders list so the orders screen doesn't disappear
class OrderItemsLoading extends OrderState {
  const OrderItemsLoading(this.orderId, {this.orders = const []});

  final int orderId;
  final List<OrderEntity> orders;

  /// Get active orders (not delivered or cancelled)
  List<OrderEntity> get activeOrders {
    return orders.where((o) => o.isActive).toList();
  }

  /// Get completed/cancelled orders
  List<OrderEntity> get completedOrders {
    return orders.where((o) => !o.isActive).toList();
  }
}

/// Order items loaded successfully
/// Preserves the orders list so the orders screen doesn't disappear
class OrderItemsLoaded extends OrderState {
  const OrderItemsLoaded(this.orderId, this.items, {this.orders = const []});

  final int orderId;
  final List<OrderItemEntity> items;
  final List<OrderEntity> orders;

  /// Get active orders (not delivered or cancelled)
  List<OrderEntity> get activeOrders {
    return orders.where((o) => o.isActive).toList();
  }

  /// Get completed/cancelled orders
  List<OrderEntity> get completedOrders {
    return orders.where((o) => !o.isActive).toList();
  }

  /// Calculate subtotal (sum of all item prices)
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Calculate total items count
  int get totalItemsCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

/// Submitting rating for an order
class OrderRatingSubmitting extends OrderState {
  const OrderRatingSubmitting(this.orderId);

  final int orderId;
}

/// Rating submitted successfully
class OrderRatingSuccess extends OrderState {
  const OrderRatingSuccess(this.orderId);

  final int orderId;
}

/// Order was already rated
class OrderAlreadyRated extends OrderState {
  const OrderAlreadyRated(this.orderId);

  final int orderId;
}

/// Reordering an order
class OrderReordering extends OrderState {
  const OrderReordering(this.orderId);

  final int orderId;
}

/// Reorder successful
class OrderReorderSuccess extends OrderState {
  const OrderReorderSuccess(this.orderId);

  final int orderId;
}

/// Error state with previous state for recovery
class OrderError extends OrderState {
  const OrderError(this.failure, this.previousState);

  final Failure failure;
  final OrderState previousState;
}

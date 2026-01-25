import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../application/providers/order_provider.dart';
import '../../application/states/order_state.dart';
import '../../domain/entities/order.dart';
import 'orders/orders.dart';

/// My Orders Screen
/// Displays user's order history with Active and Previous tabs
///
/// This screen is now modular and uses the following components:
/// - [OrdersHeader] - Header with back button and title
/// - [OrdersTabButtons] - Tab buttons for Active/Previous
/// - [OrderCard] - Individual order card with expandable details
/// - [OrderTimeline] - Order delivery progress timeline
/// - [OrdersEmptyState] - Empty state when no orders
/// - [OrdersErrorState] - Error state when loading fails
/// - [OrdersShimmerList] - Loading skeleton
class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  bool _isActiveTab = true;
  int? _expandedOrderId;

  /// Timer for auto-refresh every 30 seconds
  Timer? _pollingTimer;

  /// Polling interval for delivery status updates
  static const Duration _pollingInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    // Start polling for status updates
    _startPolling();
  }

  @override
  void dispose() {
    // Cancel polling timer when screen is disposed
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// Start polling for delivery status updates every 30 seconds
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _refreshOrders();
    });
  }

  /// Refresh orders from API
  Future<void> _refreshOrders() async {
    try {
      await ref.read(orderProvider.notifier).refreshOrders();
    } catch (e) {
      // Errors are handled by the provider and shown in the UI
    }
  }

  /// Handle tab change
  void _onTabChanged(bool isActive) {
    setState(() {
      _isActiveTab = isActive;
      _expandedOrderId = null;
    });
  }

  /// Toggle order expansion
  void _toggleOrderExpansion(int orderId) {
    setState(() {
      _expandedOrderId = _expandedOrderId == orderId ? null : orderId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          const OrdersHeader(),

          SizedBox(height: 20.h),

          // Tab buttons
          OrdersTabButtons(
            isActiveTab: _isActiveTab,
            onTabChanged: _onTabChanged,
          ),

          SizedBox(height: 20.h),

          // Orders list
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    final orderState = ref.watch(orderProvider);

    // Handle loading state with shimmer effect
    if (orderState is OrderLoading) {
      return const OrdersShimmerList();
    }

    // Handle error state
    if (orderState is OrderError) {
      return OrdersErrorState(
        failure: orderState.failure,
        onRetry: () => ref.read(orderProvider.notifier).refreshOrders(),
      );
    }

    // Handle loaded state and states that preserve orders
    // (OrderItemsLoading and OrderItemsLoaded also have orders)
    if (orderState is OrderLoaded ||
        orderState is OrderItemsLoading ||
        orderState is OrderItemsLoaded) {
      final orders = _getOrdersFromState(orderState);

      if (orders.isEmpty) {
        return OrdersEmptyState(
          isActiveTab: _isActiveTab,
          onStartShopping: () => Navigator.pop(context),
        );
      }

      return RefreshIndicator(
        onRefresh: () => ref.read(orderProvider.notifier).refreshOrders(),
        color: const Color(0xFF25A63E),
        backgroundColor: Colors.white,
        displacement: 40.h,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(
              order: order,
              isExpanded: _expandedOrderId == order.id,
              onToggleExpand: () => _toggleOrderExpansion(order.id),
            );
          },
        ),
      );
    }

    // Default state
    return const SizedBox.shrink();
  }

  /// Extract orders from various states
  List<OrderEntity> _getOrdersFromState(OrderState state) {
    if (state is OrderLoaded) {
      return _isActiveTab ? state.activeOrders : state.completedOrders;
    } else if (state is OrderItemsLoading) {
      return _isActiveTab ? state.activeOrders : state.completedOrders;
    } else if (state is OrderItemsLoaded) {
      return _isActiveTab ? state.activeOrders : state.completedOrders;
    }
    return [];
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/profile/application/providers/order_provider.dart';
import 'package:imart/features/profile/application/states/order_state.dart';
import 'package:imart/features/profile/domain/entities/order.dart';
import 'package:imart/features/profile/presentation/components/my_orders_screen.dart';
import 'package:imart/features/profile/presentation/components/pending_rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing dismissed banner order IDs
const _dismissedBannerOrdersKey = 'dismissed_banner_orders';

/// Key for storing order statuses to detect status changes
const _orderStatusCacheKey = 'order_status_cache';

/// Live order tracking banner that shows the most recent active order
/// Displays at the bottom of the home screen and navigates to order details when tapped
/// Auto-refreshes every 30 seconds to get latest status
/// Triggers rating dialog when order is delivered
class LiveOrderTrackingBanner extends ConsumerStatefulWidget {
  const LiveOrderTrackingBanner({super.key});

  @override
  ConsumerState<LiveOrderTrackingBanner> createState() =>
      _LiveOrderTrackingBannerState();
}

class _LiveOrderTrackingBannerState
    extends ConsumerState<LiveOrderTrackingBanner> {
  Timer? _refreshTimer;
  Set<int> _dismissedOrderIds = {};
  bool _isInitialized = false;

  /// Track previous statuses for ALL orders to detect transitions
  final Map<int, String> _previousOrderStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.invalidate(orderProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Load dismissed order IDs and cached statuses from shared preferences
  /// On fresh install, this starts with empty state (no stale data)
  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load dismissed orders
    final dismissed = prefs.getStringList(_dismissedBannerOrdersKey) ?? [];
    _dismissedOrderIds = dismissed.map((id) => int.tryParse(id) ?? 0).toSet();

    // Load cached order statuses
    // Note: On fresh install, this will be empty, preventing stale status transitions
    final cachedStatuses = prefs.getStringList(_orderStatusCacheKey) ?? [];
    for (final entry in cachedStatuses) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final orderId = int.tryParse(parts[0]);
        final status = parts[1];
        if (orderId != null) {
          _previousOrderStatuses[orderId] = status;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  /// Save order statuses to shared preferences for persistence across app restarts
  Future<void> _saveOrderStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = _previousOrderStatuses.entries
        .map((e) => '${e.key}:${e.value}')
        .toList();
    await prefs.setStringList(_orderStatusCacheKey, entries);
  }

  /// Dismiss the banner for a specific order
  Future<void> _dismissBannerForOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    _dismissedOrderIds.add(orderId);
    await prefs.setStringList(
      _dismissedBannerOrdersKey,
      _dismissedOrderIds.map((id) => id.toString()).toList(),
    );
    if (mounted) {
      setState(() {});
    }
  }

  /// Check if any orders just got delivered and show rating dialog
  /// This properly handles multiple orders by tracking each order's status separately
  void _checkForNewlyDeliveredOrders(OrderState state) {
    // Get all orders
    var allOrders = <OrderEntity>[];
    if (state is OrderLoaded) {
      allOrders = state.orders;
    } else if (state is OrderItemsLoading) {
      allOrders = state.orders;
    } else if (state is OrderItemsLoaded) {
      allOrders = state.orders;
    }

    if (allOrders.isEmpty) return;

    // Check each order for status transition to delivered
    for (final order in allOrders) {
      final currentStatus = order.effectiveStatus.toLowerCase();
      final previousStatus = _previousOrderStatuses[order.id]?.toLowerCase();

      // Update the tracked status
      _previousOrderStatuses[order.id] = currentStatus;

      // If this order just became delivered (and wasn't delivered before)
      if (currentStatus == 'delivered' &&
          previousStatus != null &&
          previousStatus != 'delivered') {
        // Show rating dialog for this specific order
        _showRatingDialogForOrder(order.id);

        // Only show popup for ONE newly delivered order at a time
        break;
      }
    }

    // Save updated statuses
    _saveOrderStatuses();
  }

  void _showRatingDialogForOrder(int orderId) {
    // Delay slightly to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (mounted) {
        await showRatingDialogForOrder(context, ref, orderId);
      }
    });
  }

  /// Navigate to orders and dismiss banner for completed/failed orders
  Future<void> _navigateToOrders(OrderEntity order) async {
    // Dismiss banner for failed/cancelled orders after viewing
    final status = order.effectiveStatus.toLowerCase();
    if (status == 'failed' || status == 'cancelled') {
      await _dismissBannerForOrder(order.id);
    }

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const MyOrdersScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show until initialized
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    final orderState = ref.watch(orderProvider);

    // Check for newly delivered orders (handles multiple orders correctly)
    _checkForNewlyDeliveredOrders(orderState);

    // Get trackable orders (includes failed but not delivered/cancelled)
    final trackableOrders = _getTrackableOrders(orderState);

    // Filter out dismissed orders
    final visibleOrders = trackableOrders
        .where((o) => !_dismissedOrderIds.contains(o.id))
        .toList();

    // Get the most recent order to display
    final activeOrder = visibleOrders.isNotEmpty ? visibleOrders.first : null;

    // Don't show banner if no orders
    if (activeOrder == null) {
      return const SizedBox.shrink();
    }

    // Count only truly active orders (not failed) for the badge
    // Failed orders are shown but shouldn't be counted as "active"
    final activeOrdersCount = visibleOrders.where((o) => o.isActive).length;

    return _OrderTrackingBannerContent(
      order: activeOrder,
      totalOrdersCount: activeOrdersCount,
      onTap: () => _navigateToOrders(activeOrder),
      onDismiss: () => _dismissBannerForOrder(activeOrder.id),
    );
  }

  /// Get orders that should be trackable in the banner
  /// Includes: pending, assigned, at_pickup, picked_up, out_for_delivery
  /// Failed orders: Only show if it's the LATEST order AND recent (within 24 hours)
  /// Excludes: delivered, cancelled, old failed orders
  List<OrderEntity> _getTrackableOrders(OrderState state) {
    var orders = <OrderEntity>[];

    if (state is OrderLoaded) {
      orders = state.orders;
    } else if (state is OrderItemsLoading) {
      orders = state.orders;
    } else if (state is OrderItemsLoaded) {
      orders = state.orders;
    }

    if (orders.isEmpty) return [];

    // Sort orders by creation date (newest first) to determine the latest order
    final sortedOrders = List<OrderEntity>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Get the latest order ID
    final latestOrderId = sortedOrders.first.id;

    // Time threshold for showing failed orders (24 hours)
    final failedOrderThreshold = DateTime.now().subtract(
      const Duration(hours: 24),
    );

    return orders.where((order) {
      final status = order.effectiveStatus.toLowerCase();
      final paymentStatus = order.paymentStatus?.toLowerCase() ?? '';

      // Skip refunded orders
      if (paymentStatus == 'refunded') return false;

      // Skip delivered and cancelled
      if (status == 'delivered' || status == 'cancelled') return false;

      // Special handling for failed orders
      if (status == 'failed') {
        // Only show failed if:
        // 1. It's the LATEST order, AND
        // 2. It was created/updated within the last 24 hours
        final orderDate = order.deliveryDate ?? order.createdAt;
        final isLatestOrder = order.id == latestOrderId;
        final isRecent = orderDate.isAfter(failedOrderThreshold);

        if (!isLatestOrder) {
          return false;
        }

        if (!isRecent) {
          return false;
        }

        return true;
      }

      // All other active statuses are shown
      return true;
    }).toList();
  }
}

/// Banner content widget - Compact design with status-based colors
class _OrderTrackingBannerContent extends StatelessWidget {
  const _OrderTrackingBannerContent({
    required this.order,
    required this.totalOrdersCount,
    required this.onTap,
    required this.onDismiss,
  });

  final OrderEntity order;
  final int totalOrdersCount;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  /// Check if this is a failed status
  bool _isFailedStatus(String status) {
    final statusLower = status.toLowerCase();
    return statusLower == 'failed';
  }

  /// Get status color based on delivery status
  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');

    // Failed - Red
    if (_isFailedStatus(status)) {
      return const Color(0xFFE53935);
    }

    if (statusLower == 'pending' ||
        statusLower.contains('placed') ||
        statusLower.contains('processing')) {
      return const Color(0xFFFFB800);
    }

    if (statusLower == 'assigned' || statusLower.contains('confirm')) {
      return const Color(0xFFFF8555);
    }

    if (statusLower == 'at_pickup') {
      return const Color(0xFF9C27B0);
    }

    if (statusLower == 'picked_up') {
      return const Color(0xFF2196F3);
    }

    if (statusLower == 'out_for_delivery') {
      return const Color(0xFF4ECDC4);
    }

    return const Color(0xFF25A63E);
  }

  /// Get gradient colors based on status
  List<Color> _getGradientColors(String status) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');

    // Failed - Red gradient
    if (_isFailedStatus(status)) {
      return [const Color(0xFFE53935), const Color(0xFFC62828)];
    }

    if (statusLower == 'pending' ||
        statusLower.contains('placed') ||
        statusLower.contains('processing')) {
      return [const Color(0xFFFFB800), const Color(0xFFFF9500)];
    }

    if (statusLower == 'assigned' || statusLower.contains('confirm')) {
      return [const Color(0xFFFF8555), const Color(0xFFFF6B35)];
    }

    if (statusLower == 'at_pickup') {
      return [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)];
    }

    if (statusLower == 'picked_up') {
      return [const Color(0xFF2196F3), const Color(0xFF1976D2)];
    }

    if (statusLower == 'out_for_delivery') {
      return [const Color(0xFF4ECDC4), const Color(0xFF26A69A)];
    }

    return [const Color(0xFF25A63E), const Color(0xFF1E8E33)];
  }

  /// Get user-friendly status message for live tracking
  String _getTrackingMessage(String status) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');

    // Failed
    if (statusLower == 'failed') {
      return 'Delivery failed';
    }

    if (statusLower == 'pending' ||
        statusLower.contains('placed') ||
        statusLower.contains('processing')) {
      return 'Order placed!';
    }

    if (statusLower == 'assigned' || statusLower.contains('confirm')) {
      return 'Order confirmed!';
    }

    if (statusLower == 'at_pickup') {
      return 'Getting packed!';
    }

    if (statusLower == 'picked_up') {
      return 'Picked up!';
    }

    if (statusLower == 'out_for_delivery') {
      return 'On the way!';
    }

    return 'In progress';
  }

  /// Get subtitle message
  String _getSubtitleMessage(String status, {String? deliveryNotes}) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');

    // Failed - show delivery notes if available
    if (statusLower == 'failed') {
      return deliveryNotes ?? 'Contact support for help';
    }

    if (statusLower == 'pending' ||
        statusLower.contains('placed') ||
        statusLower.contains('processing')) {
      return 'Waiting for confirmation';
    }

    if (statusLower == 'assigned' || statusLower.contains('confirm')) {
      return 'Preparing your order';
    }

    if (statusLower == 'at_pickup') {
      return 'Items being packed';
    }

    if (statusLower == 'picked_up') {
      return 'Ready for delivery';
    }

    if (statusLower == 'out_for_delivery') {
      return 'Delivery partner on the way';
    }

    return 'Track your order';
  }

  /// Get icon for current status
  IconData _getStatusIcon(String status) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');

    // Failed
    if (statusLower == 'failed') {
      return Icons.error_rounded;
    }

    if (statusLower == 'pending' ||
        statusLower.contains('placed') ||
        statusLower.contains('processing')) {
      return Icons.schedule_rounded;
    }

    if (statusLower == 'assigned' || statusLower.contains('confirm')) {
      return Icons.thumb_up_rounded;
    }

    if (statusLower == 'at_pickup') {
      return Icons.inventory_2_rounded;
    }

    if (statusLower == 'picked_up') {
      return Icons.check_circle_rounded;
    }

    if (statusLower == 'out_for_delivery') {
      return Icons.delivery_dining_rounded;
    }

    return Icons.local_shipping_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = order.effectiveStatus;
    final gradientColors = _getGradientColors(effectiveStatus);
    final statusColor = _getStatusColor(effectiveStatus);
    final isFailed = _isFailedStatus(effectiveStatus);
    final hasMultipleOrders = totalOrdersCount > 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.35),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated icon (no animation for failed status)
            if (isFailed)
              _StaticIcon(
                icon: _getStatusIcon(effectiveStatus),
                color: statusColor,
              )
            else
              _AnimatedDeliveryIcon(
                icon: _getStatusIcon(effectiveStatus),
                color: statusColor,
              ),

            SizedBox(width: 12.w),

            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _getTrackingMessage(effectiveStatus),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Multiple orders badge
                      if (hasMultipleOrders) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '+${totalOrdersCount - 1}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _getSubtitleMessage(
                      effectiveStatus,
                      deliveryNotes: order.deliveryNotes,
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Live indicator / Dismiss button + Arrow
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFailed)
                  // Dismiss button for failed orders
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  )
                else ...[
                  // Live dot indicator
                  _PulsingDot(),
                  SizedBox(width: 4.w),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Static icon for failed status
class _StaticIcon extends StatelessWidget {
  const _StaticIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 8.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Icon(icon, size: 22.sp, color: color),
    );
  }
}

/// Pulsing live dot indicator
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: _animation.value * 0.6),
                blurRadius: 4.r,
                spreadRadius: 1.r,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated delivery icon with pulsing effect
class _AnimatedDeliveryIcon extends StatefulWidget {
  const _AnimatedDeliveryIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_AnimatedDeliveryIcon> createState() => _AnimatedDeliveryIconState();
}

class _AnimatedDeliveryIconState extends State<_AnimatedDeliveryIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.4),
                blurRadius: 8.r,
                spreadRadius: 1.r,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(widget.icon, size: 22.sp, color: widget.color),
          ),
        );
      },
    );
  }
}

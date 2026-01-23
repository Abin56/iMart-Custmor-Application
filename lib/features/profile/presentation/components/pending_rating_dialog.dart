import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/profile/presentation/components/rate_order_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/providers/order_provider.dart';
import '../../application/states/order_state.dart';
import '../../domain/entities/order.dart';

/// Keys for storing popup state
const _shownPopupOrdersKey = 'shown_popup_orders';
const _dismissedRatingOrdersKey = 'dismissed_rating_orders';

/// Provider to check for pending rating
/// Returns ONLY the latest delivered order if it hasn't been rated/skipped
/// Strictly follows: Only latest order, check rating, one-time popup
final pendingRatingOrderProvider = FutureProvider<OrderEntity?>((ref) async {
  final orderState = ref.watch(orderProvider);

  // Get orders from state
  var orders = <OrderEntity>[];
  if (orderState is OrderLoaded) {
    orders = orderState.orders;
  } else if (orderState is OrderItemsLoading) {
    orders = orderState.orders;
  } else if (orderState is OrderItemsLoaded) {
    orders = orderState.orders;
  }

  if (orders.isEmpty) {
    return null;
  }

  // Find ALL delivered orders and sort by delivery/created date (newest first)
  final deliveredOrders = orders
      .where((o) => o.effectiveStatus.toLowerCase() == 'delivered')
      .toList();

  if (deliveredOrders.isEmpty) return null;

  // Sort by delivery date (or created date) - newest first
  deliveredOrders.sort((a, b) {
    final dateA = a.deliveryDate ?? a.createdAt;
    final dateB = b.deliveryDate ?? b.createdAt;
    return dateB.compareTo(dateA);
  });

  // Get ONLY the latest delivered order
  final latestOrder = deliveredOrders.first;

  // Get SharedPreferences for checking and marking
  final prefs = await SharedPreferences.getInstance();
  final shownOrderIds = prefs.getStringList(_shownPopupOrdersKey) ?? [];
  final dismissedOrderIds =
      prefs.getStringList(_dismissedRatingOrdersKey) ?? [];
  final orderIdStr = latestOrder.id.toString();

  // CONDITION 1: Check if already rated - if yes, don't show popup
  // Also mark as shown to prevent future checks
  if (latestOrder.rating != null) {
    // Mark as shown so we don't check again
    if (!shownOrderIds.contains(orderIdStr)) {
      shownOrderIds.add(orderIdStr);
      await prefs.setStringList(_shownPopupOrdersKey, shownOrderIds);
    }
    return null;
  }

  // CONDITION 2: Check if popup was already shown
  if (shownOrderIds.contains(orderIdStr)) {
    return null;
  }

  // CONDITION 3: Check if dismissed/skipped
  if (dismissedOrderIds.contains(orderIdStr)) {
    return null;
  }

  // All conditions passed - return this order for popup

  return latestOrder;
});

/// Mark an order's popup as shown (one-time only)
Future<void> markPopupShownForOrder(int orderId) async {
  final prefs = await SharedPreferences.getInstance();
  final shownOrderIds = prefs.getStringList(_shownPopupOrdersKey) ?? [];
  if (!shownOrderIds.contains(orderId.toString())) {
    shownOrderIds.add(orderId.toString());
    await prefs.setStringList(_shownPopupOrdersKey, shownOrderIds);
  }
}

/// Mark an order as dismissed (user skipped rating)
Future<void> dismissRatingForOrder(int orderId) async {
  final prefs = await SharedPreferences.getInstance();
  final dismissedOrderIds =
      prefs.getStringList(_dismissedRatingOrdersKey) ?? [];
  if (!dismissedOrderIds.contains(orderId.toString())) {
    dismissedOrderIds.add(orderId.toString());
    await prefs.setStringList(_dismissedRatingOrdersKey, dismissedOrderIds);
  }
}

/// Check if order has already been shown the popup
Future<bool> hasPopupBeenShown(int orderId) async {
  final prefs = await SharedPreferences.getInstance();
  final shownOrderIds = prefs.getStringList(_shownPopupOrdersKey) ?? [];
  return shownOrderIds.contains(orderId.toString());
}

/// Check if order was dismissed/skipped
Future<bool> wasOrderDismissed(int orderId) async {
  final prefs = await SharedPreferences.getInstance();
  final dismissedOrderIds =
      prefs.getStringList(_dismissedRatingOrdersKey) ?? [];
  return dismissedOrderIds.contains(orderId.toString());
}

/// Dialog to prompt user to rate their recent order
class PendingRatingDialog extends ConsumerStatefulWidget {
  const PendingRatingDialog({required this.order, super.key});
  final OrderEntity order;

  @override
  ConsumerState<PendingRatingDialog> createState() =>
      _PendingRatingDialogState();
}

class _PendingRatingDialogState extends ConsumerState<PendingRatingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Mark popup as shown immediately when dialog opens (one-time)
    markPopupShownForOrder(widget.order.id);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleRateNow() {
    Navigator.of(context).pop();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RateOrderBottomSheet(orderId: widget.order.id),
    );
  }

  Future<void> _handleSkip() async {
    // Mark as dismissed so it won't show again
    await dismissRatingForOrder(widget.order.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30.r,
                  offset: Offset(0, 15.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success animation container
                _DeliveredIconAnimation(),

                SizedBox(height: 20.h),

                // Title
                Text(
                  'Order Delivered!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: 8.h),

                // Order ID badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Order #${widget.order.orderId}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Description
                Text(
                  'Your order has been delivered successfully!\nHow was your experience?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 16.h),

                // Order total
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF25A63E).withValues(alpha: 0.1),
                        const Color(0xFF25A63E).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFF25A63E).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 20.sp,
                        color: const Color(0xFF25A63E),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Total: ${widget.order.formattedTotal}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF25A63E),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // Star preview row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Icon(
                        Icons.star_rounded,
                        size: 28.sp,
                        color: Colors.amber.shade300,
                      ),
                    );
                  }),
                ),

                SizedBox(height: 24.h),

                // Rate Now button
                GestureDetector(
                  onTap: _handleRateNow,
                  child: Container(
                    width: double.infinity,
                    height: 54.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF25A63E), Color(0xFF1B7A43)],
                      ),
                      borderRadius: BorderRadius.circular(27.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25A63E).withValues(alpha: 0.4),
                          blurRadius: 20.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Rate Your Experience',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Skip button
                TextButton(
                  onPressed: _handleSkip,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated delivered icon
class _DeliveredIconAnimation extends StatefulWidget {
  @override
  State<_DeliveredIconAnimation> createState() =>
      _DeliveredIconAnimationState();
}

class _DeliveredIconAnimationState extends State<_DeliveredIconAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 90.w,
            height: 90.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF25A63E), Color(0xFF1B7A43)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle decoration
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2.w,
                    ),
                  ),
                ),
                // Check icon with animation
                Opacity(
                  opacity: _checkAnimation.value,
                  child: Icon(
                    Icons.check_rounded,
                    size: 48.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Show the pending rating dialog if there's an eligible order
/// Only shows for the LATEST delivered order that hasn't been rated/skipped
Future<void> showPendingRatingDialogIfNeeded(
  BuildContext context,
  WidgetRef ref,
) async {
  final pendingOrder = await ref.read(pendingRatingOrderProvider.future);

  if (pendingOrder == null) {
    return;
  }

  // Double-check rating status (sync with server state)
  if (pendingOrder.rating != null) {
    return;
  }

  if (context.mounted) {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PendingRatingDialog(order: pendingOrder),
    );
  }
}

/// Show the pending rating dialog for a specific order (when status changes)
/// Only shows if this order is the LATEST delivered and not rated/skipped
Future<void> showRatingDialogForOrder(
  BuildContext context,
  WidgetRef ref,
  int orderId,
) async {
  // Get the order from state
  final orderState = ref.read(orderProvider);
  var orders = <OrderEntity>[];
  if (orderState is OrderLoaded) {
    orders = orderState.orders;
  } else if (orderState is OrderItemsLoading) {
    orders = orderState.orders;
  } else if (orderState is OrderItemsLoaded) {
    orders = orderState.orders;
  }

  // Find all delivered orders
  final deliveredOrders = orders
      .where((o) => o.effectiveStatus.toLowerCase() == 'delivered')
      .toList();

  if (deliveredOrders.isEmpty) {
    return;
  }

  // Sort by delivery date - newest first
  deliveredOrders.sort((a, b) {
    final dateA = a.deliveryDate ?? a.createdAt;
    final dateB = b.deliveryDate ?? b.createdAt;
    return dateB.compareTo(dateA);
  });

  // Check if this order is THE LATEST delivered order
  final latestOrder = deliveredOrders.first;
  if (latestOrder.id != orderId) {
    return;
  }

  // CONDITION 1: Check if already rated
  if (latestOrder.rating != null) {
    await markPopupShownForOrder(orderId);
    return;
  }

  // CONDITION 2: Check if popup was already shown
  final alreadyShown = await hasPopupBeenShown(orderId);
  if (alreadyShown) {
    return;
  }

  // CONDITION 3: Check if dismissed/skipped
  final wasDismissed = await wasOrderDismissed(orderId);
  if (wasDismissed) {
    return;
  }

  // All conditions passed - show the popup
  if (context.mounted) {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PendingRatingDialog(order: latestOrder),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/app/core/application/providers/admin_phone_provider.dart';
import 'package:imart/features/cart/application/controllers/cart_controller.dart';
import 'package:imart/features/navigation/main_navbar.dart';
import 'package:imart/features/profile/application/providers/order_provider.dart';
import 'package:imart/features/profile/domain/entities/order.dart';
import 'package:imart/features/profile/presentation/components/order_items_bottom_sheet.dart';
import 'package:imart/features/profile/presentation/components/rate_order_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_status_utils.dart';
import 'order_timeline.dart';

/// Order card widget displaying order summary and expanded details
class OrderCard extends ConsumerStatefulWidget {
  const OrderCard({
    required this.order,
    required this.isExpanded,
    required this.onToggleExpand,
    super.key,
  });

  final OrderEntity order;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  @override
  ConsumerState<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<OrderCard> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final effectiveStatus = order.effectiveStatus;
    final statusInfo = OrderStatusUtils.getStatusInfo(
      effectiveStatus,
      paymentStatus: order.paymentStatus,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order summary
          _OrderSummary(
            order: order,
            statusInfo: statusInfo,
            isExpanded: widget.isExpanded,
            onTap: widget.onToggleExpand,
          ),

          // Expanded content
          if (widget.isExpanded)
            _ExpandedContent(order: order, onMakePhoneCall: _makePhoneCall),
        ],
      ),
    );
  }

  /// Make phone call to admin
  Future<void> _makePhoneCall() async {
    try {
      // Get admin phone number from provider
      final phoneNumber = await ref
          .read(adminPhoneProvider.notifier)
          .getPhoneNumber();

      // Remove spaces and ensure proper format
      final cleanedNumber = phoneNumber.replaceAll(' ', '');
      final uri = Uri.parse('tel:$cleanedNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open phone dialer'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to make call'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }
}

/// Order summary section (always visible)
class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.order,
    required this.statusInfo,
    required this.isExpanded,
    required this.onTap,
  });

  final OrderEntity order;
  final StatusInfo statusInfo;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Product image placeholder (order icon)
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusInfo.color.withValues(alpha: 0.15),
                    statusInfo.color.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                statusInfo.icon,
                size: 32.sp,
                color: statusInfo.color,
              ),
            ),

            SizedBox(width: 14.w),

            // Order details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Total Amount row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.orderId}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        order.formattedTotal,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF25A63E),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Items button, status, and rated badge
                  Row(
                    children: [
                      // View Items button
                      _ViewItemsButton(orderId: order.id),

                      SizedBox(width: 10.w),

                      // Bullet point
                      Container(
                        width: 4.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),

                      SizedBox(width: 5.w),

                      // Status
                      Text(
                        statusInfo.label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: statusInfo.color,
                        ),
                      ),

                      // Rated badge (if order has rating)
                      if (order.rating != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFA500,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(
                                0xFFFFA500,
                              ).withValues(alpha: 0.4),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 12.sp,
                                color: const Color(0xFFFFA500),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                '${order.rating}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE67E00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Expand arrow
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 24.sp,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}

/// View Items button widget
class _ViewItemsButton extends StatelessWidget {
  const _ViewItemsButton({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => OrderItemsBottomSheet(orderId: orderId),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFF25A63E).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View Items',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF25A63E),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 10.sp,
              color: const Color(0xFF25A63E),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expanded content section (action buttons and timeline)
class _ExpandedContent extends ConsumerWidget {
  const _ExpandedContent({required this.order, required this.onMakePhoneCall});

  final OrderEntity order;
  final VoidCallback onMakePhoneCall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRating = order.rating != null;

    return Column(
      children: [
        // Show existing rating if order has been rated
        if (hasRating) ...[
          _ExistingRatingDisplay(
            rating: order.rating!,
            review: order.ratingReview,
          ),
          Divider(height: 1.h, thickness: 1.h, color: Colors.grey.shade300),
        ],

        // Action buttons
        _ActionButtons(order: order, onMakePhoneCall: onMakePhoneCall),

        // Divider
        Divider(height: 1.h, thickness: 1.h, color: Colors.grey.shade300),

        // Order timeline
        OrderTimeline(
          status: order.effectiveStatus,
          createdAt: order.createdAt,
          paymentStatus: order.paymentStatus,
          deliveryNotes: order.deliveryNotes,
        ),
      ],
    );
  }
}

/// Widget to display existing rating and review
class _ExistingRatingDisplay extends StatelessWidget {
  const _ExistingRatingDisplay({required this.rating, this.review});

  final int rating;
  final String? review;

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFA500).withValues(alpha: 0.1),
            const Color(0xFFFFD700).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFFA500).withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "Your Rating" label
          Row(
            children: [
              Icon(
                Icons.rate_review_rounded,
                size: 18.sp,
                color: const Color(0xFFFFA500),
              ),
              SizedBox(width: 8.w),
              Text(
                'Your Rating',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Star rating row
          Row(
            children: [
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 24.sp,
                      color: index < rating
                          ? const Color(0xFFFFA500)
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),

              SizedBox(width: 12.w),

              // Rating text
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA500).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _getRatingText(rating),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE67E00),
                  ),
                ),
              ),
            ],
          ),

          // Review text (if available)
          if (review != null && review!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200, width: 1.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 16.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Your Review',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    review!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Action buttons (Rate, Reorder, Call)
class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.order, required this.onMakePhoneCall});

  final OrderEntity order;
  final VoidCallback onMakePhoneCall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
      child: Row(
        children: [
          // Rate button (only show if order can be rated)
          if (order.canBeRated) ...[
            Expanded(child: _RateButton(orderId: order.id)),
            SizedBox(width: 12.w),
          ],

          // Reorder button
          Expanded(child: _ReorderButton(orderId: order.id)),

          SizedBox(width: 12.w),

          // Call button
          Expanded(child: _CallButton(onTap: onMakePhoneCall)),
        ],
      ),
    );
  }
}

/// Rate button widget - User-friendly design with star icon and gradient
class _RateButton extends StatelessWidget {
  const _RateButton({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RateOrderBottomSheet(orderId: orderId),
        );
      },
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFA500), // Orange
              Color(0xFFFF8C00), // Dark Orange
            ],
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA500).withValues(alpha: 0.4),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, size: 18.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              'Rate',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reorder button widget
class _ReorderButton extends ConsumerStatefulWidget {
  const _ReorderButton({required this.orderId});

  final int orderId;

  @override
  ConsumerState<_ReorderButton> createState() => _ReorderButtonState();
}

class _ReorderButtonState extends ConsumerState<_ReorderButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleReorder(context, ref),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFF9AE6B4), // Light green
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25A63E).withValues(alpha: 0.2),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Reorder',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D5C2E),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleReorder(BuildContext context, WidgetRef ref) async {
    print('🔄 [REORDER] Starting reorder process for order ${widget.orderId}');

    // Capture the navigator and providers before any async operations
    final navigator = Navigator.of(context, rootNavigator: true);
    final orderNotifier = ref.read(orderProvider.notifier);
    final cartController = ref.read(cartControllerProvider.notifier);
    print('🔍 [REORDER] Navigator and providers captured');

    // Show loading dialog with progress
    final progressNotifier = ValueNotifier<double>(0.0);

    print('📱 [REORDER] Attempting to show progress dialog...');
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular progress with percentage
                  SizedBox(
                    width: 150.w,
                    height: 150.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ValueListenableBuilder<double>(
                          valueListenable: progressNotifier,
                          builder: (context, progress, child) {
                            return CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 1.w,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF25A63E),
                              ),
                              backgroundColor: Colors.grey.shade200,
                            );
                          },
                        ),
                        ValueListenableBuilder<double>(
                          valueListenable: progressNotifier,
                          builder: (context, progress, child) {
                            return Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF25A63E),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Adding items to cart...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please wait',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    print('✅ [REORDER] Progress dialog shown');

    print('🌐 [REORDER] Calling reorder API...');
    final success = await orderNotifier.reorderWithProgress(
          orderId: widget.orderId,
          onProgress: (current, total) {
            progressNotifier.value = current / total;
            print('📊 [REORDER] Progress: $current/$total (${(current/total * 100).toInt()}%)');
          },
        );
    print('🌐 [REORDER] API call completed. Success: $success');

    // Close loading dialog using the captured navigator
    print('🚪 [REORDER] Closing dialog using captured navigator...');
    try {
      navigator.pop();
      print('✅ [REORDER] Dialog closed successfully');
    } catch (e) {
      print('❌ [REORDER] Failed to close dialog: $e');
    }

    progressNotifier.dispose();
    print('🧹 [REORDER] Progress notifier disposed');

    if (success) {
      print('✅ [REORDER] Reorder successful. Proceeding with cart refresh and navigation...');

      // Refresh cart data FIRST (the reorder API already added items to cart)
      print('🛒 [REORDER] Refreshing cart data...');
      try {
        // Use unawaited to refresh in background without blocking navigation
        unawaited(
          cartController.loadCart(forceRefresh: true).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⚠️ [REORDER] Cart refresh timed out after 5 seconds');
            },
          ).then((_) {
            print('✅ [REORDER] Cart data refreshed');
          }).catchError((e) {
            print('⚠️ [REORDER] Cart refresh error: $e');
          }),
        );
      } catch (e) {
        print('⚠️ [REORDER] Cart refresh error: $e');
      }

      // Close the profile drawer if it's open
      print('🚪 [REORDER] Attempting to close profile drawer...');
      try {
        navigator.pop(); // Close the drawer
        print('✅ [REORDER] Profile drawer closed');
      } catch (e) {
        print('⚠️ [REORDER] Could not close drawer (may already be closed): $e');
      }

      // Small delay to let drawer close animation complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate to cart tab (index 3)
      print('🧭 [REORDER] Attempting to navigate to cart tab (index 3)...');

      // Get the navigation shell state fresh (not captured earlier)
      final navigationShell = MainNavigationShell.globalKey.currentState;
      print('🔍 [REORDER] NavigationShell state: ${navigationShell != null ? "Found" : "NULL"}');

      if (navigationShell != null) {
        print('🧭 [REORDER] Calling navigateToTab(3)...');
        try {
          navigationShell.navigateToTab(3);
          print('✅ [REORDER] Navigation to cart tab completed');
        } catch (e) {
          print('❌ [REORDER] Navigation error: $e');
        }
      } else {
        print('❌ [REORDER] NavigationShell is null! Cannot navigate to cart.');
      }

      print('🎉 [REORDER] Reorder process completed successfully!');

    } else {
      print('❌ [REORDER] Reorder failed. Items may be out of stock.');
    }
  }
}

/// Call button widget
class _CallButton extends StatelessWidget {
  const _CallButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.blue.shade400, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.call, size: 18.sp, color: Colors.blue.shade700),
              SizedBox(width: 6.w),
              Text(
                'Call',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

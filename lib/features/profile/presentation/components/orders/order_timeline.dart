import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'order_status_utils.dart';

/// Order timeline widget showing delivery progress
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({
    required this.status,
    required this.createdAt,
    this.paymentStatus,
    this.deliveryNotes,
    super.key,
  });

  final String status;
  final DateTime createdAt;
  final String? paymentStatus;
  final String? deliveryNotes;

  @override
  Widget build(BuildContext context) {
    final currentStep = OrderStatusUtils.getStatusStep(
      status,
      paymentStatus: paymentStatus,
    );
    final isCancelled = status.toLowerCase().contains('cancel');
    final isRefunded = paymentStatus?.toLowerCase() == 'refunded';

    // If refunded, show refunded timeline
    if (isRefunded) {
      return _buildRefundedTimeline();
    }

    // If cancelled, show cancelled timeline
    if (isCancelled) {
      return _buildCancelledTimeline();
    }

    // Check for failed delivery
    final isFailed = status.toLowerCase() == 'failed';
    if (isFailed) {
      return _buildFailedTimeline();
    }

    // Normal order timeline (6 steps)
    return _buildNormalTimeline(currentStep);
  }

  Widget _buildRefundedTimeline() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _TimelineItem(
            title: 'Order Placed',
            date: DateFormatUtils.formatTimelineDate(createdAt),
            time: DateFormatUtils.formatTimelineTime(createdAt),
            isCompleted: true,
          ),
          const _TimelineItem(
            title: 'Payment Refunded',
            date: 'Amount returned to your account',
            time: '',
            isCompleted: true,
            isRefunded: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledTimeline() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _TimelineItem(
            title: 'Order Placed',
            date: DateFormatUtils.formatTimelineDate(createdAt),
            time: DateFormatUtils.formatTimelineTime(createdAt),
            isCompleted: true,
          ),
          _TimelineItem(
            title: 'Order Cancelled',
            date: DateFormatUtils.formatTimelineDate(createdAt),
            time: '',
            isCompleted: true,
            isCancelled: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFailedTimeline() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _TimelineItem(
            title: 'Order Placed',
            date: DateFormatUtils.formatTimelineDate(createdAt),
            time: DateFormatUtils.formatTimelineTime(createdAt),
            isCompleted: true,
          ),
          _TimelineItem(
            title: 'Delivery Failed',
            date: deliveryNotes ?? 'Unable to deliver',
            time: '',
            isCompleted: true,
            isCancelled: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNormalTimeline(int currentStep) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Step 0: Order Placed
          _TimelineItem(
            title: 'Order Placed',
            date: DateFormatUtils.formatTimelineDate(createdAt),
            time: DateFormatUtils.formatTimelineTime(createdAt),
            isCompleted: currentStep >= 0,
            icon: Icons.receipt_long_outlined,
          ),
          // Step 1: Order Confirmed
          _TimelineItem(
            title: 'Order Confirmed',
            date: currentStep >= 1 ? 'Partner assigned' : 'Pending',
            time: '',
            isCompleted: currentStep >= 1,
            icon: Icons.assignment_turned_in_outlined,
          ),
          // Step 2: Getting Packed
          _TimelineItem(
            title: 'Getting Packed',
            date: currentStep >= 2 ? 'At pickup location' : 'Pending',
            time: '',
            isCompleted: currentStep >= 2,
            icon: Icons.inventory_outlined,
          ),
          // Step 3: Picked Up
          _TimelineItem(
            title: 'Picked Up',
            date: currentStep >= 3 ? 'Order collected' : 'Pending',
            time: '',
            isCompleted: currentStep >= 3,
            icon: Icons.inventory_2_outlined,
          ),
          // Step 4: Out for Delivery
          _TimelineItem(
            title: 'Out for Delivery',
            date: currentStep >= 4 ? 'On the way' : 'Pending',
            time: '',
            isCompleted: currentStep >= 4,
            icon: Icons.local_shipping_outlined,
          ),
          // Step 5: Delivered
          _TimelineItem(
            title: 'Delivered',
            date: currentStep >= 5 ? (deliveryNotes ?? 'Completed') : 'Pending',
            time: '',
            isCompleted: currentStep >= 5,
            isLast: true,
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }
}

/// Individual timeline item widget
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.date,
    required this.time,
    required this.isCompleted,
    this.isLast = false,
    this.isCancelled = false,
    this.isRefunded = false,
    this.icon,
  });

  final String title;
  final String date;
  final String time;
  final bool isCompleted;
  final bool isLast;
  final bool isCancelled;
  final bool isRefunded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    final Color indicatorColor;
    final Color indicatorBorderColor;
    final Color titleColor;
    final Color iconColor;

    if (isRefunded) {
      indicatorColor = Colors.orange.shade700;
      indicatorBorderColor = Colors.orange.shade700;
      titleColor = Colors.orange.shade700;
      iconColor = Colors.orange.shade700;
    } else if (isCancelled) {
      indicatorColor = Colors.red.shade600;
      indicatorBorderColor = Colors.red.shade600;
      titleColor = Colors.red.shade600;
      iconColor = Colors.red.shade600;
    } else if (isCompleted) {
      indicatorColor = const Color(0xFF25A63E);
      indicatorBorderColor = const Color(0xFF25A63E);
      titleColor = Colors.black;
      iconColor = const Color(0xFF25A63E);
    } else {
      indicatorColor = Colors.white;
      indicatorBorderColor = Colors.grey.shade400;
      titleColor = Colors.grey.shade500;
      iconColor = Colors.grey.shade400;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator with icon
        Column(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: isCompleted || isCancelled || isRefunded
                    ? indicatorColor.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || isCancelled || isRefunded
                      ? indicatorBorderColor
                      : Colors.grey.shade300,
                  width: 2.w,
                ),
              ),
              child: Icon(
                isRefunded
                    ? Icons.currency_exchange
                    : (isCancelled ? Icons.close : (icon ?? Icons.check)),
                size: 14.sp,
                color: isCompleted || isCancelled || isRefunded
                    ? iconColor
                    : Colors.grey.shade400,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 36.h,
                color: isCompleted
                    ? const Color(0xFF25A63E).withValues(alpha: 0.3)
                    : Colors.grey.shade300,
              ),
          ],
        ),

        SizedBox(width: 12.w),

        // Timeline content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                if (date.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: isRefunded
                          ? Colors.orange.shade400
                          : (isCancelled
                                ? Colors.red.shade400
                                : Colors.grey.shade600),
                    ),
                  ),
                ],
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

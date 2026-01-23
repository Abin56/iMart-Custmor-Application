import 'package:flutter/material.dart';

/// Status information record containing icon, color, label, and badge icon
typedef StatusInfo = ({
  IconData icon,
  Color color,
  String label,
  IconData badgeIcon,
});

/// Utility class for order status related operations
class OrderStatusUtils {
  OrderStatusUtils._();

  /// Get status information (icon, color, label, badge icon)
  /// If paymentStatus is "Refunded", show refunded status regardless of order status
  ///
  /// Delivery Status Flow (from API):
  /// pending -> assigned -> at_pickup -> picked_up -> out_for_delivery -> delivered
  static StatusInfo getStatusInfo(String status, {String? paymentStatus}) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');
    final paymentStatusLower = paymentStatus?.toLowerCase() ?? '';

    // Check if payment is refunded - show refunded status
    if (paymentStatusLower == 'refunded') {
      return (
        icon: Icons.currency_exchange_outlined,
        color: Colors.orange.shade700,
        label: 'Refunded',
        badgeIcon: Icons.currency_exchange_rounded,
      );
    }

    // Cancelled or Failed
    if (statusLower.contains('cancel') || statusLower == 'failed') {
      return (
        icon: Icons.cancel_outlined,
        color: Colors.red.shade600,
        label: statusLower == 'failed' ? 'Failed' : 'Cancelled',
        badgeIcon: Icons.close_rounded,
      );
    }

    // Delivered
    if (statusLower == 'delivered' || statusLower == 'completed') {
      return (
        icon: Icons.check_circle_outline,
        color: const Color(0xFF25A63E),
        label: 'Delivered',
        badgeIcon: Icons.check_rounded,
      );
    }

    // Out for Delivery
    if (statusLower == 'out_for_delivery' ||
        statusLower.contains('out_for_delivery')) {
      return (
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFF4ECDC4),
        label: 'Out for Delivery',
        badgeIcon: Icons.local_shipping_rounded,
      );
    }

    // Picked Up
    if (statusLower == 'picked_up') {
      return (
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF2196F3),
        label: 'Picked Up',
        badgeIcon: Icons.inventory_2_rounded,
      );
    }

    // At Pickup / Getting Packed
    if (statusLower == 'at_pickup') {
      return (
        icon: Icons.inventory_outlined,
        color: const Color(0xFF9C27B0),
        label: 'Getting Packed',
        badgeIcon: Icons.inventory_rounded,
      );
    }

    // Assigned / Order Confirmed
    if (statusLower == 'assigned' || statusLower.contains('confirm')) {
      return (
        icon: Icons.assignment_turned_in_outlined,
        color: const Color(0xFFFF8555),
        label: 'Order Confirmed',
        badgeIcon: Icons.assignment_turned_in_rounded,
      );
    }

    // Pending / Order Placed
    if (statusLower == 'pending' ||
        statusLower.contains('placed') ||
        statusLower.contains('processing')) {
      return (
        icon: Icons.schedule_outlined,
        color: const Color(0xFFFFB800),
        label: 'Pending',
        badgeIcon: Icons.schedule_rounded,
      );
    }

    // Default
    return (
      icon: Icons.shopping_bag_outlined,
      color: Colors.grey.shade600,
      label: status,
      badgeIcon: Icons.info_outline_rounded,
    );
  }

  /// Get the step index for a given status (0-5)
  /// New Delivery Status Flow:
  /// 0 = Order Placed (pending)
  /// 1 = Order Confirmed (assigned)
  /// 2 = Getting Packed (at_pickup)
  /// 3 = Picked Up (picked_up)
  /// 4 = Out for Delivery (out_for_delivery)
  /// 5 = Delivered (delivered)
  /// -1 = Refunded (special case)
  /// -2 = Failed (special case)
  static int getStatusStep(String status, {String? paymentStatus}) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');
    final paymentStatusLower = paymentStatus?.toLowerCase() ?? '';

    // If refunded, return -1 to indicate special refunded state
    if (paymentStatusLower == 'refunded') {
      return -1;
    }

    // Failed delivery
    if (statusLower == 'failed') {
      return -2;
    }

    // Step 5: Delivered
    if (statusLower == 'delivered' || statusLower == 'completed') {
      return 5;
    }

    // Step 4: Out for Delivery
    if (statusLower == 'out_for_delivery') {
      return 4;
    }

    // Step 3: Picked Up
    if (statusLower == 'picked_up') {
      return 3;
    }

    // Step 2: Getting Packed (at_pickup)
    if (statusLower == 'at_pickup') {
      return 2;
    }

    // Step 1: Order Confirmed (assigned)
    if (statusLower == 'assigned' || statusLower.contains('confirm')) {
      return 1;
    }

    // Step 0: Order Placed (pending, processing, placed)
    return 0;
  }

  /// Get status color based on effective status
  static Color getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('cancel') || statusLower == 'failed') {
      return Colors.red.shade600;
    } else if (statusLower == 'delivered') {
      return const Color(0xFF25A63E);
    }
    return Colors.black;
  }
}

/// Utility class for date formatting
class DateFormatUtils {
  DateFormatUtils._();

  /// Format relative date (e.g., "2 days ago", "Just now")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? 'Yesterday'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Format date for timeline display
  static String formatTimelineDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month ${date.year}';
  }

  /// Format time for timeline display
  static String formatTimelineTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

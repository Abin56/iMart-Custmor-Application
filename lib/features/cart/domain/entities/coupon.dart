import 'package:equatable/equatable.dart';

/// Coupon entity
/// Represents a discount coupon/voucher that can be applied to checkout
///
/// Matches backend API structure from /api/order/v1/coupons/
/// Contains validation properties for client-side checks:
/// - [status]: Whether coupon is currently active (backend field)
/// - [isAtLimit]: Whether coupon has reached usage limit
/// - [isAvailable]: Combined check (status && isValid && !isAtLimit)
class Coupon extends Equatable {
  const Coupon({
    required this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.limit,
    required this.status,
    required this.usage,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name; // Can be used as coupon code
  final String description;
  final String discountPercentage; // Stored as string from API (e.g., "20.5")
  final int limit; // Maximum number of times coupon can be used
  final bool status; // Whether coupon is active
  final int usage; // Current usage count
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed properties

  /// Get discount percentage as double
  double get discountPercentageAsDouble =>
      double.tryParse(discountPercentage) ?? 0.0;

  /// Get formatted discount text (e.g., "20% OFF")
  String get formattedDiscount {
    return '${discountPercentageAsDouble.toStringAsFixed(0)}% OFF';
  }

  /// Check if coupon is currently valid (within date range)
  bool get isValid {
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return false;
    }
    if (now.isAfter(endDate)) {
      return false;
    }
    return true;
  }

  /// Check if coupon has expired
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Check if coupon is not yet active
  bool get isNotYetActive {
    return DateTime.now().isBefore(startDate);
  }

  /// Client-side validation: Check if coupon has reached usage limit
  bool get isAtLimit {
    return usage >= limit;
  }

  /// Client-side validation: Check if coupon is available for use
  /// (active, within date range, and not at usage limit)
  bool get isAvailable {
    return status && isValid && !isAtLimit;
  }

  /// Get formatted validity period (e.g., "Valid till 31 Dec 2026")
  String get validityDisplayText {
    try {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return 'Valid till ${endDate.day} ${months[endDate.month - 1]} ${endDate.year}';
    } catch (e) {
      return 'Check validity';
    }
  }

  /// Calculate discount amount for a given cart total
  /// Returns the discount amount (not the final price)
  double calculateDiscount(double cartTotal) {
    // Calculate percentage discount
    final discount = (cartTotal * discountPercentageAsDouble) / 100;
    return discount;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    discountPercentage,
    limit,
    status,
    usage,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  ];

  Coupon copyWith({
    int? id,
    String? name,
    String? description,
    String? discountPercentage,
    int? limit,
    bool? status,
    int? usage,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      limit: limit ?? this.limit,
      status: status ?? this.status,
      usage: usage ?? this.usage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

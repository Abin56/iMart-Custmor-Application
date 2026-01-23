import 'package:equatable/equatable.dart';

/// Order entity representing a user's order
class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.itemCount,
    this.deliveryDate,
    this.rating,
    this.ratingReview,
    this.paymentStatus,
    this.userName,
    this.deliveryStatus,
    this.deliveryNotes,
  });

  factory OrderEntity.fromMap(Map<String, dynamic> map) {
    // Handle order_id - API may return 'order_id' or we use 'id' as fallback
    final orderId = map['order_id'] as String? ?? map['id'].toString();

    // Handle total amount - API may return 'total_amount' or 'total'
    final totalAmount = map['total_amount'] ?? map['total'];

    // Handle item count - API may return 'item_count', 'orderlines_count', or default to 0
    final itemCount =
        map['item_count'] as int? ?? map['orderlines_count'] as int? ?? 0;

    // Handle rating - may be an int or a map with 'stars' and 'body' fields
    int? rating;
    String? ratingReview;
    if (map['rating'] is int) {
      rating = map['rating'] as int;
    } else if (map['rating'] is Map<String, dynamic>) {
      final ratingMap = map['rating'] as Map<String, dynamic>;
      rating = ratingMap['stars'] as int?;
      ratingReview = ratingMap['body'] as String?;
    }

    final statusValue = map['status'] as String? ?? 'pending';
    // final paymentStatusValue = map['payment_status'] as String?;
    final deliveryStatusValue = map['delivery_status'] as String?;
    final deliveryNotesValue = map['delivery_notes'] as String?;

    return OrderEntity(
      id: map['id'] as int,
      orderId: orderId,
      status: statusValue,
      totalAmount: _parseAmount(totalAmount),
      createdAt: DateTime.parse(map['created_at'] as String),
      itemCount: itemCount,
      deliveryDate: map['delivery_date'] != null
          ? DateTime.parse(map['delivery_date'] as String)
          : null,
      rating: rating,
      ratingReview: ratingReview,
      paymentStatus: map['payment_status'] as String?,
      userName: map['user_name'] as String?,
      deliveryStatus: deliveryStatusValue,
      deliveryNotes: deliveryNotesValue,
    );
  }

  final int id;
  final String orderId;
  final String status; // pending, processing, shipped, delivered, cancelled
  final double totalAmount;
  final DateTime createdAt;
  final int itemCount;
  final DateTime? deliveryDate;
  final int? rating; // Star rating (1-5)
  final String? ratingReview; // Review text from the rating
  final String? paymentStatus; // Paid, Refunded, Pending, etc.
  final String? userName;
  final String?
  deliveryStatus; // pending, assigned, at_pickup, picked_up, out_for_delivery, delivered, failed
  final String?
  deliveryNotes; // Notes from delivery driver (e.g., "Customer not available")

  /// Get the effective status for UI display
  /// Prioritizes delivery status over order status
  String get effectiveStatus => deliveryStatus ?? status;

  /// Parse amount from String or num
  static double _parseAmount(dynamic amount) {
    if (amount is String) {
      return double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      return amount.toDouble();
    }
    return 0.0;
  }

  /// Check if order is active (not delivered, cancelled, failed, or refunded)
  bool get isActive {
    final statusLower = effectiveStatus.toLowerCase();
    final paymentStatusLower = paymentStatus?.toLowerCase() ?? '';

    // Refunded orders are not active
    if (paymentStatusLower == 'refunded') {
      return false;
    }

    return statusLower != 'delivered' &&
        statusLower != 'cancelled' &&
        statusLower != 'failed';
  }

  /// Check if order can be rated
  bool get canBeRated {
    return effectiveStatus.toLowerCase() == 'delivered' && rating == null;
  }

  /// Format total amount with currency
  String get formattedTotal => '₹${totalAmount.toStringAsFixed(2)}';

  /// Create a copy with updated delivery status
  OrderEntity copyWith({
    int? id,
    String? orderId,
    String? status,
    double? totalAmount,
    DateTime? createdAt,
    int? itemCount,
    DateTime? deliveryDate,
    int? rating,
    String? ratingReview,
    String? paymentStatus,
    String? userName,
    String? deliveryStatus,
    String? deliveryNotes,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      itemCount: itemCount ?? this.itemCount,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      rating: rating ?? this.rating,
      ratingReview: ratingReview ?? this.ratingReview,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      userName: userName ?? this.userName,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'status': status,
      'total_amount': totalAmount.toString(),
      'created_at': createdAt.toIso8601String(),
      'item_count': itemCount,
      'delivery_date': deliveryDate?.toIso8601String(),
      'rating': rating != null
          ? {'stars': rating, if (ratingReview != null) 'body': ratingReview}
          : null,
      'payment_status': paymentStatus,
      'user_name': userName,
      'delivery_status': deliveryStatus,
      'delivery_notes': deliveryNotes,
    };
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    status,
    totalAmount,
    createdAt,
    itemCount,
    deliveryDate,
    rating,
    ratingReview,
    paymentStatus,
    userName,
    deliveryStatus,
    deliveryNotes,
  ];
}

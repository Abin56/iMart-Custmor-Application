import 'package:equatable/equatable.dart';

/// OrderRating entity for submitting order ratings
class OrderRatingEntity extends Equatable {
  const OrderRatingEntity({
    required this.orderId,
    required this.rating,
    this.review,
  });

  /// Create from API response
  /// API returns: { "id": 0, "user": 0, "order": 0, "stars": 5, "body": "string", ... }
  factory OrderRatingEntity.fromMap(Map<String, dynamic> map) {
    return OrderRatingEntity(
      orderId: map['order'] as int? ?? map['order_id'] as int,
      rating: map['stars'] as int? ?? map['rating'] as int,
      review: map['body'] as String? ?? map['review'] as String?,
    );
  }

  final int orderId;
  final int rating; // 1-5
  final String? review;

  /// Validate rating is within range
  bool get isValidRating => rating >= 1 && rating <= 5;

  /// Get rating text description
  String get ratingText {
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
        return 'Unknown';
    }
  }

  /// Convert to map for API request
  /// API expects: { "stars": 5, "body": "string" }
  Map<String, dynamic> toMap() {
    return {
      'stars': rating,
      if (review != null && review!.isNotEmpty) 'body': review,
    };
  }

  @override
  List<Object?> get props => [orderId, rating, review];
}

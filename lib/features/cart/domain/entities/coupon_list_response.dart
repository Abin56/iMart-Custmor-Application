import 'package:equatable/equatable.dart';
import 'package:imart/features/cart/domain/entities/coupon.dart';

/// Coupon list response entity for paginated API responses
///
/// Contains pagination metadata from backend API:
/// - [count]: Total number of coupons available
/// - [next]: URL for next page (null if last page)
/// - [previous]: URL for previous page (null if first page)
/// - [results]: List of coupons for current page
class CouponListResponse extends Equatable {
  const CouponListResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  /// Total count of coupons in the system
  final int count;

  /// URL for next page of results (null if no more pages)
  final String? next;

  /// URL for previous page of results (null if first page)
  final String? previous;

  /// List of coupons in current page
  final List<Coupon> results;

  /// Check if there are more pages available
  bool get hasNextPage => next != null;

  /// Check if there is a previous page
  bool get hasPreviousPage => previous != null;

  /// Check if this is the first page
  bool get isFirstPage => previous == null;

  /// Check if this is the last page
  bool get isLastPage => next == null;

  /// Get only active and available coupons from results
  List<Coupon> get availableCoupons {
    return results.where((coupon) => coupon.isAvailable).toList();
  }

  /// Get only expired coupons from results
  List<Coupon> get expiredCoupons {
    return results.where((coupon) => coupon.isExpired).toList();
  }

  /// Get only inactive coupons from results
  List<Coupon> get inactiveCoupons {
    return results.where((coupon) => !coupon.status).toList();
  }

  @override
  List<Object?> get props => [count, next, previous, results];

  CouponListResponse copyWith({
    int? count,
    String? next,
    String? previous,
    List<Coupon>? results,
  }) {
    return CouponListResponse(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }
}

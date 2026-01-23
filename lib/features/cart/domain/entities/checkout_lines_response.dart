import 'package:equatable/equatable.dart';

import 'checkout_line.dart';

/// Checkout lines response entity
/// Wraps the list of cart items with pagination info
class CheckoutLinesResponse extends Equatable {
  const CheckoutLinesResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<CheckoutLine> results;

  // Aggregated calculations

  /// Total amount for all items in cart (after discounts)
  double get totalAmount =>
      results.fold(0.0, (sum, line) => sum + line.lineTotal);

  /// Total savings across all items
  double get totalSavings =>
      results.fold(0.0, (sum, line) => sum + line.lineSavings);

  /// Total items count (sum of all quantities)
  int get totalItems => results.fold(0, (sum, line) => sum + line.quantity);

  /// Original total before discounts
  double get originalTotal =>
      results.fold(0.0, (sum, line) => sum + line.lineOriginalTotal);

  /// Check if cart is empty
  bool get isEmpty => results.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => results.isNotEmpty;

  @override
  List<Object?> get props => [count, next, previous, results];

  CheckoutLinesResponse copyWith({
    int? count,
    String? next,
    String? previous,
    List<CheckoutLine>? results,
  }) {
    return CheckoutLinesResponse(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }
}

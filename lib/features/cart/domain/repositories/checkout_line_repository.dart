import '../entities/checkout_line.dart';
import '../entities/checkout_lines_response.dart';

/// Checkout line repository interface
/// Defines contract for cart operations (CRUD)
abstract class CheckoutLineRepository {
  /// Get all checkout lines (cart items)
  ///
  /// Returns null if data hasn't changed (HTTP 304)
  /// Set [forceRefresh] to true to bypass cache
  Future<CheckoutLinesResponse?> getCheckoutLines({bool forceRefresh = false});

  /// Add item to cart
  ///
  /// If item already exists, increments quantity
  /// Throws [InsufficientStockException] if stock unavailable
  Future<CheckoutLine> addToCart({
    required int productVariantId,
    required int quantity,
  });

  /// Update quantity using delta (increment/decrement)
  ///
  /// IMPORTANT: [quantity] is a DELTA value, not absolute
  /// - Positive: increment (e.g., +1, +2)
  /// - Negative: decrement (e.g., -1, -2)
  ///
  /// Example: Current quantity is 3
  /// - updateQuantity(quantity: 2) → New quantity: 5
  /// - updateQuantity(quantity: -1) → New quantity: 2
  ///
  /// Throws [InsufficientStockException] if exceeds stock/limit
  Future<CheckoutLine> updateQuantity({
    required int lineId,
    required int productVariantId,
    required int quantity, // Delta value!
  });

  /// Delete item from cart
  Future<void> deleteCheckoutLine(int lineId);
}

/// Exception thrown when product stock is insufficient
class InsufficientStockException implements Exception {
  InsufficientStockException(this.message);

  final String message;

  @override
  String toString() => message;
}

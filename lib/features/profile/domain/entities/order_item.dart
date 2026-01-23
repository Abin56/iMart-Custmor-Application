import 'package:equatable/equatable.dart';

/// OrderItem entity representing a product in an order
class OrderItemEntity extends Equatable {
  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.variantName,
  });

  factory OrderItemEntity.fromMap(Map<String, dynamic> map) {
    // Fix image URL if it doesn't start with http/https
    String? fixImageUrl(String? url) {
      if (url == null || url.isEmpty) return null;
      if (url.startsWith('http://') ||
          url.startsWith('https://') ||
          url.startsWith('assets/')) {
        return url;
      }
      return 'https://$url';
    }

    // Handle nested product_variant_details structure from API
    final variantDetails =
        map['product_variant_details'] as Map<String, dynamic>?;

    // Extract values - handle both flat and nested structures
    String productName;
    String productImage;
    double price;
    String? variantName;

    if (variantDetails != null) {
      // New API structure with nested product_variant_details
      productName = variantDetails['name'] as String? ?? 'Unknown Product';
      productImage =
          fixImageUrl(variantDetails['primary_image'] as String?) ?? '';
      price = _parseAmount(
        variantDetails['price'] ?? variantDetails['discounted_price'],
      );
      variantName = variantDetails['sku'] as String?;
    } else {
      // Legacy/flat structure
      productName = map['product_name'] as String? ?? 'Unknown Product';
      productImage = fixImageUrl(map['product_image'] as String?) ?? '';
      price = _parseAmount(map['price']);
      variantName = map['variant_name'] as String?;
    }

    // Get quantity
    final quantity = map['quantity'] as int? ?? 1;

    // Calculate total price - use provided total_price or calculate from price * quantity
    final totalPrice = map['total_price'] != null
        ? _parseAmount(map['total_price'])
        : price * quantity;

    // Get order ID - API may use 'order' or 'order_id'
    final orderId = map['order_id'] as int? ?? map['order'] as int? ?? 0;

    return OrderItemEntity(
      id: map['id'] as int,
      orderId: orderId,
      productName: productName,
      productImage: productImage,
      quantity: quantity,
      price: price,
      totalPrice: totalPrice,
      variantName: variantName,
    );
  }

  final int id;
  final int orderId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final double totalPrice;
  final String? variantName;

  /// Parse amount from String or num
  static double _parseAmount(dynamic amount) {
    if (amount is String) {
      return double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      return amount.toDouble();
    }
    return 0.0;
  }

  /// Format price with currency
  String get formattedPrice => '₹${price.toStringAsFixed(2)}';

  /// Format total price with currency
  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(2)}';

  /// Get display name with variant if available
  String get displayName {
    if (variantName != null && variantName!.isNotEmpty) {
      return '$productName - $variantName';
    }
    return productName;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price': price.toString(),
      'total_price': totalPrice.toString(),
      'variant_name': variantName,
    };
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    productName,
    productImage,
    quantity,
    price,
    totalPrice,
    variantName,
  ];
}

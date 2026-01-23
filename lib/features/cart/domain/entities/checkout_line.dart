import 'package:equatable/equatable.dart';

import 'product_variant_details.dart';

/// Checkout line entity (Cart item)
/// Represents a single item in the shopping cart
class CheckoutLine extends Equatable {
  const CheckoutLine({
    required this.id,
    required this.productVariantId,
    required this.quantity,
    required this.productVariantDetails,
    this.checkout,
  });

  final int id;
  final int? checkout;
  final int productVariantId;
  final int quantity;
  final ProductVariantDetails productVariantDetails;

  // Computed properties

  /// Total price for this line (quantity × effective price)
  double get lineTotal => quantity * productVariantDetails.effectivePrice;

  /// Total savings for this line (if product has discount)
  double get lineSavings {
    if (!productVariantDetails.hasDiscount) return 0.0;
    return quantity *
        (productVariantDetails.priceValue -
            productVariantDetails.discountedPriceValue);
  }

  /// Original price without discount
  double get lineOriginalTotal => quantity * productVariantDetails.priceValue;

  @override
  List<Object?> get props => [
    id,
    checkout,
    productVariantId,
    quantity,
    productVariantDetails,
  ];

  CheckoutLine copyWith({
    int? id,
    int? checkout,
    int? productVariantId,
    int? quantity,
    ProductVariantDetails? productVariantDetails,
  }) {
    return CheckoutLine(
      id: id ?? this.id,
      checkout: checkout ?? this.checkout,
      productVariantId: productVariantId ?? this.productVariantId,
      quantity: quantity ?? this.quantity,
      productVariantDetails:
          productVariantDetails ?? this.productVariantDetails,
    );
  }
}

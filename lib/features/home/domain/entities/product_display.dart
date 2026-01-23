import 'package:equatable/equatable.dart';

import 'product.dart';

/// Display model for showing products in the UI
/// Combines Product data with a selected variant
class ProductDisplay extends Equatable {
  const ProductDisplay({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.categoryId,
    required this.rating,
    required this.status,
    required this.variantId,
    required this.sku,
    required this.price,
    this.discountedPrice,
    this.imageUrl,
    this.description,
    this.tags,
  });

  /// Create ProductDisplay from a Product and one of its variants
  factory ProductDisplay.fromProduct(
    Product product,
    ProductVariantSummary variant,
  ) {
    return ProductDisplay(
      productId: product.id,
      productName: product.name,
      categoryName: product.categoryName,
      categoryId: product.categoryId,
      rating: product.rating,
      status: product.status,
      variantId: variant.id,
      sku: variant.sku,
      price: variant.price,
      discountedPrice: variant.discountedPrice,
      imageUrl: product.imageUrl,
      description: product.descriptionPlaintext,
      tags: product.tags,
    );
  }

  /// Convert a list of Products into ProductDisplay items
  /// For each product, creates one ProductDisplay per variant
  /// If product has no variants, creates a display item with default values
  static List<ProductDisplay> fromProductList(List<Product> products) {
    final displayList = <ProductDisplay>[];

    for (final product in products) {
      if (product.variants.isEmpty) {
        // Product has no variants - create a display item with product data only
        displayList.add(
          ProductDisplay(
            productId: product.id,
            productName: product.name,
            categoryName: product.categoryName,
            categoryId: product.categoryId,
            rating: product.rating,
            status: product.status,
            variantId: 0, // No variant
            sku: 'no-sku',
            price: '0.00',
            imageUrl: product.imageUrl,
            description: product.descriptionPlaintext,
            tags: product.tags,
          ),
        );
        continue;
      }

      // Product has variants - create a ProductDisplay for EACH variant
      for (final variant in product.variants) {
        displayList.add(ProductDisplay.fromProduct(product, variant));
      }
    }

    return displayList;
  }

  final int productId;
  final String productName;
  final String categoryName;
  final int categoryId;
  final String rating;
  final bool status;
  final int variantId;
  final String sku;
  final String price;
  final String? discountedPrice;
  final String? imageUrl;
  final String? description;
  final String? tags;

  // Helper getters
  double get priceValue => double.tryParse(price) ?? 0.0;
  double get discountedPriceValue =>
      double.tryParse(discountedPrice ?? price) ?? 0.0;
  double get discountPercentage {
    if (priceValue == 0) return 0;
    final discounted = discountedPriceValue;
    if (discounted >= priceValue) return 0;
    return (priceValue - discounted) / priceValue * 100;
  }

  bool get hasDiscount =>
      discountedPrice != null && discountedPriceValue < priceValue;
  double get ratingValue => double.tryParse(rating) ?? 0.0;

  @override
  List<Object?> get props => [
    productId,
    variantId,
    sku,
    price,
    discountedPrice,
    imageUrl,
  ];
}

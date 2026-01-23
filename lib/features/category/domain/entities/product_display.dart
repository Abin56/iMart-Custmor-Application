import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/product.dart';

/// Flattened display model combining Product + Variant for UI
class ProductDisplay extends Equatable {
  const ProductDisplay({
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantSku,
    required this.price,
    this.discountedPrice,
    this.image,
    this.categoryName,
    this.categoryId,
    this.rating,
    this.description,
  });

  /// Create ProductDisplay from Product entity with a specific variant
  factory ProductDisplay.fromProduct(
    Product product,
    ProductVariantSummary variant,
  ) {
    return ProductDisplay(
      productId: product.id,
      productName: product.name,
      variantId: variant.id,
      variantSku: variant.sku,
      price: variant.price,
      discountedPrice: variant.discountedPrice,
      image: product.imageUrl,
      categoryName: product.categoryName,
      categoryId: product.categoryId,
      rating: product.rating,
      description: product.descriptionPlaintext,
    );
  }

  /// Create list of ProductDisplay from list of Products (each variant becomes separate item)
  static List<ProductDisplay> fromProductList(List<Product> products) {
    final displayList = <ProductDisplay>[];

    for (final product in products) {
      if (product.variants.isEmpty) {
        // Handle products without variants by creating a default display
        displayList.add(
          ProductDisplay(
            productId: product.id,
            productName: product.name,
            variantId: 0,
            variantSku: 'N/A',
            price: '0',
            categoryName: product.categoryName,
            categoryId: product.categoryId,
            rating: product.rating,
            description: product.descriptionPlaintext,
            image: product.imageUrl,
          ),
        );
        continue;
      }

      // Create ProductDisplay for EACH variant
      for (final variant in product.variants) {
        displayList.add(ProductDisplay.fromProduct(product, variant));
      }
    }

    return displayList;
  }

  final int productId;
  final String productName;
  final int variantId;
  final String variantSku;
  final String price;
  final String? discountedPrice;
  final String? image;
  final String? categoryName;
  final int? categoryId;
  final String? rating;
  final String? description;

  /// Calculate discount percentage
  double get discountPercentage {
    if (discountedPrice == null) return 0;
    final originalPrice = double.tryParse(price) ?? 0;
    final discounted = double.tryParse(discountedPrice!) ?? 0;
    if (originalPrice <= 0) return 0;
    return ((originalPrice - discounted) / originalPrice) * 100;
  }

  /// Check if product has discount
  bool get hasDiscount => discountedPrice != null && discountPercentage > 0;

  /// Get display price (discounted if available, otherwise regular)
  String get displayPrice => discountedPrice ?? price;

  @override
  List<Object?> get props => [
    productId,
    productName,
    variantId,
    variantSku,
    price,
    discountedPrice,
    image,
    categoryName,
    categoryId,
    rating,
    description,
  ];
}

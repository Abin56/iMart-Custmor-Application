import 'package:equatable/equatable.dart';

import 'product_image.dart';

/// Product variant details entity
/// Contains all information about a product variant in the cart
class ProductVariantDetails extends Equatable {
  const ProductVariantDetails({
    required this.id,
    required this.sku,
    required this.name,
    required this.productId,
    required this.price,
    required this.discountedPrice,
    required this.trackInventory,
    required this.currentQuantity,
    required this.quantityLimitPerCustomer,
    required this.isPreorder,
    required this.preorderGlobalThreshold,
    required this.images,
    this.preorderEndDate,
  });

  final int id;
  final String sku;
  final String name;
  final int productId;

  // Pricing (stored as strings from API)
  final String price;
  final String discountedPrice;

  // Inventory
  final bool trackInventory;
  final int currentQuantity;
  final int quantityLimitPerCustomer;

  // Preorder
  final bool isPreorder;
  final DateTime? preorderEndDate;
  final int preorderGlobalThreshold;

  // Images
  final List<ProductImage> images;

  // Computed properties
  double get priceValue => double.tryParse(price) ?? 0.0;
  double get discountedPriceValue => double.tryParse(discountedPrice) ?? 0.0;

  double get effectivePrice =>
      discountedPriceValue > 0 ? discountedPriceValue : priceValue;

  bool get hasDiscount =>
      discountedPriceValue > 0 && discountedPriceValue < priceValue;

  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((priceValue - discountedPriceValue) / priceValue) * 100;
  }

  bool get inStock => !trackInventory || currentQuantity > 0;

  String? get primaryImageUrl =>
      images.isNotEmpty ? images.first.imageUrl : null;

  @override
  List<Object?> get props => [
    id,
    sku,
    name,
    productId,
    price,
    discountedPrice,
    trackInventory,
    currentQuantity,
    quantityLimitPerCustomer,
    isPreorder,
    preorderEndDate,
    preorderGlobalThreshold,
    images,
  ];

  ProductVariantDetails copyWith({
    int? id,
    String? sku,
    String? name,
    int? productId,
    String? price,
    String? discountedPrice,
    bool? trackInventory,
    int? currentQuantity,
    int? quantityLimitPerCustomer,
    bool? isPreorder,
    DateTime? preorderEndDate,
    int? preorderGlobalThreshold,
    List<ProductImage>? images,
  }) {
    return ProductVariantDetails(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      trackInventory: trackInventory ?? this.trackInventory,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      quantityLimitPerCustomer:
          quantityLimitPerCustomer ?? this.quantityLimitPerCustomer,
      isPreorder: isPreorder ?? this.isPreorder,
      preorderEndDate: preorderEndDate ?? this.preorderEndDate,
      preorderGlobalThreshold:
          preorderGlobalThreshold ?? this.preorderGlobalThreshold,
      images: images ?? this.images,
    );
  }
}

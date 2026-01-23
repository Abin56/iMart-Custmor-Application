import 'package:equatable/equatable.dart';

/// Product entity representing a product with its variants
/// This is different from ProductVariant - Product is the parent,
/// and it contains multiple ProductVariant items
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.categoryId,
    required this.rating,
    required this.status,
    this.descriptionPlaintext,
    this.slug,
    this.tags,
    this.variants = const [],
    this.primaryImage,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    // Parse variants list
    final variantsList =
        (map['variants'] as List?)
            ?.map(
              (item) =>
                  ProductVariantSummary.fromMap(item as Map<String, dynamic>),
            )
            .toList() ??
        [];

    // Parse primary image if exists
    ProductImage? primaryImg;
    if (map['primary_image'] != null && map['primary_image'] is Map) {
      primaryImg = ProductImage.fromMap(
        map['primary_image'] as Map<String, dynamic>,
      );
    }

    return Product(
      id: map['id'] as int,
      name: map['name'] as String,
      descriptionPlaintext: map['description_plaintext'] as String?,
      categoryName: map['category_name'] as String,
      categoryId: map['category_id'] as int,
      slug: map['slug'] as String?,
      rating: map['rating'] as String,
      status: map['status'] as bool,
      tags: map['tags'] as String?,
      variants: variantsList,
      primaryImage: primaryImg,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  final int id;
  final String name;
  final String? descriptionPlaintext;
  final String categoryName;
  final int categoryId;
  final String? slug;
  final String rating;
  final bool status;
  final String? tags;
  final List<ProductVariantSummary> variants;
  final ProductImage? primaryImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Helper getters
  double get ratingValue => double.tryParse(rating) ?? 0.0;
  String? get imageUrl => primaryImage?.imageUrl;
  bool get hasVariants => variants.isNotEmpty;

  @override
  List<Object?> get props => [id, name, categoryId, variants];
}

/// Simplified variant data from product list endpoint
class ProductVariantSummary extends Equatable {
  const ProductVariantSummary({
    required this.id,
    required this.sku,
    required this.price,
    this.discountedPrice,
  });

  factory ProductVariantSummary.fromMap(Map<String, dynamic> map) {
    return ProductVariantSummary(
      id: map['id'] as int,
      sku: map['sku'] as String,
      price: map['price'] as String,
      discountedPrice: map['discounted_price'] as String?,
    );
  }

  final int id;
  final String sku;
  final String price;
  final String? discountedPrice;

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

  @override
  List<Object?> get props => [id, sku, price, discountedPrice];
}

/// Product image from API
class ProductImage extends Equatable {
  const ProductImage({
    required this.id,
    required this.imageUrl,
    this.filePath,
    this.alt,
    this.externalUrl,
    this.oembedData,
    this.toRemove = false,
    this.productId,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductImage.fromMap(Map<String, dynamic> map) {
    // Fix image URL - add https:// if missing
    String? fixImageUrl(String? url) {
      if (url == null || url.isEmpty) return url;
      if (url.startsWith('http://') ||
          url.startsWith('https://') ||
          url.startsWith('assets/')) {
        return url;
      }
      return 'https://$url';
    }

    return ProductImage(
      id: map['id'] as int,
      filePath: map['file_path'] as String?,
      imageUrl: fixImageUrl(map['image'] as String?) ?? '',
      alt: map['alt'] as String?,
      externalUrl: map['external_url'] as String?,
      oembedData: map['oembed_data'] as String?,
      toRemove: map['to_remove'] as bool? ?? false,
      productId: map['product_id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  final int id;
  final String? filePath;
  final String imageUrl;
  final String? alt;
  final String? externalUrl;
  final String? oembedData;
  final bool toRemove;
  final int? productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, imageUrl, productId];
}

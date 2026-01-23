import 'package:equatable/equatable.dart';

import 'product_variant_image.dart';
import 'product_variant_media.dart';
import 'product_variant_review.dart';

/// Product variant entity with pricing, stock, and media
class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.stock,
    this.discountedPrice,
    this.sku,
    this.size,
    this.color,
    this.weight,
    this.unit,
    this.description,
    this.stockUnit,
    this.images = const [],
    this.media = const [],
    this.reviews = const [],
    this.averageRating,
    this.reviewCount = 0,
    this.isWishlisted = false,
    this.lastModified,
    this.etag,
  });

  final int id;
  final int productId;
  final String name;
  final double price;
  final int stock;
  final double? discountedPrice;
  final String? sku;
  final String? size;
  final String? color;
  final double? weight;
  final String? unit;
  final String? description;
  final String? stockUnit;
  final List<ProductVariantImage> images;
  final List<ProductVariantMedia> media;
  final List<ProductVariantReview> reviews;
  final double? averageRating;
  final int reviewCount;
  final bool isWishlisted;
  final DateTime? lastModified;
  final String? etag;

  /// Check if variant is in stock
  bool get isInStock => stock > 0;

  /// Check if variant has discount
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;

  /// Get effective price (discounted or regular)
  double get effectivePrice => discountedPrice ?? price;

  /// Calculate discount percentage
  double? get discountPercentage {
    if (!hasDiscount) return null;
    return (price - discountedPrice!) / price * 100;
  }

  /// Copy with method for updates
  ProductVariant copyWith({
    int? id,
    int? productId,
    String? name,
    double? price,
    int? stock,
    double? discountedPrice,
    String? sku,
    String? size,
    String? color,
    double? weight,
    String? unit,
    String? description,
    String? stockUnit,
    List<ProductVariantImage>? images,
    List<ProductVariantMedia>? media,
    List<ProductVariantReview>? reviews,
    double? averageRating,
    int? reviewCount,
    bool? isWishlisted,
    DateTime? lastModified,
    String? etag,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      sku: sku ?? this.sku,
      size: size ?? this.size,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      stockUnit: stockUnit ?? this.stockUnit,
      images: images ?? this.images,
      media: media ?? this.media,
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      lastModified: lastModified ?? this.lastModified,
      etag: etag ?? this.etag,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    name,
    price,
    stock,
    discountedPrice,
    sku,
    size,
    color,
    weight,
    unit,
    description,
    stockUnit,
    images,
    media,
    reviews,
    averageRating,
    reviewCount,
    isWishlisted,
    lastModified,
    etag,
  ];
}

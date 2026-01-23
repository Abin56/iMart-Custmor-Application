// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_variant.dart';
import 'product_variant_image_dto.dart';
import 'product_variant_media_dto.dart';
import 'product_variant_review_dto.dart';

part 'product_variant_dto.freezed.dart';
part 'product_variant_dto.g.dart';

@freezed
class ProductVariantDto with _$ProductVariantDto {
  const factory ProductVariantDto({
    required int id,
    @JsonKey(name: 'product_id') required int productId,
    required String name,
    @JsonKey(fromJson: _priceFromJson) required double price,
    @JsonKey(name: 'current_quantity', fromJson: _stockFromJson)
    required int stock,
    @JsonKey(name: 'discounted_price', fromJson: _nullableDoubleFromJson)
    double? discountedPrice,
    String? sku,
    String? size,
    String? color,
    @JsonKey(fromJson: _nullableDoubleFromJson) double? weight,
    String? unit,
    @JsonKey(name: 'prod_description') String? description,
    @JsonKey(name: 'current_stock_unit') String? stockUnit,
    @Default([]) List<ProductVariantImageDto> images,
    @Default([]) List<ProductVariantMediaDto> media,
    @Default([]) List<ProductVariantReviewDto> reviews,
    @JsonKey(name: 'product_rating', fromJson: _nullableDoubleFromJson)
    double? averageRating,
    @JsonKey(name: 'review_count', fromJson: _intFromJson)
    @Default(0)
    int reviewCount,
    @JsonKey(name: 'is_wishlisted') @Default(false) bool isWishlisted,
  }) = _ProductVariantDto;

  factory ProductVariantDto.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantDtoFromJson(json);
}

/// Extension to convert DTO to Entity
extension ProductVariantDtoX on ProductVariantDto {
  ProductVariant toEntity({DateTime? lastModified, String? etag}) {
    return ProductVariant(
      id: id,
      productId: productId,
      name: name,
      price: price,
      stock: stock,
      discountedPrice: discountedPrice,
      sku: sku,
      size: size,
      color: color,
      weight: weight,
      unit: unit,
      description: description,
      stockUnit: stockUnit,
      images: images.map((img) => img.toEntity()).toList(),
      media: media.map((m) => m.toEntity()).toList(),
      reviews: reviews.map((r) => r.toEntity()).toList(),
      averageRating: averageRating,
      reviewCount: reviewCount,
      isWishlisted: isWishlisted,
      lastModified: lastModified,
      etag: etag,
    );
  }
}

/// Helper functions to convert string/int/double to double
double _priceFromJson(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.parse(value);
  throw ArgumentError('Cannot convert $value to double');
}

int _stockFromJson(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.parse(value);
  throw ArgumentError('Cannot convert $value to int');
}

double? _nullableDoubleFromJson(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

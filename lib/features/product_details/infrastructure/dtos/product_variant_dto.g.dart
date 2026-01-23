// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantDtoImpl _$$ProductVariantDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ProductVariantDtoImpl(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  name: json['name'] as String,
  price: _priceFromJson(json['price']),
  stock: _stockFromJson(json['current_quantity']),
  discountedPrice: _nullableDoubleFromJson(json['discounted_price']),
  sku: json['sku'] as String?,
  size: json['size'] as String?,
  color: json['color'] as String?,
  weight: _nullableDoubleFromJson(json['weight']),
  unit: json['unit'] as String?,
  description: json['prod_description'] as String?,
  stockUnit: json['current_stock_unit'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map(
            (e) => ProductVariantImageDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  media:
      (json['media'] as List<dynamic>?)
          ?.map(
            (e) => ProductVariantMediaDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  reviews:
      (json['reviews'] as List<dynamic>?)
          ?.map(
            (e) => ProductVariantReviewDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  averageRating: _nullableDoubleFromJson(json['product_rating']),
  reviewCount: json['review_count'] == null
      ? 0
      : _intFromJson(json['review_count']),
  isWishlisted: json['is_wishlisted'] as bool? ?? false,
);

Map<String, dynamic> _$$ProductVariantDtoImplToJson(
  _$ProductVariantDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'name': instance.name,
  'price': instance.price,
  'current_quantity': instance.stock,
  'discounted_price': instance.discountedPrice,
  'sku': instance.sku,
  'size': instance.size,
  'color': instance.color,
  'weight': instance.weight,
  'unit': instance.unit,
  'prod_description': instance.description,
  'current_stock_unit': instance.stockUnit,
  'images': instance.images,
  'media': instance.media,
  'reviews': instance.reviews,
  'product_rating': instance.averageRating,
  'review_count': instance.reviewCount,
  'is_wishlisted': instance.isWishlisted,
};

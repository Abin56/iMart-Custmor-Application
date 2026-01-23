// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_details_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantDetailsDtoImpl _$$ProductVariantDetailsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ProductVariantDetailsDtoImpl(
  id: (json['id'] as num).toInt(),
  sku: json['sku'] as String,
  name: json['name'] as String,
  price: json['price'] as String,
  currentQuantity: (json['current_quantity'] as num).toInt(),
  productId: (json['product_id'] as num?)?.toInt(),
  discountedPrice: json['discounted_price'] as String?,
  trackInventory: json['track_inventory'] as bool?,
  quantityLimitPerCustomer: (json['quantity_limit_per_customer'] as num?)
      ?.toInt(),
  isPreorder: json['is_preorder'] as bool?,
  preorderGlobalThreshold: (json['preorder_global_threshold'] as num?)?.toInt(),
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => ProductImageDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  preorderEndDate: json['preorder_end_date'] == null
      ? null
      : DateTime.parse(json['preorder_end_date'] as String),
);

Map<String, dynamic> _$$ProductVariantDetailsDtoImplToJson(
  _$ProductVariantDetailsDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sku': instance.sku,
  'name': instance.name,
  'price': instance.price,
  'current_quantity': instance.currentQuantity,
  'product_id': instance.productId,
  'discounted_price': instance.discountedPrice,
  'track_inventory': instance.trackInventory,
  'quantity_limit_per_customer': instance.quantityLimitPerCustomer,
  'is_preorder': instance.isPreorder,
  'preorder_global_threshold': instance.preorderGlobalThreshold,
  'images': instance.images,
  'preorder_end_date': instance.preorderEndDate?.toIso8601String(),
};

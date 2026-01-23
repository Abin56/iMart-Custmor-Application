// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_line_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckoutLineDtoImpl _$$CheckoutLineDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CheckoutLineDtoImpl(
  id: (json['id'] as num).toInt(),
  productVariantId: (json['product_variant_id'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  productVariantDetails: ProductVariantDetailsDto.fromJson(
    json['product_variant_details'] as Map<String, dynamic>,
  ),
  checkout: (json['checkout'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CheckoutLineDtoImplToJson(
  _$CheckoutLineDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_variant_id': instance.productVariantId,
  'quantity': instance.quantity,
  'product_variant_details': instance.productVariantDetails,
  'checkout': instance.checkout,
};

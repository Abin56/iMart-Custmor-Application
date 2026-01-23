// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_image_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantImageDtoImpl _$$ProductVariantImageDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ProductVariantImageDtoImpl(
  id: (json['id'] as num).toInt(),
  url: json['image'] as String,
  position: (json['position'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ProductVariantImageDtoImplToJson(
  _$ProductVariantImageDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'image': instance.url,
  'position': instance.position,
};

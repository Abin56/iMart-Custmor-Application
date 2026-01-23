// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImageDtoImpl _$$ProductImageDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ProductImageDtoImpl(
  id: (json['id'] as num).toInt(),
  image: json['image'] as String,
  alt: json['alt'] as String?,
);

Map<String, dynamic> _$$ProductImageDtoImplToJson(
  _$ProductImageDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'image': instance.image,
  'alt': instance.alt,
};

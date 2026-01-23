// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_media_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantMediaDtoImpl _$$ProductVariantMediaDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ProductVariantMediaDtoImpl(
  id: (json['id'] as num).toInt(),
  url: json['image'] as String,
  filePath: json['file_path'] as String?,
  alt: json['alt'] as String?,
  position: (json['position'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ProductVariantMediaDtoImplToJson(
  _$ProductVariantMediaDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'image': instance.url,
  'file_path': instance.filePath,
  'alt': instance.alt,
  'position': instance.position,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_base_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductBaseDtoImpl _$$ProductBaseDtoImplFromJson(Map<String, dynamic> json) =>
    _$ProductBaseDtoImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      categoryId: (json['category_id'] as num).toInt(),
      description: _descriptionFromJson(json['description']),
      brand: json['brand'] as String?,
      manufacturer: json['manufacturer'] as String?,
      tags: json['tags'] == null ? const [] : _tagsFromJson(json['tags']),
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      slug: json['slug'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$ProductBaseDtoImplToJson(
  _$ProductBaseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category_id': instance.categoryId,
  'description': instance.description,
  'brand': instance.brand,
  'manufacturer': instance.manufacturer,
  'tags': instance.tags,
  'meta_title': instance.metaTitle,
  'meta_description': instance.metaDescription,
  'slug': instance.slug,
  'is_active': instance.isActive,
};

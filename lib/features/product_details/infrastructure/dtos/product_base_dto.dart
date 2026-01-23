// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_base.dart';

part 'product_base_dto.freezed.dart';
part 'product_base_dto.g.dart';

@freezed
class ProductBaseDto with _$ProductBaseDto {
  const factory ProductBaseDto({
    required int id,
    required String name,
    @JsonKey(name: 'category_id') required int categoryId,
    @JsonKey(fromJson: _descriptionFromJson) String? description,
    String? brand,
    String? manufacturer,
    @JsonKey(fromJson: _tagsFromJson) @Default([]) List<String> tags,
    @JsonKey(name: 'meta_title') String? metaTitle,
    @JsonKey(name: 'meta_description') String? metaDescription,
    String? slug,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _ProductBaseDto;

  factory ProductBaseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductBaseDtoFromJson(json);
}

/// Extract text from description object or return string directly
String? _descriptionFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    // Handle {"text": "..."} format
    return value['text'] as String?;
  }
  return null;
}

/// Convert tags from various formats to List of String
List<String> _tagsFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String) {
    // If it's a comma-separated string, split it
    if (value.isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return [];
}

/// Extension to convert DTO to Entity
extension ProductBaseDtoX on ProductBaseDto {
  ProductBase toEntity() {
    return ProductBase(
      id: id,
      name: name,
      categoryId: categoryId,
      description: description,
      brand: brand,
      manufacturer: manufacturer,
      tags: tags,
      metaTitle: metaTitle,
      metaDescription: metaDescription,
      slug: slug,
      isActive: isActive,
    );
  }
}

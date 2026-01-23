// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_variant_image.dart';

part 'product_variant_image_dto.freezed.dart';
part 'product_variant_image_dto.g.dart';

@freezed
class ProductVariantImageDto with _$ProductVariantImageDto {
  const factory ProductVariantImageDto({
    required int id,
    @JsonKey(name: 'image') required String url,
    int? position,
  }) = _ProductVariantImageDto;

  factory ProductVariantImageDto.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantImageDtoFromJson(json);
}

/// Extension to convert DTO to Entity
extension ProductVariantImageDtoX on ProductVariantImageDto {
  ProductVariantImage toEntity() {
    return ProductVariantImage(id: id, url: url, position: position);
  }
}

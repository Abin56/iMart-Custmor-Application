// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_image.dart';

part 'product_image_dto.freezed.dart';
part 'product_image_dto.g.dart';

@freezed
class ProductImageDto with _$ProductImageDto {
  const factory ProductImageDto({
    required int id,
    required String image,
    String? alt,
  }) = _ProductImageDto;

  const ProductImageDto._();

  factory ProductImageDto.fromJson(Map<String, dynamic> json) =>
      _$ProductImageDtoFromJson(json);

  /// Convert DTO to Entity
  ProductImage toEntity() {
    return ProductImage(id: id, image: image, alt: alt);
  }
}

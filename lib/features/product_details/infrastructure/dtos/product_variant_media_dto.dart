// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_variant_media.dart';

part 'product_variant_media_dto.freezed.dart';
part 'product_variant_media_dto.g.dart';

@freezed
class ProductVariantMediaDto with _$ProductVariantMediaDto {
  const factory ProductVariantMediaDto({
    required int id,
    @JsonKey(name: 'image') required String url,
    @JsonKey(name: 'file_path') String? filePath,
    @JsonKey(name: 'alt') String? alt,
    int? position,
  }) = _ProductVariantMediaDto;

  factory ProductVariantMediaDto.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantMediaDtoFromJson(json);
}

/// Extension to convert DTO to Entity
extension ProductVariantMediaDtoX on ProductVariantMediaDto {
  ProductVariantMedia toEntity() {
    // Determine type from file extension or default to 'image'
    var mediaType = 'image';
    if (filePath != null) {
      final path = filePath!.toLowerCase();
      if (path.endsWith('.mp4') ||
          path.endsWith('.webm') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi')) {
        mediaType = 'video';
      }
    }

    return ProductVariantMedia(
      id: id,
      type: mediaType,
      url: url,
      thumbnailUrl: alt,
      position: position,
    );
  }
}

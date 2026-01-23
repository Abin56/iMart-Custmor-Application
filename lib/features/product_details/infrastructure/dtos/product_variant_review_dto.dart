// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_variant_review.dart';

part 'product_variant_review_dto.freezed.dart';
part 'product_variant_review_dto.g.dart';

@freezed
class ProductVariantReviewDto with _$ProductVariantReviewDto {
  const factory ProductVariantReviewDto({
    required int id,
    required double rating,
    String? comment,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ProductVariantReviewDto;

  factory ProductVariantReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantReviewDtoFromJson(json);
}

/// Extension to convert DTO to Entity
extension ProductVariantReviewDtoX on ProductVariantReviewDto {
  ProductVariantReview toEntity() {
    return ProductVariantReview(
      id: id,
      rating: rating,
      comment: comment,
      userName: userName,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantReviewDtoImpl _$$ProductVariantReviewDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ProductVariantReviewDtoImpl(
  id: (json['id'] as num).toInt(),
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String?,
  userName: json['user_name'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$$ProductVariantReviewDtoImplToJson(
  _$ProductVariantReviewDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'comment': instance.comment,
  'user_name': instance.userName,
  'created_at': instance.createdAt,
};

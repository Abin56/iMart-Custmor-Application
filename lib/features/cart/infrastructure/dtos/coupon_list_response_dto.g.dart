// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CouponListResponseDtoImpl _$$CouponListResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CouponListResponseDtoImpl(
  count: (json['count'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => CouponDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
);

Map<String, dynamic> _$$CouponListResponseDtoImplToJson(
  _$CouponListResponseDtoImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'results': instance.results,
  'next': instance.next,
  'previous': instance.previous,
};

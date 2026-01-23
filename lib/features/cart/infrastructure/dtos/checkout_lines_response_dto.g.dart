// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_lines_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckoutLinesResponseDtoImpl _$$CheckoutLinesResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CheckoutLinesResponseDtoImpl(
  count: (json['count'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => CheckoutLineDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
);

Map<String, dynamic> _$$CheckoutLinesResponseDtoImplToJson(
  _$CheckoutLinesResponseDtoImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'results': instance.results,
  'next': instance.next,
  'previous': instance.previous,
};

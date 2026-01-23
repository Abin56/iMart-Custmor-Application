// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressListResponseDtoImpl _$$AddressListResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AddressListResponseDtoImpl(
  count: (json['count'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => AddressDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
);

Map<String, dynamic> _$$AddressListResponseDtoImplToJson(
  _$AddressListResponseDtoImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'results': instance.results,
  'next': instance.next,
  'previous': instance.previous,
};

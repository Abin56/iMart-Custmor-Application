// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressDtoImpl _$$AddressDtoImplFromJson(Map<String, dynamic> json) =>
    _$AddressDtoImpl(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      addressType: json['address_type'] as String,
      streetAddress1: json['street_address_1'] as String?,
      streetAddress2: json['street_address_2'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      selected: json['selected'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$AddressDtoImplToJson(_$AddressDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'city': instance.city,
      'state': instance.state,
      'postal_code': instance.postalCode,
      'country': instance.country,
      'address_type': instance.addressType,
      'street_address_1': instance.streetAddress1,
      'street_address_2': instance.streetAddress2,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'selected': instance.selected,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

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

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
      streetAddress1: json['street_address_1'] as String,
      city: json['city'] as String,
      countryArea: json['country_area'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String,
      isDefaultShippingAddress: json['is_default_shipping_address'] as bool,
      isDefaultBillingAddress: json['is_default_billing_address'] as bool,
      companyName: json['company_name'] as String?,
      streetAddress2: json['street_address_2'] as String?,
      cityArea: json['city_area'] as String?,
    );

Map<String, dynamic> _$$AddressDtoImplToJson(_$AddressDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'street_address_1': instance.streetAddress1,
      'city': instance.city,
      'country_area': instance.countryArea,
      'postal_code': instance.postalCode,
      'country': instance.country,
      'phone': instance.phone,
      'is_default_shipping_address': instance.isDefaultShippingAddress,
      'is_default_billing_address': instance.isDefaultBillingAddress,
      'company_name': instance.companyName,
      'street_address_2': instance.streetAddress2,
      'city_area': instance.cityArea,
    };

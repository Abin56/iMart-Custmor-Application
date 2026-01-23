// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/address.dart';

part 'address_dto.freezed.dart';
part 'address_dto.g.dart';

@freezed
class AddressDto with _$AddressDto {
  const factory AddressDto({
    required int id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'street_address_1') required String streetAddress1,
    required String city,
    @JsonKey(name: 'country_area') required String countryArea,
    @JsonKey(name: 'postal_code') required String postalCode,
    required String country,
    required String phone,
    @JsonKey(name: 'is_default_shipping_address')
    required bool isDefaultShippingAddress,
    @JsonKey(name: 'is_default_billing_address')
    required bool isDefaultBillingAddress,
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'street_address_2') String? streetAddress2,
    @JsonKey(name: 'city_area') String? cityArea,
  }) = _AddressDto;

  const AddressDto._();

  factory AddressDto.fromJson(Map<String, dynamic> json) =>
      _$AddressDtoFromJson(json);

  /// Convert DTO to Entity
  Address toEntity() {
    return Address(
      id: id,
      firstName: firstName,
      lastName: lastName,
      streetAddress1: streetAddress1,
      city: city,
      countryArea: countryArea,
      postalCode: postalCode,
      country: country,
      phone: phone,
      isDefaultShippingAddress: isDefaultShippingAddress,
      isDefaultBillingAddress: isDefaultBillingAddress,
      companyName: companyName,
      streetAddress2: streetAddress2,
      cityArea: cityArea,
    );
  }
}

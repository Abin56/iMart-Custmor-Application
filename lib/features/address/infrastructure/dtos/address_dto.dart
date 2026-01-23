// coverage:ignore-file
// ignore_for_file: invalid_annotation_target, invalid_assignment

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
    required String city,
    required String state,
    @JsonKey(name: 'postal_code') required String postalCode,
    required String country,
    @JsonKey(name: 'address_type') required String addressType,
    @JsonKey(name: 'street_address_1') String? streetAddress1,
    @JsonKey(name: 'street_address_2') String? streetAddress2,
    String? latitude,
    String? longitude,
    @Default(false) bool selected,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AddressDto;

  const AddressDto._();

  factory AddressDto.fromJson(Map<String, dynamic> json) =>
      _$AddressDtoFromJson(json);

  /// Convert to domain entity
  Address toEntity() {
    return Address(
      id: id,
      firstName: firstName,
      lastName: lastName,
      streetAddress1: streetAddress1,
      streetAddress2: streetAddress2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      latitude: latitude,
      longitude: longitude,
      addressType: addressType,
      selected: selected,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@freezed
class AddressListResponseDto with _$AddressListResponseDto {
  const factory AddressListResponseDto({
    required int count,
    required List<AddressDto> results,
    String? next,
    String? previous,
  }) = _AddressListResponseDto;

  factory AddressListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AddressListResponseDtoFromJson(json);
}

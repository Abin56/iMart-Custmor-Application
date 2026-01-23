// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AddressDto _$AddressDtoFromJson(Map<String, dynamic> json) {
  return _AddressDto.fromJson(json);
}

/// @nodoc
mixin _$AddressDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'street_address_1')
  String get streetAddress1 => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  @JsonKey(name: 'country_area')
  String get countryArea => throw _privateConstructorUsedError;
  @JsonKey(name: 'postal_code')
  String get postalCode => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default_shipping_address')
  bool get isDefaultShippingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default_billing_address')
  bool get isDefaultBillingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_name')
  String? get companyName => throw _privateConstructorUsedError;
  @JsonKey(name: 'street_address_2')
  String? get streetAddress2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'city_area')
  String? get cityArea => throw _privateConstructorUsedError;

  /// Serializes this AddressDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddressDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressDtoCopyWith<AddressDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressDtoCopyWith<$Res> {
  factory $AddressDtoCopyWith(
    AddressDto value,
    $Res Function(AddressDto) then,
  ) = _$AddressDtoCopyWithImpl<$Res, AddressDto>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'first_name') String firstName,
    @JsonKey(name: 'last_name') String lastName,
    @JsonKey(name: 'street_address_1') String streetAddress1,
    String city,
    @JsonKey(name: 'country_area') String countryArea,
    @JsonKey(name: 'postal_code') String postalCode,
    String country,
    String phone,
    @JsonKey(name: 'is_default_shipping_address') bool isDefaultShippingAddress,
    @JsonKey(name: 'is_default_billing_address') bool isDefaultBillingAddress,
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'street_address_2') String? streetAddress2,
    @JsonKey(name: 'city_area') String? cityArea,
  });
}

/// @nodoc
class _$AddressDtoCopyWithImpl<$Res, $Val extends AddressDto>
    implements $AddressDtoCopyWith<$Res> {
  _$AddressDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddressDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? streetAddress1 = null,
    Object? city = null,
    Object? countryArea = null,
    Object? postalCode = null,
    Object? country = null,
    Object? phone = null,
    Object? isDefaultShippingAddress = null,
    Object? isDefaultBillingAddress = null,
    Object? companyName = freezed,
    Object? streetAddress2 = freezed,
    Object? cityArea = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            streetAddress1: null == streetAddress1
                ? _value.streetAddress1
                : streetAddress1 // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            countryArea: null == countryArea
                ? _value.countryArea
                : countryArea // ignore: cast_nullable_to_non_nullable
                      as String,
            postalCode: null == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            isDefaultShippingAddress: null == isDefaultShippingAddress
                ? _value.isDefaultShippingAddress
                : isDefaultShippingAddress // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDefaultBillingAddress: null == isDefaultBillingAddress
                ? _value.isDefaultBillingAddress
                : isDefaultBillingAddress // ignore: cast_nullable_to_non_nullable
                      as bool,
            companyName: freezed == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            streetAddress2: freezed == streetAddress2
                ? _value.streetAddress2
                : streetAddress2 // ignore: cast_nullable_to_non_nullable
                      as String?,
            cityArea: freezed == cityArea
                ? _value.cityArea
                : cityArea // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddressDtoImplCopyWith<$Res>
    implements $AddressDtoCopyWith<$Res> {
  factory _$$AddressDtoImplCopyWith(
    _$AddressDtoImpl value,
    $Res Function(_$AddressDtoImpl) then,
  ) = __$$AddressDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'first_name') String firstName,
    @JsonKey(name: 'last_name') String lastName,
    @JsonKey(name: 'street_address_1') String streetAddress1,
    String city,
    @JsonKey(name: 'country_area') String countryArea,
    @JsonKey(name: 'postal_code') String postalCode,
    String country,
    String phone,
    @JsonKey(name: 'is_default_shipping_address') bool isDefaultShippingAddress,
    @JsonKey(name: 'is_default_billing_address') bool isDefaultBillingAddress,
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'street_address_2') String? streetAddress2,
    @JsonKey(name: 'city_area') String? cityArea,
  });
}

/// @nodoc
class __$$AddressDtoImplCopyWithImpl<$Res>
    extends _$AddressDtoCopyWithImpl<$Res, _$AddressDtoImpl>
    implements _$$AddressDtoImplCopyWith<$Res> {
  __$$AddressDtoImplCopyWithImpl(
    _$AddressDtoImpl _value,
    $Res Function(_$AddressDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddressDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? streetAddress1 = null,
    Object? city = null,
    Object? countryArea = null,
    Object? postalCode = null,
    Object? country = null,
    Object? phone = null,
    Object? isDefaultShippingAddress = null,
    Object? isDefaultBillingAddress = null,
    Object? companyName = freezed,
    Object? streetAddress2 = freezed,
    Object? cityArea = freezed,
  }) {
    return _then(
      _$AddressDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        streetAddress1: null == streetAddress1
            ? _value.streetAddress1
            : streetAddress1 // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        countryArea: null == countryArea
            ? _value.countryArea
            : countryArea // ignore: cast_nullable_to_non_nullable
                  as String,
        postalCode: null == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        isDefaultShippingAddress: null == isDefaultShippingAddress
            ? _value.isDefaultShippingAddress
            : isDefaultShippingAddress // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDefaultBillingAddress: null == isDefaultBillingAddress
            ? _value.isDefaultBillingAddress
            : isDefaultBillingAddress // ignore: cast_nullable_to_non_nullable
                  as bool,
        companyName: freezed == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        streetAddress2: freezed == streetAddress2
            ? _value.streetAddress2
            : streetAddress2 // ignore: cast_nullable_to_non_nullable
                  as String?,
        cityArea: freezed == cityArea
            ? _value.cityArea
            : cityArea // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressDtoImpl extends _AddressDto {
  const _$AddressDtoImpl({
    required this.id,
    @JsonKey(name: 'first_name') required this.firstName,
    @JsonKey(name: 'last_name') required this.lastName,
    @JsonKey(name: 'street_address_1') required this.streetAddress1,
    required this.city,
    @JsonKey(name: 'country_area') required this.countryArea,
    @JsonKey(name: 'postal_code') required this.postalCode,
    required this.country,
    required this.phone,
    @JsonKey(name: 'is_default_shipping_address')
    required this.isDefaultShippingAddress,
    @JsonKey(name: 'is_default_billing_address')
    required this.isDefaultBillingAddress,
    @JsonKey(name: 'company_name') this.companyName,
    @JsonKey(name: 'street_address_2') this.streetAddress2,
    @JsonKey(name: 'city_area') this.cityArea,
  }) : super._();

  factory _$AddressDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  @JsonKey(name: 'street_address_1')
  final String streetAddress1;
  @override
  final String city;
  @override
  @JsonKey(name: 'country_area')
  final String countryArea;
  @override
  @JsonKey(name: 'postal_code')
  final String postalCode;
  @override
  final String country;
  @override
  final String phone;
  @override
  @JsonKey(name: 'is_default_shipping_address')
  final bool isDefaultShippingAddress;
  @override
  @JsonKey(name: 'is_default_billing_address')
  final bool isDefaultBillingAddress;
  @override
  @JsonKey(name: 'company_name')
  final String? companyName;
  @override
  @JsonKey(name: 'street_address_2')
  final String? streetAddress2;
  @override
  @JsonKey(name: 'city_area')
  final String? cityArea;

  @override
  String toString() {
    return 'AddressDto(id: $id, firstName: $firstName, lastName: $lastName, streetAddress1: $streetAddress1, city: $city, countryArea: $countryArea, postalCode: $postalCode, country: $country, phone: $phone, isDefaultShippingAddress: $isDefaultShippingAddress, isDefaultBillingAddress: $isDefaultBillingAddress, companyName: $companyName, streetAddress2: $streetAddress2, cityArea: $cityArea)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.streetAddress1, streetAddress1) ||
                other.streetAddress1 == streetAddress1) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.countryArea, countryArea) ||
                other.countryArea == countryArea) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(
                  other.isDefaultShippingAddress,
                  isDefaultShippingAddress,
                ) ||
                other.isDefaultShippingAddress == isDefaultShippingAddress) &&
            (identical(
                  other.isDefaultBillingAddress,
                  isDefaultBillingAddress,
                ) ||
                other.isDefaultBillingAddress == isDefaultBillingAddress) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.streetAddress2, streetAddress2) ||
                other.streetAddress2 == streetAddress2) &&
            (identical(other.cityArea, cityArea) ||
                other.cityArea == cityArea));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    firstName,
    lastName,
    streetAddress1,
    city,
    countryArea,
    postalCode,
    country,
    phone,
    isDefaultShippingAddress,
    isDefaultBillingAddress,
    companyName,
    streetAddress2,
    cityArea,
  );

  /// Create a copy of AddressDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressDtoImplCopyWith<_$AddressDtoImpl> get copyWith =>
      __$$AddressDtoImplCopyWithImpl<_$AddressDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressDtoImplToJson(this);
  }
}

abstract class _AddressDto extends AddressDto {
  const factory _AddressDto({
    required final int id,
    @JsonKey(name: 'first_name') required final String firstName,
    @JsonKey(name: 'last_name') required final String lastName,
    @JsonKey(name: 'street_address_1') required final String streetAddress1,
    required final String city,
    @JsonKey(name: 'country_area') required final String countryArea,
    @JsonKey(name: 'postal_code') required final String postalCode,
    required final String country,
    required final String phone,
    @JsonKey(name: 'is_default_shipping_address')
    required final bool isDefaultShippingAddress,
    @JsonKey(name: 'is_default_billing_address')
    required final bool isDefaultBillingAddress,
    @JsonKey(name: 'company_name') final String? companyName,
    @JsonKey(name: 'street_address_2') final String? streetAddress2,
    @JsonKey(name: 'city_area') final String? cityArea,
  }) = _$AddressDtoImpl;
  const _AddressDto._() : super._();

  factory _AddressDto.fromJson(Map<String, dynamic> json) =
      _$AddressDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  @JsonKey(name: 'street_address_1')
  String get streetAddress1;
  @override
  String get city;
  @override
  @JsonKey(name: 'country_area')
  String get countryArea;
  @override
  @JsonKey(name: 'postal_code')
  String get postalCode;
  @override
  String get country;
  @override
  String get phone;
  @override
  @JsonKey(name: 'is_default_shipping_address')
  bool get isDefaultShippingAddress;
  @override
  @JsonKey(name: 'is_default_billing_address')
  bool get isDefaultBillingAddress;
  @override
  @JsonKey(name: 'company_name')
  String? get companyName;
  @override
  @JsonKey(name: 'street_address_2')
  String? get streetAddress2;
  @override
  @JsonKey(name: 'city_area')
  String? get cityArea;

  /// Create a copy of AddressDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressDtoImplCopyWith<_$AddressDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Address {
  int get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get postalCode => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get addressType =>
      throw _privateConstructorUsedError; // 'home', 'work', 'other'
  String? get streetAddress1 => throw _privateConstructorUsedError;
  String? get streetAddress2 => throw _privateConstructorUsedError;
  String? get latitude => throw _privateConstructorUsedError;
  String? get longitude => throw _privateConstructorUsedError;
  bool get selected => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressCopyWith<Address> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) then) =
      _$AddressCopyWithImpl<$Res, Address>;
  @useResult
  $Res call({
    int id,
    String firstName,
    String lastName,
    String city,
    String state,
    String postalCode,
    String country,
    String addressType,
    String? streetAddress1,
    String? streetAddress2,
    String? latitude,
    String? longitude,
    bool selected,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$AddressCopyWithImpl<$Res, $Val extends Address>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? city = null,
    Object? state = null,
    Object? postalCode = null,
    Object? country = null,
    Object? addressType = null,
    Object? streetAddress1 = freezed,
    Object? streetAddress2 = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? selected = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String,
            postalCode: null == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            addressType: null == addressType
                ? _value.addressType
                : addressType // ignore: cast_nullable_to_non_nullable
                      as String,
            streetAddress1: freezed == streetAddress1
                ? _value.streetAddress1
                : streetAddress1 // ignore: cast_nullable_to_non_nullable
                      as String?,
            streetAddress2: freezed == streetAddress2
                ? _value.streetAddress2
                : streetAddress2 // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as String?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as String?,
            selected: null == selected
                ? _value.selected
                : selected // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddressImplCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$$AddressImplCopyWith(
    _$AddressImpl value,
    $Res Function(_$AddressImpl) then,
  ) = __$$AddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String firstName,
    String lastName,
    String city,
    String state,
    String postalCode,
    String country,
    String addressType,
    String? streetAddress1,
    String? streetAddress2,
    String? latitude,
    String? longitude,
    bool selected,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AddressImplCopyWithImpl<$Res>
    extends _$AddressCopyWithImpl<$Res, _$AddressImpl>
    implements _$$AddressImplCopyWith<$Res> {
  __$$AddressImplCopyWithImpl(
    _$AddressImpl _value,
    $Res Function(_$AddressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? city = null,
    Object? state = null,
    Object? postalCode = null,
    Object? country = null,
    Object? addressType = null,
    Object? streetAddress1 = freezed,
    Object? streetAddress2 = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? selected = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AddressImpl(
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
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        postalCode: null == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        addressType: null == addressType
            ? _value.addressType
            : addressType // ignore: cast_nullable_to_non_nullable
                  as String,
        streetAddress1: freezed == streetAddress1
            ? _value.streetAddress1
            : streetAddress1 // ignore: cast_nullable_to_non_nullable
                  as String?,
        streetAddress2: freezed == streetAddress2
            ? _value.streetAddress2
            : streetAddress2 // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as String?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as String?,
        selected: null == selected
            ? _value.selected
            : selected // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$AddressImpl extends _Address {
  const _$AddressImpl({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.addressType,
    this.streetAddress1,
    this.streetAddress2,
    this.latitude,
    this.longitude,
    this.selected = false,
    this.createdAt,
    this.updatedAt,
  }) : super._();

  @override
  final int id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String city;
  @override
  final String state;
  @override
  final String postalCode;
  @override
  final String country;
  @override
  final String addressType;
  // 'home', 'work', 'other'
  @override
  final String? streetAddress1;
  @override
  final String? streetAddress2;
  @override
  final String? latitude;
  @override
  final String? longitude;
  @override
  @JsonKey()
  final bool selected;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Address(id: $id, firstName: $firstName, lastName: $lastName, city: $city, state: $state, postalCode: $postalCode, country: $country, addressType: $addressType, streetAddress1: $streetAddress1, streetAddress2: $streetAddress2, latitude: $latitude, longitude: $longitude, selected: $selected, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.addressType, addressType) ||
                other.addressType == addressType) &&
            (identical(other.streetAddress1, streetAddress1) ||
                other.streetAddress1 == streetAddress1) &&
            (identical(other.streetAddress2, streetAddress2) ||
                other.streetAddress2 == streetAddress2) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.selected, selected) ||
                other.selected == selected) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    firstName,
    lastName,
    city,
    state,
    postalCode,
    country,
    addressType,
    streetAddress1,
    streetAddress2,
    latitude,
    longitude,
    selected,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      __$$AddressImplCopyWithImpl<_$AddressImpl>(this, _$identity);
}

abstract class _Address extends Address {
  const factory _Address({
    required final int id,
    required final String firstName,
    required final String lastName,
    required final String city,
    required final String state,
    required final String postalCode,
    required final String country,
    required final String addressType,
    final String? streetAddress1,
    final String? streetAddress2,
    final String? latitude,
    final String? longitude,
    final bool selected,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$AddressImpl;
  const _Address._() : super._();

  @override
  int get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get city;
  @override
  String get state;
  @override
  String get postalCode;
  @override
  String get country;
  @override
  String get addressType; // 'home', 'work', 'other'
  @override
  String? get streetAddress1;
  @override
  String? get streetAddress2;
  @override
  String? get latitude;
  @override
  String? get longitude;
  @override
  bool get selected;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

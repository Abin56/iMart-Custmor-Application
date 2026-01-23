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
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'postal_code')
  String get postalCode => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_type')
  String get addressType => throw _privateConstructorUsedError;
  @JsonKey(name: 'street_address_1')
  String? get streetAddress1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'street_address_2')
  String? get streetAddress2 => throw _privateConstructorUsedError;
  String? get latitude => throw _privateConstructorUsedError;
  String? get longitude => throw _privateConstructorUsedError;
  bool get selected => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

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
    String city,
    String state,
    @JsonKey(name: 'postal_code') String postalCode,
    String country,
    @JsonKey(name: 'address_type') String addressType,
    @JsonKey(name: 'street_address_1') String? streetAddress1,
    @JsonKey(name: 'street_address_2') String? streetAddress2,
    String? latitude,
    String? longitude,
    bool selected,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
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
    String city,
    String state,
    @JsonKey(name: 'postal_code') String postalCode,
    String country,
    @JsonKey(name: 'address_type') String addressType,
    @JsonKey(name: 'street_address_1') String? streetAddress1,
    @JsonKey(name: 'street_address_2') String? streetAddress2,
    String? latitude,
    String? longitude,
    bool selected,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
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
@JsonSerializable()
class _$AddressDtoImpl extends _AddressDto {
  const _$AddressDtoImpl({
    required this.id,
    @JsonKey(name: 'first_name') required this.firstName,
    @JsonKey(name: 'last_name') required this.lastName,
    required this.city,
    required this.state,
    @JsonKey(name: 'postal_code') required this.postalCode,
    required this.country,
    @JsonKey(name: 'address_type') required this.addressType,
    @JsonKey(name: 'street_address_1') this.streetAddress1,
    @JsonKey(name: 'street_address_2') this.streetAddress2,
    this.latitude,
    this.longitude,
    this.selected = false,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
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
  final String city;
  @override
  final String state;
  @override
  @JsonKey(name: 'postal_code')
  final String postalCode;
  @override
  final String country;
  @override
  @JsonKey(name: 'address_type')
  final String addressType;
  @override
  @JsonKey(name: 'street_address_1')
  final String? streetAddress1;
  @override
  @JsonKey(name: 'street_address_2')
  final String? streetAddress2;
  @override
  final String? latitude;
  @override
  final String? longitude;
  @override
  @JsonKey()
  final bool selected;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AddressDto(id: $id, firstName: $firstName, lastName: $lastName, city: $city, state: $state, postalCode: $postalCode, country: $country, addressType: $addressType, streetAddress1: $streetAddress1, streetAddress2: $streetAddress2, latitude: $latitude, longitude: $longitude, selected: $selected, createdAt: $createdAt, updatedAt: $updatedAt)';
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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
    required final String city,
    required final String state,
    @JsonKey(name: 'postal_code') required final String postalCode,
    required final String country,
    @JsonKey(name: 'address_type') required final String addressType,
    @JsonKey(name: 'street_address_1') final String? streetAddress1,
    @JsonKey(name: 'street_address_2') final String? streetAddress2,
    final String? latitude,
    final String? longitude,
    final bool selected,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
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
  String get city;
  @override
  String get state;
  @override
  @JsonKey(name: 'postal_code')
  String get postalCode;
  @override
  String get country;
  @override
  @JsonKey(name: 'address_type')
  String get addressType;
  @override
  @JsonKey(name: 'street_address_1')
  String? get streetAddress1;
  @override
  @JsonKey(name: 'street_address_2')
  String? get streetAddress2;
  @override
  String? get latitude;
  @override
  String? get longitude;
  @override
  bool get selected;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of AddressDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressDtoImplCopyWith<_$AddressDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AddressListResponseDto _$AddressListResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _AddressListResponseDto.fromJson(json);
}

/// @nodoc
mixin _$AddressListResponseDto {
  int get count => throw _privateConstructorUsedError;
  List<AddressDto> get results => throw _privateConstructorUsedError;
  String? get next => throw _privateConstructorUsedError;
  String? get previous => throw _privateConstructorUsedError;

  /// Serializes this AddressListResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddressListResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressListResponseDtoCopyWith<AddressListResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressListResponseDtoCopyWith<$Res> {
  factory $AddressListResponseDtoCopyWith(
    AddressListResponseDto value,
    $Res Function(AddressListResponseDto) then,
  ) = _$AddressListResponseDtoCopyWithImpl<$Res, AddressListResponseDto>;
  @useResult
  $Res call({
    int count,
    List<AddressDto> results,
    String? next,
    String? previous,
  });
}

/// @nodoc
class _$AddressListResponseDtoCopyWithImpl<
  $Res,
  $Val extends AddressListResponseDto
>
    implements $AddressListResponseDtoCopyWith<$Res> {
  _$AddressListResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddressListResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? results = null,
    Object? next = freezed,
    Object? previous = freezed,
  }) {
    return _then(
      _value.copyWith(
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            results: null == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<AddressDto>,
            next: freezed == next
                ? _value.next
                : next // ignore: cast_nullable_to_non_nullable
                      as String?,
            previous: freezed == previous
                ? _value.previous
                : previous // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddressListResponseDtoImplCopyWith<$Res>
    implements $AddressListResponseDtoCopyWith<$Res> {
  factory _$$AddressListResponseDtoImplCopyWith(
    _$AddressListResponseDtoImpl value,
    $Res Function(_$AddressListResponseDtoImpl) then,
  ) = __$$AddressListResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int count,
    List<AddressDto> results,
    String? next,
    String? previous,
  });
}

/// @nodoc
class __$$AddressListResponseDtoImplCopyWithImpl<$Res>
    extends
        _$AddressListResponseDtoCopyWithImpl<$Res, _$AddressListResponseDtoImpl>
    implements _$$AddressListResponseDtoImplCopyWith<$Res> {
  __$$AddressListResponseDtoImplCopyWithImpl(
    _$AddressListResponseDtoImpl _value,
    $Res Function(_$AddressListResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddressListResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? results = null,
    Object? next = freezed,
    Object? previous = freezed,
  }) {
    return _then(
      _$AddressListResponseDtoImpl(
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<AddressDto>,
        next: freezed == next
            ? _value.next
            : next // ignore: cast_nullable_to_non_nullable
                  as String?,
        previous: freezed == previous
            ? _value.previous
            : previous // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressListResponseDtoImpl implements _AddressListResponseDto {
  const _$AddressListResponseDtoImpl({
    required this.count,
    required final List<AddressDto> results,
    this.next,
    this.previous,
  }) : _results = results;

  factory _$AddressListResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressListResponseDtoImplFromJson(json);

  @override
  final int count;
  final List<AddressDto> _results;
  @override
  List<AddressDto> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  final String? next;
  @override
  final String? previous;

  @override
  String toString() {
    return 'AddressListResponseDto(count: $count, results: $results, next: $next, previous: $previous)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressListResponseDtoImpl &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.next, next) || other.next == next) &&
            (identical(other.previous, previous) ||
                other.previous == previous));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    const DeepCollectionEquality().hash(_results),
    next,
    previous,
  );

  /// Create a copy of AddressListResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressListResponseDtoImplCopyWith<_$AddressListResponseDtoImpl>
  get copyWith =>
      __$$AddressListResponseDtoImplCopyWithImpl<_$AddressListResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressListResponseDtoImplToJson(this);
  }
}

abstract class _AddressListResponseDto implements AddressListResponseDto {
  const factory _AddressListResponseDto({
    required final int count,
    required final List<AddressDto> results,
    final String? next,
    final String? previous,
  }) = _$AddressListResponseDtoImpl;

  factory _AddressListResponseDto.fromJson(Map<String, dynamic> json) =
      _$AddressListResponseDtoImpl.fromJson;

  @override
  int get count;
  @override
  List<AddressDto> get results;
  @override
  String? get next;
  @override
  String? get previous;

  /// Create a copy of AddressListResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressListResponseDtoImplCopyWith<_$AddressListResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

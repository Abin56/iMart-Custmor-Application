// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CouponDto _$CouponDtoFromJson(Map<String, dynamic> json) {
  return _CouponDto.fromJson(json);
}

/// @nodoc
mixin _$CouponDto {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_percentage')
  String get discountPercentage => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  bool get status => throw _privateConstructorUsedError;
  int get usage => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CouponDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CouponDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CouponDtoCopyWith<CouponDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponDtoCopyWith<$Res> {
  factory $CouponDtoCopyWith(CouponDto value, $Res Function(CouponDto) then) =
      _$CouponDtoCopyWithImpl<$Res, CouponDto>;
  @useResult
  $Res call({
    int id,
    String name,
    String description,
    @JsonKey(name: 'discount_percentage') String discountPercentage,
    int limit,
    bool status,
    int usage,
    @JsonKey(name: 'start_date') DateTime startDate,
    @JsonKey(name: 'end_date') DateTime endDate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$CouponDtoCopyWithImpl<$Res, $Val extends CouponDto>
    implements $CouponDtoCopyWith<$Res> {
  _$CouponDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CouponDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? discountPercentage = null,
    Object? limit = null,
    Object? status = null,
    Object? usage = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            discountPercentage: null == discountPercentage
                ? _value.discountPercentage
                : discountPercentage // ignore: cast_nullable_to_non_nullable
                      as String,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as bool,
            usage: null == usage
                ? _value.usage
                : usage // ignore: cast_nullable_to_non_nullable
                      as int,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CouponDtoImplCopyWith<$Res>
    implements $CouponDtoCopyWith<$Res> {
  factory _$$CouponDtoImplCopyWith(
    _$CouponDtoImpl value,
    $Res Function(_$CouponDtoImpl) then,
  ) = __$$CouponDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String description,
    @JsonKey(name: 'discount_percentage') String discountPercentage,
    int limit,
    bool status,
    int usage,
    @JsonKey(name: 'start_date') DateTime startDate,
    @JsonKey(name: 'end_date') DateTime endDate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$CouponDtoImplCopyWithImpl<$Res>
    extends _$CouponDtoCopyWithImpl<$Res, _$CouponDtoImpl>
    implements _$$CouponDtoImplCopyWith<$Res> {
  __$$CouponDtoImplCopyWithImpl(
    _$CouponDtoImpl _value,
    $Res Function(_$CouponDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CouponDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? discountPercentage = null,
    Object? limit = null,
    Object? status = null,
    Object? usage = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CouponDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        discountPercentage: null == discountPercentage
            ? _value.discountPercentage
            : discountPercentage // ignore: cast_nullable_to_non_nullable
                  as String,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as bool,
        usage: null == usage
            ? _value.usage
            : usage // ignore: cast_nullable_to_non_nullable
                  as int,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CouponDtoImpl extends _CouponDto {
  const _$CouponDtoImpl({
    required this.id,
    required this.name,
    required this.description,
    @JsonKey(name: 'discount_percentage') required this.discountPercentage,
    required this.limit,
    required this.status,
    required this.usage,
    @JsonKey(name: 'start_date') required this.startDate,
    @JsonKey(name: 'end_date') required this.endDate,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : super._();

  factory _$CouponDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CouponDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey(name: 'discount_percentage')
  final String discountPercentage;
  @override
  final int limit;
  @override
  final bool status;
  @override
  final int usage;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CouponDto(id: $id, name: $name, description: $description, discountPercentage: $discountPercentage, limit: $limit, status: $status, usage: $usage, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.discountPercentage, discountPercentage) ||
                other.discountPercentage == discountPercentage) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
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
    name,
    description,
    discountPercentage,
    limit,
    status,
    usage,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CouponDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponDtoImplCopyWith<_$CouponDtoImpl> get copyWith =>
      __$$CouponDtoImplCopyWithImpl<_$CouponDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CouponDtoImplToJson(this);
  }
}

abstract class _CouponDto extends CouponDto {
  const factory _CouponDto({
    required final int id,
    required final String name,
    required final String description,
    @JsonKey(name: 'discount_percentage')
    required final String discountPercentage,
    required final int limit,
    required final bool status,
    required final int usage,
    @JsonKey(name: 'start_date') required final DateTime startDate,
    @JsonKey(name: 'end_date') required final DateTime endDate,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$CouponDtoImpl;
  const _CouponDto._() : super._();

  factory _CouponDto.fromJson(Map<String, dynamic> json) =
      _$CouponDtoImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'discount_percentage')
  String get discountPercentage;
  @override
  int get limit;
  @override
  bool get status;
  @override
  int get usage;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime get endDate;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of CouponDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CouponDtoImplCopyWith<_$CouponDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

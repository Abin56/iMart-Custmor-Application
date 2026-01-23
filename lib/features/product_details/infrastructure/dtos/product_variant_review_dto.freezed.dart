// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_variant_review_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductVariantReviewDto _$ProductVariantReviewDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ProductVariantReviewDto.fromJson(json);
}

/// @nodoc
mixin _$ProductVariantReviewDto {
  int get id => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String? get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ProductVariantReviewDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariantReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantReviewDtoCopyWith<ProductVariantReviewDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantReviewDtoCopyWith<$Res> {
  factory $ProductVariantReviewDtoCopyWith(
    ProductVariantReviewDto value,
    $Res Function(ProductVariantReviewDto) then,
  ) = _$ProductVariantReviewDtoCopyWithImpl<$Res, ProductVariantReviewDto>;
  @useResult
  $Res call({
    int id,
    double rating,
    String? comment,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'created_at') String? createdAt,
  });
}

/// @nodoc
class _$ProductVariantReviewDtoCopyWithImpl<
  $Res,
  $Val extends ProductVariantReviewDto
>
    implements $ProductVariantReviewDtoCopyWith<$Res> {
  _$ProductVariantReviewDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariantReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? userName = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductVariantReviewDtoImplCopyWith<$Res>
    implements $ProductVariantReviewDtoCopyWith<$Res> {
  factory _$$ProductVariantReviewDtoImplCopyWith(
    _$ProductVariantReviewDtoImpl value,
    $Res Function(_$ProductVariantReviewDtoImpl) then,
  ) = __$$ProductVariantReviewDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    double rating,
    String? comment,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'created_at') String? createdAt,
  });
}

/// @nodoc
class __$$ProductVariantReviewDtoImplCopyWithImpl<$Res>
    extends
        _$ProductVariantReviewDtoCopyWithImpl<
          $Res,
          _$ProductVariantReviewDtoImpl
        >
    implements _$$ProductVariantReviewDtoImplCopyWith<$Res> {
  __$$ProductVariantReviewDtoImplCopyWithImpl(
    _$ProductVariantReviewDtoImpl _value,
    $Res Function(_$ProductVariantReviewDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariantReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? userName = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ProductVariantReviewDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariantReviewDtoImpl implements _ProductVariantReviewDto {
  const _$ProductVariantReviewDtoImpl({
    required this.id,
    required this.rating,
    this.comment,
    @JsonKey(name: 'user_name') this.userName,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$ProductVariantReviewDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantReviewDtoImplFromJson(json);

  @override
  final int id;
  @override
  final double rating;
  @override
  final String? comment;
  @override
  @JsonKey(name: 'user_name')
  final String? userName;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'ProductVariantReviewDto(id: $id, rating: $rating, comment: $comment, userName: $userName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantReviewDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, rating, comment, userName, createdAt);

  /// Create a copy of ProductVariantReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantReviewDtoImplCopyWith<_$ProductVariantReviewDtoImpl>
  get copyWith =>
      __$$ProductVariantReviewDtoImplCopyWithImpl<
        _$ProductVariantReviewDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantReviewDtoImplToJson(this);
  }
}

abstract class _ProductVariantReviewDto implements ProductVariantReviewDto {
  const factory _ProductVariantReviewDto({
    required final int id,
    required final double rating,
    final String? comment,
    @JsonKey(name: 'user_name') final String? userName,
    @JsonKey(name: 'created_at') final String? createdAt,
  }) = _$ProductVariantReviewDtoImpl;

  factory _ProductVariantReviewDto.fromJson(Map<String, dynamic> json) =
      _$ProductVariantReviewDtoImpl.fromJson;

  @override
  int get id;
  @override
  double get rating;
  @override
  String? get comment;
  @override
  @JsonKey(name: 'user_name')
  String? get userName;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of ProductVariantReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantReviewDtoImplCopyWith<_$ProductVariantReviewDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

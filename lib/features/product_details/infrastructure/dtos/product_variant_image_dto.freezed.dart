// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_variant_image_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductVariantImageDto _$ProductVariantImageDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ProductVariantImageDto.fromJson(json);
}

/// @nodoc
mixin _$ProductVariantImageDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'image')
  String get url => throw _privateConstructorUsedError;
  int? get position => throw _privateConstructorUsedError;

  /// Serializes this ProductVariantImageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariantImageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantImageDtoCopyWith<ProductVariantImageDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantImageDtoCopyWith<$Res> {
  factory $ProductVariantImageDtoCopyWith(
    ProductVariantImageDto value,
    $Res Function(ProductVariantImageDto) then,
  ) = _$ProductVariantImageDtoCopyWithImpl<$Res, ProductVariantImageDto>;
  @useResult
  $Res call({int id, @JsonKey(name: 'image') String url, int? position});
}

/// @nodoc
class _$ProductVariantImageDtoCopyWithImpl<
  $Res,
  $Val extends ProductVariantImageDto
>
    implements $ProductVariantImageDtoCopyWith<$Res> {
  _$ProductVariantImageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariantImageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? position = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            position: freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductVariantImageDtoImplCopyWith<$Res>
    implements $ProductVariantImageDtoCopyWith<$Res> {
  factory _$$ProductVariantImageDtoImplCopyWith(
    _$ProductVariantImageDtoImpl value,
    $Res Function(_$ProductVariantImageDtoImpl) then,
  ) = __$$ProductVariantImageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, @JsonKey(name: 'image') String url, int? position});
}

/// @nodoc
class __$$ProductVariantImageDtoImplCopyWithImpl<$Res>
    extends
        _$ProductVariantImageDtoCopyWithImpl<$Res, _$ProductVariantImageDtoImpl>
    implements _$$ProductVariantImageDtoImplCopyWith<$Res> {
  __$$ProductVariantImageDtoImplCopyWithImpl(
    _$ProductVariantImageDtoImpl _value,
    $Res Function(_$ProductVariantImageDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariantImageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? position = freezed,
  }) {
    return _then(
      _$ProductVariantImageDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        position: freezed == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariantImageDtoImpl implements _ProductVariantImageDto {
  const _$ProductVariantImageDtoImpl({
    required this.id,
    @JsonKey(name: 'image') required this.url,
    this.position,
  });

  factory _$ProductVariantImageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantImageDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'image')
  final String url;
  @override
  final int? position;

  @override
  String toString() {
    return 'ProductVariantImageDto(id: $id, url: $url, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantImageDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, position);

  /// Create a copy of ProductVariantImageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantImageDtoImplCopyWith<_$ProductVariantImageDtoImpl>
  get copyWith =>
      __$$ProductVariantImageDtoImplCopyWithImpl<_$ProductVariantImageDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantImageDtoImplToJson(this);
  }
}

abstract class _ProductVariantImageDto implements ProductVariantImageDto {
  const factory _ProductVariantImageDto({
    required final int id,
    @JsonKey(name: 'image') required final String url,
    final int? position,
  }) = _$ProductVariantImageDtoImpl;

  factory _ProductVariantImageDto.fromJson(Map<String, dynamic> json) =
      _$ProductVariantImageDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'image')
  String get url;
  @override
  int? get position;

  /// Create a copy of ProductVariantImageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantImageDtoImplCopyWith<_$ProductVariantImageDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

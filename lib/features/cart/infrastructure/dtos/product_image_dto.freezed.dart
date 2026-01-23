// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_image_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductImageDto _$ProductImageDtoFromJson(Map<String, dynamic> json) {
  return _ProductImageDto.fromJson(json);
}

/// @nodoc
mixin _$ProductImageDto {
  int get id => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  String? get alt => throw _privateConstructorUsedError;

  /// Serializes this ProductImageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductImageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductImageDtoCopyWith<ProductImageDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductImageDtoCopyWith<$Res> {
  factory $ProductImageDtoCopyWith(
    ProductImageDto value,
    $Res Function(ProductImageDto) then,
  ) = _$ProductImageDtoCopyWithImpl<$Res, ProductImageDto>;
  @useResult
  $Res call({int id, String image, String? alt});
}

/// @nodoc
class _$ProductImageDtoCopyWithImpl<$Res, $Val extends ProductImageDto>
    implements $ProductImageDtoCopyWith<$Res> {
  _$ProductImageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductImageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? image = null, Object? alt = freezed}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            image: null == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String,
            alt: freezed == alt
                ? _value.alt
                : alt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImageDtoImplCopyWith<$Res>
    implements $ProductImageDtoCopyWith<$Res> {
  factory _$$ProductImageDtoImplCopyWith(
    _$ProductImageDtoImpl value,
    $Res Function(_$ProductImageDtoImpl) then,
  ) = __$$ProductImageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String image, String? alt});
}

/// @nodoc
class __$$ProductImageDtoImplCopyWithImpl<$Res>
    extends _$ProductImageDtoCopyWithImpl<$Res, _$ProductImageDtoImpl>
    implements _$$ProductImageDtoImplCopyWith<$Res> {
  __$$ProductImageDtoImplCopyWithImpl(
    _$ProductImageDtoImpl _value,
    $Res Function(_$ProductImageDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductImageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? image = null, Object? alt = freezed}) {
    return _then(
      _$ProductImageDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        image: null == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String,
        alt: freezed == alt
            ? _value.alt
            : alt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImageDtoImpl extends _ProductImageDto {
  const _$ProductImageDtoImpl({required this.id, required this.image, this.alt})
    : super._();

  factory _$ProductImageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImageDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String image;
  @override
  final String? alt;

  @override
  String toString() {
    return 'ProductImageDto(id: $id, image: $image, alt: $alt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImageDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.alt, alt) || other.alt == alt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, image, alt);

  /// Create a copy of ProductImageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImageDtoImplCopyWith<_$ProductImageDtoImpl> get copyWith =>
      __$$ProductImageDtoImplCopyWithImpl<_$ProductImageDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImageDtoImplToJson(this);
  }
}

abstract class _ProductImageDto extends ProductImageDto {
  const factory _ProductImageDto({
    required final int id,
    required final String image,
    final String? alt,
  }) = _$ProductImageDtoImpl;
  const _ProductImageDto._() : super._();

  factory _ProductImageDto.fromJson(Map<String, dynamic> json) =
      _$ProductImageDtoImpl.fromJson;

  @override
  int get id;
  @override
  String get image;
  @override
  String? get alt;

  /// Create a copy of ProductImageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImageDtoImplCopyWith<_$ProductImageDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

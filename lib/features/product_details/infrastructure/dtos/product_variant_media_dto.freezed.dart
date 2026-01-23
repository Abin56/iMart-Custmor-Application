// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_variant_media_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductVariantMediaDto _$ProductVariantMediaDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ProductVariantMediaDto.fromJson(json);
}

/// @nodoc
mixin _$ProductVariantMediaDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'image')
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_path')
  String? get filePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'alt')
  String? get alt => throw _privateConstructorUsedError;
  int? get position => throw _privateConstructorUsedError;

  /// Serializes this ProductVariantMediaDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariantMediaDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantMediaDtoCopyWith<ProductVariantMediaDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantMediaDtoCopyWith<$Res> {
  factory $ProductVariantMediaDtoCopyWith(
    ProductVariantMediaDto value,
    $Res Function(ProductVariantMediaDto) then,
  ) = _$ProductVariantMediaDtoCopyWithImpl<$Res, ProductVariantMediaDto>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'image') String url,
    @JsonKey(name: 'file_path') String? filePath,
    @JsonKey(name: 'alt') String? alt,
    int? position,
  });
}

/// @nodoc
class _$ProductVariantMediaDtoCopyWithImpl<
  $Res,
  $Val extends ProductVariantMediaDto
>
    implements $ProductVariantMediaDtoCopyWith<$Res> {
  _$ProductVariantMediaDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariantMediaDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? filePath = freezed,
    Object? alt = freezed,
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
            filePath: freezed == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            alt: freezed == alt
                ? _value.alt
                : alt // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$ProductVariantMediaDtoImplCopyWith<$Res>
    implements $ProductVariantMediaDtoCopyWith<$Res> {
  factory _$$ProductVariantMediaDtoImplCopyWith(
    _$ProductVariantMediaDtoImpl value,
    $Res Function(_$ProductVariantMediaDtoImpl) then,
  ) = __$$ProductVariantMediaDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'image') String url,
    @JsonKey(name: 'file_path') String? filePath,
    @JsonKey(name: 'alt') String? alt,
    int? position,
  });
}

/// @nodoc
class __$$ProductVariantMediaDtoImplCopyWithImpl<$Res>
    extends
        _$ProductVariantMediaDtoCopyWithImpl<$Res, _$ProductVariantMediaDtoImpl>
    implements _$$ProductVariantMediaDtoImplCopyWith<$Res> {
  __$$ProductVariantMediaDtoImplCopyWithImpl(
    _$ProductVariantMediaDtoImpl _value,
    $Res Function(_$ProductVariantMediaDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariantMediaDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? filePath = freezed,
    Object? alt = freezed,
    Object? position = freezed,
  }) {
    return _then(
      _$ProductVariantMediaDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: freezed == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        alt: freezed == alt
            ? _value.alt
            : alt // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$ProductVariantMediaDtoImpl implements _ProductVariantMediaDto {
  const _$ProductVariantMediaDtoImpl({
    required this.id,
    @JsonKey(name: 'image') required this.url,
    @JsonKey(name: 'file_path') this.filePath,
    @JsonKey(name: 'alt') this.alt,
    this.position,
  });

  factory _$ProductVariantMediaDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantMediaDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'image')
  final String url;
  @override
  @JsonKey(name: 'file_path')
  final String? filePath;
  @override
  @JsonKey(name: 'alt')
  final String? alt;
  @override
  final int? position;

  @override
  String toString() {
    return 'ProductVariantMediaDto(id: $id, url: $url, filePath: $filePath, alt: $alt, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantMediaDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.alt, alt) || other.alt == alt) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, url, filePath, alt, position);

  /// Create a copy of ProductVariantMediaDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantMediaDtoImplCopyWith<_$ProductVariantMediaDtoImpl>
  get copyWith =>
      __$$ProductVariantMediaDtoImplCopyWithImpl<_$ProductVariantMediaDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantMediaDtoImplToJson(this);
  }
}

abstract class _ProductVariantMediaDto implements ProductVariantMediaDto {
  const factory _ProductVariantMediaDto({
    required final int id,
    @JsonKey(name: 'image') required final String url,
    @JsonKey(name: 'file_path') final String? filePath,
    @JsonKey(name: 'alt') final String? alt,
    final int? position,
  }) = _$ProductVariantMediaDtoImpl;

  factory _ProductVariantMediaDto.fromJson(Map<String, dynamic> json) =
      _$ProductVariantMediaDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'image')
  String get url;
  @override
  @JsonKey(name: 'file_path')
  String? get filePath;
  @override
  @JsonKey(name: 'alt')
  String? get alt;
  @override
  int? get position;

  /// Create a copy of ProductVariantMediaDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantMediaDtoImplCopyWith<_$ProductVariantMediaDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

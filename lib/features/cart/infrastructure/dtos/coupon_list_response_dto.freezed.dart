// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon_list_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CouponListResponseDto _$CouponListResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CouponListResponseDto.fromJson(json);
}

/// @nodoc
mixin _$CouponListResponseDto {
  int get count => throw _privateConstructorUsedError;
  List<CouponDto> get results => throw _privateConstructorUsedError;
  String? get next => throw _privateConstructorUsedError;
  String? get previous => throw _privateConstructorUsedError;

  /// Serializes this CouponListResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CouponListResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CouponListResponseDtoCopyWith<CouponListResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponListResponseDtoCopyWith<$Res> {
  factory $CouponListResponseDtoCopyWith(
    CouponListResponseDto value,
    $Res Function(CouponListResponseDto) then,
  ) = _$CouponListResponseDtoCopyWithImpl<$Res, CouponListResponseDto>;
  @useResult
  $Res call({
    int count,
    List<CouponDto> results,
    String? next,
    String? previous,
  });
}

/// @nodoc
class _$CouponListResponseDtoCopyWithImpl<
  $Res,
  $Val extends CouponListResponseDto
>
    implements $CouponListResponseDtoCopyWith<$Res> {
  _$CouponListResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CouponListResponseDto
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
                      as List<CouponDto>,
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
abstract class _$$CouponListResponseDtoImplCopyWith<$Res>
    implements $CouponListResponseDtoCopyWith<$Res> {
  factory _$$CouponListResponseDtoImplCopyWith(
    _$CouponListResponseDtoImpl value,
    $Res Function(_$CouponListResponseDtoImpl) then,
  ) = __$$CouponListResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int count,
    List<CouponDto> results,
    String? next,
    String? previous,
  });
}

/// @nodoc
class __$$CouponListResponseDtoImplCopyWithImpl<$Res>
    extends
        _$CouponListResponseDtoCopyWithImpl<$Res, _$CouponListResponseDtoImpl>
    implements _$$CouponListResponseDtoImplCopyWith<$Res> {
  __$$CouponListResponseDtoImplCopyWithImpl(
    _$CouponListResponseDtoImpl _value,
    $Res Function(_$CouponListResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CouponListResponseDto
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
      _$CouponListResponseDtoImpl(
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<CouponDto>,
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
class _$CouponListResponseDtoImpl extends _CouponListResponseDto {
  const _$CouponListResponseDtoImpl({
    required this.count,
    required final List<CouponDto> results,
    this.next,
    this.previous,
  }) : _results = results,
       super._();

  factory _$CouponListResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CouponListResponseDtoImplFromJson(json);

  @override
  final int count;
  final List<CouponDto> _results;
  @override
  List<CouponDto> get results {
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
    return 'CouponListResponseDto(count: $count, results: $results, next: $next, previous: $previous)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponListResponseDtoImpl &&
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

  /// Create a copy of CouponListResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponListResponseDtoImplCopyWith<_$CouponListResponseDtoImpl>
  get copyWith =>
      __$$CouponListResponseDtoImplCopyWithImpl<_$CouponListResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CouponListResponseDtoImplToJson(this);
  }
}

abstract class _CouponListResponseDto extends CouponListResponseDto {
  const factory _CouponListResponseDto({
    required final int count,
    required final List<CouponDto> results,
    final String? next,
    final String? previous,
  }) = _$CouponListResponseDtoImpl;
  const _CouponListResponseDto._() : super._();

  factory _CouponListResponseDto.fromJson(Map<String, dynamic> json) =
      _$CouponListResponseDtoImpl.fromJson;

  @override
  int get count;
  @override
  List<CouponDto> get results;
  @override
  String? get next;
  @override
  String? get previous;

  /// Create a copy of CouponListResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CouponListResponseDtoImplCopyWith<_$CouponListResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_lines_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CheckoutLinesResponseDto _$CheckoutLinesResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CheckoutLinesResponseDto.fromJson(json);
}

/// @nodoc
mixin _$CheckoutLinesResponseDto {
  int get count => throw _privateConstructorUsedError;
  List<CheckoutLineDto> get results => throw _privateConstructorUsedError;
  String? get next => throw _privateConstructorUsedError;
  String? get previous => throw _privateConstructorUsedError;

  /// Serializes this CheckoutLinesResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckoutLinesResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckoutLinesResponseDtoCopyWith<CheckoutLinesResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutLinesResponseDtoCopyWith<$Res> {
  factory $CheckoutLinesResponseDtoCopyWith(
    CheckoutLinesResponseDto value,
    $Res Function(CheckoutLinesResponseDto) then,
  ) = _$CheckoutLinesResponseDtoCopyWithImpl<$Res, CheckoutLinesResponseDto>;
  @useResult
  $Res call({
    int count,
    List<CheckoutLineDto> results,
    String? next,
    String? previous,
  });
}

/// @nodoc
class _$CheckoutLinesResponseDtoCopyWithImpl<
  $Res,
  $Val extends CheckoutLinesResponseDto
>
    implements $CheckoutLinesResponseDtoCopyWith<$Res> {
  _$CheckoutLinesResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckoutLinesResponseDto
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
                      as List<CheckoutLineDto>,
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
abstract class _$$CheckoutLinesResponseDtoImplCopyWith<$Res>
    implements $CheckoutLinesResponseDtoCopyWith<$Res> {
  factory _$$CheckoutLinesResponseDtoImplCopyWith(
    _$CheckoutLinesResponseDtoImpl value,
    $Res Function(_$CheckoutLinesResponseDtoImpl) then,
  ) = __$$CheckoutLinesResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int count,
    List<CheckoutLineDto> results,
    String? next,
    String? previous,
  });
}

/// @nodoc
class __$$CheckoutLinesResponseDtoImplCopyWithImpl<$Res>
    extends
        _$CheckoutLinesResponseDtoCopyWithImpl<
          $Res,
          _$CheckoutLinesResponseDtoImpl
        >
    implements _$$CheckoutLinesResponseDtoImplCopyWith<$Res> {
  __$$CheckoutLinesResponseDtoImplCopyWithImpl(
    _$CheckoutLinesResponseDtoImpl _value,
    $Res Function(_$CheckoutLinesResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CheckoutLinesResponseDto
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
      _$CheckoutLinesResponseDtoImpl(
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<CheckoutLineDto>,
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
class _$CheckoutLinesResponseDtoImpl extends _CheckoutLinesResponseDto {
  const _$CheckoutLinesResponseDtoImpl({
    required this.count,
    required final List<CheckoutLineDto> results,
    this.next,
    this.previous,
  }) : _results = results,
       super._();

  factory _$CheckoutLinesResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckoutLinesResponseDtoImplFromJson(json);

  @override
  final int count;
  final List<CheckoutLineDto> _results;
  @override
  List<CheckoutLineDto> get results {
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
    return 'CheckoutLinesResponseDto(count: $count, results: $results, next: $next, previous: $previous)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckoutLinesResponseDtoImpl &&
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

  /// Create a copy of CheckoutLinesResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckoutLinesResponseDtoImplCopyWith<_$CheckoutLinesResponseDtoImpl>
  get copyWith =>
      __$$CheckoutLinesResponseDtoImplCopyWithImpl<
        _$CheckoutLinesResponseDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckoutLinesResponseDtoImplToJson(this);
  }
}

abstract class _CheckoutLinesResponseDto extends CheckoutLinesResponseDto {
  const factory _CheckoutLinesResponseDto({
    required final int count,
    required final List<CheckoutLineDto> results,
    final String? next,
    final String? previous,
  }) = _$CheckoutLinesResponseDtoImpl;
  const _CheckoutLinesResponseDto._() : super._();

  factory _CheckoutLinesResponseDto.fromJson(Map<String, dynamic> json) =
      _$CheckoutLinesResponseDtoImpl.fromJson;

  @override
  int get count;
  @override
  List<CheckoutLineDto> get results;
  @override
  String? get next;
  @override
  String? get previous;

  /// Create a copy of CheckoutLinesResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckoutLinesResponseDtoImplCopyWith<_$CheckoutLinesResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

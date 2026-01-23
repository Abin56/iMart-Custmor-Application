// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_list_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

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
class _$AddressListResponseDtoImpl extends _AddressListResponseDto {
  const _$AddressListResponseDtoImpl({
    required this.count,
    required final List<AddressDto> results,
    this.next,
    this.previous,
  }) : _results = results,
       super._();

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

abstract class _AddressListResponseDto extends AddressListResponseDto {
  const factory _AddressListResponseDto({
    required final int count,
    required final List<AddressDto> results,
    final String? next,
    final String? previous,
  }) = _$AddressListResponseDtoImpl;
  const _AddressListResponseDto._() : super._();

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

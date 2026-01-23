// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_verification_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentVerificationDto _$PaymentVerificationDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PaymentVerificationDto.fromJson(json);
}

/// @nodoc
mixin _$PaymentVerificationDto {
  bool get success =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'order_id')
  int get orderId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this PaymentVerificationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentVerificationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentVerificationDtoCopyWith<PaymentVerificationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentVerificationDtoCopyWith<$Res> {
  factory $PaymentVerificationDtoCopyWith(
    PaymentVerificationDto value,
    $Res Function(PaymentVerificationDto) then,
  ) = _$PaymentVerificationDtoCopyWithImpl<$Res, PaymentVerificationDto>;
  @useResult
  $Res call({
    bool success,
    @JsonKey(name: 'order_id') int orderId,
    String message,
  });
}

/// @nodoc
class _$PaymentVerificationDtoCopyWithImpl<
  $Res,
  $Val extends PaymentVerificationDto
>
    implements $PaymentVerificationDtoCopyWith<$Res> {
  _$PaymentVerificationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentVerificationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? orderId = null,
    Object? message = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as int,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentVerificationDtoImplCopyWith<$Res>
    implements $PaymentVerificationDtoCopyWith<$Res> {
  factory _$$PaymentVerificationDtoImplCopyWith(
    _$PaymentVerificationDtoImpl value,
    $Res Function(_$PaymentVerificationDtoImpl) then,
  ) = __$$PaymentVerificationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    @JsonKey(name: 'order_id') int orderId,
    String message,
  });
}

/// @nodoc
class __$$PaymentVerificationDtoImplCopyWithImpl<$Res>
    extends
        _$PaymentVerificationDtoCopyWithImpl<$Res, _$PaymentVerificationDtoImpl>
    implements _$$PaymentVerificationDtoImplCopyWith<$Res> {
  __$$PaymentVerificationDtoImplCopyWithImpl(
    _$PaymentVerificationDtoImpl _value,
    $Res Function(_$PaymentVerificationDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentVerificationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? orderId = null,
    Object? message = null,
  }) {
    return _then(
      _$PaymentVerificationDtoImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as int,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentVerificationDtoImpl extends _PaymentVerificationDto {
  const _$PaymentVerificationDtoImpl({
    required this.success,
    @JsonKey(name: 'order_id') required this.orderId,
    required this.message,
  }) : super._();

  factory _$PaymentVerificationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentVerificationDtoImplFromJson(json);

  @override
  final bool success;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'order_id')
  final int orderId;
  @override
  final String message;

  @override
  String toString() {
    return 'PaymentVerificationDto(success: $success, orderId: $orderId, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentVerificationDtoImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, orderId, message);

  /// Create a copy of PaymentVerificationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentVerificationDtoImplCopyWith<_$PaymentVerificationDtoImpl>
  get copyWith =>
      __$$PaymentVerificationDtoImplCopyWithImpl<_$PaymentVerificationDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentVerificationDtoImplToJson(this);
  }
}

abstract class _PaymentVerificationDto extends PaymentVerificationDto {
  const factory _PaymentVerificationDto({
    required final bool success,
    @JsonKey(name: 'order_id') required final int orderId,
    required final String message,
  }) = _$PaymentVerificationDtoImpl;
  const _PaymentVerificationDto._() : super._();

  factory _PaymentVerificationDto.fromJson(Map<String, dynamic> json) =
      _$PaymentVerificationDtoImpl.fromJson;

  @override
  bool get success; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'order_id')
  int get orderId;
  @override
  String get message;

  /// Create a copy of PaymentVerificationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentVerificationDtoImplCopyWith<_$PaymentVerificationDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

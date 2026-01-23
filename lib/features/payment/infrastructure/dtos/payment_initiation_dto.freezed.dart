// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_initiation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentInitiationDto _$PaymentInitiationDtoFromJson(Map<String, dynamic> json) {
  return _PaymentInitiationDto.fromJson(json);
}

/// @nodoc
mixin _$PaymentInitiationDto {
  // ignore: invalid_annotation_target
  @JsonKey(name: 'razorpay_order_id')
  String get razorpayOrderId => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'razorpay_key')
  String get razorpayKey => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'amount', fromJson: _amountFromJson)
  String get amount => throw _privateConstructorUsedError;
  String get currency =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'order_id')
  int get orderId => throw _privateConstructorUsedError;

  /// Serializes this PaymentInitiationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentInitiationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentInitiationDtoCopyWith<PaymentInitiationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentInitiationDtoCopyWith<$Res> {
  factory $PaymentInitiationDtoCopyWith(
    PaymentInitiationDto value,
    $Res Function(PaymentInitiationDto) then,
  ) = _$PaymentInitiationDtoCopyWithImpl<$Res, PaymentInitiationDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'razorpay_order_id') String razorpayOrderId,
    @JsonKey(name: 'razorpay_key') String razorpayKey,
    @JsonKey(name: 'amount', fromJson: _amountFromJson) String amount,
    String currency,
    @JsonKey(name: 'order_id') int orderId,
  });
}

/// @nodoc
class _$PaymentInitiationDtoCopyWithImpl<
  $Res,
  $Val extends PaymentInitiationDto
>
    implements $PaymentInitiationDtoCopyWith<$Res> {
  _$PaymentInitiationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentInitiationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? razorpayOrderId = null,
    Object? razorpayKey = null,
    Object? amount = null,
    Object? currency = null,
    Object? orderId = null,
  }) {
    return _then(
      _value.copyWith(
            razorpayOrderId: null == razorpayOrderId
                ? _value.razorpayOrderId
                : razorpayOrderId // ignore: cast_nullable_to_non_nullable
                      as String,
            razorpayKey: null == razorpayKey
                ? _value.razorpayKey
                : razorpayKey // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentInitiationDtoImplCopyWith<$Res>
    implements $PaymentInitiationDtoCopyWith<$Res> {
  factory _$$PaymentInitiationDtoImplCopyWith(
    _$PaymentInitiationDtoImpl value,
    $Res Function(_$PaymentInitiationDtoImpl) then,
  ) = __$$PaymentInitiationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'razorpay_order_id') String razorpayOrderId,
    @JsonKey(name: 'razorpay_key') String razorpayKey,
    @JsonKey(name: 'amount', fromJson: _amountFromJson) String amount,
    String currency,
    @JsonKey(name: 'order_id') int orderId,
  });
}

/// @nodoc
class __$$PaymentInitiationDtoImplCopyWithImpl<$Res>
    extends _$PaymentInitiationDtoCopyWithImpl<$Res, _$PaymentInitiationDtoImpl>
    implements _$$PaymentInitiationDtoImplCopyWith<$Res> {
  __$$PaymentInitiationDtoImplCopyWithImpl(
    _$PaymentInitiationDtoImpl _value,
    $Res Function(_$PaymentInitiationDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentInitiationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? razorpayOrderId = null,
    Object? razorpayKey = null,
    Object? amount = null,
    Object? currency = null,
    Object? orderId = null,
  }) {
    return _then(
      _$PaymentInitiationDtoImpl(
        razorpayOrderId: null == razorpayOrderId
            ? _value.razorpayOrderId
            : razorpayOrderId // ignore: cast_nullable_to_non_nullable
                  as String,
        razorpayKey: null == razorpayKey
            ? _value.razorpayKey
            : razorpayKey // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentInitiationDtoImpl extends _PaymentInitiationDto {
  const _$PaymentInitiationDtoImpl({
    @JsonKey(name: 'razorpay_order_id') required this.razorpayOrderId,
    @JsonKey(name: 'razorpay_key') required this.razorpayKey,
    @JsonKey(name: 'amount', fromJson: _amountFromJson) required this.amount,
    required this.currency,
    @JsonKey(name: 'order_id') required this.orderId,
  }) : super._();

  factory _$PaymentInitiationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentInitiationDtoImplFromJson(json);

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'razorpay_order_id')
  final String razorpayOrderId;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'razorpay_key')
  final String razorpayKey;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'amount', fromJson: _amountFromJson)
  final String amount;
  @override
  final String currency;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'order_id')
  final int orderId;

  @override
  String toString() {
    return 'PaymentInitiationDto(razorpayOrderId: $razorpayOrderId, razorpayKey: $razorpayKey, amount: $amount, currency: $currency, orderId: $orderId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentInitiationDtoImpl &&
            (identical(other.razorpayOrderId, razorpayOrderId) ||
                other.razorpayOrderId == razorpayOrderId) &&
            (identical(other.razorpayKey, razorpayKey) ||
                other.razorpayKey == razorpayKey) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.orderId, orderId) || other.orderId == orderId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    razorpayOrderId,
    razorpayKey,
    amount,
    currency,
    orderId,
  );

  /// Create a copy of PaymentInitiationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentInitiationDtoImplCopyWith<_$PaymentInitiationDtoImpl>
  get copyWith =>
      __$$PaymentInitiationDtoImplCopyWithImpl<_$PaymentInitiationDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentInitiationDtoImplToJson(this);
  }
}

abstract class _PaymentInitiationDto extends PaymentInitiationDto {
  const factory _PaymentInitiationDto({
    @JsonKey(name: 'razorpay_order_id') required final String razorpayOrderId,
    @JsonKey(name: 'razorpay_key') required final String razorpayKey,
    @JsonKey(name: 'amount', fromJson: _amountFromJson)
    required final String amount,
    required final String currency,
    @JsonKey(name: 'order_id') required final int orderId,
  }) = _$PaymentInitiationDtoImpl;
  const _PaymentInitiationDto._() : super._();

  factory _PaymentInitiationDto.fromJson(Map<String, dynamic> json) =
      _$PaymentInitiationDtoImpl.fromJson;

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'razorpay_order_id')
  String get razorpayOrderId; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'razorpay_key')
  String get razorpayKey; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'amount', fromJson: _amountFromJson)
  String get amount;
  @override
  String get currency; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'order_id')
  int get orderId;

  /// Create a copy of PaymentInitiationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentInitiationDtoImplCopyWith<_$PaymentInitiationDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

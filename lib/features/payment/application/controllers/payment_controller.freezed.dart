// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaymentState {
  PaymentStatus get status => throw _privateConstructorUsedError;
  PaymentInitiation? get paymentInitiation =>
      throw _privateConstructorUsedError;
  PaymentVerification? get paymentVerification =>
      throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentStateCopyWith<PaymentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentStateCopyWith<$Res> {
  factory $PaymentStateCopyWith(
    PaymentState value,
    $Res Function(PaymentState) then,
  ) = _$PaymentStateCopyWithImpl<$Res, PaymentState>;
  @useResult
  $Res call({
    PaymentStatus status,
    PaymentInitiation? paymentInitiation,
    PaymentVerification? paymentVerification,
    String? errorMessage,
  });
}

/// @nodoc
class _$PaymentStateCopyWithImpl<$Res, $Val extends PaymentState>
    implements $PaymentStateCopyWith<$Res> {
  _$PaymentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? paymentInitiation = freezed,
    Object? paymentVerification = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PaymentStatus,
            paymentInitiation: freezed == paymentInitiation
                ? _value.paymentInitiation
                : paymentInitiation // ignore: cast_nullable_to_non_nullable
                      as PaymentInitiation?,
            paymentVerification: freezed == paymentVerification
                ? _value.paymentVerification
                : paymentVerification // ignore: cast_nullable_to_non_nullable
                      as PaymentVerification?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentStateImplCopyWith<$Res>
    implements $PaymentStateCopyWith<$Res> {
  factory _$$PaymentStateImplCopyWith(
    _$PaymentStateImpl value,
    $Res Function(_$PaymentStateImpl) then,
  ) = __$$PaymentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PaymentStatus status,
    PaymentInitiation? paymentInitiation,
    PaymentVerification? paymentVerification,
    String? errorMessage,
  });
}

/// @nodoc
class __$$PaymentStateImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentStateImpl>
    implements _$$PaymentStateImplCopyWith<$Res> {
  __$$PaymentStateImplCopyWithImpl(
    _$PaymentStateImpl _value,
    $Res Function(_$PaymentStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? paymentInitiation = freezed,
    Object? paymentVerification = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$PaymentStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PaymentStatus,
        paymentInitiation: freezed == paymentInitiation
            ? _value.paymentInitiation
            : paymentInitiation // ignore: cast_nullable_to_non_nullable
                  as PaymentInitiation?,
        paymentVerification: freezed == paymentVerification
            ? _value.paymentVerification
            : paymentVerification // ignore: cast_nullable_to_non_nullable
                  as PaymentVerification?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PaymentStateImpl implements _PaymentState {
  const _$PaymentStateImpl({
    this.status = PaymentStatus.initial,
    this.paymentInitiation,
    this.paymentVerification,
    this.errorMessage,
  });

  @override
  @JsonKey()
  final PaymentStatus status;
  @override
  final PaymentInitiation? paymentInitiation;
  @override
  final PaymentVerification? paymentVerification;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PaymentState(status: $status, paymentInitiation: $paymentInitiation, paymentVerification: $paymentVerification, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentInitiation, paymentInitiation) ||
                other.paymentInitiation == paymentInitiation) &&
            (identical(other.paymentVerification, paymentVerification) ||
                other.paymentVerification == paymentVerification) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    paymentInitiation,
    paymentVerification,
    errorMessage,
  );

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentStateImplCopyWith<_$PaymentStateImpl> get copyWith =>
      __$$PaymentStateImplCopyWithImpl<_$PaymentStateImpl>(this, _$identity);
}

abstract class _PaymentState implements PaymentState {
  const factory _PaymentState({
    final PaymentStatus status,
    final PaymentInitiation? paymentInitiation,
    final PaymentVerification? paymentVerification,
    final String? errorMessage,
  }) = _$PaymentStateImpl;

  @override
  PaymentStatus get status;
  @override
  PaymentInitiation? get paymentInitiation;
  @override
  PaymentVerification? get paymentVerification;
  @override
  String? get errorMessage;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentStateImplCopyWith<_$PaymentStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

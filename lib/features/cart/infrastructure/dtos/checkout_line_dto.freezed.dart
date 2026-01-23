// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_line_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CheckoutLineDto _$CheckoutLineDtoFromJson(Map<String, dynamic> json) {
  return _CheckoutLineDto.fromJson(json);
}

/// @nodoc
mixin _$CheckoutLineDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_variant_id')
  int get productVariantId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_variant_details')
  ProductVariantDetailsDto get productVariantDetails =>
      throw _privateConstructorUsedError;
  int? get checkout => throw _privateConstructorUsedError;

  /// Serializes this CheckoutLineDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckoutLineDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckoutLineDtoCopyWith<CheckoutLineDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutLineDtoCopyWith<$Res> {
  factory $CheckoutLineDtoCopyWith(
    CheckoutLineDto value,
    $Res Function(CheckoutLineDto) then,
  ) = _$CheckoutLineDtoCopyWithImpl<$Res, CheckoutLineDto>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'product_variant_id') int productVariantId,
    int quantity,
    @JsonKey(name: 'product_variant_details')
    ProductVariantDetailsDto productVariantDetails,
    int? checkout,
  });

  $ProductVariantDetailsDtoCopyWith<$Res> get productVariantDetails;
}

/// @nodoc
class _$CheckoutLineDtoCopyWithImpl<$Res, $Val extends CheckoutLineDto>
    implements $CheckoutLineDtoCopyWith<$Res> {
  _$CheckoutLineDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckoutLineDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productVariantId = null,
    Object? quantity = null,
    Object? productVariantDetails = null,
    Object? checkout = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            productVariantId: null == productVariantId
                ? _value.productVariantId
                : productVariantId // ignore: cast_nullable_to_non_nullable
                      as int,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            productVariantDetails: null == productVariantDetails
                ? _value.productVariantDetails
                : productVariantDetails // ignore: cast_nullable_to_non_nullable
                      as ProductVariantDetailsDto,
            checkout: freezed == checkout
                ? _value.checkout
                : checkout // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of CheckoutLineDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductVariantDetailsDtoCopyWith<$Res> get productVariantDetails {
    return $ProductVariantDetailsDtoCopyWith<$Res>(
      _value.productVariantDetails,
      (value) {
        return _then(_value.copyWith(productVariantDetails: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$CheckoutLineDtoImplCopyWith<$Res>
    implements $CheckoutLineDtoCopyWith<$Res> {
  factory _$$CheckoutLineDtoImplCopyWith(
    _$CheckoutLineDtoImpl value,
    $Res Function(_$CheckoutLineDtoImpl) then,
  ) = __$$CheckoutLineDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'product_variant_id') int productVariantId,
    int quantity,
    @JsonKey(name: 'product_variant_details')
    ProductVariantDetailsDto productVariantDetails,
    int? checkout,
  });

  @override
  $ProductVariantDetailsDtoCopyWith<$Res> get productVariantDetails;
}

/// @nodoc
class __$$CheckoutLineDtoImplCopyWithImpl<$Res>
    extends _$CheckoutLineDtoCopyWithImpl<$Res, _$CheckoutLineDtoImpl>
    implements _$$CheckoutLineDtoImplCopyWith<$Res> {
  __$$CheckoutLineDtoImplCopyWithImpl(
    _$CheckoutLineDtoImpl _value,
    $Res Function(_$CheckoutLineDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CheckoutLineDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productVariantId = null,
    Object? quantity = null,
    Object? productVariantDetails = null,
    Object? checkout = freezed,
  }) {
    return _then(
      _$CheckoutLineDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        productVariantId: null == productVariantId
            ? _value.productVariantId
            : productVariantId // ignore: cast_nullable_to_non_nullable
                  as int,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        productVariantDetails: null == productVariantDetails
            ? _value.productVariantDetails
            : productVariantDetails // ignore: cast_nullable_to_non_nullable
                  as ProductVariantDetailsDto,
        checkout: freezed == checkout
            ? _value.checkout
            : checkout // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckoutLineDtoImpl extends _CheckoutLineDto {
  const _$CheckoutLineDtoImpl({
    required this.id,
    @JsonKey(name: 'product_variant_id') required this.productVariantId,
    required this.quantity,
    @JsonKey(name: 'product_variant_details')
    required this.productVariantDetails,
    this.checkout,
  }) : super._();

  factory _$CheckoutLineDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckoutLineDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'product_variant_id')
  final int productVariantId;
  @override
  final int quantity;
  @override
  @JsonKey(name: 'product_variant_details')
  final ProductVariantDetailsDto productVariantDetails;
  @override
  final int? checkout;

  @override
  String toString() {
    return 'CheckoutLineDto(id: $id, productVariantId: $productVariantId, quantity: $quantity, productVariantDetails: $productVariantDetails, checkout: $checkout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckoutLineDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productVariantId, productVariantId) ||
                other.productVariantId == productVariantId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.productVariantDetails, productVariantDetails) ||
                other.productVariantDetails == productVariantDetails) &&
            (identical(other.checkout, checkout) ||
                other.checkout == checkout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    productVariantId,
    quantity,
    productVariantDetails,
    checkout,
  );

  /// Create a copy of CheckoutLineDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckoutLineDtoImplCopyWith<_$CheckoutLineDtoImpl> get copyWith =>
      __$$CheckoutLineDtoImplCopyWithImpl<_$CheckoutLineDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckoutLineDtoImplToJson(this);
  }
}

abstract class _CheckoutLineDto extends CheckoutLineDto {
  const factory _CheckoutLineDto({
    required final int id,
    @JsonKey(name: 'product_variant_id') required final int productVariantId,
    required final int quantity,
    @JsonKey(name: 'product_variant_details')
    required final ProductVariantDetailsDto productVariantDetails,
    final int? checkout,
  }) = _$CheckoutLineDtoImpl;
  const _CheckoutLineDto._() : super._();

  factory _CheckoutLineDto.fromJson(Map<String, dynamic> json) =
      _$CheckoutLineDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'product_variant_id')
  int get productVariantId;
  @override
  int get quantity;
  @override
  @JsonKey(name: 'product_variant_details')
  ProductVariantDetailsDto get productVariantDetails;
  @override
  int? get checkout;

  /// Create a copy of CheckoutLineDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckoutLineDtoImplCopyWith<_$CheckoutLineDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

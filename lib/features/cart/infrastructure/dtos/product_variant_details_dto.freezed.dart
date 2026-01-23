// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_variant_details_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductVariantDetailsDto _$ProductVariantDetailsDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ProductVariantDetailsDto.fromJson(json);
}

/// @nodoc
mixin _$ProductVariantDetailsDto {
  int get id => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_quantity')
  int get currentQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  int? get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'discounted_price')
  String? get discountedPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantity_limit_per_customer')
  int? get quantityLimitPerCustomer => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_preorder')
  bool? get isPreorder => throw _privateConstructorUsedError;
  @JsonKey(name: 'preorder_global_threshold')
  int? get preorderGlobalThreshold => throw _privateConstructorUsedError;
  List<ProductImageDto>? get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'preorder_end_date')
  DateTime? get preorderEndDate => throw _privateConstructorUsedError;

  /// Serializes this ProductVariantDetailsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariantDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantDetailsDtoCopyWith<ProductVariantDetailsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantDetailsDtoCopyWith<$Res> {
  factory $ProductVariantDetailsDtoCopyWith(
    ProductVariantDetailsDto value,
    $Res Function(ProductVariantDetailsDto) then,
  ) = _$ProductVariantDetailsDtoCopyWithImpl<$Res, ProductVariantDetailsDto>;
  @useResult
  $Res call({
    int id,
    String sku,
    String name,
    String price,
    @JsonKey(name: 'current_quantity') int currentQuantity,
    @JsonKey(name: 'product_id') int? productId,
    @JsonKey(name: 'discounted_price') String? discountedPrice,
    @JsonKey(name: 'track_inventory') bool? trackInventory,
    @JsonKey(name: 'quantity_limit_per_customer') int? quantityLimitPerCustomer,
    @JsonKey(name: 'is_preorder') bool? isPreorder,
    @JsonKey(name: 'preorder_global_threshold') int? preorderGlobalThreshold,
    List<ProductImageDto>? images,
    @JsonKey(name: 'preorder_end_date') DateTime? preorderEndDate,
  });
}

/// @nodoc
class _$ProductVariantDetailsDtoCopyWithImpl<
  $Res,
  $Val extends ProductVariantDetailsDto
>
    implements $ProductVariantDetailsDtoCopyWith<$Res> {
  _$ProductVariantDetailsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariantDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sku = null,
    Object? name = null,
    Object? price = null,
    Object? currentQuantity = null,
    Object? productId = freezed,
    Object? discountedPrice = freezed,
    Object? trackInventory = freezed,
    Object? quantityLimitPerCustomer = freezed,
    Object? isPreorder = freezed,
    Object? preorderGlobalThreshold = freezed,
    Object? images = freezed,
    Object? preorderEndDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            sku: null == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
            currentQuantity: null == currentQuantity
                ? _value.currentQuantity
                : currentQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as int?,
            discountedPrice: freezed == discountedPrice
                ? _value.discountedPrice
                : discountedPrice // ignore: cast_nullable_to_non_nullable
                      as String?,
            trackInventory: freezed == trackInventory
                ? _value.trackInventory
                : trackInventory // ignore: cast_nullable_to_non_nullable
                      as bool?,
            quantityLimitPerCustomer: freezed == quantityLimitPerCustomer
                ? _value.quantityLimitPerCustomer
                : quantityLimitPerCustomer // ignore: cast_nullable_to_non_nullable
                      as int?,
            isPreorder: freezed == isPreorder
                ? _value.isPreorder
                : isPreorder // ignore: cast_nullable_to_non_nullable
                      as bool?,
            preorderGlobalThreshold: freezed == preorderGlobalThreshold
                ? _value.preorderGlobalThreshold
                : preorderGlobalThreshold // ignore: cast_nullable_to_non_nullable
                      as int?,
            images: freezed == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<ProductImageDto>?,
            preorderEndDate: freezed == preorderEndDate
                ? _value.preorderEndDate
                : preorderEndDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductVariantDetailsDtoImplCopyWith<$Res>
    implements $ProductVariantDetailsDtoCopyWith<$Res> {
  factory _$$ProductVariantDetailsDtoImplCopyWith(
    _$ProductVariantDetailsDtoImpl value,
    $Res Function(_$ProductVariantDetailsDtoImpl) then,
  ) = __$$ProductVariantDetailsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String sku,
    String name,
    String price,
    @JsonKey(name: 'current_quantity') int currentQuantity,
    @JsonKey(name: 'product_id') int? productId,
    @JsonKey(name: 'discounted_price') String? discountedPrice,
    @JsonKey(name: 'track_inventory') bool? trackInventory,
    @JsonKey(name: 'quantity_limit_per_customer') int? quantityLimitPerCustomer,
    @JsonKey(name: 'is_preorder') bool? isPreorder,
    @JsonKey(name: 'preorder_global_threshold') int? preorderGlobalThreshold,
    List<ProductImageDto>? images,
    @JsonKey(name: 'preorder_end_date') DateTime? preorderEndDate,
  });
}

/// @nodoc
class __$$ProductVariantDetailsDtoImplCopyWithImpl<$Res>
    extends
        _$ProductVariantDetailsDtoCopyWithImpl<
          $Res,
          _$ProductVariantDetailsDtoImpl
        >
    implements _$$ProductVariantDetailsDtoImplCopyWith<$Res> {
  __$$ProductVariantDetailsDtoImplCopyWithImpl(
    _$ProductVariantDetailsDtoImpl _value,
    $Res Function(_$ProductVariantDetailsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariantDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sku = null,
    Object? name = null,
    Object? price = null,
    Object? currentQuantity = null,
    Object? productId = freezed,
    Object? discountedPrice = freezed,
    Object? trackInventory = freezed,
    Object? quantityLimitPerCustomer = freezed,
    Object? isPreorder = freezed,
    Object? preorderGlobalThreshold = freezed,
    Object? images = freezed,
    Object? preorderEndDate = freezed,
  }) {
    return _then(
      _$ProductVariantDetailsDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        sku: null == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
        currentQuantity: null == currentQuantity
            ? _value.currentQuantity
            : currentQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as int?,
        discountedPrice: freezed == discountedPrice
            ? _value.discountedPrice
            : discountedPrice // ignore: cast_nullable_to_non_nullable
                  as String?,
        trackInventory: freezed == trackInventory
            ? _value.trackInventory
            : trackInventory // ignore: cast_nullable_to_non_nullable
                  as bool?,
        quantityLimitPerCustomer: freezed == quantityLimitPerCustomer
            ? _value.quantityLimitPerCustomer
            : quantityLimitPerCustomer // ignore: cast_nullable_to_non_nullable
                  as int?,
        isPreorder: freezed == isPreorder
            ? _value.isPreorder
            : isPreorder // ignore: cast_nullable_to_non_nullable
                  as bool?,
        preorderGlobalThreshold: freezed == preorderGlobalThreshold
            ? _value.preorderGlobalThreshold
            : preorderGlobalThreshold // ignore: cast_nullable_to_non_nullable
                  as int?,
        images: freezed == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<ProductImageDto>?,
        preorderEndDate: freezed == preorderEndDate
            ? _value.preorderEndDate
            : preorderEndDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariantDetailsDtoImpl extends _ProductVariantDetailsDto {
  const _$ProductVariantDetailsDtoImpl({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    @JsonKey(name: 'current_quantity') required this.currentQuantity,
    @JsonKey(name: 'product_id') this.productId,
    @JsonKey(name: 'discounted_price') this.discountedPrice,
    @JsonKey(name: 'track_inventory') this.trackInventory,
    @JsonKey(name: 'quantity_limit_per_customer') this.quantityLimitPerCustomer,
    @JsonKey(name: 'is_preorder') this.isPreorder,
    @JsonKey(name: 'preorder_global_threshold') this.preorderGlobalThreshold,
    final List<ProductImageDto>? images,
    @JsonKey(name: 'preorder_end_date') this.preorderEndDate,
  }) : _images = images,
       super._();

  factory _$ProductVariantDetailsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantDetailsDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String sku;
  @override
  final String name;
  @override
  final String price;
  @override
  @JsonKey(name: 'current_quantity')
  final int currentQuantity;
  @override
  @JsonKey(name: 'product_id')
  final int? productId;
  @override
  @JsonKey(name: 'discounted_price')
  final String? discountedPrice;
  @override
  @JsonKey(name: 'track_inventory')
  final bool? trackInventory;
  @override
  @JsonKey(name: 'quantity_limit_per_customer')
  final int? quantityLimitPerCustomer;
  @override
  @JsonKey(name: 'is_preorder')
  final bool? isPreorder;
  @override
  @JsonKey(name: 'preorder_global_threshold')
  final int? preorderGlobalThreshold;
  final List<ProductImageDto>? _images;
  @override
  List<ProductImageDto>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'preorder_end_date')
  final DateTime? preorderEndDate;

  @override
  String toString() {
    return 'ProductVariantDetailsDto(id: $id, sku: $sku, name: $name, price: $price, currentQuantity: $currentQuantity, productId: $productId, discountedPrice: $discountedPrice, trackInventory: $trackInventory, quantityLimitPerCustomer: $quantityLimitPerCustomer, isPreorder: $isPreorder, preorderGlobalThreshold: $preorderGlobalThreshold, images: $images, preorderEndDate: $preorderEndDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantDetailsDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currentQuantity, currentQuantity) ||
                other.currentQuantity == currentQuantity) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.discountedPrice, discountedPrice) ||
                other.discountedPrice == discountedPrice) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory) &&
            (identical(
                  other.quantityLimitPerCustomer,
                  quantityLimitPerCustomer,
                ) ||
                other.quantityLimitPerCustomer == quantityLimitPerCustomer) &&
            (identical(other.isPreorder, isPreorder) ||
                other.isPreorder == isPreorder) &&
            (identical(
                  other.preorderGlobalThreshold,
                  preorderGlobalThreshold,
                ) ||
                other.preorderGlobalThreshold == preorderGlobalThreshold) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.preorderEndDate, preorderEndDate) ||
                other.preorderEndDate == preorderEndDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sku,
    name,
    price,
    currentQuantity,
    productId,
    discountedPrice,
    trackInventory,
    quantityLimitPerCustomer,
    isPreorder,
    preorderGlobalThreshold,
    const DeepCollectionEquality().hash(_images),
    preorderEndDate,
  );

  /// Create a copy of ProductVariantDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantDetailsDtoImplCopyWith<_$ProductVariantDetailsDtoImpl>
  get copyWith =>
      __$$ProductVariantDetailsDtoImplCopyWithImpl<
        _$ProductVariantDetailsDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantDetailsDtoImplToJson(this);
  }
}

abstract class _ProductVariantDetailsDto extends ProductVariantDetailsDto {
  const factory _ProductVariantDetailsDto({
    required final int id,
    required final String sku,
    required final String name,
    required final String price,
    @JsonKey(name: 'current_quantity') required final int currentQuantity,
    @JsonKey(name: 'product_id') final int? productId,
    @JsonKey(name: 'discounted_price') final String? discountedPrice,
    @JsonKey(name: 'track_inventory') final bool? trackInventory,
    @JsonKey(name: 'quantity_limit_per_customer')
    final int? quantityLimitPerCustomer,
    @JsonKey(name: 'is_preorder') final bool? isPreorder,
    @JsonKey(name: 'preorder_global_threshold')
    final int? preorderGlobalThreshold,
    final List<ProductImageDto>? images,
    @JsonKey(name: 'preorder_end_date') final DateTime? preorderEndDate,
  }) = _$ProductVariantDetailsDtoImpl;
  const _ProductVariantDetailsDto._() : super._();

  factory _ProductVariantDetailsDto.fromJson(Map<String, dynamic> json) =
      _$ProductVariantDetailsDtoImpl.fromJson;

  @override
  int get id;
  @override
  String get sku;
  @override
  String get name;
  @override
  String get price;
  @override
  @JsonKey(name: 'current_quantity')
  int get currentQuantity;
  @override
  @JsonKey(name: 'product_id')
  int? get productId;
  @override
  @JsonKey(name: 'discounted_price')
  String? get discountedPrice;
  @override
  @JsonKey(name: 'track_inventory')
  bool? get trackInventory;
  @override
  @JsonKey(name: 'quantity_limit_per_customer')
  int? get quantityLimitPerCustomer;
  @override
  @JsonKey(name: 'is_preorder')
  bool? get isPreorder;
  @override
  @JsonKey(name: 'preorder_global_threshold')
  int? get preorderGlobalThreshold;
  @override
  List<ProductImageDto>? get images;
  @override
  @JsonKey(name: 'preorder_end_date')
  DateTime? get preorderEndDate;

  /// Create a copy of ProductVariantDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantDetailsDtoImplCopyWith<_$ProductVariantDetailsDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_variant_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductVariantDto _$ProductVariantDtoFromJson(Map<String, dynamic> json) {
  return _ProductVariantDto.fromJson(json);
}

/// @nodoc
mixin _$ProductVariantDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  int get productId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _priceFromJson)
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_quantity', fromJson: _stockFromJson)
  int get stock => throw _privateConstructorUsedError;
  @JsonKey(name: 'discounted_price', fromJson: _nullableDoubleFromJson)
  double? get discountedPrice => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _nullableDoubleFromJson)
  double? get weight => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  @JsonKey(name: 'prod_description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_stock_unit')
  String? get stockUnit => throw _privateConstructorUsedError;
  List<ProductVariantImageDto> get images => throw _privateConstructorUsedError;
  List<ProductVariantMediaDto> get media => throw _privateConstructorUsedError;
  List<ProductVariantReviewDto> get reviews =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'product_rating', fromJson: _nullableDoubleFromJson)
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count', fromJson: _intFromJson)
  int get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_wishlisted')
  bool get isWishlisted => throw _privateConstructorUsedError;

  /// Serializes this ProductVariantDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantDtoCopyWith<ProductVariantDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantDtoCopyWith<$Res> {
  factory $ProductVariantDtoCopyWith(
    ProductVariantDto value,
    $Res Function(ProductVariantDto) then,
  ) = _$ProductVariantDtoCopyWithImpl<$Res, ProductVariantDto>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'product_id') int productId,
    String name,
    @JsonKey(fromJson: _priceFromJson) double price,
    @JsonKey(name: 'current_quantity', fromJson: _stockFromJson) int stock,
    @JsonKey(name: 'discounted_price', fromJson: _nullableDoubleFromJson)
    double? discountedPrice,
    String? sku,
    String? size,
    String? color,
    @JsonKey(fromJson: _nullableDoubleFromJson) double? weight,
    String? unit,
    @JsonKey(name: 'prod_description') String? description,
    @JsonKey(name: 'current_stock_unit') String? stockUnit,
    List<ProductVariantImageDto> images,
    List<ProductVariantMediaDto> media,
    List<ProductVariantReviewDto> reviews,
    @JsonKey(name: 'product_rating', fromJson: _nullableDoubleFromJson)
    double? averageRating,
    @JsonKey(name: 'review_count', fromJson: _intFromJson) int reviewCount,
    @JsonKey(name: 'is_wishlisted') bool isWishlisted,
  });
}

/// @nodoc
class _$ProductVariantDtoCopyWithImpl<$Res, $Val extends ProductVariantDto>
    implements $ProductVariantDtoCopyWith<$Res> {
  _$ProductVariantDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariantDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? name = null,
    Object? price = null,
    Object? stock = null,
    Object? discountedPrice = freezed,
    Object? sku = freezed,
    Object? size = freezed,
    Object? color = freezed,
    Object? weight = freezed,
    Object? unit = freezed,
    Object? description = freezed,
    Object? stockUnit = freezed,
    Object? images = null,
    Object? media = null,
    Object? reviews = null,
    Object? averageRating = freezed,
    Object? reviewCount = null,
    Object? isWishlisted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
            discountedPrice: freezed == discountedPrice
                ? _value.discountedPrice
                : discountedPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            sku: freezed == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String?,
            size: freezed == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double?,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            stockUnit: freezed == stockUnit
                ? _value.stockUnit
                : stockUnit // ignore: cast_nullable_to_non_nullable
                      as String?,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<ProductVariantImageDto>,
            media: null == media
                ? _value.media
                : media // ignore: cast_nullable_to_non_nullable
                      as List<ProductVariantMediaDto>,
            reviews: null == reviews
                ? _value.reviews
                : reviews // ignore: cast_nullable_to_non_nullable
                      as List<ProductVariantReviewDto>,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isWishlisted: null == isWishlisted
                ? _value.isWishlisted
                : isWishlisted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductVariantDtoImplCopyWith<$Res>
    implements $ProductVariantDtoCopyWith<$Res> {
  factory _$$ProductVariantDtoImplCopyWith(
    _$ProductVariantDtoImpl value,
    $Res Function(_$ProductVariantDtoImpl) then,
  ) = __$$ProductVariantDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'product_id') int productId,
    String name,
    @JsonKey(fromJson: _priceFromJson) double price,
    @JsonKey(name: 'current_quantity', fromJson: _stockFromJson) int stock,
    @JsonKey(name: 'discounted_price', fromJson: _nullableDoubleFromJson)
    double? discountedPrice,
    String? sku,
    String? size,
    String? color,
    @JsonKey(fromJson: _nullableDoubleFromJson) double? weight,
    String? unit,
    @JsonKey(name: 'prod_description') String? description,
    @JsonKey(name: 'current_stock_unit') String? stockUnit,
    List<ProductVariantImageDto> images,
    List<ProductVariantMediaDto> media,
    List<ProductVariantReviewDto> reviews,
    @JsonKey(name: 'product_rating', fromJson: _nullableDoubleFromJson)
    double? averageRating,
    @JsonKey(name: 'review_count', fromJson: _intFromJson) int reviewCount,
    @JsonKey(name: 'is_wishlisted') bool isWishlisted,
  });
}

/// @nodoc
class __$$ProductVariantDtoImplCopyWithImpl<$Res>
    extends _$ProductVariantDtoCopyWithImpl<$Res, _$ProductVariantDtoImpl>
    implements _$$ProductVariantDtoImplCopyWith<$Res> {
  __$$ProductVariantDtoImplCopyWithImpl(
    _$ProductVariantDtoImpl _value,
    $Res Function(_$ProductVariantDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariantDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? name = null,
    Object? price = null,
    Object? stock = null,
    Object? discountedPrice = freezed,
    Object? sku = freezed,
    Object? size = freezed,
    Object? color = freezed,
    Object? weight = freezed,
    Object? unit = freezed,
    Object? description = freezed,
    Object? stockUnit = freezed,
    Object? images = null,
    Object? media = null,
    Object? reviews = null,
    Object? averageRating = freezed,
    Object? reviewCount = null,
    Object? isWishlisted = null,
  }) {
    return _then(
      _$ProductVariantDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
        discountedPrice: freezed == discountedPrice
            ? _value.discountedPrice
            : discountedPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        sku: freezed == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String?,
        size: freezed == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double?,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        stockUnit: freezed == stockUnit
            ? _value.stockUnit
            : stockUnit // ignore: cast_nullable_to_non_nullable
                  as String?,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<ProductVariantImageDto>,
        media: null == media
            ? _value._media
            : media // ignore: cast_nullable_to_non_nullable
                  as List<ProductVariantMediaDto>,
        reviews: null == reviews
            ? _value._reviews
            : reviews // ignore: cast_nullable_to_non_nullable
                  as List<ProductVariantReviewDto>,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isWishlisted: null == isWishlisted
            ? _value.isWishlisted
            : isWishlisted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariantDtoImpl implements _ProductVariantDto {
  const _$ProductVariantDtoImpl({
    required this.id,
    @JsonKey(name: 'product_id') required this.productId,
    required this.name,
    @JsonKey(fromJson: _priceFromJson) required this.price,
    @JsonKey(name: 'current_quantity', fromJson: _stockFromJson)
    required this.stock,
    @JsonKey(name: 'discounted_price', fromJson: _nullableDoubleFromJson)
    this.discountedPrice,
    this.sku,
    this.size,
    this.color,
    @JsonKey(fromJson: _nullableDoubleFromJson) this.weight,
    this.unit,
    @JsonKey(name: 'prod_description') this.description,
    @JsonKey(name: 'current_stock_unit') this.stockUnit,
    final List<ProductVariantImageDto> images = const [],
    final List<ProductVariantMediaDto> media = const [],
    final List<ProductVariantReviewDto> reviews = const [],
    @JsonKey(name: 'product_rating', fromJson: _nullableDoubleFromJson)
    this.averageRating,
    @JsonKey(name: 'review_count', fromJson: _intFromJson) this.reviewCount = 0,
    @JsonKey(name: 'is_wishlisted') this.isWishlisted = false,
  }) : _images = images,
       _media = media,
       _reviews = reviews;

  factory _$ProductVariantDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'product_id')
  final int productId;
  @override
  final String name;
  @override
  @JsonKey(fromJson: _priceFromJson)
  final double price;
  @override
  @JsonKey(name: 'current_quantity', fromJson: _stockFromJson)
  final int stock;
  @override
  @JsonKey(name: 'discounted_price', fromJson: _nullableDoubleFromJson)
  final double? discountedPrice;
  @override
  final String? sku;
  @override
  final String? size;
  @override
  final String? color;
  @override
  @JsonKey(fromJson: _nullableDoubleFromJson)
  final double? weight;
  @override
  final String? unit;
  @override
  @JsonKey(name: 'prod_description')
  final String? description;
  @override
  @JsonKey(name: 'current_stock_unit')
  final String? stockUnit;
  final List<ProductVariantImageDto> _images;
  @override
  @JsonKey()
  List<ProductVariantImageDto> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<ProductVariantMediaDto> _media;
  @override
  @JsonKey()
  List<ProductVariantMediaDto> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  final List<ProductVariantReviewDto> _reviews;
  @override
  @JsonKey()
  List<ProductVariantReviewDto> get reviews {
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviews);
  }

  @override
  @JsonKey(name: 'product_rating', fromJson: _nullableDoubleFromJson)
  final double? averageRating;
  @override
  @JsonKey(name: 'review_count', fromJson: _intFromJson)
  final int reviewCount;
  @override
  @JsonKey(name: 'is_wishlisted')
  final bool isWishlisted;

  @override
  String toString() {
    return 'ProductVariantDto(id: $id, productId: $productId, name: $name, price: $price, stock: $stock, discountedPrice: $discountedPrice, sku: $sku, size: $size, color: $color, weight: $weight, unit: $unit, description: $description, stockUnit: $stockUnit, images: $images, media: $media, reviews: $reviews, averageRating: $averageRating, reviewCount: $reviewCount, isWishlisted: $isWishlisted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.discountedPrice, discountedPrice) ||
                other.discountedPrice == discountedPrice) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.stockUnit, stockUnit) ||
                other.stockUnit == stockUnit) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.isWishlisted, isWishlisted) ||
                other.isWishlisted == isWishlisted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    productId,
    name,
    price,
    stock,
    discountedPrice,
    sku,
    size,
    color,
    weight,
    unit,
    description,
    stockUnit,
    const DeepCollectionEquality().hash(_images),
    const DeepCollectionEquality().hash(_media),
    const DeepCollectionEquality().hash(_reviews),
    averageRating,
    reviewCount,
    isWishlisted,
  ]);

  /// Create a copy of ProductVariantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantDtoImplCopyWith<_$ProductVariantDtoImpl> get copyWith =>
      __$$ProductVariantDtoImplCopyWithImpl<_$ProductVariantDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantDtoImplToJson(this);
  }
}

abstract class _ProductVariantDto implements ProductVariantDto {
  const factory _ProductVariantDto({
    required final int id,
    @JsonKey(name: 'product_id') required final int productId,
    required final String name,
    @JsonKey(fromJson: _priceFromJson) required final double price,
    @JsonKey(name: 'current_quantity', fromJson: _stockFromJson)
    required final int stock,
    @JsonKey(name: 'discounted_price', fromJson: _nullableDoubleFromJson)
    final double? discountedPrice,
    final String? sku,
    final String? size,
    final String? color,
    @JsonKey(fromJson: _nullableDoubleFromJson) final double? weight,
    final String? unit,
    @JsonKey(name: 'prod_description') final String? description,
    @JsonKey(name: 'current_stock_unit') final String? stockUnit,
    final List<ProductVariantImageDto> images,
    final List<ProductVariantMediaDto> media,
    final List<ProductVariantReviewDto> reviews,
    @JsonKey(name: 'product_rating', fromJson: _nullableDoubleFromJson)
    final double? averageRating,
    @JsonKey(name: 'review_count', fromJson: _intFromJson)
    final int reviewCount,
    @JsonKey(name: 'is_wishlisted') final bool isWishlisted,
  }) = _$ProductVariantDtoImpl;

  factory _ProductVariantDto.fromJson(Map<String, dynamic> json) =
      _$ProductVariantDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'product_id')
  int get productId;
  @override
  String get name;
  @override
  @JsonKey(fromJson: _priceFromJson)
  double get price;
  @override
  @JsonKey(name: 'current_quantity', fromJson: _stockFromJson)
  int get stock;
  @override
  @JsonKey(name: 'discounted_price', fromJson: _nullableDoubleFromJson)
  double? get discountedPrice;
  @override
  String? get sku;
  @override
  String? get size;
  @override
  String? get color;
  @override
  @JsonKey(fromJson: _nullableDoubleFromJson)
  double? get weight;
  @override
  String? get unit;
  @override
  @JsonKey(name: 'prod_description')
  String? get description;
  @override
  @JsonKey(name: 'current_stock_unit')
  String? get stockUnit;
  @override
  List<ProductVariantImageDto> get images;
  @override
  List<ProductVariantMediaDto> get media;
  @override
  List<ProductVariantReviewDto> get reviews;
  @override
  @JsonKey(name: 'product_rating', fromJson: _nullableDoubleFromJson)
  double? get averageRating;
  @override
  @JsonKey(name: 'review_count', fromJson: _intFromJson)
  int get reviewCount;
  @override
  @JsonKey(name: 'is_wishlisted')
  bool get isWishlisted;

  /// Create a copy of ProductVariantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantDtoImplCopyWith<_$ProductVariantDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

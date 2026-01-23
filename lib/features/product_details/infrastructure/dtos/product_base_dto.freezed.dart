// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_base_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductBaseDto _$ProductBaseDtoFromJson(Map<String, dynamic> json) {
  return _ProductBaseDto.fromJson(json);
}

/// @nodoc
mixin _$ProductBaseDto {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  int get categoryId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _descriptionFromJson)
  String? get description => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get manufacturer => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _tagsFromJson)
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'meta_title')
  String? get metaTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'meta_description')
  String? get metaDescription => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ProductBaseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductBaseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductBaseDtoCopyWith<ProductBaseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductBaseDtoCopyWith<$Res> {
  factory $ProductBaseDtoCopyWith(
    ProductBaseDto value,
    $Res Function(ProductBaseDto) then,
  ) = _$ProductBaseDtoCopyWithImpl<$Res, ProductBaseDto>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'category_id') int categoryId,
    @JsonKey(fromJson: _descriptionFromJson) String? description,
    String? brand,
    String? manufacturer,
    @JsonKey(fromJson: _tagsFromJson) List<String> tags,
    @JsonKey(name: 'meta_title') String? metaTitle,
    @JsonKey(name: 'meta_description') String? metaDescription,
    String? slug,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class _$ProductBaseDtoCopyWithImpl<$Res, $Val extends ProductBaseDto>
    implements $ProductBaseDtoCopyWith<$Res> {
  _$ProductBaseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductBaseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? categoryId = null,
    Object? description = freezed,
    Object? brand = freezed,
    Object? manufacturer = freezed,
    Object? tags = null,
    Object? metaTitle = freezed,
    Object? metaDescription = freezed,
    Object? slug = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            brand: freezed == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String?,
            manufacturer: freezed == manufacturer
                ? _value.manufacturer
                : manufacturer // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            metaTitle: freezed == metaTitle
                ? _value.metaTitle
                : metaTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            metaDescription: freezed == metaDescription
                ? _value.metaDescription
                : metaDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            slug: freezed == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductBaseDtoImplCopyWith<$Res>
    implements $ProductBaseDtoCopyWith<$Res> {
  factory _$$ProductBaseDtoImplCopyWith(
    _$ProductBaseDtoImpl value,
    $Res Function(_$ProductBaseDtoImpl) then,
  ) = __$$ProductBaseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'category_id') int categoryId,
    @JsonKey(fromJson: _descriptionFromJson) String? description,
    String? brand,
    String? manufacturer,
    @JsonKey(fromJson: _tagsFromJson) List<String> tags,
    @JsonKey(name: 'meta_title') String? metaTitle,
    @JsonKey(name: 'meta_description') String? metaDescription,
    String? slug,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class __$$ProductBaseDtoImplCopyWithImpl<$Res>
    extends _$ProductBaseDtoCopyWithImpl<$Res, _$ProductBaseDtoImpl>
    implements _$$ProductBaseDtoImplCopyWith<$Res> {
  __$$ProductBaseDtoImplCopyWithImpl(
    _$ProductBaseDtoImpl _value,
    $Res Function(_$ProductBaseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductBaseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? categoryId = null,
    Object? description = freezed,
    Object? brand = freezed,
    Object? manufacturer = freezed,
    Object? tags = null,
    Object? metaTitle = freezed,
    Object? metaDescription = freezed,
    Object? slug = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _$ProductBaseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        brand: freezed == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String?,
        manufacturer: freezed == manufacturer
            ? _value.manufacturer
            : manufacturer // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        metaTitle: freezed == metaTitle
            ? _value.metaTitle
            : metaTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        metaDescription: freezed == metaDescription
            ? _value.metaDescription
            : metaDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        slug: freezed == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductBaseDtoImpl implements _ProductBaseDto {
  const _$ProductBaseDtoImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'category_id') required this.categoryId,
    @JsonKey(fromJson: _descriptionFromJson) this.description,
    this.brand,
    this.manufacturer,
    @JsonKey(fromJson: _tagsFromJson) final List<String> tags = const [],
    @JsonKey(name: 'meta_title') this.metaTitle,
    @JsonKey(name: 'meta_description') this.metaDescription,
    this.slug,
    @JsonKey(name: 'is_active') this.isActive = true,
  }) : _tags = tags;

  factory _$ProductBaseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductBaseDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'category_id')
  final int categoryId;
  @override
  @JsonKey(fromJson: _descriptionFromJson)
  final String? description;
  @override
  final String? brand;
  @override
  final String? manufacturer;
  final List<String> _tags;
  @override
  @JsonKey(fromJson: _tagsFromJson)
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'meta_title')
  final String? metaTitle;
  @override
  @JsonKey(name: 'meta_description')
  final String? metaDescription;
  @override
  final String? slug;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'ProductBaseDto(id: $id, name: $name, categoryId: $categoryId, description: $description, brand: $brand, manufacturer: $manufacturer, tags: $tags, metaTitle: $metaTitle, metaDescription: $metaDescription, slug: $slug, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductBaseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.metaTitle, metaTitle) ||
                other.metaTitle == metaTitle) &&
            (identical(other.metaDescription, metaDescription) ||
                other.metaDescription == metaDescription) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    categoryId,
    description,
    brand,
    manufacturer,
    const DeepCollectionEquality().hash(_tags),
    metaTitle,
    metaDescription,
    slug,
    isActive,
  );

  /// Create a copy of ProductBaseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductBaseDtoImplCopyWith<_$ProductBaseDtoImpl> get copyWith =>
      __$$ProductBaseDtoImplCopyWithImpl<_$ProductBaseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductBaseDtoImplToJson(this);
  }
}

abstract class _ProductBaseDto implements ProductBaseDto {
  const factory _ProductBaseDto({
    required final int id,
    required final String name,
    @JsonKey(name: 'category_id') required final int categoryId,
    @JsonKey(fromJson: _descriptionFromJson) final String? description,
    final String? brand,
    final String? manufacturer,
    @JsonKey(fromJson: _tagsFromJson) final List<String> tags,
    @JsonKey(name: 'meta_title') final String? metaTitle,
    @JsonKey(name: 'meta_description') final String? metaDescription,
    final String? slug,
    @JsonKey(name: 'is_active') final bool isActive,
  }) = _$ProductBaseDtoImpl;

  factory _ProductBaseDto.fromJson(Map<String, dynamic> json) =
      _$ProductBaseDtoImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'category_id')
  int get categoryId;
  @override
  @JsonKey(fromJson: _descriptionFromJson)
  String? get description;
  @override
  String? get brand;
  @override
  String? get manufacturer;
  @override
  @JsonKey(fromJson: _tagsFromJson)
  List<String> get tags;
  @override
  @JsonKey(name: 'meta_title')
  String? get metaTitle;
  @override
  @JsonKey(name: 'meta_description')
  String? get metaDescription;
  @override
  String? get slug;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of ProductBaseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductBaseDtoImplCopyWith<_$ProductBaseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

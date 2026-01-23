// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartCategoriesHash() => r'96714e4c114f7ea051929262d6c1ccadfd26b5e6';

/// Provider for fetching all categories (filtered to only show categories with products)
///
/// Copied from [cartCategories].
@ProviderFor(cartCategories)
final cartCategoriesProvider =
    AutoDisposeFutureProvider<List<Category>>.internal(
      cartCategories,
      name: r'cartCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cartCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartCategoriesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$categoryProductsHash() => r'5997cd5b1c525c917ca60e75d7a20e62a1fd62e3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider family for fetching products by category ID
///
/// Copied from [categoryProducts].
@ProviderFor(categoryProducts)
const categoryProductsProvider = CategoryProductsFamily();

/// Provider family for fetching products by category ID
///
/// Copied from [categoryProducts].
class CategoryProductsFamily extends Family<AsyncValue<List<ProductDisplay>>> {
  /// Provider family for fetching products by category ID
  ///
  /// Copied from [categoryProducts].
  const CategoryProductsFamily();

  /// Provider family for fetching products by category ID
  ///
  /// Copied from [categoryProducts].
  CategoryProductsProvider call(int categoryId) {
    return CategoryProductsProvider(categoryId);
  }

  @override
  CategoryProductsProvider getProviderOverride(
    covariant CategoryProductsProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryProductsProvider';
}

/// Provider family for fetching products by category ID
///
/// Copied from [categoryProducts].
class CategoryProductsProvider
    extends AutoDisposeFutureProvider<List<ProductDisplay>> {
  /// Provider family for fetching products by category ID
  ///
  /// Copied from [categoryProducts].
  CategoryProductsProvider(int categoryId)
    : this._internal(
        (ref) => categoryProducts(ref as CategoryProductsRef, categoryId),
        from: categoryProductsProvider,
        name: r'categoryProductsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$categoryProductsHash,
        dependencies: CategoryProductsFamily._dependencies,
        allTransitiveDependencies:
            CategoryProductsFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  CategoryProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final int categoryId;

  @override
  Override overrideWith(
    FutureOr<List<ProductDisplay>> Function(CategoryProductsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryProductsProvider._internal(
        (ref) => create(ref as CategoryProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProductDisplay>> createElement() {
    return _CategoryProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryProductsProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryProductsRef
    on AutoDisposeFutureProviderRef<List<ProductDisplay>> {
  /// The parameter `categoryId` of this provider.
  int get categoryId;
}

class _CategoryProductsProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductDisplay>>
    with CategoryProductsRef {
  _CategoryProductsProviderElement(super.provider);

  @override
  int get categoryId => (origin as CategoryProductsProvider).categoryId;
}

String _$allCategoryProductsHash() =>
    r'19e8de754694039f49187505b7e852d8f728f95a';

/// Provider for fetching all products from all categories (combined)
///
/// Copied from [allCategoryProducts].
@ProviderFor(allCategoryProducts)
final allCategoryProductsProvider =
    AutoDisposeFutureProvider<Map<int, List<ProductDisplay>>>.internal(
      allCategoryProducts,
      name: r'allCategoryProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allCategoryProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCategoryProductsRef =
    AutoDisposeFutureProviderRef<Map<int, List<ProductDisplay>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

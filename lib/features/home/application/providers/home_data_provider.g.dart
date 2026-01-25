// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesHash() => r'87f8a90dee236f8ebfdd552dba32fc2f08765fc0';

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

/// Provider for fetching categories with offer filter
///
/// Copied from [categories].
@ProviderFor(categories)
const categoriesProvider = CategoriesFamily();

/// Provider for fetching categories with offer filter
///
/// Copied from [categories].
class CategoriesFamily extends Family<AsyncValue<List<Category>>> {
  /// Provider for fetching categories with offer filter
  ///
  /// Copied from [categories].
  const CategoriesFamily();

  /// Provider for fetching categories with offer filter
  ///
  /// Copied from [categories].
  CategoriesProvider call({bool? isOffer}) {
    return CategoriesProvider(isOffer: isOffer);
  }

  @override
  CategoriesProvider getProviderOverride(
    covariant CategoriesProvider provider,
  ) {
    return call(isOffer: provider.isOffer);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoriesProvider';
}

/// Provider for fetching categories with offer filter
///
/// Copied from [categories].
class CategoriesProvider extends AutoDisposeFutureProvider<List<Category>> {
  /// Provider for fetching categories with offer filter
  ///
  /// Copied from [categories].
  CategoriesProvider({bool? isOffer})
    : this._internal(
        (ref) => categories(ref as CategoriesRef, isOffer: isOffer),
        from: categoriesProvider,
        name: r'categoriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$categoriesHash,
        dependencies: CategoriesFamily._dependencies,
        allTransitiveDependencies: CategoriesFamily._allTransitiveDependencies,
        isOffer: isOffer,
      );

  CategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isOffer,
  }) : super.internal();

  final bool? isOffer;

  @override
  Override overrideWith(
    FutureOr<List<Category>> Function(CategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoriesProvider._internal(
        (ref) => create(ref as CategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isOffer: isOffer,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Category>> createElement() {
    return _CategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesProvider && other.isOffer == isOffer;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isOffer.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoriesRef on AutoDisposeFutureProviderRef<List<Category>> {
  /// The parameter `isOffer` of this provider.
  bool? get isOffer;
}

class _CategoriesProviderElement
    extends AutoDisposeFutureProviderElement<List<Category>>
    with CategoriesRef {
  _CategoriesProviderElement(super.provider);

  @override
  bool? get isOffer => (origin as CategoriesProvider).isOffer;
}

String _$bannersHash() => r'24e1fd9c2d4bd5273f06c320ca56b369f0439079';

/// Provider for fetching promotional banners
///
/// Copied from [banners].
@ProviderFor(banners)
final bannersProvider = AutoDisposeFutureProvider<List<PromoBanner>>.internal(
  banners,
  name: r'bannersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bannersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BannersRef = AutoDisposeFutureProviderRef<List<PromoBanner>>;
String _$offerCategoriesHash() => r'7f5150127a4152bba55a9a859084d2fb8fabadd7';

/// Provider for fetching offer categories (convenience provider)
///
/// Copied from [offerCategories].
@ProviderFor(offerCategories)
final offerCategoriesProvider =
    AutoDisposeFutureProvider<List<Category>>.internal(
      offerCategories,
      name: r'offerCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offerCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfferCategoriesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$discountedProductsHash() =>
    r'5ec95f54e5592c16328ea763e94251f8bdf2d3b1';

/// Provider for fetching discounted products (Best Deals)
///
/// Copied from [discountedProducts].
@ProviderFor(discountedProducts)
final discountedProductsProvider =
    AutoDisposeFutureProvider<List<ProductVariant>>.internal(
      discountedProducts,
      name: r'discountedProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$discountedProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DiscountedProductsRef =
    AutoDisposeFutureProviderRef<List<ProductVariant>>;
String _$offerCategoryProductsHash() =>
    r'f53dcef9e69c3fe9dbc4b83ad28bead5ddc3d691';

/// Provider for fetching products from first offer category (Mega Fresh offers)
///
/// Copied from [offerCategoryProducts].
@ProviderFor(offerCategoryProducts)
final offerCategoryProductsProvider =
    AutoDisposeFutureProvider<List<ProductDisplay>>.internal(
      offerCategoryProducts,
      name: r'offerCategoryProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offerCategoryProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfferCategoryProductsRef =
    AutoDisposeFutureProviderRef<List<ProductDisplay>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

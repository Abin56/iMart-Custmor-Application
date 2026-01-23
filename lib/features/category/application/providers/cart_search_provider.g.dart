// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productSearchHash() => r'2182cd3ee513e4c91382071b62aada3cd793b6db';

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

abstract class _$ProductSearch
    extends BuildlessAutoDisposeAsyncNotifier<List<ProductDisplay>> {
  late final String query;

  FutureOr<List<ProductDisplay>> build(String query);
}

/// Provider for searching products across all categories
///
/// Copied from [ProductSearch].
@ProviderFor(ProductSearch)
const productSearchProvider = ProductSearchFamily();

/// Provider for searching products across all categories
///
/// Copied from [ProductSearch].
class ProductSearchFamily extends Family<AsyncValue<List<ProductDisplay>>> {
  /// Provider for searching products across all categories
  ///
  /// Copied from [ProductSearch].
  const ProductSearchFamily();

  /// Provider for searching products across all categories
  ///
  /// Copied from [ProductSearch].
  ProductSearchProvider call(String query) {
    return ProductSearchProvider(query);
  }

  @override
  ProductSearchProvider getProviderOverride(
    covariant ProductSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productSearchProvider';
}

/// Provider for searching products across all categories
///
/// Copied from [ProductSearch].
class ProductSearchProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ProductSearch,
          List<ProductDisplay>
        > {
  /// Provider for searching products across all categories
  ///
  /// Copied from [ProductSearch].
  ProductSearchProvider(String query)
    : this._internal(
        () => ProductSearch()..query = query,
        from: productSearchProvider,
        name: r'productSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productSearchHash,
        dependencies: ProductSearchFamily._dependencies,
        allTransitiveDependencies:
            ProductSearchFamily._allTransitiveDependencies,
        query: query,
      );

  ProductSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<ProductDisplay>> runNotifierBuild(
    covariant ProductSearch notifier,
  ) {
    return notifier.build(query);
  }

  @override
  Override overrideWith(ProductSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductSearchProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProductSearch, List<ProductDisplay>>
  createElement() {
    return _ProductSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductSearchRef
    on AutoDisposeAsyncNotifierProviderRef<List<ProductDisplay>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _ProductSearchProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ProductSearch,
          List<ProductDisplay>
        >
    with ProductSearchRef {
  _ProductSearchProviderElement(super.provider);

  @override
  String get query => (origin as ProductSearchProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

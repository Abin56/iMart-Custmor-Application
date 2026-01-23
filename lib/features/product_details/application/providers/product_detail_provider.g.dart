// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productDetailHash() => r'b45e971d3485759c9850864ba4506bcf80df9542';

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

abstract class _$ProductDetail
    extends BuildlessAutoDisposeNotifier<ProductDetailState> {
  late final int variantId;

  ProductDetailState build(int variantId);
}

/// AutoDisposeFamily provider for product details
/// Creates separate state for each variant ID
/// Automatically disposes when no longer watched (navigated away)
///
/// Copied from [ProductDetail].
@ProviderFor(ProductDetail)
const productDetailProvider = ProductDetailFamily();

/// AutoDisposeFamily provider for product details
/// Creates separate state for each variant ID
/// Automatically disposes when no longer watched (navigated away)
///
/// Copied from [ProductDetail].
class ProductDetailFamily extends Family<ProductDetailState> {
  /// AutoDisposeFamily provider for product details
  /// Creates separate state for each variant ID
  /// Automatically disposes when no longer watched (navigated away)
  ///
  /// Copied from [ProductDetail].
  const ProductDetailFamily();

  /// AutoDisposeFamily provider for product details
  /// Creates separate state for each variant ID
  /// Automatically disposes when no longer watched (navigated away)
  ///
  /// Copied from [ProductDetail].
  ProductDetailProvider call(int variantId) {
    return ProductDetailProvider(variantId);
  }

  @override
  ProductDetailProvider getProviderOverride(
    covariant ProductDetailProvider provider,
  ) {
    return call(provider.variantId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productDetailProvider';
}

/// AutoDisposeFamily provider for product details
/// Creates separate state for each variant ID
/// Automatically disposes when no longer watched (navigated away)
///
/// Copied from [ProductDetail].
class ProductDetailProvider
    extends AutoDisposeNotifierProviderImpl<ProductDetail, ProductDetailState> {
  /// AutoDisposeFamily provider for product details
  /// Creates separate state for each variant ID
  /// Automatically disposes when no longer watched (navigated away)
  ///
  /// Copied from [ProductDetail].
  ProductDetailProvider(int variantId)
    : this._internal(
        () => ProductDetail()..variantId = variantId,
        from: productDetailProvider,
        name: r'productDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productDetailHash,
        dependencies: ProductDetailFamily._dependencies,
        allTransitiveDependencies:
            ProductDetailFamily._allTransitiveDependencies,
        variantId: variantId,
      );

  ProductDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.variantId,
  }) : super.internal();

  final int variantId;

  @override
  ProductDetailState runNotifierBuild(covariant ProductDetail notifier) {
    return notifier.build(variantId);
  }

  @override
  Override overrideWith(ProductDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailProvider._internal(
        () => create()..variantId = variantId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        variantId: variantId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ProductDetail, ProductDetailState>
  createElement() {
    return _ProductDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.variantId == variantId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, variantId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductDetailRef on AutoDisposeNotifierProviderRef<ProductDetailState> {
  /// The parameter `variantId` of this provider.
  int get variantId;
}

class _ProductDetailProviderElement
    extends
        AutoDisposeNotifierProviderElement<ProductDetail, ProductDetailState>
    with ProductDetailRef {
  _ProductDetailProviderElement(super.provider);

  @override
  int get variantId => (origin as ProductDetailProvider).variantId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

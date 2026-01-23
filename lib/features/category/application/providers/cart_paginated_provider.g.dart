// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_paginated_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paginatedCategoryProductsHash() =>
    r'bfbabe1912ea2c6d660b314ed19d163c0dcf22dd';

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

abstract class _$PaginatedCategoryProducts
    extends BuildlessAutoDisposeAsyncNotifier<PaginatedProductsState> {
  late final int categoryId;

  FutureOr<PaginatedProductsState> build(int categoryId);
}

/// Notifier for paginated products by category ID with lazy loading
///
/// Copied from [PaginatedCategoryProducts].
@ProviderFor(PaginatedCategoryProducts)
const paginatedCategoryProductsProvider = PaginatedCategoryProductsFamily();

/// Notifier for paginated products by category ID with lazy loading
///
/// Copied from [PaginatedCategoryProducts].
class PaginatedCategoryProductsFamily
    extends Family<AsyncValue<PaginatedProductsState>> {
  /// Notifier for paginated products by category ID with lazy loading
  ///
  /// Copied from [PaginatedCategoryProducts].
  const PaginatedCategoryProductsFamily();

  /// Notifier for paginated products by category ID with lazy loading
  ///
  /// Copied from [PaginatedCategoryProducts].
  PaginatedCategoryProductsProvider call(int categoryId) {
    return PaginatedCategoryProductsProvider(categoryId);
  }

  @override
  PaginatedCategoryProductsProvider getProviderOverride(
    covariant PaginatedCategoryProductsProvider provider,
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
  String? get name => r'paginatedCategoryProductsProvider';
}

/// Notifier for paginated products by category ID with lazy loading
///
/// Copied from [PaginatedCategoryProducts].
class PaginatedCategoryProductsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PaginatedCategoryProducts,
          PaginatedProductsState
        > {
  /// Notifier for paginated products by category ID with lazy loading
  ///
  /// Copied from [PaginatedCategoryProducts].
  PaginatedCategoryProductsProvider(int categoryId)
    : this._internal(
        () => PaginatedCategoryProducts()..categoryId = categoryId,
        from: paginatedCategoryProductsProvider,
        name: r'paginatedCategoryProductsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$paginatedCategoryProductsHash,
        dependencies: PaginatedCategoryProductsFamily._dependencies,
        allTransitiveDependencies:
            PaginatedCategoryProductsFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  PaginatedCategoryProductsProvider._internal(
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
  FutureOr<PaginatedProductsState> runNotifierBuild(
    covariant PaginatedCategoryProducts notifier,
  ) {
    return notifier.build(categoryId);
  }

  @override
  Override overrideWith(PaginatedCategoryProducts Function() create) {
    return ProviderOverride(
      origin: this,
      override: PaginatedCategoryProductsProvider._internal(
        () => create()..categoryId = categoryId,
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
  AutoDisposeAsyncNotifierProviderElement<
    PaginatedCategoryProducts,
    PaginatedProductsState
  >
  createElement() {
    return _PaginatedCategoryProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaginatedCategoryProductsProvider &&
        other.categoryId == categoryId;
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
mixin PaginatedCategoryProductsRef
    on AutoDisposeAsyncNotifierProviderRef<PaginatedProductsState> {
  /// The parameter `categoryId` of this provider.
  int get categoryId;
}

class _PaginatedCategoryProductsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PaginatedCategoryProducts,
          PaginatedProductsState
        >
    with PaginatedCategoryProductsRef {
  _PaginatedCategoryProductsProviderElement(super.provider);

  @override
  int get categoryId =>
      (origin as PaginatedCategoryProductsProvider).categoryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

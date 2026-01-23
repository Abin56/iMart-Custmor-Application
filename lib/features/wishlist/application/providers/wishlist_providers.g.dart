// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wishlistRemoteDataSourceHash() =>
    r'6b8931f2fbd09cc3441daf835a4966ea164c01aa';

/// Wishlist remote data source provider
///
/// Copied from [wishlistRemoteDataSource].
@ProviderFor(wishlistRemoteDataSource)
final wishlistRemoteDataSourceProvider =
    AutoDisposeProvider<WishlistRemoteDataSource>.internal(
      wishlistRemoteDataSource,
      name: r'wishlistRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wishlistRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistRemoteDataSourceRef =
    AutoDisposeProviderRef<WishlistRemoteDataSource>;
String _$wishlistLocalDataSourceHash() =>
    r'7581717bd66514d49cf36fe573749f5efe07fc5c';

/// Wishlist local data source provider
///
/// Copied from [wishlistLocalDataSource].
@ProviderFor(wishlistLocalDataSource)
final wishlistLocalDataSourceProvider =
    AutoDisposeProvider<WishlistLocalDataSource>.internal(
      wishlistLocalDataSource,
      name: r'wishlistLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wishlistLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistLocalDataSourceRef =
    AutoDisposeProviderRef<WishlistLocalDataSource>;
String _$wishlistRepositoryHash() =>
    r'a621d31755f949bc3859c3b402fb4508f49b571f';

/// Wishlist repository provider
///
/// Copied from [wishlistRepository].
@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider =
    AutoDisposeProvider<WishlistRepository>.internal(
      wishlistRepository,
      name: r'wishlistRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wishlistRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistRepositoryRef = AutoDisposeProviderRef<WishlistRepository>;
String _$wishlistItemsHash() => r'7f1533ca4fcd4d66bc4cd13a186068b2ad76dfc5';

/// Watch only items (optimization)
///
/// Copied from [wishlistItems].
@ProviderFor(wishlistItems)
final wishlistItemsProvider = AutoDisposeProvider<List<WishlistItem>>.internal(
  wishlistItems,
  name: r'wishlistItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistItemsRef = AutoDisposeProviderRef<List<WishlistItem>>;
String _$isInWishlistHash() => r'bc89dd7fc3aea925299e7e33702eb0e7d2b7c149';

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

/// Check if specific product is in wishlist
///
/// Copied from [isInWishlist].
@ProviderFor(isInWishlist)
const isInWishlistProvider = IsInWishlistFamily();

/// Check if specific product is in wishlist
///
/// Copied from [isInWishlist].
class IsInWishlistFamily extends Family<bool> {
  /// Check if specific product is in wishlist
  ///
  /// Copied from [isInWishlist].
  const IsInWishlistFamily();

  /// Check if specific product is in wishlist
  ///
  /// Copied from [isInWishlist].
  IsInWishlistProvider call(String productId) {
    return IsInWishlistProvider(productId);
  }

  @override
  IsInWishlistProvider getProviderOverride(
    covariant IsInWishlistProvider provider,
  ) {
    return call(provider.productId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isInWishlistProvider';
}

/// Check if specific product is in wishlist
///
/// Copied from [isInWishlist].
class IsInWishlistProvider extends AutoDisposeProvider<bool> {
  /// Check if specific product is in wishlist
  ///
  /// Copied from [isInWishlist].
  IsInWishlistProvider(String productId)
    : this._internal(
        (ref) => isInWishlist(ref as IsInWishlistRef, productId),
        from: isInWishlistProvider,
        name: r'isInWishlistProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isInWishlistHash,
        dependencies: IsInWishlistFamily._dependencies,
        allTransitiveDependencies:
            IsInWishlistFamily._allTransitiveDependencies,
        productId: productId,
      );

  IsInWishlistProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(bool Function(IsInWishlistRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsInWishlistProvider._internal(
        (ref) => create(ref as IsInWishlistRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsInWishlistProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsInWishlistProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsInWishlistRef on AutoDisposeProviderRef<bool> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _IsInWishlistProviderElement extends AutoDisposeProviderElement<bool>
    with IsInWishlistRef {
  _IsInWishlistProviderElement(super.provider);

  @override
  String get productId => (origin as IsInWishlistProvider).productId;
}

String _$wishlistCountHash() => r'31b3899f2bbb1f537c67fae0eee8bf06513aaaba';

/// Get wishlist count
///
/// Copied from [wishlistCount].
@ProviderFor(wishlistCount)
final wishlistCountProvider = AutoDisposeProvider<int>.internal(
  wishlistCount,
  name: r'wishlistCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistCountRef = AutoDisposeProviderRef<int>;
String _$wishlistHash() => r'3a0baec1ad8d9c18ea4f3b7668ed56095d182ff3';

/// Wishlist state notifier
///
/// Copied from [Wishlist].
@ProviderFor(Wishlist)
final wishlistProvider = NotifierProvider<Wishlist, WishlistState>.internal(
  Wishlist.new,
  name: r'wishlistProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Wishlist = Notifier<WishlistState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

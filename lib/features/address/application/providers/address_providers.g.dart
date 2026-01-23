// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addressRemoteDataSourceHash() =>
    r'dfef98f4d494e8b61a483ab33481f70b46aea90e';

/// Provide remote data source
///
/// Copied from [addressRemoteDataSource].
@ProviderFor(addressRemoteDataSource)
final addressRemoteDataSourceProvider =
    AutoDisposeProvider<AddressRemoteDataSource>.internal(
      addressRemoteDataSource,
      name: r'addressRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addressRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddressRemoteDataSourceRef =
    AutoDisposeProviderRef<AddressRemoteDataSource>;
String _$addressLocalDataSourceHash() =>
    r'dd18a37a4f1edd586ffe4d22232947d2719be9e1';

/// Provide local data source
///
/// Copied from [addressLocalDataSource].
@ProviderFor(addressLocalDataSource)
final addressLocalDataSourceProvider =
    AutoDisposeProvider<AddressLocalDataSource>.internal(
      addressLocalDataSource,
      name: r'addressLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addressLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddressLocalDataSourceRef =
    AutoDisposeProviderRef<AddressLocalDataSource>;
String _$addressRepositoryHash() => r'83a88af49746f59665f6cb8fd2cb14bc3821ccdd';

/// Provide repository
///
/// Copied from [addressRepository].
@ProviderFor(addressRepository)
final addressRepositoryProvider =
    AutoDisposeProvider<AddressRepository>.internal(
      addressRepository,
      name: r'addressRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addressRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddressRepositoryRef = AutoDisposeProviderRef<AddressRepository>;
String _$selectedAddressHash() => r'bbcbe7d9c0d2987e35d66fd6cca32f1c68220c4a';

/// Provider to get selected address
///
/// Copied from [selectedAddress].
@ProviderFor(selectedAddress)
final selectedAddressProvider = AutoDisposeProvider<Address?>.internal(
  selectedAddress,
  name: r'selectedAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedAddressRef = AutoDisposeProviderRef<Address?>;
String _$isAddressSelectedHash() => r'43315d956911b176db819cbf1bcc0a7828123da5';

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

/// Provider to check if an address is selected
///
/// Copied from [isAddressSelected].
@ProviderFor(isAddressSelected)
const isAddressSelectedProvider = IsAddressSelectedFamily();

/// Provider to check if an address is selected
///
/// Copied from [isAddressSelected].
class IsAddressSelectedFamily extends Family<bool> {
  /// Provider to check if an address is selected
  ///
  /// Copied from [isAddressSelected].
  const IsAddressSelectedFamily();

  /// Provider to check if an address is selected
  ///
  /// Copied from [isAddressSelected].
  IsAddressSelectedProvider call(int addressId) {
    return IsAddressSelectedProvider(addressId);
  }

  @override
  IsAddressSelectedProvider getProviderOverride(
    covariant IsAddressSelectedProvider provider,
  ) {
    return call(provider.addressId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isAddressSelectedProvider';
}

/// Provider to check if an address is selected
///
/// Copied from [isAddressSelected].
class IsAddressSelectedProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if an address is selected
  ///
  /// Copied from [isAddressSelected].
  IsAddressSelectedProvider(int addressId)
    : this._internal(
        (ref) => isAddressSelected(ref as IsAddressSelectedRef, addressId),
        from: isAddressSelectedProvider,
        name: r'isAddressSelectedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isAddressSelectedHash,
        dependencies: IsAddressSelectedFamily._dependencies,
        allTransitiveDependencies:
            IsAddressSelectedFamily._allTransitiveDependencies,
        addressId: addressId,
      );

  IsAddressSelectedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.addressId,
  }) : super.internal();

  final int addressId;

  @override
  Override overrideWith(bool Function(IsAddressSelectedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsAddressSelectedProvider._internal(
        (ref) => create(ref as IsAddressSelectedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        addressId: addressId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsAddressSelectedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsAddressSelectedProvider && other.addressId == addressId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, addressId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsAddressSelectedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `addressId` of this provider.
  int get addressId;
}

class _IsAddressSelectedProviderElement extends AutoDisposeProviderElement<bool>
    with IsAddressSelectedRef {
  _IsAddressSelectedProviderElement(super.provider);

  @override
  int get addressId => (origin as IsAddressSelectedProvider).addressId;
}

String _$addressNotifierHash() => r'f930b486d6dac05758d055b14eacc15a1455ac39';

/// Address list provider with state management
///
/// Copied from [AddressNotifier].
@ProviderFor(AddressNotifier)
final addressNotifierProvider =
    AutoDisposeNotifierProvider<AddressNotifier, AddressState>.internal(
      AddressNotifier.new,
      name: r'addressNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addressNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AddressNotifier = AutoDisposeNotifier<AddressState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

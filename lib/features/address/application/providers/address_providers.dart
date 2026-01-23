// ignore_for_file: deprecated_member_use_from_same_package

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/core/network/api_client.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../../infrastructure/data_sources/local/address_local_data_source.dart';
import '../../infrastructure/data_sources/remote/address_remote_data_source.dart';
import '../../infrastructure/repositories/address_repository_impl.dart';
import '../states/address_state.dart';

part 'address_providers.g.dart';

/// Provide remote data source
@riverpod
AddressRemoteDataSource addressRemoteDataSource(
  AddressRemoteDataSourceRef ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return AddressRemoteDataSourceImpl(apiClient);
}

/// Provide local data source
@riverpod
AddressLocalDataSource addressLocalDataSource(AddressLocalDataSourceRef ref) {
  return AddressLocalDataSourceImpl();
}

/// Provide repository
@riverpod
AddressRepository addressRepository(AddressRepositoryRef ref) {
  final remoteDataSource = ref.watch(addressRemoteDataSourceProvider);
  final localDataSource = ref.watch(addressLocalDataSourceProvider);

  return AddressRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
}

/// Address list provider with state management
@riverpod
class AddressNotifier extends _$AddressNotifier {
  @override
  AddressState build() {
    // Auto-load addresses when provider is created
    loadAddresses();
    return const AddressState.initial();
  }

  /// Load addresses
  Future<void> loadAddresses({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && state is AddressLoaded) {
        // Already loaded, don't reload unless forced
        return;
      }

      state = const AddressState.loading();

      final repository = ref.read(addressRepositoryProvider);
      final addresses = await repository.getAddresses(
        forceRefresh: forceRefresh,
      );

      // Find selected address
      final selectedAddress = addresses
          .where((addr) => addr.selected)
          .firstOrNull;

      state = AddressState.loaded(
        addresses: addresses,
        selectedAddress: selectedAddress,
      );
    } catch (e) {
      state = AddressState.error(message: e.toString());
    }
  }

  /// Create new address
  Future<Address?> createAddress({
    required String firstName,
    required String lastName,
    required String streetAddress1,
    required String city,
    required String stateProvince,
    required String postalCode,
    required String country,
    required String addressType,
    String? streetAddress2,
    String? latitude,
    String? longitude,
  }) async {
    try {
      final repository = ref.read(addressRepositoryProvider);
      final address = await repository.createAddress(
        firstName: firstName,
        lastName: lastName,
        streetAddress1: streetAddress1,
        city: city,
        stateProvince: stateProvince,
        postalCode: postalCode,
        country: country,
        addressType: addressType,
        streetAddress2: streetAddress2,
        latitude: latitude,
        longitude: longitude,
      );

      // Reload addresses to get updated list
      await loadAddresses(forceRefresh: true);

      return address;
    } catch (e) {
      state = AddressState.error(message: e.toString());
      return null;
    }
  }

  /// Update address
  Future<Address?> updateAddress({
    required int id,
    String? firstName,
    String? lastName,
    String? streetAddress1,
    String? streetAddress2,
    String? city,
    String? stateProvince,
    String? postalCode,
    String? country,
    String? latitude,
    String? longitude,
    String? addressType,
  }) async {
    try {
      final repository = ref.read(addressRepositoryProvider);
      final address = await repository.updateAddress(
        id: id,
        firstName: firstName,
        lastName: lastName,
        streetAddress1: streetAddress1,
        streetAddress2: streetAddress2,
        city: city,
        stateProvince: stateProvince,
        postalCode: postalCode,
        country: country,
        latitude: latitude,
        longitude: longitude,
        addressType: addressType,
      );

      // Reload addresses to get updated list
      await loadAddresses(forceRefresh: true);

      return address;
    } catch (e) {
      state = AddressState.error(message: e.toString());
      return null;
    }
  }

  /// Delete address
  Future<bool> deleteAddress(int id) async {
    try {
      final repository = ref.read(addressRepositoryProvider);
      await repository.deleteAddress(id);

      // Reload addresses to get updated list
      await loadAddresses(forceRefresh: true);

      return true;
    } catch (e) {
      state = AddressState.error(message: e.toString());
      return false;
    }
  }

  /// Select address (mark as default)
  Future<bool> selectAddress(int id) async {
    try {
      // Optimistic update
      final currentState = state;
      if (currentState is AddressLoaded) {
        final updatedAddresses = currentState.addresses.map((addr) {
          return addr.copyWith(selected: addr.id == id);
        }).toList();

        final newSelectedAddress = updatedAddresses.firstWhere(
          (addr) => addr.id == id,
        );

        state = AddressState.loaded(
          addresses: updatedAddresses,
          selectedAddress: newSelectedAddress,
        );
      }

      // Make API call
      final repository = ref.read(addressRepositoryProvider);
      await repository.selectAddress(id);

      // Reload to get server state
      await loadAddresses(forceRefresh: true);

      return true;
    } catch (e) {
      // Revert optimistic update
      await loadAddresses(forceRefresh: true);

      state = AddressState.error(message: e.toString());
      return false;
    }
  }
}

/// Provider to get selected address
@riverpod
Address? selectedAddress(SelectedAddressRef ref) {
  final addressState = ref.watch(addressNotifierProvider);
  return addressState.maybeWhen(
    loaded: (addresses, selectedAddress) => selectedAddress,
    orElse: () => null,
  );
}

/// Provider to check if an address is selected
@riverpod
bool isAddressSelected(IsAddressSelectedRef ref, int addressId) {
  final selected = ref.watch(selectedAddressProvider);
  return selected?.id == addressId;
}

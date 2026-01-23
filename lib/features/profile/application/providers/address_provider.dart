import 'package:imart/features/auth/domain/entities/address.dart';
import 'package:imart/features/profile/application/states/address_state.dart';
import 'package:imart/features/profile/domain/repositories/profile_repository.dart';
import 'package:imart/features/profile/infrastructure/repositories/profile_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'address_provider.g.dart';

/// Address Notifier for managing delivery addresses state
@Riverpod(keepAlive: true)
class Address extends _$Address {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  AddressState build() {
    // Initialize by loading cached addresses
    _loadAddresses();
    return const AddressInitial();
  }

  /// Load addresses (cache-first strategy)
  Future<void> _loadAddresses() async {
    try {
      state = const AddressLoading();

      final result = await _repository.getAddresses();

      result.fold(
        (failure) {
          state = AddressError(failure, state);
        },
        (addresses) {
          state = AddressLoaded(addresses);
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Refresh addresses (force fetch from API)
  Future<void> refreshAddresses() async {
    try {
      state = const AddressLoading();

      final result = await _repository.getAddresses(forceRefresh: true);

      result.fold(
        (failure) {
          state = AddressError(failure, state);
        },
        (addresses) {
          state = AddressLoaded(addresses);
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Add a new address
  Future<void> addAddress({
    required String firstName,
    required String lastName,
    required String streetAddress1,
    required String city,
    required String addressState,
    required String addressType,
    String? streetAddress2,
    bool selected = false,
  }) async {
    try {
      // Get current addresses for optimistic update
      final currentState = state;
      final currentAddresses = currentState is AddressLoaded
          ? currentState.addresses
          : <AddressEntity>[];

      state = AddressProcessing(currentAddresses);

      final result = await _repository.addAddress(
        firstName: firstName,
        lastName: lastName,
        streetAddress1: streetAddress1,
        city: city,
        state: addressState,
        addressType: addressType,
        streetAddress2: streetAddress2,
        selected: selected,
      );

      result.fold(
        (failure) {
          state = AddressError(failure, currentState);
        },
        (newAddress) {
          // Reload addresses to get updated list
          _loadAddresses();
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Update an existing address
  Future<void> updateAddress({
    required int id,
    required String firstName,
    required String lastName,
    required String streetAddress1,
    required String city,
    required String addressState,
    required String addressType,
    String? streetAddress2,
    bool selected = false,
  }) async {
    try {
      final currentState = state;
      final currentAddresses = currentState is AddressLoaded
          ? currentState.addresses
          : <AddressEntity>[];

      state = AddressProcessing(currentAddresses);

      final result = await _repository.updateAddress(
        id: id,
        firstName: firstName,
        lastName: lastName,
        streetAddress1: streetAddress1,
        city: city,
        state: addressState,
        addressType: addressType,
        streetAddress2: streetAddress2,
        selected: selected,
      );

      result.fold(
        (failure) {
          state = AddressError(failure, currentState);
        },
        (updatedAddress) {
          // Reload addresses to get updated list
          _loadAddresses();
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Delete an address
  Future<void> deleteAddress({required int id}) async {
    try {
      final currentState = state;
      final currentAddresses = currentState is AddressLoaded
          ? currentState.addresses
          : <AddressEntity>[];

      state = AddressProcessing(currentAddresses);

      final result = await _repository.deleteAddress(id: id);

      result.fold(
        (failure) {
          state = AddressError(failure, currentState);
        },
        (_) {
          // Reload addresses to get updated list
          _loadAddresses();
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }
}

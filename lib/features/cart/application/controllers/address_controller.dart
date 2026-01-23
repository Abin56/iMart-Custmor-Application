import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/address.dart';
import '../providers/cart_providers.dart';
import '../states/address_state.dart';

part 'address_controller.g.dart';

/// Address controller for CRUD operations
@riverpod
class AddressController extends _$AddressController {
  @override
  AddressState build() {
    // Load addresses when controller is first created
    loadAddresses();
    return AddressState.initial();
  }

  /// Load all addresses
  Future<void> loadAddresses() async {
    state = state.copyWith(status: AddressStatus.loading, errorMessage: null);

    try {
      final repository = ref.read(addressRepositoryProvider);
      final response = await repository.getAddresses();

      state = state.copyWith(
        status: AddressStatus.loaded,
        data: response,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AddressStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Create a new address
  Future<Address> createAddress({
    required String firstName,
    required String lastName,
    required String streetAddress1,
    required String city,
    required String countryArea,
    required String postalCode,
    required String country,
    required String phone,
    String? companyName,
    String? streetAddress2,
    String? cityArea,
  }) async {
    try {
      final repository = ref.read(addressRepositoryProvider);
      final address = await repository.createAddress(
        firstName: firstName,
        lastName: lastName,
        streetAddress1: streetAddress1,
        city: city,
        countryArea: countryArea,
        postalCode: postalCode,
        country: country,
        phone: phone,
        companyName: companyName,
        streetAddress2: streetAddress2,
        cityArea: cityArea,
      );

      // Reload addresses after creating
      await loadAddresses();

      return address;
    } catch (e) {
      state = state.copyWith(
        status: AddressStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Update an existing address
  Future<Address> updateAddress({
    required int id,
    String? firstName,
    String? lastName,
    String? companyName,
    String? streetAddress1,
    String? streetAddress2,
    String? city,
    String? cityArea,
    String? countryArea,
    String? postalCode,
    String? country,
    String? phone,
  }) async {
    try {
      final repository = ref.read(addressRepositoryProvider);
      final address = await repository.updateAddress(
        id: id,
        firstName: firstName,
        lastName: lastName,
        companyName: companyName,
        streetAddress1: streetAddress1,
        streetAddress2: streetAddress2,
        city: city,
        cityArea: cityArea,
        countryArea: countryArea,
        postalCode: postalCode,
        country: country,
        phone: phone,
      );

      // Reload addresses after updating
      await loadAddresses();

      return address;
    } catch (e) {
      state = state.copyWith(
        status: AddressStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete an address
  Future<void> deleteAddress(int id) async {
    try {
      final repository = ref.read(addressRepositoryProvider);
      await repository.deleteAddress(id);

      // Reload addresses after deleting
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(
        status: AddressStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Set default shipping address
  Future<void> setDefaultShippingAddress(int id) async {
    try {
      final repository = ref.read(addressRepositoryProvider);
      await repository.setDefaultShippingAddress(id);

      // Reload addresses after setting default
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(
        status: AddressStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Set default billing address
  Future<void> setDefaultBillingAddress(int id) async {
    try {
      final repository = ref.read(addressRepositoryProvider);
      await repository.setDefaultBillingAddress(id);

      // Reload addresses after setting default
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(
        status: AddressStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

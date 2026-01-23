import '../entities/address.dart';
import '../entities/address_list_response.dart';

/// Address repository interface
/// Defines contract for address management operations (CRUD)
abstract class AddressRepository {
  /// Get all addresses for the current user
  ///
  /// Returns list of addresses with pagination info
  /// Set [forceRefresh] to true to bypass cache
  Future<AddressListResponse> getAddresses({bool forceRefresh = false});

  /// Get a specific address by ID
  ///
  /// Throws [AddressNotFoundException] if address doesn't exist
  Future<Address> getAddressById(int id);

  /// Create a new address
  ///
  /// Throws [AddressValidationException] if validation fails
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
  });

  /// Update an existing address
  ///
  /// All fields are optional - only provided fields will be updated
  /// Throws [AddressNotFoundException] if address doesn't exist
  /// Throws [AddressValidationException] if validation fails
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
  });

  /// Delete an address
  ///
  /// Throws [AddressNotFoundException] if address doesn't exist
  Future<void> deleteAddress(int id);

  /// Set an address as default shipping address
  ///
  /// Automatically unsets previous default
  /// Throws [AddressNotFoundException] if address doesn't exist
  Future<Address> setDefaultShippingAddress(int id);

  /// Set an address as default billing address
  ///
  /// Automatically unsets previous default
  /// Throws [AddressNotFoundException] if address doesn't exist
  Future<Address> setDefaultBillingAddress(int id);
}

/// Exception thrown when address is not found
class AddressNotFoundException implements Exception {
  AddressNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when address validation fails
class AddressValidationException implements Exception {
  AddressValidationException(this.message, this.errors);

  final String message;
  final Map<String, List<String>> errors;

  @override
  String toString() => message;
}

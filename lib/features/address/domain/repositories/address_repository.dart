import '../entities/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getAddresses({bool forceRefresh = false});
  Future<Address> getAddress(int id);
  Future<Address> createAddress({
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
  });
  Future<Address> updateAddress({
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
  });
  Future<void> deleteAddress(int id);
  Future<Address> selectAddress(int id);
  Future<Address?> getSelectedAddress();
  Future<void> clearCache();
}

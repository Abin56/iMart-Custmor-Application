import 'package:dio/dio.dart';

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../data_sources/local/address_local_data_source.dart';
import '../data_sources/remote/address_remote_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl({
    required AddressRemoteDataSource remoteDataSource,
    required AddressLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final AddressRemoteDataSource _remoteDataSource;
  final AddressLocalDataSource _localDataSource;

  @override
  Future<List<Address>> getAddresses({bool forceRefresh = false}) async {
    try {
      // Try cache first if not forcing refresh
      if (!forceRefresh) {
        final cached = await _localDataSource.getCachedAddresses();
        if (cached.isNotEmpty) {
          return cached;
        }
      }

      // Fetch from API
      final dtos = await _remoteDataSource.fetchAddresses();
      final addresses = dtos.map((dto) => dto.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheAddresses(addresses);

      return addresses;
    } on DioException {
      // Return cached data on error if available
      final cached = await _localDataSource.getCachedAddresses();
      if (cached.isNotEmpty) {
        return cached;
      }

      rethrow;
    }
  }

  @override
  Future<Address> getAddress(int id) async {
    try {
      final dto = await _remoteDataSource.fetchAddress(id);
      return dto.toEntity();
    } on DioException {
      rethrow;
    }
  }

  @override
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
  }) async {
    try {
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'street_address_1': streetAddress1,
        if (streetAddress2 != null) 'street_address_2': streetAddress2,
        'city': city,
        'state': stateProvince,
        'postal_code': postalCode,
        'country': country,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'address_type': addressType,
      };

      final dto = await _remoteDataSource.createAddress(data);

      // Clear cache to force refresh
      await _localDataSource.clearCache();

      return dto.toEntity();
    } on DioException {
      rethrow;
    }
  }

  @override
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
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (streetAddress1 != null) data['street_address_1'] = streetAddress1;
      if (streetAddress2 != null) data['street_address_2'] = streetAddress2;
      if (city != null) data['city'] = city;
      if (stateProvince != null) data['state'] = stateProvince;
      if (postalCode != null) data['postal_code'] = postalCode;
      if (country != null) data['country'] = country;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (addressType != null) data['address_type'] = addressType;

      final dto = await _remoteDataSource.updateAddress(id, data);

      // Clear cache to force refresh
      await _localDataSource.clearCache();

      return dto.toEntity();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(int id) async {
    try {
      await _remoteDataSource.deleteAddress(id);

      // Clear cache to force refresh
      await _localDataSource.clearCache();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<Address> selectAddress(int id) async {
    try {
      final dto = await _remoteDataSource.selectAddress(id);

      // Clear cache to force refresh
      await _localDataSource.clearCache();

      return dto.toEntity();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<Address?> getSelectedAddress() async {
    try {
      final dto = await _remoteDataSource.fetchSelectedAddress();
      return dto?.toEntity();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }
}

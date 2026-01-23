import 'package:dio/dio.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/address_list_response.dart';
import '../../domain/repositories/address_repository.dart';
import '../data_sources/address_remote_data_source.dart';

/// Implementation of AddressRepository
/// Handles address CRUD operations with error handling
class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl({required AddressRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AddressRemoteDataSource _remoteDataSource;

  @override
  Future<AddressListResponse> getAddresses({bool forceRefresh = false}) async {
    try {
      final dto = await _remoteDataSource.getAddresses();
      return dto.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
  Future<Address> getAddressById(int id) async {
    try {
      final dto = await _remoteDataSource.getAddressById(id);
      return dto.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw AddressNotFoundException('Address not found');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
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
      final dto = await _remoteDataSource.createAddress(
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

      return dto.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final errors = <String, List<String>>{};
          errorData.forEach((key, value) {
            if (value is List) {
              errors[key] = value.map((e) => e.toString()).toList();
            } else {
              errors[key] = [value.toString()];
            }
          });
          throw AddressValidationException('Address validation failed', errors);
        }
        throw AddressValidationException('Address validation failed', {});
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
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
      final dto = await _remoteDataSource.updateAddress(
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

      return dto.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw AddressNotFoundException('Address not found');
      }
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final errors = <String, List<String>>{};
          errorData.forEach((key, value) {
            if (value is List) {
              errors[key] = value.map((e) => e.toString()).toList();
            } else {
              errors[key] = [value.toString()];
            }
          });
          throw AddressValidationException('Address validation failed', errors);
        }
        throw AddressValidationException('Address validation failed', {});
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(int id) async {
    try {
      await _remoteDataSource.deleteAddress(id);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw AddressNotFoundException('Address not found');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
  Future<Address> setDefaultShippingAddress(int id) async {
    try {
      final dto = await _remoteDataSource.setDefaultShippingAddress(id);
      return dto.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw AddressNotFoundException('Address not found');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }

  @override
  Future<Address> setDefaultBillingAddress(int id) async {
    try {
      final dto = await _remoteDataSource.setDefaultBillingAddress(id);
      return dto.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw AddressNotFoundException('Address not found');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';

import '../dtos/address_dto.dart';
import '../dtos/address_list_response_dto.dart';

/// Remote data source for address operations
/// Handles all address-related API calls
class AddressRemoteDataSource {
  AddressRemoteDataSource(this._dio);

  final Dio _dio;

  /// Get all addresses for the current user
  Future<AddressListResponseDto> getAddresses() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/auth/v1/address/',
    );
    return AddressListResponseDto.fromJson(response.data!);
  }

  /// Get a specific address by ID
  ///
  /// Throws DioException with 404 if address doesn't exist
  Future<AddressDto> getAddressById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/auth/v1/address/$id/',
    );
    return AddressDto.fromJson(response.data!);
  }

  /// Create a new address
  ///
  /// Throws DioException with 400 if validation fails
  Future<AddressDto> createAddress({
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
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/v1/address/',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'street_address_1': streetAddress1,
        'city': city,
        'country_area': countryArea,
        'postal_code': postalCode,
        'country': country,
        'phone': phone,
        if (companyName != null) 'company_name': companyName,
        if (streetAddress2 != null) 'street_address_2': streetAddress2,
        if (cityArea != null) 'city_area': cityArea,
      },
    );

    return AddressDto.fromJson(response.data!);
  }

  /// Update an existing address
  ///
  /// All fields are optional - only provided fields will be updated
  /// Throws DioException with 404 if address doesn't exist
  /// Throws DioException with 400 if validation fails
  Future<AddressDto> updateAddress({
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
    final data = <String, dynamic>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (companyName != null) data['company_name'] = companyName;
    if (streetAddress1 != null) data['street_address_1'] = streetAddress1;
    if (streetAddress2 != null) data['street_address_2'] = streetAddress2;
    if (city != null) data['city'] = city;
    if (cityArea != null) data['city_area'] = cityArea;
    if (countryArea != null) data['country_area'] = countryArea;
    if (postalCode != null) data['postal_code'] = postalCode;
    if (country != null) data['country'] = country;
    if (phone != null) data['phone'] = phone;

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/auth/v1/address/$id/',
      data: data,
    );

    return AddressDto.fromJson(response.data!);
  }

  /// Delete an address
  ///
  /// Returns 204 No Content on success
  /// Throws DioException with 404 if address doesn't exist
  Future<void> deleteAddress(int id) async {
    await _dio.delete('/api/auth/v1/address/$id/');
  }

  /// Set an address as default shipping address
  ///
  /// Automatically unsets previous default
  /// Throws DioException with 404 if address doesn't exist
  Future<AddressDto> setDefaultShippingAddress(int id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/v1/address/$id/set-default-shipping/',
    );

    return AddressDto.fromJson(response.data!);
  }

  /// Set an address as default billing address
  ///
  /// Automatically unsets previous default
  /// Throws DioException with 404 if address doesn't exist
  Future<AddressDto> setDefaultBillingAddress(int id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/v1/address/$id/set-default-billing/',
    );

    return AddressDto.fromJson(response.data!);
  }
}

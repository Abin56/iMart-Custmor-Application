import 'package:dio/dio.dart';

import '../../../../../app/core/network/api_client.dart';
import '../../dtos/address_dto.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressDto>> fetchAddresses();
  Future<AddressDto> fetchAddress(int id);
  Future<AddressDto> createAddress(Map<String, dynamic> data);
  Future<AddressDto> updateAddress(int id, Map<String, dynamic> data);
  Future<void> deleteAddress(int id);
  Future<AddressDto> selectAddress(int id);
  Future<AddressDto?> fetchSelectedAddress();
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  AddressRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;
  static const String _addressEndpoint = '/api/auth/v1/address/';

  @override
  Future<List<AddressDto>> fetchAddresses() async {
    try {
      final response = await _apiClient.get(_addressEndpoint);
      final data = AddressListResponseDto.fromJson(response.data);
      return data.results;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AddressDto> fetchAddress(int id) async {
    try {
      final response = await _apiClient.get('$_addressEndpoint$id/');
      return AddressDto.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AddressDto> createAddress(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(_addressEndpoint, data: data);
      return AddressDto.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AddressDto> updateAddress(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        '$_addressEndpoint$id/',
        data: data,
      );
      return AddressDto.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(int id) async {
    try {
      await _apiClient.delete('$_addressEndpoint$id/');
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AddressDto> selectAddress(int id) async {
    try {
      final response = await _apiClient.patch(
        '$_addressEndpoint$id/',
        data: {'selected': true},
      );
      return AddressDto.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AddressDto?> fetchSelectedAddress() async {
    try {
      final response = await _apiClient.get(
        _addressEndpoint,
        queryParameters: {'selected': 'true'},
      );
      final data = AddressListResponseDto.fromJson(response.data);

      if (data.results.isEmpty) {
        return null;
      }

      return data.results.first;
    } on DioException {
      rethrow;
    }
  }
}

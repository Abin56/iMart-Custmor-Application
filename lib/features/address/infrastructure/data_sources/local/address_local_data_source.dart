import 'dart:convert';

import '../../../../../app/core/storage/hive/boxes.dart';
import '../../../domain/entities/address.dart';

abstract class AddressLocalDataSource {
  Future<List<Address>> getCachedAddresses();
  Future<void> cacheAddresses(List<Address> addresses);
  Future<void> clearCache();
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  static const String _addressesKey = 'cached_addresses';
  static const String _timestampKey = 'addresses_cached_at';

  @override
  Future<List<Address>> getCachedAddresses() async {
    try {
      final box = Boxes.cacheBox;
      final jsonData = box.get(_addressesKey) as String?;
      final timestamp = box.get(_timestampKey) as String?;

      if (jsonData == null || timestamp == null) {
        return [];
      }

      // Check if cache is expired (24 hours)
      final cachedAt = DateTime.parse(timestamp);
      final age = DateTime.now().difference(cachedAt);
      if (age.inHours > 24) {
        await clearCache();
        return [];
      }

      final jsonList = jsonDecode(jsonData) as List;
      final addresses = jsonList
          .map((json) => _addressFromJson(json as Map<String, dynamic>))
          .toList();

      return addresses;
    } catch (e) {
      await clearCache();
      return [];
    }
  }

  @override
  Future<void> cacheAddresses(List<Address> addresses) async {
    try {
      final box = Boxes.cacheBox;
      final jsonList = addresses.map(_addressToJson).toList();
      final jsonData = jsonEncode(jsonList);

      await box.put(_addressesKey, jsonData);
      await box.put(_timestampKey, DateTime.now().toIso8601String());
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = Boxes.cacheBox;
      await box.delete(_addressesKey);
      await box.delete(_timestampKey);
      // ignore: empty_catches
    } catch (e) {}
  }

  // Helper methods
  Map<String, dynamic> _addressToJson(Address address) {
    return {
      'id': address.id,
      'firstName': address.firstName,
      'lastName': address.lastName,
      'streetAddress1': address.streetAddress1,
      'streetAddress2': address.streetAddress2,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'country': address.country,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'addressType': address.addressType,
      'selected': address.selected,
    };
  }

  Address _addressFromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      streetAddress1: json['streetAddress1'] as String,
      streetAddress2: json['streetAddress2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      addressType: json['addressType'] as String,
      selected: json['selected'] as bool? ?? false,
    );
  }
}

// coverage:ignore-file
// ignore_for_file: invalid_assignment

import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';

@freezed
class Address with _$Address {
  const factory Address({
    required int id,
    required String firstName,
    required String lastName,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String addressType, // 'home', 'work', 'other'
    String? streetAddress1,
    String? streetAddress2,
    String? latitude,
    String? longitude,
    @Default(false) bool selected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Address;

  const Address._();

  /// Full formatted address
  String get fullAddress {
    final parts = [
      if (streetAddress1 != null && streetAddress1!.isNotEmpty) streetAddress1!,
      if (streetAddress2 != null && streetAddress2!.isNotEmpty) streetAddress2!,
      city,
      state,
      postalCode,
    ];
    return parts.join(', ');
  }

  /// Full name
  String get fullName {
    // If first name and last name are the same, show only once
    if (firstName == lastName) {
      return firstName;
    }
    return '$firstName $lastName';
  }

  /// Short address type label
  String get typeLabel {
    switch (addressType.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      default:
        return 'Other';
    }
  }
}

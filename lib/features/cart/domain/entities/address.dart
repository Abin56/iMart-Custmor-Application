import 'package:equatable/equatable.dart';

/// Address entity
/// Represents a customer shipping/billing address in checkout
class Address extends Equatable {
  const Address({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.streetAddress1,
    required this.city,
    required this.countryArea,
    required this.postalCode,
    required this.country,
    required this.phone,
    required this.isDefaultShippingAddress,
    required this.isDefaultBillingAddress,
    this.companyName,
    this.streetAddress2,
    this.cityArea,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String? companyName;
  final String streetAddress1;
  final String? streetAddress2;
  final String city;
  final String? cityArea;
  final String countryArea; // State/Province
  final String postalCode;
  final String country; // Country code (e.g., "IN")
  final String phone;
  final bool isDefaultShippingAddress;
  final bool isDefaultBillingAddress;

  // Computed properties

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get formatted single-line address
  String get formattedAddress {
    final parts = <String>[
      streetAddress1,
      if (streetAddress2 != null && streetAddress2!.isNotEmpty) streetAddress2!,
      if (cityArea != null && cityArea!.isNotEmpty) cityArea!,
      city,
      countryArea,
      postalCode,
    ];
    return parts.join(', ');
  }

  /// Get formatted multi-line address
  String get formattedMultilineAddress {
    final buffer = StringBuffer();
    if (companyName != null && companyName!.isNotEmpty) {
      buffer.writeln(companyName);
    }
    buffer.writeln(streetAddress1);
    if (streetAddress2 != null && streetAddress2!.isNotEmpty) {
      buffer.writeln(streetAddress2);
    }
    if (cityArea != null && cityArea!.isNotEmpty) {
      buffer.writeln(cityArea);
    }
    buffer
      ..writeln('$city, $countryArea $postalCode')
      ..write(country);
    return buffer.toString();
  }

  /// Check if this is a default address (either shipping or billing)
  bool get isDefault => isDefaultShippingAddress || isDefaultBillingAddress;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    companyName,
    streetAddress1,
    streetAddress2,
    city,
    cityArea,
    countryArea,
    postalCode,
    country,
    phone,
    isDefaultShippingAddress,
    isDefaultBillingAddress,
  ];

  Address copyWith({
    int? id,
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
    bool? isDefaultShippingAddress,
    bool? isDefaultBillingAddress,
  }) {
    return Address(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      streetAddress1: streetAddress1 ?? this.streetAddress1,
      streetAddress2: streetAddress2 ?? this.streetAddress2,
      city: city ?? this.city,
      cityArea: cityArea ?? this.cityArea,
      countryArea: countryArea ?? this.countryArea,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      isDefaultShippingAddress:
          isDefaultShippingAddress ?? this.isDefaultShippingAddress,
      isDefaultBillingAddress:
          isDefaultBillingAddress ?? this.isDefaultBillingAddress,
    );
  }
}

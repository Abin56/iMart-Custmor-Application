import 'package:equatable/equatable.dart';

import 'address.dart';

/// Address list response entity
/// Wraps the list of customer addresses with pagination info
class AddressListResponse extends Equatable {
  const AddressListResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<Address> results;

  // Helper methods

  /// Get default shipping address
  Address? get defaultShippingAddress {
    try {
      return results.firstWhere((addr) => addr.isDefaultShippingAddress);
    } catch (_) {
      return null;
    }
  }

  /// Get default billing address
  Address? get defaultBillingAddress {
    try {
      return results.firstWhere((addr) => addr.isDefaultBillingAddress);
    } catch (_) {
      return null;
    }
  }

  /// Check if user has any saved addresses
  bool get hasAddresses => results.isNotEmpty;

  /// Check if user has no saved addresses
  bool get isEmpty => results.isEmpty;

  @override
  List<Object?> get props => [count, next, previous, results];

  AddressListResponse copyWith({
    int? count,
    String? next,
    String? previous,
    List<Address>? results,
  }) {
    return AddressListResponse(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }
}

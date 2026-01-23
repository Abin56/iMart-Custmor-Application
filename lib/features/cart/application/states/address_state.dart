import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/address_list_response.dart';

part 'address_state.freezed.dart';

/// Address list state
@freezed
class AddressState with _$AddressState {
  const factory AddressState({
    required AddressStatus status,
    AddressListResponse? data,
    String? errorMessage,
  }) = _AddressState;

  const AddressState._();

  /// Initial state
  factory AddressState.initial() =>
      const AddressState(status: AddressStatus.initial);

  /// Get all addresses
  List<Address> get addresses => data?.results ?? [];

  /// Get default shipping address
  Address? get defaultShippingAddress => data?.defaultShippingAddress;

  /// Get default billing address
  Address? get defaultBillingAddress => data?.defaultBillingAddress;

  /// Check if has addresses
  bool get hasAddresses => data?.hasAddresses ?? false;
}

/// Address status enum
enum AddressStatus {
  /// Initial state, no data loaded yet
  initial,

  /// Loading addresses
  loading,

  /// Addresses loaded successfully
  loaded,

  /// Error loading addresses
  error,
}

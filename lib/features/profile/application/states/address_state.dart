import 'package:imart/app/core/error/failure.dart';
import 'package:imart/features/auth/domain/entities/address.dart';

/// Sealed class for type-safe address state management
sealed class AddressState {
  const AddressState();
}

/// Initial state - checking for cached addresses
class AddressInitial extends AddressState {
  const AddressInitial();
}

/// Loading state - fetching addresses from API
class AddressLoading extends AddressState {
  const AddressLoading();
}

/// Addresses loaded successfully
class AddressLoaded extends AddressState {
  const AddressLoaded(this.addresses);

  final List<AddressEntity> addresses;

  /// Get selected/default address
  AddressEntity? get selectedAddress {
    try {
      return addresses.firstWhere((a) => a.selected);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  /// Check if addresses list is empty
  bool get isEmpty => addresses.isEmpty;

  /// Check if addresses list is not empty
  bool get isNotEmpty => addresses.isNotEmpty;
}

/// Processing address operation (add, update, delete)
class AddressProcessing extends AddressState {
  const AddressProcessing(this.currentAddresses);

  final List<AddressEntity> currentAddresses;
}

/// Address operation completed successfully
class AddressOperationSuccess extends AddressState {
  const AddressOperationSuccess(this.addresses, this.message);

  final List<AddressEntity> addresses;
  final String message;
}

/// Error state with previous state for recovery
class AddressError extends AddressState {
  const AddressError(this.failure, this.previousState);

  final Failure failure;
  final AddressState previousState;
}

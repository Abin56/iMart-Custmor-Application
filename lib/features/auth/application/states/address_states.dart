import 'package:imart/app/core/error/failure.dart';

import '../../domain/entities/address.dart';

sealed class AddressState {}

class AddressInitial extends AddressState {}

class AddressSaving extends AddressState {}

class AddressSaved extends AddressState {
  AddressSaved(this.address);
  final AddressEntity address;
}

class AddressSkipped extends AddressState {}

class AddressError extends AddressState {
  AddressError(this.failure);
  final Failure failure;
}

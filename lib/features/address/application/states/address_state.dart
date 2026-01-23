import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/address.dart';

part 'address_state.freezed.dart';

@freezed
class AddressState with _$AddressState {
  const factory AddressState.initial() = AddressInitial;
  const factory AddressState.loading() = AddressLoading;
  const factory AddressState.loaded({
    required List<Address> addresses,
    Address? selectedAddress,
  }) = AddressLoaded;
  const factory AddressState.error({required String message}) = AddressError;
}

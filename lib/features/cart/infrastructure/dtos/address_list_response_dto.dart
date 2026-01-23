// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/address_list_response.dart';
import 'address_dto.dart';

part 'address_list_response_dto.freezed.dart';
part 'address_list_response_dto.g.dart';

@freezed
class AddressListResponseDto with _$AddressListResponseDto {
  const factory AddressListResponseDto({
    required int count,
    required List<AddressDto> results,
    String? next,
    String? previous,
  }) = _AddressListResponseDto;

  const AddressListResponseDto._();

  factory AddressListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AddressListResponseDtoFromJson(json);

  /// Convert DTO to Entity
  AddressListResponse toEntity() {
    return AddressListResponse(
      count: count,
      results: results.map((addr) => addr.toEntity()).toList(),
      next: next,
      previous: previous,
    );
  }
}

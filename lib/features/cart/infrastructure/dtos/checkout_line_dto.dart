// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/checkout_line.dart';
import 'product_variant_details_dto.dart';

part 'checkout_line_dto.freezed.dart';
part 'checkout_line_dto.g.dart';

@freezed
class CheckoutLineDto with _$CheckoutLineDto {
  const factory CheckoutLineDto({
    required int id,
    @JsonKey(name: 'product_variant_id') required int productVariantId,
    required int quantity,
    @JsonKey(name: 'product_variant_details')
    required ProductVariantDetailsDto productVariantDetails,
    int? checkout,
  }) = _CheckoutLineDto;

  const CheckoutLineDto._();

  factory CheckoutLineDto.fromJson(Map<String, dynamic> json) =>
      _$CheckoutLineDtoFromJson(json);

  /// Convert DTO to Entity
  CheckoutLine toEntity() {
    return CheckoutLine(
      id: id,
      checkout: checkout,
      productVariantId: productVariantId,
      quantity: quantity,
      productVariantDetails: productVariantDetails.toEntity(),
    );
  }
}

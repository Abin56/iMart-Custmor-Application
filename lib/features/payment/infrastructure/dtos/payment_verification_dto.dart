import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/payment_verification.dart';

part 'payment_verification_dto.freezed.dart';
part 'payment_verification_dto.g.dart';

@freezed
class PaymentVerificationDto with _$PaymentVerificationDto {
  const factory PaymentVerificationDto({
    required bool success,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'order_id') required int orderId,
    required String message,
  }) = _PaymentVerificationDto;

  const PaymentVerificationDto._();

  factory PaymentVerificationDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentVerificationDtoFromJson(json);

  PaymentVerification toDomain() {
    return PaymentVerification(
      success: success,
      orderId: orderId,
      message: message,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/payment_initiation.dart';

part 'payment_initiation_dto.freezed.dart';
part 'payment_initiation_dto.g.dart';

/// Convert amount from either double or string to string
String _amountFromJson(dynamic amount) {
  if (amount is String) {
    return amount;
  } else if (amount is num) {
    return amount.toString();
  }
  throw Exception('Invalid amount type: ${amount.runtimeType}');
}

@freezed
class PaymentInitiationDto with _$PaymentInitiationDto {
  const factory PaymentInitiationDto({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'razorpay_order_id') required String razorpayOrderId,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'razorpay_key') required String razorpayKey,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'amount', fromJson: _amountFromJson) required String amount,
    required String currency,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'order_id') required int orderId,
  }) = _PaymentInitiationDto;

  const PaymentInitiationDto._();

  factory PaymentInitiationDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentInitiationDtoFromJson(json);

  PaymentInitiation toDomain() {
    return PaymentInitiation(
      razorpayOrderId: razorpayOrderId,
      razorpayKey: razorpayKey,
      amount: amount,
      currency: currency,
      orderId: orderId,
    );
  }
}

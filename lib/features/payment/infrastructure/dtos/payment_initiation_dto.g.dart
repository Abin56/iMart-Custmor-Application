// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_initiation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentInitiationDtoImpl _$$PaymentInitiationDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentInitiationDtoImpl(
  razorpayOrderId: json['razorpay_order_id'] as String,
  razorpayKey: json['razorpay_key'] as String,
  amount: _amountFromJson(json['amount']),
  currency: json['currency'] as String,
  orderId: (json['order_id'] as num).toInt(),
);

Map<String, dynamic> _$$PaymentInitiationDtoImplToJson(
  _$PaymentInitiationDtoImpl instance,
) => <String, dynamic>{
  'razorpay_order_id': instance.razorpayOrderId,
  'razorpay_key': instance.razorpayKey,
  'amount': instance.amount,
  'currency': instance.currency,
  'order_id': instance.orderId,
};

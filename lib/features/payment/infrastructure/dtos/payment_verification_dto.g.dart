// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_verification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentVerificationDtoImpl _$$PaymentVerificationDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentVerificationDtoImpl(
  success: json['success'] as bool,
  orderId: (json['order_id'] as num).toInt(),
  message: json['message'] as String,
);

Map<String, dynamic> _$$PaymentVerificationDtoImplToJson(
  _$PaymentVerificationDtoImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'order_id': instance.orderId,
  'message': instance.message,
};

import 'package:equatable/equatable.dart';

/// Payment Verification Response from backend
class PaymentVerification extends Equatable {
  const PaymentVerification({
    required this.success,
    required this.orderId,
    required this.message,
  });

  final bool success;
  final int orderId;
  final String message;

  @override
  List<Object?> get props => [success, orderId, message];
}

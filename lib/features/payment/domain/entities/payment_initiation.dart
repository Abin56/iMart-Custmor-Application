import 'package:equatable/equatable.dart';

/// Payment Initiation Response from backend
/// Contains Razorpay order details needed to start payment
class PaymentInitiation extends Equatable {
  const PaymentInitiation({
    required this.razorpayOrderId,
    required this.razorpayKey,
    required this.amount,
    required this.currency,
    required this.orderId,
  });

  final String razorpayOrderId;
  final String razorpayKey;
  final String amount;
  final String currency;
  final int orderId;

  /// Amount in paise (multiply by 100 for Razorpay)
  int get amountInPaise => (double.parse(amount) * 100).toInt();

  @override
  List<Object?> get props => [
    razorpayOrderId,
    razorpayKey,
    amount,
    currency,
    orderId,
  ];
}

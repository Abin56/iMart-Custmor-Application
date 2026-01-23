import '../entities/payment_initiation.dart';
import '../entities/payment_verification.dart';

/// Payment Repository Interface
abstract class PaymentRepository {
  /// Initiate payment and get Razorpay order details
  /// POST /api/order/v1/checkout/
  Future<PaymentInitiation> initiatePayment();

  /// Verify payment after Razorpay success
  /// POST /api/order/v1/payment/verify/
  Future<PaymentVerification> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/payment_initiation.dart';
import '../../domain/entities/payment_verification.dart';
import '../providers/payment_providers.dart';

part 'payment_controller.freezed.dart';
part 'payment_controller.g.dart';

/// Payment state
@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState({
    @Default(PaymentStatus.initial) PaymentStatus status,
    PaymentInitiation? paymentInitiation,
    PaymentVerification? paymentVerification,
    String? errorMessage,
  }) = _PaymentState;

  factory PaymentState.initial() => const PaymentState();
}

/// Payment status enum
enum PaymentStatus {
  initial,
  initiating,
  initiated,
  processing,
  verified,
  error,
}

/// Payment controller
@riverpod
class PaymentController extends _$PaymentController {
  @override
  PaymentState build() {
    return PaymentState.initial();
  }

  /// Initiate payment and get Razorpay order details
  Future<PaymentInitiation> initiatePayment() async {
    state = state.copyWith(
      status: PaymentStatus.initiating,
      errorMessage: null,
    );

    try {
      final repository = ref.read(paymentRepositoryProvider);
      final initiation = await repository.initiatePayment();

      state = state.copyWith(
        status: PaymentStatus.initiated,
        paymentInitiation: initiation,
      );

      return initiation;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Verify payment after Razorpay success
  Future<PaymentVerification> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    state = state.copyWith(
      status: PaymentStatus.processing,
      errorMessage: null,
    );

    try {
      final repository = ref.read(paymentRepositoryProvider);
      final verification = await repository.verifyPayment(
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      state = state.copyWith(
        status: PaymentStatus.verified,
        paymentVerification: verification,
      );

      return verification;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Reset payment state
  void reset() {
    state = PaymentState.initial();
  }
}

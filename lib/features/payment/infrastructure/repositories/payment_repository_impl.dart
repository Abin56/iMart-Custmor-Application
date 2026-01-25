import 'package:dio/dio.dart';

import '../../domain/entities/payment_initiation.dart';
import '../../domain/entities/payment_verification.dart';
import '../../domain/repositories/payment_repository.dart';
import '../dtos/payment_initiation_dto.dart';
import '../dtos/payment_verification_dto.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaymentInitiation> initiatePayment() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/order/v1/checkout/',
      );

      if (response.data == null) {
        throw Exception('No data received from payment initiation');
      }

      final dto = PaymentInitiationDto.fromJson(response.data!);
      return dto.toDomain();
    } on DioException catch (e) {
      // Handle authentication errors
      if (e.response?.statusCode == 403) {
        throw Exception('Authentication required. Please login again.');
      }

      // Handle server errors with helpful context
      if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?['error'] ??
            e.response?.data?['detail'] ??
            'Internal server error';
        throw Exception(
          'Server error occurred while processing checkout.\n\n'
          'Error: $errorMsg\n\n'
          'This may happen if:\n'
          '• Your cart is empty or has invalid items\n'
          '• A selected product is out of stock\n'
          '• There\'s no delivery address set\n'
          '• The backend service is temporarily unavailable\n\n'
          'Please try:\n'
          '1. Refresh your cart and verify all items\n'
          '2. Check your delivery address is set\n'
          '3. Try again in a few moments',
        );
      }

      // Handle other client/server errors
      final errorMessage =
          e.response?.data?['error'] ??
          e.response?.data?['detail'] ??
          'Failed to initiate payment';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  @override
  Future<PaymentVerification> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/order/v1/payment/verify/',
        data: {
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.data == null) {
        throw Exception('No data received from payment verification');
      }

      final dto = PaymentVerificationDto.fromJson(response.data!);
      return dto.toDomain();
    } on DioException catch (e) {
      // Handle authentication errors
      if (e.response?.statusCode == 403) {
        throw Exception('Authentication required. Please login again.');
      }

      // Handle server errors
      if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?['error'] ??
            e.response?.data?['detail'] ??
            'Internal server error';
        throw Exception(
          'Server error during payment verification.\n\n'
          'Error: $errorMsg\n\n'
          'Your payment was successful with Razorpay, but we couldn\'t '
          'verify it immediately. Our system will automatically process '
          'your order via webhook. Please check your orders section in '
          'a few minutes.',
        );
      }

      // Check for both 'error' and 'detail' fields in response
      final errorMessage =
          e.response?.data?['error'] ??
          e.response?.data?['detail'] ??
          'Failed to verify payment';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }
}

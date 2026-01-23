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
      if (e.response?.statusCode == 403) {
        throw Exception('Authentication required. Please login again.');
      }
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to initiate payment',
      );
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
      if (e.response?.statusCode == 403) {
        throw Exception('Authentication required. Please login again.');
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

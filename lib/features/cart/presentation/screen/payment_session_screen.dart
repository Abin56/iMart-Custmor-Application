import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../app/core/widgets/app_text.dart';
import '../../../../app/theme/colors.dart';
import '../../../auth/application/providers/auth_provider.dart';
import '../../../auth/application/states/auth_state.dart';
import '../../../payment/application/controllers/payment_controller.dart';
import '../../../profile/application/providers/order_provider.dart';
import '../../application/controllers/cart_controller.dart';
import '../../application/controllers/coupon_controller.dart';
import '../components/bill_summary.dart';
import '../components/cart_stepper.dart';
import '../components/promo_bottom_sheet.dart';

/// Payment Session Screen (Step 2)
/// Shows order summary, coupon application, and payment method selection
class PaymentSessionScreen extends ConsumerStatefulWidget {
  const PaymentSessionScreen({
    super.key,
    this.onBackPressed,
    this.onOrderPlaced,
  });
  final VoidCallback? onBackPressed;
  final VoidCallback? onOrderPlaced;

  @override
  ConsumerState<PaymentSessionScreen> createState() =>
      _PaymentSessionScreenState();
}

class _PaymentSessionScreenState extends ConsumerState<PaymentSessionScreen> {
  String? _selectedPaymentMethod;
  late Razorpay _razorpay;

  void _logDebug(String message, [Object? data]) {
    if (kDebugMode) {
      dev.log(
        '🔵 [RAZORPAY] $message${data != null ? ': $data' : ''}',
        name: 'PaymentSession',
      );
    }
  }

  void _logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      dev.log(
        '🔴 [RAZORPAY ERROR] $message${error != null ? ': $error' : ''}',
        name: 'PaymentSession',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _logDebug('Initializing Razorpay');
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _logDebug('Razorpay initialized with event listeners');
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'upi',
      name: 'UPI Payment',
      description: 'Pay using GPay, PhonePe, Paytm & more',
      icon: Icons.phonelink_ring,
      iconColor: const Color(0xFF4ECDC4),
    ),
    PaymentMethod(
      id: 'card',
      name: 'Credit/Debit Card',
      description: 'Visa, Mastercard, Rupay & more',
      icon: Icons.credit_card,
      iconColor: const Color(0xFFFF6B35),
    ),
    PaymentMethod(
      id: 'netbanking',
      name: 'Net Banking',
      description: 'All major banks supported',
      icon: Icons.account_balance,
      iconColor: const Color(0xFF25A63E),
    ),
    PaymentMethod(
      id: 'wallet',
      name: 'Digital Wallets',
      description: 'Paytm, PhonePe, Amazon Pay & more',
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFFFF8555),
    ),
    PaymentMethod(
      id: 'cod',
      name: 'Cash on Delivery',
      description: 'Pay when you receive',
      icon: Icons.money,
      iconColor: const Color(0xFF2C7A7B),
    ),
  ];

  void _showPromoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PromoBottomSheet(),
    );
  }

  void _removeCoupon() {
    ref.read(couponControllerProvider.notifier).clearCoupon();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Handle place order button - Initiate Razorpay payment
  Future<void> _handlePlaceOrder() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      _logDebug('Starting payment flow');
      _logDebug('Selected payment method', _selectedPaymentMethod);

      // Reset payment state before initiating new payment
      ref.read(paymentControllerProvider.notifier).reset();
      _logDebug('Payment state reset');

      // Step 1: Initiate payment with backend
      _logDebug('Initiating payment with backend...');
      final paymentInitiation = await ref
          .read(paymentControllerProvider.notifier)
          .initiatePayment();

      _logDebug('Payment initiation response received', {
        'razorpayOrderId': paymentInitiation.razorpayOrderId,
        'razorpayKey': '${paymentInitiation.razorpayKey.substring(0, 10)}...',
        'razorpayKeyFull':
            paymentInitiation.razorpayKey, // TEMP: Log full key for debugging
        'amount': paymentInitiation.amount,
        'amountInPaise': paymentInitiation.amountInPaise,
        'currency': paymentInitiation.currency,
        'orderId': paymentInitiation.orderId,
      });

      // Validate amount is positive and reasonable
      if (paymentInitiation.amountInPaise <= 0) {
        throw Exception(
          'Invalid amount: ${paymentInitiation.amountInPaise} paise',
        );
      }
      if (paymentInitiation.amountInPaise < 100) {
        _logError(
          'Amount is less than 1 INR (100 paise) - Razorpay minimum is 1 INR',
        );
      }

      // Step 2: Open Razorpay payment widget
      // Get user details for prefill to avoid Razorpay login/signup prompt
      final authState = ref.read(authProvider);
      String? userEmail;
      String? userPhone;
      String? userName;

      _logDebug('Auth state type', authState.runtimeType.toString());

      if (authState is Authenticated) {
        userEmail = authState.user.email;
        // Razorpay expects phone number without country code for Indian numbers
        // Remove +91, 91, 0 prefixes
        userPhone = authState.user.phoneNumber;
        userPhone = userPhone.replaceAll(RegExp(r'^\+91'), '');
        userPhone = userPhone.replaceAll(RegExp(r'^91(?=\d{10}$)'), '');
        userPhone = userPhone.replaceAll(RegExp('^0'), '');
        userPhone = userPhone.replaceAll(
          RegExp(r'[\s\-]'),
          '',
        ); // Remove spaces/dashes
        userName = '${authState.user.firstName} ${authState.user.lastName}'
            .trim();
        if (userName.isEmpty) {
          userName = authState.user.username;
        }
        _logDebug('User details for prefill', {
          'email': userEmail,
          'phone': userPhone,
          'originalPhone': authState.user.phoneNumber,
          'name': userName,
        });
      } else {
        _logError(
          'User is NOT authenticated! Auth state: ${authState.runtimeType}',
        );
      }

      final options = {
        'key': paymentInitiation.razorpayKey,
        'amount': paymentInitiation.amountInPaise,
        'currency': paymentInitiation.currency,
        'name': 'I-Mart',
        'description': 'Order Payment',
        'order_id': paymentInitiation.razorpayOrderId,
        'prefill': {
          'email': userEmail ?? '',
          'contact': userPhone ?? '',
          'name': userName ?? '',
        },
        'theme': {'color': '#25A63E'},
        'retry': {'enabled': true, 'max_count': 3},
        'timeout': 300, // 5 minutes timeout
        'modal': {'confirm_close': true, 'escape': false, 'handleback': true},
        // Disable external wallet selection which can cause issues
        'config': {
          'display': {
            'hide': [
              {'method': 'wallet'},
            ],
          },
        },
      };

      _logDebug('Opening Razorpay with options', {
        'key': '${options['key'].toString().substring(0, 10)}...',
        'amount': options['amount'],
        'currency': options['currency'],
        'order_id': options['order_id'],
        'prefill': options['prefill'],
        'timeout': options['timeout'],
      });

      _razorpay.open(options);
      _logDebug('Razorpay.open() called successfully');
    } catch (e, stackTrace) {
      _logError('Payment initiation failed', e, stackTrace);
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Show detailed error in a dialog for multi-line messages
      if (errorMessage.contains('\n')) {
        _showErrorDialog(
          'Payment Initiation Failed',
          errorMessage,
        );
      } else {
        // Show simple errors in snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Handle Razorpay payment success
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _logDebug('Payment SUCCESS callback received', {
      'paymentId': response.paymentId,
      'orderId': response.orderId,
      'signature': response.signature?.substring(0, 20),
    });

    try {
      // Step 3: Verify payment with backend
      _logDebug('Verifying payment with backend...');
      final verification = await ref
          .read(paymentControllerProvider.notifier)
          .verifyPayment(
            razorpayPaymentId: response.paymentId ?? '',
            razorpayOrderId: response.orderId ?? '',
            razorpaySignature: response.signature ?? '',
          );
      _logDebug('Payment verification response', {
        'success': verification.success,
        'orderId': verification.orderId,
        'message': verification.message,
      });

      if (verification.success && mounted) {
        // Clear cart state immediately (don't wait for backend)
        ref.read(cartControllerProvider.notifier).clearCart();

        // Clear applied coupon
        ref.read(couponControllerProvider.notifier).clearCoupon();

        // Refresh order list so new order appears
        unawaited(ref.read(orderProvider.notifier).refreshOrders());

        // Show success dialog
        if (mounted) {
          unawaited(
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _buildSuccessDialog(verification.orderId),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      _logError('Payment verification failed', e, stackTrace);
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Check if it's a reservation expired error
      if (errorMessage.contains('Reservation expired') ||
          errorMessage.contains('not found')) {
        _logDebug('Reservation expired - webhook will handle order creation');
        // Payment succeeded but verification failed due to timeout
        // The webhook will handle order creation
        if (mounted) {
          unawaited(
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _buildPaymentProcessingDialog(),
            ),
          );
        }
      } else {
        // Other verification errors
        _logError('Other verification error', errorMessage);
        if (mounted) {
          // Show detailed error in dialog for multi-line messages
          if (errorMessage.contains('\n')) {
            _showErrorDialog(
              'Payment Verification Failed',
              errorMessage,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment verification failed: $errorMessage'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    }
  }

  /// Handle Razorpay payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    _logError('Payment failed', {
      'code': response.code,
      'message': response.message,
      'error': response.error,
    });

    // Razorpay error codes reference:
    // 0 - Network error
    // 1 - Invalid options (wrong key, missing fields, etc.)
    // 2 - Payment cancelled by user
    // 3 - Payment failed
    // 4 - Invalid signature
    // 5 - External wallet was selected
    var errorDetail = '';
    switch (response.code) {
      case 0:
        errorDetail = 'Network error - Check your internet connection';
        break;
      case 1:
        errorDetail =
            'Configuration error - Invalid options passed to Razorpay';
        break;
      case 2:
        errorDetail = 'Payment cancelled by user';
        break;
      case 3:
        errorDetail = 'Payment failed at gateway';
        break;
      case 4:
        errorDetail = 'Invalid signature';
        break;
      default:
        errorDetail = response.message ?? 'Unknown error';
    }

    _logDebug('Error code interpretation', errorDetail);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed (Code ${response.code}): $errorDetail'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Handle external wallet (optional)
  void _handleExternalWallet(ExternalWalletResponse response) {
    _logDebug('External wallet selected', {'walletName': response.walletName});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error dialog with detailed message
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 45.sp,
                ),
              ),

              SizedBox(height: 20.h),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // Message
              Container(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: SingleChildScrollView(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // OK Button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Center(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Header
          Container(height: 13.h, color: const Color(0xFF0D5C2E)),
          _buildHeader(),

          // Progress Stepper
          const CartStepper(currentStep: 2),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Section
                  _buildSectionHeader('Order Summary'),
                  SizedBox(height: 12.h),
                  _buildOrderSummaryCard(),

                  SizedBox(height: 24.h),

                  // Coupon Section
                  _buildSectionHeader('Apply Coupon'),
                  SizedBox(height: 12.h),
                  _buildCouponSection(),

                  SizedBox(height: 24.h),

                  // Payment Method Section
                  _buildSectionHeader('Payment Method'),
                  SizedBox(height: 12.h),
                  _buildPaymentMethods(),

                  SizedBox(height: 80.h), // Space for button
                ],
              ),
            ),
          ),

          // Place Order Button
          _buildPlaceOrderButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 90.h,
      padding: EdgeInsets.only(
        top: 30.h,
        left: 20.w,
        right: 20.w,
        bottom: 10.h,
      ),
      decoration: const BoxDecoration(color: Color(0xFF0D5C2E)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              widget.onBackPressed?.call();
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          AppText(
            text: 'Payment',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return AppText(
      text: title,
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.black,
    );
  }

  Widget _buildOrderSummaryCard() {
    final cartState = ref.watch(cartControllerProvider);
    final couponState = ref.watch(couponControllerProvider);

    // Get subtotal from cart
    final subtotal = cartState.data?.originalTotal ?? 0.0;
    final discountAmount = couponState.getDiscountAmount(subtotal);
    final subtotalAfterDiscount = subtotal - discountAmount;
    final tax = subtotalAfterDiscount * 0.02;
    final total = subtotalAfterDiscount + tax;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bill Summary
          BillSummary(
            subtotal: '₹${subtotal.toStringAsFixed(2)}',
            tax: '₹${tax.toStringAsFixed(2)}',
            deliveryCharges: 'Free',
            discount: couponState.hasCoupon && discountAmount > 0
                ? '-₹${discountAmount.toStringAsFixed(2)}'
                : null,
            total: '₹${total.toStringAsFixed(2)}',
          ),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    final cartState = ref.watch(cartControllerProvider);
    final couponState = ref.watch(couponControllerProvider);
    final subtotal = cartState.data?.originalTotal ?? 0.0;
    final discountAmount = couponState.getDiscountAmount(subtotal);

    if (couponState.hasCoupon) {
      // Show applied coupon with attractive design
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF25A63E).withValues(alpha: 0.15),
              const Color(0xFF4ECDC4).withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF25A63E).withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25A63E).withValues(alpha: 0.2),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles in background
            Positioned(
              top: -20.h,
              right: -20.w,
              child: Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -10.h,
              left: -10.w,
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF25A63E).withValues(alpha: 0.1),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                children: [
                  // Success icon with glow effect
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF25A63E), Color(0xFF4ECDC4)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25A63E).withValues(alpha: 0.4),
                          blurRadius: 10.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Coupon details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coupon code with badge
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF25A63E),
                                    Color(0xFF2C8C3A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF25A63E,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 3.r,
                                    offset: Offset(0, 1.h),
                                  ),
                                ],
                              ),
                              child: Text(
                                couponState.appliedCoupon!.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.verified,
                              size: 16.sp,
                              color: const Color(0xFF25A63E),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),

                        // Savings amount with icon
                        Row(
                          children: [
                            Icon(
                              Icons.savings_outlined,
                              size: 14.sp,
                              color: const Color(0xFF2C7A7B),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'You saved ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '₹${discountAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF25A63E),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(
                              Icons.celebration,
                              size: 12.sp,
                              color: const Color(0xFFFFB800),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        // Discount description
                        Text(
                          couponState.appliedCoupon!.description,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Remove button
                  GestureDetector(
                    onTap: _removeCoupon,
                    child: Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show apply coupon button
    return GestureDetector(
      onTap: _showPromoBottomSheet,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8555)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: 'Apply Coupon Code',
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Save more on this order',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44B3AA)],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10.sp,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: List.generate(
        _paymentMethods.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildPaymentMethodCard(_paymentMethods[index]),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF25A63E) : Colors.grey.shade300,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF25A63E).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12.r : 8.r,
              offset: Offset(0, isSelected ? 4.h : 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: method.iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(method.icon, color: method.iconColor, size: 24.sp),
            ),

            SizedBox(width: 14.w),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Radio button
            Container(
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF25A63E)
                      : Colors.grey.shade400,
                  width: 2.w,
                ),
                color: isSelected
                    ? const Color(0xFF25A63E)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    final cartState = ref.watch(cartControllerProvider);
    final couponState = ref.watch(couponControllerProvider);
    final subtotal = cartState.data?.originalTotal ?? 0.0;
    final discountAmount = couponState.getDiscountAmount(subtotal);
    final subtotalAfterDiscount = subtotal - discountAmount;
    final tax = subtotalAfterDiscount * 0.02;
    final total = subtotalAfterDiscount + tax;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total amount display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF25A63E),
                    ),
                  ),
                ],
              ),
              // Place Order Button
              Expanded(
                child: GestureDetector(
                  onTap: _handlePlaceOrder,
                  child: Container(
                    margin: EdgeInsets.only(left: 20.w),
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25A63E),
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                          blurRadius: 20.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProcessingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Processing icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFF25A63E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_bottom_rounded,
                color: const Color(0xFF25A63E),
                size: 50.sp,
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'Payment Processing',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(
              'Your payment was successful and is being processed. You will receive an order confirmation shortly via email or check your orders section.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // OK Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigate back to home
                widget.onOrderPlaced?.call();
              },
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF25A63E),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Center(
                  child: Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDialog(int orderId) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon with animation
            Container(
              width: 80.w,
              height: 80.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF25A63E), Color(0xFF4ECDC4)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.white, size: 50.sp),
            ),

            SizedBox(height: 20.h),

            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(
              'Order #$orderId',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF25A63E),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(
              'Your order has been placed successfully. You will receive a confirmation shortly.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // OK Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigate back to home or orders screen
                widget.onOrderPlaced?.call();
              },
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF25A63E),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Center(
                  child: Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment Method model
class PaymentMethod {
  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
}

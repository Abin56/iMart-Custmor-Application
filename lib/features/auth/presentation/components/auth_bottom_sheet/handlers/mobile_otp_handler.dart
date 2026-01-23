import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/features/widgets/app_snackbar.dart';
import '../../../../application/providers/auth_provider.dart';
import '../../../../application/states/auth_state.dart';
import '../controllers/mobile_otp_controller.dart';
import '../utils/phone_mask_helper.dart';

class MobileOtpHandler {
  static void handleAction({
    required BuildContext context,
    required WidgetRef ref,
    required MobileOtpController controller,
    required AuthState state,
    required bool isSubmitting,
    required Function(bool) setSubmitting,
  }) {
    if (isSubmitting || state is OtpSending || state is OtpVerifying) return;

    final mobile = controller.mobileController.text.trim();
    if (mobile.isEmpty || mobile.length != 10) {
      AppSnackbar.error(context, 'Please enter a valid 10-digit mobile number');
      return;
    }

    if (!controller.showOtpField) {
      // Send OTP
      setSubmitting(true);
      final phoneWithCode = PhoneMaskHelper.addCountryCode(mobile);
      ref.read(authProvider.notifier).sendOtp(phoneWithCode);
    } else {
      // Verify OTP
      final otp = controller.completeOtp;
      if (otp.length != 6) {
        controller.setOtpError('Please enter all 6 digits');
        return;
      }
      setSubmitting(true);
      final phoneWithCode = PhoneMaskHelper.addCountryCode(mobile);
      ref.read(authProvider.notifier).verifyOtp(phoneWithCode, otp);
    }
  }

  static void handleResendOtp({
    required BuildContext context,
    required WidgetRef ref,
    required MobileOtpController controller,
  }) {
    final mobile = controller.mobileController.text.trim();
    if (mobile.isEmpty || mobile.length != 10) {
      AppSnackbar.error(context, 'Invalid mobile number');
      return;
    }
    controller.clearOtp();
    final phoneWithCode = PhoneMaskHelper.addCountryCode(mobile);
    ref.read(authProvider.notifier).sendOtp(phoneWithCode);
  }
}

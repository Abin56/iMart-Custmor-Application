import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/features/widgets/app_snackbar.dart';

import '../../../../application/providers/auth_repository_provider.dart';
import '../../../../application/states/auth_state.dart';
import '../../../../infrastructure/data_sources/remote/auth_api.dart';
import '../controllers/forgot_password_controller.dart';
import '../models/auth_mode.dart';
import '../utils/phone_mask_helper.dart';

class ForgotPasswordHandler {
  static Future<void> handleAction({
    required BuildContext context,
    required WidgetRef ref,
    required ForgotPasswordController controller,
    required AuthState state,
    required bool isSubmitting,
    required Function(bool) setSubmitting,
    required Function(AuthMode) switchMode,
  }) async {
    if (isSubmitting || state is OtpSending || state is OtpVerifying) return;

    final mobile = controller.mobileController.text.trim();
    if (mobile.isEmpty || mobile.length != 10) {
      AppSnackbar.error(context, 'Please enter a valid 10-digit mobile number');
      return;
    }

    if (!controller.showOtpField) {
      // Send OTP for forgot password
      setSubmitting(true);
      try {
        final authApi = ref.read(authApiProvider);
        final phoneWithCountryCode = PhoneMaskHelper.addCountryCode(mobile);
        final message = await authApi.sendOtp(
          phoneNumber: phoneWithCountryCode,
        );

        if (!context.mounted) return;

        setSubmitting(false);

        if (message == 'OTP sent successfully') {
          controller
            ..showOtpField = true
            ..setVerifiedData(phoneWithCountryCode, '')
            ..clearOtp();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (controller.otpFocusNodes[0].canRequestFocus) {
              controller.otpFocusNodes[0].requestFocus();
            }
          });
          AppSnackbar.success(context, 'OTP sent successfully');
        } else {
          AppSnackbar.error(context, message);
        }
      } catch (e) {
        if (!context.mounted) return;
        setSubmitting(false);
        AppSnackbar.error(context, e.toString());
      }
    } else {
      // Verify OTP and move to reset password
      final otp = controller.completeOtp;
      if (otp.length != 6) {
        controller.setOtpError('Please enter all 6 digits');
        return;
      }

      // Verify OTP with backend before moving to reset password
      setSubmitting(true);
      try {
        final repo = ref.read(authRepositoryProvider);
        final result = await repo.verifyOtpOnly(
          phoneNumber: controller.verifiedMobileNumber,
          otp: otp,
        );

        if (!context.mounted) return;

        setSubmitting(false);

        result.fold(
          (l) {
            controller.setOtpError(l.message);
          },
          (r) {
            // OTP verified successfully, session created
            controller.setVerifiedData(controller.verifiedMobileNumber, otp);
            switchMode(AuthMode.resetPassword);
          },
        );
      } catch (e) {
        if (!context.mounted) return;
        setSubmitting(false);
        controller.setOtpError(e.toString());
      }
    }
  }
}

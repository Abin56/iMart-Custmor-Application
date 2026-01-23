import 'package:flutter/material.dart';
import 'package:imart/features/widgets/app_snackbar.dart';

import '../../../../../../app/router/app_router.dart';
import '../../../../application/states/auth_state.dart';
import '../controllers/email_login_controller.dart';
import '../controllers/forgot_password_controller.dart';
import '../controllers/mobile_otp_controller.dart';
import '../models/auth_mode.dart';
import '../utils/error_message_handler.dart';

class AuthStateHandler {
  static void handleAuthStateChange({
    required BuildContext context,
    required AuthState state,
    required AuthMode currentMode,
    required MobileOtpController? mobileOtpController,
    required EmailLoginController? emailLoginController,
    required ForgotPasswordController? forgotPasswordController,
    required Function(bool) setSubmitting,
    required Function(
      bool, {
      String? otpError,
      String? mobileError,
      String? loginError,
      String? forgotOtpError,
    })
    setError,
  }) {
    if (state is OtpSent) {
      if (mobileOtpController != null) {
        mobileOtpController
          ..showOtpField = true
          ..clearOtp();
        setSubmitting(false);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mobileOtpController.otpFocusNodes[0].canRequestFocus) {
            mobileOtpController.otpFocusNodes[0].requestFocus();
          }
        });
      }
      AppSnackbar.success(context, 'OTP sent successfully');
    }

    if (state is Authenticated) {
      setSubmitting(false);
      Navigator.pop(context);

      // Check if user has a name, if not show welcome screen
      final user = state.user;
      if (user.firstName.isEmpty || user.firstName == user.username) {
        goToWelcomeName(context);
      } else {
        goToHome(context);
      }
    }

    if (state is AuthError) {
      setSubmitting(false);
      final failure = state.failure;
      final errorMessage = failure.message.toLowerCase();
      final isOtpError =
          errorMessage.contains('otp') ||
          errorMessage.contains('invalid') ||
          errorMessage.contains('expired');

      if (currentMode == AuthMode.mobileOTP && mobileOtpController != null) {
        if (mobileOtpController.showOtpField && isOtpError) {
          // Show OTP-specific error inline
          setError(
            true,
            otpError: ErrorMessageHandler.getOtpErrorMessage(failure),
          );
        } else if (!mobileOtpController.showOtpField) {
          // Show mobile number error inline before OTP field is shown
          setError(
            true,
            mobileError: ErrorMessageHandler.getUserFriendlyError(failure),
          );
        } else {
          AppSnackbar.error(
            context,
            ErrorMessageHandler.getUserFriendlyError(failure),
          );
        }
      } else if (currentMode == AuthMode.emailPassword &&
          emailLoginController != null) {
        // Show login error inline for email/password mode
        setError(
          true,
          loginError: ErrorMessageHandler.getUserFriendlyError(failure),
        );
      } else if (currentMode == AuthMode.forgotPassword &&
          forgotPasswordController != null) {
        if (forgotPasswordController.showOtpField && isOtpError) {
          setError(
            true,
            forgotOtpError: ErrorMessageHandler.getOtpErrorMessage(failure),
          );
        } else {
          AppSnackbar.error(
            context,
            ErrorMessageHandler.getUserFriendlyError(failure),
          );
        }
      } else {
        // For other modes (signup, reset password), use snackbar
        AppSnackbar.error(
          context,
          ErrorMessageHandler.getUserFriendlyError(failure),
        );
      }
    }

    if (state is OtpSending || state is OtpVerifying) {
      setSubmitting(true);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_button.dart';

import '../../../../../../../app/theme/app_spacing.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../../../../application/states/auth_state.dart';
import '../../../otp_input_field.dart';
import '../../controllers/mobile_otp_controller.dart';
import '../../models/auth_mode.dart';
import '../common/auth_error_message.dart';
import '../common/auth_field_label.dart';
import '../common/auth_header.dart';
import '../common/auth_mode_switcher.dart';
import '../fields/mobile_field.dart';
import '../otp/otp_error_message.dart';
import '../otp/otp_instructions.dart';
import '../otp/otp_resend_option.dart';

class MobileOtpScreen extends ConsumerWidget {
  const MobileOtpScreen({
    required this.controller,
    required this.authState,
    required this.onGetOtp,
    required this.onResendOtp,
    required this.onSwitchMode,
    required this.isSubmitting,
    super.key,
  });
  final MobileOtpController controller;
  final AuthState authState;
  final VoidCallback onGetOtp;
  final VoidCallback onResendOtp;
  final Function(AuthMode) onSwitchMode;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = authState is OtpSending || authState is OtpVerifying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthHeader(title: 'Welcome'),
        AppSpacing.h24,
        const AuthFieldLabel(label: 'Mobile Number'),
        AppSpacing.h8,
        MobileField(
          controller: controller.mobileController,
          enabled: !controller.showOtpField,
          fillColor: controller.showOtpField
              ? AppColors.field
              : AppColors.white,
        ),
        if (controller.hasMobileError && !controller.showOtpField) ...[
          AppSpacing.h16,
          AuthErrorMessage(message: controller.mobileErrorMessage),
        ],
        if (controller.showOtpField) ...[
          AppSpacing.h24,
          OtpInstructions(maskedPhoneNumber: controller.maskedPhoneNumber),
          AppSpacing.h16,
          OtpInputField(
            controllers: controller.otpControllers,
            focusNodes: controller.otpFocusNodes,
            hasError: controller.hasOtpError,
            onChanged: () {
              if (controller.hasOtpError) {
                controller.clearOtpError();
              }
            },
            onCompleted: () {},
          ),
          if (controller.hasOtpError) ...[
            AppSpacing.h8,
            OtpErrorMessage(message: controller.otpErrorMessage),
          ],
          AppSpacing.h16,
          OtpResendOption(
            isResending: authState is OtpSending,
            onResend: authState is OtpSending ? null : onResendOtp,
          ),
        ],
        AppSpacing.h32,
        _buildMainButton(isProcessing),
        AppSpacing.h16,
        AppButton(
          text: 'Sign in with password',
          onPressed: () => onSwitchMode(AuthMode.emailPassword),
          backgroundColor: AppColors.lightGreen,
          textColor: AppColors.titleColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          borderRadius: 30.r,
          height: 52.h,
        ),
        AppSpacing.h16,
        AuthModeSwitcher(
          promptText: "Don't have an account? ",
          actionText: 'Sign Up',
          onTap: () => onSwitchMode(AuthMode.signUp),
        ),
        AppSpacing.h16,
      ],
    );
  }

  Widget _buildMainButton(bool isProcessing) {
    var buttonText = 'Get OTP';
    if (authState is OtpSending) buttonText = 'Sending OTP...';
    if (authState is OtpVerifying) buttonText = 'Verifying...';
    if (controller.showOtpField) buttonText = 'Verify OTP';

    var isEnabled = false;
    if (!isProcessing && !isSubmitting) {
      if (controller.showOtpField) {
        isEnabled = controller.isOtpComplete;
      } else {
        isEnabled = controller.isMobileValid;
      }
    }

    return AppButton(
      text: buttonText,
      onPressed: isEnabled ? onGetOtp : null,
      isLoading: isProcessing || isSubmitting,
      backgroundColor: isEnabled
          ? AppColors.buttonGreen
          : AppColors.buttonGreen.withValues(alpha: 0.5),
      textColor: AppColors.white,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      borderRadius: 30.r,
      height: 52.h,
    );
  }
}

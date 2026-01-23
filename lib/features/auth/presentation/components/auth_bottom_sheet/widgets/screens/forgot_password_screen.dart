import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_button.dart';

import '../../../../../../../app/theme/app_spacing.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../../../../application/states/auth_state.dart';
import '../../../otp_input_field.dart';
import '../../controllers/forgot_password_controller.dart';
import '../common/auth_field_label.dart';
import '../common/auth_header.dart';
import '../fields/mobile_field.dart';
import '../otp/otp_error_message.dart';
import '../otp/otp_instructions.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({
    required this.controller,
    required this.authState,
    required this.onAction,
    required this.isSubmitting,
    super.key,
  });
  final ForgotPasswordController controller;
  final AuthState authState;
  final VoidCallback onAction;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = authState is OtpSending || authState is OtpVerifying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthHeader(title: 'Forgot password?'),
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
        ],
        AppSpacing.h32,
        _buildForgotPasswordButton(isProcessing),
        AppSpacing.h16,
      ],
    );
  }

  Widget _buildForgotPasswordButton(bool isProcessing) {
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
      onPressed: isEnabled ? onAction : null,
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

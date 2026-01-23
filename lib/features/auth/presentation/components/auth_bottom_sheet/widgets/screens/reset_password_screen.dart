import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_button.dart';

import '../../../../../../../app/theme/app_spacing.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../controllers/reset_password_controller.dart';
import '../../models/auth_mode.dart';
import '../../utils/validators.dart';
import '../common/auth_field_label.dart';
import '../common/auth_header.dart';
import '../common/auth_mode_switcher.dart';
import '../fields/password_field.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({
    required this.controller,
    required this.onReset,
    required this.onSwitchMode,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.isSubmitting,
    super.key,
  });
  final ResetPasswordController controller;
  final VoidCallback onReset;
  final Function(AuthMode) onSwitchMode;
  final Function() onTogglePassword;
  final Function() onToggleConfirmPassword;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthHeader(title: 'Reset Password'),
        AppSpacing.h24,
        const AuthFieldLabel(label: 'Set Password'),
        AppSpacing.h8,
        PasswordField(
          controller: controller.passwordController,
          obscureText: controller.obscurePassword,
          onToggleVisibility: onTogglePassword,
          validator: AuthValidators.validatePasswordWithLength,
          hintText: 'Must be 8 Characters',
        ),
        AppSpacing.h16,
        const AuthFieldLabel(label: 'Confirm Password'),
        AppSpacing.h8,
        PasswordField(
          controller: controller.confirmPasswordController,
          obscureText: controller.obscureConfirmPassword,
          onToggleVisibility: onToggleConfirmPassword,
          validator: (value) => AuthValidators.validateConfirmPassword(
            value,
            controller.passwordController.text,
          ),
          hintText: 'Re-frame password',
        ),
        AppSpacing.h16,
        AuthModeSwitcher(
          promptText: 'Already have an account? ',
          actionText: 'Login',
          onTap: () => onSwitchMode(AuthMode.emailPassword),
        ),
        AppSpacing.h24,
        AppButton(
          text: isSubmitting ? 'Resetting...' : 'Sign up',
          onPressed: !isSubmitting ? onReset : null,
          isLoading: isSubmitting,
          backgroundColor: AppColors.buttonGreen,
          textColor: AppColors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          borderRadius: 30.r,
          height: 52.h,
        ),
        AppSpacing.h16,
      ],
    );
  }
}

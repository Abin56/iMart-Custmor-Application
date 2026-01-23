import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_button.dart';
import 'package:imart/features/widgets/app_text.dart';
import '../../../../../../../app/theme/app_spacing.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../../../../application/states/auth_state.dart';
import '../../controllers/email_login_controller.dart';
import '../../models/auth_mode.dart';
import '../../utils/validators.dart';
import '../common/auth_error_message.dart';
import '../common/auth_field_label.dart';
import '../common/auth_header.dart';
import '../common/auth_mode_switcher.dart';
import '../fields/email_field.dart';
import '../fields/password_field.dart';

class EmailPasswordScreen extends ConsumerWidget {
  const EmailPasswordScreen({
    required this.controller,
    required this.authState,
    required this.onLogin,
    required this.onSwitchMode,
    required this.onTogglePassword,
    super.key,
  });
  final EmailLoginController controller;
  final AuthState authState;
  final VoidCallback onLogin;
  final Function(AuthMode) onSwitchMode;
  final Function() onTogglePassword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = authState is AuthLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthHeader(title: 'Welcome'),
        AppSpacing.h24,
        const AuthFieldLabel(label: 'Email/Username'),
        AppSpacing.h8,
        EmailField(
          controller: controller.emailController,
          validator: AuthValidators.validateEmailSimple,
        ),
        AppSpacing.h16,
        const AuthFieldLabel(label: 'Password'),
        AppSpacing.h8,
        PasswordField(
          controller: controller.passwordController,
          obscureText: controller.obscurePassword,
          onToggleVisibility: onTogglePassword,
          validator: AuthValidators.validatePassword,
        ),
        AppSpacing.h8,
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => onSwitchMode(AuthMode.forgotPassword),
            child: AppText(
              text: 'Forgot Password? Reset',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
            ),
          ),
        ),
        if (controller.hasLoginError) ...[
          AppSpacing.h16,
          AuthErrorMessage(message: controller.loginErrorMessage),
        ],
        AppSpacing.h16,
        AuthModeSwitcher(
          promptText: "Don't have an account? ",
          actionText: 'Sign Up',
          onTap: () => onSwitchMode(AuthMode.signUp),
        ),
        AppSpacing.h24,
        AppButton(
          text: isLoading ? 'Logging in...' : 'Login',
          onPressed: !isLoading ? onLogin : null,
          isLoading: isLoading,
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

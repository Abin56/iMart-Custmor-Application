import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/features/widgets/app_snackbar.dart';

import '../../../../application/providers/auth_provider.dart';
import '../controllers/signup_controller.dart';
import '../utils/phone_mask_helper.dart';

class SignupHandler {
  static void handleSignup({
    required BuildContext context,
    required WidgetRef ref,
    required SignupController controller,
    required GlobalKey<FormState> formKey,
  }) {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final emailOrUsername = controller.emailController.text.trim();
    final phone = controller.phoneController.text.trim();
    final password = controller.passwordController.text.trim();
    final confirmPassword = controller.confirmPasswordController.text.trim();

    if (emailOrUsername.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      AppSnackbar.error(context, 'Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      AppSnackbar.error(context, 'Passwords do not match');
      return;
    }

    if (password.length < 8) {
      AppSnackbar.error(context, 'Password must be at least 8 characters');
      return;
    }

    if (phone.length != 10) {
      AppSnackbar.error(context, 'Phone number must be 10 digits');
      return;
    }

    // Determine if input is email or username
    final isEmail = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailOrUsername);
    final email = isEmail ? emailOrUsername : '$emailOrUsername@temp.com';
    final username = isEmail ? emailOrUsername.split('@')[0] : emailOrUsername;
    final phoneWithCountryCode = PhoneMaskHelper.addCountryCode(phone);

    // Call signup with available data
    ref
        .read(authProvider.notifier)
        .signup(
          username: username,
          email: email,
          firstName: '',
          lastName: '',
          phoneNumber: phoneWithCountryCode,
          password: password,
          confirmPassword: confirmPassword,
        );
  }
}

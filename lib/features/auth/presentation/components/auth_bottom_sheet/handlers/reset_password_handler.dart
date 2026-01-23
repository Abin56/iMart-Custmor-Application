import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../widgets/app_snackbar.dart';
import '../../../../application/providers/auth_repository_provider.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordHandler {
  static Future<void> handleReset({
    required BuildContext context,
    required WidgetRef ref,
    required ResetPasswordController controller,
    required GlobalKey<FormState> formKey,
    required bool isSubmitting,
    required Function(bool) setSubmitting,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final password = controller.passwordController.text.trim();
    final confirmPassword = controller.confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
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

    setSubmitting(true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.resetPassword(newPassword: password);

      if (!context.mounted) return;

      setSubmitting(false);

      result.fold(
        (l) {
          AppSnackbar.error(context, l.message);
        },
        (r) {
          AppSnackbar.success(context, 'Password reset successfully');
          Navigator.pop(context); // Close bottom sheet
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      setSubmitting(false);
      AppSnackbar.error(context, e.toString());
    }
  }
}

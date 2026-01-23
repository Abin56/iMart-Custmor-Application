import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/features/widgets/app_snackbar.dart';
import '../../../../application/providers/auth_provider.dart';
import '../controllers/email_login_controller.dart';

class EmailLoginHandler {
  static void handleLogin({
    required BuildContext context,
    required WidgetRef ref,
    required EmailLoginController controller,
    required GlobalKey<FormState> formKey,
  }) {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final email = controller.emailController.text.trim();
    final password = controller.passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error(context, 'Please fill all fields');
      return;
    }

    ref.read(authProvider.notifier).login(email: email, password: password);
  }
}

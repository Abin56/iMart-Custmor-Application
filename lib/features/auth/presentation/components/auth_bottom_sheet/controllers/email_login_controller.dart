import 'package:flutter/material.dart';

class EmailLoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool hasLoginError = false;
  String loginErrorMessage = '';

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
  }

  void clearLoginError() {
    hasLoginError = false;
    loginErrorMessage = '';
  }

  void setLoginError(String message) {
    hasLoginError = true;
    loginErrorMessage = message;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

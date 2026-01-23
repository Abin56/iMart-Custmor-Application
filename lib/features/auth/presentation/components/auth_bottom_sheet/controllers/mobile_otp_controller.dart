import 'package:flutter/material.dart';

import '../utils/phone_mask_helper.dart';
import '../utils/validators.dart';

class MobileOtpController {
  final TextEditingController mobileController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool showOtpField = false;
  bool hasOtpError = false;
  String otpErrorMessage = '';
  bool hasMobileError = false;
  String mobileErrorMessage = '';

  String get completeOtp => otpControllers.map((c) => c.text).join();

  bool get isOtpComplete => AuthValidators.isOtpComplete(completeOtp);

  String get maskedPhoneNumber =>
      PhoneMaskHelper.maskPhoneNumber(mobileController.text.trim());

  bool get isMobileValid =>
      AuthValidators.isValidPhone(mobileController.text.trim());

  void clearOtp() {
    for (final controller in otpControllers) {
      controller.clear();
    }
    hasOtpError = false;
    otpErrorMessage = '';
  }

  void clearMobileError() {
    hasMobileError = false;
    mobileErrorMessage = '';
  }

  void clearOtpError() {
    hasOtpError = false;
    otpErrorMessage = '';
  }

  void setOtpError(String message) {
    hasOtpError = true;
    otpErrorMessage = message;
  }

  void setMobileError(String message) {
    hasMobileError = true;
    mobileErrorMessage = message;
  }

  void dispose() {
    mobileController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in otpFocusNodes) {
      node.dispose();
    }
  }
}

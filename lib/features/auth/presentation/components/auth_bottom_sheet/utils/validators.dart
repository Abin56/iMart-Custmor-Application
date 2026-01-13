class AuthValidators {
  // Phone validation
  static String? validatePhone(String? value) {
    if (value?.isEmpty ?? true) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
      return 'Enter valid 10-digit phone number';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Email validation (simple - for login)
  static String? validateEmailSimple(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    return null;
  }

  // Password with length validation
  static String? validatePasswordWithLength(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value?.isEmpty ?? true) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  // OTP validation
  static bool isOtpComplete(String otp) {
    return otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
  }

  // Phone format check
  static bool isValidPhone(String phone) {
    return phone.length == 10 && RegExp(r'^\d{10}$').hasMatch(phone);
  }
}

import 'package:imart/app/core/error/failure.dart';

class ErrorMessageHandler {
  /// Get user-friendly OTP error messages
  static String getOtpErrorMessage(Failure failure) {
    final message = failure.message.toLowerCase();
    if (message.contains('expired')) {
      return 'OTP has expired. Please request a new one.';
    }
    if (message.contains('invalid') || message.contains('incorrect')) {
      return 'Invalid OTP. Please check and try again.';
    }
    if (message.contains('attempts') || message.contains('limit')) {
      return 'Too many attempts. Please try again later.';
    }
    return failure.message;
  }

  /// Get user-friendly error messages for various auth scenarios
  static String getUserFriendlyError(Failure failure) {
    final message = failure.message.toLowerCase();

    // Connection errors
    if (message.contains('connection refused') ||
        message.contains('failed to connect') ||
        message.contains('socketexception')) {
      return 'Unable to connect to server. Please check your internet connection and try again.';
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return 'Request timed out. Please check your internet connection and try again.';
    }

    if (message.contains('network') || message.contains('no internet')) {
      return 'No internet connection. Please check your network settings.';
    }

    // Authentication errors
    if (message.contains('invalid credentials') ||
        message.contains('wrong password') ||
        message.contains('incorrect password')) {
      return 'Invalid email or password. Please try again.';
    }

    if (message.contains('user not found') ||
        message.contains('account not found') ||
        message.contains('does not exist')) {
      return 'Account not found. Please check your email or sign up.';
    }

    if (message.contains('account locked') ||
        message.contains('account disabled') ||
        message.contains('account suspended')) {
      return 'Your account has been locked. Please contact support.';
    }

    // Rate limiting errors
    if (message.contains('too many requests') ||
        message.contains('rate limit') ||
        message.contains('try again later')) {
      // Extract time if present (e.g., "30 minutes", "1 hour")
      final timeMatch = RegExp(
        r'(\d+)\s*(minute|hour|min|hr)s?',
      ).firstMatch(message);
      if (timeMatch != null) {
        final time = timeMatch.group(1);
        final unit = timeMatch.group(2);
        return 'Too many attempts. Please try again after $time ${unit}s.';
      }
      return 'Too many attempts. Please try again after 30 minutes.';
    }

    if (message.contains('maximum attempts') ||
        message.contains('limit reached') ||
        message.contains('exceeded')) {
      return 'Maximum login attempts reached. Please try again after 30 minutes.';
    }

    // Validation errors
    if (message.contains('invalid email') || message.contains('email format')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('invalid phone') || message.contains('phone format')) {
      return 'Please enter a valid phone number.';
    }

    if (message.contains('password too short') ||
        message.contains('password must be')) {
      return 'Password must be at least 8 characters long.';
    }

    if (message.contains('passwords do not match')) {
      return 'Passwords do not match. Please try again.';
    }

    // Account exists errors
    if (message.contains('already exists') ||
        message.contains('already registered') ||
        message.contains('already taken')) {
      return 'This email or phone number is already registered. Please login instead.';
    }

    // Server errors
    if (message.contains('500') ||
        message.contains('internal server error') ||
        message.contains('server error')) {
      return 'Something went wrong on our end. Please try again later.';
    }

    if (message.contains('503') ||
        message.contains('service unavailable') ||
        message.contains('maintenance')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    // Default: return original message if no match
    return failure.message;
  }
}

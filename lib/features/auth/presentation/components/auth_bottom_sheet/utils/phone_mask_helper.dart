class PhoneMaskHelper {
  /// Masks a phone number to show only last 4 digits
  /// Example: 9876543210 -> ******3210
  static String maskPhoneNumber(String number) {
    if (number.length < 4) return number;
    final visibleDigits = number.substring(number.length - 4);
    return '******$visibleDigits';
  }

  /// Adds country code to phone number
  /// Example: 9876543210 -> +919876543210
  static String addCountryCode(String phone, {String countryCode = '+91'}) {
    return '$countryCode$phone';
  }
}

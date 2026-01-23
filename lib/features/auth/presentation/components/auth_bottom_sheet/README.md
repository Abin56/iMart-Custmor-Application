# Authentication Bottom Sheet - Developer Guide

## Quick Start

### Usage
```dart
// Show the auth bottom sheet
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => const UnifiedAuthBottomSheet(),
);
```

## Folder Structure

```
auth_bottom_sheet/
├── unified_auth_bottom_sheet.dart       # Main entry point (406 lines)
├── models/                              # Data models
├── controllers/                         # State management
├── handlers/                            # Business logic
├── utils/                               # Pure functions
└── widgets/                             # UI components
    ├── screens/                         # Full screen views
    ├── fields/                          # Input fields
    ├── otp/                             # OTP-related widgets
    └── common/                          # Shared widgets
```

## File Organization

### When to Create Which File?

| Need | Create In | Example |
|------|-----------|---------|
| New auth flow | `screens/` | `biometric_screen.dart` |
| Form state | `controllers/` | `biometric_controller.dart` |
| API logic | `handlers/` | `biometric_handler.dart` |
| Input component | `fields/` | `biometric_field.dart` |
| Validation rule | `utils/validators.dart` | `validateBiometric()` |
| Shared UI element | `common/` | `auth_button.dart` |

## Common Tasks

### 1. Modify Existing Auth Mode

**Example: Change mobile OTP button text**

```dart
// File: widgets/screens/mobile_otp_screen.dart
// Line: ~110

// Before:
String buttonText = 'Get OTP';

// After:
String buttonText = 'Send Code';
```

### 2. Add New Validation Rule

```dart
// File: utils/validators.dart

// Add new validator
static String? validateUsername(String? value) {
  if (value?.isEmpty ?? true) return 'Username is required';
  if (value!.length < 3) return 'Username must be at least 3 characters';
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
    return 'Username can only contain letters, numbers, and underscores';
  }
  return null;
}

// Use in field
UsernameField(
  controller: controller,
  validator: AuthValidators.validateUsername,
)
```

### 3. Customize Error Messages

```dart
// File: utils/error_message_handler.dart

// Add new error pattern
if (message.contains('custom_error_code')) {
  return 'Your custom user-friendly message here';
}
```

### 4. Add New Input Field

```dart
// File: widgets/fields/custom_field.dart

import 'package:flutter/material.dart';
import 'auth_text_field.dart';

class CustomField extends StatelessWidget {
  final TextEditingController controller;

  const CustomField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hintText: 'Enter custom value',
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'This field is required';
        return null;
      },
    );
  }
}
```

### 5. Add New Auth Mode

See [AUTH_ARCHITECTURE.md](../../../../../../../../AUTH_ARCHITECTURE.md#extension-points) for detailed steps.

## Component Reference

### Controllers

| Controller | Purpose | Key Properties |
|------------|---------|----------------|
| `MobileOtpController` | Mobile OTP flow state | `showOtpField`, `hasOtpError`, `isOtpComplete` |
| `EmailLoginController` | Email/password login | `obscurePassword`, `hasLoginError` |
| `SignupController` | User registration | `obscurePassword`, `obscureConfirmPassword` |
| `ForgotPasswordController` | Password reset request | `showOtpField`, `verifiedMobileNumber` |
| `ResetPasswordController` | New password entry | `obscurePassword`, `obscureConfirmPassword` |

### Handlers

| Handler | Handles | Key Methods |
|---------|---------|-------------|
| `MobileOtpHandler` | Send & verify OTP | `handleAction()`, `handleResendOtp()` |
| `EmailLoginHandler` | Email/password auth | `handleLogin()` |
| `SignupHandler` | User registration | `handleSignup()` |
| `ForgotPasswordHandler` | Password reset flow | `handleAction()` |
| `ResetPasswordHandler` | Set new password | `handleReset()` |
| `AuthStateHandler` | Auth state changes | `handleAuthStateChange()` |

### Screens

| Screen | Displays | Fields |
|--------|----------|--------|
| `MobileOtpScreen` | Mobile OTP login | Mobile, OTP |
| `EmailPasswordScreen` | Email login | Email, Password |
| `SignupScreen` | Registration | Email, Phone, Password x2 |
| `ForgotPasswordScreen` | Password reset | Mobile, OTP |
| `ResetPasswordScreen` | New password | Password x2 |

### Reusable Widgets

#### Fields
- `AuthTextField` - Base text input (all others extend this)
- `MobileField` - 10-digit phone input
- `EmailField` - Email input with validation
- `PasswordField` - Password with visibility toggle
- `PhoneField` - Phone number (for signup)

#### Common
- `AuthHeader` - Screen title
- `AuthFieldLabel` - Input label
- `AuthErrorMessage` - Full-width error box
- `AuthModeSwitcher` - "Don't have account? Sign Up" links

#### OTP
- `OtpInstructions` - "Enter 6-digit OTP sent to..."
- `OtpErrorMessage` - OTP-specific error
- `OtpResendOption` - "Didn't receive? Resend OTP"

### Utilities

#### Validators (`utils/validators.dart`)
```dart
AuthValidators.validatePhone(value)           // 10-digit phone
AuthValidators.validateEmail(value)           // Email format
AuthValidators.validatePassword(value)        // Required password
AuthValidators.validatePasswordWithLength(value) // 8+ chars
AuthValidators.validateConfirmPassword(value, password) // Match check
AuthValidators.isOtpComplete(otp)            // 6-digit check
AuthValidators.isValidPhone(phone)           // Phone format check
```

#### Error Handler (`utils/error_message_handler.dart`)
```dart
ErrorMessageHandler.getUserFriendlyError(failure)  // Generic errors
ErrorMessageHandler.getOtpErrorMessage(failure)    // OTP-specific errors
```

#### Phone Helper (`utils/phone_mask_helper.dart`)
```dart
PhoneMaskHelper.maskPhoneNumber('9876543210')     // Returns: ******3210
PhoneMaskHelper.addCountryCode('9876543210')      // Returns: +919876543210
```

## Styling

### Theme Colors
```dart
AppColors.buttonGreen       // Primary button
AppColors.lightGreen        // Secondary button
AppColors.white             // Background
AppColors.black             // Text
AppColors.grey              // Secondary text
AppColors.darkGrey          // Labels
AppColors.red               // Errors
AppColors.field             // Disabled field
AppColors.titleColor        // Title text
```

### Spacing
```dart
AppSpacing.h8, h16, h24, h32  // Vertical spacing
AppSpacing.w8                  // Horizontal spacing
```

### Sizes (using ScreenUtil)
```dart
14.sp   // Small text
16.sp   // Regular text
20.sp   // Title text
12.r    // Border radius
30.r    // Button radius
52.h    // Button height
```

## Best Practices

### ✅ Do
- Use existing validators from `utils/validators.dart`
- Extend `AuthTextField` for new input types
- Put business logic in handlers, not widgets
- Use const constructors where possible
- Dispose controllers in the dispose method
- Add listeners in initState, remove in dispose

### ❌ Don't
- Put API calls directly in widgets
- Duplicate validation logic
- Create new text field styles (extend `AuthTextField`)
- Mix business logic with UI code
- Forget to remove listeners
- Hardcode colors or sizes (use theme)

## Debugging Tips

### Check Controller State
```dart
print('OTP Complete: ${controller.isOtpComplete}');
print('Has Error: ${controller.hasOtpError}');
print('Error Message: ${controller.otpErrorMessage}');
```

### Monitor Auth State
```dart
ref.listen<AuthState>(authProvider, (prev, next) {
  print('Auth State Changed: ${next.runtimeType}');
});
```

### Validate Handler Logic
```dart
// Add breakpoint in handler
MobileOtpHandler.handleAction(...);
```

## Common Issues

### Issue: Field not updating
**Solution**: Ensure controller listener is added and setState() is called

### Issue: OTP not showing
**Solution**: Check `controller.showOtpField` is set to true in state handler

### Issue: Error not displayed
**Solution**: Verify error handler is setting correct error flags

### Issue: Button stays disabled
**Solution**: Check validation logic in screen's `isEnabled` calculation

## Testing

### Test a Controller
```dart
test('MobileOtpController completes OTP with 6 digits', () {
  final controller = MobileOtpController();

  for (int i = 0; i < 6; i++) {
    controller.otpControllers[i].text = '$i';
  }

  expect(controller.isOtpComplete, true);
  expect(controller.completeOtp, '012345');

  controller.dispose();
});
```

### Test a Validator
```dart
test('validatePhone rejects invalid phone', () {
  expect(AuthValidators.validatePhone('123'), isNotNull);
  expect(AuthValidators.validatePhone('9876543210'), isNull);
});
```

### Test a Widget
```dart
testWidgets('MobileField displays hint text', (tester) async {
  final controller = TextEditingController();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MobileField(controller: controller),
      ),
    ),
  );

  expect(find.text('Enter your number'), findsOneWidget);
});
```

## Migration from Old Code

### Before (Monolithic)
```dart
// All in one file - hard to find and modify
_buildMobileField() { /* 30 lines */ }
_buildEmailField() { /* 25 lines */ }
_handleMobileOTPAction() { /* 50 lines */ }
```

### After (Modular)
```dart
// Easy to locate and modify
// widgets/fields/mobile_field.dart - 33 lines
// widgets/fields/email_field.dart - 27 lines
// handlers/mobile_otp_handler.dart - 59 lines
```

## Performance Tips

1. **Use const constructors**
   ```dart
   const AuthHeader(title: 'Welcome')  // ✅
   AuthHeader(title: 'Welcome')        // ❌
   ```

2. **Limit rebuilds**
   ```dart
   // Only rebuild specific widgets
   Consumer(builder: (context, ref, child) { ... })
   ```

3. **Dispose properly**
   ```dart
   @override
   void dispose() {
     controller.dispose();  // Prevents memory leaks
     super.dispose();
   }
   ```

## Support

For questions or issues:
1. Check [REFACTORING_SUMMARY.md](../../../../../../../../REFACTORING_SUMMARY.md)
2. Review [AUTH_ARCHITECTURE.md](../../../../../../../../AUTH_ARCHITECTURE.md)
3. See original backup: `unified_auth_bottom_sheet_backup.dart`

---

**Last Updated**: 2026-01-13
**Version**: 2.0 (Refactored)
**Maintained by**: Development Team

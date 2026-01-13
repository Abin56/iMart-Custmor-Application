# Authentication Code Refactoring Guide

## Current Status

The `splash_screen.dart` file is **1755 lines** and contains:
- SplashScreen widget
- UnifiedAuthBottomSheet widget (5 auth modes)
- All form fields, validators, and handlers
- State management for all auth modes

## Problems

1. **Single Responsibility Principle violated**: One file handles multiple concerns
2. **Hard to maintain**: Changes to one auth mode affect the entire file
3. **Code duplication**: Similar patterns repeated across modes
4. **Poor testability**: Difficult to unit test individual components
5. **Large file size**: 1755 lines is difficult to navigate

## Recommended Folder Structure

```
lib/features/auth/presentation/
├── components/
│   ├── auth_bottom_sheet/
│   │   ├── auth_mode.dart                    # Enum for auth modes
│   │   ├── unified_auth_bottom_sheet.dart    # Main bottom sheet container
│   │   ├── mobile_otp_mode.dart              # Mobile OTP login UI
│   │   ├── email_password_mode.dart          # Email/password login UI
│   │   ├── signup_mode.dart                  # Signup UI
│   │   ├── forgot_password_mode.dart         # Forgot password UI
│   │   ├── reset_password_mode.dart          # Reset password UI
│   │   └── auth_state_handler.dart           # State change handler logic
│   ├── form_fields/
│   │   ├── mobile_number_field.dart          # Reusable mobile field
│   │   ├── email_field.dart                  # Reusable email field
│   │   ├── password_field.dart               # Reusable password field
│   │   └── otp_input_field.dart              # OTP input with auto-fill
│   └── auth_buttons/
│       ├── auth_button.dart                  # Generic auth button
│       └── mode_switch_link.dart             # Switch between modes link
├── screen/
│   ├── splash_screen.dart                    # REFACTORED - Only splash logic
│   ├── welcome_name_screen.dart              # Onboarding screen
│   └── ... (other auth screens)
└── utils/
    └── auth_validators.dart                  # Form validation logic
```

## Refactoring Steps

### Step 1: Extract Reusable Components

**Already Done:**
- ✅ `otp_input_field.dart` - OTP input with SMS auto-fill

**To Do:**
1. Create `mobile_number_field.dart`
2. Create `email_field.dart`
3. Create `password_field.dart`

### Step 2: Extract Auth Mode Widgets

Split `UnifiedAuthBottomSheet` into:

1. **unified_auth_bottom_sheet.dart** (Container)
   - Manages current mode state
   - Handles mode switching
   - Contains auth state listener
   - Renders appropriate mode widget

2. **mobile_otp_mode.dart**
   - Mobile number input
   - OTP input fields
   - Get OTP / Verify OTP button
   - Resend OTP link
   - Switch to other modes

3. **email_password_mode.dart**
   - Email/username input
   - Password input
   - Login button
   - Forgot password link
   - Switch to signup

4. **signup_mode.dart**
   - Email input
   - Phone input
   - Password inputs
   - Signup button
   - Switch to login

5. **forgot_password_mode.dart**
   - Mobile number input
   - OTP input
   - Get OTP / Verify button

6. **reset_password_mode.dart**
   - New password input
   - Confirm password input
   - Reset button

### Step 3: Extract Business Logic

Create handlers:

1. **auth_actions.dart**
   ```dart
   class AuthActions {
     static void handleMobileOTPAction(...)
     static void handleEmailPasswordLogin(...)
     static void handleSignup(...)
     static void handleForgotPassword(...)
     static void handleResetPassword(...)
   }
   ```

2. **auth_validators.dart**
   ```dart
   class AuthValidators {
     static String? validateEmail(String? value)
     static String? validatePassword(String? value)
     static String? validatePhone(String? value)
     static String? validateOTP(String? value)
   }
   ```

### Step 4: Refactored SplashScreen

**New splash_screen.dart** should only contain:
```dart
class SplashScreen extends ConsumerStatefulWidget {
  // 1. Animation logic
  // 2. Auth state checking
  // 3. Navigation logic
  // 4. Get Started button
  // 5. Skip button
}

// MOVED to separate file:
// - UnifiedAuthBottomSheet widget
// - All auth mode UIs
// - Form handlers
```

## Benefits After Refactoring

1. **Maintainability**: Each file < 200 lines
2. **Reusability**: Components used across multiple screens
3. **Testability**: Easy to unit test individual components
4. **Readability**: Clear separation of concerns
5. **Scalability**: Easy to add new auth modes

## Implementation Priority

### High Priority (Do First)
1. ✅ Fix welcome screen keyboard overflow
2. ✅ Add SMS OTP auto-fill
3. Extract `UnifiedAuthBottomSheet` to separate file
4. Extract each auth mode to separate widget

### Medium Priority
1. Create reusable form field components
2. Extract validation logic
3. Extract business logic handlers

### Low Priority
1. Create custom auth button component
2. Add unit tests for validators
3. Add widget tests for components

## Quick Win: Move UnifiedAuthBottomSheet

**Immediate action** - Move from lines 198-1730 of `splash_screen.dart` to:

```
lib/features/auth/presentation/components/auth_bottom_sheet/unified_auth_bottom_sheet.dart
```

This alone will reduce `splash_screen.dart` from **1755 lines** to **~200 lines**!

## Code Example: Refactored Structure

### Before (splash_screen.dart - 1755 lines)
```dart
class SplashScreen { ... }
enum AuthMode { ... }
class UnifiedAuthBottomSheet { ... }  // 1500+ lines
```

### After (splash_screen.dart - ~150 lines)
```dart
import 'components/auth_bottom_sheet/unified_auth_bottom_sheet.dart';

class SplashScreen extends ConsumerStatefulWidget {
  // Only splash screen logic
  void _showAuthBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const UnifiedAuthBottomSheet(),
    );
  }
}
```

### After (unified_auth_bottom_sheet.dart - ~300 lines)
```dart
import 'auth_mode.dart';
import 'mobile_otp_mode.dart';
import 'email_password_mode.dart';
import 'signup_mode.dart';
import 'forgot_password_mode.dart';
import 'reset_password_mode.dart';

class UnifiedAuthBottomSheet extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return switch (_currentMode) {
      AuthMode.mobileOTP => MobileOTPMode(...),
      AuthMode.emailPassword => EmailPasswordMode(...),
      AuthMode.signUp => SignUpMode(...),
      AuthMode.forgotPassword => ForgotPasswordMode(...),
      AuthMode.resetPassword => ResetPasswordMode(...),
    };
  }
}
```

### After (mobile_otp_mode.dart - ~200 lines)
```dart
class MobileOTPMode extends StatelessWidget {
  final TextEditingController mobileController;
  final VoidCallback onGetOtp;
  // ... only mobile OTP UI and logic
}
```

## SMS OTP Auto-Fill Implementation

**Already Added:**
- ✅ `sms_autofill: ^2.4.0` package in pubspec.yaml
- ✅ `OtpInputField` widget with SMS auto-read

**Usage in UnifiedAuthBottomSheet:**
```dart
// Replace existing OTP input with:
OtpInputField(
  controllers: _otpControllers,
  focusNodes: _otpFocusNodes,
  hasError: _hasOtpError,
  onChanged: _onOtpChanged,
  onCompleted: () => _handleMobileOTPAction(authState),
  enabled: !_isSubmitting,
)
```

**Android Permissions Required (already in AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
```

## Next Steps

1. Run `flutter pub get` to install `sms_autofill` package
2. Test OTP auto-fill on physical Android device
3. Move `UnifiedAuthBottomSheet` to separate file
4. Gradually extract each auth mode to its own widget
5. Create reusable form field components

---

**Status:** ✅ Keyboard overflow fixed | ✅ SMS auto-fill added | ⏳ Code refactoring pending

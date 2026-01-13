# Authentication Bottom Sheet Architecture

## Component Hierarchy

```
UnifiedAuthBottomSheet (Main Entry Point)
│
├── Controllers (State Management)
│   ├── MobileOtpController
│   ├── EmailLoginController
│   ├── SignupController
│   ├── ForgotPasswordController
│   └── ResetPasswordController
│
├── Handlers (Business Logic)
│   ├── MobileOtpHandler
│   ├── EmailLoginHandler
│   ├── SignupHandler
│   ├── ForgotPasswordHandler
│   ├── ResetPasswordHandler
│   └── AuthStateHandler
│
└── Screens (UI)
    ├── MobileOtpScreen
    │   ├── MobileField
    │   ├── OtpInputField (external component)
    │   ├── OtpInstructions
    │   ├── OtpErrorMessage
    │   └── OtpResendOption
    │
    ├── EmailPasswordScreen
    │   ├── EmailField
    │   ├── PasswordField
    │   └── AuthModeSwitcher
    │
    ├── SignupScreen
    │   ├── EmailField
    │   ├── PhoneField
    │   ├── PasswordField (x2)
    │   └── AuthModeSwitcher
    │
    ├── ForgotPasswordScreen
    │   ├── MobileField
    │   ├── OtpInputField
    │   ├── OtpInstructions
    │   └── OtpErrorMessage
    │
    └── ResetPasswordScreen
        ├── PasswordField (x2)
        └── AuthModeSwitcher
```

## Data Flow

```
User Action
    ↓
Screen Widget (UI)
    ↓
Handler (Business Logic)
    ↓
Provider/Repository (Data Layer)
    ↓
API Call
    ↓
AuthState Update
    ↓
AuthStateHandler (State Processing)
    ↓
Controller Update (State Sync)
    ↓
Screen Widget Re-render (UI Update)
```

## Module Dependencies

```
┌─────────────────────────────────────────┐
│   unified_auth_bottom_sheet.dart        │  ← Main orchestrator
│   (406 lines - was 1,640)               │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴────────┬──────────────┬────────────┐
       ↓                ↓              ↓            ↓
┌─────────────┐  ┌──────────┐  ┌───────────┐  ┌──────────┐
│ Controllers │  │ Handlers │  │  Screens  │  │  Models  │
│  (5 files)  │  │(6 files) │  │ (5 files) │  │(1 file)  │
└─────┬───────┘  └────┬─────┘  └─────┬─────┘  └──────────┘
      │               │               │
      └───────┬───────┴───────┬───────┘
              ↓               ↓
       ┌──────────┐    ┌──────────────┐
       │  Utils   │    │   Widgets    │
       │(3 files) │    │              │
       └──────────┘    │ ┌──────────┐ │
                       │ │  Fields  │ │
                       │ │(5 files) │ │
                       │ └──────────┘ │
                       │ ┌──────────┐ │
                       │ │   OTP    │ │
                       │ │(3 files) │ │
                       │ └──────────┘ │
                       │ ┌──────────┐ │
                       │ │  Common  │ │
                       │ │(4 files) │ │
                       │ └──────────┘ │
                       └──────────────┘
```

## Responsibility Matrix

| Component | Responsibility | Examples |
|-----------|---------------|----------|
| **Controllers** | Manage form state, text controllers, focus nodes | `MobileOtpController.showOtpField` |
| **Handlers** | Execute business logic, API calls, validation | `MobileOtpHandler.handleAction()` |
| **Screens** | Compose UI, handle layout | `MobileOtpScreen` builds the full screen |
| **Fields** | Input components with validation | `EmailField`, `PasswordField` |
| **Utils** | Pure functions, no side effects | `AuthValidators.validatePhone()` |
| **Models** | Data structures and enums | `AuthMode.mobileOTP` |

## Example: Mobile OTP Flow

```
1. User enters phone number
   ↓
2. MobileOtpScreen.onGetOtp() called
   ↓
3. _handleMobileOTPAction() in main file
   ↓
4. MobileOtpHandler.handleAction()
   ├── Validates phone number
   ├── Calls ref.read(authProvider.notifier).sendOtp()
   └── Updates _isSubmitting state
   ↓
5. AuthState changes to OtpSent
   ↓
6. AuthStateHandler.handleAuthStateChange()
   ├── Detects OtpSent state
   ├── Updates MobileOtpController.showOtpField = true
   └── Shows success snackbar
   ↓
7. Screen rebuilds with OTP input field
   ↓
8. User enters OTP
   ↓
9. MobileOtpScreen.onGetOtp() called again
   ↓
10. MobileOtpHandler.handleAction()
    ├── Validates OTP (6 digits)
    ├── Calls ref.read(authProvider.notifier).verifyOtp()
    └── Updates _isSubmitting state
    ↓
11. AuthState changes to Authenticated
    ↓
12. AuthStateHandler.handleAuthStateChange()
    ├── Detects Authenticated state
    ├── Closes bottom sheet
    └── Navigates to home or welcome screen
```

## State Management

### Controller State (UI State)
- Text input values
- Focus states
- Show/hide fields
- Error messages
- Loading states

### Auth State (Business State)
- `AuthInitial`
- `OtpSending`
- `OtpSent`
- `OtpVerifying`
- `AuthLoading`
- `Authenticated`
- `AuthError`

### Local State (Component State)
- `_isSubmitting` (button loading)
- `_currentMode` (which screen to show)
- `_formKey` (form validation)

## Reusable Components

### Base Components
```
AuthTextField (92 lines)
    ↓
├── MobileField (33 lines)
├── EmailField (27 lines)
├── PasswordField (44 lines)
└── PhoneField (29 lines)
```

### Composed Components
```
Screen Widgets
    ↓
├── Fields (from above)
├── Common Widgets
│   ├── AuthHeader
│   ├── AuthFieldLabel
│   ├── AuthErrorMessage
│   └── AuthModeSwitcher
└── OTP Widgets
    ├── OtpInstructions
    ├── OtpErrorMessage
    └── OtpResendOption
```

## Error Handling Flow

```
API Error
    ↓
AuthError State
    ↓
AuthStateHandler.handleAuthStateChange()
    ↓
ErrorMessageHandler.getUserFriendlyError()
    ├── Maps technical errors to user-friendly messages
    └── Returns localized error string
    ↓
Display Error
    ├── Inline (AuthErrorMessage widget)
    ├── Field-specific (OtpErrorMessage widget)
    └── Toast (AppSnackbar)
```

## Testing Strategy

### Unit Tests
```dart
// Controllers
test('MobileOtpController completes OTP')
test('EmailLoginController toggles password visibility')

// Validators
test('validatePhone accepts 10 digits')
test('validateEmail rejects invalid format')

// Handlers
test('MobileOtpHandler sends OTP with country code')
test('SignupHandler validates password match')

// Utils
test('ErrorMessageHandler maps connection errors')
test('PhoneMaskHelper masks phone correctly')
```

### Widget Tests
```dart
// Screens
testWidgets('MobileOtpScreen shows OTP field after send')
testWidgets('EmailPasswordScreen validates inputs')

// Fields
testWidgets('PasswordField toggles visibility')
testWidgets('MobileField accepts only digits')

// Common Widgets
testWidgets('AuthErrorMessage displays error')
testWidgets('AuthModeSwitcher switches modes')
```

### Integration Tests
```dart
testWidgets('Complete mobile OTP login flow')
testWidgets('Complete email/password login flow')
testWidgets('Complete signup flow')
testWidgets('Complete forgot password flow')
```

## Extension Points

### Adding New Auth Mode

1. **Create Model**
   ```dart
   // models/auth_mode.dart
   enum AuthMode {
     mobileOTP,
     emailPassword,
     signUp,
     forgotPassword,
     resetPassword,
     biometric, // NEW
   }
   ```

2. **Create Controller**
   ```dart
   // controllers/biometric_controller.dart
   class BiometricController {
     bool isAvailable = false;
     // ... state management
   }
   ```

3. **Create Handler**
   ```dart
   // handlers/biometric_handler.dart
   class BiometricHandler {
     static Future<void> authenticate() {
       // ... business logic
     }
   }
   ```

4. **Create Screen**
   ```dart
   // widgets/screens/biometric_screen.dart
   class BiometricScreen extends ConsumerWidget {
     // ... UI composition
   }
   ```

5. **Wire in Main File**
   ```dart
   // unified_auth_bottom_sheet.dart
   case AuthMode.biometric:
     return BiometricScreen(...);
   ```

## Performance Optimizations

### 1. Const Constructors
```dart
const AuthHeader(title: 'Welcome')  // Avoids unnecessary rebuilds
```

### 2. ConsumerWidget
```dart
class MobileOtpScreen extends ConsumerWidget  // Efficient state updates
```

### 3. Controller Disposal
```dart
@override
void dispose() {
  _mobileOtpController.dispose();  // Prevents memory leaks
  super.dispose();
}
```

### 4. Listener Management
```dart
controller.addListener(_onChanged);     // Add in initState
controller.removeListener(_onChanged);  // Remove in dispose
```

### 5. Conditional Rendering
```dart
if (controller.showOtpField) ...[]  // Only build when needed
```

---

**Architecture designed for**: Maintainability, Testability, Scalability
**Pattern**: Clean Architecture + MVVM
**State Management**: Riverpod
**Status**: ✅ Production Ready

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../../app/theme/colors.dart';
// import '../../../application/providers/auth_provider.dart';
// import '../../../application/states/auth_state.dart';
// import 'controllers/email_login_controller.dart';
// import 'controllers/forgot_password_controller.dart';
// import 'controllers/mobile_otp_controller.dart';
// import 'controllers/reset_password_controller.dart';
// import 'controllers/signup_controller.dart';
// import 'handlers/auth_state_handler.dart';
// import 'handlers/email_login_handler.dart';
// import 'handlers/forgot_password_handler.dart';
// import 'handlers/mobile_otp_handler.dart';
// import 'handlers/reset_password_handler.dart';
// import 'handlers/signup_handler.dart';
// import 'models/auth_mode.dart';
// import 'widgets/screens/email_password_screen.dart';
// import 'widgets/screens/forgot_password_screen.dart';
// import 'widgets/screens/mobile_otp_screen.dart';
// import 'widgets/screens/reset_password_screen.dart';
// import 'widgets/screens/signup_screen.dart';

// class UnifiedAuthBottomSheet extends ConsumerStatefulWidget {
//   const UnifiedAuthBottomSheet({super.key});

//   @override
//   ConsumerState<UnifiedAuthBottomSheet> createState() =>
//       _UnifiedAuthBottomSheetState();
// }

// class _UnifiedAuthBottomSheetState
//     extends ConsumerState<UnifiedAuthBottomSheet> {
//   AuthMode _currentMode = AuthMode.mobileOTP;

//   // Controllers
//   late final MobileOtpController _mobileOtpController;
//   late final EmailLoginController _emailLoginController;
//   late final SignupController _signupController;
//   late final ForgotPasswordController _forgotPasswordController;
//   late final ResetPasswordController _resetPasswordController;

//   final _formKey = GlobalKey<FormState>();
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _mobileOtpController = MobileOtpController();
//     _emailLoginController = EmailLoginController();
//     _signupController = SignupController();
//     _forgotPasswordController = ForgotPasswordController();
//     _resetPasswordController = ResetPasswordController();

//     // Add listeners for error clearing
//     _mobileOtpController.mobileController.addListener(_onMobileFieldChanged);
//     _emailLoginController.emailController.addListener(_onLoginFieldChanged);
//     _emailLoginController.passwordController.addListener(_onLoginFieldChanged);

//     for (var controller in _mobileOtpController.otpControllers) {
//       controller.addListener(_onOtpChanged);
//     }
//     for (var controller in _forgotPasswordController.otpControllers) {
//       controller.addListener(_onForgotOtpChanged);
//     }
//   }

//   @override
//   void dispose() {
//     _mobileOtpController.mobileController.removeListener(_onMobileFieldChanged);
//     _emailLoginController.emailController.removeListener(_onLoginFieldChanged);
//     _emailLoginController.passwordController.removeListener(_onLoginFieldChanged);

//     for (var controller in _mobileOtpController.otpControllers) {
//       controller.removeListener(_onOtpChanged);
//     }
//     for (var controller in _forgotPasswordController.otpControllers) {
//       controller.removeListener(_onForgotOtpChanged);
//     }

//     _mobileOtpController.dispose();
//     _emailLoginController.dispose();
//     _signupController.dispose();
//     _forgotPasswordController.dispose();
//     _resetPasswordController.dispose();
//     super.dispose();
//   }

//   void _onOtpChanged() {
//     if (_mobileOtpController.hasOtpError) {
//       setState(() {
//         _mobileOtpController.clearOtpError();
//       });
//     }
//     setState(() {});
//   }

//   void _onForgotOtpChanged() {
//     if (_forgotPasswordController.hasOtpError) {
//       setState(() {
//         _forgotPasswordController.clearOtpError();
//       });
//     }
//     setState(() {});
//   }

//   void _onLoginFieldChanged() {
//     if (_emailLoginController.hasLoginError) {
//       setState(() {
//         _emailLoginController.clearLoginError();
//       });
//     }
//   }

//   void _onMobileFieldChanged() {
//     if (_mobileOtpController.hasMobileError) {
//       setState(() {
//         _mobileOtpController.clearMobileError();
//       });
//     }
//   }

//   void _switchMode(AuthMode mode) {
//     setState(() {
//       _currentMode = mode;
//       _mobileOtpController.showOtpField = false;
//       _mobileOtpController.hasOtpError = false;
//       _mobileOtpController.otpErrorMessage = '';
//       _mobileOtpController.hasMobileError = false;
//       _mobileOtpController.mobileErrorMessage = '';
//       _forgotPasswordController.showOtpField = false;
//       _forgotPasswordController.hasOtpError = false;
//       _forgotPasswordController.otpErrorMessage = '';
//       _emailLoginController.hasLoginError = false;
//       _emailLoginController.loginErrorMessage = '';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);

//     ref.listen<AuthState>(authProvider, (prev, next) {
//       _handleAuthStateChange(next);
//     });

//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.75,
//         ),
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30.r),
//             topRight: Radius.circular(30.r),
//           ),
//         ),
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: EdgeInsets.only(
//             left: 24.w,
//             right: 24.w,
//             top: 32.h,
//             bottom: 24.h,
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildCurrentScreen(authState),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentScreen(AuthState authState) {
//     switch (_currentMode) {
//       case AuthMode.mobileOTP:
//         return MobileOtpScreen(
//           controller: _mobileOtpController,
//           authState: authState,
//           onGetOtp: () => _handleMobileOTPAction(authState),
//           onResendOtp: _handleResendOtp,
//           onSwitchMode: _switchMode,
//           isSubmitting: _isSubmitting,
//         );
//       case AuthMode.emailPassword:
//         return EmailPasswordScreen(
//           controller: _emailLoginController,
//           authState: authState,
//           onLogin: _handleEmailPasswordLogin,
//           onSwitchMode: _switchMode,
//           onTogglePassword: () {
//             setState(() {
//               _emailLoginController.togglePasswordVisibility();
//             });
//           },
//         );
//       case AuthMode.signUp:
//         return SignupScreen(
//           controller: _signupController,
//           authState: authState,
//           onSignup: _handleSignup,
//           onSwitchMode: _switchMode,
//           onTogglePassword: () {
//             setState(() {
//               _signupController.togglePasswordVisibility();
//             });
//           },
//           onToggleConfirmPassword: () {
//             setState(() {
//               _signupController.toggleConfirmPasswordVisibility();
//             });
//           },
//         );
//       case AuthMode.forgotPassword:
//         return ForgotPasswordScreen(
//           controller: _forgotPasswordController,
//           authState: authState,
//           onAction: () => _handleForgotPasswordAction(authState),
//           isSubmitting: _isSubmitting,
//         );
//       case AuthMode.resetPassword:
//         return ResetPasswordScreen(
//           controller: _resetPasswordController,
//           onReset: _handleResetPassword,
//           onSwitchMode: _switchMode,
//           onTogglePassword: () {
//             setState(() {
//               _resetPasswordController.togglePasswordVisibility();
//             });
//           },
//           onToggleConfirmPassword: () {
//             setState(() {
//               _resetPasswordController.toggleConfirmPasswordVisibility();
//             });
//           },
//           isSubmitting: _isSubmitting,
//         );
//     }
//   }

//   // Action handlers
//   void _handleMobileOTPAction(AuthState state) {
//     MobileOtpHandler.handleAction(
//       context: context,
//       ref: ref,
//       controller: _mobileOtpController,
//       state: state,
//       isSubmitting: _isSubmitting,
//       setSubmitting: (value) => setState(() => _isSubmitting = value),
//     );
//   }

//   void _handleEmailPasswordLogin() {
//     EmailLoginHandler.handleLogin(
//       context: context,
//       ref: ref,
//       controller: _emailLoginController,
//       formKey: _formKey,
//     );
//   }

//   void _handleSignup() {
//     SignupHandler.handleSignup(
//       context: context,
//       ref: ref,
//       controller: _signupController,
//       formKey: _formKey,
//     );
//   }

//   void _handleResendOtp() {
//     MobileOtpHandler.handleResendOtp(
//       context: context,
//       ref: ref,
//       controller: _mobileOtpController,
//     );
//   }

//   void _handleForgotPasswordAction(AuthState state) {
//     ForgotPasswordHandler.handleAction(
//       context: context,
//       ref: ref,
//       controller: _forgotPasswordController,
//       state: state,
//       isSubmitting: _isSubmitting,
//       setSubmitting: (value) => setState(() => _isSubmitting = value),
//       switchMode: _switchMode,
//     );
//   }

//   void _handleResetPassword() {
//     ResetPasswordHandler.handleReset(
//       context: context,
//       ref: ref,
//       controller: _resetPasswordController,
//       formKey: _formKey,
//       isSubmitting: _isSubmitting,
//       setSubmitting: (value) => setState(() => _isSubmitting = value),
//     );
//   }

//   void _handleAuthStateChange(AuthState state) {
//     AuthStateHandler.handleAuthStateChange(
//       context: context,
//       state: state,
//       currentMode: _currentMode,
//       mobileOtpController: _currentMode == AuthMode.mobileOTP ? _mobileOtpController : null,
//       emailLoginController: _currentMode == AuthMode.emailPassword ? _emailLoginController : null,
//       forgotPasswordController: _currentMode == AuthMode.forgotPassword ? _forgotPasswordController : null,
//       setSubmitting: (value) => setState(() => _isSubmitting = value),
//       setError: (hasError, {String? otpError, String? mobileError, String? loginError, String? forgotOtpError}) {
//         setState(() {
//           if (otpError != null && _mobileOtpController.hasOtpError != hasError) {
//             _mobileOtpController.setOtpError(otpError);
//           }
//           if (mobileError != null && _mobileOtpController.hasMobileError != hasError) {
//             _mobileOtpController.setMobileError(mobileError);
//           }
//           if (loginError != null && _emailLoginController.hasLoginError != hasError) {
//             _emailLoginController.setLoginError(loginError);
//           }
//           if (forgotOtpError != null && _forgotPasswordController.hasOtpError != hasError) {
//             _forgotPasswordController.setOtpError(forgotOtpError);
//           }
//         });
//       },
//     );
//   }
// }

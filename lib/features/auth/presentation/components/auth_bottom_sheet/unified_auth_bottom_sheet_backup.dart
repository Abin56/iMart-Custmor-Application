// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../../app/router/app_router.dart';
// import '../../../../../app/theme/app_spacing.dart';
// import '../../../../../app/theme/colors.dart';
// import '../../../../../core/error/failure.dart';
// import '../../../../../core/widgets/app_button.dart';
// import '../../../../../core/widgets/app_snackbar.dart';
// import '../../../../../core/widgets/app_text.dart';
// import '../../../application/providers/auth_provider.dart';
// import '../../../application/providers/auth_repository_provider.dart';
// import '../../../application/states/auth_state.dart';
// import '../../../infrastructure/data_sources/remote/auth_api.dart';
// import '../otp_input_field.dart';

// enum AuthMode { mobileOTP, emailPassword, signUp, forgotPassword, resetPassword }

// class UnifiedAuthBottomSheet extends ConsumerStatefulWidget {
//   const UnifiedAuthBottomSheet({super.key});

//   @override
//   ConsumerState<UnifiedAuthBottomSheet> createState() =>
//       _UnifiedAuthBottomSheetState();
// }

// class _UnifiedAuthBottomSheetState
//     extends ConsumerState<UnifiedAuthBottomSheet> {
//   AuthMode _currentMode = AuthMode.mobileOTP;

//   // Controllers for mobile OTP
//   final mobileController = TextEditingController();
//   final List<TextEditingController> _otpControllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
//   bool showOtpField = false;
//   bool _hasOtpError = false;
//   String _otpErrorMessage = '';
//   bool _hasMobileError = false;
//   String _mobileErrorMessage = '';

//   // Controllers for email/password login
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _hasLoginError = false;
//   String _loginErrorMessage = '';

//   // Controllers for signup
//   final signupEmailController = TextEditingController();
//   final signupPhoneController = TextEditingController();
//   final signupPasswordController = TextEditingController();
//   final signupConfirmPasswordController = TextEditingController();
//   bool _obscureSignupPassword = true;
//   bool _obscureSignupConfirmPassword = true;

//   // Controllers for forgot password
//   final forgotPasswordMobileController = TextEditingController();
//   final List<TextEditingController> _forgotOtpControllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _forgotOtpFocusNodes = List.generate(6, (_) => FocusNode());
//   bool showForgotOtpField = false;
//   bool _hasForgotOtpError = false;
//   String _forgotOtpErrorMessage = '';

//   // Controllers for reset password
//   final resetPasswordController = TextEditingController();
//   final resetConfirmPasswordController = TextEditingController();
//   bool _obscureResetPassword = true;
//   bool _obscureResetConfirmPassword = true;
//   String _verifiedMobileNumber = '';
//   String _verifiedOtp = '';

//   final _formKey = GlobalKey<FormState>();
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     for (var controller in _otpControllers) {
//       controller.addListener(_onOtpChanged);
//     }
//     for (var controller in _forgotOtpControllers) {
//       controller.addListener(_onForgotOtpChanged);
//     }
//     // Clear login error when user types
//     emailController.addListener(_onLoginFieldChanged);
//     passwordController.addListener(_onLoginFieldChanged);
//     // Clear mobile error when user types
//     mobileController.addListener(_onMobileFieldChanged);
//   }

//   @override
//   void dispose() {
//     mobileController.removeListener(_onMobileFieldChanged);
//     mobileController.dispose();
//     for (var controller in _otpControllers) {
//       controller.removeListener(_onOtpChanged);
//       controller.dispose();
//     }
//     for (var node in _otpFocusNodes) {
//       node.dispose();
//     }
//     emailController.removeListener(_onLoginFieldChanged);
//     emailController.dispose();
//     passwordController.removeListener(_onLoginFieldChanged);
//     passwordController.dispose();
//     signupEmailController.dispose();
//     signupPhoneController.dispose();
//     signupPasswordController.dispose();
//     signupConfirmPasswordController.dispose();
//     forgotPasswordMobileController.dispose();
//     for (var controller in _forgotOtpControllers) {
//       controller.removeListener(_onForgotOtpChanged);
//       controller.dispose();
//     }
//     for (var node in _forgotOtpFocusNodes) {
//       node.dispose();
//     }
//     resetPasswordController.dispose();
//     resetConfirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _onOtpChanged() {
//     if (_hasOtpError) {
//       setState(() {
//         _hasOtpError = false;
//         _otpErrorMessage = '';
//       });
//     }
//     setState(() {});
//   }

//   void _onForgotOtpChanged() {
//     if (_hasForgotOtpError) {
//       setState(() {
//         _hasForgotOtpError = false;
//         _forgotOtpErrorMessage = '';
//       });
//     }
//     setState(() {});
//   }

//   void _onLoginFieldChanged() {
//     if (_hasLoginError) {
//       setState(() {
//         _hasLoginError = false;
//         _loginErrorMessage = '';
//       });
//     }
//   }

//   void _onMobileFieldChanged() {
//     if (_hasMobileError) {
//       setState(() {
//         _hasMobileError = false;
//         _mobileErrorMessage = '';
//       });
//     }
//   }

//   String get _completeOtp => _otpControllers.map((c) => c.text).join();

//   bool get _isOtpComplete =>
//       _completeOtp.length == 6 && RegExp(r'^\d{6}$').hasMatch(_completeOtp);

//   String get _completeForgotOtp => _forgotOtpControllers.map((c) => c.text).join();

//   bool get _isForgotOtpComplete =>
//       _completeForgotOtp.length == 6 && RegExp(r'^\d{6}$').hasMatch(_completeForgotOtp);

//   String get _maskedPhoneNumber {
//     final number = mobileController.text.trim();
//     if (number.length < 4) return number;
//     final visibleDigits = number.substring(number.length - 4);
//     return '******$visibleDigits';
//   }

//   String get _maskedForgotPhoneNumber {
//     final number = forgotPasswordMobileController.text.trim();
//     if (number.length < 4) return number;
//     final visibleDigits = number.substring(number.length - 4);
//     return '******$visibleDigits';
//   }

//   void _switchMode(AuthMode mode) {
//     setState(() {
//       _currentMode = mode;
//       showOtpField = false;
//       _hasOtpError = false;
//       _otpErrorMessage = '';
//       _hasMobileError = false;
//       _mobileErrorMessage = '';
//       showForgotOtpField = false;
//       _hasForgotOtpError = false;
//       _forgotOtpErrorMessage = '';
//       _hasLoginError = false;
//       _loginErrorMessage = '';
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
//                 // Build content based on current mode
//                 if (_currentMode == AuthMode.mobileOTP) _buildMobileOTPMode(authState),
//                 if (_currentMode == AuthMode.emailPassword) _buildEmailPasswordMode(authState),
//                 if (_currentMode == AuthMode.signUp) _buildSignUpMode(authState),
//                 if (_currentMode == AuthMode.forgotPassword) _buildForgotPasswordMode(authState),
//                 if (_currentMode == AuthMode.resetPassword) _buildResetPasswordMode(authState),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Mobile OTP Mode UI
//   Widget _buildMobileOTPMode(AuthState authState) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         AppText(
//           text: 'Welcome',
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.black,
//         ),
//         AppSpacing.h24,
//         AppText(
//           text: 'Mobile Number',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildMobileField(),
//         if (_hasMobileError && !showOtpField) ...[
//           AppSpacing.h16,
//           _buildErrorMessage(_mobileErrorMessage),
//         ],

//         if (showOtpField) ...[
//           AppSpacing.h24,
//           _buildOtpInstructions(),
//           AppSpacing.h16,
//           _buildOtpInputFields(),
//           if (_hasOtpError) ...[
//             AppSpacing.h8,
//             _buildOtpErrorMessage(),
//           ],
//           AppSpacing.h16,
//           _buildResendOption(authState),
//         ],

//         AppSpacing.h32,
//         _buildMainButton(authState),
//         AppSpacing.h16,

//         AppButton(
//           text: 'Sign in with password',
//           onPressed: () => _switchMode(AuthMode.emailPassword),
//           backgroundColor: AppColors.lightGreen,
//           textColor: AppColors.titleColor,
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w600,
//           borderRadius: 30.r,
//           height: 52.h,
//         ),

//         AppSpacing.h16,
//         Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AppText(
//                 text: "Don't have an account? ",
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.darkGrey,
//               ),
//               GestureDetector(
//                 onTap: () => _switchMode(AuthMode.signUp),
//                 child: AppText(
//                   text: 'Sign Up',
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.buttonGreen,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         AppSpacing.h16,
//       ],
//     );
//   }

//   // Email/Password Login Mode UI
//   Widget _buildEmailPasswordMode(AuthState authState) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         AppText(
//           text: 'Welcome',
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.black,
//         ),
//         AppSpacing.h24,
//         AppText(
//           text: 'Email/Username',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildEmailField(),
//         AppSpacing.h16,
//         AppText(
//           text: 'Password',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildPasswordField(),
//         AppSpacing.h8,
//         Align(
//           alignment: Alignment.centerRight,
//           child: GestureDetector(
//             onTap: () => _switchMode(AuthMode.forgotPassword),
//             child: AppText(
//               text: 'Forgot Password? Reset',
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w400,
//               color: AppColors.grey,
//             ),
//           ),
//         ),
//         if (_hasLoginError) ...[
//           AppSpacing.h16,
//           _buildErrorMessage(_loginErrorMessage),
//         ],
//         AppSpacing.h16,
//         Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AppText(
//                 text: "Don't have an account? ",
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.darkGrey,
//               ),
//               GestureDetector(
//                 onTap: () => _switchMode(AuthMode.signUp),
//                 child: AppText(
//                   text: 'Sign Up',
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.buttonGreen,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         AppSpacing.h24,
//         _buildLoginButton(authState),
//         AppSpacing.h16,
//       ],
//     );
//   }

//   // Sign Up Mode UI
//   Widget _buildSignUpMode(AuthState authState) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         AppText(
//           text: 'Sign Up',
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.black,
//         ),
//         AppSpacing.h24,
//         AppText(
//           text: 'Email/Username',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildSignupEmailField(),
//         AppSpacing.h16,
//         AppText(
//           text: 'Phone number',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildSignupPhoneField(),
//         AppSpacing.h16,
//         AppText(
//           text: 'Set Password',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildSignupPasswordField(),
//         AppSpacing.h16,
//         AppText(
//           text: 'Confirm Password',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildSignupConfirmPasswordField(),
//         AppSpacing.h16,
//         Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AppText(
//                 text: 'Already have an account? ',
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.darkGrey,
//               ),
//               GestureDetector(
//                 onTap: () => _switchMode(AuthMode.emailPassword),
//                 child: AppText(
//                   text: 'Login',
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.buttonGreen,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         AppSpacing.h24,
//         _buildSignupButton(authState),
//         AppSpacing.h16,
//       ],
//     );
//   }

//   // Forgot Password Mode UI
//   Widget _buildForgotPasswordMode(AuthState authState) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         AppText(
//           text: 'Forgot password?',
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.black,
//         ),
//         AppSpacing.h24,
//         AppText(
//           text: 'Mobile Number',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildForgotPasswordMobileField(),

//         if (showForgotOtpField) ...[
//           AppSpacing.h24,
//           _buildForgotOtpInstructions(),
//           AppSpacing.h16,
//           _buildForgotOtpInputFields(),
//           if (_hasForgotOtpError) ...[
//             AppSpacing.h8,
//             _buildForgotOtpErrorMessage(),
//           ],
//         ],

//         AppSpacing.h32,
//         _buildForgotPasswordButton(authState),
//         AppSpacing.h16,
//       ],
//     );
//   }

//   // Reset Password Mode UI
//   Widget _buildResetPasswordMode(AuthState authState) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         AppText(
//           text: 'Reset Password',
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.black,
//         ),
//         AppSpacing.h24,
//         AppText(
//           text: 'Set Password',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildResetPasswordField(),
//         AppSpacing.h16,
//         AppText(
//           text: 'Confirm Password',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.black,
//         ),
//         AppSpacing.h8,
//         _buildResetConfirmPasswordField(),
//         AppSpacing.h16,
//         Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AppText(
//                 text: 'Already have an account? ',
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.darkGrey,
//               ),
//               GestureDetector(
//                 onTap: () => _switchMode(AuthMode.emailPassword),
//                 child: AppText(
//                   text: 'Login',
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.buttonGreen,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         AppSpacing.h24,
//         _buildResetPasswordSubmitButton(authState),
//         AppSpacing.h16,
//       ],
//     );
//   }

//   // Build input fields
//   Widget _buildMobileField() {
//     return TextFormField(
//       controller: mobileController,
//       cursorColor: AppColors.grey,
//       enabled: !showOtpField,
//       keyboardType: TextInputType.phone,
//       maxLength: 10,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'Enter your number',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w200),
//         counterText: '',
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: showOtpField ? AppColors.field : AppColors.white,
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Phone number is required';
//         if (!RegExp(r'^\d{10}$').hasMatch(value!)) return 'Enter valid 10-digit phone number';
//         return null;
//       },
//     );
//   }

//   Widget _buildEmailField() {
//     return TextFormField(
//       controller: emailController,
//       cursorColor: AppColors.grey,
//       keyboardType: TextInputType.emailAddress,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'you@example.com',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w400),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: AppColors.white,
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Email is required';
//         return null;
//       },
//     );
//   }

//   Widget _buildPasswordField() {
//     return TextFormField(
//       controller: passwordController,
//       cursorColor: AppColors.grey,
//       obscureText: _obscurePassword,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: '••••••••',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w400),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: AppColors.white,
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//             color: AppColors.grey,
//             size: 20.sp,
//           ),
//           onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Password is required';
//         return null;
//       },
//     );
//   }

//   Widget _buildSignupEmailField() {
//     return TextFormField(
//       controller: signupEmailController,
//       cursorColor: AppColors.grey,
//       keyboardType: TextInputType.emailAddress,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'you@example.com',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w400),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: AppColors.white,
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Email is required';
//         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
//           return 'Enter a valid email';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildSignupPhoneField() {
//     return TextFormField(
//       controller: signupPhoneController,
//       cursorColor: AppColors.grey,
//       keyboardType: TextInputType.phone,
//       maxLength: 10,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w200, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'Enter you number',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w200),
//         counterText: '',
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: AppColors.white,
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Phone number is required';
//         if (!RegExp(r'^\d{10}$').hasMatch(value!)) return 'Enter valid 10-digit phone number';
//         return null;
//       },
//     );
//   }

//   Widget _buildSignupPasswordField() {
//     return TextFormField(
//       controller: signupPasswordController,
//       cursorColor: AppColors.grey,
//       obscureText: _obscureSignupPassword,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'Must be 8 Characters',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w400),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: AppColors.white,
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscureSignupPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//             color: AppColors.grey,
//             size: 20.sp,
//           ),
//           onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Password is required';
//         if (value!.length < 8) return 'Password must be at least 8 characters';
//         return null;
//       },
//     );
//   }

//   Widget _buildSignupConfirmPasswordField() {
//     return TextFormField(
//       controller: signupConfirmPasswordController,
//       cursorColor: AppColors.grey,
//       obscureText: _obscureSignupConfirmPassword,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'Re-frame password',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w400),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: AppColors.white,
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscureSignupConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//             color: AppColors.grey,
//             size: 20.sp,
//           ),
//           onPressed: () => setState(() => _obscureSignupConfirmPassword = !_obscureSignupConfirmPassword),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Please confirm your password';
//         if (value != signupPasswordController.text) return 'Passwords do not match';
//         return null;
//       },
//     );
//   }

//   // Forgot Password input fields
//   Widget _buildForgotPasswordMobileField() {
//     return TextFormField(
//       controller: forgotPasswordMobileController,
//       cursorColor: AppColors.grey,
//       enabled: !showForgotOtpField,
//       keyboardType: TextInputType.phone,
//       maxLength: 10,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'Enter 10 digit number',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w200),
//         counterText: '',
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: showForgotOtpField ? AppColors.field : AppColors.white,
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Phone number is required';
//         if (!RegExp(r'^\d{10}$').hasMatch(value!)) return 'Enter valid 10-digit phone number';
//         return null;
//       },
//     );
//   }

//   Widget _buildResetPasswordField() {
//     return TextFormField(
//       controller: resetPasswordController,
//       cursorColor: AppColors.grey,
//       obscureText: _obscureResetPassword,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'Must be 8 Characters',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w400),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: AppColors.white,
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscureResetPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//             color: AppColors.grey,
//             size: 20.sp,
//           ),
//           onPressed: () => setState(() => _obscureResetPassword = !_obscureResetPassword),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Password is required';
//         if (value!.length < 8) return 'Password must be at least 8 characters';
//         return null;
//       },
//     );
//   }

//   Widget _buildResetConfirmPasswordField() {
//     return TextFormField(
//       controller: resetConfirmPasswordController,
//       cursorColor: AppColors.grey,
//       obscureText: _obscureResetConfirmPassword,
//       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.black),
//       decoration: InputDecoration(
//         hintText: 'Re-frame password',
//         hintStyle: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w400),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         filled: true,
//         fillColor: AppColors.white,
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscureResetConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//             color: AppColors.grey,
//             size: 20.sp,
//           ),
//           onPressed: () => setState(() => _obscureResetConfirmPassword = !_obscureResetConfirmPassword),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: AppColors.buttonGreen, width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Please confirm your password';
//         if (value != resetPasswordController.text) return 'Passwords do not match';
//         return null;
//       },
//     );
//   }

//   // OTP related widgets
//   Widget _buildOtpInstructions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AppText(
//           text: 'Enter OTP',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.darkGrey,
//         ),
//         AppSpacing.h4,
//         AppText(
//           text: 'Enter the 6-digit OTP sent to +91 $_maskedPhoneNumber',
//           fontSize: 13.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.grey,
//           maxLines: 2,
//         ),
//       ],
//     );
//   }

//   Widget _buildOtpInputFields() {
//     return OtpInputField(
//       controllers: _otpControllers,
//       focusNodes: _otpFocusNodes,
//       hasError: _hasOtpError,
//       onChanged: () {
//         if (_hasOtpError) {
//           setState(() {
//             _hasOtpError = false;
//             _otpErrorMessage = '';
//           });
//         }
//       },
//       onCompleted: () {
//         // Optional: Auto-submit when OTP is complete
//         // You can trigger verification here if desired
//       },
//     );
//   }

//   Widget _buildOtpErrorMessage() {
//     return Row(
//       children: [
//         Icon(Icons.error_outline, size: 16.sp, color: AppColors.red),
//         AppSpacing.w8,
//         Expanded(
//           child: AppText(
//             text: _otpErrorMessage,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w400,
//             color: AppColors.red,
//             maxLines: 2,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorMessage(String message) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//       decoration: BoxDecoration(
//         color: AppColors.red.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(8.r),
//         border: Border.all(color: AppColors.red.withValues(alpha: 0.3), width: 1),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, size: 18.sp, color: AppColors.red),
//           AppSpacing.w8,
//           Expanded(
//             child: AppText(
//               text: message,
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w400,
//               color: AppColors.red,
//               maxLines: 3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResendOption(AuthState authState) {
//     final isResending = authState is OtpSending;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         AppText(
//           text: "Didn't receive the OTP? ",
//           fontSize: 13.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.grey,
//         ),
//         GestureDetector(
//           onTap: isResending ? null : _handleResendOtp,
//           child: AppText(
//             text: isResending ? 'Sending...' : 'Resend OTP',
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w600,
//             color: isResending ? AppColors.grey : AppColors.buttonGreen,
//           ),
//         ),
//       ],
//     );
//   }

//   // Forgot Password OTP widgets
//   Widget _buildForgotOtpInstructions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AppText(
//           text: 'Enter OTP',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.darkGrey,
//         ),
//         AppSpacing.h4,
//         AppText(
//           text: 'Enter the 6-digit OTP sent to +91 $_maskedForgotPhoneNumber',
//           fontSize: 13.sp,
//           fontWeight: FontWeight.w400,
//           color: AppColors.grey,
//           maxLines: 2,
//         ),
//       ],
//     );
//   }

//   Widget _buildForgotOtpInputFields() {
//     return OtpInputField(
//       controllers: _forgotOtpControllers,
//       focusNodes: _forgotOtpFocusNodes,
//       hasError: _hasForgotOtpError,
//       onChanged: () {
//         if (_hasForgotOtpError) {
//           setState(() {
//             _hasForgotOtpError = false;
//             _forgotOtpErrorMessage = '';
//           });
//         }
//       },
//       onCompleted: () {
//         // Optional: Auto-submit when OTP is complete
//       },
//     );
//   }

//   Widget _buildForgotOtpErrorMessage() {
//     return Row(
//       children: [
//         Icon(Icons.error_outline, size: 16.sp, color: AppColors.red),
//         AppSpacing.w8,
//         Expanded(
//           child: AppText(
//             text: _forgotOtpErrorMessage,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w400,
//             color: AppColors.red,
//             maxLines: 2,
//           ),
//         ),
//       ],
//     );
//   }

//   // Buttons
//   Widget _buildMainButton(AuthState authState) {
//     final isProcessing = authState is OtpSending || authState is OtpVerifying;
//     String buttonText = 'Get OTP';
//     if (authState is OtpSending) buttonText = 'Sending OTP...';
//     if (authState is OtpVerifying) buttonText = 'Verifying...';
//     if (showOtpField) buttonText = 'Verify OTP';

//     bool isEnabled = false;
//     if (!isProcessing && !_isSubmitting) {
//       if (showOtpField) {
//         isEnabled = _isOtpComplete;
//       } else {
//         final phone = mobileController.text.trim();
//         isEnabled = phone.length == 10 && RegExp(r'^\d{10}$').hasMatch(phone);
//       }
//     }

//     return AppButton(
//       text: buttonText,
//       onPressed: isEnabled ? () => _handleMobileOTPAction(authState) : null,
//       isLoading: isProcessing || _isSubmitting,
//       backgroundColor: isEnabled ? AppColors.buttonGreen : AppColors.buttonGreen.withValues(alpha: 0.5),
//       textColor: AppColors.white,
//       fontSize: 16.sp,
//       fontWeight: FontWeight.w600,
//       borderRadius: 30.r,
//       height: 52.h,
//     );
//   }

//   Widget _buildLoginButton(AuthState authState) {
//     final isLoading = authState is AuthLoading;
//     return AppButton(
//       text: isLoading ? 'Logging in...' : 'Login',
//       onPressed: !isLoading ? _handleEmailPasswordLogin : null,
//       isLoading: isLoading,
//       backgroundColor: AppColors.buttonGreen,
//       textColor: AppColors.white,
//       fontSize: 16.sp,
//       fontWeight: FontWeight.w600,
//       borderRadius: 30.r,
//       height: 52.h,
//     );
//   }

//   Widget _buildSignupButton(AuthState authState) {
//     final isLoading = authState is AuthLoading;
//     return AppButton(
//       text: isLoading ? 'Signing up...' : 'Sign up',
//       onPressed: !isLoading ? _handleSignup : null,
//       isLoading: isLoading,
//       backgroundColor: AppColors.buttonGreen,
//       textColor: AppColors.white,
//       fontSize: 16.sp,
//       fontWeight: FontWeight.w600,
//       borderRadius: 30.r,
//       height: 52.h,
//     );
//   }

//   Widget _buildForgotPasswordButton(AuthState authState) {
//     final isProcessing = authState is OtpSending || authState is OtpVerifying;
//     String buttonText = 'Get OTP';
//     if (authState is OtpSending) buttonText = 'Sending OTP...';
//     if (authState is OtpVerifying) buttonText = 'Verifying...';
//     if (showForgotOtpField) buttonText = 'Verify OTP';

//     bool isEnabled = false;
//     if (!isProcessing && !_isSubmitting) {
//       if (showForgotOtpField) {
//         isEnabled = _isForgotOtpComplete;
//       } else {
//         final phone = forgotPasswordMobileController.text.trim();
//         isEnabled = phone.length == 10 && RegExp(r'^\d{10}$').hasMatch(phone);
//       }
//     }

//     return AppButton(
//       text: buttonText,
//       onPressed: isEnabled ? () => _handleForgotPasswordAction(authState) : null,
//       isLoading: isProcessing || _isSubmitting,
//       backgroundColor: isEnabled ? AppColors.buttonGreen : AppColors.buttonGreen.withValues(alpha: 0.5),
//       textColor: AppColors.white,
//       fontSize: 16.sp,
//       fontWeight: FontWeight.w600,
//       borderRadius: 30.r,
//       height: 52.h,
//     );
//   }

//   Widget _buildResetPasswordSubmitButton(AuthState authState) {
//     final isLoading = _isSubmitting;
//     return AppButton(
//       text: isLoading ? 'Resetting...' : 'Sign up',
//       onPressed: !isLoading ? _handleResetPassword : null,
//       isLoading: isLoading,
//       backgroundColor: AppColors.buttonGreen,
//       textColor: AppColors.white,
//       fontSize: 16.sp,
//       fontWeight: FontWeight.w600,
//       borderRadius: 30.r,
//       height: 52.h,
//     );
//   }

//   // Action handlers
//   void _handleMobileOTPAction(AuthState state) {
//     if (_isSubmitting || state is OtpSending || state is OtpVerifying) return;

//     final mobile = mobileController.text.trim();
//     if (mobile.isEmpty || mobile.length != 10) {
//       AppSnackbar.error(context, 'Please enter a valid 10-digit mobile number');
//       return;
//     }

//     if (!showOtpField) {
//       setState(() => _isSubmitting = true);
//       ref.read(authProvider.notifier).sendOtp('+91$mobile');
//     } else {
//       final otp = _completeOtp;
//       if (otp.length != 6) {
//         setState(() {
//           _hasOtpError = true;
//           _otpErrorMessage = 'Please enter all 6 digits';
//         });
//         return;
//       }
//       setState(() => _isSubmitting = true);
//       ref.read(authProvider.notifier).verifyOtp('+91$mobile', otp);
//     }
//   }

//   void _handleEmailPasswordLogin() {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();
//     if (email.isEmpty || password.isEmpty) {
//       AppSnackbar.error(context, 'Please fill all fields');
//       return;
//     }
//     ref.read(authProvider.notifier).login(email: email, password: password);
//   }

//   void _handleSignup() {
//     if (!(_formKey.currentState?.validate() ?? false)) return;

//     final emailOrUsername = signupEmailController.text.trim();
//     final phone = signupPhoneController.text.trim();
//     final password = signupPasswordController.text.trim();
//     final confirmPassword = signupConfirmPasswordController.text.trim();

//     if (emailOrUsername.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
//       AppSnackbar.error(context, 'Please fill all fields');
//       return;
//     }

//     if (password != confirmPassword) {
//       AppSnackbar.error(context, 'Passwords do not match');
//       return;
//     }

//     if (password.length < 8) {
//       AppSnackbar.error(context, 'Password must be at least 8 characters');
//       return;
//     }

//     if (phone.length != 10) {
//       AppSnackbar.error(context, 'Phone number must be 10 digits');
//       return;
//     }

//     // Determine if input is email or username
//     final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailOrUsername);
//     final email = isEmail ? emailOrUsername : '$emailOrUsername@temp.com';
//     final username = isEmail ? emailOrUsername.split('@')[0] : emailOrUsername;
//     final phoneWithCountryCode = '+91$phone';

//     // Call signup with available data, using empty strings for missing fields
//     ref.read(authProvider.notifier).signup(
//       username: username,
//       email: email,
//       firstName: '',
//       lastName: '',
//       phoneNumber: phoneWithCountryCode,
//       password: password,
//       confirmPassword: confirmPassword,
//     );
//   }

//   void _handleResendOtp() {
//     final mobile = mobileController.text.trim();
//     if (mobile.isEmpty || mobile.length != 10) {
//       AppSnackbar.error(context, 'Invalid mobile number');
//       return;
//     }
//     for (var controller in _otpControllers) {
//       controller.clear();
//     }
//     setState(() {
//       _hasOtpError = false;
//       _otpErrorMessage = '';
//     });
//     ref.read(authProvider.notifier).sendOtp('+91$mobile');
//   }

//   void _handleForgotPasswordAction(AuthState state) async {
//     if (_isSubmitting || state is OtpSending || state is OtpVerifying) return;

//     final mobile = forgotPasswordMobileController.text.trim();
//     if (mobile.isEmpty || mobile.length != 10) {
//       AppSnackbar.error(context, 'Please enter a valid 10-digit mobile number');
//       return;
//     }

//     if (!showForgotOtpField) {
//       // Send OTP for forgot password
//       setState(() => _isSubmitting = true);
//       try {
//         final authApi = ref.read(authApiProvider);
//         final phoneWithCountryCode = '+91$mobile';
//         final message = await authApi.sendOtp(phoneNumber: phoneWithCountryCode);

//         if (!mounted) return;

//         setState(() => _isSubmitting = false);

//         if (message == 'OTP sent successfully') {
//           setState(() {
//             showForgotOtpField = true;
//             _verifiedMobileNumber = phoneWithCountryCode;
//           });
//           for (var controller in _forgotOtpControllers) {
//             controller.clear();
//           }
//           Future.delayed(const Duration(milliseconds: 100), () {
//             if (mounted) _forgotOtpFocusNodes[0].requestFocus();
//           });
//           AppSnackbar.success(context, 'OTP sent successfully');
//         } else {
//           AppSnackbar.error(context, message);
//         }
//       } catch (e) {
//         if (!mounted) return;
//         setState(() => _isSubmitting = false);
//         AppSnackbar.error(context, e.toString());
//       }
//     } else {
//       // Verify OTP and move to reset password
//       final otp = _completeForgotOtp;
//       if (otp.length != 6) {
//         setState(() {
//           _hasForgotOtpError = true;
//           _forgotOtpErrorMessage = 'Please enter all 6 digits';
//         });
//         return;
//       }

//       // Verify OTP with backend before moving to reset password
//       setState(() => _isSubmitting = true);
//       try {
//         final repo = ref.read(authRepositoryProvider);
//         final result = await repo.verifyOtpOnly(
//           phoneNumber: _verifiedMobileNumber,
//           otp: otp,
//         );

//         if (!mounted) return;

//         setState(() => _isSubmitting = false);

//         result.fold(
//           (failure) {
//             setState(() {
//               _hasForgotOtpError = true;
//               _forgotOtpErrorMessage = failure.message;
//             });
//           },
//           (message) {
//             // OTP verified successfully, session created
//             setState(() {
//               _verifiedOtp = otp;
//             });
//             _switchMode(AuthMode.resetPassword);
//           },
//         );
//       } catch (e) {
//         if (!mounted) return;
//         setState(() => _isSubmitting = false);
//         setState(() {
//           _hasForgotOtpError = true;
//           _forgotOtpErrorMessage = e.toString();
//         });
//       }
//     }
//   }

//   void _handleResetPassword() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;

//     final password = resetPasswordController.text.trim();
//     final confirmPassword = resetConfirmPasswordController.text.trim();

//     if (password.isEmpty || confirmPassword.isEmpty) {
//       AppSnackbar.error(context, 'Please fill all fields');
//       return;
//     }

//     if (password != confirmPassword) {
//       AppSnackbar.error(context, 'Passwords do not match');
//       return;
//     }

//     if (password.length < 8) {
//       AppSnackbar.error(context, 'Password must be at least 8 characters');
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       final repo = ref.read(authRepositoryProvider);
//       final result = await repo.resetPassword(newPassword: password);

//       if (!mounted) return;

//       setState(() => _isSubmitting = false);

//       result.fold(
//         (failure) => AppSnackbar.error(context, failure.message),
//         (message) {
//           AppSnackbar.success(context, 'Password reset successfully');
//           Navigator.pop(context); // Close bottom sheet
//           // goToLogin(context); // Navigate to login
//         },
//       );
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isSubmitting = false);
//       AppSnackbar.error(context, e.toString());
//     }
//   }

//   void _handleAuthStateChange(AuthState state) {
//     if (state is OtpSent) {
//       setState(() {
//         showOtpField = true;
//         _isSubmitting = false;
//       });
//       for (var controller in _otpControllers) {
//         controller.clear();
//       }
//       Future.delayed(const Duration(milliseconds: 100), () {
//         if (mounted) _otpFocusNodes[0].requestFocus();
//       });
//       AppSnackbar.success(context, 'OTP sent successfully');
//     }

//     if (state is Authenticated) {
//       setState(() => _isSubmitting = false);
//       Navigator.pop(context);

//       // Check if user has a name, if not show welcome screen
//       final user = state.user;
//       if (user.firstName.isEmpty || user.firstName == user.username) {
//         goToWelcomeName(context);
//       } else {
//         goToHome(context);
//       }
//     }

//     if (state is AuthError) {
//       setState(() => _isSubmitting = false);
//       final failure = state.failure;
//       final errorMessage = failure.message.toLowerCase();
//       final isOtpError = errorMessage.contains('otp') ||
//           errorMessage.contains('invalid') ||
//           errorMessage.contains('expired');

//       if (showOtpField && isOtpError) {
//         // Show OTP-specific error inline
//         setState(() {
//           _hasOtpError = true;
//           _otpErrorMessage = _getOtpErrorMessage(failure);
//         });
//       } else if (showForgotOtpField && isOtpError) {
//         // Show forgot password OTP error inline
//         setState(() {
//           _hasForgotOtpError = true;
//           _forgotOtpErrorMessage = _getOtpErrorMessage(failure);
//         });
//       } else if (_currentMode == AuthMode.mobileOTP && !showOtpField) {
//         // Show mobile number error inline before OTP field is shown
//         final friendlyMessage = _getUserFriendlyError(failure);
//         setState(() {
//           _hasMobileError = true;
//           _mobileErrorMessage = friendlyMessage;
//         });
//       } else if (_currentMode == AuthMode.emailPassword) {
//         // Show login error inline for email/password mode
//         final friendlyMessage = _getUserFriendlyError(failure);
//         setState(() {
//           _hasLoginError = true;
//           _loginErrorMessage = friendlyMessage;
//         });
//       } else {
//         // For other modes (signup, reset password), use snackbar
//         final friendlyMessage = _getUserFriendlyError(failure);
//         AppSnackbar.error(context, friendlyMessage);
//       }
//     }

//     if (state is OtpSending || state is OtpVerifying) {
//       setState(() => _isSubmitting = true);
//     }
//   }

//   String _getOtpErrorMessage(Failure failure) {
//     final message = failure.message.toLowerCase();
//     if (message.contains('expired')) return 'OTP has expired. Please request a new one.';
//     if (message.contains('invalid') || message.contains('incorrect')) {
//       return 'Invalid OTP. Please check and try again.';
//     }
//     if (message.contains('attempts') || message.contains('limit')) {
//       return 'Too many attempts. Please try again later.';
//     }
//     return failure.message;
//   }

//   String _getUserFriendlyError(Failure failure) {
//     final message = failure.message.toLowerCase();

//     // Connection errors
//     if (message.contains('connection refused') ||
//         message.contains('failed to connect') ||
//         message.contains('socketexception')) {
//       return 'Unable to connect to server. Please check your internet connection and try again.';
//     }

//     if (message.contains('timeout') || message.contains('timed out')) {
//       return 'Request timed out. Please check your internet connection and try again.';
//     }

//     if (message.contains('network') || message.contains('no internet')) {
//       return 'No internet connection. Please check your network settings.';
//     }

//     // Authentication errors
//     if (message.contains('invalid credentials') ||
//         message.contains('wrong password') ||
//         message.contains('incorrect password')) {
//       return 'Invalid email or password. Please try again.';
//     }

//     if (message.contains('user not found') ||
//         message.contains('account not found') ||
//         message.contains('does not exist')) {
//       return 'Account not found. Please check your email or sign up.';
//     }

//     if (message.contains('account locked') ||
//         message.contains('account disabled') ||
//         message.contains('account suspended')) {
//       return 'Your account has been locked. Please contact support.';
//     }

//     // Rate limiting errors
//     if (message.contains('too many requests') ||
//         message.contains('rate limit') ||
//         message.contains('try again later')) {
//       // Extract time if present (e.g., "30 minutes", "1 hour")
//       final timeMatch = RegExp(r'(\d+)\s*(minute|hour|min|hr)s?').firstMatch(message);
//       if (timeMatch != null) {
//         final time = timeMatch.group(1);
//         final unit = timeMatch.group(2);
//         return 'Too many attempts. Please try again after $time ${unit}s.';
//       }
//       return 'Too many attempts. Please try again after 30 minutes.';
//     }

//     if (message.contains('maximum attempts') ||
//         message.contains('limit reached') ||
//         message.contains('exceeded')) {
//       return 'Maximum login attempts reached. Please try again after 30 minutes.';
//     }

//     // Validation errors
//     if (message.contains('invalid email') || message.contains('email format')) {
//       return 'Please enter a valid email address.';
//     }

//     if (message.contains('invalid phone') || message.contains('phone format')) {
//       return 'Please enter a valid phone number.';
//     }

//     if (message.contains('password too short') ||
//         message.contains('password must be')) {
//       return 'Password must be at least 8 characters long.';
//     }

//     if (message.contains('passwords do not match')) {
//       return 'Passwords do not match. Please try again.';
//     }

//     // Account exists errors
//     if (message.contains('already exists') ||
//         message.contains('already registered') ||
//         message.contains('already taken')) {
//       return 'This email or phone number is already registered. Please login instead.';
//     }

//     // Server errors
//     if (message.contains('500') ||
//         message.contains('internal server error') ||
//         message.contains('server error')) {
//       return 'Something went wrong on our end. Please try again later.';
//     }

//     if (message.contains('503') ||
//         message.contains('service unavailable') ||
//         message.contains('maintenance')) {
//       return 'Service temporarily unavailable. Please try again later.';
//     }

//     // Default: return original message if no match
//     return failure.message;
//   }
// }

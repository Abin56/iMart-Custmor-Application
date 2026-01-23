import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/app/router/app_router.dart';
import 'package:imart/features/widgets/app_button.dart';
import 'package:imart/features/widgets/app_snackbar.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/colors.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/states/auth_state.dart';

class WelcomeNameScreen extends ConsumerStatefulWidget {
  const WelcomeNameScreen({super.key});

  @override
  ConsumerState<WelcomeNameScreen> createState() => _WelcomeNameScreenState();
}

class _WelcomeNameScreenState extends ConsumerState<WelcomeNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppSnackbar.error(context, 'Please enter your name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get phone number from authenticated user
      final authState = ref.read(authProvider);

      if (authState is Authenticated) {
        // phoneNumber variable is intentionally unused for now
        // var phoneNumber = authState.user.phoneNumber;
      }

      // If phone number is not available from auth, try profile
      // if (phoneNumber.isEmpty) {
      //   final currentProfile = ref.read(profileControllerProvider).profile;
      //   phoneNumber = currentProfile?.mobileNumber ?? '';
      // }

      // Update profile with the name
      // await ref.read(profileControllerProvider.notifier).updateProfile(
      //       fullName: name,
      //       phoneNumber: phoneNumber,
      //     );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Navigate to home
      goToHome(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackbar.error(context, 'Failed to update profile. Please try again.');
    }
  }

  void _handleSkip() {
    // Allow user to skip and go to home
    goToHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 32.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Decorative icon
                Center(
                  child: Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: const BoxDecoration(
                      color: AppColors.green10,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.waving_hand_rounded,
                      size: 60.sp,
                      color: AppColors.buttonGreen,
                    ),
                  ),
                ),

                AppSpacing.h32,

                // Welcome text
                Center(
                  child: AppText(
                    text: 'Welcome aboard!',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleColor,
                  ),
                ),

                AppSpacing.h16,

                Center(
                  child: AppText(
                    text:
                        "We're excited to have you here.\nLet's get to know you better!",
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),

                AppSpacing.h48,

                // Name field label
                AppText(
                  text: 'What should we call you?',
                  fontSize: 16.sp,
                  color: AppColors.titleColor,
                ),

                AppSpacing.h12,

                // Name input field
                TextFormField(
                  controller: _nameController,
                  cursorColor: AppColors.buttonGreen,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.buttonGreen,
                      size: 24.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    filled: true,
                    fillColor: _isLoading ? AppColors.field : AppColors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.buttonGreen,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.red,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    if (value!.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 40.h),

                // Continue button
                AppButton(
                  text: _isLoading ? 'Saving...' : 'Continue',
                  onPressed: _isLoading ? null : _handleContinue,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.buttonGreen,
                  textColor: AppColors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  borderRadius: 30.r,
                  height: 52.h,
                ),

                AppSpacing.h16,

                // Skip button
                Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleSkip,
                    child: AppText(
                      text: 'Skip for now',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                AppSpacing.h24,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

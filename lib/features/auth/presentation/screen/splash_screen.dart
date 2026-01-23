import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/app/router/app_router.dart';
import 'package:imart/features/widgets/app_button.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/colors.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/states/auth_state.dart';
import '../components/auth_bottom_sheet/unified_auth_bottom_sheet.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasNavigated = false;
  bool _minDurationComplete = false;
  bool _isSkipping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Minimum splash screen duration of 1 second for logged in users
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _minDurationComplete = true;
        });
        _navigateBasedOnAuthState();
      }
    });
  }

  void _navigateBasedOnAuthState() {
    if (_hasNavigated || !_minDurationComplete) return;

    final authState = ref.read(authProvider);

    if (authState is Authenticated) {
      _hasNavigated = true;

      // Check if user has a name, if not show welcome screen
      final user = authState.user;
      if (user.firstName.isEmpty || user.firstName == user.username) {
        goToWelcomeName(context);
      } else {
        goToHome(context);
      }
    } else if (authState is AuthChecking) {
      // wait for listener
    }
    // For GuestMode or logged out: Show "Get Started" button
  }

  void _onGetStartedPressed() {
    // Prevent multiple taps while bottom sheet is opening
    if (_isSkipping) return;

    // Show unified auth bottom sheet
    _showAuthBottomSheet();
  }

  void _showAuthBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UnifiedAuthBottomSheet(),
    );
  }

  void _onSkipPressed() {
    // Prevent multiple taps
    if (_isSkipping || _hasNavigated) return;

    setState(() {
      _isSkipping = true;
      _hasNavigated = true;
    });

    // Continue as guest
    ref.read(authProvider.notifier).continueAsGuest();
    goToHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState is Authenticated;
    final isChecking = authState is AuthChecking;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (!_hasNavigated && next is! AuthChecking && !_controller.isAnimating) {
        _navigateBasedOnAuthState();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/images/frame.png', fit: BoxFit.cover),
          ),

          // Main content
          Positioned.fill(
            child: Column(
              children: [
                // Top spacer
                const Spacer(flex: 2),

                // Centered logo
                Center(
                  child: Image.asset(
                    'assets/images/imartlogo.png',
                    height: 140,
                    width: 115,
                    fit: BoxFit.contain,
                  ),
                ),

                AppSpacing.h16,

                // "online grocery app" text
                Center(
                  child: AppText(
                    text: 'online grocery app',
                    fontSize: 24.sp,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Middle spacer
                const Spacer(flex: 2),

                // Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Center(
                    child: AppText(
                      text:
                          'Groceries at your doorstep—\nfresh, fast, and easy.',
                      maxLines: 2,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // "Get Started" button - only show if NOT logged in
                if (!isLoggedIn && !isChecking)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AppButton(
                      text: 'Get Started',
                      onPressed: _onGetStartedPressed,
                      backgroundColor: AppColors.buttonGreen,
                      textColor: AppColors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      borderRadius: 30.r,
                      height: 52.h,
                    ),
                  ),

                // Show loading indicator while checking auth
                if (isChecking)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      height: 52,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Skip button - only show if NOT logged in
                if (!isLoggedIn && !isChecking)
                  GestureDetector(
                    onTap: _onSkipPressed,
                    child: Center(
                      child: AppText(
                        text: 'Skip',
                        fontSize: 18.sp,
                        color: AppColors.titleColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                // Bottom spacer
                SizedBox(height: MediaQuery.of(context).padding.bottom + 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:imart/features/auth/application/providers/auth_provider.dart';
import 'package:imart/features/auth/application/states/auth_state.dart';
import 'package:imart/features/profile/application/providers/profile_provider.dart';
import 'package:imart/features/profile/application/states/profile_state.dart';
import 'package:imart/features/profile/presentation/components/delivery_address_screen.dart';
import 'package:imart/features/profile/presentation/components/edit_profile_screen.dart';
import 'package:imart/features/profile/presentation/components/my_orders_screen.dart';
import 'package:imart/features/widgets/app_text.dart';

/// Profile Drawer
/// Shows user profile information and menu options
class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check auth state
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is Authenticated;

    return Drawer(
      backgroundColor: const Color(0xFFE8F5E9), // Light green background
      width: 280.w, // Drawer width
      child: SafeArea(
        child: !isAuthenticated
            ? _buildLoginPrompt(context, ref)
            : Column(
                children: [
                  SizedBox(height: 20.h),

                  // Profile Header Card
                  _buildProfileHeader(ref),

                  SizedBox(height: 24.h),

                  // Menu Options
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context: context,
                          icon: Icons.edit_outlined,
                          label: 'Edit Profile',
                          onTap: () {
                            // Navigate to edit profile screen
                            Navigator.pop(context); // Close drawer first
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.shopping_bag_outlined,
                          label: 'My Orders',
                          onTap: () {
                            // Navigate to orders screen
                            Navigator.pop(context); // Close drawer first
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrdersScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.location_on_outlined,
                          label: 'Delivery Address',
                          onTap: () {
                            // Navigate to delivery address screen
                            Navigator.pop(context); // Close drawer first
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DeliveryAddressScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: () {
                            // Navigate to settings screen
                            Navigator.pop(context); // Close drawer first
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.logout,
                          label: 'Log Out',
                          iconColor: const Color(0xFFD32F2F),
                          onTap: () {
                            Navigator.pop(context); // Close drawer first
                            _showLogoutDialog(context, ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileHeader(WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    // Extract user data from state
    var userName = 'Guest User';
    var phoneNumber = '';
    var email = '';

    if (profileState is ProfileLoaded) {
      final user = profileState.user;
      userName = '${user.firstName} ${user.lastName}'.trim();
      if (userName.isEmpty) userName = user.username;
      phoneNumber = user.phoneNumber;
      email = user.email;
    } else if (profileState is ProfileUpdated) {
      final user = profileState.user;
      userName = '${user.firstName} ${user.lastName}'.trim();
      if (userName.isEmpty) userName = user.username;
      phoneNumber = user.phoneNumber;
      email = user.email;
    }

    return SizedBox(
      height: 200.h,
      child: Stack(
        children: [
          // Curved green background
          ClipPath(
            clipper: _ProfileHeaderClipper(),
            child: Container(
              height: 200.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D5C2E), // Dark green
                    Color(0xFF1B7A43), // Medium green
                  ],
                ),
              ),
            ),
          ),

          // Profile content on top of curved background
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profileState is ProfileLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : ColoredBox(
                            color: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40.sp,
                              color: const Color(0xFF0D5C2E),
                            ),
                          ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Profile Info
                Expanded(
                  child: profileState is ProfileLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Icon + Name
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 18.sp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: AppText(
                                    text: userName,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8.h),

                            // Phone Icon + Number
                            if (phoneNumber.isNotEmpty) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 16.sp,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      phoneNumber,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                            ],

                            // Email Icon + Address
                            if (email.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16.sp,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final color = iconColor ?? const Color(0xFF25A63E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with circular background
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22.sp, color: color),
            ),

            SizedBox(width: 16.w),

            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout,
                size: 30.sp,
                color: const Color(0xFFD32F2F),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(dialogContext),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    // Handle logout
                    Navigator.pop(dialogContext);

                    // Call auth provider to logout
                    await ref.read(authProvider.notifier).logout();

                    // Navigation will be handled by auth state listener in main app
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build login prompt for unauthenticated users
  Widget _buildLoginPrompt(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF25A63E).withValues(alpha: 0.2),
                    const Color(0xFF0D5C2E).withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 60.sp,
                color: const Color(0xFF0D5C2E),
              ),
            ),

            SizedBox(height: 32.h),

            // Title
            AppText(
              text: 'Not Logged In',
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D5C2E),
            ),

            SizedBox(height: 12.h),

            // Description
            Text(
              'Please login to access your profile, orders, and saved addresses',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            SizedBox(height: 40.h),

            // Login Button
            GestureDetector(
              onTap: () {
                // Close drawer
                Navigator.pop(context);

                // Navigate to splash screen (which handles navigation to login)
                context.go('/splash');
              },
              child: Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25A63E), Color(0xFF1B7A43)],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25A63E).withValues(alpha: 0.4),
                      blurRadius: 25.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, color: Colors.white, size: 24.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Continue as Guest
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Continue Browsing',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D5C2E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom clipper for curved bottom edge of profile header
class _ProfileHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start from top-left and draw the complete path
    path
      ..moveTo(0, 0)
      // Top edge
      ..lineTo(width, 0)
      // Right edge down to curve start
      ..lineTo(width, height - 40)
      // Smooth wave curve at bottom - quadratic bezier
      ..quadraticBezierTo(
        width / 2, // Control point X at center
        height + 30, // Control point Y - creates gentle downward curve
        0, // End point X at left side
        height - 40, // End point Y
      )
      // Left edge up
      ..lineTo(0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

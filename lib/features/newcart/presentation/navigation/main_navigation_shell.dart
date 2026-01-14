import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../components/widgets/product_card.dart';
import '../screen/category_screen.dart';
import '../screen/wishlist_screen.dart';
import '../screens/home_screen_content.dart';

/// Main navigation shell with glassmorphism bottom navigation bar
/// Connects: Home, Categories, Wishlist, Cart screens
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    //  const CategoryScreen(),
    const HomeScreenContent(),
    const CategoryScreen(),
  const WishlistScreen(),
    const _CartPlaceholder(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Trigger animations when navigating to Categories screen
    if (index == 1) {
      debugPrint('Navigation: Switching to Categories (index 1)');
      // Delay to ensure screen is visible and widgets are built
      Future.delayed(const Duration(milliseconds: 300), () {
        debugPrint('Navigation: Calling ProductCard.triggerAnimations()');
        ProductCard.triggerAnimations();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Current screen content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Glassmorphism bottom navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildGlassmorphismNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismNavBar() {
    return Container(
      height: 60.h,
      margin: EdgeInsets.fromLTRB(25.w, 0, 25.w, 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 35.r,
            spreadRadius: 0,
            offset: Offset(0, 12.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18.r,
            spreadRadius: 0,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Categories',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.favorite_border,
                  label: 'Wishlist',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isActive ? 52.w : 44.w,
            height: isActive ? 60.h : 44.h,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF25A63E) : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF25A63E).withValues(alpha: 0.35),
                        blurRadius: 15.r,
                        spreadRadius: 2,
                        offset: Offset(0, 5.h),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 30.sp,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder screen for Wishlist tab
class _WishlistPlaceholder extends StatelessWidget {
  const _WishlistPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 100.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Wishlist',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your favorite items will appear here',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder screen for Cart tab
class _CartPlaceholder extends StatelessWidget {
  const _CartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 100.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

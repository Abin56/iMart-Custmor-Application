import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/cart/presentation/screen/address_session_screen.dart';
import 'package:imart/features/cart/presentation/screen/cart_screen.dart';
import 'package:imart/features/cart/presentation/screen/payment_session_screen.dart';
import 'package:imart/features/category/category_screen.dart';
import 'package:imart/features/home/presentation/home.dart';
import 'package:imart/features/wishlist/presentation/screen/wishlist_screen.dart';

/// Main navigation shell with glassmorphism bottom navigation bar
/// Connects: Home, Categories, Wishlist, Cart screens
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  // ignore: library_private_types_in_public_api
  static final GlobalKey<_MainNavigationShellState> globalKey = GlobalKey();

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _showNavBar = true;

  List<Widget> get _screens => [
    const HomeScreen(), // Index 0
    const CategoryScreen(), // Index 1
    WishlistScreen(
      // Index 2
      onBackPressed: () {
        // Navigate back to home when back is pressed in wishlist
        setState(() {
          _currentIndex = 0;
          _showNavBar = true;
        });
      },
      onStartShopping: () {
        // Navigate to category page when Start Shopping button is tapped
        setState(() {
          _currentIndex = 1; // Category page
          _showNavBar = true;
        });
      },
    ),
    CartScreen(
      // Index 3
      onBackPressed: () {
        // Navigate back to home when back is pressed in cart
        setState(() {
          _currentIndex = 0;
          _showNavBar = true;
        });
      },
      onProceedToAddress: () {
        // Navigate to address selection screen
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => AddressSessionScreen(
              onBackPressed: () {
                Navigator.of(context).pop();
              },
              onProceedToPayment: () {
                // Navigate to payment screen
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => PaymentSessionScreen(
                      onBackPressed: () {
                        Navigator.of(context).pop();
                      },
                      onOrderPlaced: () {
                        // Order placed - navigate back to home
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                        // Reset to home tab and show navbar
                        setState(() {
                          _currentIndex = 0;
                          _showNavBar = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully!'),
                            backgroundColor: Color(0xFF25A63E),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      // Hide navbar when navigating to cart (index 3)
      _showNavBar = index != 3;
    });

    // Trigger animations when navigating to Categories screen
    if (index == 1) {}
  }

  // Reserved for future cart back navigation functionality
  // void _handleCartBackPressed() {
  //   setState(() {
  //     _currentIndex = 0; // Go back to Home
  //     _showNavBar = true; // Show navbar again
  //   });
  // }

  /// Public method to navigate to a specific tab
  void navigateToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      _onNavItemTapped(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Current screen content
          IndexedStack(index: _currentIndex, children: _screens),

          // Glassmorphism bottom navigation bar (conditionally shown)
          if (_showNavBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: _showNavBar ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showNavBar ? 1.0 : 0.0,
                  child: _buildGlassmorphismNavBar(),
                ),
              ),
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
            offset: Offset(0, 12.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.15),
                ],
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

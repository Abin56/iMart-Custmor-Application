import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../widgets/home_top_section_ui.dart';

/// Complete Home Screen Implementation
/// Matches Figma design exactly with all sections
class HomeScreenComplete extends StatefulWidget {
  const HomeScreenComplete({super.key});

  @override
  State<HomeScreenComplete> createState() => _HomeScreenCompleteState();
}

class _HomeScreenCompleteState extends State<HomeScreenComplete> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section (green background + categories)
                const HomeTopSectionUI(),

                // Search bar
                _buildSearchBar(),

                AppSpacing.h16,

                // Your go-to items section
                _buildGoToItemsSection(),

            AppSpacing.h16,

                // Offers made for you section
                _buildOffersSection(),

                SizedBox(height: 100.h), // Space for bottom nav
              ],
            ),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
         AppSpacing.w12,
            Icon(
              Icons.search,
              color: Colors.grey.shade600,
              size: 22.sp,
            ),
         AppSpacing.w12,
          const Center(child: AppText(text: 'Search...',color: AppColors.grey,fontWeight: FontWeight.w200,),)
          ],
        ),
      ),
    );
  }

  Widget _buildGoToItemsSection() {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your go-to items',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF25A63E),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Horizontal product cards
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: const _ProductCard(
                  title: 'Fresh fruits',
                  price: '₹ 6.00',
                  discount: '20% OFF',
                  imagePath: 'assets/images/fruits.png',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offers made for you',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See More',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF25A63E),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Horizontal product cards
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: const _ProductCard(
                  title: 'Fresh fruits',
                  price: '₹ 6.00',
                  discount: '20% OFF',
                  imagePath: 'assets/images/fruits.png',
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildGlassmorphismNavBar() {
    return Container(
      height: 60.h,
      margin: EdgeInsets.fromLTRB(25.w, 0, 25.w, 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          // Primary shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 35.r,
            spreadRadius: 0,
            offset: Offset(0, 12.h),
          ),
          // Secondary shadow for subtle lift
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
                  isActive: true,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Categories',
                  isActive: false,
                ),
                _buildNavItem(
                  icon: Icons.favorite_border,
                  label: 'Wishlist',
                  isActive: false,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  isActive: false,
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
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Handle navigation
        },
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
                size: isActive ? 30.sp : 30.sp,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Product Card Widget with Add to Cart functionality
/// Shows "Add to cart" button initially, then quantity selector after adding
class _ProductCard extends StatefulWidget {
  final String title;
  final String price;
  final String discount;
  final String imagePath;

  const _ProductCard({
    required this.title,
    required this.price,
    required this.discount,
    required this.imagePath,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isAddedToCart = false;
  bool _isFavorite = false;
  int _quantity = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badges
          Stack(
            children: [
              Container(
                height: 100.h,
                width: double.infinity,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                ),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.shopping_basket,
                      size: 40.sp,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              // Discount badge - flag shape at top left
              Positioned(
                top: 0,
                left: 0,
                child: ClipPath(
                  clipper: _BadgeClipper(),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 8.w,
                      right: 8.w,
                      top: 6.h,
                      bottom: 10.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFF8C42), // Lighter orange at top
                          Color(0xFFFF6B35), // Darker orange at bottom
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.discount,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
              // Wishlist icon - circle at top right
              Positioned(
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18.sp,
                        color: _isFavorite
                            ? const Color(0xFFFF6B6B) // Red/coral for filled
                            : const Color(0xFFFFA726), // Orange for outline
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Product details
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.price,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF25A63E),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Toggle between "Add to cart" button and quantity selector
                _isAddedToCart ? _buildQuantitySelector() : _buildAddToCartButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quantity selector with - and + buttons
  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Quantity selector with circular buttons
        Container(
          height: 30.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade100),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_quantity > 1) {
                      _quantity--;
                    } else {
                      // If quantity is 1 and user taps minus, remove from cart
                      _isAddedToCart = false;
                      _quantity = 2; // Reset to default quantity
                    }
                  });
                },
                  child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration:  BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color:  AppColors.black)
                  ),
                  child: Center(
                    child: Icon(
                      Icons.remove,
                      size: 15 .sp,
                      color: const Color(0xFF25A63E)
                    ),
                  ),
                ),
              ),
              AppSpacing.w8,
              Container(
                width: 20.w,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              AppSpacing.w8,
              GestureDetector(
                onTap: () {
                  setState(() {
                    _quantity++;
                  });
                },
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration:  BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color:  AppColors.black)
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 15 .sp,
                      color: const Color(0xFF25A63E)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Add to cart circular button
   
      ],
    );
  }

  /// Add to cart button with shopping bag icon
  Widget _buildAddToCartButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAddedToCart = true;
        });
      },
      child: Container(
        height: 32.h,
        decoration:  BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.grey,
            // width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 16.sp,
              color: const Color(0xFF25A63E),
            ),
            SizedBox(width: 6.w),
         const AppText(text:  'Add to cart',fontSize: 12,fontWeight: FontWeight.w600,),
       
            
          ],
        ),
      ),
    );
  }
}

/// Custom clipper for the ribbon/flag-shaped discount badge
/// Creates a flag shape with triangular notches at the bottom
class _BadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at top-left corner
    path.moveTo(0, 0);

    // Draw to top-right
    path.lineTo(size.width, 0);

    // Draw down right side
    path.lineTo(size.width, size.height * 0.75);

    // Create triangular notch at bottom (flag cut)
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);

    // Draw up left side
    path.lineTo(0, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

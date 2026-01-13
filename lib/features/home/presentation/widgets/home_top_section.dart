import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home screen top section with dark green background,
/// delivery location, profile icon, promotional banner carousel,
/// and category icons overlapping the white section below.
class HomeTopSection extends StatefulWidget {
  final String deliveryAddress;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLocationTap;
  final ValueChanged<int>? onCategoryTap;
  final List<PromoBanner>? banners;

  const HomeTopSection({
    super.key,
    this.deliveryAddress = 'Sarjapur Marathahalli Road, Kaikondrahalli,',
    this.onProfileTap,
    this.onLocationTap,
    this.onCategoryTap,
    this.banners,
  });

  @override
  State<HomeTopSection> createState() => _HomeTopSectionState();
}

class _HomeTopSectionState extends State<HomeTopSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Default banners if none provided
  late final List<PromoBanner> _banners;

  @override
  void initState() {
    super.initState();
    _banners = widget.banners ??
        [
          const PromoBanner(
            title: 'Use Code "Fresh" to',
            subtitle: 'get 10% off on all\nFresh groceries',
            imagePath: 'assets/images/fruits.png',
          ),
          const PromoBanner(
            title: 'Free Delivery',
            subtitle: 'on orders above\n₹299',
            imagePath: 'assets/images/trolley.png',
          ),
          const PromoBanner(
            title: 'Fresh Vegetables',
            subtitle: 'Daily farm fresh\ndelivery',
            imagePath: 'assets/images/fruits.png',
          ),
        ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dark green background container with rounded bottom corners
          _buildGreenBackground(),

          // Content inside green section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  // Delivering To row
                  _buildDeliveryLocationRow(),
                  SizedBox(height: 20.h),
                  // Promotional banner carousel
                  _buildPromoBannerCarousel(),
                  SizedBox(height: 12.h),
                  // Carousel indicators
                  _buildCarouselIndicators(),
                ],
              ),
            ),
          ),

          // White curved container at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildWhiteCurvedSection(),
          ),

          // Category icons row (overlapping green and white sections)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCategoryIconsRow(),
          ),
        ],
      ),
    );
  }

  /// Dark green background with rounded bottom corners
  Widget _buildGreenBackground() {
    return Container(
      height: 320.h,
      decoration: BoxDecoration(
        color: const Color(0xFF0D5C2E), // Dark green
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
    );
  }

  /// Delivery location row with location icon, address text, and profile icon
  Widget _buildDeliveryLocationRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location icon and address
          Expanded(
            child: GestureDetector(
              onTap: widget.onLocationTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location icon
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                  SizedBox(width: 8.w),
                  // Address text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivering To',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.deliveryAddress,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Profile icon button
          GestureDetector(
            onTap: widget.onProfileTap,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFF0A4A24),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Promotional banner carousel
  Widget _buildPromoBannerCarousel() {
    return SizedBox(
      height: 140.h,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          return _buildPromoBannerCard(_banners[index]);
        },
      ),
    );
  }

  /// Single promotional banner card
  Widget _buildPromoBannerCard(PromoBanner banner) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE0), // Light cream/beige
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Text content
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banner.title,
                  style: TextStyle(
                    color: const Color(0xFF1A1A1A),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    color: const Color(0xFF4A4A4A),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Right side - Image
          Expanded(
            flex: 2,
            child: Image.asset(
              banner.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 40.sp,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Carousel indicator dots
  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _banners.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: _currentPage == index ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  /// White curved section at bottom (creates layered effect)
  Widget _buildWhiteCurvedSection() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
    );
  }

  /// Category icons row overlapping green and white sections
  Widget _buildCategoryIconsRow() {
    const categories = [
      CategoryItem(icon: Icons.eco_outlined, label: 'Vegetables', color: Color(0xFF4CAF50)),
      CategoryItem(icon: Icons.apple, label: 'Fruits', color: Color(0xFFFF9800)),
      CategoryItem(icon: Icons.cookie_outlined, label: 'Snacks', color: Color(0xFF9C27B0)),
      CategoryItem(icon: Icons.cleaning_services_outlined, label: 'Cleaning', color: Color(0xFF2196F3)),
      CategoryItem(icon: Icons.spa_outlined, label: 'Beauty and\nHygiene', color: Color(0xFFE91E63)),
    ];

    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          categories.length,
          (index) => _buildCategoryIcon(categories[index], index),
        ),
      ),
    );
  }

  /// Single category icon with label
  Widget _buildCategoryIcon(CategoryItem category, int index) {
    return GestureDetector(
      onTap: () => widget.onCategoryTap?.call(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular icon container
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0D5C2E).withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              category.icon,
              color: const Color(0xFF0D5C2E),
              size: 28.sp,
            ),
          ),
          SizedBox(height: 6.h),
          // Category label
          SizedBox(
            width: 65.w,
            child: Text(
              category.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF1A1A1A),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Model for promotional banner data
class PromoBanner {
  final String title;
  final String subtitle;
  final String imagePath;

  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

/// Model for category item data
class CategoryItem {
  final IconData icon;
  final String label;
  final Color color;

  const CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home screen top section - UI ONLY implementation
/// Matches EXACT design specifications from screenshot
///
/// Structure:
/// - Green curved background (280px height)
/// - White curved bottom section (creates wave overlap)
/// - Delivery header with location and profile icon
/// - Promo banner card (cream colored)
/// - Slider indicator dots
/// - Category icons overlapping green/white sections
///
/// NO state management, NO API calls, PURE UI
class HomeTopSectionUI extends StatelessWidget {
  const HomeTopSectionUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 380.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Layer 1: Green curved background
            _buildGreenBackground(),

            // Layer 2: Content on green background
            _buildTopContent(context),

            // Layer 3: Category icons (overlapping green & white)
            _buildCategoryIcons(),
          ],
        ),
      ),
    );
  }

  /// Green background container with curved bottom corners and center dip
  Widget _buildGreenBackground() {
    return ClipPath(
      clipper: _GreenCurvedClipper(),
      child: Container(
        height: 320.h,
        color: const Color(0xFF145A32), // Dark forest green
      ),
    );
  }

  /// Top content (header, promo, indicator)
  Widget _buildTopContent(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _HeaderRow(),
            SizedBox(height: 24.h),
            _PromoCardWithIndicator(),
          ],
        ),
      ),
    );
  }

  /// Category icons row with rotary dial animation
  /// Swipeable carousel with smooth curve following
  Widget _buildCategoryIcons() {
    return Positioned(
      bottom: 20.h,
      left: 0,
      right: 0,
      height: 100.h,
      child: const _CategoryCarousel(),
    );
  }
}

/// Header row with location and profile icon
class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location icon
          Icon(Icons.location_on, color: Colors.white, size: 24.sp),
          SizedBox(width: 8.w),
          // Address column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivering To',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Sarjapur Marathahalli Road, Kaikondrahalli,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Profile icon button
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFF0D4A26),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2.w,
              ),
            ),
            child: Icon(Icons.person_outline, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
    );
  }
}

/// Promotional banner card with indicators combined
class _PromoCardWithIndicator extends StatefulWidget {
  @override
  State<_PromoCardWithIndicator> createState() =>
      _PromoCardWithIndicatorState();
}

class _PromoCardWithIndicatorState extends State<_PromoCardWithIndicator> {
  late PageController _pageController;
  double _currentPage = 0.0;

  final List<_PromoBannerData> _banners = const [
    _PromoBannerData(
      title: 'Use Code "Fresh" to',
      subtitle: 'get 10% off on all\nFresh groceries',
      iconData: Icons.discount_outlined,
      imagePath: 'assets/images/fruits.png',
    ),
    _PromoBannerData(
      title: 'Free Delivery',
      subtitle: 'on orders above\n₹299',
      iconData: Icons.local_shipping_outlined,
      imagePath: 'assets/images/trolley.png',
    ),
    _PromoBannerData(
      title: 'Fresh Vegetables',
      subtitle: 'Daily farm fresh\ndelivery',
      iconData: Icons.eco_outlined,
      imagePath: 'assets/images/fruits.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.72);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),

            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
               final distance = (index - _currentPage).abs();
                final scaleX = 1.0 - (distance * 0.08);
                final scaleY = 1.0 - (distance * 0.25);
                final opacity = (1.0 - distance * 0.35).clamp(0.6, 1.0);

                return Transform.translate(
                  offset: Offset((index - _currentPage) * 1.w, 0),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
                    child: Opacity(
                      opacity: opacity,
                      child: _buildBanner(_banners[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = _currentPage.round() == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: isActive ? 24.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBanner(_PromoBannerData banner) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE0),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              banner.iconData,
              color: const Color(0xFF4CAF50),
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
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
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                banner.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.shopping_basket,
                      size: 40.sp,
                      color: const Color(0xFF4CAF50),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Promo banner data model
class _PromoBannerData {
  final String title;
  final String subtitle;
  final IconData iconData;
  final String imagePath;

  const _PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.imagePath,
  });
}

/// Category carousel with rotary dial animation
class _CategoryCarousel extends StatefulWidget {
  const _CategoryCarousel();

  @override
  State<_CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<_CategoryCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  double _currentPage = 0.0;
  late AnimationController _rotationController;
  bool _autoRotating = true;

  // All 10 categories
  final List<CategoryData> _categories = const [
    CategoryData(icon: Icons.shopping_basket_outlined, label: 'Vegetables'),
    CategoryData(icon: Icons.apple_outlined, label: 'Fruits'),
    CategoryData(icon: Icons.fastfood_outlined, label: 'Snacks'),
    CategoryData(icon: Icons.cleaning_services_outlined, label: 'Cleaning'),
    CategoryData(icon: Icons.spa_outlined, label: 'Beauty and\nHygiene'),
    CategoryData(icon: Icons.local_drink_outlined, label: 'Beverages'),
    CategoryData(icon: Icons.bakery_dining_outlined, label: 'Bakery'),
    CategoryData(icon: Icons.egg_outlined, label: 'Dairy'),
    CategoryData(icon: Icons.rice_bowl_outlined, label: 'Rice & Grains'),
    CategoryData(icon: Icons.dining_outlined, label: 'Kitchen'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.25);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });

    // Auto-rotation animation controller
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // Start auto-rotation animation
    _startAutoRotation();
  }

  void _startAutoRotation() async {
    // Wait a bit before starting
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted || !_autoRotating) return;

    // Animate through categories - stop at a balanced middle position
    // Instead of going to the last icon, stop at index 4-5 for better balance
    final double targetPosition =
        (_categories.length / 2) *
        _pageController.position.viewportDimension *
        0.25;

    await _pageController.animateTo(
      targetPosition,
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutCubic,
    );

    // After animation completes, stop auto-rotation
    if (mounted) {
      setState(() {
        _autoRotating = false;
      });
    }
  }

  void _stopAutoRotation() {
    if (_autoRotating) {
      setState(() {
        _autoRotating = false;
      });
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => _stopAutoRotation(),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _categories.length,
        physics: _autoRotating
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildCategoryIcon(index);
        },
      ),
    );
  }

  Widget _buildCategoryIcon(int index) {
    // Calculate distance from current page (center position)
    final double difference = (index - _currentPage).abs();

    // Calculate vertical offset using parabola for curve effect
    // Icons at center should be lower (more negative), icons at edges higher (less negative)
    final double curveOffset = _calculateCurveOffset(difference);

    return GestureDetector(
      onTap: () {
        _stopAutoRotation();
        // User can tap any icon, not just center
        // Optional: Add callback here for category selection
      },
      child: Transform.translate(
        offset: Offset(0, curveOffset),
        child: _CategoryItem(
          icon: _categories[index].icon,
          label: _categories[index].label,
        ),
      ),
    );
  }

  /// Calculate vertical offset to follow the green container's curve
  /// Center icons are DOWN (positive offset), edge icons are UP (negative offset)
  /// This matches the green container's dip curve from the Figma design
  double _calculateCurveOffset(double difference) {
    // The green container curves DOWN at the center (like a smile)
    // So icons at center need POSITIVE offset (move down)
    // Icons at edges need NEGATIVE offset (move up)

    const double curveDepth = 25.0; // How much the center dips down

    // Parabolic curve calculation - INVERTED from previous
    // difference 0 (center) → offset = +25 (push down into the dip)
    // difference 2+ (edges) → offset = 0 (stay at baseline)
    final double normalizedDiff = (difference / 2.0).clamp(0.0, 1.0);
    final double curveValue =
        normalizedDiff * normalizedDiff; // x² gives parabolic shape
    final double offset =
        curveDepth * (1 - curveValue); // Positive for center, 0 for edges

    return offset;
  }
}

/// Category data model
class CategoryData {
  final IconData icon;
  final String label;

  const CategoryData({required this.icon, required this.label});
}

/// Single category item
class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular icon container
        Container(
          width: 58.w,
          height: 58.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF145A32).withValues(alpha: 0.15),
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF145A32), size: 28.sp),
        ),
        SizedBox(height: 6.h),
        // Label
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Custom clipper for green container with smooth arc curve at bottom center
/// Creates a smooth circular wave where category icons sit
class _GreenCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start from top-left
    path.moveTo(0, 0);

    // Top edge
    path.lineTo(width, 0);

    // Right edge down to curve start
    path.lineTo(width, height - 50);

    // Smooth wide wave curve at bottom - single continuous bezier
    path.quadraticBezierTo(
      width / 2,
      height + 50, // Control point at center - creates gentle downward curve
      0,
      height - 50, // End point at left side
    );

    // Left edge up
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Custom clipper for white container with smooth upward arc at top center
/// Mirrors the green container's arc to create perfect nesting
class _WhiteCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start from bottom-left
    path.moveTo(0, height);

    // Left edge up to curve start
    path.lineTo(0, 50);

    // Smooth wide wave curve at top - single continuous bezier (mirrors green)
    path.quadraticBezierTo(
      width / 2,
      -60, // Control point at center - creates gentle upward curve
      width,
      50, // End point at right side
    );

    // Right edge down
    path.lineTo(width, height);

    // Bottom edge
    path.lineTo(0, height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

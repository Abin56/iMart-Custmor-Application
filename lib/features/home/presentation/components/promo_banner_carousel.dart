import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/promo_banner.dart';

/// Promotional banner carousel with indicators
/// Displays promo cards with scale and opacity animations
class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({
    required this.banners,
    this.onBannerTap,
    super.key,
  });

  final List<PromoBanner> banners;
  final ValueChanged<PromoBanner>? onBannerTap;

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

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
    return SizedBox(
      height: 140.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.banners.length,
          clipBehavior: Clip.none,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index.toDouble();
            });
          },
          itemBuilder: (context, index) {
            final distance = (index - _currentPage).abs();
            final scaleX = 1.0 - (distance * 0.08);
            final scaleY = 1.0 - (distance * 0.25);
            final opacity = (1.0 - distance * 0.35).clamp(0.6, 1.0);
            final isActive = _currentPage.round() == index;

            return Transform.translate(
              offset: Offset((index - _currentPage) * 1.w, 0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
                child: Opacity(
                  opacity: opacity,
                  child: _buildBanner(widget.banners[index], isActive, index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBanner(PromoBanner banner, bool isActive, int index) {
    return GestureDetector(
      onTap: () => widget.onBannerTap?.call(banner),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBannerContent(banner),
            if (isActive) ...[SizedBox(height: 17.h), _buildIndicators()],
          ],
        ),
      ),
    );
  }

  Widget _buildBannerContent(PromoBanner banner) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                banner.title,
                style: TextStyle(
                  color: const Color(0xFF1A1A1A),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        _buildBannerImage(banner.imageUrl),
      ],
    );
  }

  Widget _buildBannerImage(String imageUrl) {
    // Check if it's a local asset or network URL
    final isNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    return Container(
      width: 85.w,
      height: 85.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: isNetworkImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.fitHeight,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: const Color(0xFF4CAF50),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.shopping_basket,
                      size: 42.sp,
                      color: const Color(0xFF4CAF50),
                    ),
                  );
                },
              )
            : Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.shopping_basket,
                      size: 42.sp,
                      color: const Color(0xFF4CAF50),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.banners.length, (index) {
        final isDotActive = _currentPage.round() == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isDotActive ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isDotActive
                ? const Color(0xFF145A32)
                : const Color(0xFF145A32).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

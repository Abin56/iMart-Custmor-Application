import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../application/providers/home_data_provider.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/promo_banner.dart';
import 'category_carousel.dart';
import 'curved_clippers.dart';
import 'home_header.dart';
import 'promo_banner_carousel.dart';

/// Home screen top section - Integrated with backend
/// Fetches categories and banners from API using Riverpod providers
///
/// Structure:
/// - Green curved background (280px height)
/// - White curved bottom section (creates wave overlap)
/// - Delivery header with location and profile icon
/// - Promo banner card (cream colored)
/// - Slider indicator dots
/// - Category icons overlapping green/white sections
class HomeTopSectionUI extends ConsumerWidget {
  const HomeTopSectionUI({
    this.address = 'Sarjapur Marathahalli Road, Kaikondrahalli,',
    this.onProfileTap,
    this.onBannerTap,
    this.onCategoryTap,
    super.key,
  });

  final String address;
  final VoidCallback? onProfileTap;
  final ValueChanged<PromoBanner>? onBannerTap;
  final ValueChanged<Category>? onCategoryTap;

  // Default mock data for banners if not provided
  static const List<PromoBanner> _defaultBanners = [
    PromoBanner(
      id: 1,
      name: 'Use Code "Fresh" to',
      imageUrl: 'assets/images/no-image.png',
      descriptionPlaintext: 'get 10% off on all\nFresh groceries',
    ),
    PromoBanner(
      id: 2,
      name: 'Free Delivery',
      imageUrl: 'assets/images/trolley.png',
      descriptionPlaintext: 'on orders above\n₹299',
    ),
    PromoBanner(
      id: 3,
      name: 'Fresh Vegetables',
      imageUrl: 'assets/images/no-image.png',
      descriptionPlaintext: 'Daily farm fresh\ndelivery',
    ),
  ];

  // Default mock data for categories if not provided
  static const List<Category> _defaultCategories = [
    Category(id: 1, name: 'Vegetables'),
    Category(id: 2, name: 'Fruits'),
    Category(id: 3, name: 'Snacks'),
    Category(id: 4, name: 'Cleaning'),
    Category(id: 5, name: 'Beauty and\nHygiene'),
    Category(id: 6, name: 'Beverages'),
    Category(id: 7, name: 'Bakery'),
    Category(id: 8, name: 'Dairy'),
    Category(id: 9, name: 'Rice & Grains'),
    Category(id: 10, name: 'Kitchen'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers for banners and offer categories
    final bannersAsync = ref.watch(bannersProvider);
    // Fetch ONLY offer categories (is_offer=true) for category carousel
    final offerCategoriesAsync = ref.watch(categoriesProvider(isOffer: true));

    // Get data from async values or use defaults
    final displayBanners = bannersAsync.when(
      data: (data) => data.isNotEmpty ? data : _defaultBanners,
      loading: () => _defaultBanners,
      error: (_, _) => _defaultBanners,
    );

    final displayCategories = offerCategoriesAsync.when(
      data: (data) => data.isNotEmpty ? data : _defaultCategories,
      loading: () => _defaultCategories,
      error: (_, _) => _defaultCategories,
    );

    return SizedBox(
      height: 380.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Layer 1: Green curved background
          _buildGreenBackground(),

          // Layer 2: Content on green background
          _buildTopContent(displayBanners),

          // Layer 3: Category icons (overlapping green & white)
          _buildCategoryIcons(displayCategories),
        ],
      ),
    );
  }

  /// Green background container with curved bottom corners and center dip
  Widget _buildGreenBackground() {
    return ClipPath(
      clipper: GreenCurvedClipper(),
      child: Container(
        height: 310.h,
        color: const Color(0xFF145A32), // Dark forest green
      ),
    );
  }

  /// Top content (header, promo, indicator)
  Widget _buildTopContent(List<PromoBanner> displayBanners) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppSpacing.h12,
            HomeHeader(address: address, onProfileTap: onProfileTap),
            AppSpacing.h12,
            PromoBannerCarousel(
              banners: displayBanners,
              onBannerTap: onBannerTap,
            ),
          ],
        ),
      ),
    );
  }

  /// Category icons row with rotary dial animation
  /// Swipeable carousel with smooth curve following
  Widget _buildCategoryIcons(List<Category> displayCategories) {
    return Positioned(
      bottom: 15.h,
      left: 0,
      right: 0,
      height: 110.h,
      child: CategoryCarousel(
        categories: displayCategories,
        onCategoryTap: onCategoryTap,
      ),
    );
  }
}

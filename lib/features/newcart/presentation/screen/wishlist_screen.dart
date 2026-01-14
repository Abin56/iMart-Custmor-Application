import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../models/category_product.dart';
import '../../models/dummy_data.dart';
import '../components/widgets/product_card.dart';
import '../screens/product_detail_screen.dart';

/// Wishlist Screen - Shows user's favorite products
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // For demo purposes, we'll show some dummy products
  // In real app, this would come from a wishlist state management
  late List<CategoryProduct> _wishlistProducts;

  @override
  void initState() {
    super.initState();
    // Get some sample products for the wishlist from different categories
    _wishlistProducts = [
      ...DummyData.getProductsForCategory('1').take(4),
      ...DummyData.getProductsForCategory('2').take(3),
      ...DummyData.getProductsForCategory('3').take(3),
      ...DummyData.getProductsForCategory('5').take(2),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          // Status bar space
          Container(height: 42.h, color: const Color(0xFF0D5C2E)),
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            decoration: const BoxDecoration(color: Color(0xFF0D5C2E)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Your Favorites',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
  
          // Products grid
          Expanded(
            child: _wishlistProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                      mainAxisExtent: 190.h,
                    ),
                    itemCount: _wishlistProducts.length,
                    itemBuilder: (context, index) {
                      final product = _wishlistProducts[index];
                      return ProductCard(
                        key: ValueKey(product.variantId),
                        product: product,
                        colorScheme: colorScheme,
                        onAddToCart: () {
                          // Handle add to cart
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64.sp, color: AppColors.grey),
          SizedBox(height: 16.h),
          AppText(
            text: 'Your wishlist is empty',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
          SizedBox(height: 8.h),
          AppText(
            text: 'Add your favorite products here',
            fontSize: 14.sp,
            color: AppColors.grey.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

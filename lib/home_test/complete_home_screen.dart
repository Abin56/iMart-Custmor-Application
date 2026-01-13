import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home.dart';

/// Complete home screen matching the design image
class CompleteHomeScreen extends StatelessWidget {
  const CompleteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top section with green header, promo banner, and categories
          const HomeTopSection(
            deliveryAddress: 'Sarjapur Marathahalli Road, Kaikondrahalli,',
          ),

          // Scrollable content below
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Search bar
                  _buildSearchBar(),

                  SizedBox(height: 24.h),

                  // "Your go-to items" section
                  _buildGoToItemsSection(),

                  SizedBox(height: 16.h),

                  // Items grid
                  _buildItemsGrid(),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(
              Icons.search,
              color: Colors.grey.shade600,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(width: 16.w),
          ],
        ),
      ),
    );
  }

  /// "Your go-to items" section header
  Widget _buildGoToItemsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your go-to items',
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            'See All',
            style: TextStyle(
              color: const Color(0xFF0D5C2E),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  /// Items grid
  Widget _buildItemsGrid() {
    final items = [
      GoToItem(
        name: 'Fresh Tomatoes',
        price: '₹40',
        unit: 'per kg',
        image: 'assets/images/tomato.png',
        discount: '10% OFF',
      ),
      GoToItem(
        name: 'Fresh Carrots',
        price: '₹60',
        unit: 'per kg',
        image: 'assets/images/carrot.png',
      ),
      GoToItem(
        name: 'Fresh Potatoes',
        price: '₹30',
        unit: 'per kg',
        image: 'assets/images/potato.png',
      ),
      GoToItem(
        name: 'Fresh Onions',
        price: '₹45',
        unit: 'per kg',
        image: 'assets/images/onion.png',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildItemCard(items[index]);
        },
      ),
    );
  }

  /// Single item card
  Widget _buildItemCard(GoToItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 48.sp,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
                // Discount badge
                if (item.discount != null)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        item.discount!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Details section
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    item.name,
                    style: TextStyle(
                      color: const Color(0xFF1A1A1A),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Unit
                  Text(
                    item.unit,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  // Price and add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.price,
                        style: TextStyle(
                          color: const Color(0xFF0D5C2E),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D5C2E),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Model for go-to items
class GoToItem {
  final String name;
  final String price;
  final String unit;
  final String image;
  final String? discount;

  GoToItem({
    required this.name,
    required this.price,
    required this.unit,
    required this.image,
    this.discount,
  });
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/colors.dart';

/// Individual cart item card widget
/// Shows product image, name, unit, price, and quantity controls
class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    required this.productName,
    required this.unit,
    required this.originalPrice,
    required this.currentPrice,
    required this.imagePath,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
    this.onInfoTap,
    this.isOutOfStock = false,
  });
  final String productName;
  final String unit;
  final String originalPrice;
  final String currentPrice;
  final String imagePath;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onInfoTap;
  final bool isOutOfStock;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onInfoTap,
      child: Container(
        height: 90.h,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Product image
            Container(
              width: 65.w,
              height: 65.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(imagePath),
                    if (isOutOfStock)
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        originalPrice,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        currentPrice,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF25A63E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quantity controls
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildCircleButton(
                      icon: Icons.remove,
                      onTap: onDecrement,
                      isFilled: false,
                    ),
                    Container(
                      width: 30.w,
                      alignment: Alignment.center,
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    _buildCircleButton(
                      icon: Icons.add,
                      onTap: onIncrement,
                      isFilled: true,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    // Check if it's a network URL or asset path
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.fitHeight,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.shopping_basket, size: 30.sp, color: Colors.grey);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2.w,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.fitHeight,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.shopping_basket, size: 30.sp, color: Colors.grey);
        },
      );
    }
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isFilled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24.w,
        height: 24.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFilled ? const Color(0xFF25A63E) : Colors.transparent,
          border: Border.all(
            color: isFilled ? const Color(0xFF25A63E) : Colors.grey.shade400,
            width: 1.5.w,
          ),
        ),
        child: Icon(
          icon,
          size: 14.sp,
          color: isFilled ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }
}

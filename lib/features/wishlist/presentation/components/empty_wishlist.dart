import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/core/widgets/app_text.dart';

/// Empty Wishlist Widget
/// Shows when wishlist is empty with a CTA to start shopping
class EmptyWishlist extends StatelessWidget {
  const EmptyWishlist({required this.onStartShopping, super.key});

  final VoidCallback onStartShopping;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFF25A63E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60.sp,
                color: const Color(0xFF25A63E),
              ),
            ),

            SizedBox(height: 24.h),

            // Title
            AppText(
              text: 'Your Wishlist is Empty',
              fontSize: 20.sp,
              color: Colors.black87,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            // Subtitle
            AppText(
              text:
                  'Start adding items to your wishlist\nand they will appear here',
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // Start Shopping Button
            GestureDetector(
              onTap: onStartShopping,
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF25A63E),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: AppText(
                    text: 'Start Shopping',
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shimmer loading card for skeleton UI
class OrderShimmerCard extends StatelessWidget {
  const OrderShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Shimmer icon
            _ShimmerBox(width: 60.w, height: 60.h, borderRadius: 12.r),

            SizedBox(width: 12.w),

            // Shimmer content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 120.w, height: 16.h, borderRadius: 4.r),
                  SizedBox(height: 8.h),
                  _ShimmerBox(
                    width: 80.w,
                    height: 14.h,
                    borderRadius: 4.r,
                    color: Colors.grey.shade200,
                  ),
                  SizedBox(height: 8.h),
                  _ShimmerBox(
                    width: 100.w,
                    height: 12.h,
                    borderRadius: 4.r,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading list for orders
class OrdersShimmerList extends StatelessWidget {
  const OrdersShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 3,
      itemBuilder: (context, index) => const OrderShimmerCard(),
    );
  }
}

/// Reusable shimmer box widget
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.color,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

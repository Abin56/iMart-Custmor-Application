import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/category.dart';

/// Single category item widget
/// Displays a circular icon with label
class CategoryItem extends StatelessWidget {
  const CategoryItem({required this.category, this.onTap, super.key});

  final Category category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(),
          SizedBox(height: 6.h),
          _buildLabel(),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    final hasBackgroundImage =
        category.backgroundImageUrl != null &&
        category.backgroundImageUrl!.isNotEmpty;
    final isNetworkImage =
        hasBackgroundImage &&
        (category.backgroundImageUrl!.startsWith('http://') ||
            category.backgroundImageUrl!.startsWith('https://'));

    return Container(
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
      child: ClipOval(
        child: hasBackgroundImage
            ? (isNetworkImage
                  ? Image.network(
                      category.backgroundImageUrl!,
                      fit: BoxFit.fitHeight,
                      width: 58.w,
                      height: 58.h,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF4CAF50),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          category.icon,
                          color: const Color(0xFF145A32),
                          size: 28.sp,
                        );
                      },
                    )
                  : Image.asset(
                      category.backgroundImageUrl!,
                      fit: BoxFit.cover,
                      width: 58.w,
                      height: 58.h,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          category.icon,
                          color: const Color(0xFF145A32),
                          size: 28.sp,
                        );
                      },
                    ))
            : Icon(category.icon, color: const Color(0xFF145A32), size: 28.sp),
      ),
    );
  }

  Widget _buildLabel() {
    return SizedBox(
      width: 70.w,
      child: Text(
        category.name,
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
    );
  }
}

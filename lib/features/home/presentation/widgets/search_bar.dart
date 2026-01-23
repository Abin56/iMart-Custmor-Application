import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/colors.dart';
import '../../../widgets/app_text.dart';

/// Home screen search bar widget
/// Displays a non-interactive search bar that navigates to search screen on tap
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              AppSpacing.w12,
              Icon(Icons.search, color: Colors.grey.shade600, size: 22.sp),
              AppSpacing.w12,
              const Center(
                child: AppText(
                  text: 'Search...',
                  color: AppColors.grey,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

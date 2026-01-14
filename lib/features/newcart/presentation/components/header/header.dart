import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_text.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.colorScheme,
    this.onCategoryTap,
    this.onSearchTap,
  });

  final ColorScheme colorScheme;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: const BoxDecoration(
        color: Color(0xFF0D5C2E),
      ),
      child: Row(
        children: [
       
          AppSpacing.w16,
           AppText(
            text: 'Categories',
                fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
            
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSearchTap,
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          AppSpacing.w12,
        ],
      ),
    );
  }
}

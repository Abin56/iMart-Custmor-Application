import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../../../app/theme/app_spacing.dart';
import '../../../../../../../app/theme/colors.dart';

class AuthErrorMessage extends StatelessWidget {
  const AuthErrorMessage({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18.sp, color: AppColors.red),
          AppSpacing.w8,
          Expanded(
            child: AppText(
              text: message,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.red,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

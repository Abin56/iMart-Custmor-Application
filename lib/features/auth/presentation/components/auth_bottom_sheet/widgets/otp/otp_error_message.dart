import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../../../app/theme/app_spacing.dart';
import '../../../../../../../app/theme/colors.dart';

class OtpErrorMessage extends StatelessWidget {
  const OtpErrorMessage({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.error_outline, size: 16.sp, color: AppColors.red),
        AppSpacing.w8,
        Expanded(
          child: AppText(
            text: message,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.red,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

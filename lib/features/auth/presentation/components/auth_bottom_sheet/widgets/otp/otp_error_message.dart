import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../app/theme/app_spacing.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../../../../../../core/widgets/app_text.dart';

class OtpErrorMessage extends StatelessWidget {
  final String message;

  const OtpErrorMessage({
    super.key,
    required this.message,
  });

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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../../../app/theme/app_spacing.dart';
import '../../../../../../../app/theme/colors.dart';

class OtpInstructions extends StatelessWidget {
  const OtpInstructions({required this.maskedPhoneNumber, super.key});
  final String maskedPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Enter OTP',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.darkGrey,
        ),
        AppSpacing.h4,
        AppText(
          text: 'Enter the 6-digit OTP sent to +91 $maskedPhoneNumber',
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
          maxLines: 2,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../../../app/theme/colors.dart';

class OtpResendOption extends StatelessWidget {
  const OtpResendOption({
    required this.isResending,
    required this.onResend,
    super.key,
  });
  final bool isResending;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          text: "Didn't receive the OTP? ",
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
        GestureDetector(
          onTap: isResending ? null : onResend,
          child: AppText(
            text: isResending ? 'Sending...' : 'Resend OTP',
            fontSize: 13.sp,
            color: isResending ? AppColors.grey : AppColors.buttonGreen,
          ),
        ),
      ],
    );
  }
}

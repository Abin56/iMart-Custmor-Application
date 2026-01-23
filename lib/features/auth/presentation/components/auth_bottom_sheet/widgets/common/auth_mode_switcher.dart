import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../../../app/theme/colors.dart';

class AuthModeSwitcher extends StatelessWidget {
  const AuthModeSwitcher({
    required this.promptText,
    required this.actionText,
    required this.onTap,
    super.key,
  });
  final String promptText;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: promptText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.darkGrey,
          ),
          GestureDetector(
            onTap: onTap,
            child: AppText(
              text: actionText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.buttonGreen,
            ),
          ),
        ],
      ),
    );
  }
}

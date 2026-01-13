import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../../../../../../core/widgets/app_text.dart';

class AuthModeSwitcher extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onTap;

  const AuthModeSwitcher({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onTap,
  });

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

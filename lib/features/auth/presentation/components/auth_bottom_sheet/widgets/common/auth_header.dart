import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../../../../../../core/widgets/app_text.dart';

class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: title,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    );
  }
}

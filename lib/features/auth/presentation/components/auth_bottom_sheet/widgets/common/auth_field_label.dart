import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../../../../../../core/widgets/app_text.dart';

class AuthFieldLabel extends StatelessWidget {
  final String label;

  const AuthFieldLabel({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: label,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../../../app/theme/colors.dart';

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({required this.label, super.key});
  final String label;

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

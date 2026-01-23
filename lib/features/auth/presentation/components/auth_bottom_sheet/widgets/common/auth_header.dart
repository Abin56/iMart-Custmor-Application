import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../../../app/theme/colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppText(text: title, fontSize: 20.sp, color: AppColors.black);
  }
}

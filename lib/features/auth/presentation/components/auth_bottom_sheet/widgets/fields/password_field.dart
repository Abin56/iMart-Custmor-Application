import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../app/theme/colors.dart';
import '../../utils/validators.dart';
import 'auth_text_field.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;
  final String hintText;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.hintText = '••••••••',
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hintText: hintText,
      obscureText: obscureText,
      validator: validator ?? AuthValidators.validatePassword,
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.grey,
          size: 20.sp,
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }
}

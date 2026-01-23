import 'package:flutter/material.dart';

import '../../../../../../../app/theme/colors.dart';
import '../../utils/validators.dart';
import 'auth_text_field.dart';

class MobileField extends StatelessWidget {
  const MobileField({
    required this.controller,
    super.key,
    this.enabled = true,
    this.fillColor,
  });
  final TextEditingController controller;
  final bool enabled;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hintText: 'Enter your number',
      keyboardType: TextInputType.phone,
      maxLength: 10,
      enabled: enabled,
      fillColor: fillColor ?? (enabled ? AppColors.white : AppColors.field),
      validator: AuthValidators.validatePhone,
      fontWeight: FontWeight.w200,
    );
  }
}

import 'package:flutter/material.dart';

import '../../utils/validators.dart';
import 'auth_text_field.dart';

class EmailField extends StatelessWidget {
  const EmailField({required this.controller, super.key, this.validator});
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hintText: 'you@example.com',
      keyboardType: TextInputType.emailAddress,
      validator: validator ?? AuthValidators.validateEmailSimple,
    );
  }
}

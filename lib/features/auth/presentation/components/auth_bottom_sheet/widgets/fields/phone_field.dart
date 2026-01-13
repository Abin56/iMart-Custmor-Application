import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/validators.dart';
import 'auth_text_field.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hintText: 'Enter you number',
      keyboardType: TextInputType.phone,
      maxLength: 10,
      validator: AuthValidators.validatePhone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      fontWeight: FontWeight.w200,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../app/theme/colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.hintText,
    super.key,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
    this.fillColor,
    this.maxLength,
    this.inputFormatters,
    this.fontWeight,
    this.cursorColor,
  });
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final Color? fillColor;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FontWeight? fontWeight;
  final Color? cursorColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: cursorColor ?? AppColors.grey,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.grey,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        counterText: maxLength != null ? '' : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        filled: true,
        fillColor: fillColor ?? AppColors.white,
        suffixIcon: suffixIcon,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: AppColors.buttonGreen,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
      ),
      validator: validator,
    );
  }
}

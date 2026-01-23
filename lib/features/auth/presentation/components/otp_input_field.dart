import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../app/theme/colors.dart';

/// Reusable OTP Input Field Component with SMS Auto-fill
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    required this.controllers,
    required this.focusNodes,
    super.key,
    this.hasError = false,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
  }) : assert(
         controllers.length == 6 && focusNodes.length == 6,
         'OTP must have exactly 6 controllers and focus nodes',
       );
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final VoidCallback? onChanged;
  final VoidCallback? onCompleted;
  final bool enabled;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> with CodeAutoFill {
  bool _smsAutoFillEnabled = false;

  @override
  void initState() {
    super.initState();
    _listenForSmsCode();
  }

  Future<void> _listenForSmsCode() async {
    try {
      // Listen for SMS code
      await SmsAutoFill().listenForCode();

      // Mark as enabled only if we successfully initialized
      _smsAutoFillEnabled = true;
    } catch (e) {
      // SMS auto-fill is not available on this platform (iOS, Web, or emulator)
      _smsAutoFillEnabled = false;
    }
  }

  @override
  void codeUpdated() {
    // This is called when SMS is received
    if (code != null && code!.length == 6) {
      _fillOtpFields(code!);
      widget.onCompleted?.call();
    }
  }

  void _fillOtpFields(String otpCode) {
    for (var i = 0; i < 6 && i < otpCode.length; i++) {
      widget.controllers[i].text = otpCode[i];
    }
    // Unfocus after filling
    widget.focusNodes.last.unfocus();
    setState(() {});
  }

  @override
  void dispose() {
    // Cancel SMS listening only if it was enabled
    if (_smsAutoFillEnabled) {
      try {
        SmsAutoFill().unregisterListener();
      } catch (e) {
        // Silently handle - widget is being disposed anyway
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48.w,
          height: 56.h,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  widget.controllers[index].text.isEmpty &&
                  index > 0) {
                widget.focusNodes[index - 1].requestFocus();
              }
            },
            child: TextFormField(
              controller: widget.controllers[index],
              focusNode: widget.focusNodes[index],
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: widget.hasError ? AppColors.red : AppColors.black,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: widget.hasError
                    ? AppColors.red.withValues(alpha: 0.05)
                    : AppColors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.red
                        : AppColors.buttonGreen,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.red
                        : AppColors.grey.withValues(alpha: 0.3),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.grey.withValues(alpha: 0.3),
                  ),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  widget.focusNodes[index + 1].requestFocus();
                } else if (value.isNotEmpty && index == 5) {
                  widget.focusNodes[index].unfocus();
                  widget.onCompleted?.call();
                }
                widget.onChanged?.call();
              },
            ),
          ),
        );
      }),
    );
  }
}

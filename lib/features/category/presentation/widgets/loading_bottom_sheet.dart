// ignore_for_file: use_decorated_box

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// User-friendly loading bottom sheet with progress indicator
class LoadingBottomSheet extends StatefulWidget {
  const LoadingBottomSheet({
    required this.message,
    super.key,
    this.showPercentage = true,
    this.stages,
  });

  final String message;
  final bool showPercentage;
  final List<String>? stages; // Optional multi-stage messages

  /// Show the loading bottom sheet
  static void show(
    BuildContext context, {
    required String message,
    bool showPercentage = true,
    List<String>? stages,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      isScrollControlled: true,
      builder: (context) => LoadingBottomSheet(
        message: message,
        showPercentage: showPercentage,
        stages: stages,
      ),
    );
  }

  /// Hide the loading bottom sheet
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  State<LoadingBottomSheet> createState() => _LoadingBottomSheetState();
}

class _LoadingBottomSheetState extends State<LoadingBottomSheet> {
  int _percentage = 0;
  String _currentStageMessage = '';

  @override
  void initState() {
    super.initState();

    if (widget.showPercentage) {
      _simulateProgress();
    }
  }

  void _simulateProgress() {
    // Stage 1: 40%
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _percentage = 40;
        if (widget.stages != null && widget.stages!.isNotEmpty) {
          _currentStageMessage = widget.stages![0];
        }
      });
    });
    // Stage 2: 70%
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _percentage = 70;
        if (widget.stages != null && widget.stages!.length > 1) {
          _currentStageMessage = widget.stages![1];
        }
      });
    });
    // Stage 3: 90%
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _percentage = 90;
        if (widget.stages != null && widget.stages!.length > 2) {
          _currentStageMessage = widget.stages![2];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20.r,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Progress indicator
              Row(
                children: [
                  // Animated circular progress
                  SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50.w,
                          height: 50.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 4.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF25A63E),
                            ),
                            backgroundColor: Colors.grey.shade200,
                            value: widget.showPercentage
                                ? _percentage / 100
                                : null,
                          ),
                        ),
                        if (widget.showPercentage)
                          TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: _percentage),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) {
                              return Text(
                                '$value%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF25A63E),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        // Stage message (if available)
                        if (widget.stages != null &&
                            _currentStageMessage.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _currentStageMessage,
                              key: ValueKey(_currentStageMessage),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF25A63E),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            SizedBox(
                              width: 12.w,
                              height: 12.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Please wait',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

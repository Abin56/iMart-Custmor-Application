import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Professional loading overlay with percentage indicator
class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    required this.message,
    super.key,
    this.showPercentage = false,
    this.stages,
  });

  final String message;
  final bool showPercentage;
  final List<String>? stages; // Optional multi-stage messages

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _percentage = 0;
  String _currentStageMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Simulate percentage progress
    if (widget.showPercentage) {
      _simulateProgress();
    }
  }

  void _simulateProgress() {
    // Stage 1: 30%
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _percentage = 30;
        if (widget.stages != null && widget.stages!.isNotEmpty) {
          _currentStageMessage = widget.stages![0];
        }
      });
    });
    // Stage 2: 60%
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _percentage = 60;
        if (widget.stages != null && widget.stages!.length > 1) {
          _currentStageMessage = widget.stages![1];
        }
      });
    });
    // Stage 3: 85%
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _percentage = 85;
        if (widget.stages != null && widget.stages!.length > 2) {
          _currentStageMessage = widget.stages![2];
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular progress indicator with percentage
                  SizedBox(
                    width: 80.w,
                    height: 80.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80.w,
                          height: 80.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 6.w,
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
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF25A63E),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Loading message
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Stage message (if available)
                  if (widget.stages != null &&
                      _currentStageMessage.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentStageMessage,
                        key: ValueKey(_currentStageMessage),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF25A63E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  SizedBox(height: 6.h),
                  // Subtitle with sparkle
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hourglass_bottom,
                        size: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Just a moment',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.hourglass_bottom,
                        size: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple loading indicator for filter application
class FilterLoadingIndicator extends StatelessWidget {
  const FilterLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF25A63E).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF25A63E).withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF25A63E),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Applying filter...',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0D5C2E),
            ),
          ),
        ],
      ),
    );
  }
}

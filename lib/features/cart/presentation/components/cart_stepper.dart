import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Progress stepper widget showing Cart → Address → Payment steps
/// Displays horizontal step indicators with animated connecting lines and radiation effects
class CartStepper extends StatefulWidget {
  const CartStepper({super.key, this.currentStep = 0});
  final int currentStep;

  @override
  State<CartStepper> createState() => _CartStepperState();
}

class _CartStepperState extends State<CartStepper>
    with TickerProviderStateMixin {
  late AnimationController _radiationController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Radiation animation for active step
    _radiationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Progress line animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animations after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _radiationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75.h,
      // padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AnimatedStepCircle(
            isActive: widget.currentStep >= 0,
            isCurrent: widget.currentStep == 0,
            label: 'Cart',
            radiationController: _radiationController,
            delay: Duration.zero,
          ),
          _AnimatedStepConnector(
            isCompleted: widget.currentStep > 0,
            progressController: _progressController,
            delay: const Duration(milliseconds: 300),
          ),
          _AnimatedStepCircle(
            isActive: widget.currentStep >= 1,
            isCurrent: widget.currentStep == 1,
            label: 'Address',
            radiationController: _radiationController,
            delay: const Duration(milliseconds: 400),
          ),
          _AnimatedStepConnector(
            isCompleted: widget.currentStep > 1,
            progressController: _progressController,
            delay: const Duration(milliseconds: 700),
          ),
          _AnimatedStepCircle(
            isActive: widget.currentStep >= 2,
            isCurrent: widget.currentStep == 2,
            label: 'Payment',
            radiationController: _radiationController,
            delay: const Duration(milliseconds: 800),
          ),
        ],
      ),
    );
  }
}

/// Individual animated step circle with radiation effect
class _AnimatedStepCircle extends StatefulWidget {
  const _AnimatedStepCircle({
    required this.isActive,
    required this.isCurrent,
    required this.label,
    required this.radiationController,
    required this.delay,
  });
  final bool isActive;
  final bool isCurrent;
  final String label;
  final AnimationController radiationController;
  final Duration delay;

  @override
  State<_AnimatedStepCircle> createState() => _AnimatedStepCircleState();
}

class _AnimatedStepCircleState extends State<_AnimatedStepCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeIn));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Radiation rings for current step
            SizedBox(
              width: 70.w,
              height: 55.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Multiple radiation waves
                  if (widget.isCurrent) ...[
                    _RadiationWave(
                      controller: widget.radiationController,
                      maxRadius: 27.w,
                      delay: 0.0,
                    ),
                    _RadiationWave(
                      controller: widget.radiationController,
                      maxRadius: 27.w,
                      delay: 0.33,
                    ),
                    _RadiationWave(
                      controller: widget.radiationController,
                      maxRadius: 27.w,
                      delay: 0.66,
                    ),
                  ],
                  // Main step circle
                  _buildStepCircle(),
                ],
              ),
            ),
            // SizedBox(height: 6.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                color: widget.isActive ? Colors.black : Colors.grey.shade600,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 28.w,
      height: 28.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isActive ? const Color(0xFF25A63E) : Colors.transparent,
        border: Border.all(
          color: widget.isActive
              ? const Color(0xFF25A63E)
              : Colors.grey.shade400,
          width: 2.w,
        ),
        boxShadow: widget.isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF25A63E).withValues(alpha: 0.4),
                  blurRadius: 8.r,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: widget.isActive
          ? TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(Icons.check, color: Colors.white, size: 18.sp),
                );
              },
            )
          : null,
    );
  }
}

/// Radiation wave effect widget
class _RadiationWave extends StatelessWidget {
  const _RadiationWave({
    required this.controller,
    required this.maxRadius,
    required this.delay,
  });
  final AnimationController controller;
  final double maxRadius;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        final progress = delayedAnimation.value;
        final currentRadius = maxRadius * progress;
        final opacity = (1.0 - progress) * 0.6;

        return Container(
          width: currentRadius * 2,
          height: currentRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF25A63E).withValues(alpha: opacity),
              width: 2.5.w,
            ),
          ),
        );
      },
    );
  }
}

/// Animated connector line between step circles
class _AnimatedStepConnector extends StatefulWidget {
  const _AnimatedStepConnector({
    required this.isCompleted,
    required this.progressController,
    required this.delay,
  });
  final bool isCompleted;
  final AnimationController progressController;
  final Duration delay;

  @override
  State<_AnimatedStepConnector> createState() => _AnimatedStepConnectorState();
}

class _AnimatedStepConnectorState extends State<_AnimatedStepConnector>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted && widget.isCompleted) {
        _lineController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(_AnimatedStepConnector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _lineController.forward();
      } else {
        _lineController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 2.h,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(1.r),
      ),
      child: AnimatedBuilder(
        animation: _lineAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Animated progress line
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 60.w * _lineAnimation.value,
                  height: 2.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF25A63E), Color(0xFF34D058)],
                    ),
                    borderRadius: BorderRadius.circular(1.r),
                    boxShadow: widget.isCompleted
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF25A63E,
                              ).withValues(alpha: 0.5),
                              blurRadius: 4.r,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              // Animated shimmer effect
              if (widget.isCompleted && _lineAnimation.value > 0.9)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: -1.0, end: 2.0),
                  builder: (context, value, child) {
                    return Positioned(
                      left: 60.w * value,
                      child: Container(
                        width: 20.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.6),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Repeat shimmer effect
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

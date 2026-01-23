import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../application/providers/order_provider.dart';

/// Rate Order Bottom Sheet
/// Allows users to rate and review their orders
/// Features improved UI and loading state to prevent multiple submissions
class RateOrderBottomSheet extends ConsumerStatefulWidget {
  const RateOrderBottomSheet({required this.orderId, super.key});
  final int orderId;

  @override
  ConsumerState<RateOrderBottomSheet> createState() =>
      _RateOrderBottomSheetState();
}

class _RateOrderBottomSheetState extends ConsumerState<RateOrderBottomSheet>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  int _hoveredRating = 0;
  final _reviewController = TextEditingController();
  late AnimationController _animationController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_rating == 0) {
      _showErrorSnackbar('Please select a rating');
      return;
    }

    // Prevent multiple submissions
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Submit rating to backend
      // Returns: true = success, false = error, null = already rated
      final result = await ref
          .read(orderProvider.notifier)
          .submitRating(
            orderId: widget.orderId,
            rating: _rating,
            review: _reviewController.text.trim().isEmpty
                ? null
                : _reviewController.text.trim(),
          );

      if (mounted) {
        if (result ?? false) {
          // Success - show success animation then close
          await _showSuccessAndClose();
        } else if (result == null) {
          // Already rated
          _showInfoSnackbar(
            'Already Rated',
            'You have already rated this order',
          );
          Navigator.pop(context);
        } else {
          // Error - allow retry
          setState(() {
            _isSubmitting = false;
          });
          _showErrorSnackbar('Failed to submit review. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorSnackbar('Something went wrong. Please try again.');
      }
    }
  }

  Future<void> _showSuccessAndClose() async {
    // Haptic feedback
    await HapticFeedback.mediumImpact();

    // Show success snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Thank you!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Your feedback helps us improve',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF25A63E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showErrorSnackbar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showInfoSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap to rate';
    }
  }

  String _getRatingEmoji(int rating) {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '⭐';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red.shade400;
      case 2:
        return Colors.orange.shade400;
      case 3:
        return Colors.amber.shade500;
      case 4:
        return Colors.lightGreen.shade500;
      case 5:
        return const Color(0xFF25A63E);
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayRating = _hoveredRating > 0 ? _hoveredRating : _rating;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24.w,
            16.h,
            24.w,
            MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Header with emoji
              Center(
                child: Column(
                  children: [
                    // Emoji container with animated background
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: displayRating > 0
                              ? [
                                  _getRatingColor(
                                    displayRating,
                                  ).withValues(alpha: 0.15),
                                  _getRatingColor(
                                    displayRating,
                                  ).withValues(alpha: 0.05),
                                ]
                              : [Colors.grey.shade100, Colors.grey.shade50],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: displayRating > 0
                              ? _getRatingColor(
                                  displayRating,
                                ).withValues(alpha: 0.3)
                              : Colors.grey.shade200,
                          width: 2.w,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getRatingEmoji(displayRating),
                          style: TextStyle(fontSize: 36.sp),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Title
                    Text(
                      'Rate Your Order',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Order ID
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Order #${widget.orderId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // Star rating section
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Stars row - use FittedBox to prevent overflow
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starRating = index + 1;
                          final isSelected = displayRating >= starRating;

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _rating = starRating;
                              });
                              _animationController
                                ..reset()
                                ..forward();
                            },
                            onTapDown: (_) {
                              setState(() {
                                _hoveredRating = starRating;
                              });
                            },
                            onTapUp: (_) {
                              setState(() {
                                _hoveredRating = 0;
                              });
                            },
                            onTapCancel: () {
                              setState(() {
                                _hoveredRating = 0;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: AnimatedScale(
                                scale: isSelected ? 1.05 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.amber.shade300
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 10.r,
                                              spreadRadius: 1.r,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 40.sp,
                                    color: isSelected
                                        ? Colors.amber.shade400
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Rating text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _getRatingText(displayRating),
                        key: ValueKey(displayRating),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: displayRating > 0
                              ? _getRatingColor(displayRating)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Review text field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 20.sp,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Share your thoughts',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    maxLength: 200,
                    enabled: !_isSubmitting,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tell us about your experience...',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.all(16.w),
                      counterStyle: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(
                          color: const Color(0xFF25A63E),
                          width: 2.w,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Submit button with loading state
              GestureDetector(
                onTap: _isSubmitting ? null : _handleSubmit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: _isSubmitting
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade500,
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF25A63E), Color(0xFF1B7A43)],
                          ),
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: _isSubmitting
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(
                                0xFF25A63E,
                              ).withValues(alpha: 0.4),
                              blurRadius: 20.r,
                              offset: Offset(0, 8.h),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting) ...[
                        SizedBox(
                          width: 22.w,
                          height: 22.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Submitting...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Skip button
              Center(
                child: TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _isSubmitting
                          ? Colors.grey.shade300
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

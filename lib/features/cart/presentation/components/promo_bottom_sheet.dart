import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/colors.dart';
import '../../application/controllers/cart_controller.dart';
import '../../application/controllers/coupon_controller.dart';
import '../../application/controllers/coupon_list_controller.dart';
import '../../domain/entities/coupon.dart';

/// Bottom sheet showing available promo codes
class PromoBottomSheet extends ConsumerStatefulWidget {
  const PromoBottomSheet({super.key});

  @override
  ConsumerState<PromoBottomSheet> createState() => _PromoBottomSheetState();
}

class _PromoBottomSheetState extends ConsumerState<PromoBottomSheet> {
  final TextEditingController _promoController = TextEditingController();
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with applied coupon code if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final couponState = ref.read(couponControllerProvider);
      if (couponState.hasCoupon) {
        _promoController.text = couponState.appliedCoupon!.name;
      }
      // Fetch coupons when bottom sheet opens
      ref.read(couponListControllerProvider.notifier).fetchCoupons();
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _clearPromoCode() {
    _promoController.clear();
    setState(() {});
  }

  Future<void> _validateAndApplyCoupon(String code) async {
    if (code.trim().isEmpty) {
      _showSnackBar('Please enter a promo code', isError: true);
      return;
    }

    setState(() {
      _isValidating = true;
    });

    try {
      final cartState = ref.read(cartControllerProvider);
      final totalItems = cartState.totalItems;

      // Validate coupon
      await ref
          .read(couponControllerProvider.notifier)
          .validateCoupon(code: code.trim(), checkoutItemsQuantity: totalItems);

      // Apply coupon
      await ref
          .read(couponControllerProvider.notifier)
          .applyCoupon(code.trim());

      if (!mounted) return;

      _showSnackBar('Coupon applied successfully!', isError: false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4ECDC4),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couponState = ref.watch(couponControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8555)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offers for you',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Save more on your order',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Applied coupon display
            if (couponState.hasCoupon)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F7),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ECDC4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              couponState.appliedCoupon!.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C7A7B),
                              ),
                            ),
                            Text(
                              couponState.appliedCoupon!.description,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          couponState.appliedCoupon!.formattedDiscount,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () async {
                          await ref
                              .read(couponControllerProvider.notifier)
                              .removeCoupon();
                          _promoController.clear();
                        },
                        child: Icon(
                          Icons.close,
                          color: const Color(0xFF718096),
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Promo code input field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon prefix
                    Padding(
                      padding: EdgeInsets.only(left: 14.w, right: 10.w),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        color: const Color(0xFF718096),
                        size: 20.sp,
                      ),
                    ),
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA0AEC0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                          suffixIcon: _promoController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: _clearPromoCode,
                                  child: Icon(
                                    Icons.clear,
                                    size: 18.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {}); // Rebuild to show/hide clear button
                        },
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty && !_isValidating) {
                            _validateAndApplyCoupon(value.trim());
                          }
                        },
                      ),
                    ),
                    // Check button
                    Padding(
                      padding: EdgeInsets.all(6.w),
                      child: GestureDetector(
                        onTap: _isValidating
                            ? null
                            : () => _validateAndApplyCoupon(
                                _promoController.text,
                              ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isValidating
                                  ? [Colors.grey.shade400, Colors.grey.shade500]
                                  : const [
                                      Color(0xFF4ECDC4),
                                      Color(0xFF44B3AA),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  63,
                                  163,
                                  157,
                                ).withValues(alpha: 0.3),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: _isValidating
                              ? SizedBox(
                                  width: 40.w,
                                  height: 13.sp,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Check',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Promo cards list - Fetch from backend
            Consumer(
              builder: (context, ref, child) {
                final couponListState = ref.watch(couponListControllerProvider);

                return couponListState.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  loaded: (response, lastUpdated) {
                    final coupons = response.availableCoupons;

                    if (coupons.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Center(
                          child: Text(
                            'No coupons available',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: coupons.length,
                      separatorBuilder: (context, index) => AppSpacing.h12,
                      itemBuilder: (context, index) {
                        final coupon = coupons[index];
                        return _PromoCard(
                          coupon: coupon,
                          onApply: () {
                            _promoController.text = coupon.name;
                            _validateAndApplyCoupon(coupon.name);
                          },
                        );
                      },
                    );
                  },
                  error: (message, cachedResponse) {
                    final coupons = cachedResponse?.availableCoupons ?? [];

                    if (coupons.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Center(
                          child: Text(
                            'Failed to load coupons',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: coupons.length,
                      separatorBuilder: (context, index) => AppSpacing.h12,
                      itemBuilder: (context, index) {
                        final coupon = coupons[index];
                        return _PromoCard(
                          coupon: coupon,
                          onApply: () {
                            _promoController.text = coupon.name;
                            _validateAndApplyCoupon(coupon.name);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

/// Individual promo card widget - Ticket style with perforations
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.coupon, required this.onApply});
  final Coupon coupon;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h, // Fixed compact height
      child: Stack(
        children: [
          // Main ticket container
          ClipPath(
            clipper: _TicketClipper(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFBF5), // Light cream
                    Color(0xFFFFF8ED), // Lighter orange tint
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left section - Discount badge with diagonal stripe pattern
                  Container(
                    width: 75.w,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF6B35), // Orange
                          Color(0xFFFF8555), // Lighter orange
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Diagonal stripes pattern
                        CustomPaint(
                          size: Size(75.w, 110.h),
                          painter: _DiagonalStripesPainter(),
                        ),
                        // Content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.local_offer_rounded,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                coupon.formattedDiscount,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      offset: Offset(0, 1.h),
                                      blurRadius: 2.r,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right section - Promo details
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top section - Code and title
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Promo code badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5F7),
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: const Color(0xFF4ECDC4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      coupon.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF2C7A7B),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.content_copy,
                                      size: 11.sp,
                                      color: const Color(0xFF2C7A7B),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6.h),
                              // Title
                              Text(
                                coupon.description,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A202C),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              // Description
                              Text(
                                '${(coupon.usage / coupon.limit * 100).toStringAsFixed(0)}% claimed',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF718096),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // Bottom row - Valid until and Apply button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Valid until
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 12.sp,
                                    color: const Color(0xFF718096),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    coupon.validityDisplayText,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF718096),
                                    ),
                                  ),
                                ],
                              ),

                              // Apply button
                              GestureDetector(
                                onTap: onApply,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B35),
                                        Color(0xFFFF8555),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFF6B35,
                                        ).withValues(alpha: 0.35),
                                        blurRadius: 8.r,
                                        offset: Offset(0, 2.h),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Perforation circles on the divider line
          Positioned(
            left: 70.w,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                7,
                (index) => Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for diagonal stripes pattern
class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const spacing = 12.0;
    for (var i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom clipper for ticket shape with curved notches on sides
class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const notchRadius = 8.0;
    final notchY = size.height / 2;

    // Start from top-left with rounded corner
    path
      ..moveTo(12, 0)
      ..lineTo(size.width - 12, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 12)
      // Right side with notch
      ..lineTo(size.width, notchY - notchRadius)
      ..arcToPoint(
        Offset(size.width, notchY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      // Continue to bottom-right corner
      ..lineTo(size.width, size.height - 12)
      ..quadraticBezierTo(size.width, size.height, size.width - 12, size.height)
      // Bottom edge
      ..lineTo(12, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 12)
      // Left side with notch
      ..lineTo(0, notchY + notchRadius)
      ..arcToPoint(
        Offset(0, notchY - notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      // Back to top-left
      ..lineTo(0, 12)
      ..quadraticBezierTo(0, 0, 12, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

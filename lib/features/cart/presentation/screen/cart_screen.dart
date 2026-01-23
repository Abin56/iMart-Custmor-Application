import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/core/widgets/app_text.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/colors.dart';
import '../../application/controllers/cart_controller.dart';
import '../../application/controllers/coupon_controller.dart';
import '../../application/states/cart_state.dart';
import '../components/bill_summary.dart';
import '../components/cart_item_widget.dart';
import '../components/cart_stepper.dart';

/// Main Cart Screen
/// Shows cart items, bill summary, and checkout button
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key, this.onBackPressed, this.onProceedToAddress});
  final VoidCallback? onBackPressed;
  final VoidCallback? onProceedToAddress;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // Note: Cart is automatically loaded by CartController on initialization
    // No need to manually call loadCart() here

    // Trigger animations only on first load
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _hasAnimated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final couponState = ref.watch(couponControllerProvider);

    // Handle loading state
    if (cartState.status == CartStatus.loading && cartState.data == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Container(height: 13.h, color: const Color(0xFF0D5C2E)),
            _buildHeader(),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    // Handle error state
    if (cartState.status == CartStatus.error && cartState.data == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Container(height: 13.h, color: const Color(0xFF0D5C2E)),
            _buildHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading cart',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      cartState.errorMessage ?? 'Unknown error',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .loadCart(forceRefresh: true);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Handle empty cart
    if (cartState.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Container(height: 13.h, color: const Color(0xFF0D5C2E)),
            _buildHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80.sp,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add items to get started',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final cartItems = cartState.data!.results;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Header
          Container(height: 13.h, color: const Color(0xFF0D5C2E)),

          // // Header
          _buildHeader(),

          // Progress Stepper
          const CartStepper(),

          // Scrollable cart items section ONLY
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => AppSpacing.h12,
              itemBuilder: (context, index) {
                final checkoutLine = cartItems[index];
                final shouldAnimate = _hasAnimated && index < 5;

                final cartItem = CartItemWidget(
                  productName: checkoutLine.productVariantDetails.name,
                  unit: checkoutLine.productVariantDetails.sku,
                  originalPrice:
                      '₹${checkoutLine.productVariantDetails.priceValue.toStringAsFixed(2)}',
                  currentPrice:
                      '₹${checkoutLine.productVariantDetails.effectivePrice.toStringAsFixed(2)}',
                  imagePath:
                      checkoutLine.productVariantDetails.primaryImageUrl ??
                      'assets/images/no-image.png',
                  quantity: checkoutLine.quantity,
                  onIncrement: () {
                    ref
                        .read(cartControllerProvider.notifier)
                        .updateQuantity(
                          lineId: checkoutLine.id,
                          productVariantId: checkoutLine.productVariantId,
                          quantityDelta: 1, // +1
                        );
                  },
                  onDecrement: () {
                    ref
                        .read(cartControllerProvider.notifier)
                        .updateQuantity(
                          lineId: checkoutLine.id,
                          productVariantId: checkoutLine.productVariantId,
                          quantityDelta: -1, // -1
                        );
                  },
                  onInfoTap: () {
                    // Navigate to product detail page
                    final router = GoRouter.of(context);
                    final imageUrl =
                        checkoutLine.productVariantDetails.primaryImageUrl;
                    final uri = Uri(
                      path: '/product/${checkoutLine.productVariantId}',
                      queryParameters: imageUrl != null
                          ? {'imageUrl': imageUrl}
                          : null,
                    );
                    router.push(uri.toString());
                  },
                );

                return shouldAnimate
                    ? AnimatedSlideIn(
                        delay: Duration(milliseconds: index * 100),
                        child: cartItem,
                      )
                    : cartItem;
              },
            ),
          ),

          // Fixed Bill Summary Section
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15.r,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bill Summary
                Builder(
                  builder: (context) {
                    // Calculate discount amount
                    final subtotal = cartState.data!.originalTotal;
                    final discountAmount = couponState.getDiscountAmount(
                      subtotal,
                    );
                    final subtotalAfterDiscount = subtotal - discountAmount;
                    final tax = subtotalAfterDiscount * 0.02;
                    final total = subtotalAfterDiscount + tax;

                    return BillSummary(
                      subtotal: '₹${subtotal.toStringAsFixed(2)}',
                      tax: '₹${tax.toStringAsFixed(2)}',
                      deliveryCharges: 'Free',
                      discount: couponState.hasCoupon && discountAmount > 0
                          ? '-₹${discountAmount.toStringAsFixed(2)}'
                          : null,
                      total: '₹${total.toStringAsFixed(2)}',
                    );
                  },
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),

          // Checkout Button
          _buildCheckoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 90.h,
      padding: EdgeInsets.only(
        top: 30.h,
        left: 20.w,
        right: 20.w,
        bottom: 10.h,
      ),
      decoration: const BoxDecoration(color: Color(0xFF0D5C2E)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Navigate back or to home
              widget.onBackPressed?.call();
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          AppText(
            text: 'Cart',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          // Navigate to address session
          widget.onProceedToAddress?.call();
        },
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: const Color(0xFF25A63E),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Proceed to Checkout',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated slide-in widget for cart items
class AnimatedSlideIn extends StatefulWidget {
  const AnimatedSlideIn({
    required this.child,
    super.key,
    this.delay = Duration.zero,
  });
  final Widget child;
  final Duration delay;

  @override
  State<AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
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
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

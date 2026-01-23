// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/category/models/category_product.dart';

import '../../../../../app/theme/colors.dart';
import '../cart/application/controllers/cart_controller.dart';
import '../wishlist/application/providers/wishlist_providers.dart';
import '../wishlist/application/states/wishlist_state.dart';

const String _rupeeSymbol = '\u20B9';

/// Individual product card displayed in product grid
/// Shows: Image + add-to-cart button | Name, weight, price + wishlist
/// Now integrated with cart backend via CartController
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    required this.product,
    required this.colorScheme,
    super.key,
    this.onAddToCart,
    this.onTap,
    this.index = 0,
  });
  // Static method to trigger animations on all product cards
  static void triggerAnimations() {
    _ProductCardState._pageVisitCount++;
  }

  final CategoryProduct product;
  final ColorScheme colorScheme;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;
  final int index;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with TickerProviderStateMixin {
  static int _pageVisitCount = 0;
  int _myPageVisit = -1;

  bool _showIntroAnimation = false;
  bool _isAddingToCart = false;
  bool _isUpdatingQuantity = false; // Loading state for increment/decrement
  bool _isTogglingWishlist = false; // Loading state for wishlist toggle
  DateTime? _lastUpdateTime; // Throttle rapid taps

  // Sweep animation controller
  late AnimationController _sweepController;
  late Animation<double> _sweepAnimation;

  @override
  void initState() {
    super.initState();

    // Sweep animation for light effect (single slow motion sweep)
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _sweepAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.easeInOut),
    );

    // Trigger animation on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartAnimation();
    });

    // Start periodic check to detect navigation changes
    _startPeriodicCheck();
  }

  // Get cart quantity for this product from cart state
  // Uses ref.watch to listen to real-time cart updates
  int _getCartQuantity() {
    if (!mounted) return 0; // Guard against disposed widget

    // ✅ Use ref.watch instead of ref.read for real-time updates
    final cartState = ref.watch(cartControllerProvider);
    if (cartState.data == null) return 0;

    // Convert variantId string to int for comparison
    final productVariantId = int.tryParse(widget.product.variantId);
    if (productVariantId == null) return 0;

    // Find checkout line matching this product variant
    try {
      final line = cartState.data!.results.firstWhere(
        (line) => line.productVariantId == productVariantId,
      );
      return line.quantity;
    } catch (e) {
      return 0; // Product not in cart
    }
  }

  // Get checkout line ID for this product
  int? _getCheckoutLineId() {
    if (!mounted) return null; // Guard against disposed widget

    final cartState = ref.read(cartControllerProvider);
    if (cartState.data == null) return null;

    final productVariantId = int.tryParse(widget.product.variantId);
    if (productVariantId == null) return null;

    try {
      final line = cartState.data!.results.firstWhere(
        (line) => line.productVariantId == productVariantId,
      );
      return line.id;
    } catch (e) {
      return null;
    }
  }

  void _checkAndStartAnimation() {
    final cartQuantity = _getCartQuantity();

    // Only show intro animation for first 6 products (index 0-5)
    // to reduce render overhead
    if (_myPageVisit != _pageVisitCount &&
        cartQuantity == 0 &&
        mounted &&
        widget.index < 6) {
      _myPageVisit = _pageVisitCount;

      setState(() {
        _showIntroAnimation = true; // Show full "Add" button
      });

      // Reset and start sweep animation once (slow motion)
      _sweepController.reset();
      _sweepController.forward();

      // After 2 seconds, switch to "+" button
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _getCartQuantity() == 0) {
          setState(() {
            _showIntroAnimation = false; // Switch to "+" button
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force check every time widget updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartAnimation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also check on dependencies change (when page becomes visible)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartAnimation();
    });
  }

  // Periodically check if page visit count changed
  void _startPeriodicCheck() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkAndStartAnimation();
        _startPeriodicCheck(); // Check again
      }
    });
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    if (!widget.product.inStock) return;

    final productVariantId = int.tryParse(widget.product.variantId);
    if (productVariantId == null) return;

    setState(() {
      _isAddingToCart = true;
      _showIntroAnimation = false;
    });

    try {
      await ref
          .read(cartControllerProvider.notifier)
          .addToCart(productVariantId: productVariantId, quantity: 1);
      widget.onAddToCart?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _handleDecreaseQuantity() async {
    // Throttle: Prevent rapid successive taps (minimum 300ms between taps)
    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < const Duration(milliseconds: 300)) {
      return; // Ignore tap if too soon after last tap
    }

    if (_isUpdatingQuantity) return; // Prevent multiple simultaneous updates

    final lineId = _getCheckoutLineId();
    final productVariantId = int.tryParse(widget.product.variantId);

    if (lineId == null || productVariantId == null) return;

    setState(() {
      _isUpdatingQuantity = true;
      _lastUpdateTime = now;
    });

    try {
      // Use delta -1 for decrement (API expects delta, not absolute value)
      ref
          .read(cartControllerProvider.notifier)
          .updateQuantity(
            lineId: lineId,
            productVariantId: productVariantId,
            quantityDelta: -1,
          );

      // Wait a bit for the optimistic update to reflect
      await Future.delayed(const Duration(milliseconds: 150));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingQuantity = false;
        });
      }
    }
  }

  Future<void> _handleIncreaseQuantity() async {
    // Throttle: Prevent rapid successive taps (minimum 300ms between taps)
    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < const Duration(milliseconds: 300)) {
      return; // Ignore tap if too soon after last tap
    }

    if (_isUpdatingQuantity) return; // Prevent multiple simultaneous updates

    final lineId = _getCheckoutLineId();
    final productVariantId = int.tryParse(widget.product.variantId);

    if (lineId == null || productVariantId == null) return;

    setState(() {
      _isUpdatingQuantity = true;
      _lastUpdateTime = now;
    });

    try {
      // Use delta +1 for increment (API expects delta, not absolute value)
      ref
          .read(cartControllerProvider.notifier)
          .updateQuantity(
            lineId: lineId,
            productVariantId: productVariantId,
            quantityDelta: 1,
          );

      // Wait a bit for the optimistic update to reflect
      await Future.delayed(const Duration(milliseconds: 150));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingQuantity = false;
        });
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isTogglingWishlist) return;

    setState(() {
      _isTogglingWishlist = true;
    });

    try {
      final productId = widget.product.variantId;
      await ref.read(wishlistProvider.notifier).toggleWishlist(productId);

      // Success - no snackbar needed, UI will update automatically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update wishlist: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingWishlist = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if product is in wishlist
    final wishlistState = ref.watch(wishlistProvider);
    final isInWishlist = wishlistState.isInWishlist(widget.product.variantId);

    final image = widget.product.imageUrl ?? widget.product.thumbnailUrl;
    final formattedWeight = _formatWeight(widget.product.weight);
    final inStock = widget.product.inStock;

    final priceValue = _formatPriceValue(widget.product.price);
    final originalPriceValue = _formatPriceValue(widget.product.originalPrice);

    // Calculate discount percentage if both prices exist
    String? discountText;
    if (priceValue != null &&
        originalPriceValue != null &&
        originalPriceValue != priceValue) {
      final price = double.tryParse(priceValue);
      final originalPrice = double.tryParse(originalPriceValue);
      if (price != null && originalPrice != null && originalPrice > price) {
        final discountPercent = ((originalPrice - price) / originalPrice * 100)
            .round();
        discountText = '$discountPercent% OFF';
      }
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 135.w,
        // constraints: BoxConstraints(
        //   minHeight: 200.h, // Minimum height to ensure content always fits
        // ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                Container(
                  height: 95.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                  ),
                  child: _ProductImage(image: image),
                ),
                // Discount badge (top-left)
                if (discountText != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: ClipPath(
                      clipper: _BadgeClipper(),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 8.w,
                          right: 8.w,
                          top: 6.h,
                          bottom: 10.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFF6B35,
                              ).withValues(alpha: 0.3),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Text(
                          discountText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Wishlist icon (top-right)
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: GestureDetector(
                    onTap: _toggleWishlist,
                    child: Container(
                      width: 34.w,
                      height: 34.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isTogglingWishlist
                            ? SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  color: const Color(0xFFFFA726),
                                ),
                              )
                            : Icon(
                                isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 19.sp,
                                color: isInWishlist
                                    ? const Color(0xFFFF6B6B)
                                    : const Color(0xFFFFA726),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product details with button overlay
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    8.w,
                    4.h,
                    _getCartQuantity() > 0
                        ? 1
                              .w // Quantity selector: minimal right padding
                        : _showIntroAnimation
                        ? 1
                              .w // Full "Add" button: minimal right padding
                        : 9.w, // Small "+" button: more right padding
                    3.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (formattedWeight != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          formattedWeight,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                      SizedBox(height: 3.h),
                      // Price section with button overlay using Stack
                      SizedBox(
                        height: 36.h,
                        child: Stack(
                          children: [
                            // Price takes full width - never truncated
                            Positioned(
                              // top: 1,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Current price (large green) - shown first
                                  if (priceValue != null)
                                    Text(
                                      '$_rupeeSymbol $priceValue',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF25A63E),
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  // Original price (strikethrough) - shown below
                                  if (originalPriceValue != null &&
                                      priceValue != null &&
                                      originalPriceValue != priceValue) ...[
                                    SizedBox(height: 1.h),
                                    Text(
                                      '$_rupeeSymbol $originalPriceValue',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade400,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.grey.shade400,
                                        decorationThickness: 1.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                    SizedBox(height: 4.h),
                                  ],
                                ],
                              ),
                            ),
                            //  SizedBox(height: 4.h),
                            // Button positioned at bottom-right
                            Positioned(
                              // top: 12.h,
                              bottom: 0.h,
                              right: 0.w,
                              child: _getCartQuantity() > 0
                                  ? _buildQuantitySelector()
                                  : _buildAnimatedAddButton(inStock),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Opacity(
      opacity: _isUpdatingQuantity ? 0.6 : 1.0, // Dim when updating
      child: Container(
        height: 26.h,
        // padding: EdgeInsets.symmetric(horizontal: .w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.all(Radius.circular(30.r)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _isUpdatingQuantity ? null : _handleDecreaseQuantity,
              child: Container(
                width: 22.w,
                height: 22.h,
                decoration: BoxDecoration(
                  color: _isUpdatingQuantity
                      ? Colors.grey.shade400
                      : const Color(0xFF25A63E),
                  shape: BoxShape.circle,
                ),
                child: _isUpdatingQuantity
                    ? SizedBox(
                        width: 10.w,
                        height: 10.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.remove, color: Colors.white, size: 12),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                '${_getCartQuantity()}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: _isUpdatingQuantity ? null : _handleIncreaseQuantity,
              child: Container(
                width: 22.w,
                height: 22.h,
                decoration: BoxDecoration(
                  color: _isUpdatingQuantity
                      ? Colors.grey.shade400
                      : const Color(0xFF25A63E),
                  shape: BoxShape.circle,
                ),
                child: _isUpdatingQuantity
                    ? SizedBox(
                        width: 10.w,
                        height: 10.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.add, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAddButton(bool inStock) {
    // Ultra-smooth fade and scale transition between buttons
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: _showIntroAnimation
          ? _buildIntroAddButton(inStock)
          : _buildAddToCartButton(inStock),
    );
  }

  Widget _buildIntroAddButton(bool inStock) {
    return GestureDetector(
      key: const ValueKey('intro_add_button'),
      onTap: inStock && !_isAddingToCart ? _handleAddToCart : null,
      child: Material(
        elevation: 4,
        shadowColor: (inStock ? const Color(0xFF25A63E) : Colors.grey.shade400)
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.r),
          bottomLeft: Radius.circular(6.r),
          bottomRight: Radius.circular(16.r),
        ),
        child: AnimatedBuilder(
          animation: _sweepAnimation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6.r),
                bottomLeft: Radius.circular(6.r),
                bottomRight: Radius.circular(16.r),
              ),
              child: Container(
                height: 30.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  gradient: inStock && !_isAddingToCart
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2BBD4E), Color(0xFF25A63E)],
                        )
                      : null,
                  color: inStock && !_isAddingToCart
                      ? null
                      : Colors.grey.shade400,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Diagonal light sweep effect with multiple beams and blur
                    if (inStock)
                      Positioned(
                        left: -50.w,
                        right: -50.w,
                        top: -20.h,
                        bottom: -20.h,
                        child: Transform.translate(
                          offset: Offset(_sweepAnimation.value * 150.w, 0),
                          child: Transform.rotate(
                            angle: -0.5, // Diagonal angle (\ direction)
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    // First beam (brighter)
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.35),
                                    Colors.white.withValues(alpha: 0.6),
                                    Colors.white.withValues(alpha: 0.35),
                                    Colors.white.withValues(alpha: 0.0),
                                    // Gap
                                    Colors.transparent,
                                    Colors.transparent,
                                    // Second beam (softer)
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.transparent,
                                  ],
                                  stops: const [
                                    0.0,
                                    // First beam
                                    0.12,
                                    0.18,
                                    0.22,
                                    0.26,
                                    0.32,
                                    // Gap
                                    0.38,
                                    0.52,
                                    // Second beam
                                    0.58,
                                    0.64,
                                    0.68,
                                    0.72,
                                    0.78,
                                    1.0,
                                  ],
                                ),
                                boxShadow: [
                                  // Blur/glow effect
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 8.r,
                                    spreadRadius: 2.r,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Button content
                    Center(
                      child: _isAddingToCart
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 15.sp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 7.w),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(bool inStock) {
    return GestureDetector(
      key: const ValueKey('add_to_cart_button'),
      onTap: inStock && !_isAddingToCart ? _handleAddToCart : null,
      child: Material(
        elevation: 4,
        shadowColor: (inStock ? const Color(0xFF25A63E) : Colors.grey.shade400)
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.r),
          topRight: Radius.circular(6.r),
          bottomLeft: Radius.circular(6.r),
          bottomRight: Radius.circular(16.r), // Match card's corner
        ),
        child: Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            gradient: inStock && !_isAddingToCart
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2BBD4E), Color(0xFF25A63E)],
                  )
                : null,
            color: inStock && !_isAddingToCart ? null : Colors.grey.shade400,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6.r),
              topRight: Radius.circular(6.r),
              bottomLeft: Radius.circular(6.r),
              bottomRight: Radius.circular(16.r), // Match card's corner
            ),
          ),
          child: Center(
            child: _isAddingToCart
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Icon(
                    Icons.add,
                    size: 22.sp,
                    color: Colors.white,
                    weight: 700,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return Container(
        color: const Color.fromARGB(189, 239, 244, 235),
        alignment: Alignment.center,
        child: const Icon(
          Icons.local_grocery_store_outlined,
          size: 28,
          color: AppColors.green100,
        ),
      );
    }

    if (image!.startsWith('assets/')) {
      return Image.asset(
        image!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    return Image(
      image: NetworkImage(image!, headers: {'User-Agent': 'Mozilla/5.0'}),
      fit: BoxFit.fitHeight,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color.fromARGB(189, 239, 244, 235),
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green100),
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.green10,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 28,
        color: AppColors.green100,
      ),
    );
  }
}

String? _formatWeight(String? weight) {
  if (weight == null) return null;

  final trimmed = weight.trim();
  if (trimmed.isEmpty) return null;

  final numeric = double.tryParse(trimmed);
  if (numeric != null) {
    final value = numeric % 1 == 0
        ? numeric.toInt().toString()
        : _trimTrailingZeros(numeric.toStringAsFixed(2));
    return '$value g';
  }

  final hasUnit = RegExp('[A-Za-z]').hasMatch(trimmed);
  if (hasUnit) {
    return trimmed;
  }

  return '$trimmed g';
}

String? _formatPriceValue(String? price) {
  if (price == null) return null;

  final trimmed = price.trim();
  if (trimmed.isEmpty) return null;

  var normalized = trimmed;
  if (normalized.startsWith(_rupeeSymbol)) {
    normalized = normalized.substring(_rupeeSymbol.length).trim();
  }

  if (normalized.isEmpty) return null;
  if (normalized.toUpperCase() == 'N/A') return null;

  final numeric = double.tryParse(normalized.replaceAll(',', ''));
  if (numeric != null) {
    return numeric % 1 == 0
        ? numeric.toInt().toString()
        : _trimTrailingZeros(numeric.toStringAsFixed(2));
  }

  return normalized;
}

String _trimTrailingZeros(String value) {
  return value.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// Custom clipper for the discount badge with arrow shape
class _BadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

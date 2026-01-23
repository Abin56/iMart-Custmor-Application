// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/colors.dart';
import '../../../cart/application/controllers/cart_controller.dart';
import '../../application/providers/wishlist_providers.dart';
import '../../domain/entities/wishlist_item.dart';

const String _rupeeSymbol = '\u20B9';

/// Dedicated product card for wishlist screen
/// Matches exact UI from category page ProductCard
class WishlistProductCard extends ConsumerStatefulWidget {
  const WishlistProductCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final WishlistItem item;
  final VoidCallback? onTap;

  @override
  ConsumerState<WishlistProductCard> createState() =>
      _WishlistProductCardState();
}

class _WishlistProductCardState extends ConsumerState<WishlistProductCard>
    with TickerProviderStateMixin {
  bool _showIntroAnimation = false;
  bool _isAddingToCart = false;
  bool _isUpdatingQuantity = false;
  bool _isTogglingWishlist = false;
  DateTime? _lastUpdateTime;

  // Sweep animation controller
  late AnimationController _sweepController;
  late Animation<double> _sweepAnimation;

  @override
  void initState() {
    super.initState();

    // Sweep animation for light effect
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _sweepAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  int _getCartQuantity() {
    if (!mounted) return 0;

    final cartState = ref.watch(cartControllerProvider);
    if (cartState.data == null) return 0;

    final productVariantId = int.tryParse(widget.item.productId);
    if (productVariantId == null) return 0;

    try {
      final line = cartState.data!.results.firstWhere(
        (line) => line.productVariantId == productVariantId,
      );
      return line.quantity;
    } catch (e) {
      return 0;
    }
  }

  int? _getCheckoutLineId() {
    if (!mounted) return null;

    final cartState = ref.read(cartControllerProvider);
    if (cartState.data == null) return null;

    final productVariantId = int.tryParse(widget.item.productId);
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

  Future<void> _handleAddToCart() async {
    final productVariantId = int.tryParse(widget.item.productId);
    if (productVariantId == null) return;

    setState(() {
      _isAddingToCart = true;
      _showIntroAnimation = false;
    });

    try {
      await ref
          .read(cartControllerProvider.notifier)
          .addToCart(productVariantId: productVariantId, quantity: 1);
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
    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < const Duration(milliseconds: 300)) {
      return;
    }

    if (_isUpdatingQuantity) return;

    final lineId = _getCheckoutLineId();
    final productVariantId = int.tryParse(widget.item.productId);

    if (lineId == null || productVariantId == null) return;

    setState(() {
      _isUpdatingQuantity = true;
      _lastUpdateTime = now;
    });

    try {
      ref
          .read(cartControllerProvider.notifier)
          .updateQuantity(
            lineId: lineId,
            productVariantId: productVariantId,
            quantityDelta: -1,
          );

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
    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < const Duration(milliseconds: 300)) {
      return;
    }

    if (_isUpdatingQuantity) return;

    final lineId = _getCheckoutLineId();
    final productVariantId = int.tryParse(widget.item.productId);

    if (lineId == null || productVariantId == null) return;

    setState(() {
      _isUpdatingQuantity = true;
      _lastUpdateTime = now;
    });

    try {
      ref
          .read(cartControllerProvider.notifier)
          .updateQuantity(
            lineId: lineId,
            productVariantId: productVariantId,
            quantityDelta: 1,
          );

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

  Future<void> _handleRemoveFromWishlist() async {
    if (_isTogglingWishlist) return;

    setState(() {
      _isTogglingWishlist = true;
    });

    try {
      await ref
          .read(wishlistProvider.notifier)
          .removeFromWishlist(widget.item.id.toString());

      // Success - item removed via optimistic update, no snackbar needed
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove from wishlist: $e'),
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
    final image = widget.item.imageUrl;
    final formattedWeight = widget.item.unitLabel;
    final hasDiscount = widget.item.hasDiscount;

    final priceValue = widget.item.displayPrice.toString();
    final originalPriceValue = hasDiscount ? widget.item.mrp.toString() : null;

    // Discount percentage
    String? discountText;
    if (hasDiscount) {
      discountText = '${widget.item.discountPct}% OFF';
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 135.w,
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
                // Wishlist icon (top-right) - Always filled red in wishlist
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: GestureDetector(
                    onTap: _handleRemoveFromWishlist,
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
                                  color: const Color(0xFFFF6B6B),
                                ),
                              )
                            : Icon(
                                Icons.favorite,
                                size: 19.sp,
                                color: const Color(0xFFFF6B6B),
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
                        ? 1.w
                        : _showIntroAnimation
                        ? 1.w
                        : 9.w,
                    3.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        widget.item.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (formattedWeight.isNotEmpty) ...[
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
                      // Price section with button overlay
                      SizedBox(
                        height: 36.h,
                        child: Stack(
                          children: [
                            // Price takes full width
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Current price (large green)
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
                                  // Original price (strikethrough)
                                  if (originalPriceValue != null) ...[
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
                            // Button positioned at bottom-right
                            Positioned(
                              bottom: 0.h,
                              right: 0.w,
                              child: _getCartQuantity() > 0
                                  ? _buildQuantitySelector()
                                  : _buildAnimatedAddButton(),
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
      opacity: _isUpdatingQuantity ? 0.6 : 1.0,
      child: Container(
        height: 26.h,
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

  Widget _buildAnimatedAddButton() {
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
          ? _buildIntroAddButton()
          : _buildAddToCartButton(),
    );
  }

  Widget _buildIntroAddButton() {
    return GestureDetector(
      key: const ValueKey('intro_add_button'),
      onTap: !_isAddingToCart ? _handleAddToCart : null,
      child: Material(
        elevation: 4,
        shadowColor: const Color(0xFF25A63E).withValues(alpha: 0.35),
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
                  gradient: !_isAddingToCart
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2BBD4E), Color(0xFF25A63E)],
                        )
                      : null,
                  color: !_isAddingToCart ? null : Colors.grey.shade400,
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return GestureDetector(
      key: const ValueKey('add_to_cart_button'),
      onTap: !_isAddingToCart ? _handleAddToCart : null,
      child: Material(
        elevation: 4,
        shadowColor: const Color(0xFF25A63E).withValues(alpha: 0.35),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.r),
          topRight: Radius.circular(6.r),
          bottomLeft: Radius.circular(6.r),
          bottomRight: Radius.circular(16.r),
        ),
        child: Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            gradient: !_isAddingToCart
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2BBD4E), Color(0xFF25A63E)],
                  )
                : null,
            color: !_isAddingToCart ? null : Colors.grey.shade400,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6.r),
              topRight: Radius.circular(6.r),
              bottomLeft: Radius.circular(6.r),
              bottomRight: Radius.circular(16.r),
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

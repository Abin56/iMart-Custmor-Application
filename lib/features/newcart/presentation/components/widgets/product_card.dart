import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/colors.dart';
import '../../../models/category_product.dart';

const String _rupeeSymbol = '\u20B9';

/// Individual product card displayed in product grid
/// Shows: Image + add-to-cart button | Name, weight, price + wishlist
/// Static version with hardcoded cart quantity state
class ProductCard extends StatefulWidget {
  // Static method to trigger animations on all product cards
  static void triggerAnimations() {
    _ProductCardState._pageVisitCount++;
  }
  const ProductCard({
    super.key,
    required this.product,
    required this.colorScheme,
    this.onAddToCart,
    this.onTap,
  });

  final CategoryProduct product;
  final ColorScheme colorScheme;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  static int _pageVisitCount = 0;
  int _myPageVisit = -1;

  int _cartQuantity = 0;
  bool _isInWishlist = false;
  bool _showIntroAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Increased duration to see animation better
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Trigger animation on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartAnimation();
    });

    // DISABLED: Periodic check causes too many logs
    // _startPeriodicCheck();
  }

  void _checkAndStartAnimation() {
    // Show "Add" button for 2 seconds, then switch to "+" button (no animation)
    if (_myPageVisit != _pageVisitCount && _cartQuantity == 0 && mounted) {
      _myPageVisit = _pageVisitCount;

      setState(() {
        _showIntroAnimation = true; // Show full "Add" button
      });

      // After 2 seconds, switch to "+" button
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _cartQuantity == 0) {
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
    _animationController.dispose();
    super.dispose();
  }

  void _handleAddToCart() {
    if (!widget.product.inStock) return;
    setState(() {
      _cartQuantity = 1;
      _showIntroAnimation = false;
    });
    widget.onAddToCart?.call();
  }

  void _handleDecreaseQuantity() {
    setState(() {
      _cartQuantity--;
    });
  }

  void _handleIncreaseQuantity() {
    setState(() {
      _cartQuantity++;
    });
  }

  void _toggleWishlist() {
    setState(() {
      _isInWishlist = !_isInWishlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.product.imageUrl ?? widget.product.thumbnailUrl;
    final formattedWeight = _formatWeight(widget.product.weight);
    final inStock = widget.product.inStock;

    final priceValue = _formatPriceValue(widget.product.price);
    final originalPriceValue = _formatPriceValue(widget.product.originalPrice);

    // Calculate discount percentage if both prices exist
    String? discountText;
    if (priceValue != null && originalPriceValue != null && originalPriceValue != priceValue) {
      final price = double.tryParse(priceValue);
      final originalPrice = double.tryParse(originalPriceValue);
      if (price != null && originalPrice != null && originalPrice > price) {
        final discountPercent = ((originalPrice - price) / originalPrice * 100).round();
        discountText = '$discountPercent% OFF';
      }
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 135.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.2,
          ),
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
                            colors: [
                              Color(0xFFFF8C42),
                              Color(0xFFFF6B35),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
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
                        child: Icon(
                          _isInWishlist ? Icons.favorite : Icons.favorite_border,
                          size: 19.sp,
                          color: _isInWishlist
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
                  padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        widget.product.variantName,
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
                        height: 35.h,
                        child: Stack(
                          children: [
                            // Price takes full width - never truncated
                            Positioned(
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
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                  // Original price (strikethrough) - shown below
                                  if (originalPriceValue != null &&
                                      priceValue != null &&
                                      originalPriceValue != priceValue) ...[
                                    SizedBox(height: 2.h),
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
                                  ],
                                ],
                              ),
                            ),

                            // Button positioned at bottom-right
                            Positioned(
                              bottom: 0,
                              right: 0.w,
                              child: _cartQuantity > 0
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
    return Container(
      height: 26.h,
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.all(Radius.circular(30.r))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _handleDecreaseQuantity,
            child: Container(
              width: 22.w,
              height: 22.h,
              decoration: const BoxDecoration(
                color: Color(0xFF25A63E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              '$_cartQuantity',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleIncreaseQuantity,
            child: Container(
              width: 22.w,
              height: 22.h,
              decoration: const BoxDecoration(
                color: Color(0xFF25A63E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAddButton(bool inStock) {
    // No animation - just switch between buttons directly
    if (_showIntroAnimation) {
      return _buildIntroAddButton(inStock); // Show full "Add" button
    } else {
      return _buildAddToCartButton(inStock); // Show "+" button
    }
  }

  Widget _buildIntroAddButton(bool inStock) {
    return GestureDetector(
      onTap: inStock ? _handleAddToCart : null,
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          gradient: inStock
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2BBD4E),
                    Color(0xFF25A63E),
                  ],
                )
              : null,
          color: inStock ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.r),
            topRight: Radius.circular(6.r),
            bottomLeft: Radius.circular(6.r),
            bottomRight: Radius.circular(16.r), // Match card's corner
          ),
          boxShadow: [
            BoxShadow(
              color: (inStock ? const Color(0xFF25A63E) : Colors.grey.shade400)
                  .withValues(alpha: 0.35),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
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
    );
  }

  Widget _buildAddToCartButton(bool inStock) {
    return GestureDetector(
      onTap: inStock ? _handleAddToCart : null,
      child: Container(
        width: 30.w,
        height: 30.h,
        decoration: BoxDecoration(
          gradient: inStock
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2BBD4E),
                    Color(0xFF25A63E),
                  ],
                )
              : null,
          color: inStock ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.r),
            topRight: Radius.circular(6.r),
            bottomLeft: Radius.circular(6.r),
            bottomRight: Radius.circular(16.r), // Match card's corner
          ),
          boxShadow: [
            BoxShadow(
              color: (inStock ? const Color(0xFF25A63E) : Colors.grey.shade400)
                  .withValues(alpha: 0.35),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 22.sp,
            color: Colors.white,
            weight: 700,
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

  final hasUnit = RegExp(r'[A-Za-z]').hasMatch(trimmed);
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

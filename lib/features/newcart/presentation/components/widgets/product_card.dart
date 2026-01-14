import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/colors.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../models/category_product.dart';

const String _rupeeSymbol = '\u20B9';

/// Individual product card displayed in product grid
/// Shows: Image + add-to-cart button | Name, weight, price + wishlist
/// Static version with hardcoded cart quantity state
class ProductCard extends StatefulWidget {
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

class _ProductCardState extends State<ProductCard> {
  int _cartQuantity = 0;
  bool _isInWishlist = false;

  void _handleAddToCart() {
    if (!widget.product.inStock) return;
    setState(() {
      _cartQuantity = 1;
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
    final quantity = widget.product.currentQuantity ?? 0;

    final priceValue = _formatPriceValue(widget.product.price);
    final originalPriceValue = _formatPriceValue(widget.product.originalPrice);

    final showStockBadge = widget.product.currentQuantity != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 171.h,
        width: 129.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: widget.colorScheme.shadow.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10.r),
                        ),
                        color: AppColors.white,
                      ),
                      child: ClipRRect(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _ProductImage(image: image),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4.h,
                    right: 4.w,
                    child: _cartQuantity > 0
                        ? _QuantitySelector(
                            quantity: _cartQuantity,
                            onDecrease: _handleDecreaseQuantity,
                            onIncrease: _handleIncreaseQuantity,
                          )
                        : _AnimatedAddButton(
                            onTap: _handleAddToCart,
                            primaryColor:
                                inStock ? AppColors.green : AppColors.grey,
                            isEnabled: inStock,
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.pageTitle(
                    text: widget.product.variantName,
                    maxLines: 1,
                  ),
                  AppSpacing.h8,
                  if (formattedWeight != null)
                    AppText(
                      text: formattedWeight,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  if (formattedWeight != null) AppSpacing.h8,
                  Row(
                    children: [
                      if (priceValue != null) ...[
                        const AppText.pageTitle(text: _rupeeSymbol),
                        AppSpacing.w4,
                        AppText.pageTitle(text: priceValue),
                        if (originalPriceValue != null &&
                            originalPriceValue != priceValue) ...[
                          AppSpacing.w8,
                          AppText(
                            text: '$_rupeeSymbol$originalPriceValue',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ],
                      ] else ...[
                        const AppText.pageTitle(text: 'N/A'),
                      ],
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleWishlist,
                        child: Icon(
                          _isInWishlist
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 22.sp,
                          color:
                              _isInWishlist ? Colors.red : AppColors.green100,
                        ),
                      ),
                    ],
                  ),
                  if (showStockBadge) ...[
                    AppSpacing.h4,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: inStock
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: AppText(
                        text: inStock
                            ? quantity > 0
                                ? 'In Stock'
                                : 'Only $quantity left'
                            : 'Out of Stock',
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: inStock ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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

class _AnimatedAddButton extends StatefulWidget {
  const _AnimatedAddButton({
    required this.onTap,
    required this.primaryColor,
    this.isEnabled = true,
  });

  final VoidCallback onTap;
  final Color primaryColor;
  final bool isEnabled;

  @override
  State<_AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<_AnimatedAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isEnabled) return;
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.isEnabled ? 1.0 : 0.5,
              child: Container(
                width: 29.w,
                height: 29.w,
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withValues(
                      alpha:
                          widget.isEnabled ? _glowAnimation.value * 0.8 : 0.3,
                    ),
                    width: 2.5 * (widget.isEnabled ? _glowAnimation.value : 0.5),
                  ),
                  boxShadow: widget.isEnabled
                      ? [
                          BoxShadow(
                            color: widget.primaryColor.withValues(
                              alpha: 0.3 + (_glowAnimation.value * 0.4),
                            ),
                            blurRadius: 4 + (_glowAnimation.value * 8),
                            spreadRadius: _glowAnimation.value * 2,
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add, color: AppColors.white, size: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrease,
            child: Container(
              width: 29.w,
              height: 29.h,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, color: AppColors.white, size: 18),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: AppText(
              text: quantity.toString(),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          GestureDetector(
            onTap: onIncrease,
            child: Container(
              width: 29.w,
              height: 29.h,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

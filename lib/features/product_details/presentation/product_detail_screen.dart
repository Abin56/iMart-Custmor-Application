// ignore_for_file: cascade_invocations

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/app/theme/colors.dart';
import 'package:imart/features/cart/application/controllers/cart_controller.dart';
import 'package:imart/features/navigation/main_navbar.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../application/providers/product_detail_provider.dart';
import '../domain/entities/complete_product_detail.dart';

/// Product Detail Screen with Backend Integration
/// Features:
/// - HTTP 304 caching for optimal performance
/// - Real-time stock updates (30-second polling)
/// - Wishlist integration
/// - Image carousel with navigation
/// - Dynamic pricing and quantity management
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({
    required this.variantId,
    this.fallbackImageUrl,
    super.key,
  });

  final int variantId;
  final String? fallbackImageUrl;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool _isAddingToCart = false;
  bool _isUpdatingQuantity = false;
  DateTime? _lastUpdateTime;

  /// Get cart quantity for this product from cart state
  int _getCartQuantity() {
    if (!mounted) return 0;

    final cartState = ref.watch(cartControllerProvider);
    if (cartState.data == null) return 0;

    try {
      final line = cartState.data!.results.firstWhere(
        (line) => line.productVariantId == widget.variantId,
      );
      return line.quantity;
    } catch (e) {
      return 0; // Not in cart
    }
  }

  /// Get checkout line ID for this product
  int? _getCheckoutLineId() {
    if (!mounted) return null;

    final cartState = ref.read(cartControllerProvider);
    if (cartState.data == null) return null;

    try {
      final line = cartState.data!.results.firstWhere(
        (line) => line.productVariantId == widget.variantId,
      );
      return line.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleAddToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      await ref
          .read(cartControllerProvider.notifier)
          .addToCart(productVariantId: widget.variantId, quantity: 1);
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

  Future<void> _handleIncreaseQuantity() async {
    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < const Duration(milliseconds: 300)) {
      return;
    }

    if (_isUpdatingQuantity) return;

    final lineId = _getCheckoutLineId();
    if (lineId == null) return;

    setState(() {
      _isUpdatingQuantity = true;
      _lastUpdateTime = now;
    });

    try {
      ref
          .read(cartControllerProvider.notifier)
          .updateQuantity(
            lineId: lineId,
            productVariantId: widget.variantId,
            quantityDelta: 1,
          );

      await Future.delayed(const Duration(milliseconds: 150));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
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

  Future<void> _handleDecreaseQuantity() async {
    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < const Duration(milliseconds: 300)) {
      return;
    }

    if (_isUpdatingQuantity) return;

    final lineId = _getCheckoutLineId();
    if (lineId == null) return;

    setState(() {
      _isUpdatingQuantity = true;
      _lastUpdateTime = now;
    });

    try {
      ref
          .read(cartControllerProvider.notifier)
          .updateQuantity(
            lineId: lineId,
            productVariantId: widget.variantId,
            quantityDelta: -1,
          );

      await Future.delayed(const Duration(milliseconds: 150));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
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

  /// Add https:// protocol to image URL if missing
  String _getImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productDetailProvider(widget.variantId));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: productState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (product) => _buildContent(product: product),
        refreshing: (product) =>
            _buildContent(product: product, isRefreshing: true),
        wishlistToggling: (product) =>
            _buildContent(product: product, isTogglingWishlist: true),
        error: (failure, previousProduct) {
          // Show error UI with option to retry
          if (previousProduct != null) {
            // Show previous data with error snackbar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () => ref
                        .read(productDetailProvider(widget.variantId).notifier)
                        .refresh(),
                  ),
                ),
              );
            });
            return _buildContent(product: previousProduct);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  failure.message,
                  style: TextStyle(fontSize: 16.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => ref
                      .read(productDetailProvider(widget.variantId).notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required CompleteProductDetail product,
    bool isRefreshing = false,
    bool isTogglingWishlist = false,
  }) {
    final variant = product.variant;
    final base = product.base;

    return Stack(
      children: [
        Column(
          children: [
            // Image carousel section
            _buildImageCarousel(
              media: variant.media,
              fallbackImageUrl: widget.fallbackImageUrl,
              isWishlisted: variant.isWishlisted,
              isTogglingWishlist: isTogglingWishlist,
            ),

            // Product details section with pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(productDetailProvider(widget.variantId).notifier)
                      .refresh();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      _buildProductDetails(
                        variantName: variant.name,
                        price: variant.effectivePrice,
                        originalPrice: variant.hasDiscount
                            ? variant.price
                            : null,
                        discountPercent: variant.discountPercentage,
                        averageRating: variant.averageRating,
                        reviewCount: variant.reviewCount,
                        description: variant.description ?? base.description,
                        stock: variant.stock,
                        stockUnit: variant.stockUnit ?? variant.unit ?? 'units',
                        unit: variant.unit ?? 'units',
                        weight: variant.weight,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Add to Basket button
            _buildAddToBasketButton(
              isInStock: variant.isInStock,
              stock: variant.stock,
            ),
          ],
        ),

        // Refreshing indicator
        if (isRefreshing)
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Updating...',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageCarousel({
    required List media,
    required bool isWishlisted,
    String? fallbackImageUrl,
    bool isTogglingWishlist = false,
  }) {
    // Check if media has items
    final hasMedia = media.isNotEmpty;

    return Container(
      height: 320.h,
      decoration: const BoxDecoration(color: Color(0xFF0D5C2E)),
      child: Stack(
        children: [
          // Main product image with decorative arc
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 80.h),
              width: double.infinity,
              height: 300.h,
              color: Colors.white.withValues(
                alpha: 0.1,
              ), // Slight background to see container
              child: Stack(
                children: [
                  // Decorative arc overlay - at bottom layer
                  CustomPaint(
                    size: Size(double.infinity, 100.h),
                    painter: _CurvedArcPainter(),
                  ),

                  // Product image or placeholder - on top of arc
                  if (hasMedia)
                    Builder(
                      builder: (context) {
                        final imageUrl = _getImageUrl(
                          media[_currentImageIndex].url,
                        );

                        return Image.network(
                          imageUrl,
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                                strokeWidth: 3.w,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Image.asset(
                                'assets/images/no-image.png',
                                width: 100.w,
                                height: 100.h,
                              ),
                            );
                          },
                        );
                      },
                    )
                  else
                    Center(
                      child: Image.asset(
                        'assets/images/no-image.png',
                        width: 100.w,
                        height: 100.h,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 30.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 24.sp,
                  color: AppColors.black,
                ),
              ),
            ),
          ),

          // Favorite button with wishlist integration
          Positioned(
            top: 30.h,
            right: 20.w,
            child: GestureDetector(
              onTap: isTogglingWishlist
                  ? null
                  : () {
                      ref
                          .read(
                            productDetailProvider(widget.variantId).notifier,
                          )
                          .toggleWishlist();
                    },
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C4A3A),
                  shape: BoxShape.circle,
                ),
                child: isTogglingWishlist
                    ? Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      )
                    : Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 24.sp,
                        color: isWishlisted ? Colors.red : Colors.white,
                      ),
              ),
            ),
          ),

          // Left navigation arrow
          if (media.length > 1)
            Positioned(
              left: 20.w,
              top: 200.h,
              child: GestureDetector(
                onTap: () {
                  if (_currentImageIndex > 0) {
                    setState(() {
                      _currentImageIndex--;
                    });
                  }
                },
                child: Icon(
                  Icons.chevron_left,
                  size: 40.sp,
                  color: Colors.black,
                ),
              ),
            ),

          // Right navigation arrow
          if (media.length > 1)
            Positioned(
              right: 20.w,
              top: 200.h,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentImageIndex =
                        (_currentImageIndex + 1) % media.length;
                  });
                },
                child: Icon(
                  Icons.chevron_right,
                  size: 40.sp,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductDetails({
    required String variantName,
    required double price,
    required int reviewCount,
    required int stock,
    required String stockUnit,
    required String unit,
    double? originalPrice,
    double? discountPercent,
    double? averageRating,
    String? description,
    double? weight,
  }) {
    return ClipPath(
      clipper: _BottomShadowClipper(),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.r),
            topRight: Radius.circular(40.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    text: variantName,
                    fontSize: 30.sp,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(width: 16.w),
                // Unit display
                Container(
                  height: 35.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF25A63E)),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unit: ',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        weight != null
                            ? '${weight.toStringAsFixed(2)} $unit'
                            : unit,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF25A63E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Stock indicator
            Row(
              children: [
                Icon(
                  stock > 10
                      ? Icons.check_circle
                      : stock > 0
                      ? Icons.warning
                      : Icons.cancel,
                  size: 16.sp,
                  color: stock > 10
                      ? Colors.green
                      : stock > 0
                      ? Colors.orange
                      : Colors.red,
                ),
                SizedBox(width: 6.w),
                Text(
                  stock > 10
                      ? 'In Stock'
                      : stock > 0
                      ? 'Only $stock left'
                      : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: stock > 10
                        ? Colors.green
                        : stock > 0
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Price section
            AppText(
              text: 'Price',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                if (originalPrice != null) ...[
                  Text(
                    '₹${originalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Text(
                  '₹${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF25A63E),
                  ),
                ),
                if (discountPercent != null) ...[
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${discountPercent.toStringAsFixed(0)}% OFF',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 16.h),

            // Rating
            if (averageRating != null)
              Row(
                children: [
                  Icon(Icons.star, size: 24.sp, color: Colors.amber),
                  SizedBox(width: 8.w),
                  AppText(
                    text: averageRating.toStringAsFixed(1),
                    fontSize: 18.sp,
                    color: AppColors.black,
                  ),
                  SizedBox(width: 4.w),
                  AppText(
                    text: '($reviewCount reviews)',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                  ),
                ],
              ),

            SizedBox(height: 24.h),

            // Description
            if (description != null)
              Text(
                description,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black,
                  height: 1.6,
                ),
              ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToBasketButton({
    required bool isInStock,
    required int stock,
  }) {
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
      child: !isInStock
          ? Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Center(
                child: AppText(
                  text: 'Out of Stock',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : _getCartQuantity() == 0
          ? GestureDetector(
              onTap: _isAddingToCart ? null : _handleAddToCart,
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D5C2E),
                  borderRadius: BorderRadius.circular(50.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D5C2E).withValues(alpha: 0.3),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: _isAddingToCart
                    ? Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          AppText(
                            text: 'Add to Basket',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            )
          : Opacity(
              opacity: _isUpdatingQuantity ? 0.6 : 1.0,
              child: Row(
                children: [
                  // Minus button
                  GestureDetector(
                    onTap: _isUpdatingQuantity ? null : _handleDecreaseQuantity,
                    child: Container(
                      width: 35.w,
                      height: 35.w,
                      decoration: BoxDecoration(
                        color: _isUpdatingQuantity
                            ? Colors.grey.shade300
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isUpdatingQuantity
                              ? Colors.grey.shade400
                              : const Color(0xFF0D5C2E),
                          width: 2.w,
                        ),
                      ),
                      child: _isUpdatingQuantity
                          ? Center(
                              child: SizedBox(
                                width: 18.w,
                                height: 18.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0D5C2E),
                                  ),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.remove,
                              color: const Color(0xFF0D5C2E),
                              size: 22.sp,
                            ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Quantity display
                  Container(
                    width: 38.w,
                    height: 35.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFF0D5C2E),
                        width: 1.w,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${_getCartQuantity()}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0D5C2E),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Plus button
                  GestureDetector(
                    onTap: _isUpdatingQuantity
                        ? null
                        : () {
                            // Don't allow adding more than available stock
                            if (_getCartQuantity() < stock) {
                              _handleIncreaseQuantity();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Only $stock items available'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                    child: Container(
                      width: 35.w,
                      height: 35.w,
                      decoration: BoxDecoration(
                        color: _isUpdatingQuantity
                            ? Colors.grey.shade300
                            : const Color(0xFF0D5C2E),
                        shape: BoxShape.circle,
                      ),
                      child: _isUpdatingQuantity
                          ? Center(
                              child: SizedBox(
                                width: 18.w,
                                height: 18.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Icon(Icons.add, color: Colors.white, size: 22.sp),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // View Basket button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Pop back to main navigation
                        Navigator.of(context).pop();
                        // Use post-frame callback to navigate to cart after pop completes
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Navigate to cart tab (index 2) using the global key
                          MainNavigationShell.globalKey.currentState
                              ?.navigateToTab(3);
                        });
                      },
                      child: Container(
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D5C2E),
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                            SizedBox(width: 8.w),
                            AppText(
                              text: 'View Basket',
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Custom painter for the curved arc decoration on the white circle
class _CurvedArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final imageWidth = size.width * 0.59;
    final radius = imageWidth * 1.8;
    final centerX = size.width / 2;
    final centerY = radius * 0.9;

    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      math.pi * 1.29,
      math.pi * 1.64,
    );

    canvas.drawPath(path, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom clipper to hide bottom shadow
class _BottomShadowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(-20, -20);
    path.lineTo(size.width + 20, -20);
    path.lineTo(size.width + 20, size.height);
    path.lineTo(-20, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

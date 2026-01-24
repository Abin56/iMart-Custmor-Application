import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:imart/app/theme/app_spacing.dart';
import 'package:imart/app/theme/colors.dart';
import 'package:imart/features/cart/application/controllers/cart_controller.dart';
import 'package:imart/features/category/application/providers/cart_data_provider.dart';
import 'package:imart/features/category/application/providers/cart_filter_provider.dart';
import 'package:imart/features/category/application/providers/cart_paginated_provider.dart';
import 'package:imart/features/category/application/providers/cart_search_provider.dart';
import 'package:imart/features/category/application/providers/recent_search_provider.dart';
import 'package:imart/features/category/application/providers/selected_category_provider.dart';
import 'package:imart/features/category/domain/entities/category.dart';
import 'package:imart/features/category/models/category_item.dart';
import 'package:imart/features/navigation/main_navbar.dart';
import 'package:imart/features/home/application/providers/home_data_provider.dart';
import 'package:imart/features/home/domain/entities/product_variant.dart';
import 'package:imart/features/home/presentation/components/home_top_section_ui.dart';
import 'package:imart/features/home/presentation/components/live_order_tracking_banner.dart';
import 'package:imart/features/profile/application/providers/order_provider.dart';
import 'package:imart/features/profile/application/states/order_state.dart';
import 'package:imart/features/profile/presentation/components/pending_rating_dialog.dart';
import 'package:imart/features/profile/presentation/profile.dart';
import 'package:imart/features/widgets/app_text.dart';
import 'package:imart/features/wishlist/application/providers/wishlist_providers.dart';

/// Home Screen Content without bottom navigation bar
/// Used inside MainNavigationShell
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasCheckedPendingRating = false;

  @override
  void initState() {
    super.initState();
    // Load orders to check for pending ratings
    Future.microtask(() {
      ref.read(orderProvider.notifier);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for pending ratings after the first build
    if (!_hasCheckedPendingRating) {
      _hasCheckedPendingRating = true;
      // Start listening for orders to be loaded
      _waitForOrdersAndCheckRatings();
    }
  }

  /// Wait for orders to be loaded, then check for pending ratings
  Future<void> _waitForOrdersAndCheckRatings() async {
    // Wait a bit to let the widget settle
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Check current order state
    final orderState = ref.read(orderProvider);

    // If orders are already loaded, check immediately
    if (orderState is OrderLoaded ||
        orderState is OrderItemsLoading ||
        orderState is OrderItemsLoaded) {
      await _checkPendingRatings();
      return;
    }

    // If still loading or initial, wait and poll for up to 10 seconds
    for (var i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final currentState = ref.read(orderProvider);
      if (currentState is OrderLoaded ||
          currentState is OrderItemsLoading ||
          currentState is OrderItemsLoaded) {
        // Add small delay to ensure state is stable
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          await _checkPendingRatings();
        }
        return;
      }
    }
  }

  Future<void> _checkPendingRatings() async {
    // Invalidate the provider to ensure fresh check
    ref.invalidate(pendingRatingOrderProvider);
    await showPendingRatingDialogIfNeeded(context, ref);
  }

  /// Convert Category entity to CategoryItem for UI
  List<CategoryItem> _convertCategoriesToItems(List<Category> categories) {
    return categories.map((cat) {
      return CategoryItem(
        id: cat.id.toString(),
        title: cat.name,
        imageUrl: cat.image,
      );
    }).toList();
  }

  void _showSearchBottomSheet(BuildContext context, List<Category> categories) {
    final categoryItems = _convertCategoriesToItems(categories);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchBottomSheet(categories: categoryItems),
    );
  }

  /// Navigate to discounted products (Best Deals)
  void _navigateToDiscountedProducts() {
    final discountedProducts = ref.read(discountedProductsProvider);
    discountedProducts.whenData((products) {
      if (products.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _ProductListBottomSheet(
            title: 'Best Deals',
            products: products,
          ),
        );
      }
    });
  }

  /// Navigate to offer products (Mega Fresh offers)
  void _navigateToOfferProducts() {
    final offerProducts = ref.read(offerCategoryProductsProvider);
    offerProducts.whenData((products) {
      if (products.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _OfferProductListBottomSheet(
            title: 'Mega Fresh Offers',
            products: products,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const ProfileDrawer(), // Add profile drawer
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section (green background + categories)
                HomeTopSectionUI(
                  onCategoryTap: (category) {
                    // Set the selected category ID in the provider
                    ref
                        .read(selectedCategoryProvider.notifier)
                        .selectCategory(category.id);

                    // Navigate to category screen (tab index 1)
                    final navKey = MainNavigationShell.globalKey;
                    navKey.currentState?.navigateToTab(1);
                  },
                ),

                // Search bar
                _buildSearchBar(),

                AppSpacing.h16,

                //Best Deals det items section
                _buildGoToItemsSection(),

                AppSpacing.h16,

                // Offers made for you section
                _buildOffersSection(),

                SizedBox(height: 160.h), // Space for bottom nav + banner
              ],
            ),
          ),

          // Live order tracking banner at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 80.h, // Above bottom navigation
            child: const LiveOrderTrackingBanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final categoriesAsync = ref.watch(cartCategoriesProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () {
          categoriesAsync.whenData((categories) {
            _showSearchBottomSheet(context, categories);
          });
        },
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              AppSpacing.w12,
              Icon(Icons.search, color: Colors.grey.shade600, size: 22.sp),
              AppSpacing.w12,
              const Center(
                child: AppText(
                  text: 'Search...',
                  color: AppColors.grey,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoToItemsSection() {
    final discountedProductsAsync = ref.watch(discountedProductsProvider);

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Deals',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to discounted products page
                  _navigateToDiscountedProducts();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF25A63E),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Horizontal product cards
        SizedBox(
          height: 195.h,
          child: discountedProductsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Text(
                    'No discounted products available',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: _ProductCard(
                      key: ValueKey('discounted_${product.id}'),
                      title: product.name,
                      price: '₹ ${product.discountedPrice}',
                      discount:
                          '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                      imagePath: product.primaryImageUrl ?? '',
                      productVariant: product,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF4CAF50),
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Failed to load products',
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    final offerProductsAsync = ref.watch(offerCategoryProductsProvider);

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mega Fresh offers',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to offer products page
                  _navigateToOfferProducts();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See More',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF25A63E),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Horizontal product cards
        SizedBox(
          height: 195.h,
          child: offerProductsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Text(
                    'No offer products available',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: _ProductCard(
                      key: ValueKey(
                        'offer_${product.productId}_${product.variantId}',
                      ),
                      title: product.productName,
                      price: '₹ ${product.discountedPrice ?? product.price}',
                      discount: product.hasDiscount
                          ? '${product.discountPercentage.toStringAsFixed(0)}% OFF'
                          : null,
                      imagePath: product.imageUrl ?? '',
                      variantId: product.variantId,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF4CAF50),
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Failed to load offers',
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Product Card Widget with Add to Cart functionality
class _ProductCard extends ConsumerStatefulWidget {
  const _ProductCard({
    required this.title,
    required this.price,
    required this.imagePath,
    this.discount,
    this.productVariant,
    this.variantId,
    super.key,
  });
  final String title;
  final String price;
  final String? discount;
  final String imagePath;
  final ProductVariant? productVariant;
  final int? variantId;

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard> {
  bool _isTogglingWishlist = false;
  bool _isAddingToCart = false;
  bool _isUpdatingQuantity = false;
  DateTime? _lastUpdateTime;

  /// Get cart quantity for this product from cart state
  int _getCartQuantity() {
    if (!mounted) return 0;

    final cartState = ref.watch(cartControllerProvider);
    if (cartState.data == null) return 0;

    // Get variant ID
    final variantId = widget.productVariant?.id ?? widget.variantId;
    if (variantId == null) return 0;

    try {
      final line = cartState.data!.results.firstWhere(
        (line) => line.productVariantId == variantId,
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

    final variantId = widget.productVariant?.id ?? widget.variantId;
    if (variantId == null) return null;

    try {
      final line = cartState.data!.results.firstWhere(
        (line) => line.productVariantId == variantId,
      );
      return line.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleAddToCart() async {
    final variantId = widget.productVariant?.id ?? widget.variantId;
    if (variantId == null) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await ref
          .read(cartControllerProvider.notifier)
          .addToCart(productVariantId: variantId, quantity: 1);
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
    final variantId = widget.productVariant?.id ?? widget.variantId;
    if (lineId == null || variantId == null) return;

    setState(() {
      _isUpdatingQuantity = true;
      _lastUpdateTime = now;
    });

    try {
      ref
          .read(cartControllerProvider.notifier)
          .updateQuantity(
            lineId: lineId,
            productVariantId: variantId,
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
    final variantId = widget.productVariant?.id ?? widget.variantId;
    if (lineId == null || variantId == null) return;

    setState(() {
      _isUpdatingQuantity = true;
      _lastUpdateTime = now;
    });

    try {
      ref
          .read(cartControllerProvider.notifier)
          .updateQuantity(
            lineId: lineId,
            productVariantId: variantId,
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

  Future<void> _toggleWishlist() async {
    if (_isTogglingWishlist) return;

    setState(() {
      _isTogglingWishlist = true;
    });

    try {
      final variantId = widget.productVariant?.id ?? widget.variantId;
      if (variantId == null) return;

      final productId = variantId.toString();
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
    return GestureDetector(
      onTap: () {
        // Navigate to product detail screen
        final variantId = widget.productVariant?.id ?? widget.variantId;
        if (variantId != null) {
          context.push('/product/$variantId');
        }
      },
      child: Container(
        width: 130.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                Container(
                  height: 100.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                  ),
                  child: _buildProductImage(),
                ),
                // Discount badge
                if (widget.discount != null)
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
                          widget.discount!,
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
                // Wishlist icon
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: GestureDetector(
                    onTap: _isTogglingWishlist ? null : _toggleWishlist,
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8.r,
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
                            : Builder(
                                builder: (context) {
                                  final variantId =
                                      widget.productVariant?.id ??
                                      widget.variantId;
                                  final productId = variantId?.toString() ?? '';
                                  final isInWishlist = ref.watch(
                                    isInWishlistProvider(productId),
                                  );

                                  return Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 18.sp,
                                    color: isInWishlist
                                        ? const Color(0xFFFF6B6B)
                                        : const Color(0xFFFFA726),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product details
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        widget.price,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF25A63E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  if (_getCartQuantity() > 0)
                    _buildQuantitySelector()
                  else
                    _buildAddToCartButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    // Check if it's a network image or asset
    final isNetworkImage =
        widget.imagePath.startsWith('http://') ||
        widget.imagePath.startsWith('https://');

    if (widget.imagePath.isEmpty) {
      return Icon(Icons.shopping_basket, size: 40.sp, color: Colors.grey);
    }

    if (isNetworkImage) {
      return Image.network(
        widget.imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF4CAF50),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.shopping_basket, size: 40.sp, color: Colors.grey);
        },
      );
    }

    return Image.asset(
      widget.imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.shopping_basket, size: 40.sp, color: Colors.grey);
      },
    );
  }

  Widget _buildQuantitySelector() {
    return Opacity(
      opacity: _isUpdatingQuantity ? 0.6 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 30.h,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade100),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _isUpdatingQuantity ? null : _handleDecreaseQuantity,
                  child: Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isUpdatingQuantity
                            ? Colors.grey.shade400
                            : Colors.black,
                      ),
                      color: _isUpdatingQuantity
                          ? Colors.grey.shade300
                          : Colors.white,
                    ),
                    child: Center(
                      child: _isUpdatingQuantity
                          ? SizedBox(
                              width: 10.w,
                              height: 10.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5.w,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF25A63E),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.remove,
                              size: 15.sp,
                              color: const Color(0xFF25A63E),
                            ),
                    ),
                  ),
                ),
                AppSpacing.w8,
                Container(
                  width: 20.w,
                  alignment: Alignment.center,
                  child: Text(
                    '${_getCartQuantity()}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                AppSpacing.w8,
                GestureDetector(
                  onTap: _isUpdatingQuantity ? null : _handleIncreaseQuantity,
                  child: Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isUpdatingQuantity
                            ? Colors.grey.shade400
                            : Colors.black,
                      ),
                      color: _isUpdatingQuantity
                          ? Colors.grey.shade300
                          : Colors.white,
                    ),
                    child: Center(
                      child: _isUpdatingQuantity
                          ? SizedBox(
                              width: 10.w,
                              height: 10.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5.w,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF25A63E),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.add,
                              size: 15.sp,
                              color: const Color(0xFF25A63E),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return GestureDetector(
      onTap: _isAddingToCart ? null : _handleAddToCart,
      child: Container(
        height: 32.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grey),
        ),
        child: _isAddingToCart
            ? Center(
                child: SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF25A63E),
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16.sp,
                    color: const Color(0xFF25A63E),
                  ),
                  SizedBox(width: 6.w),
                  const AppText(text: 'Add to cart', fontSize: 12),
                ],
              ),
      ),
    );
  }
}

class _BadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(0, size.height * 0.75)
      ..lineTo(0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _SearchBottomSheet extends ConsumerStatefulWidget {
  const _SearchBottomSheet({required this.categories});
  final List<CategoryItem> categories;

  @override
  ConsumerState<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends ConsumerState<_SearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<CategoryItem> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
    // Auto-focus on search field
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      // Don't filter categories - only search products
      // Keep categories list empty when searching to show only products
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = []; // Clear categories to show only products
      }
    });
  }

  /// Apply search query to backend filter
  void _applySearchFilter(String query) {
    ref
        .read(cartFilterProvider.notifier)
        .setSearchQuery(query.isEmpty ? null : query);

    // Invalidate products to refetch with search query
    ref.invalidate(paginatedCategoryProductsProvider);

    // Close bottom sheet
    Navigator.pop(context);

    _addToRecentSearches(query);
  }

  Future<void> _addToRecentSearches(String query) async {
    if (query.trim().isNotEmpty) {
      await ref.read(recentSearchesProvider.notifier).addSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Header with search bar
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
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
                SizedBox(height: 16.h),
                // Search bar
                Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 20.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Search field
                    Expanded(
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: _performSearch,
                          onSubmitted: _applySearchFilter,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search categories & products...',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade500,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                              size: 22.sp,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      _performSearch('');
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.grey.shade600,
                                      size: 20.sp,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isSearching ? _buildSearchResults() : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final recentSearches = ref.watch(recentSearchesProvider);
                  if (recentSearches.isEmpty) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () async {
                      await ref
                          .read(recentSearchesProvider.notifier)
                          .clearAll();
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF25A63E),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Consumer(
            builder: (context, ref, child) {
              final recentSearches = ref.watch(recentSearchesProvider);

              if (recentSearches.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No recent searches',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: recentSearches.map(_buildRecentSearchItem).toList(),
              );
            },
          ),

          SizedBox(height: 24.h),

          // Popular categories
          Text(
            'Popular Categories',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          _buildPopularCategories(),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        _performSearch(search);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.w),
        ),
        child: Row(
          children: [
            Icon(Icons.history, size: 20.sp, color: Colors.grey.shade600),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                search,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.north_west, size: 16.sp, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    final popularCategories = widget.categories.take(6).toList();

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: popularCategories.map((category) {
        return GestureDetector(
          onTap: () {
            _searchController.text = category.title;
            _performSearch(category.title);
            _addToRecentSearches(category.title);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF25A63E).withValues(alpha: 0.1),
                  const Color(0xFF0D5C2E).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Text(
              category.title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D5C2E),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults() {
    final searchQuery = _searchController.text.trim();

    // Watch product search results
    final productsAsync = ref.watch(productSearchProvider(searchQuery));

    // Show empty state if both categories and products are empty
    if (_filteredCategories.isEmpty) {
      return productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Try searching with different keywords',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
          // Only products found, no categories
          return _buildResultsList([], products);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildResultsList([], []),
      );
    }

    // Show categories and products
    return productsAsync.when(
      data: (products) => _buildResultsList(_filteredCategories, products),
      loading: () => _buildResultsList(_filteredCategories, []),
      error: (error, stackTrace) => _buildResultsList(_filteredCategories, []),
    );
  }

  Widget _buildResultsList(
    List<CategoryItem> categories,
    List<dynamic> products,
  ) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        // Categories section
        if (categories.isNotEmpty) ...[
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          ...categories.map(_buildCategoryResultItem),
          if (products.isNotEmpty) SizedBox(height: 24.h),
        ],

        // Products section
        if (products.isNotEmpty) ...[
          Text(
            'Products',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          ...products.map(_buildProductResultItem),
        ],
      ],
    );
  }

  Widget _buildCategoryResultItem(CategoryItem category) {
    return GestureDetector(
      onTap: () {
        _addToRecentSearches(category.title);
        // Close bottom sheet and navigate to category
        Navigator.pop(context);
        // You can add navigation logic here to open the specific category
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.w),
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
            // Category icon
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF25A63E).withValues(alpha: 0.2),
                    const Color(0xFF0D5C2E).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: category.assetPath != null
                    ? Image.asset(category.assetPath!, fit: BoxFit.cover)
                    : category.imageUrl != null
                    ? Image.network(category.imageUrl!, fit: BoxFit.cover)
                    : Icon(
                        Icons.category_outlined,
                        size: 28.sp,
                        color: const Color(0xFF25A63E),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'View category',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: const Color(0xFF25A63E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductResultItem(dynamic productDisplay) {
    // Skip products without valid variant ID
    if (productDisplay.variantId == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () async {
        // Save context-dependent values before async gap
        final navigator = Navigator.of(context);
        final router = GoRouter.of(context);
        final imageUrl = productDisplay.image;
        final uri = Uri(
          path: '/product/${productDisplay.variantId}',
          queryParameters: imageUrl != null ? {'imageUrl': imageUrl} : null,
        );

        await _addToRecentSearches(productDisplay.productName);

        // Close bottom sheet and navigate to product detail
        navigator.pop();
        unawaited(router.push(uri.toString()));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.w),
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
            // Product image
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child:
                    productDisplay.image != null &&
                        productDisplay.image!.isNotEmpty
                    ? Image.network(
                        productDisplay.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 28.sp,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : Icon(
                        Icons.shopping_bag_outlined,
                        size: 28.sp,
                        color: Colors.grey.shade400,
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productDisplay.productName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        productDisplay.price,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF25A63E),
                        ),
                      ),
                      if (productDisplay.discountPercentage > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '${productDisplay.discountPercentage.toStringAsFixed(0)}% OFF',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (productDisplay.variantSku.isNotEmpty &&
                      productDisplay.variantSku != 'N/A') ...[
                    SizedBox(height: 2.h),
                    Text(
                      'SKU: ${productDisplay.variantSku}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: const Color(0xFF25A63E),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product List Bottom Sheet for Best Deals (See All)
class _ProductListBottomSheet extends ConsumerWidget {
  const _ProductListBottomSheet({
    required this.title,
    required this.products,
  });

  final String title;
  final List<ProductVariant> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
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
                SizedBox(height: 16.h),
                // Title row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '${products.length} items',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF25A63E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Product grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(
                  key: ValueKey('discounted_all_${product.id}'),
                  title: product.name,
                  price: '₹ ${product.discountedPrice}',
                  discount:
                      '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                  imagePath: product.primaryImageUrl ?? '',
                  productVariant: product,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Offer Product List Bottom Sheet for Mega Offers (See More)
class _OfferProductListBottomSheet extends ConsumerWidget {
  const _OfferProductListBottomSheet({
    required this.title,
    required this.products,
  });

  final String title;
  final List<dynamic> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
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
                SizedBox(height: 16.h),
                // Title row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '${products.length} items',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF25A63E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Product grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(
                  key: ValueKey('offer_all_${product.productId}_${product.variantId}'),
                  title: product.productName,
                  price: '₹ ${product.discountedPrice ?? product.price}',
                  discount: product.hasDiscount
                      ? '${product.discountPercentage.toStringAsFixed(0)}% OFF'
                      : null,
                  imagePath: product.imageUrl ?? '',
                  variantId: product.variantId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

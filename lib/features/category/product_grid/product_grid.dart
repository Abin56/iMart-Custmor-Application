// ignore_for_file: avoid_redundant_argument_values, omit_local_variable_types, deprecated_member_use_from_same_package, cascade_invocations, unawaited_futures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/category/models/category_item.dart';
import 'package:imart/features/category/models/category_product.dart';
import 'package:imart/features/category/product_card.dart';
import 'package:imart/features/category/product_detail_screen.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../app/theme/colors.dart';
import '../application/providers/cart_data_provider.dart';
import '../application/providers/cart_paginated_provider.dart';
import '../domain/entities/product_display.dart';

/// Displays products in a grid with category headings
/// Uses backend API with Riverpod state management
class ProductGrid extends ConsumerStatefulWidget {
  const ProductGrid({
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onCategoryInViewChanged,
    super.key,
    this.onAddToCart,
    this.onProductTap,
  });

  final List<CategoryItem> categories;
  final int selectedCategoryIndex;
  final ValueChanged<int> onCategoryInViewChanged;
  final ValueChanged<CategoryProduct>? onAddToCart;
  final ValueChanged<CategoryProduct>? onProductTap;

  @override
  ConsumerState<ProductGrid> createState() => ProductGridState();
}

class ProductGridState extends ConsumerState<ProductGrid> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _sectionKeys;
  bool _isProgrammaticScroll = false;
  int? _lastReportedIndex;

  @override
  void initState() {
    super.initState();
    _buildSectionKeys();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(ProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories.length != widget.categories.length) {
      _buildSectionKeys();
    }
  }

  void _buildSectionKeys() {
    _sectionKeys = List<GlobalKey>.generate(
      widget.categories.length,
      (_) => GlobalKey(),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> scrollToCategory(int index) async {
    if (!_scrollController.hasClients) return;
    if (index < 0 || index >= _sectionKeys.length) return;

    // Set flag before checking context to prevent race conditions
    _isProgrammaticScroll = true;
    _lastReportedIndex = index;

    // Wait for next frame to ensure widgets are built
    await Future.delayed(const Duration(milliseconds: 50));

    if (!mounted || !_scrollController.hasClients) {
      _isProgrammaticScroll = false;
      return;
    }

    final targetContext = _sectionKeys[index].currentContext;
    if (targetContext == null) {
      // Try again after a delay
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _isProgrammaticScroll = false;
        scrollToCategory(index);
      }
      return;
    }

    final renderBox = targetContext.findRenderObject() as RenderBox?;
    final scrollBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || scrollBox == null) {
      _isProgrammaticScroll = false;
      return;
    }

    try {
      final offsetWithinScroll = renderBox
          .localToGlobal(Offset.zero, ancestor: scrollBox)
          .dy;
      final targetOffset = _scrollController.offset + offsetWithinScroll;
      final position = _scrollController.position;
      final clampedOffset = targetOffset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );

      await _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 350));
    } finally {
      _isProgrammaticScroll = false;
    }
  }

  void _handleScroll() {
    if (_isProgrammaticScroll || !_scrollController.hasClients) return;

    final scrollBox = context.findRenderObject() as RenderBox?;
    if (scrollBox == null) return;

    int? visibleIndex;
    double smallestTop = double.infinity;

    for (var i = 0; i < _sectionKeys.length; i++) {
      final sectionContext = _sectionKeys[i].currentContext;
      if (sectionContext == null) continue;

      final sectionBox = sectionContext.findRenderObject() as RenderBox?;
      if (sectionBox == null || !sectionBox.attached) continue;

      final top = sectionBox.localToGlobal(Offset.zero, ancestor: scrollBox).dy;
      final bottom = top + sectionBox.size.height;
      const viewportTop = 0.0;
      final viewportBottom = scrollBox.size.height;

      if (top < viewportBottom && bottom > viewportTop) {
        final effectiveTop = top < viewportTop ? viewportTop : top;

        if (effectiveTop < smallestTop) {
          smallestTop = effectiveTop;
          visibleIndex = i;
        }
      }
    }

    // Only notify if the visible index changed and is different from last reported
    if (visibleIndex != null &&
        visibleIndex != widget.selectedCategoryIndex &&
        visibleIndex != _lastReportedIndex) {
      _lastReportedIndex = visibleIndex;
      widget.onCategoryInViewChanged(visibleIndex);
    }
  }

  /// Convert ProductDisplay to CategoryProduct for UI
  CategoryProduct _convertProductDisplay(ProductDisplay display) {
    return CategoryProduct(
      variantId: display.variantId.toString(),
      variantName: display.variantSku,
      name: display.productName,
      price: display.displayPrice,
      originalPrice: display.hasDiscount ? display.price : null,
      imageUrl: display.image,
      inStock: true, // ProductDisplay doesn't have stock info from API
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    int globalProductIndex = 0;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        for (var i = 0; i < widget.categories.length; i++) ...[
          Builder(
            builder: (context) {
              final startIndex = globalProductIndex;
              final categoryId =
                  int.tryParse(widget.categories[i].id ?? '0') ?? 0;

              // Watch paginated products for this category
              final productsAsync = ref.watch(
                paginatedCategoryProductsProvider(categoryId),
              );

              return productsAsync.when(
                data: (paginatedState) {
                  // Convert ProductDisplay list to CategoryProduct list
                  final products = paginatedState.products
                      .map(_convertProductDisplay)
                      .toList();
                  globalProductIndex += products.length;

                  return _CategorySectionBuilder(
                    sectionKey: _sectionKeys[i],
                    category: widget.categories[i],
                    categoryId: categoryId,
                    products: products,
                    isFirst: i == 0,
                    colorScheme: colorScheme,
                    onAddToCart: widget.onAddToCart,
                    onProductTap: widget.onProductTap,
                    startIndex: startIndex,
                    hasMore: paginatedState.hasMore,
                    isLoadingMore: paginatedState.isLoadingMore,
                    onLoadMore: () {
                      ref
                          .read(
                            paginatedCategoryProductsProvider(
                              categoryId,
                            ).notifier,
                          )
                          .loadMore(categoryId);
                    },
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: Container(
                    key: _sectionKeys[i],
                    height:
                        0, // Hide loading indicator - bottom sheet shows progress
                  ),
                ),
                error: (error, stack) {
                  // Check if it's a timeout error
                  final isTimeout =
                      error.toString().contains('timeout') ||
                      error.toString().contains('Timeout');

                  return SliverToBoxAdapter(
                    child: Container(
                      key: _sectionKeys[i],
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        children: [
                          // Category header (keep it visible even on error)
                          Container(
                            height: 25.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.grey.withValues(alpha: 0.2),
                              ),
                              color: AppColors.white,
                            ),
                            child: Center(
                              child: AppText(
                                text: widget.categories[i].title,
                                color: AppColors.green100,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // Error message
                          Icon(
                            isTimeout ? Icons.access_time : Icons.error_outline,
                            size: 40.sp,
                            color: isTimeout
                                ? Colors.orange.shade400
                                : Colors.red.shade400,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            isTimeout
                                ? 'Request timed out'
                                : 'Failed to load products',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            isTimeout
                                ? 'Server is taking too long to respond'
                                : 'Something went wrong',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.invalidate(
                                categoryProductsProvider(categoryId),
                              );
                            },
                            icon: Icon(Icons.refresh, size: 16.sp),
                            label: Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25A63E),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
        // Add bottom padding to prevent content from being hidden behind nav bar
        SliverPadding(
          padding: EdgeInsets.only(bottom: 80.h), // Height of bottom nav bar
        ),
      ],
    );
  }
}

class _CategorySectionBuilder extends StatelessWidget {
  const _CategorySectionBuilder({
    required this.sectionKey,
    required this.category,
    required this.categoryId,
    required this.products,
    required this.isFirst,
    required this.colorScheme,
    required this.startIndex,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    this.onAddToCart,
    this.onProductTap,
  });

  final GlobalKey sectionKey;
  final CategoryItem category;
  final int categoryId;
  final List<CategoryProduct> products;
  final bool isFirst;
  final ColorScheme colorScheme;
  final ValueChanged<CategoryProduct>? onAddToCart;
  final ValueChanged<CategoryProduct>? onProductTap;
  final int startIndex;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            key: sectionKey,
            padding: EdgeInsets.only(
              top: isFirst ? 0.h : 5.h,
              bottom: 5.h,
              left: 4.w,
              right: 4.w,
            ),
            child: Container(
              height: 25.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
                color: AppColors.white,
              ),
              child: Center(
                child: AppText(
                  text: category.title,
                  color: AppColors.green100,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          sliver: _CategoryProductsSliver(
            products: products,
            colorScheme: colorScheme,
            onAddToCart: onAddToCart,
            onProductTap: onProductTap,
            startIndex: startIndex,
          ),
        ),
        // Load More button
        if (hasMore || isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: isLoadingMore
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF25A63E),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onLoadMore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25A63E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, size: 18),
                          SizedBox(width: 8.w),
                          Text(
                            'Load More Products',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

class _CategoryProductsSliver extends StatelessWidget {
  const _CategoryProductsSliver({
    required this.products,
    required this.colorScheme,
    required this.startIndex,
    this.onAddToCart,
    this.onProductTap,
  });

  final List<CategoryProduct> products;
  final ColorScheme colorScheme;
  final ValueChanged<CategoryProduct>? onAddToCart;
  final ValueChanged<CategoryProduct>? onProductTap;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6.w,
        mainAxisSpacing: 6.h,
        mainAxisExtent: 182.h, // Increased to fit all content including prices
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = products[index];
        return ProductCard(
          key: ValueKey(product.variantId),
          product: product,
          colorScheme: colorScheme,
          onAddToCart: () => onAddToCart?.call(product),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
            onProductTap?.call(product);
          },
          index: startIndex + index,
        );
      }, childCount: products.length),
    );
  }
}

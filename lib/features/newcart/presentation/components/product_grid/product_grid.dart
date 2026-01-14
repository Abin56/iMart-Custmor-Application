import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/colors.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../models/category_item.dart';
import '../../../models/category_product.dart';
import '../../../models/dummy_data.dart';
import '../widgets/product_card.dart';

/// Displays products in a grid with category headings
/// Static version using hardcoded dummy data
class ProductGrid extends StatefulWidget {
  const ProductGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onCategoryInViewChanged,
    this.onAddToCart,
    this.onProductTap,
  });

  final List<CategoryItem> categories;
  final int selectedCategoryIndex;
  final ValueChanged<int> onCategoryInViewChanged;
  final ValueChanged<CategoryProduct>? onAddToCart;
  final ValueChanged<CategoryProduct>? onProductTap;

  @override
  State<ProductGrid> createState() => ProductGridState();
}

class ProductGridState extends State<ProductGrid> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _sectionKeys;
  bool _isProgrammaticScroll = false;

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

    final targetContext = _sectionKeys[index].currentContext;
    if (targetContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          scrollToCategory(index);
        }
      });
      return;
    }

    final renderBox = targetContext.findRenderObject() as RenderBox?;
    final scrollBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || scrollBox == null) return;

    final offsetWithinScroll =
        renderBox.localToGlobal(Offset.zero, ancestor: scrollBox).dy;
    final targetOffset = _scrollController.offset + offsetWithinScroll;
    final position = _scrollController.position;
    final clampedOffset = targetOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    _isProgrammaticScroll = true;

    await _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _isProgrammaticScroll = false;
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

      final top =
          sectionBox.localToGlobal(Offset.zero, ancestor: scrollBox).dy;
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

    if (visibleIndex != null && visibleIndex != widget.selectedCategoryIndex) {
      widget.onCategoryInViewChanged(visibleIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        for (var i = 0; i < widget.categories.length; i++) ...[
          _CategorySectionBuilder(
            sectionKey: _sectionKeys[i],
            category: widget.categories[i],
            isFirst: i == 0,
            colorScheme: colorScheme,
            onAddToCart: widget.onAddToCart,
            onProductTap: widget.onProductTap,
          ),
        ],
      ],
    );
  }
}

class _CategorySectionBuilder extends StatelessWidget {
  const _CategorySectionBuilder({
    required this.sectionKey,
    required this.category,
    required this.isFirst,
    required this.colorScheme,
    this.onAddToCart,
    this.onProductTap,
  });

  final GlobalKey sectionKey;
  final CategoryItem category;
  final bool isFirst;
  final ColorScheme colorScheme;
  final ValueChanged<CategoryProduct>? onAddToCart;
  final ValueChanged<CategoryProduct>? onProductTap;

  @override
  Widget build(BuildContext context) {
    final products = DummyData.getProductsForCategory(category.id);

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
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          sliver: _CategoryProductsSliver(
            products: products,
            colorScheme: colorScheme,
            onAddToCart: onAddToCart,
            onProductTap: onProductTap,
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
    this.onAddToCart,
    this.onProductTap,
  });

  final List<CategoryProduct> products;
  final ColorScheme colorScheme;
  final ValueChanged<CategoryProduct>? onAddToCart;
  final ValueChanged<CategoryProduct>? onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.5.w,
        mainAxisSpacing: 5.h,
        mainAxisExtent: 175.h,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return ProductCard(
            key: ValueKey(product.variantId),
            product: product,
            colorScheme: colorScheme,
            onAddToCart: () => onAddToCart?.call(product),
            onTap: () => onProductTap?.call(product),
          );
        },
        childCount: products.length,
      ),
    );
  }
}

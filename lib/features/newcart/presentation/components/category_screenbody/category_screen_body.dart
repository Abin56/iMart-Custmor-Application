import 'package:flutter/material.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../models/category_item.dart';
import '../views/category_empty_view.dart';
import '../widgets/category_list.dart';
import '../widgets/filter_bar.dart';
import '../product_grid/product_grid.dart';

/// Main category screen layout that combines:
/// - Left sidebar: Category list for navigation
/// - Right side: Filter bar + Product grid with category headings
///
/// Static version - no backend or state management
class CategoryScreenBody extends StatefulWidget {
  static const List<String> _filters = ['Brand', 'Price Drop', 'Popular'];

  final List<CategoryItem> categories;
  final int selectedCategoryIndex;
  final int selectedFilterIndex;
  final void Function(int index) onCategorySelected;
  final void Function(int index) onFilterSelected;

  const CategoryScreenBody({
    required this.categories,
    required this.selectedCategoryIndex,
    required this.selectedFilterIndex,
    required this.onCategorySelected,
    required this.onFilterSelected,
    super.key,
  });

  @override
  State<CategoryScreenBody> createState() => CategoryScreenBodyState();
}

class CategoryScreenBodyState extends State<CategoryScreenBody> {
  late final GlobalKey<ProductGridState> _productGridKey;

  @override
  void initState() {
    super.initState();
    _productGridKey = GlobalKey<ProductGridState>();
  }

  void scrollToCategory(int index) {
    _productGridKey.currentState?.scrollToCategory(index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const CategoryEmptyView();
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryList(
                categories: widget.categories,
                selectedIndex: widget.selectedCategoryIndex,
                onCategorySelected: (index) {
                  widget.onCategorySelected(index);
                  _productGridKey.currentState?.scrollToCategory(index);
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              AppSpacing.h4,
              FilterBar(
                filters: CategoryScreenBody._filters,
                selectedIndex: widget.selectedFilterIndex,
                onFilterSelected: widget.onFilterSelected,
                leadingIconAsset: 'assets/svgs/category_screen/filter_icon.svg',
              ),
              AppSpacing.h4,
              Expanded(
                child: ProductGrid(
                  key: _productGridKey,
                  categories: widget.categories,
                  selectedCategoryIndex: widget.selectedCategoryIndex,
                  onCategoryInViewChanged: widget.onCategorySelected,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

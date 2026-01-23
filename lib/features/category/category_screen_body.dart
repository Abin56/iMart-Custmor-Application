import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/category/category_list.dart';
import 'package:imart/features/category/filter_bar.dart';
import 'package:imart/features/category/models/category_item.dart';
import 'package:imart/features/category/product_grid/product_grid.dart';
import 'package:imart/features/category/views/category_empty_view.dart';

import '../../../../../app/theme/app_spacing.dart';

/// Main category screen layout that combines:
/// - Left sidebar: Category list for navigation
/// - Right side: Filter bar + Product grid with category headings
///
/// Static version - no backend or state management
class CategoryScreenBody extends StatefulWidget {
  const CategoryScreenBody({
    required this.categories,
    required this.selectedCategoryIndex,
    required this.selectedFilterIndex,
    required this.onCategorySelected,
    required this.onFilterSelected,
    super.key,
    this.isFilterLoading = false,
    this.isFilterCanceling = false,
  });
  static const List<String> _filters = [
    'Price Drop',
    'Popular',
    'New Arrivals',
  ];

  final List<CategoryItem> categories;
  final int selectedCategoryIndex;
  final int selectedFilterIndex;
  final void Function(int index) onCategorySelected;
  final void Function(int index) onFilterSelected;
  final bool isFilterLoading;
  final bool isFilterCanceling;

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
          flex: 2,
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
              Container(width: 5.w, color: const Color(0xFFE3F4E3)),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              AppSpacing.h4,
              FilterBar(
                filters: CategoryScreenBody._filters,
                selectedIndex: widget.selectedFilterIndex,
                onFilterSelected: widget.onFilterSelected,
                isLoading: widget.isFilterLoading,
                isCanceling: widget.isFilterCanceling,
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

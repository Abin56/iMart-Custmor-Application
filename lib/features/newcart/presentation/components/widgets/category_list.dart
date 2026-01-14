import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/colors.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../models/category_item.dart';

/// Left sidebar category navigation list
/// - Shows all categories with icon and text
/// - Selected item has green filled icon
/// - Notifies parent when category is tapped
/// - Auto-scrolls to keep selected category visible
class CategoryList extends StatefulWidget {
  const CategoryList({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  final List<CategoryItem> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final ScrollController _scrollController = ScrollController();
  final double _itemHeight = 100.0;

  @override
  void initState() {
    super.initState();
    if (widget.selectedIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedCategory();
      });
    }
  }

  @override
  void didUpdateWidget(CategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelectedCategory();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedCategory() {
    if (!_scrollController.hasClients) return;

    double targetOffset = widget.selectedIndex * _itemHeight;

    final viewportHeight = _scrollController.position.viewportDimension;
    final currentOffset = _scrollController.offset;
    final maxOffset = _scrollController.position.maxScrollExtent;

    final itemTop = targetOffset;
    final itemBottom = targetOffset + _itemHeight;
    final viewportTop = currentOffset;
    final viewportBottom = currentOffset + viewportHeight;

    if (itemTop < viewportTop || itemBottom > viewportBottom) {
      final centeredOffset =
          targetOffset - (viewportHeight / 2) + (_itemHeight / 2);
      final clampedOffset = centeredOffset.clamp(0.0, maxOffset);

      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
        
            // Category List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 8.h,horizontal: 0.h),
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final item = widget.categories[index];
                  final isSelected = index == widget.selectedIndex;

                  return GestureDetector(
                    onTap: () => widget.onCategorySelected(index),
                    child: Container(

               
                      height: _itemHeight.h,
                      decoration: const BoxDecoration(

                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with circular background
                          Container(
                            width: 55.w,
                            height: 55.w,
                         

                            decoration:  BoxDecoration(
                              shape: BoxShape.circle,
                              color:const Color(0xFFE3F4E3),

                               
                              border: Border.all(
                                
                                color: isSelected
                                    ? Colors.green
                                    : AppColors.grey.withValues(alpha: 0.3),
                                width: isSelected?2.5:0.w,
                              ),
                            ),
                            child: Center(
                              child: _getCategoryIcon(item, isSelected),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          // Category text
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: AppText(
                              text: item.title,
                              fontSize: 9.5.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w300,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              color: 
                                   AppColors.green100
                               
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(CategoryItem item, bool isSelected) {
    // Map category titles to icons
    IconData iconData;

    switch (item.title.toLowerCase()) {
      case 'all':
        iconData = Icons.shopping_bag_outlined;
        break;
      case 'meat and seafood':
        iconData = Icons.set_meal_outlined;
        break;
      case 'vegetables':
        iconData = Icons.eco_outlined;
        break;
      case 'fruits':
        iconData = Icons.apple_outlined;
        break;
      case 'snacks':
        iconData = Icons.cookie_outlined;
        break;
      case 'cleaning':
        iconData = Icons.cleaning_services_outlined;
        break;
      case 'beauty and hygiene':
        iconData = Icons.spa_outlined;
        break;
      default:
        iconData = Icons.category_outlined;
    }

    return Icon(
      iconData,
      size: 26.sp,
      color: 
           AppColors.black
        
    );
  }
}

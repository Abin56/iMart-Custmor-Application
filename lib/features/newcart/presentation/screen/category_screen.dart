import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../models/category_item.dart';
import '../../models/dummy_data.dart';
import '../components/category_screenbody/category_screen_body.dart';

/// Static Category Screen - No backend, Riverpod, or API calls
/// Uses hardcoded dummy data for UI display
class CategoryScreen extends StatefulWidget {
  final String? initialCategoryId;
  const CategoryScreen({super.key, this.initialCategoryId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedFilterIndex = 0;
  final GlobalKey<CategoryScreenBodyState> _bodyKey = GlobalKey();

  final List<CategoryItem> _categories = DummyData.categories;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToInitialCategory();
      });
    }
  }

  void _scrollToInitialCategory() {
    if (!mounted) return;
    if (_categories.isEmpty || widget.initialCategoryId == null) return;

    final initialIndex = _categories.indexWhere(
      (cat) => cat.id == widget.initialCategoryId,
    );

    if (initialIndex >= 0) {
      setState(() {
        _selectedCategoryIndex = initialIndex;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _bodyKey.currentState?.scrollToCategory(initialIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
     // Status bar space
          Container(height: 42.h, color: const Color(0xFF0D5C2E)),
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            decoration: const BoxDecoration(color: Color(0xFF0D5C2E)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Categories',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(),
              child: CategoryScreenBody(
                key: _bodyKey,
                categories: _categories,
                selectedCategoryIndex: _selectedCategoryIndex,
                selectedFilterIndex: _selectedFilterIndex,
                onCategorySelected: (index) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                onFilterSelected: (index) {
                  setState(() => _selectedFilterIndex = index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

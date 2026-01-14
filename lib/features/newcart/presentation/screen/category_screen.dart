import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/colors.dart';
import '../../models/category_item.dart';
import '../../models/dummy_data.dart';
import '../components/header/header.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: AppColors.green10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 42.h, color: AppColors.green60),
          Header(
            colorScheme: colorScheme,
            onCategoryTap: () {
              // Handle category icon tap (static - no navigation)
            },
            onSearchTap: () {
              // Handle search tap (static - no navigation)
            },
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_graphics.png'),
                  fit: BoxFit.cover,
                ),
              ),
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

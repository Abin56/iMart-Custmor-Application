// ignore_for_file: cascade_invocations, unnecessary_underscores, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:imart/features/category/category_screen_body.dart';
import 'package:imart/features/category/models/category_item.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../app/theme/colors.dart';
import 'application/providers/cart_data_provider.dart';
import 'application/providers/cart_filter_provider.dart';
import 'application/providers/cart_paginated_provider.dart';
import 'application/providers/cart_search_provider.dart';
import 'application/providers/recent_search_provider.dart';
import 'domain/entities/category.dart';
import 'presentation/widgets/loading_bottom_sheet.dart';

/// Category Screen with backend API integration
class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key, this.initialCategoryId});
  final int? initialCategoryId;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedFilterIndex = -1; // -1 means no filter selected
  final GlobalKey<CategoryScreenBodyState> _bodyKey = GlobalKey();
  List<Category> _categories = [];
  bool _isApplyingFilter = false;
  bool _isCancelingFilter = false; // New state for canceling
  bool _hasInitiallyLoaded = false;

  @override
  void initState() {
    super.initState();
    // Initial category selection will be handled in build after data loads
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

  /// Wait for all category providers to finish loading
  Future<void> _waitForProvidersToLoad() async {
    // Poll until all providers are loaded (not in loading state)
    const maxAttempts = 50; // 5 seconds max (50 * 100ms)
    var attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if all category providers have finished loading
      var allLoaded = true;
      for (final category in _categories) {
        final providerState = ref.read(
          paginatedCategoryProductsProvider(category.id),
        );

        if (providerState.isLoading) {
          allLoaded = false;
          break;
        }
      }

      if (allLoaded) {
        return;
      }

      attempts++;
    }
  }

  /// Apply backend filter based on selected filter chip
  /// Tapping the same filter again will clear/cancel it
  Future<void> _applyFilter(int filterIndex) async {
    final filterNotifier = ref.read(cartFilterProvider.notifier);

    // Check if tapping the same filter - if so, clear it
    final isClearingFilter = _selectedFilterIndex == filterIndex;

    if (isClearingFilter) {
      // Clear filter - set canceling state
      setState(() {
        _selectedFilterIndex = -1;
        _isCancelingFilter = true;
        _isApplyingFilter = false;
      });

      final loadingContext = context;
      LoadingBottomSheet.show(loadingContext, message: 'Clearing filter');

      filterNotifier.clearFilters();
      // Note: No manual invalidate needed - provider watches filter state

      // Wait for providers to rebuild with new filter state
      await Future.delayed(const Duration(milliseconds: 100));

      // Wait for all category providers to finish loading
      await _waitForProvidersToLoad();

      if (mounted) {
        LoadingBottomSheet.hide(loadingContext);
        setState(() {
          _isCancelingFilter = false;
        });
      }
      return;
    }

    // Set user-friendly loading message based on filter
    String loadingMessage;
    switch (filterIndex) {
      case 0: // Price Drop
        loadingMessage = 'Finding best deals';
        break;
      case 1: // Popular
        loadingMessage = 'Loading popular items';
        break;
      case 2: // New Arrivals
        loadingMessage = 'Getting latest products';
        break;
      default:
        loadingMessage = 'Refreshing products';
    }

    setState(() {
      _selectedFilterIndex = filterIndex;
      _isApplyingFilter = true;
      _isCancelingFilter = false;
    });

    // Show bottom sheet loading
    final loadingContext = context;
    LoadingBottomSheet.show(loadingContext, message: loadingMessage);

    // Apply filter based on selection - use atomic update to ensure single state change
    switch (filterIndex) {
      case 0: // Price Drop
        filterNotifier.setMultipleFilters(
          isDiscounted: true,
          ordering: '-min_price',
        );

        break;
      case 1: // Popular
        filterNotifier.setMultipleFilters(ordering: '-rating');

        break;
      case 2: // New Arrivals
        filterNotifier.setMultipleFilters(ordering: '-created_at');

        break;
      default:
        filterNotifier.clearFilters();
    }

    // Wait briefly for the filter state to propagate
    await Future.delayed(const Duration(milliseconds: 100));

    // Wait for all category providers to finish loading with new filter
    // Note: No manual invalidate needed - providers watch cartFilterProvider
    await _waitForProvidersToLoad();

    if (mounted) {
      // Hide bottom sheet only after all products have loaded
      LoadingBottomSheet.hide(loadingContext);
      setState(() {
        _isApplyingFilter = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(cartCategoriesProvider);

    // Debug: Listen to filter state changes
    ref.listen(cartFilterProvider, (previous, next) {});

    return Stack(
      children: [
        ColoredBox(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: 'Categories',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: () {
                        categoriesAsync.whenData((categories) {
                          _showSearchBottomSheet(context, categories);
                        });
                      },
                      child: Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5.w,
                          ),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(),
                  child: categoriesAsync.when(
                    data: (categories) {
                      // Update local categories list and handle initial scroll
                      if (_categories.isEmpty && categories.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _categories = categories;
                          });
                          if (widget.initialCategoryId != null) {
                            _scrollToInitialCategory();
                          }
                          // Show initial loading bottom sheet
                          if (!_hasInitiallyLoaded && mounted) {
                            final initialContext = context;
                            LoadingBottomSheet.show(
                              initialContext,
                              message: 'Getting everything ready',
                              stages: const [
                                'Setting up categories...',
                                'Loading products...',
                                'Finalizing...',
                              ],
                            );
                            // Hide loading after initial products load
                            Future.delayed(
                              const Duration(milliseconds: 1500),
                              () {
                                if (mounted) {
                                  LoadingBottomSheet.hide(initialContext);
                                  setState(() {
                                    _hasInitiallyLoaded = true;
                                  });
                                }
                              },
                            );
                          }
                        });
                      }

                      final categoryItems = _convertCategoriesToItems(
                        categories,
                      );

                      return CategoryScreenBody(
                        key: _bodyKey,
                        categories: categoryItems,
                        selectedCategoryIndex: _selectedCategoryIndex,
                        selectedFilterIndex: _selectedFilterIndex,
                        isFilterLoading: _isApplyingFilter,
                        isFilterCanceling: _isCancelingFilter,
                        onCategorySelected: (index) async {
                          setState(() {
                            _selectedCategoryIndex = index;
                            _selectedFilterIndex =
                                -1; // Reset filter when category changes
                          });

                          // Clear any active filters when switching categories
                          final filterNotifier = ref.read(
                            cartFilterProvider.notifier,
                          );
                          filterNotifier.clearFilters();

                          // Show bottom sheet loading with stages
                          final loadingContext = context;
                          LoadingBottomSheet.show(
                            loadingContext,
                            message: _hasInitiallyLoaded
                                ? 'Loading products'
                                : 'Getting ready',
                            stages: _hasInitiallyLoaded
                                ? const [
                                    'Fetching items...',
                                    'Organizing products...',
                                    'Ready!',
                                  ]
                                : const [
                                    'Setting up...',
                                    'Loading products...',
                                    'Finalizing...',
                                  ],
                          );

                          // Wait for products to load
                          await Future.delayed(
                            const Duration(milliseconds: 1400),
                          );

                          if (mounted) {
                            // Hide bottom sheet
                            LoadingBottomSheet.hide(loadingContext);
                          }
                        },
                        onFilterSelected: _applyFilter,
                      );
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60.w,
                            height: 60.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 5.w,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF25A63E),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Setting up your shop',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Please wait...',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load categories',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(cartCategoriesProvider);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25A63E),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Search Bottom Sheet for searching categories and products
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
    final filterNotifier = ref.read(cartFilterProvider.notifier);
    filterNotifier.setSearchQuery(query.isEmpty ? null : query);

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
      error: (_, __) => _buildResultsList(_filteredCategories, []),
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

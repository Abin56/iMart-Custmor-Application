import 'package:flutter/foundation.dart' hide Category;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/product_display.dart';
import 'cart_filter_provider.dart';
import 'cart_repository_provider.dart';

part 'cart_paginated_provider.g.dart';

/// State for paginated products per category
class PaginatedProductsState {
  const PaginatedProductsState({
    required this.products,
    required this.hasMore,
    required this.isLoadingMore,
    this.currentPage = 1,
  });

  final List<ProductDisplay> products;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;

  PaginatedProductsState copyWith({
    List<ProductDisplay>? products,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return PaginatedProductsState(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Notifier for paginated products by category ID with lazy loading
@riverpod
class PaginatedCategoryProducts extends _$PaginatedCategoryProducts {
  @override
  Future<PaginatedProductsState> build(int categoryId) async {
    return _loadProducts(categoryId: categoryId, page: 1);
  }

  Future<PaginatedProductsState> _loadProducts({
    required int categoryId,
    required int page,
  }) async {
    final repository = ref.watch(cartRepositoryProvider);

    // IMPORTANT: Watch the filter state so provider rebuilds when filters change
    final filterState = ref.watch(cartFilterProvider);

    // Debug: Log the filter state being used

    final result = await repository.getCategoryProducts(
      categoryId: categoryId,
      page: page,
      productName: filterState.searchQuery,
      minPrice: filterState.minPrice,
      maxPrice: filterState.maxPrice,
      isDiscounted: filterState.isDiscounted,
      ordering: filterState.ordering,
    );

    // Filter valid products
    final validProducts = result.products.where((p) {
      return p.name.isNotEmpty;
    }).toList();

    final displayList = ProductDisplay.fromProductList(validProducts);

    // Filter display items
    final validDisplayList = displayList.where((item) {
      return item.productName.isNotEmpty && item.price.isNotEmpty;
    }).toList();

    final hasMore = result.next != null;

    return PaginatedProductsState(
      products: validDisplayList,
      hasMore: hasMore,
      isLoadingMore: false,
      currentPage: page,
    );
  }

  Future<void> loadMore(int categoryId) async {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    // Set loading state
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final newPageState = await _loadProducts(
        categoryId: categoryId,
        page: nextPage,
      );

      // Merge with existing products
      final allProducts = [...currentState.products, ...newPageState.products];

      state = AsyncValue.data(
        PaginatedProductsState(
          products: allProducts,
          hasMore: newPageState.hasMore,
          isLoadingMore: false,
          currentPage: nextPage,
        ),
      );
    } catch (e, stack) {
      // Revert loading state on error
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      state = AsyncValue.error(e, stack);
    }
  }
}

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/product_display.dart';
import 'cart_repository_provider.dart';

part 'cart_data_provider.g.dart';

/// Provider for fetching all categories (filtered to only show categories with products)
@riverpod
Future<List<Category>> cartCategories(Ref ref) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.getCategories();

  // Filter out null or invalid categories
  final validCategories = result.categories.where((cat) {
    return cat.name.isNotEmpty; // Only include categories with valid names
  }).toList();

  // Filter out categories that have no products
  final categoriesWithProducts = <Category>[];
  for (final category in validCategories) {
    try {
      final products = await ref.watch(
        categoryProductsProvider(category.id).future,
      );
      if (products.isNotEmpty) {
        categoriesWithProducts.add(category);
      } else {}
    } catch (e) {
      // Skip categories that failed to load products
    }
  }

  return categoriesWithProducts;
}

/// Provider family for fetching products by category ID
@riverpod
Future<List<ProductDisplay>> categoryProducts(Ref ref, int categoryId) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.getCategoryProducts(categoryId: categoryId);

  if (result.products.isNotEmpty) {
    // Filter out products without valid data
    final validProducts = result.products.where((product) {
      return product.name.isNotEmpty; // Only include products with valid names
    }).toList();

    final displayList = ProductDisplay.fromProductList(validProducts);

    // Filter out display items with null or empty data
    final validDisplayList = displayList.where((item) {
      return item.productName.isNotEmpty && item.price.isNotEmpty;
    }).toList();

    return validDisplayList;
  } else {
    return [];
  }
}

/// Provider for fetching all products from all categories (combined)
@riverpod
Future<Map<int, List<ProductDisplay>>> allCategoryProducts(Ref ref) async {
  final categories = await ref.watch(cartCategoriesProvider.future);
  final productMap = <int, List<ProductDisplay>>{};

  for (final category in categories) {
    final products = await ref.watch(
      categoryProductsProvider(category.id).future,
    );
    productMap[category.id] = products;
  }

  return productMap;
}

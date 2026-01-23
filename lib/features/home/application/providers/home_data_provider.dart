import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/product_display.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/promo_banner.dart';
import 'home_repository_provider.dart';

part 'home_data_provider.g.dart';

/// Provider for fetching categories with offer filter
@riverpod
Future<List<Category>> categories(Ref ref, {bool? isOffer}) async {
  final repository = ref.watch(homeRepositoryProvider);
  final response = await repository.getCategories(isOffer: isOffer);

  return response.categories;
}

/// Provider for fetching promotional banners
@riverpod
Future<List<PromoBanner>> banners(Ref ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final response = await repository.getBanners();

  return response.banners;
}

/// Provider for fetching offer categories (convenience provider)
@riverpod
Future<List<Category>> offerCategories(Ref ref) async {
  final result = await ref.watch(categoriesProvider(isOffer: true).future);

  return result;
}

/// Provider for fetching discounted products (Best Deals)
@riverpod
Future<List<ProductVariant>> discountedProducts(Ref ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final response = await repository.getDiscountedProducts();

  return response.products;
}

/// Provider for fetching products from first offer category (Mega Fresh offers)
@riverpod
Future<List<ProductDisplay>> offerCategoryProducts(Ref ref) async {
  // First, get offer categories
  final categories = await ref.watch(offerCategoriesProvider.future);

  if (categories.isEmpty) {
    return [];
  }

  final repository = ref.watch(homeRepositoryProvider);

  // Try each offer category until we find one with products
  for (var i = 0; i < categories.length; i++) {
    final category = categories[i];

    final response = await repository.getCategoryProducts(
      categoryId: category.id,
    );

    if (response.products.isNotEmpty) {
      // Convert Products to ProductDisplay (flattens variants)
      final displayList = ProductDisplay.fromProductList(response.products);

      return displayList;
    } else {}
  }

  return [];
}

import 'package:flutter/foundation.dart' hide Category;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/product_display.dart';
import 'cart_repository_provider.dart';

part 'cart_search_provider.g.dart';

/// Provider for searching products across all categories
@riverpod
class ProductSearch extends _$ProductSearch {
  @override
  Future<List<ProductDisplay>> build(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final repository = ref.read(cartRepositoryProvider);

    try {
      // Search across all categories by omitting categoryId
      // This searches all products via /api/products/v1/?product_name=query
      final result = await repository.getCategoryProducts(
        productName: query,
        page: 1,
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

      return validDisplayList;
    } catch (e) {
      rethrow;
    }
  }
}

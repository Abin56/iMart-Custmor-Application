import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/app/core/network/network_exceptions.dart';
import 'package:imart/app/core/providers/network_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../home/domain/entities/product.dart';
import '../../../domain/entities/category.dart';

part 'cart_api.g.dart';

@riverpod
CartApi cartApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CartApi(dio);
}

/// Response wrapper for paginated API responses
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;
}

/// API endpoints for cart feature
class CartEndpoints {
  const CartEndpoints._();

  static const String categories = 'api/products/v1/category/';
  static const String products = 'api/products/v1/';
}

/// Remote data source for cart feature
class CartApi {
  CartApi(this._dio);

  final Dio _dio;

  /// Fetch all categories
  Future<PaginatedResponse<Category>> getCategories({int? page}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) {
        queryParams['page'] = page;
      }

      final res = await _dio.get(
        CartEndpoints.categories,
        queryParameters: queryParams,
      );

      if (res.statusCode != 200) {
        throw Exception('Get categories failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final count = data['count'] as int;
      final next = data['next'] as String?;
      final previous = data['previous'] as String?;
      final results = (data['results'] as List)
          .map((item) => Category.fromMap(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(
        count: count,
        next: next,
        previous: previous,
        results: results,
      );
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }

  /// Fetch products with advanced filtering and sorting
  Future<PaginatedResponse<Product>> getCategoryProducts({
    int? categoryId, // Made optional for searching all products
    int? page,
    String? productName,
    double? minPrice,
    double? maxPrice,
    bool? isDiscounted,
    String? ordering,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      // Only add category_id if provided (omit for searching all products)
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }

      if (page != null) queryParams['page'] = page;
      if (productName != null && productName.isNotEmpty) {
        queryParams['product_name'] = productName;
      }
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (isDiscounted != null) queryParams['is_discounted'] = isDiscounted;
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }

      final res = await _dio.get(
        CartEndpoints.products,
        queryParameters: queryParams,
      );

      if (res.statusCode != 200) {
        throw Exception('Get products failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final count = data['count'] as int;
      final next = data['next'] as String?;
      final previous = data['previous'] as String?;
      final results = (data['results'] as List)
          .map((item) => Product.fromMap(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(
        count: count,
        next: next,
        previous: previous,
        results: results,
      );
    } catch (e) {
      final failure = mapDioError(e);
      throw Exception(failure.message);
    }
  }
}

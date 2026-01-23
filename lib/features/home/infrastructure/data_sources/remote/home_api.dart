import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imart/app/core/network/endpoints.dart';
import 'package:imart/app/core/network/network_exceptions.dart';
import 'package:imart/app/core/providers/network_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_variant.dart';
import '../../../domain/entities/promo_banner.dart';

part 'home_api.g.dart';

@riverpod
HomeApi homeApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return HomeApi(dio);
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

class HomeApi {
  HomeApi(this._dio);
  final Dio _dio;

  // ----------------------------------------------------------
  // 1. GET CATEGORIES (with offer filter)
  // ----------------------------------------------------------
  Future<PaginatedResponse<Category>> getCategories({
    bool? isOffer,
    int? page,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isOffer != null) {
        queryParams['is_offer'] = isOffer;
      }
      if (page != null) {
        queryParams['page'] = page;
      }

      final res = await _dio.get(
        HomeEndpoints.categories,
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

  // ----------------------------------------------------------
  // 2. GET BANNERS
  // ----------------------------------------------------------
  Future<PaginatedResponse<PromoBanner>> getBanners({int? page}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) {
        queryParams['page'] = page;
      }

      final res = await _dio.get(
        HomeEndpoints.banners,
        queryParameters: queryParams,
      );

      if (res.statusCode != 200) {
        throw Exception('Get banners failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final count = data['count'] as int;
      final next = data['next'] as String?;
      final previous = data['previous'] as String?;
      final results = (data['results'] as List)
          .map((item) => PromoBanner.fromMap(item as Map<String, dynamic>))
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

  // ----------------------------------------------------------
  // 3. GET DISCOUNTED PRODUCTS (Best Deals)
  // ----------------------------------------------------------
  Future<PaginatedResponse<ProductVariant>> getDiscountedProducts({
    int? page,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) {
        queryParams['page'] = page;
      }

      final res = await _dio.get(
        HomeEndpoints.discountedVariants,
        queryParameters: queryParams,
      );

      if (res.statusCode != 200) {
        throw Exception('Get discounted products failed: ${res.statusCode}');
      }

      final data = res.data as Map<String, dynamic>;
      final count = data['count'] as int;
      final next = data['next'] as String?;
      final previous = data['previous'] as String?;
      final results = (data['results'] as List)
          .map((item) => ProductVariant.fromMap(item as Map<String, dynamic>))
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

  // ----------------------------------------------------------
  // 4. GET PRODUCTS BY CATEGORY (Mega Fresh offers)
  // ----------------------------------------------------------
  Future<PaginatedResponse<Product>> getCategoryProducts({
    required int categoryId,
    int? page,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) {
        queryParams['page'] = page;
      }

      final res = await _dio.get(
        HomeEndpoints.categoryProducts(categoryId.toString()),
        queryParameters: queryParams,
      );

      if (res.statusCode != 200) {
        throw Exception('Get category products failed: ${res.statusCode}');
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

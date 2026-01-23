import '../../../home/domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/cart_repository.dart';
import '../data_sources/remote/cart_api.dart';

/// Implementation of CartRepository using remote API
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._api);

  final CartApi _api;

  @override
  Future<({List<Category> categories, int count, String? next})> getCategories({
    int? page,
  }) async {
    final response = await _api.getCategories(page: page);
    return (
      categories: response.results,
      count: response.count,
      next: response.next,
    );
  }

  @override
  Future<({List<Product> products, int count, String? next})>
  getCategoryProducts({
    int? categoryId,
    int? page,
    String? productName,
    double? minPrice,
    double? maxPrice,
    bool? isDiscounted,
    String? ordering,
  }) async {
    final response = await _api.getCategoryProducts(
      categoryId: categoryId,
      page: page,
      productName: productName,
      minPrice: minPrice,
      maxPrice: maxPrice,
      isDiscounted: isDiscounted,
      ordering: ordering,
    );
    return (
      products: response.results,
      count: response.count,
      next: response.next,
    );
  }
}

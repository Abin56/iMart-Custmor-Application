import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_sources/remote/home_api.dart';

/// Implementation of HomeRepository
/// Uses HomeApi to fetch data from remote server
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._homeApi);

  final HomeApi _homeApi;

  @override
  Future<({List<Category> categories, int count, String? next})> getCategories({
    bool? isOffer,
    int? page,
  }) async {
    final response = await _homeApi.getCategories(isOffer: isOffer, page: page);
    return (
      categories: response.results,
      count: response.count,
      next: response.next,
    );
  }

  @override
  Future<({List<PromoBanner> banners, int count, String? next})> getBanners({
    int? page,
  }) async {
    final response = await _homeApi.getBanners(page: page);
    return (
      banners: response.results,
      count: response.count,
      next: response.next,
    );
  }

  @override
  Future<({List<ProductVariant> products, int count, String? next})>
  getDiscountedProducts({int? page}) async {
    final response = await _homeApi.getDiscountedProducts(page: page);
    return (
      products: response.results,
      count: response.count,
      next: response.next,
    );
  }

  @override
  Future<({List<Product> products, int count, String? next})>
  getCategoryProducts({required int categoryId, int? page}) async {
    final response = await _homeApi.getCategoryProducts(
      categoryId: categoryId,
      page: page,
    );
    return (
      products: response.results,
      count: response.count,
      next: response.next,
    );
  }
}

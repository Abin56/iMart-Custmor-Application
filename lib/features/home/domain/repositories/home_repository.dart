import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/product_variant.dart';
import '../entities/promo_banner.dart';

/// Repository interface for home feature data
/// Defines contracts for fetching categories, banners, and products
abstract class HomeRepository {
  /// Get categories with optional offer filter
  /// Returns list of categories and pagination info
  Future<({List<Category> categories, int count, String? next})> getCategories({
    bool? isOffer,
    int? page,
  });

  /// Get promotional banners
  /// Returns list of banners and pagination info
  Future<({List<PromoBanner> banners, int count, String? next})> getBanners({
    int? page,
  });

  /// Get discounted product variants (Best Deals)
  /// Returns list of product variants with discounts and pagination info
  Future<({List<ProductVariant> products, int count, String? next})>
  getDiscountedProducts({int? page});

  /// Get products by category ID (Mega Fresh offers)
  /// Returns list of products (with nested variants) for a specific category
  Future<({List<Product> products, int count, String? next})>
  getCategoryProducts({required int categoryId, int? page});
}

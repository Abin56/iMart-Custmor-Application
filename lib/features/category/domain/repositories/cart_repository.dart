import '../../../home/domain/entities/product.dart';
import '../entities/category.dart';

/// Abstract repository for cart feature data operations
abstract class CartRepository {
  /// Fetch all categories
  Future<({List<Category> categories, int count, String? next})> getCategories({
    int? page,
  });

  /// Fetch products with advanced filtering and sorting
  /// If categoryId is null, searches across all categories
  Future<({List<Product> products, int count, String? next})>
  getCategoryProducts({
    int? categoryId,
    int? page,
    String? productName,
    double? minPrice,
    double? maxPrice,
    bool? isDiscounted,
    String? ordering,
  });
}

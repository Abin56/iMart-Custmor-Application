/// Static product model for UI display
class CategoryProduct {
  const CategoryProduct({
    required this.variantId,
    required this.variantName,
    required this.name,
    this.price,
    this.originalPrice,
    this.weight,
    this.imageUrl,
    this.thumbnailUrl,
    this.inStock = true,
    this.currentQuantity,
  });

  final String variantId;
  final String variantName;
  final String name;
  final bool inStock;
  final String? price;
  final String? originalPrice;
  final String? weight;
  final String? imageUrl;
  final String? thumbnailUrl;
  final int? currentQuantity;
}

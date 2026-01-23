import 'package:equatable/equatable.dart';

/// Product variant entity for discounted products
/// Represents a specific variant/SKU of a product with pricing and inventory
class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.sku,
    required this.name,
    required this.productId,
    required this.price,
    required this.discountedPrice,
    required this.weight,
    required this.currentQuantity,
    required this.currentStockUnit,
    this.trackInventory = false,
    this.isSelected = false,
    this.isPreorder = false,
    this.status = false,
    this.preorderEndDate,
    this.preorderGlobalThreshold,
    this.quantityLimitPerCustomer,
    this.tags,
    this.barCode,
    this.media = const [],
    this.productDescription,
    this.productRating,
    this.warehouseName,
    this.warehouseId,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    final mediaList =
        (map['media'] as List?)
            ?.map((item) => ProductMedia.fromMap(item as Map<String, dynamic>))
            .toList() ??
        [];

    return ProductVariant(
      id: map['id'] as int,
      sku: map['sku'] as String,
      name: map['name'] as String,
      productId: map['product_id'] as int,
      trackInventory: map['track_inventory'] as bool? ?? false,
      price: map['price'] as String,
      discountedPrice: map['discounted_price'] as String,
      isSelected: map['is_selected'] as bool? ?? false,
      isPreorder: map['is_preorder'] as bool? ?? false,
      preorderEndDate: map['preorder_end_date'] as String?,
      preorderGlobalThreshold: map['preorder_global_threshold'] as int?,
      quantityLimitPerCustomer: map['quantity_limit_per_customer'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      weight: map['weight'] as String,
      status: map['status'] as bool? ?? false,
      tags: map['tags'] as String?,
      barCode: map['bar_code'] as String?,
      media: mediaList,
      currentQuantity: map['current_quantity'] as int,
      currentStockUnit: map['current_stock_unit'] as String,
      productDescription: map['prod_description'] as String?,
      productRating: map['product_rating'] as String?,
      warehouseName: map['warehouse_name'] as String?,
      warehouseId: map['warehouse_id'] as int?,
    );
  }

  final int id;
  final String sku;
  final String name;
  final int productId;
  final bool trackInventory;
  final String price;
  final String discountedPrice;
  final bool isSelected;
  final bool isPreorder;
  final String? preorderEndDate;
  final int? preorderGlobalThreshold;
  final int? quantityLimitPerCustomer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String weight;
  final bool status;
  final String? tags;
  final String? barCode;
  final List<ProductMedia> media;
  final int currentQuantity;
  final String currentStockUnit;
  final String? productDescription;
  final String? productRating;
  final String? warehouseName;
  final int? warehouseId;

  // Helper getters
  double get priceValue => double.tryParse(price) ?? 0.0;
  double get discountedPriceValue => double.tryParse(discountedPrice) ?? 0.0;
  double get discountPercentage {
    if (priceValue == 0) return 0;
    return (priceValue - discountedPriceValue) / priceValue * 100;
  }

  bool get hasDiscount => discountedPriceValue < priceValue;
  String? get primaryImageUrl => media.isNotEmpty ? media.first.imageUrl : null;
  double get ratingValue => double.tryParse(productRating ?? '0') ?? 0.0;

  @override
  List<Object?> get props => [
    id,
    sku,
    name,
    productId,
    price,
    discountedPrice,
    media,
    currentQuantity,
  ];
}

/// Product media entity for product images
class ProductMedia extends Equatable {
  const ProductMedia({
    required this.id,
    required this.imageUrl,
    this.filePath,
    this.alt,
    this.externalUrl,
    this.oembedData,
    this.toRemove = false,
    this.productId,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductMedia.fromMap(Map<String, dynamic> map) {
    // Fix image URL - add https:// if missing
    String? fixImageUrl(String? url) {
      if (url == null || url.isEmpty) return url;
      if (url.startsWith('http://') ||
          url.startsWith('https://') ||
          url.startsWith('assets/')) {
        return url;
      }
      return 'https://$url';
    }

    return ProductMedia(
      id: map['id'] as int,
      filePath: map['file_path'] as String?,
      imageUrl: fixImageUrl(map['image'] as String) ?? '',
      alt: map['alt'] as String?,
      externalUrl: map['external_url'] as String?,
      oembedData: map['oembed_data'] as String?,
      toRemove: map['to_remove'] as bool? ?? false,
      productId: map['product_id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  final int id;
  final String? filePath;
  final String imageUrl;
  final String? alt;
  final String? externalUrl;
  final String? oembedData;
  final bool toRemove;
  final int? productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, imageUrl, productId];
}

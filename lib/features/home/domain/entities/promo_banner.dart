import 'package:equatable/equatable.dart';

/// Promotional banner entity for home screen carousel
/// Displays offers, discounts, and promotional messages
class PromoBanner extends Equatable {
  const PromoBanner({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    this.descriptionPlaintext,
    this.categoryId,
    this.productVariantId,
    this.productId,
  });

  factory PromoBanner.fromMap(Map<String, dynamic> map) {
    // Fix image URL - add https:// if missing
    final rawImageUrl = map['image'] as String;
    final fixedImageUrl =
        (!rawImageUrl.startsWith('http://') &&
            !rawImageUrl.startsWith('https://') &&
            !rawImageUrl.startsWith('assets/'))
        ? 'https://$rawImageUrl'
        : rawImageUrl;

    return PromoBanner(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: fixedImageUrl,
      description: map['description'] as String?,
      descriptionPlaintext: map['description_plaintext'] as String?,
      categoryId: map['category'] as int?,
      productVariantId: map['product_variant'] as int?,
      productId: map['product'] as int?,
    );
  }

  final int id;
  final String name;
  final String imageUrl;
  final String? description;
  final String? descriptionPlaintext;
  final int? categoryId;
  final int? productVariantId;
  final int? productId;

  // Helper getters for backward compatibility with existing UI
  String get title => name;
  String get subtitle => descriptionPlaintext ?? description ?? '';
  String? get code => null; // Not provided by API

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': imageUrl,
      'description': description,
      'description_plaintext': descriptionPlaintext,
      'category': categoryId,
      'product_variant': productVariantId,
      'product': productId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    description,
    descriptionPlaintext,
    categoryId,
    productVariantId,
    productId,
  ];
}

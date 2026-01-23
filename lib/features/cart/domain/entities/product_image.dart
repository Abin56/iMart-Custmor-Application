import 'package:equatable/equatable.dart';

/// Product image entity
/// Represents an image associated with a product variant
class ProductImage extends Equatable {
  const ProductImage({required this.id, required this.image, this.alt});

  final int id;
  final String image;
  final String? alt;

  /// Fix image URL by prepending https:// if needed
  String get imageUrl {
    if (image.isEmpty) return image;
    if (image.startsWith('http://') ||
        image.startsWith('https://') ||
        image.startsWith('assets/')) {
      return image;
    }
    return 'https://$image';
  }

  @override
  List<Object?> get props => [id, image, alt];

  ProductImage copyWith({int? id, String? image, String? alt}) {
    return ProductImage(
      id: id ?? this.id,
      image: image ?? this.image,
      alt: alt ?? this.alt,
    );
  }
}

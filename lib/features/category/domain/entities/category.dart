import 'package:equatable/equatable.dart';

/// Category entity representing a product category
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.icon,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    // Get background_image_url and add https:// if it's missing
    var imageUrl = map['background_image_url'] as String?;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Add https:// if not present
      if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
        imageUrl = 'https://$imageUrl';
      }
    }

    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      image: imageUrl,
      icon: map['icon'] as String?,
    );
  }

  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? icon;

  @override
  List<Object?> get props => [id, name, description, image, icon];
}

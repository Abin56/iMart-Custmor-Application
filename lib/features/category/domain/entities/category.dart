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

    // Parse description - handle both String and Map formats
    String? parseDescription(dynamic description) {
      if (description == null) return null;
      if (description is String) return description;
      if (description is Map) {
        // If it's a map, try to get the 'en' key or the first value
        if (description.containsKey('en')) {
          return description['en'] as String?;
        }
        // Return the first value if 'en' key doesn't exist
        return description.values.firstOrNull?.toString();
      }
      return description.toString();
    }

    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      description: parseDescription(map['description']),
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

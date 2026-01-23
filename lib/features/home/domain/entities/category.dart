import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Category entity representing a product category
/// Used in home screen category carousel and category listing
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.descriptionPlaintext,
    this.parentId,
    this.backgroundImageUrl,
    this.backgroundImagePath,
    this.backgroundImageAlt,
    this.isOffer,
    this.createdAt,
    this.updatedAt,
    this.icon = Icons.shopping_basket_outlined,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    // Fix background image URL - add https:// if missing
    String? fixBackgroundImageUrl(String? url) {
      if (url == null || url.isEmpty) return url;
      if (url.startsWith('http://') ||
          url.startsWith('https://') ||
          url.startsWith('assets/')) {
        return url;
      }
      return 'https://$url';
    }

    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      slug: map['slug'] as String?,
      description: map['description'] as String?,
      descriptionPlaintext: map['description_plaintext'] as String?,
      parentId: map['parent_id'] as int?,
      backgroundImageUrl: fixBackgroundImageUrl(
        map['background_image_url'] as String?,
      ),
      backgroundImagePath: fixBackgroundImageUrl(
        map['background_image_path'] as String?,
      ),
      backgroundImageAlt: map['background_image_alt'] as String?,
      isOffer: map['is_offer'] as bool?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? descriptionPlaintext;
  final int? parentId;
  final String? backgroundImageUrl;
  final String? backgroundImagePath;
  final String? backgroundImageAlt;
  final bool? isOffer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final IconData icon; // For UI display

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'description_plaintext': descriptionPlaintext,
      'parent_id': parentId,
      'background_image_url': backgroundImageUrl,
      'background_image_path': backgroundImagePath,
      'background_image_alt': backgroundImageAlt,
      'is_offer': isOffer,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    descriptionPlaintext,
    parentId,
    backgroundImageUrl,
    backgroundImagePath,
    backgroundImageAlt,
    isOffer,
    createdAt,
    updatedAt,
  ];
}

import 'package:equatable/equatable.dart';

/// Base product entity with descriptive information
class ProductBase extends Equatable {
  const ProductBase({
    required this.id,
    required this.name,
    required this.categoryId,
    this.description,
    this.brand,
    this.manufacturer,
    this.tags = const [],
    this.metaTitle,
    this.metaDescription,
    this.slug,
    this.isActive = true,
  });

  final int id;
  final String name;
  final int categoryId;
  final String? description;
  final String? brand;
  final String? manufacturer;
  final List<String> tags;
  final String? metaTitle;
  final String? metaDescription;
  final String? slug;
  final bool isActive;

  @override
  List<Object?> get props => [
    id,
    name,
    categoryId,
    description,
    brand,
    manufacturer,
    tags,
    metaTitle,
    metaDescription,
    slug,
    isActive,
  ];
}

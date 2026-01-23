import 'package:equatable/equatable.dart';

/// Media entity for product variant (image or video)
class ProductVariantMedia extends Equatable {
  const ProductVariantMedia({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.position,
  });

  final int id;
  final String type; // 'image' or 'video'
  final String url;
  final String? thumbnailUrl;
  final int? position;

  @override
  List<Object?> get props => [id, type, url, thumbnailUrl, position];
}

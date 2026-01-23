import 'package:equatable/equatable.dart';

/// Image entity for product variant
class ProductVariantImage extends Equatable {
  const ProductVariantImage({
    required this.id,
    required this.url,
    this.position,
  });

  final int id;
  final String url;
  final int? position;

  @override
  List<Object?> get props => [id, url, position];
}

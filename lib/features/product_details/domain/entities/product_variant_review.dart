import 'package:equatable/equatable.dart';

/// Review entity for product variant
class ProductVariantReview extends Equatable {
  const ProductVariantReview({
    required this.id,
    required this.rating,
    this.comment,
    this.userName,
    this.createdAt,
  });

  final int id;
  final double rating;
  final String? comment;
  final String? userName;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, rating, comment, userName, createdAt];
}

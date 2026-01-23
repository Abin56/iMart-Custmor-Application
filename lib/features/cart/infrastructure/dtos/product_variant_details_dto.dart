// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_variant_details.dart';
import 'product_image_dto.dart';

part 'product_variant_details_dto.freezed.dart';
part 'product_variant_details_dto.g.dart';

@freezed
class ProductVariantDetailsDto with _$ProductVariantDetailsDto {
  const factory ProductVariantDetailsDto({
    required int id,
    required String sku,
    required String name,
    required String price,
    @JsonKey(name: 'current_quantity') required int currentQuantity,
    @JsonKey(name: 'product_id') int? productId,
    @JsonKey(name: 'discounted_price') String? discountedPrice,
    @JsonKey(name: 'track_inventory') bool? trackInventory,
    @JsonKey(name: 'quantity_limit_per_customer') int? quantityLimitPerCustomer,
    @JsonKey(name: 'is_preorder') bool? isPreorder,
    @JsonKey(name: 'preorder_global_threshold') int? preorderGlobalThreshold,
    List<ProductImageDto>? images,
    @JsonKey(name: 'preorder_end_date') DateTime? preorderEndDate,
  }) = _ProductVariantDetailsDto;

  const ProductVariantDetailsDto._();

  factory ProductVariantDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantDetailsDtoFromJson(json);

  /// Convert DTO to Entity
  ProductVariantDetails toEntity() {
    return ProductVariantDetails(
      id: id,
      sku: sku,
      name: name,
      productId: productId ?? 0,
      price: price,
      discountedPrice: discountedPrice ?? price,
      trackInventory: trackInventory ?? false,
      currentQuantity: currentQuantity,
      quantityLimitPerCustomer: quantityLimitPerCustomer ?? 999,
      isPreorder: isPreorder ?? false,
      preorderGlobalThreshold: preorderGlobalThreshold ?? 0,
      images: images?.map((img) => img.toEntity()).toList() ?? [],
      preorderEndDate: preorderEndDate,
    );
  }
}

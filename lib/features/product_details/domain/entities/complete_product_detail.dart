import 'package:equatable/equatable.dart';

import 'product_base.dart';
import 'product_variant.dart';

/// Complete product detail entity (merged variant + base)
class CompleteProductDetail extends Equatable {
  const CompleteProductDetail({required this.variant, required this.base});

  final ProductVariant variant;
  final ProductBase base;

  /// Get product name (base or variant)
  String get productName => base.name;

  /// Get variant name
  String get variantName => variant.name;

  /// Get full display name
  String get fullName {
    if (variantName.toLowerCase().contains(productName.toLowerCase())) {
      return variantName;
    }
    return '$productName - $variantName';
  }

  /// Check if product is available
  bool get isAvailable => variant.isInStock && base.isActive;

  /// Copy with method for updates
  CompleteProductDetail copyWith({ProductVariant? variant, ProductBase? base}) {
    return CompleteProductDetail(
      variant: variant ?? this.variant,
      base: base ?? this.base,
    );
  }

  @override
  List<Object?> get props => [variant, base];
}

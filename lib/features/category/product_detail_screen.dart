import 'package:flutter/material.dart';
import 'package:imart/features/category/models/category_product.dart';
import 'package:imart/features/product_details/presentation/product_detail_screen.dart'
    as new_product_detail;

/// Legacy Product Detail Screen - Redirects to new implementation
///
/// This file is maintained for backward compatibility with existing navigation code.
/// All new code should use the new ProductDetailScreen directly from the
/// product_details feature, which includes:
/// - HTTP 304 caching for optimal performance
/// - Real-time stock updates (30-second polling)
/// - Wishlist integration
/// - Complete backend integration
///
/// Migration: Replace CategoryProduct navigation with direct variant ID:
/// ```dart
/// // Old way (still works via this redirect):
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => ProductDetailScreen(product: categoryProduct),
/// ));
///
/// // New way (recommended):
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => new_product_detail.ProductDetailScreen(
///     variantId: int.parse(categoryProduct.variantId),
///   ),
/// ));
/// ```
@Deprecated('Use new ProductDetailScreen from product_details feature instead')
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.product, super.key});
  final CategoryProduct product;

  @override
  Widget build(BuildContext context) {
    // Convert String variantId to int
    final variantId = int.tryParse(product.variantId);

    if (variantId == null) {
      // If variantId is invalid, show error screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Invalid product ID: ${product.variantId}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Redirect to new implementation with backend integration
    return new_product_detail.ProductDetailScreen(variantId: variantId);
  }
}

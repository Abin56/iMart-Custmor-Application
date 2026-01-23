// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../wishlist/application/providers/wishlist_providers.dart';
import '../../domain/entities/complete_product_detail.dart';
import '../../domain/repositories/product_detail_repository.dart';
import '../../infrastructure/repositories/product_detail_repository_impl.dart';
import '../states/product_detail_state.dart';

part 'product_detail_provider.g.dart';

/// AutoDisposeFamily provider for product details
/// Creates separate state for each variant ID
/// Automatically disposes when no longer watched (navigated away)
@riverpod
class ProductDetail extends _$ProductDetail {
  ProductDetailRepository get _repository =>
      ref.read(productDetailRepositoryProvider);

  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 30);

  @override
  ProductDetailState build(int variantId) {
    // Initialize by loading product details
    _loadProductDetail();

    // Start real-time polling
    _startPolling();

    // Cleanup timer when provider is disposed
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    return const ProductDetailState.initial();
  }

  /// Load product detail (cache-first with HTTP 304)
  Future<void> _loadProductDetail() async {
    try {
      state = const ProductDetailState.loading();

      final result = await _repository.getCompleteProductDetail(
        variantId: variantId,
        forceRefresh: false,
      );

      result.fold(
        (failure) {
          state = ProductDetailState.error(failure: failure);
        },
        (product) {
          // Sync wishlist status with global wishlist provider
          final productIdStr = variantId.toString();
          final isInGlobalWishlist = ref.read(
            isInWishlistProvider(productIdStr),
          );

          // If global wishlist state differs from product state, update product
          if (isInGlobalWishlist != product.variant.isWishlisted) {
            final updatedVariant = product.variant.copyWith(
              isWishlisted: isInGlobalWishlist,
            );
            final updatedProduct = product.copyWith(variant: updatedVariant);
            state = ProductDetailState.loaded(product: updatedProduct);
          } else {
            state = ProductDetailState.loaded(product: product);
          }
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Refresh product detail (force fetch)
  Future<void> refresh() async {
    try {
      final currentState = state;

      // Show refreshing state if we have data
      if (currentState is ProductDetailLoaded) {
        state = ProductDetailState.refreshing(product: currentState.product);
      } else {
        state = const ProductDetailState.loading();
      }

      final result = await _repository.getCompleteProductDetail(
        variantId: variantId,
        forceRefresh: true,
      );

      result.fold(
        (failure) {
          // Preserve previous data on error
          if (currentState is ProductDetailLoaded) {
            state = ProductDetailState.error(
              failure: failure,
              previousProduct: currentState.product,
            );
          } else {
            state = ProductDetailState.error(failure: failure);
          }
        },
        (product) {
          // Sync wishlist status with global wishlist provider
          final productIdStr = variantId.toString();
          final isInGlobalWishlist = ref.read(
            isInWishlistProvider(productIdStr),
          );

          // If global wishlist state differs from product state, update product
          if (isInGlobalWishlist != product.variant.isWishlisted) {
            final updatedVariant = product.variant.copyWith(
              isWishlisted: isInGlobalWishlist,
            );
            final updatedProduct = product.copyWith(variant: updatedVariant);
            state = ProductDetailState.loaded(product: updatedProduct);
          } else {
            state = ProductDetailState.loaded(product: product);
          }
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Start real-time polling (every 30 seconds)
  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      final currentState = state;

      // Only poll if we have data loaded (not during errors or initial loading)
      if (currentState is ProductDetailLoaded ||
          currentState is ProductDetailRefreshing) {
        _pollUpdate();
      }
    });
  }

  /// Poll for updates (silent refresh)
  Future<void> _pollUpdate() async {
    try {
      // Don't change state during polling - update silently
      final result = await _repository.getCompleteProductDetail(
        variantId: variantId,
        forceRefresh: false, // Use HTTP 304 caching
      );

      result.fold(
        (failure) {
          // Don't update state on polling errors
        },
        (product) {
          final currentState = state;
          // Only update if data actually changed
          if (currentState is ProductDetailLoaded) {
            // Sync wishlist status with global wishlist provider
            final productIdStr = variantId.toString();
            final isInGlobalWishlist = ref.read(
              isInWishlistProvider(productIdStr),
            );

            // Override with global wishlist state
            final syncedProduct =
                isInGlobalWishlist != product.variant.isWishlisted
                ? product.copyWith(
                    variant: product.variant.copyWith(
                      isWishlisted: isInGlobalWishlist,
                    ),
                  )
                : product;

            if (_hasProductChanged(currentState.product, syncedProduct)) {
              state = ProductDetailState.loaded(product: syncedProduct);
            }
          }
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Check if product data has changed
  bool _hasProductChanged(
    CompleteProductDetail oldProduct,
    CompleteProductDetail newProduct,
  ) {
    final oldVariant = oldProduct.variant;
    final newVariant = newProduct.variant;

    return oldVariant.stock != newVariant.stock ||
        oldVariant.isWishlisted != newVariant.isWishlisted ||
        oldVariant.price != newVariant.price ||
        oldVariant.discountedPrice != newVariant.discountedPrice;
  }

  /// Toggle wishlist status
  Future<void> toggleWishlist() async {
    final currentState = state;

    if (currentState is! ProductDetailLoaded) {
      return;
    }

    try {
      final currentProduct = currentState.product;
      final currentWishlistStatus = currentProduct.variant.isWishlisted;

      // Optimistic update
      state = ProductDetailState.wishlistToggling(product: currentProduct);

      final result = await _repository.toggleWishlist(
        variantId: variantId,
        isWishlisted: !currentWishlistStatus,
      );

      result.fold(
        (failure) {
          // Revert to previous state
          state = ProductDetailState.error(
            failure: failure,
            previousProduct: currentProduct,
          );

          // Return to loaded state after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            state = ProductDetailState.loaded(product: currentProduct);
          });
        },
        (newStatus) {
          // Sync with global wishlist provider
          final productIdStr = variantId.toString();
          if (newStatus) {
            // Added to wishlist - notify wishlist provider
            ref.read(wishlistProvider.notifier).addToWishlist(productIdStr);
          } else {
            // Removed from wishlist - notify wishlist provider
            ref
                .read(wishlistProvider.notifier)
                .removeFromWishlistByProductId(productIdStr);
          }

          // Update product with new wishlist status
          final updatedVariant = currentProduct.variant.copyWith(
            isWishlisted: newStatus,
          );
          final updatedProduct = currentProduct.copyWith(
            variant: updatedVariant,
          );

          state = ProductDetailState.loaded(product: updatedProduct);
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Clear cache and reload
  Future<void> clearAndReload() async {
    await _repository.clearVariantCache(variantId);
    await _loadProductDetail();
  }
}

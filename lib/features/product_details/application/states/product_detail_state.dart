import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:imart/app/core/error/failure.dart';
import '../../domain/entities/complete_product_detail.dart';

part 'product_detail_state.freezed.dart';

/// Product detail state using Freezed for type-safe state management
@freezed
sealed class ProductDetailState with _$ProductDetailState {
  /// Initial state before any data is loaded
  const factory ProductDetailState.initial() = ProductDetailInitial;

  /// Loading state while fetching data
  const factory ProductDetailState.loading() = ProductDetailLoading;

  /// Data loaded successfully
  const factory ProductDetailState.loaded({
    required CompleteProductDetail product,
  }) = ProductDetailLoaded;

  /// Refreshing data (showing current data while fetching new)
  const factory ProductDetailState.refreshing({
    required CompleteProductDetail product,
  }) = ProductDetailRefreshing;

  /// Wishlist toggle in progress
  const factory ProductDetailState.wishlistToggling({
    required CompleteProductDetail product,
  }) = ProductDetailWishlistToggling;

  /// Error state with failure details
  const factory ProductDetailState.error({
    required Failure failure,
    CompleteProductDetail? previousProduct,
  }) = ProductDetailError;
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../app/core/error/failure.dart';
import '../../domain/entities/wishlist_item.dart';

part 'wishlist_state.freezed.dart';

@freezed
sealed class WishlistState with _$WishlistState {
  const factory WishlistState.initial() = WishlistInitial;

  const factory WishlistState.loading() = WishlistLoading;

  const factory WishlistState.loaded({
    required List<WishlistItem> items,
    @Default(false) bool isRefreshing,
  }) = WishlistLoaded;

  const factory WishlistState.refreshing({required List<WishlistItem> items}) =
      WishlistRefreshing;

  const factory WishlistState.error({
    required Failure failure,
    WishlistState? previousState,
  }) = WishlistError;
}

/// Extension methods for WishlistState
extension WishlistStateX on WishlistState {
  /// Get items regardless of state
  List<WishlistItem> get items {
    return when(
      initial: () => [],
      loading: () => [],
      loaded: (items, _) => items,
      refreshing: (items) => items,
      error: (_, previousState) => previousState?.items ?? [],
    );
  }

  /// Check if has items
  bool get hasItems => items.isNotEmpty;

  /// Get item count
  int get itemCount => items.length;

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Get wishlist item by product ID
  WishlistItem? getWishlistItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }
}
